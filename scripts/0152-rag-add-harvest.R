# scripts/0152-rag-add-harvest.R
# ---------------------------------------------------------------------------
# Add harvested EcoCat report PDFs (named "<EXTENT>__<reportId>.pdf" by the
# wf_*_report_harvest workflows) into an existing ragnar store, deduped by
# EcoCat reportId so a report already in the store is not ingested twice.
#
# WHY / DESIGN NOTES (pipeline still new -> notes here, not a README):
#   - The harvest workflow writes files as <EXTENT>__<id>.pdf. The same report
#     can be reached from >1 watershed group (study areas overlap) or already be
#     in the store under a different extent (e.g. BOWR__214 vs WILL__214) or via
#     a Zotero-key rebuild. reportId is the stable identity -> dedup on it.
#   - Zotero-key-named docs (0150-store.R build) can't be mapped to a reportId from the
#     filename, so a report present ONLY under a Zotero key may slip through as a
#     near-dup. Accepted: retrieval is unharmed; the canonical fix is to refile
#     to Zotero + rebuild via 0150-store.R. Flagged, not solved here.
#   - ragnar stores the extracted text IN the store; origin is just provenance,
#     so ingesting from a scratchpad harvest dir is fine (matches UFRA/WILL/TABR).
#
# INPUT:  STORE (env, default "fraser") -> data/rag/<STORE>.duckdb (must exist)
#         HARVEST_DIR (env) -> dir of <EXTENT>__<id>.pdf files
# OUTPUT: PDFs ingested into the store; prints before/after doc counts.
# REQUIRES: Ollama up (nomic-embed-text) for embedding.
# ---------------------------------------------------------------------------
suppressMessages({library(ragnar); library(DBI); library(stringr)})

store_name  <- if (nzchar(Sys.getenv("STORE"))) Sys.getenv("STORE") else "fraser"
harvest_dir <- Sys.getenv("HARVEST_DIR")
stopifnot("HARVEST_DIR must be set" = nzchar(harvest_dir), dir.exists(harvest_dir))
store_path  <- file.path("data", "rag", paste0(store_name, ".duckdb"))
# The store comes from s3://fresh-bc/rag/ (cred); pull it once rather than rebuilding:
#   Rscript -e 'cred::crd_store_connect("<store>", dir = "data/rag")'
if (!file.exists(store_path)) stop("Store not found locally: ", store_path,
  "\n  Pull it with cred::crd_store_connect(\"", store_name, "\", dir = \"data/rag\") -- do not rebuild.")

rid_of <- function(x) str_remove(str_extract(basename(x), "__[0-9]+[.]pdf$") , "^__") |> str_remove("[.]pdf$")

# ---- existing reportIds in the store (from <extent>__<id>.pdf origins) -------
ro <- dbConnect(duckdb::duckdb(), store_path, read_only = TRUE)
existing_ids <- {
  o <- dbGetQuery(ro, "SELECT origin FROM documents")$origin
  ids <- rid_of(o); ids[!is.na(ids)]
}
n_before <- dbGetQuery(ro, "SELECT count(*) n FROM documents")$n
dbDisconnect(ro, shutdown = TRUE)

# ---- candidate harvest PDFs (only <EXTENT>__<id>.pdf) ------------------------
cand <- list.files(harvest_dir, pattern = "^[A-Z]+__[0-9]+[.]pdf$", full.names = TRUE)
cand_rid <- rid_of(cand)
keep <- !duplicated(cand_rid) & !(cand_rid %in% existing_ids)   # dedup within + vs store

new_pdfs <- cand[keep]
skipped  <- cand[!keep]
message(sprintf("harvest PDFs: %d | already in store: %d | intra-harvest dup: %d | NEW to ingest: %d",
        length(cand),
        sum(cand_rid %in% existing_ids),
        sum(duplicated(cand_rid)),
        length(new_pdfs)))
if (length(skipped)) message("  skipped: ", paste(basename(skipped), collapse = ", "))

if (!length(new_pdfs)) { message("nothing new to ingest."); quit(save = "no") }

# ---- ingest (Mode 3: open read-write, store remembers its embed fn) ----------
store <- ragnar_store_connect(store_path, read_only = FALSE)
ragnar_store_ingest(store, new_pdfs, progress = TRUE)
n_after <- dbGetQuery(store@con, "SELECT count(*) n FROM documents")$n
n_chunks<- dbGetQuery(store@con, "SELECT count(*) n FROM embeddings")$n
DBI::dbDisconnect(store@con)

message(sprintf("\n== %s.duckdb == docs %d -> %d (+%d) | chunks %d", store_name, n_before, n_after, n_after - n_before, n_chunks))

message("Ingested locally only. Push before anything opens this store with VERIFY=TRUE:\n",
        "  ACTION=push STORE=", store_name, " CONFIRM=TRUE Rscript scripts/0150-store.R")
