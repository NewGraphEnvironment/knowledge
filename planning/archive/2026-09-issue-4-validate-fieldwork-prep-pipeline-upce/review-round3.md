# Review round 3 — narrow verification of the round-2 fixes

Scope: the three changes since round 2 (gnis.R rename + NA filter + guarded example;
test-gnis.R NA fixture; context_pine.md:78 query command). Checks were executed, not
reasoned about: the staged `pkg/` tree was extracted (`git archive` of the index), the
test file run against it and against a copy with the NA filter line deleted, and the all-NA
and mixed-NA paths probed directly against duckdb.

## Clean

No real issues found. What was verified:

- **Rename reached every use.** `stream_names` in the signature (gnis.R:31), `chk_character`
  (33), the `seed` construction (36), `@param` (10), and `man/knw_gnis_collisions.Rd` usage +
  arguments. `scripts/0110-gnis-collision-check.R:32` and both test files call positionally, so
  no caller names the old formal. `git grep --cached '\bnames\b'` over `pkg/` and `scripts/`
  returns only `names(...)` calls — no stray `names =` argument anywhere.
- **NA filter placement and `.data`.** The filter (gnis.R:48) sits after the fetch and before
  the empty-result return (49), so an all-NA result returns the typed empty tibble
  (`chr(0)/int(0)/chr(0)/logi(0)`) with `not_found` = the full seed — probed:
  `c("Null Creek", "Ghost Creek")`. A name with `PINE` + `NA` keeps its `PINE` row and reports
  `n_wsg = 1`, `wsg_only = TRUE`. `importFrom(rlang,.data)` is in the staged NAMESPACE. The
  filter cannot drop a legitimate (non-NULL) pair.
- **The fixture discriminates.** With the filter line deleted from a scratch copy, test-gnis.R
  fails 3 assertions (row order `Wildmare` before `Other`; `n_wsg` 3,2,1 vs 3,1,1; `wsg_only`
  inverted), 6 pass. With the filter, 0 failed / 9 passed. `n_distinct(c("PINE", NA))` is 2, as
  the round-2 finding predicted.
- **Guarded example.** Wrapped in `if (requireNamespace("duckdb", quietly = TRUE))` in both
  gnis.R and the regenerated Rd; `duckdb` stays in Suggests.
- **context_pine.md:78.** `ACTION=query STORE=peace QUERY="..." Rscript scripts/0150-store.R`
  matches 0150-store.R's contract: `ACTION` via `match.arg(Sys.getenv("ACTION","query"), ...)`
  (line 32), `STORE` required by `stopifnot` (34), `QUERY` read at line 89. `data/rag/peace.duckdb`
  exists locally and `peace` is in the S3 manifest (push log: "now holds: fraser, vca_refs,
  peace, pine"), so the download path on a fresh machine also resolves. `AWS_PROFILE` remains
  the caller's responsibility, as accepted in round 1 and stated in the 0150 header.

## Note, not a finding

- All-NULL-coded names are now classed differently from the original SQL: the original returned
  a row with `n_wsg = 0`, `wsgs = NULL`, `wsg_only = NA` (and 0110's summary counted it in none
  of its three tallies), whereas the port puts the name in `not_found` and 0110 reports it as
  "not in FWA (manual)". This is the more honest outcome and is unreachable on
  `bcfishpass.streams`, which carries no NULL codes.
