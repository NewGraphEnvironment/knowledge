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
# CREDENTIAL: 1Password is the vault (NewGraphEnvironment/cyclops#9) — the old
#   plaintext ~/.zotero-api-key is gone, do NOT reintroduce it. Resolution order:
#     1. ZOTERO_API_KEY env var — the headless path. Set it from a 1Password
#        service account (export OP_SERVICE_ACCOUNT_TOKEN, then
#        ZOTERO_API_KEY=$(op read "op://newgraph/Zotero API Key/credential"))
#        so unattended/cron runs never block on an approval prompt.
#     2. `op read` — the interactive path. Prompts for Touch ID / desktop approval
#        ONCE per run (the key is read a single time, not per request). Without a
#        service account token `op` has no persistent CLI session, so an
#        unapproved prompt just times out and the run fails.
#   The key is never passed on a command line (visible in `ps aux`) — it goes into
#   a chmod-600 curl config file that is removed on exit.
# ---------------------------------------------------------------------------
suppressMessages({library(ragnar); library(DBI); library(jsonlite)})
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# ---- credential -------------------------------------------------------------
op_ref <- Sys.getenv("ZOTERO_OP_REF", "op://newgraph/Zotero API Key/credential")
key <- trimws(Sys.getenv("ZOTERO_API_KEY"))
if (!nzchar(key)) {
  if (!nzchar(Sys.which("op")))
    stop("No ZOTERO_API_KEY and no `op` on PATH. Set ZOTERO_API_KEY, or install the ",
         "1Password CLI. See NewGraphEnvironment/cyclops#9.", call. = FALSE)
  message("Reading Zotero key from 1Password (", op_ref, ") — APPROVE THE PROMPT NOW ",
          "(op's approval window is short and it fails with 'authorization timeout').")
  out <- suppressWarnings(
    system2("op", c("read", shQuote(op_ref)), stdout = TRUE, stderr = TRUE))
  st  <- attr(out, "status") %||% 0
  # op writes errors to the captured stream; keep them for the failure message
  if (!identical(st, 0)) op_err <- paste(out, collapse = " ") else op_err <- ""
  key <- if (identical(st, 0)) trimws(paste(out, collapse = "")) else ""
}
if (!nzchar(key))
  stop("Could not resolve the Zotero API key.",
       if (nzchar(Sys.getenv("ZOTERO_API_KEY"))) "" else
         paste0("\n  op said: ", if (exists("op_err") && nzchar(op_err)) op_err else "(no output)"),
       "\n  'authorization timeout' means the 1Password prompt was not approved in time.",
       "\n  For unattended runs export OP_SERVICE_ACCOUNT_TOKEN (no prompt), or set",
       "\n  ZOTERO_API_KEY directly. See NewGraphEnvironment/cyclops#9.",
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
