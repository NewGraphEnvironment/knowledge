# scripts/0150-store.R
# ---------------------------------------------------------------------------
# Ragnar store build / query / push, through `cred`. Replaces the four scripts
# cred 0.3.0 superseded: 0150 (build from a PDF dir), 0151 (build from the
# Zotero Web API), 0155 (query) and 0157 (push/pull with log.json).
#
#   ACTION=build STORE=peace COLLECTIONS="pine - PINE,peace arm - PCEA"  Rscript scripts/0150-store.R
#   (COLLECTIONS takes names or 8-character Zotero keys, resolved in the NGE group
#    library only; GROUP_ID= for another group. An ambiguous name is refused.
#    build needs cred >= 0.5.0, the first that resolves a key inside one library, cred#40)
#   ACTION=update STORE=sturgeon COLLECTIONS=WEUFTSDC                      Rscript scripts/0150-store.R
#   (update brings an existing local store up to date with Zotero through cred's
#    crd_store_update(): new and changed PDFs are ingested, documents whose source no
#    longer resolves are dropped, the rest are kept unread. COLLECTIONS must be the
#    store's whole build list, as in scripts/README.md: a document outside it is dropped.
#    Pull the store first (ACTION=query VERIFY=TRUE), push it after.)
#   ACTION=query STORE=fraser QUERY="beaver dam culvert" TOPK=5           Rscript scripts/0150-store.R
#   (query needs cred >= 0.4.0, the first whose crd_search() works under ragnar 0.3)
#   (query opens an existing local store unverified; VERIFY=TRUE re-checks it
#    against the manifest and REPLACES it if the md5 differs. Set AWS_PROFILE
#    if your bucket credentials live under a named profile.)
#   ACTION=push  STORE=peace                                              Rscript scripts/0150-store.R
#
# What changed from 0151, and why it matters downstream:
#   - cred reads the LOCAL ~/Zotero/zotero.sqlite (read-only), not the Web API.
#     No API key, no `op`. The Zotero data dir must be synced on this machine.
#     cred opens the live file `immutable=1`, which misses commits Zotero 10 still holds
#     in zotero.sqlite-wal (cred#45, #127): collection_keys() reads a guarded copy, but
#     cred's own reads in a build do not, so a build soon after a sync can miss them.
#   - cred takes ONE collection or a vector of citation keys. The old build
#     unioned several collections, so `build` here resolves each named
#     collection to its citation keys and passes the union.
#   - A cred-built store is named by Better BibTeX citation key, not by
#     `<EXTENT>__<reportId>.pdf`. It has no watershed-group attribution and
#     needs data/zotero_key_map.csv to join the farm (0154, 0161). Items with
#     no citation key or no PDF attachment are absent; build names each one
#     (a standalone PDF a keyed item of the build also holds is not listed, #122). Prefer the
#     harvest path (wf_report_harvest.js -> 0152) for anything group-scoped.
#   - The source of truth is s3://fresh-bc/rag/ (options(cred.store_source) in
#     .Rprofile). Pull with cred::crd_store_connect("<store>"); a local write
#     (0152, 0156, or a rebuild here) must be followed by ACTION=push, because
#     the next verified connect replaces an unpushed local file.
# ---------------------------------------------------------------------------
suppressPackageStartupMessages(library(cred))

action <- match.arg(Sys.getenv("ACTION", "query"), c("build", "update", "query", "push"))
store  <- Sys.getenv("STORE")
stopifnot("STORE=<name> is required" = nzchar(store))
store_path <- file.path("data", "rag", paste0(store, ".duckdb"))
dir.create(dirname(store_path), recursive = TRUE, showWarnings = FALSE)

