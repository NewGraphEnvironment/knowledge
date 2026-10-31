# data-raw/zotero_copy_check.R
# ---------------------------------------------------------------------------
# Zotero 10 runs zotero.sqlite in WAL mode (#127): a commit sits in zotero.sqlite-wal until a
# checkpoint folds it into the main file, so a reader that copies the main file alone, or opens the
# live file `immutable=1`, can miss it. This check measures what each way of reading sees, on
# fixtures where the answer is known and on the live database.
#
# FIXTURES (a tempdir; each `live/` holds what Zotero's data directory would):
#   wal_pending   WAL mode; N_MAIN rows checkpointed into the main file, then N_WAL more committed
#                 with autocheckpoint off, and the main file and -wal copied while the writer is
#                 still open. The main file lacks the N_WAL rows; the -wal holds them.
#   wal_exclusive the same, with the writer in exclusive locking mode (its wal-index in memory, no -shm)
#   wal_empty     WAL mode, the -wal checkpointed and truncated to 0 bytes with the writer open (the
#                 state Zotero 10 leaves after a checkpoint)
#   wal_closed    WAL mode, closed cleanly: the -wal is folded in and deleted (as after Zotero quits).
#   rollback      rollback-journal mode, as Zotero ran before version 10.
#   The check stops unless each fixture still separates the reads: the main file alone and
#   immutable=1 read N_MAIN rows, the pair reads the fixture's rows.
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
# INTERFERENCE: each guard's file copies are hooked to write a live file mid-copy, or to checkpoint it
#   between tries; the guard must refuse the torn try and read the later state. These pin the
#   stability check and the clearing of an earlier try's -wal, which the fixtures cannot reach.
# STRESS: a writer commits one row per transaction, in bursts, for STRESS_SECS, with checkpoints every
#   few pages, while each guard copies its files again and again; every copy a guard accepts must be a state
#   the writer committed (rows = the largest itemID). It measures, it does not pin: with the stability
#   check removed, 6 of 2,862 accepted copies were not committed in 90 s, so a short run usually passes
#   without it. STRESS_SECS=0 skips it.
# LIVE GUARDS: each guard on the live database, beside a pair read taken at the same moment.
# WRITES: nothing outside tempdir()
# RUN:    Rscript data-raw/zotero_copy_check.R    (from the repo root; LIVE=FALSE skips the live tables)
# ---------------------------------------------------------------------------

N_MAIN <- 5L
N_WAL <- 3L

sql_exec <- function(con, sql) invisible(DBI::dbExecute(con, sql))

# -> the fixture's live/ directory; its zotero.sqlite holds expect_rows[[kind]] rows in table items
fixture <- function(root, kind) {
  dir.create(src <- file.path(root, kind, "src"), recursive = TRUE)
  dir.create(live <- file.path(root, kind, "live"))
  f <- file.path(src, "zotero.sqlite")
  con <- DBI::dbConnect(RSQLite::SQLite(), f)
  if (kind == "wal_exclusive") DBI::dbGetQuery(con, "PRAGMA locking_mode = EXCLUSIVE")
  DBI::dbGetQuery(con, paste0("PRAGMA journal_mode = ", if (kind == "rollback") "DELETE" else "WAL"))
  DBI::dbGetQuery(con, "PRAGMA wal_autocheckpoint = 0")
  sql_exec(con, "CREATE TABLE items (itemID INTEGER PRIMARY KEY, v TEXT)")
  for (i in seq_len(N_MAIN)) sql_exec(con, sprintf("INSERT INTO items (v) VALUES ('main %d')", i))
  if (kind %in% c("wal_pending", "wal_exclusive", "wal_empty")) {
    DBI::dbGetQuery(con, "PRAGMA wal_checkpoint(TRUNCATE)")
    if (kind != "wal_empty") {
      for (i in seq_len(N_WAL)) sql_exec(con, sprintf("INSERT INTO items (v) VALUES ('wal %d')", i))
    }
    # the writer is still open, so nothing has folded the -wal into the main file
    stopifnot(file.copy(f, live), file.copy(paste0(f, "-wal"), live))
    DBI::dbDisconnect(con)
  } else {
    DBI::dbDisconnect(con)
    stopifnot(!file.exists(paste0(f, "-wal")), file.copy(f, live))
  }
  live
}

