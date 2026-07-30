# scripts/04_planning/0157-rag-sync.R
# ---------------------------------------------------------------------------
# Push/pull ragnar stores to s3://fresh-bc/rag/ with a log.json provenance
# manifest. First implementation of the RAG half of #207.
#
# WHY:
#   Stores are gitignored, local-only, and slow to rebuild. The M1 needs them in
#   the field (#208) and must PULL a built store rather than rebuild one — a
#   store built against a different embedding model is not comparable, so a
#   silent local rebuild produces an artifact that looks fine and answers
#   differently. The log is what makes the artifact trustworthy rather than
#   merely present: without it S3 just relocates the "which version is this?"
#   problem out of git and into a bucket.
#
# LAYOUT (flat, one file per region — matches fwapg/dumps/):
#   s3://fresh-bc/rag/fraser.duckdb
#   s3://fresh-bc/rag/peace.duckdb
#   s3://fresh-bc/rag/log.json          <- one manifest describing every store
#
# ACCESS: fresh-bc is private by default (BlockPublicAccess on). The rag/ prefix
#   must STAY private — these stores accumulate unpublished NGE reports, client
#   work, and sensitive content (at-risk-species and culturally-important-site
#   locations, FN data-sovereignty-relevant material). The per-prefix public-read
#   hatch (rtj#114) is out of scope here. Field read access = a read-only IAM key
#   scoped to rag/*, tracked in NewGraphEnvironment/rtj#194.
#   Writing needs no prefix provisioning — S3 prefixes are key namespaces, not
#   objects; the existing geobuild creds (AWS_PROFILE=airvine) can PUT today.
#
# OPT-IN by design (same pattern as FISS_FETCH): never syncs as a build side effect.
#   RAG_SYNC=push STORES=fraser Rscript scripts/04_planning/0157-rag-sync.R
#   RAG_SYNC=pull STORES=fraser,peace Rscript scripts/04_planning/0157-rag-sync.R
#   DRY_RUN=1 to print the plan only.
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(jsonlite); library(glue)})

BUCKET  <- Sys.getenv("RAG_BUCKET", "s3://fresh-bc/rag")
PROFILE <- Sys.getenv("AWS_PROFILE", "airvine")
mode    <- Sys.getenv("RAG_SYNC", "")
stores  <- trimws(strsplit(Sys.getenv("STORES", "fraser"), ",")[[1]])
dry     <- nzchar(Sys.getenv("DRY_RUN"))
stopifnot("set RAG_SYNC=push or RAG_SYNC=pull" = mode %in% c("push", "pull"))

aws <- function(...) {
  cmd <- paste("aws", ..., "--profile", PROFILE)
  if (dry) { message("  [dry-run] ", cmd); return(0L) }
  system(cmd)
}

# ---- describe a store: counts + embedding params + checksum ----------------
describe <- function(p) {
  con <- dbConnect(duckdb::duckdb(), p, read_only = TRUE)
  on.exit(dbDisconnect(con, shutdown = TRUE))
  n_doc <- dbGetQuery(con, "SELECT count(*) AS n FROM documents")$n
  n_chk <- dbGetQuery(con, "SELECT count(*) AS n FROM embeddings")$n
  meta  <- dbGetQuery(con, "SELECT embedding_size, name FROM metadata")
  # per-group coverage from EXTENT__reportId origins (blank where a store was
  # built from Zotero keys and carries no group attribution — that is itself
  # worth recording, since "which watershed group is this store for?" is then
  # unanswerable from the store)
  org <- basename(dbGetQuery(con, "SELECT origin FROM documents")$origin)
  grp <- sub("^([A-Za-z]+)__.*", "\\1", org[grepl("__[0-9]+\\.pdf$", org)])
  list(
    documents = n_doc, chunks = n_chk,
    embedding_size = if (nrow(meta)) meta$embedding_size[1] else NA,
    embedding_model = Sys.getenv("RAG_EMBED_MODEL", "nomic-embed-text (ollama)"),
    store_name = if (nrow(meta)) meta$name[1] else NA,
    watershed_groups = if (length(grp)) as.list(sort(table(grp))) else NULL,
    docs_without_group = sum(!grepl("__[0-9]+\\.pdf$", org)),
    bytes = unname(file.size(p)),
    md5 = unname(tools::md5sum(p))
  )
}

head_sha <- tryCatch(system("git rev-parse HEAD", intern = TRUE)[1], error = function(e) NA)
branch   <- tryCatch(system("git rev-parse --abbrev-ref HEAD", intern = TRUE)[1], error = function(e) NA)

if (mode == "push") {
  entries <- list()
  for (s in stores) {
    p <- file.path("data", "rag", paste0(s, ".duckdb"))
    if (!file.exists(p)) { message("skip ", s, " (not found)"); next }
    d <- describe(p)
    message(glue("{s}: {d$documents} docs, {d$chunks} chunks, {round(d$bytes/1048576)} MB"))
    aws("s3 cp", shQuote(p), paste0(BUCKET, "/"))
    entries[[s]] <- d
  }
  log <- list(
    date_completed = format(as.POSIXct(Sys.time(), tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ"),
    repo = "NewGraphEnvironment/fish_passage_template_reporting",
    branch = branch, head_sha = head_sha,
    generating_script = "scripts/04_planning/0157-rag-sync.R",
    built_by = c("scripts/04_planning/0152-rag-add-harvest.R",
                 "scripts/04_planning/0151-rag-build-from-zotero.R"),
    chunking = "ragnar defaults (ragnar_store_ingest)",
    stores = entries
  )
  lp <- file.path(tempdir(), "log.json")
  write_json(log, lp, auto_unbox = TRUE, pretty = TRUE)
  aws("s3 cp", shQuote(lp), paste0(BUCKET, "/log.json"))
  message("\npushed ", length(entries), " store(s) + log.json -> ", BUCKET)
  if (dry) cat(readLines(lp), sep = "\n")

} else {  # pull — verify against the log before overwriting anything local
  lp <- file.path(tempdir(), "log.json")
  if (aws("s3 cp", paste0(BUCKET, "/log.json"), shQuote(lp)) != 0) stop("could not fetch log.json")
  log <- fromJSON(lp, simplifyVector = FALSE)
  for (s in stores) {
    e <- log$stores[[s]]
    if (is.null(e)) { message("skip ", s, " (not in log.json)"); next }
    p <- file.path("data", "rag", paste0(s, ".duckdb"))
    aws("s3 cp", paste0(BUCKET, "/", s, ".duckdb"), shQuote(p))
    if (!dry) {
      got <- unname(tools::md5sum(p))
      if (identical(got, e$md5)) message(glue("  {s}: md5 OK ({e$documents} docs, {e$chunks} chunks)"))
      else warning(glue("  {s}: MD5 MISMATCH — expected {e$md5}, got {got}"))
    }
  }
}