# Reads go to a copy, never the live file: under its old rollback journal Zotero held the file
# in exclusive locking mode, so a read-only connection blocked and an immutable one could see a
# sync half-written. Zotero 10 runs the database in WAL mode (a plain read-only connection did
# not block on 2026-10-31), where a commit sits in zotero.sqlite-wal until a checkpoint folds it
# into the main file, so the copy takes the -wal with the main file: the main file alone opens,
# passes quick_check and silently misses those commits (#127, data-raw/zotero_copy_check.R).
# The -shm is not copied; SQLite rebuilds it. Each try clears the copy's -wal first, so one
# left by an earlier try never sits beside a newer main file. Keep a copy only when nothing
# wrote meanwhile: both files' mtime and size and the header's journal mode are unchanged across
# the copy, no rollback-journal transaction is open (journal absent or its header zeroed, before
# and after), and the copy opens and passes quick_check. The header change counter is no guard:
# SQLite did not bump it per commit in Zotero's exclusive mode, and need not in WAL mode (same
# rule as 0270's db()).
# The same function as 0280's snapshot(), byte for byte; data-raw/zotero_copy_check.R checks they agree.
snapshot <- function(live = path.expand("~/Zotero/zotero.sqlite"), tries = 6, wait = 15) {
  wal <- paste0(live, "-wal")
  journal <- paste0(live, "-journal")
  snap <- tempfile(fileext = ".sqlite")
  state <- function() {
    info <- file.info(c(live, wal))
    open_txn <- file.exists(journal) && file.size(journal) >= 8 &&
      any(readBin(journal, "raw", 8) != as.raw(0))
    list(mtime = as.numeric(info$mtime), size = info$size,
         mode = readBin(live, "raw", 20)[19:20], open_txn = open_txn)
  }
  for (i in seq_len(tries)) {
    before <- state()
    unlink(paste0(snap, c("", "-wal", "-shm")))
    copied <- file.copy(live, snap) && (!file.exists(wal) || file.copy(wal, paste0(snap, "-wal")))
    if (!copied || !identical(state(), before) || before$open_txn) {
      Sys.sleep(wait)
      next
    }
    con <- tryCatch(DBI::dbConnect(RSQLite::SQLite(), snap), error = function(e) NULL)
    ok <- !is.null(con) && tryCatch(DBI::dbGetQuery(con, "PRAGMA quick_check")[[1]][1] == "ok",
                                    error = function(e) FALSE)
    if (ok) return(con)
    if (!is.null(con)) DBI::dbDisconnect(con)
    Sys.sleep(wait)
  }
  stop("no consistent copy of zotero.sqlite after ", tries, " tries; is Zotero mid-sync?")
}

