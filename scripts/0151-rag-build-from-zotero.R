# scripts/04_planning/0151-rag-build-from-zotero.R
# ---------------------------------------------------------------------------
# PORTABLE ragnar build: pull the report PDFs FRESH from the Zotero group library
# (cloud-synced, canonical) and build the store — so data/rag/<name>.duckdb is
# reproducible on ANY machine (M1/M4) with no file shuttling.
#
# The store binary is NOT tracked in git (it's gitignored, ~100 MB, and
# nomic-embed-text is deterministic but the DuckDB file is not bit-identical across
# machines). The reproducible artifact is THIS SCRIPT + the Zotero library. To
# rebuild anywhere: Ollama + `ollama pull nomic-embed-text`, then run this.
#
# INPUT:  STORE_NAME (env; default "peace"), COLLECTIONS (env; comma-sep Zotero
#         group-4733734 collection keys; default = the Peace set),
#         Zotero API key — see CREDENTIAL below.
# OUTPUT: data/rag/<STORE_NAME>.duckdb  (PDFs cached under data/rag/_pdfs/<name>/)
# Requires: ragnar, DBI, jsonlite, curl; Ollama running with nomic-embed-text.
#
# CREDENTIAL: 1Password is the canonical home and rotation ledger; a materialized
#   local file is the runtime path. This is the same shape rtj uses for the DO
#   token (1P canonical, gitignored `terraform.tfvars` on disk at apply time) —
#   see NewGraphEnvironment/cyclops#9 and #10. Resolution order:
#     1. ZOTERO_API_KEY env var.
#     2. Key file — default ~/.config/newgraph/zotero-api-key (override with
#        ZOTERO_KEY_FILE). Provision ONCE per machine from your own terminal,
#        where the 1Password prompt can actually be approved:
#          mkdir -p ~/.config/newgraph && chmod 700 ~/.config/newgraph
#          (umask 077; op read "op://newgraph/Zotero API Key/credential" \
#             > ~/.config/newgraph/zotero-api-key)
#        Keep it outside every git repo. Record the machine in cyclops
#        inventory.md so rotation knows every copy to update — untracked copies,
#        not files as such, were the actual failure in cyclops#9.
#     3. `op read` — interactive fallback. Needs a GUI session to approve; in a
#        headless context (no TTY, no login keychain — e.g. the M1 agent shell)
#        it just fails with "authorization timeout". Hence tiers 1 and 2.
#   The key is never passed on a command line (visible in `ps aux`) — it goes into
#   a chmod-600 curl config file that is removed on exit.
# ---------------------------------------------------------------------------
suppressMessages({library(ragnar); library(DBI); library(jsonlite)})
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# ---- credential -------------------------------------------------------------
op_ref   <- Sys.getenv("ZOTERO_OP_REF", "op://newgraph/Zotero API Key/credential")
key_file <- path.expand(Sys.getenv("ZOTERO_KEY_FILE", "~/.config/newgraph/zotero-api-key"))
op_err   <- ""

key <- trimws(Sys.getenv("ZOTERO_API_KEY"))                       # 1. env
if (!nzchar(key) && file.exists(key_file))                        # 2. materialized file
  key <- trimws(readLines(key_file, warn = FALSE)[1] %||% "")
if (!nzchar(key) && nzchar(Sys.which("op"))) {                    # 3. interactive op
  message("No ZOTERO_API_KEY and no key file at ", key_file,
          " — falling back to 1Password. APPROVE THE PROMPT NOW (it times out fast; ",
          "this cannot work in a headless session).")
  out <- suppressWarnings(
    system2("op", c("read", shQuote(op_ref)), stdout = TRUE, stderr = TRUE))
  st  <- attr(out, "status") %||% 0
  if (!identical(st, 0)) op_err <- paste(out, collapse = " ")     # keep op's message
  key <- if (identical(st, 0)) trimws(paste(out, collapse = "")) else ""
}
if (!nzchar(key))
  stop("Could not resolve the Zotero API key.",
       if (nzchar(op_err)) paste0("\n  op said: ", op_err) else "",
       "\n  Provision the key file once, from a terminal where you can approve 1Password:",
       "\n    mkdir -p ~/.config/newgraph && chmod 700 ~/.config/newgraph",
       "\n    (umask 077; op read ", shQuote(op_ref), " > ", key_file, ")",
       "\n  Then re-run — no prompt, works headless. See NewGraphEnvironment/cyclops#9.",
       call. = FALSE)

