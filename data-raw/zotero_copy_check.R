# data-raw/zotero_copy_check.R
# ---------------------------------------------------------------------------
# Zotero 10 runs zotero.sqlite in WAL mode (#127): a commit sits in zotero.sqlite-wal until a
# checkpoint folds it into the main file, so a reader that copies the main file alone, or opens the
# live file `immutable=1`, can miss it. This check measures what each way of reading sees, on
# fixtures where the answer is known and on the live database.
#
# FIXTURES (a tempdir; each `live/` holds what Zotero's data directory would):
#   wal_pending  WAL mode; N_MAIN rows checkpointed into the main file, then N_WAL more committed
#                with autocheckpoint off, and the main file and -wal copied while the writer is
#                still open. The main file lacks the N_WAL rows; the -wal holds them.
#   wal_closed   WAL mode, closed cleanly: the -wal is folded in and deleted (as after Zotero quits).
#   rollback     rollback-journal mode, as Zotero ran before version 10.
# READS, each on a fresh copy in its own directory (opened? quick_check? rows):
#   main_rw      the main file alone, opened read-write
#   main_ro      the main file alone, opened mode=ro
#   pair_rw      the main file and the -wal (no -shm), opened read-write
#   pair_ro      the same pair, opened mode=ro
#   immutable    the live file itself, mode=ro&immutable=1 (0150 and cred before #127)
# LIVE: the same reads of ~/Zotero/zotero.sqlite (items and the newest clientDateModified), when it
#   exists and LIVE is not FALSE. Reads only: the copies go to a tempdir.
# INPUT:  RSQLite; ~/Zotero/zotero.sqlite for the live table
# GUARDS: each script's guarded copy, run on each fixture, must read its rows; the script stops if not.
# WRITES: nothing outside tempdir()
# RUN:    Rscript data-raw/zotero_copy_check.R          (from the repo root; LIVE=FALSE skips the live table)
# ---------------------------------------------------------------------------

N_MAIN <- 5L
N_WAL <- 3L

sql_exec <- function(con, sql) invisible(DBI::dbExecute(con, sql))

# -> the fixture's live/ directory; its zotero.sqlite should hold `expect` rows in table items
fixture <- function(root, kind) {
  dir.create(src <- file.path(root, kind, "src"), recursive = TRUE)
  dir.create(live <- file.path(root, kind, "live"))
  f <- file.path(src, "zotero.sqlite")
  con <- DBI::dbConnect(RSQLite::SQLite(), f)
  mode <- if (kind == "rollback") "DELETE" else "WAL"
  DBI::dbGetQuery(con, paste0("PRAGMA journal_mode = ", mode))
  DBI::dbGetQuery(con, "PRAGMA wal_autocheckpoint = 0")
  sql_exec(con, "CREATE TABLE items (itemID INTEGER PRIMARY KEY, v TEXT)")
  for (i in seq_len(N_MAIN)) sql_exec(con, sprintf("INSERT INTO items (v) VALUES ('main %d')", i))
  if (kind == "wal_pending") {
    DBI::dbGetQuery(con, "PRAGMA wal_checkpoint(TRUNCATE)")
    for (i in seq_len(N_WAL)) sql_exec(con, sprintf("INSERT INTO items (v) VALUES ('wal %d')", i))
    # the writer is still open, so nothing has folded the -wal into the main file
    stopifnot(file.copy(f, live), file.copy(paste0(f, "-wal"), live))
    DBI::dbDisconnect(con)
  } else {
    DBI::dbDisconnect(con)
    stopifnot(!file.exists(paste0(f, "-wal")), file.copy(f, live))
  }
  live
}

expect_rows <- c(wal_pending = N_MAIN + N_WAL, wal_closed = N_MAIN, rollback = N_MAIN)

# One read of `live` (a data directory) the way `how` names. -> opened, quick_check, n, newest
read_way <- function(live, how, sql) {
  db <- file.path(live, "zotero.sqlite")
  target <- db
  if (how != "immutable") {
    dir.create(d <- tempfile("read_"))
    stopifnot(file.copy(db, d))
    if (startsWith(how, "pair") && file.exists(paste0(db, "-wal"))) stopifnot(file.copy(paste0(db, "-wal"), d))
    target <- file.path(d, "zotero.sqlite")
  }
  uri <- switch(how,
                main_rw = , pair_rw = target,
                main_ro = , pair_ro = paste0("file:", target, "?mode=ro"),
                immutable = paste0("file:", target, "?mode=ro&immutable=1"))
  out <- list(opened = FALSE, quick_check = NA_character_, n = NA_integer_, newest = NA_character_, error = "")
  tryCatch({
    con <- DBI::dbConnect(RSQLite::SQLite(), uri)
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    out$quick_check <- DBI::dbGetQuery(con, "PRAGMA quick_check")[[1]][1]
    r <- DBI::dbGetQuery(con, sql)
    out$opened <- TRUE
    out$n <- as.integer(r[[1]])
    if (ncol(r) > 1) out$newest <- as.character(r[[2]])
  }, error = function(e) out$error <<- conditionMessage(e))
  as.data.frame(out)
}

