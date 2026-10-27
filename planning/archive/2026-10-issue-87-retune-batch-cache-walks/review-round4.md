# Code-check round 4 (#87): since 2d395e4

## Checklist read

- `code-check-python.md`: in full (7,237 bytes). Nothing applies: the diff has no Python.
- `code-check-r.md` (178,405 bytes): read these sections in full: "A database driver's value is not a base R type",
  "`system2(stdout = TRUE)` warns on a non-zero exit", "Postgres row order is never fixed", "A `data-raw/` script
  must load the source tree", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package",
  "A `pkg::` call in a test passes `devtools::test()`", "Tests that silently do not run". Not read: the other 105.
- `code-check-shell.md` (125,440 bytes): read "A failed `git fetch` leaves the comparison you make next reading stale
  refs" (the `origin/main` default). Not read: the other 104.
- `code-check-spatial.md` (155,517 bytes): read no section. No heading names a tool this diff uses. 0 read.
- `code-check.md` (330,698 bytes): read the prose of all 14 H3s under `## Mechanisms`, without the table rows or the
  evidence blocks. Not read: the 24 headings outside Mechanisms.

## The mechanism behind both RPostgres failures

R passes arguments as promises, and RPostgres forces `params` only after it has prepared the statement. The
installed RPostgres is 1.4.10. Its `dbGetQuery()` hands `...` to `dbSendQuery()` without evaluating it. In
`dbSendQuery()`'s `.local(conn, statement, params = NULL, ...)`, the statement is forced first
(`stopifnot(is.character(statement))`). Then `result_create(conn@ptr, statement, immediate)` sends the Parse for the
unnamed prepared statement `""`. Only after that does `if (!is.null(params)) dbBind(rs, params)` force `params`.

Suppose the `params` expression, or a function formal that reaches `params` unforced, runs another query on the same
connection. That query is prepared as `""` while the outer result is still open, which clears the outer statement.
The outer Bind then meets the inner query's parameter count: "bind message supplies N parameters, but prepared
statement "" requires M".

The two cases were the same mechanism one level apart:

- `.knw_load_md5(conn, load)`, where `load` was the promise `knw_discharge_load(conn)`.
- `params = list(.knw_load_md5(conn, knw_discharge_load(conn)), ...)`.

A query in the statement argument, for example inside `sprintf()`, cannot cause it, because the statement is forced
before the Parse. `list()` and other builtins evaluate their arguments at once, so a query inside a top-level
`list(...)` assigned to a variable is also safe. Only a query that is evaluated between the Parse and the Bind causes
it: in `params`, or in a formal that arrives unforced and ends up in `params`.

### Every place it could reach

I parsed all 26 calls in tracked `.R` files that pass a named `params`. That count agrees with the findings row. No
parameterised call passes `params` positionally (checked by grep). For each call I read the `params` expression and
traced every formal it uses back to its first forcing.

| place | `params` | verdict |
|---|---|---|
| `R/link_walks.R:130` (hit query) | `l`, `min(...)`, `paste0`, `.knw_pg_array(q_grid)`, `meta$*` | pure; `meta` already evaluated |
| `R/link_walks.R:204` (`.knw_walk_chunk`) | `pg_array(chunk$...[b])`, `qs`, `src` | pure; `chunk` forced by `nrow(chunk)`; the worker has its own connection |
| `R/link_walks.R:254` (`.knw_walk_cache_prepare`) | `load_md5`, `load` | both assigned eagerly on the lines above |
| `R/link_walks.R:264` (`.knw_load_md5`) | `load` (a formal) | **was the defect**; now `force(load)` comes before the prepare |
| `R/build_record.R:31` | `paste0(schema, ...)` | `schema` forced by `chk_string`; `knw_discharge_load(conn)` runs inside an eager `list()` at :38 |
| `R/grade_species.R:112` | `ids` (local) | pure |
| `data-raw/walk_batch_check.R:104` | `cache_tbl` | pure |
| `data-raw/walk_batch_check.R:110` | `key_md5` | **was the defect**; now built by an eager `list()` at :107 |
| `scripts/0320-tune-run.R`, `scripts/0330-compare.R` | none | no parameterised call. `groups_sp()` and `knw_discharge_load(conn)` run in top-level assignments or eager `list()`s. `knw_build_record(..., run_uid = run_uid)` takes a variable |
| `R/link_access_check.R`, `R/link_place.R`, `R/bcfishobs_match.R` | the formals `schema` and `species_codes` | forced by `chk_*` before the first query |
| `R/link_barrier_dnstr.R`, `data-raw/walk_bank_check.R` (2), `scripts/0150` (2), `0240`, `0280` (4), `0298`, `0300` (2), `0310`, `tests/testthat/helper-pg.R` | locals, or a formal forced by `is.null()` first (`helper-pg.R`) | pure |

No other reach remains. `.knw_load_md5` was the only helper that put an unforced formal into `params`. The new test
line (`test-link_walks.R:108`) fails with an error if `force(load)` is removed. The script-level form in
`walk_batch_check.R` has no test, which is acceptable for a `data-raw/` check.

## Findings