expect_rows <- c(wal_pending = N_MAIN + N_WAL, wal_exclusive = N_MAIN + N_WAL, wal_empty = N_MAIN,
                 wal_closed = N_MAIN, rollback = N_MAIN)

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
# the fixtures must still reproduce the bug, or every guard below would pass without testing anything
tab$want <- ifelse(startsWith(tab$way, "pair"), expect_rows[tab$fixture], N_MAIN)
stopifnot("a fixture no longer separates the reads" = all(tab$opened & tab$quick_check == "ok" & tab$n == tab$want),
          "wal_empty's -wal is not 0 bytes" = file.size(file.path(fx[["wal_empty"]], "zotero.sqlite-wal")) == 0)

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
# Each guard returns c(rows, largest itemID) from the copy it accepted.
count_sql <- "SELECT count(*), max(itemID) FROM items"
# `event` (see INTERFERENCE) runs after the guard's `on`-th file copy, through a file.copy() the
# guard finds before base's.
r_guard <- function(file) {
  f <- fn_from(file, "snapshot")
  function(db, tries = 1, wait = 0, event = "none", on = 0L, other = "") {
    g <- f
    if (event != "none") {
      e <- new.env(parent = environment(f))
      n <- 0L
      e$file.copy <- function(...) {
        r <- base::file.copy(...)
        n <<- n + 1L
        if (n == on) interfere(event, db, other)
        r
      }
      environment(g) <- e
    }
    con <- g(live = db, tries = tries, wait = wait)
    on.exit(DBI::dbDisconnect(con))
    unlist(DBI::dbGetQuery(con, count_sql), use.names = FALSE)
  }
}
# What Zotero might do to its files while a guard copies them
interfere <- function(event, db, other) {
  switch(event,
         touch_main = Sys.setFileTime(db, file.mtime(db) + 10),
         touch_wal = Sys.setFileTime(paste0(db, "-wal"), file.mtime(paste0(db, "-wal")) + 10),
         checkpoint = { stopifnot(file.copy(other, db, overwrite = TRUE)); unlink(paste0(db, "-wal")) })
}
# 0270 is loaded as 0270 loads 0153; importing it imports 0153, which exits without ZOTERO_API_KEY,
# so the child gets a placeholder key. db() makes no API call.
py_guard <- function(file) {
  code <- c("import importlib.util, sys",
            sprintf("spec = importlib.util.spec_from_file_location('z0270', %s)", shQuote(file)),
            "m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)",
            "import os, shutil",
            "db, event, on, other = sys.argv[1], sys.argv[4], int(sys.argv[5]), sys.argv[6]",
            "orig, n = shutil.copyfile, [0]",
            "def touch(p):",
            "    st = os.stat(p); os.utime(p, ns=(st.st_atime_ns, st.st_mtime_ns + 10**10))",
            "def hooked(src, dst, *a, **k):",
            "    r = orig(src, dst, *a, **k); n[0] += 1",
            "    if n[0] == on:",
            "        if event == 'touch_main': touch(db)",
            "        elif event == 'touch_wal': touch(db + '-wal')",
            "        elif event == 'checkpoint': orig(other, db); os.remove(db + '-wal')",
            "    return r",
            "if event != 'none': shutil.copyfile = hooked",
            "try:",
            sprintf("    r = m.db(live=sys.argv[1], tries=int(sys.argv[2]), wait=float(sys.argv[3])).execute(%s).fetchone()",
                    shQuote(count_sql, type = "sh")),
            "    print(r[0], r[1])",
            "except SystemExit as e:",
            "    print('NA NA'); print(e, file=sys.stderr)")
  function(db, tries = 1, wait = 0, event = "none", on = 0L, other = "") {
    out <- system2("python3", c("-c", shQuote(paste(code, collapse = "\n")), shQuote(db), tries, wait,
                                event, on, shQuote(other)),
                   stdout = TRUE, env = "ZOTERO_API_KEY=check-only")
    suppressWarnings(as.integer(strsplit(utils::tail(out, 1), " ")[[1]]))
  }
}
guards <- list(`0280 snapshot()` = r_guard("scripts/0280-literature-verify.R"),
               `0150 snapshot()` = r_guard("scripts/0150-store.R"),
               `0270 db()` = py_guard("scripts/0270-habitat-collection-build.py"))