# curl reads the auth header from this file so the key never lands in the process
# table; 600 perms are set before the secret is written, and it is removed on exit.
curl_cfg <- file.path(tempdir(), paste0(".zotero-curl-", Sys.getpid()))
file.create(curl_cfg)
Sys.chmod(curl_cfg, "600")
writeLines(sprintf('header = "Zotero-API-Key: %s"', key), curl_cfg)
# NOTE: on.exit() does NOT fire at a script's top level (verified — neither on a
# clean exit nor on stop()), so it would silently leave the secret on disk.
# reg.finalizer(onexit = TRUE) does fire in both cases.
reg.finalizer(environment(), function(e) unlink(curl_cfg, force = TRUE), onexit = TRUE)

group <- "4733734"
store_name <- Sys.getenv("STORE_NAME", "peace")
# pine - PINE, peace arm - PCEA, parsnip arm - PARA, mackenzie (regional-extent items)
colls <- strsplit(Sys.getenv("COLLECTIONS", "B5XW948R,9QAJJJQW,9TP5AFIG,5USQ8DRG"), ",")[[1]]
dl_dir <- file.path("data", "rag", "_pdfs", store_name)
dir.create(dl_dir, recursive = TRUE, showWarnings = FALSE)

api <- function(path, query = "") {
  url <- sprintf("https://api.zotero.org/groups/%s/%s%s", group, path, query)
  txt <- system2("curl", c("-s", "--config", shQuote(curl_cfg), shQuote(url)), stdout = TRUE)
  jsonlite::fromJSON(paste(txt, collapse = ""), simplifyVector = FALSE)
}

# ---- gather PDF attachment keys across the collections ----------------------
att <- list()
for (c in colls) {
  start <- 0
  repeat {
    items <- api(sprintf("collections/%s/items/top", c), sprintf("?format=json&limit=100&start=%d", start))
    if (length(items) == 0) break
    for (it in items) {
      kids <- api(sprintf("items/%s/children", it$key))
      for (k in kids) if (isTRUE(k$data$contentType == "application/pdf"))
        att[[k$key]] <- list(key = k$key, filename = k$data$filename %||% paste0(k$key, ".pdf"))
    }
    if (length(items) < 100) break
    start <- start + 100
  }
}
message("PDF attachments found across ", length(colls), " collections: ", length(att))

# ---- download fresh (cache by attachment key) -------------------------------
for (a in att) {
  dest <- file.path(dl_dir, paste0(a$key, ".pdf"))
  if (!file.exists(dest) || file.info(dest)$size < 1000) {
    system2("curl", c("-sL", "--config", shQuote(curl_cfg),
                      shQuote(sprintf("https://api.zotero.org/groups/%s/items/%s/file", group, a$key)),
                      "-o", shQuote(dest)))
  }
}
pdfs <- list.files(dl_dir, pattern = "[.]pdf$", full.names = TRUE)
pdfs <- pdfs[vapply(pdfs, function(f) grepl("PDF", system2("file", c("-b", shQuote(f)), stdout = TRUE)), logical(1))]
message("valid PDFs to ingest: ", length(pdfs))
stopifnot("no PDFs downloaded" = length(pdfs) > 0)

# ---- build the store --------------------------------------------------------
store_path <- file.path("data", "rag", paste0(store_name, ".duckdb"))
store <- ragnar_store_create(store_path, embed = \(x) embed_ollama(x, model = "nomic-embed-text"), overwrite = TRUE)
ragnar_store_ingest(store, pdfs, progress = TRUE)
n_docs   <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM documents")$n
n_chunks <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM embeddings")$n
DBI::dbDisconnect(store@con)
message("Store: ", store_path, " | docs: ", n_docs, " | chunks: ", n_chunks, " (Zotero-sourced, portable)")
