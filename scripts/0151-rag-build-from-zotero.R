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
#         ~/.zotero-api-key
# OUTPUT: data/rag/<STORE_NAME>.duckdb  (PDFs cached under data/rag/_pdfs/<name>/)
# Requires: ragnar, DBI, jsonlite, curl; Ollama running with nomic-embed-text.
# ---------------------------------------------------------------------------
suppressMessages({library(ragnar); library(DBI); library(jsonlite)})
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

key   <- trimws(readLines("~/.zotero-api-key", warn = FALSE)[1])
group <- "4733734"
store_name <- Sys.getenv("STORE_NAME", "peace")
# pine - PINE, peace arm - PCEA, parsnip arm - PARA, mackenzie (regional-extent items)
colls <- strsplit(Sys.getenv("COLLECTIONS", "B5XW948R,9QAJJJQW,9TP5AFIG,5USQ8DRG"), ",")[[1]]
dl_dir <- file.path("data", "rag", "_pdfs", store_name)
dir.create(dl_dir, recursive = TRUE, showWarnings = FALSE)

api <- function(path, query = "") {
  url <- sprintf("https://api.zotero.org/groups/%s/%s%s", group, path, query)
  txt <- system2("curl", c("-s", "-H", shQuote(paste0("Zotero-API-Key: ", key)), shQuote(url)), stdout = TRUE)
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
    system2("curl", c("-sL", "-H", shQuote(paste0("Zotero-API-Key: ", key)),
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
