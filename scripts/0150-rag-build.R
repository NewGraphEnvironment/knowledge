# scripts/04_planning/0150-rag-build.R
# ---------------------------------------------------------------------------
# Build a ragnar (DuckDB) store over the harvested watershed-group report PDFs so
# their *results sections* are queryable ("what does Guppy recommend for Wildmare?").
#
# WHY: the value of the harvested reports is in their prose/tables, not just their
# existence. Local Ollama embeddings (nomic-embed-text) keep it offline + free.
#
# INPUT:  PDF_DIR (env; dir of harvested PDFs) — these are the same files loaded to
#         Zotero pine - PINE. Durable variant: download attachments fresh from Zotero
#         (resolve attachKeys -> ~/Zotero/storage) to guarantee index == curated corpus.
# OUTPUT: data/rag/<wsg>.duckdb  (gitignored)
# Prereq: ollama serve + `ollama pull nomic-embed-text`; R pkgs ragnar, DBI.
# ---------------------------------------------------------------------------

suppressMessages({library(ragnar); library(DBI)})

wsg     <- tolower(if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else "pine")
pdf_dir <- Sys.getenv("PDF_DIR",
  "/private/tmp/claude-501/-Users-airvine-Projects-repo-fish-passage-template-reporting/e183f2c3-3a66-4a4b-a375-24fc6560ada4/scratchpad/pine_pdfs")
pdf_paths <- list.files(pdf_dir, pattern = "[.]pdf$", full.names = TRUE)
stopifnot("no PDFs found" = length(pdf_paths) > 0)
message("Ingesting ", length(pdf_paths), " PDFs from ", pdf_dir)

store_path <- file.path("data", "rag", paste0(wsg, ".duckdb"))
dir.create(dirname(store_path), recursive = TRUE, showWarnings = FALSE)

store <- ragnar_store_create(
  location = store_path,
  embed    = \(x) embed_ollama(x, model = "nomic-embed-text"),
  overwrite = TRUE
)
ragnar_store_ingest(store, pdf_paths, progress = TRUE)

n_docs   <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM documents")$n
n_chunks <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM embeddings")$n
DBI::dbDisconnect(store@con)
message("Store: ", store_path, " | docs: ", n_docs, " | chunks: ", n_chunks)