# 0150 carries 0280's function; a fix to one that misses the other fails here
stopifnot("0150's snapshot() differs from 0280's" = identical(
  deparse(fn_from("scripts/0150-store.R", "snapshot")), deparse(fn_from("scripts/0280-literature-verify.R", "snapshot"))))
gt <- do.call(rbind, lapply(names(guards), function(g) do.call(rbind, lapply(names(fx), function(k) {
  n <- tryCatch(guards[[g]](file.path(fx[[k]], "zotero.sqlite"))[1], error = function(e) NA_integer_)
  data.frame(guard = g, fixture = k, rows = n, expected = expect_rows[[k]])
}))))
gt$ok <- !is.na(gt$rows) & gt$rows == gt$expected
cat("\n== guards\n")
print(gt, row.names = FALSE)

# --- interference: Zotero writes during a copy, or checkpoints between tries ---------------------
# Each case starts from a fresh copy of wal_pending (8 rows, 3 of them in the -wal).
#   touch_main  the main file is written after the guard copied it: the try must be refused
#   touch_wal   the -wal is written after the main file was copied: likewise
#   checkpoint  after the first try copied the -wal, Zotero checkpoints into a main file of N_LATER
#               rows and deletes the -wal; the second try must read N_LATER rows, with no -wal of
#               the first try's left beside the new main file
N_LATER <- 10L
later <- file.path(root, "later.sqlite")
local({
  con <- DBI::dbConnect(RSQLite::SQLite(), later)
  on.exit(DBI::dbDisconnect(con))
  DBI::dbGetQuery(con, "PRAGMA journal_mode = WAL")
  sql_exec(con, "CREATE TABLE items (itemID INTEGER PRIMARY KEY, v TEXT)")
  for (i in seq_len(N_LATER)) sql_exec(con, sprintf("INSERT INTO items (v) VALUES ('later %d')", i))
})
cases <- data.frame(event = c("touch_main", "touch_wal", "checkpoint"), on = c(1L, 1L, 2L),
                    tries = c(1L, 1L, 2L), expected = c(NA, NA, N_LATER))
it <- do.call(rbind, lapply(names(guards), function(g) do.call(rbind, lapply(seq_len(nrow(cases)), function(i) {
  dir.create(d <- tempfile("interfere_", tmpdir = root))
  stopifnot(file.copy(list.files(fx[["wal_pending"]], full.names = TRUE), d))
  n <- tryCatch(guards[[g]](file.path(d, "zotero.sqlite"), tries = cases$tries[i], wait = 0, event = cases$event[i],
                            on = cases$on[i], other = later)[1], error = function(e) NA_integer_)
  data.frame(guard = g, event = cases$event[i], rows = n, expected = cases$expected[i])
}))))
it$ok <- (is.na(it$expected) & is.na(it$rows)) | (!is.na(it$rows) & !is.na(it$expected) & it$rows == it$expected)
cat("\n== interference (NA: the guard refused every try, as it must)\n")
print(it, row.names = FALSE)

