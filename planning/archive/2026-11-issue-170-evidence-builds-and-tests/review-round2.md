# Code check, round 2: branch `170-backlog-move-1-evidence-builds-and-tests` (HEAD 9c8af31d)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check-r.md, by heading, 11 read: "Read-back shape must match write-back shape"; "`nzchar(NA)` is TRUE";
  "`identical()` on two reader results tests the reader, not the file"; "Under `R CMD check`, tests run from a temp
  dir against the INSTALLED package"; "CSV whitespace"; "`sort()` and `order()` collate by `LC_COLLATE`";
  "`file(open = "wb", encoding = )` does not re-encode on write"; "`match()` treats NA as a matchable VALUE";
  "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check`"; "`c(name = x)` keeps `x`'s own name";
  "A library call that dispatches on a global option is not a pure function". About 140 not read.
- code-check-shell.md, code-check-spatial.md: no heading names a tool, shape or pattern this diff uses; none read.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables skipped). No other heading read.

## Findings

- **[severity: fragile]** R/archive.R:31 (`.knw_archive_sites_check`) — `utils::read.csv(f_sites, colClasses =
  "character", na.strings = "", check.names = FALSE)` declares no encoding, so the CSV's strings are read as native
  ("unknown") bytes, while `sites.rds` carries 44 `gnis_name` values marked UTF-8 (and 0240 writes the CSV with
  `readr::write_csv()`, which always writes UTF-8; the real `fdis_sites.csv` holds 21 lines with non-ASCII bytes).
  Under a non-UTF-8 locale `identical(a, b)` is then FALSE for those names. Measured on the real build in a worktree:
  `LC_ALL=C Rscript -e 'pkgload::load_all(); .knw_archive_sites_check(<real csv>, <real sites.rds>)'` stops with
  "fdis_sites.csv's gnis_name is not data/fdis/build/sites.rds's: rerun scripts/0240 …"; adding `encoding = "UTF-8"`
  to the `read.csv()` call makes the same command return TRUE (it also passes in the default UTF-8 locale). The
  remedy the message names is the wrong one there: rerunning 0240 rewrites the host's `fdis_sites.csv` (and the tracked
  `data/fdis_evidence.csv`, `data/fdis_summary_ch_bt.csv`) to the same bytes, and the check refuses again; and since
  0335 runs `knw_archive_plan()` before it moves anything, a promotion run under that locale is refused too. Likelihood
  is low on the fleet's Macs (with every locale variable unset, R on this Mac still picks a UTF-8 locale, measured),
  but any `LC_ALL=C`/POSIX run (a Linux host or container, a scrubbed environment) hits it. Fix: `encoding = "UTF-8"`
  on that `read.csv()`.
  - **Rule:** code-check-r.md "A library call that dispatches on a global option is not a pure function" ;
    code-check.md "A guard's scope, escape hatches, and remedies"

## Answers to the round-1 fix questions (no defect)

- **Coverage of staged builds.** Every caller of `knw_archive_plan()` was enumerated (grep over R/, scripts/,
  data-raw/, tests/): 0336 (guarded), 0335's two calls (both pass `build_dir <- "data/fdis/build"` and
  `"data/fdis/derived"`, so `sites_dir`'s default is the right table; no staged build reaches them), and the tests
  (which pass `sites_dir` explicitly). 0335's BUNDLES=FALSE message now names `SITES_DIR`. A staged `EVIDENCE_DIR`
  with the default `BUILD_DIR` is not a hole: the host's `sites.rds` is held to the run's ledger first, so the host's
  `fdis_sites.csv` is held to the run's own sites.
- **Wrong firing.** PULL skips the guard (`!pull &&`); the default case passes. `BUILD_DIR=data/fdis/build/`,
  `./data/fdis/build` or the checkout's absolute path are compared as strings, so each refuses even though it is the
  host's build. That fails closed and its message's remedy (`SITES_DIR=data/fdis/derived`) works, so it is not
  reported as a finding. `SITES_DIR=` set empty also refuses (or, with a default `BUILD_DIR`, stops at "the evidence
  build lacks /fdis_sites.csv"): fails closed.
- **Restore pre-check.** Reproduced the intended behaviour through the tests; an NA md5 (unreadable target) lands in
  `off` and refuses, an empty `here` gives `off = character(0)`. The loop's "exists, so kept" branch now trusts the
  pre-check; only a file created between the two would be kept unchecked, which is not a realistic path.
- **minimal_network_check.R.** Checked that `cat(..., sep = "\n", append = TRUE)` in `block()` ends with a newline
  (it does), so a `say()` after a block starts its own line; nothing writes to the log before `file.create()`.
- **test-link_place.R.** `skip_if_not()`/`skip_if()` inside the one `test_that()` block; `skip_if_no_pg()` caches the
  connection. Fine.
- Real-data run (worktree, default locale): `.knw_archive_sites_check()` on the host's table and `sites.rds` returns
  TRUE in 0.6 s; `sites.rds` holds no integer64, POSIXct or list column today. `test-archive.R`: 0 failed, 0 errors.
