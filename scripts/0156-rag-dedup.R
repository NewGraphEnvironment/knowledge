# scripts/0156-rag-dedup.R
# ---------------------------------------------------------------------------
# Remove duplicate documents from a ragnar store before it is published/synced.
#
# WHY:
#   A store can be fed by two paths that name the same report differently:
#     * the harvest  -> EXTENT__<reportId>.pdf   (carries watershed-group attribution)
#     * a Zotero build (0150-store.R ACTION=build) -> <ATTACHMENT_KEY>.pdf  (no group, no reportId)
#   fraser.duckdb ended up with 21 EcoCat reports ingested under BOTH schemes —
#   304 documents but only 283 unique. Duplicates are not harmless: a duplicated
#   report gets two chances at every retrieval, quietly biasing search toward
#   whichever reports happen to be doubled (the McGregor inventories among them).
#   Fix before syncing to S3 (NewGraphEnvironment/fish_passage_template_reporting#207) so the M1 does not pull the skew.
#
# WHICH COPY WINS: the EXTENT__<reportId> one — it carries the watershed group,
#   which is what 0154 attribution and the farm join depend on.
#
# HOW: delete the losing doc_ids from documents/chunks/embeddings, then rebuild
#   the vss + fts indexes (the fts side lives in dict/docs/fields/stats/terms and
#   would otherwise point at deleted rows). DuckDB will not shrink the file on
#   delete, so we compact by copying the database into a fresh file.
#
# INPUT   STORE (env, default fraser) -> data/rag/<STORE>.duckdb
#         data/zotero_key_map.csv (maps legacy key filenames -> reportId)
# OUTPUT  the store, deduped + reindexed + compacted. Backup written alongside.
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(ragnar); library(dplyr); library(stringr); library(readr)})

store_name <- if (nzchar(Sys.getenv("STORE"))) Sys.getenv("STORE") else "fraser"
path <- file.path("data", "rag", paste0(store_name, ".duckdb"))
# The store comes from s3://fresh-bc/rag/ (cred); pull it rather than rebuilding:
#   Rscript -e 'cred::crd_store_connect("<store>", dir = "data/rag")'
if (!file.exists(path)) stop("Store not found locally: ", path,
  "\n  Pull it with cred::crd_store_connect(\"", store_name, "\", dir = \"data/rag\") -- do not rebuild.")
dry <- nzchar(Sys.getenv("DRY_RUN"))

# ---- work out reportId per document ----------------------------------------
ro <- dbConnect(duckdb::duckdb(), path, read_only = TRUE)
d <- dbGetQuery(ro, "SELECT doc_id, origin FROM documents")
n0 <- nrow(d); nch0 <- dbGetQuery(ro, "SELECT count(*) n FROM chunks")$n
dbDisconnect(ro, shutdown = TRUE)

d$base <- basename(d$origin)
d$rid  <- ifelse(str_detect(d$base, "__[0-9]+\\.pdf$"),
                 str_replace(d$base, "^[A-Za-z]+__([0-9]+)\\.pdf$", "\\1"), NA_character_)
d$harvest <- str_detect(d$base, "__")

kmf <- file.path("data", "zotero_key_map.csv")
if (file.exists(kmf)) {
  km <- read_csv(kmf, show_col_types = FALSE) %>% filter(!is.na(report_id) & report_id != "")
  i <- match(d$base, km$file)
  d$rid[is.na(d$rid)] <- as.character(km$report_id)[i][is.na(d$rid)]
}

dupe_ids <- d %>% filter(!is.na(rid)) %>% count(rid) %>% filter(n > 1) %>% pull(rid)
# keep the harvest-named copy, drop the other(s)
drop <- d %>% filter(rid %in% dupe_ids) %>% group_by(rid) %>%
  arrange(desc(harvest), doc_id, .by_group = TRUE) %>% slice(-1) %>% ungroup()

message(sprintf("store %s: %d documents, %d duplicate reportId(s), %d document(s) to drop",
                store_name, n0, length(dupe_ids), nrow(drop)))
if (nrow(drop)) print(as.data.frame(drop %>% select(doc_id, base, rid) %>% head(25)), row.names = FALSE)
if (!nrow(drop)) { message("nothing to do"); quit(save = "no") }
if (dry) { message("DRY_RUN set — no changes written"); quit(save = "no") }

backup <- paste0(path, ".bak")
file.copy(path, backup, overwrite = TRUE)
message("backup -> ", backup)

# ---- delete + reindex -------------------------------------------------------
# The `embeddings` table carries an HNSW vector index, so the connection must have
# the duckdb `vss` extension loaded or DELETE fails with
#   "Cannot bind index 'embeddings', unknown index type 'HNSW'".
# ragnar_store_connect() sets that up (plus experimental HNSW persistence), so run
# the deletes on ITS connection rather than a bare dbConnect().
st <- ragnar_store_connect(path, read_only = FALSE)
con <- st@con
tryCatch({
  dbExecute(con, "INSTALL vss; LOAD vss;")
  dbExecute(con, "SET hnsw_enable_experimental_persistence = true")
}, error = function(e) message("  (vss setup: ", conditionMessage(e), ")"))

ids <- paste(drop$doc_id, collapse = ",")
# `chunks` is a VIEW over the base tables — deleting from it errors with
# "Can only delete from base table!". Delete from the base tables only; the view
# follows. Base tables in a ragnar v2 store: documents, embeddings (+ the fts
# index tables dict/docs/fields/stats/terms, rebuilt below).
for (tb in c("embeddings", "documents")) {
  n <- dbExecute(con, sprintf("DELETE FROM %s WHERE doc_id IN (%s)", tb, ids))
  message(sprintf("  deleted %d row(s) from %s", n, tb))
}
n1   <- dbGetQuery(con, "SELECT count(*) n FROM documents")$n
nch1 <- dbGetQuery(con, "SELECT count(*) n FROM chunks")$n
message(sprintf("deleted: documents %d -> %d | chunks %d -> %d", n0, n1, nch0, nch1))

message("rebuilding vss + fts indexes ...")
ragnar_store_build_index(st)
DBI::dbDisconnect(con, shutdown = TRUE)

# ---- compact (DuckDB does not reclaim space on delete) ----------------------
# NOT COMPACTED — deliberately. DuckDB does not reclaim space on DELETE, so the
# file keeps the dropped rows' pages (~7% here). Two ways to compact were tried
# and both are blocked by how this store is built:
#   * `COPY FROM DATABASE src TO dst` fails with a foreign-key constraint error
#     ("key doc_id: N does not exist in the referenced table") because it inserts
#     child rows before parents; the FK between embeddings and documents makes the
#     copy order illegal. NOT corruption — the store verifies clean (0 orphaned
#     embedding rows, doc_id range intact).
#   * any plain connection must `INSTALL vss; LOAD vss;` first or the HNSW index on
#     `embeddings` blocks modification entirely.
# The space saving does not justify more effort; correctness is what matters for a
# synced artifact. If the file size ever does matter, rebuild from Zotero (ACTION=build in 0150-store.R).
message(sprintf("store is %.0f MB (not compacted — see note in this script)", file.size(path) / 1048576))
message("done. backup retained at ", backup)

message("Deduped locally only. Push before anything opens this store with VERIFY=TRUE:\n",
        "  ACTION=push STORE=", store_name, " CONFIRM=TRUE Rscript scripts/0150-store.R")