# --- stress: copies taken while a writer commits and checkpoints --------------------------------
stress_secs <- as.numeric(Sys.getenv("STRESS_SECS", "20"))
st <- NULL
if (stress_secs > 0) {
  dir.create(sdir <- file.path(root, "stress"))
  sdb <- file.path(sdir, "zotero.sqlite")
  stop_file <- file.path(sdir, "stop")
  done_file <- file.path(sdir, "done")
  writer <- sprintf(paste(
    "con <- DBI::dbConnect(RSQLite::SQLite(), %s)",
    "invisible(DBI::dbGetQuery(con, 'PRAGMA journal_mode = WAL'))",
    "invisible(DBI::dbGetQuery(con, 'PRAGMA wal_autocheckpoint = 8'))",
    "invisible(DBI::dbExecute(con, 'CREATE TABLE items (itemID INTEGER PRIMARY KEY, v BLOB)'))",
    "t0 <- Sys.time()",
    "while (!file.exists(%s) && difftime(Sys.time(), t0, units = 'secs') < %d) {",
    "  for (i in 1:20) invisible(DBI::dbExecute(con, 'INSERT INTO items (v) VALUES (randomblob(1000))'))",
    "  Sys.sleep(stats::runif(1, 0, 0.2))",
    "}",
    "DBI::dbDisconnect(con); file.create(%s)", sep = "\n"),
    deparse(sdb), deparse(stop_file), as.integer(stress_secs) + 30L, deparse(done_file))
  system2("Rscript", c("-e", shQuote(writer)), wait = FALSE, stdout = FALSE, stderr = FALSE)
  t0 <- Sys.time()
  while (!(file.exists(paste0(sdb, "-wal")) && file.size(paste0(sdb, "-wal")) > 0)) {
    if (difftime(Sys.time(), t0, units = "secs") > 30) stop("the stress writer did not start")
    Sys.sleep(0.1)
  }
  st <- list()
  t0 <- Sys.time()
  while (difftime(Sys.time(), t0, units = "secs") < stress_secs) {
    for (g in names(guards)) {
      n <- tryCatch(guards[[g]](sdb, tries = 500, wait = 0.005), error = function(e) c(NA, NA))
      st[[length(st) + 1]] <- data.frame(guard = g, rows = n[1], max_id = n[2])
    }
  }
  file.create(stop_file)
  t0 <- Sys.time()
  while (!file.exists(done_file) && difftime(Sys.time(), t0, units = "secs") < 60) Sys.sleep(0.1)
  st <- do.call(rbind, st)
  # a guard that gives up (NA) has accepted nothing; one that accepts a copy must hold a committed state
  st$ok <- is.na(st$rows) | (st$rows > 0 & st$rows == st$max_id)
  cat("\n== stress (", stress_secs, " s of copies against a writer committing in bursts)\n", sep = "")
  print(do.call(rbind, lapply(split(st, st$guard), function(d) {
    data.frame(guard = d$guard[1], calls = nrow(d), gave_up = sum(is.na(d$rows)), accepted = sum(!is.na(d$rows)),
               not_committed = sum(!d$ok), min_rows = min(d$rows, na.rm = TRUE), max_rows = max(d$rows, na.rm = TRUE))
  })), row.names = FALSE)
  idle <- names(which(tapply(!is.na(st$rows), st$guard, sum) == 0))
  if (length(idle)) stop("no stress copy accepted by ", paste(idle, collapse = ", "), ", so the stress tested nothing there")
}

if (!identical(Sys.getenv("LIVE"), "FALSE") && file.exists(path.expand("~/Zotero/zotero.sqlite"))) {
  live <- path.expand("~/Zotero")
  files <- file.path(live, c("zotero.sqlite", "zotero.sqlite-wal", "zotero.sqlite-shm"))
  info <- file.info(files)
  cat("\n== live: ", paste(sprintf("%s %s %s B", basename(files), format(info$mtime, tz = "UTC", usetz = TRUE),
                                    info$size), collapse = "; "), "\n", sep = "")
  sql <- "SELECT count(*), max(clientDateModified) FROM items"
  lt <- do.call(rbind, lapply(ways, function(w) cbind(way = w, read_way(live, w, sql))))
  print(lt, row.names = FALSE)
  # each guard beside a pair read taken just before it; the live database can move between them
  lg <- do.call(rbind, lapply(names(guards), function(g) {
    pair <- read_way(live, "pair_rw", "SELECT count(*) FROM items")$n
    n <- tryCatch(guards[[g]](files[1], tries = 3, wait = 1)[1], error = function(e) NA_integer_)
    data.frame(guard = g, pair_rows = pair, guard_rows = n)
  }))
  cat("\n== live guards\n")
  print(lg, row.names = FALSE)
  if (!identical(file.info(files)$mtime, info$mtime)) cat("(a live file changed during the reads)\n")
}
unlink(root, recursive = TRUE)
if (!all(gt$ok)) stop(sum(!gt$ok), " guard run(s) did not read the fixture's rows")
if (!all(it$ok)) stop(sum(!it$ok), " interference case(s) a guard got wrong")
if (!is.null(st) && !all(st$ok)) stop(sum(!st$ok), " stress cop(ies) a guard accepted are not a committed state")
cat("\nPASS: every guard read every fixture's rows and handled every interference case", if (!is.null(st)) ", and every stress copy it accepted was committed", "\n", sep = "")
