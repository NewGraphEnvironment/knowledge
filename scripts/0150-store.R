# scripts/0150-store.R
# ---------------------------------------------------------------------------
# Ragnar store build / query / push, through `cred`. Replaces the four scripts
# cred 0.3.0 superseded: 0150 (build from a PDF dir), 0151 (build from the
# Zotero Web API), 0155 (query) and 0157 (push/pull with log.json).
#
#   ACTION=build STORE=peace COLLECTIONS="pine - PINE,peace arm - PCEA"  Rscript scripts/0150-store.R
#   ACTION=query STORE=fraser QUERY="beaver dam culvert" TOPK=5           Rscript scripts/0150-store.R
#   (query opens an existing local store unverified; VERIFY=TRUE re-checks it
#    against the manifest and REPLACES it if the md5 differs. Set AWS_PROFILE
#    if your bucket credentials live under a named profile.)
#   ACTION=push  STORE=peace                                              Rscript scripts/0150-store.R
#
# What changed from 0151, and why it matters downstream:
#   - cred reads the LOCAL ~/Zotero/zotero.sqlite (read-only), not the Web API.
#     No API key, no `op`. The Zotero data dir must be synced on this machine.
#   - cred takes ONE collection or a vector of citation keys. The old build
#     unioned several collections, so `build` here resolves each named
#     collection to its citation keys and passes the union.
#   - A cred-built store is named by Better BibTeX citation key, not by
#     `<EXTENT>__<reportId>.pdf`. It has no watershed-group attribution and
#     needs data/zotero_key_map.csv to join the farm (0154, 0161). Items with
#     no citation key or no PDF attachment are silently absent. Prefer the
#     harvest path (wf_report_harvest.js -> 0152) for anything group-scoped.
#   - The source of truth is s3://fresh-bc/rag/ (options(cred.store_source) in
#     .Rprofile). Pull with cred::crd_store_connect("<store>"); a local write
#     (0152, 0156, or a rebuild here) must be followed by ACTION=push, because
#     the next verified connect replaces an unpushed local file.
# ---------------------------------------------------------------------------
suppressPackageStartupMessages(library(cred))

action <- match.arg(Sys.getenv("ACTION", "query"), c("build", "query", "push"))
store  <- Sys.getenv("STORE")
stopifnot("STORE=<name> is required" = nzchar(store))
store_path <- file.path("data", "rag", paste0(store, ".duckdb"))
dir.create(dirname(store_path), recursive = TRUE, showWarnings = FALSE)

# Citation keys of every item with a PDF attachment in the named collections,
# from the local Zotero database. Same join cred uses for one collection.
collection_keys <- function(collections, zotero_dir = "~/Zotero") {
  db <- file.path(path.expand(zotero_dir), "zotero.sqlite")
  stopifnot("zotero.sqlite not found; sync Zotero on this machine" = file.exists(db))
  con <- DBI::dbConnect(RSQLite::SQLite(), paste0("file:", db, "?mode=ro&immutable=1"))
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  sql <- sprintf("
    SELECT DISTINCT c.collectionName AS collection, idv.value AS citation_key
    FROM collections c
    JOIN collectionItems ci ON ci.collectionID = c.collectionID
    JOIN items           i  ON i.itemID        = ci.itemID
    JOIN itemData        id ON id.itemID       = i.itemID
    JOIN itemDataValues idv ON id.valueID      = idv.valueID
    JOIN fields          f  ON id.fieldID      = f.fieldID
    JOIN itemAttachments ia ON ia.parentItemID = i.itemID
    LEFT JOIN deletedItems dd ON dd.itemID = i.itemID
    WHERE f.fieldName = 'citationKey'
      AND ia.contentType = 'application/pdf'
      AND dd.itemID IS NULL
      AND c.collectionName IN (%s)",
    paste(sprintf("'%s'", gsub("'", "''", collections)), collapse = ", "))
  # Zotero allows the same collection name in several libraries (and several
  # times in one); IN (...) would silently union them. Refuse the ambiguity.
  dup <- DBI::dbGetQuery(con, sprintf(
    "SELECT collectionName, count(*) AS n, group_concat(libraryID) AS libraries
     FROM collections WHERE collectionName IN (%s) GROUP BY collectionName HAVING count(*) > 1",
    paste(sprintf("'%s'", gsub("'", "''", collections)), collapse = ", ")))
  if (nrow(dup)) stop("Collection name is not unique in this Zotero database: ",
    paste(sprintf("%s (x%d, libraries %s)", dup$collectionName, dup$n, dup$libraries), collapse = "; "),
    "\n  Rename the collection in Zotero or pass citation keys.")
  res <- DBI::dbGetQuery(con, sql)
  missing <- setdiff(collections, unique(res$collection))
  if (length(missing)) stop("No keyed PDF items in collection(s): ", paste(missing, collapse = ", "))
  message(sprintf("%d keys across %d collections", length(unique(res$citation_key)), length(collections)))
  unique(res$citation_key)
}

if (action == "build") {
  colls <- trimws(strsplit(Sys.getenv("COLLECTIONS"), ",")[[1]])
  stopifnot("COLLECTIONS=<name>[,<name>] is required for build" = length(colls) > 0 && all(nzchar(colls)))
  keys <- collection_keys(colls)
  crd_store_build(store_path, citation_keys = keys,
                  overwrite = identical(Sys.getenv("OVERWRITE"), "TRUE"))
  message("Built ", store_path, ". It is not in the bucket until ACTION=push.")
} else if (action == "query") {
  # A verified connect replaces a local file whose md5 differs from the manifest.
  # That is the state after build / 0152 / 0156, so an existing local store is
  # opened UNVERIFIED unless VERIFY=TRUE; a missing one is always downloaded.
  verify <- !file.exists(store_path) || identical(Sys.getenv("VERIFY"), "TRUE")
  s <- crd_store_connect(store, dir = dirname(store_path), verify = verify)
  res <- crd_search(s, Sys.getenv("QUERY"), top_k = as.integer(Sys.getenv("TOPK", "5")))
  print(res)
} else {
  crd_store_push(store_path, dry_run = TRUE)
  if (!identical(Sys.getenv("CONFIRM"), "TRUE")) {
    message("Dry run above. Re-run with CONFIRM=TRUE to upload and merge the manifest.")
  } else {
    crd_store_push(store_path)
  }
}