ways <- c("main_rw", "main_ro", "pair_rw", "pair_ro", "immutable")
root <- tempfile("zotero_copy_check_")
dir.create(root)

cat("== fixtures (rows expected: ", paste(names(expect_rows), expect_rows, sep = " ", collapse = ", "), ")\n", sep = "")
fx <- vapply(names(expect_rows), function(k) fixture(root, k), "")
tab <- do.call(rbind, lapply(names(fx), function(k) {
  hdr <- readBin(file.path(fx[[k]], "zotero.sqlite"), "raw", 20)[19:20]
  cbind(fixture = k, mode_bytes = paste(hdr, collapse = " "), wal = file.exists(file.path(fx[[k]], "zotero.sqlite-wal")),
        way = ways, do.call(rbind, lapply(ways, function(w) read_way(fx[[k]], w, "SELECT count(*) FROM items"))))
}))
tab$newest <- NULL
print(tab, row.names = FALSE)

# --- the guards, as the scripts define them ---------------------------------
# Each is taken from its script by parse(), never retyped, and run once on each fixture: it must
# return a connection whose items hold the fixture's rows.
fn_from <- function(file, name) {
  for (e in parse(file, keep.source = FALSE)) {
    if (is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name(name))) {
      env <- new.env()
      eval(e, env)
      return(env[[name]])
    }
  }
  stop(name, "() not found in ", file)
}
r_guard <- function(file) {
  f <- fn_from(file, "snapshot")
  function(db) {
    con <- f(live = db, tries = 1, wait = 0)
    on.exit(DBI::dbDisconnect(con))
    DBI::dbGetQuery(con, "SELECT count(*) FROM items")[[1]]
  }
}
# 0270 is loaded as 0270 loads 0153; importing it imports 0153, which exits without ZOTERO_API_KEY,
# so the child gets a placeholder key. db() makes no API call.
py_guard <- function(file) {
  code <- c("import importlib.util, sys",
            sprintf("spec = importlib.util.spec_from_file_location('z0270', %s)", shQuote(file)),
            "m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)",
            "try:",
            "    print(m.db(live=sys.argv[1], tries=1, wait=0).execute('SELECT count(*) FROM items').fetchone()[0])",
            "except SystemExit as e:",
            "    print('NA'); print(e, file=sys.stderr)")
  function(db) {
    out <- system2("python3", c("-c", shQuote(paste(code, collapse = "\n")), shQuote(db)),
                   stdout = TRUE, env = "ZOTERO_API_KEY=check-only")
    as.integer(utils::tail(out, 1))
  }
}
guards <- list(`0280 snapshot()` = r_guard("scripts/0280-literature-verify.R"),
               `0270 db()` = py_guard("scripts/0270-habitat-collection-build.py"))
gt <- do.call(rbind, lapply(names(guards), function(g) do.call(rbind, lapply(names(fx), function(k) {
  n <- tryCatch(guards[[g]](file.path(fx[[k]], "zotero.sqlite")), error = function(e) NA_integer_)
  data.frame(guard = g, fixture = k, rows = n, expected = expect_rows[[k]])
}))))
gt$ok <- !is.na(gt$rows) & gt$rows == gt$expected
cat("\n== guards\n")
print(gt, row.names = FALSE)

if (!identical(Sys.getenv("LIVE"), "FALSE") && file.exists(path.expand("~/Zotero/zotero.sqlite"))) {
  live <- path.expand("~/Zotero")
  files <- file.path(live, c("zotero.sqlite", "zotero.sqlite-wal", "zotero.sqlite-shm"))
  info <- file.info(files)
  cat("\n== live: ", paste(sprintf("%s %s %s B", basename(files), format(info$mtime, tz = "UTC", usetz = TRUE),
                                    info$size), collapse = "; "), "\n", sep = "")
  sql <- "SELECT count(*), max(clientDateModified) FROM items"
  lt <- do.call(rbind, lapply(ways, function(w) cbind(way = w, read_way(live, w, sql))))
  print(lt, row.names = FALSE)
  if (!identical(file.info(files)$mtime, info$mtime)) cat("(a live file changed during the reads)\n")
}
unlink(root, recursive = TRUE)
if (!all(gt$ok)) stop(sum(!gt$ok), " guard run(s) did not read the fixture's rows")
cat("\nPASS: every guard read every fixture's rows\n")