- **[severity: claim]** `CLAUDE.md:359` and `research/database_builds.md:16`. Both say `0320` and `0330` check "the
  same build (the schema's run, the flow load named in the table comment, the walk code)" at connect.
  `knw_build_record()` refuses only on `run_uid` (`R/build_record.R:42`). It records the flow load and refuses nothing
  on it. The walk's md5 is the package's own file (`knw_walk_md5()`), not something the database holds. Downstream,
  `0320` regrades on a different load at its keep-check instead of refusing (`0320:323`), and `0330` never compares
  `discharge_load`.
  - The research file's own later sentence is accurate: "refuse a schema whose run is not the evidence ledger's at
    connect" (around :92).
  - `research/database_builds.md:107` also lists "the walk installed from the same code" as something a second
    database needs. The walk is installed into each session from the checkout (`pg_temp.ch_dist_profile`), so it is
    not part of the database.
  - Why it matters: a reader would trust the connect check to catch a second database whose flow load differs. It
    does not.

- **[severity: claim]** `research/database_builds.md:83` says "the km sums agreed within 1.0e-13 relative". The log
  `20261026_compare_parallel_check.txt` gives CH_rear compare's largest relative difference as 1.04344e-13, which is
  above 1.0e-13. Write "within 1.1e-13", or "about 1e-13".

- **[severity: claim]** `planning/active/findings.md:216` says "Before, seven keys ran at once, one database core
  each". The log `20261024_compare.txt:4` reads "Compared 7 species x stage in 160.1 min on 6 workers", so at most six
  keys ran at once. The same section (:210) says "seven keys sharing six workers", which matches the log. The 578 %
  CPU figure also fits six workers.

- **[severity: claim]** `planning/active/findings.md:205` says "CO 373,154 of 615,302 starts, the fewest". CO has the
  smallest share (61 %), not the fewest walks: WCT read 149,224 (`20261026_tune_run.txt:6970`). Say "the smallest
  share". The research file's version, "from coho's ... to steelhead's", reads correctly as a range of shares.

- **[severity: claim]** `research/database_builds.md:13` says "a recompare of every key about 2.7 h (as before ...)".
  The two sides are measured differently. Before, 160.1 min (2.7 h) included the GeoPackages. Now, 162.9 min (2.7 h)
  excludes them, and with them the run is 176.9 min (2.9 h). `findings.md:215` states this correctly: 160.1 against
  176.9. Either state the total with the GeoPackages, or say that the 2.7 h now excludes them.

- **[severity: fragile]** `scripts/0330-compare.R:109`. The old code treated `CONFIG_SHA` set but empty as the default
  (`Sys.getenv("CONFIG_SHA", "")` with `nzchar()`). `Sys.getenv("CONFIG_SHA", "origin/main")` returns `""` when the
  variable is set to the empty string. The run then stops with "could not resolve  to a commit in ../link; set
  CONFIG_SHA", which I reproduced against the local link checkout. A chain that passes `CONFIG_SHA="$CONFIG_SHA"`
  through therefore aborts where it used to take `origin/main`. It fails loudly and writes nothing; the cost is a
  confusing message.
  - Fix: `config_ref <- Sys.getenv("CONFIG_SHA"); if (!nzchar(config_ref)) config_ref <- "origin/main"`.
  - Otherwise the new resolution behaves correctly on `origin/main`, on the short `102762da` (resolves to the full
    sha) and on a nonexistent ref (exit status 128, refused).

## Checked and clean

- **Per-key numbers.** Every per-key `0320` number in the findings and the research file matches
  `20261024_tune_run.txt` and `20261026_tune_run.txt`: walk minutes, totals, hits and misses, and 53.4 and 190.9 min.
  The warm run's 4.1 min and 3.1 min match `20261026_tune_run-warm.txt`.
- **Comparison times.** The per-key `0330` times, before and after, match the logs, as do 143.3, 162.9, 14.0 and
  176.9 min. The classify minutes sum to 115.2, and BT rearing's are 27.4 of 33.4.
- **The 41-minute estimate.** Dividing each key's classify minutes by its number of rules gives 40.9, which matches
  "about 41".
- **Ranges.** "4 to 37" and "50 to 160" match the per-key times, and "4 to 17 min" matches the GeoPackage times.
- **Cache size.** 4,459,402 rows equals the misses at 10 m³/s (3,603,158) plus CH's 856,244 at 3 m³/s.
- **Per-walk costs.** 4.67 and 8.2 ms per walk per worker are consistent with 8 workers. The walk-batch logs give
  2.65, 3.15, 6.71, 7.28, 17.5 and 11.7 ms, and every batched run was identical on 14 columns.
- **Smoke gates.** `0320` does run four smoke gates per key and stops on a failure (`0320:182`).
- **Public text.** The new text names no host, port or login.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round4.md

## Disposition (2026-10-27)

- Build-check claims (CLAUDE.md, research note, "walk installed"): reworded to what the code does; and `0330` now
  compares each grade table's `discharge_load` with the database's (it compared `walk_md5` only), which is what item
  5 of the issue asks for. The comparison is the one `0320`'s keep-check already makes on the same read (the warm
  `0320` kept seven keys under it).
- 1.0e-13 -> 1.04e-13 (research note and findings' Phase 3); "the fewest" -> "the smallest share"; "seven keys ran at
  once" -> "seven keys shared six workers"; "2.7 h (as before)" -> 2.9 h with GeoPackages, 2.7 h before.
- Empty CONFIG_SHA: falls back to `origin/main` again. Inside a fix (`38bd09f`), so enumerated: the branch's scripts
  read 17 environment variables with a default; CONFIG_SHA was the only one with an empty-means-default rule, now
  restored; the others fail loudly on an empty value, unchanged from before the branch.