# Citation keys of every item with a PDF attachment in the given collections,
# from the local Zotero database. Collections are resolved inside ONE library
# (the NGE group by default; GROUP_ID= to change it), by name or by their
# 8-character Zotero key. The same name appears in several libraries (a personal
# `habitat_modelling` beside the group's) and more than once in one library
# (`hydrology`, `salmon`), and IN (...) on the name would silently union them;
# an ambiguous name is refused and its keys are printed, so pass a key instead.
# Collections in the Zotero trash are not candidates.
collection_keys <- function(collections, zotero_dir = "~/Zotero",
                            group_id = Sys.getenv("GROUP_ID", "4733734")) {
  db <- file.path(path.expand(zotero_dir), "zotero.sqlite")
  stopifnot("zotero.sqlite not found; sync Zotero on this machine" = file.exists(db))
  con <- snapshot(live = db)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  lib <- DBI::dbGetQuery(con, "SELECT libraryID FROM groups WHERE groupID = ?",
                         params = list(as.integer(group_id)))$libraryID
  if (length(lib) != 1) stop("Zotero group ", group_id, " is not in this Zotero database")
  colls <- DBI::dbGetQuery(con, "
    SELECT c.collectionID, c.key, c.collectionName, p.collectionName AS parent
    FROM collections c LEFT JOIN collections p ON p.collectionID = c.parentCollectionID
    LEFT JOIN deletedCollections dc ON dc.collectionID = c.collectionID
    WHERE c.libraryID = ? AND dc.collectionID IS NULL", params = list(lib))
  ids <- vapply(collections, function(x) {
    hit <- colls[colls$collectionName == x | colls$key == x, ]
    if (nrow(hit) == 0) stop("No collection named or keyed '", x, "' in group ", group_id)
    if (nrow(hit) > 1) stop("Collection '", x, "' is ambiguous in group ", group_id, ": ",
      paste(sprintf("%s (key %s, in %s)", hit$collectionName, hit$key,
                    ifelse(is.na(hit$parent), "top level", hit$parent)), collapse = "; "),
      "\n  Pass the key instead of the name.")
    hit$collectionID
  }, numeric(1))
  sql <- sprintf("
    SELECT DISTINCT ci.collectionID, idv.value AS citation_key
    FROM collectionItems ci
    JOIN items           i  ON i.itemID        = ci.itemID
    JOIN itemData        id ON id.itemID       = i.itemID
    JOIN itemDataValues idv ON id.valueID      = idv.valueID
    JOIN fields          f  ON id.fieldID      = f.fieldID
    JOIN itemAttachments ia ON ia.parentItemID = i.itemID
    LEFT JOIN deletedItems dd ON dd.itemID = i.itemID
    LEFT JOIN deletedItems da ON da.itemID = ia.itemID
    WHERE f.fieldName = 'citationKey'
      AND ia.contentType = 'application/pdf'
      AND dd.itemID IS NULL AND da.itemID IS NULL
      AND ci.collectionID IN (%s)", paste(ids, collapse = ", "))
  res <- DBI::dbGetQuery(con, sql)
  # Every live member the build leaves out, and why. cred is handed keys, so it never
  # sees a member with no key or no PDF; this is the only place they can be named. A
  # standalone PDF whose bytes a keyed item of this build also holds (0270 gives a standalone
  # a parent and leaves it in its collection) is covered, and is not listed.
  mem <- DBI::dbGetQuery(con, sprintf("
    SELECT DISTINCT i.itemID, i.key AS item_key, it.typeName AS item_type, sa.storageHash AS standalone_hash,
      (SELECT idv.value FROM itemData id JOIN itemDataValues idv ON idv.valueID = id.valueID
         JOIN fields f ON f.fieldID = id.fieldID
       WHERE id.itemID = i.itemID AND f.fieldName = 'citationKey') AS citation_key,
      (SELECT idv.value FROM itemData id JOIN itemDataValues idv ON idv.valueID = id.valueID
         JOIN fields f ON f.fieldID = id.fieldID
       WHERE id.itemID = i.itemID AND f.fieldName = 'title') AS title
    FROM collectionItems ci
    JOIN items      i  ON i.itemID      = ci.itemID
    JOIN itemTypes  it ON it.itemTypeID = i.itemTypeID
    LEFT JOIN itemAttachments sa ON sa.itemID = i.itemID AND sa.parentItemID IS NULL
    LEFT JOIN deletedItems    d  ON d.itemID  = i.itemID
    WHERE d.itemID IS NULL AND it.typeName <> 'note' AND ci.collectionID IN (%s)
    ORDER BY i.key", paste(ids, collapse = ", ")))
  # Only a keyed item this build ingests covers a standalone: one outside the named
  # collections holds the file but never reaches the store.
  held <- DBI::dbGetQuery(con, "
    SELECT DISTINCT ia.storageHash, idv.value AS citation_key
    FROM itemAttachments ia
    JOIN items     p  ON p.itemID  = ia.parentItemID
    JOIN itemData  id ON id.itemID = p.itemID
    JOIN fields    f  ON f.fieldID = id.fieldID AND f.fieldName = 'citationKey'
    JOIN itemDataValues idv ON idv.valueID = id.valueID
    LEFT JOIN deletedItems dp ON dp.itemID = p.itemID
    LEFT JOIN deletedItems da ON da.itemID = ia.itemID
    WHERE p.libraryID = ? AND ia.contentType = 'application/pdf' AND ia.storageHash IS NOT NULL
      AND dp.itemID IS NULL AND da.itemID IS NULL", params = list(lib))
  held <- held$storageHash[held$citation_key %in% res$citation_key]
  standalone <- mem$item_type == "attachment"
  why <- ifelse(standalone,
    ifelse(!is.na(mem$standalone_hash) & mem$standalone_hash %in% held, NA,
           "standalone attachment, no keyed item in this build holds its file"),
    ifelse(is.na(mem$citation_key), "no citation key",
           ifelse(mem$citation_key %in% res$citation_key, NA, "no live PDF")))
  out <- mem[!is.na(why), ]
  if (nrow(out)) message(sprintf("%d of %d members left out:\n%s", nrow(out), nrow(mem),
    paste(sprintf("  %s  %s  (%s)", out$item_key,
                  ifelse(is.na(out$citation_key), substr(out$title, 1, 60), out$citation_key),
                  why[!is.na(why)]), collapse = "\n")))
  missing <- collections[!ids %in% res$collectionID]
  if (length(missing)) stop("No keyed PDF items in collection(s): ", paste(missing, collapse = ", "))
  message(sprintf("%d keys across %d collections", length(unique(res$citation_key)), length(collections)))
  unique(res$citation_key)
}

if (action %in% c("build", "update")) {
  colls <- trimws(strsplit(Sys.getenv("COLLECTIONS"), ",")[[1]])
  stopifnot("COLLECTIONS=<name>[,<name>] is required for build and update" =
              length(colls) > 0 && all(nzchar(colls)))
  # Below cred 0.5.0 a key resolved across libraries, to trashed attachments, and to the
  # newest of several PDFs (cred#40). The library is named because a key is unique only in one.
  if (utils::packageVersion("cred") < "0.5.0") {
    stop("ACTION=", action, " needs cred >= 0.5.0, not ", utils::packageVersion("cred"),
         ": pak::pak(\"NewGraphEnvironment/cred\")")
  }
  if (action == "update") {
    if (!exists("crd_store_update", envir = asNamespace("cred"), inherits = FALSE)) {
      stop("ACTION=update needs a cred with crd_store_update() (0.7.0 has it), not ", utils::packageVersion("cred"),
           ": pak::pak(\"NewGraphEnvironment/cred\")")
    }
    if (!file.exists(store_path)) {
      stop(store_path, " is not here to update: pull it first with ACTION=query STORE=", store, " VERIFY=TRUE")
    }
    # crd_store_update() keeps a document only where its origin is a Zotero attachment
    # (storage/<8-character key>/<file>), cred's own test; anything else (a harvest file from 0152, a PDF
    # ingested from a local directory) never resolves and would be dropped. fraser, peace and pine are
    # all such documents; every store built by 0150 is none. The file name decides nothing: a Zotero
    # attachment named PINE__56963.pdf (habitat_modelling) resolves.
    doc_origins <- function() {
      con <- DBI::dbConnect(duckdb::duckdb(), store_path, read_only = TRUE)
      on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
      DBI::dbGetQuery(con, "SELECT DISTINCT origin FROM documents")$origin
    }
    before <- doc_origins()
    harvest <- !grepl("/storage/[A-Z0-9]{8}/[^/]+$", before)
    if (any(harvest)) {
      stop(store_path, " holds ", sum(harvest), " documents from outside Zotero (", basename(before[harvest][1]), ", ...), ",
           "which an update would drop: rebuild it, or bring them into Zotero first")
    }
  }
  keys <- collection_keys(colls)
  # cred reads the live file immutable, which skips Zotero's -wal (cred#45, #127). Zotero truncates
  # the -wal at a checkpoint, so one that holds anything may hold commits the build cannot see,
  # though collection_keys() above read them.
  wal <- path.expand("~/Zotero/zotero.sqlite-wal")
  if (file.exists(wal) && file.size(wal) > 0) {
    warning("zotero.sqlite-wal holds ", file.size(wal), " bytes, which cred reads past (cred#45): the store ",
            "may lack what Zotero has synced since its last checkpoint", call. = FALSE)
  }
  lib <- as.integer(Sys.getenv("GROUP_ID", "4733734"))
  if (action == "build") {
    crd_store_build(store_path, citation_keys = keys, library = lib,
                    overwrite = identical(Sys.getenv("OVERWRITE"), "TRUE"))
  } else {
    crd_store_update(store_path, citation_keys = keys, library = lib)
    after <- doc_origins()
    message(sprintf("%d documents before, %d after: %d added, %d dropped", length(before), length(after),
                    length(setdiff(after, before)), length(setdiff(before, after))))
    if (length(setdiff(before, after))) message("dropped:\n  ", paste(setdiff(before, after), collapse = "\n  "))
  }
  message(if (action == "build") "Built " else "Updated ", store_path, ". It is not in the bucket until ACTION=push.")
} else if (action == "query") {
  # cred 0.3.0's crd_search() fails on every store under ragnar 0.3.0 (cred#27).
  if (utils::packageVersion("cred") < "0.4.0") {
    stop("ACTION=query needs cred >= 0.4.0, not ", utils::packageVersion("cred"),
         ": pak::pak(\"NewGraphEnvironment/cred\")")
  }
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
