# Review: stream-branch reference for the grade (#65), round 1

Diff: `/tmp/codecheck.wdiHrA/diff4.patch` (staged vs HEAD ec67685).

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (all 14, table rows skipped). Stand-alone rules: none
  read in full beyond their index lines ("Documentation Staleness" applied from its index line). 0 Mechanisms headings
  unread; the 21 stand-alone, Security and Spreadsheet headings were not opened.
- `code-check-r.md`: read 13 headings: Read-back shape must match write-back shape; Tests that silently do not run;
  testthat counts an uncaught error under `error`; A `skip_if_not()` skips only its own block; `$` on a list
  partial-matches; open_dataset(unify_schemas); `nzchar(NA)`; `identical()` on two reader results; Under `R CMD
  check`, tests run from a temp dir; CSV whitespace; `match()` treats NA as a value; `tolerance` is relative;
  `data.frame()` recycles a scalar; dot-prefixed column name; Rscript reads a script as it runs; Inside a dplyr verb a
  column named like a local variable wins; `bind_rows()` of all-NULL; `ifelse()` with an all-NA test. The remaining
  ~95 headings were not opened (no tool, shape or pattern of theirs in the diff).
- `code-check-shell.md`: index only; the diff has no shell. 0 headings opened.
- `code-check-spatial.md`: index only; the diff has no spatial code. 0 headings opened.

## What was checked and holds

- **Every other `knw_grade()` caller** (grep over R/, scripts/, data-raw/, vignettes/, tests/):
  `data-raw/vignette_chinook.R:185` (surface grid; reads `rate` only, which `ref_rows` does not touch) and
  `tests/testthat/test-tune_curve.R:68,78` (default `ref_rows = NULL`, old behaviour). `ref_rows` is appended last,
  so no positional call shifts. `test-tune_curve.R` passes in a temp copy (0 failed, no error).
- **Accessible only**: `acc <- rate[segments$accessible %in% TRUE & ref_rows %in% TRUE & !is.na(rate)]` keeps the
  accessible filter; NA in `ref_rows` reads FALSE.
- **NA `edge_type`**: `knw_link_segments()` casts `edge_type` with `as.integer()` (R/link_segments.R:58); an NA edge
  type is `%in%` FALSE, so it is graded but kept out of the reference. Default `ref_edge` equals
  `knw_tune_run()`'s `edge_stream` default, and 0320 calls `knw_tune_run()` without overriding it.
- **Readers of `data/tune/*_grades.csv`**: 0330 reads with `col_select` of six named columns (new column ignored);
  0325 `bind_rows()` then `transmute()` drops `ref_population` (a mix of files with and without it binds, filled
  NA, then dropped), so the published Parquet schema is unchanged; 0322 reads its own `.rds`, not the CSV;
  `knw_compare_rules()` checks/selects its six columns. `vignette_chinook.R` reads the log, not the table.
- **Regrade notice**: `"%s: grades on file ..."` cannot match `^CH_rear grades:`; the keep line is unchanged.
- **Keep check**: read with `.default = "c"`, so `identical(head1$ref_population, "stream_branch")` compares
  character to character; a table with `dist_status` but no `ref_population` (today's CH table) is regraded.
- **Tests, mutation**: in a temp copy the new block passes (4 expectations). Removing `ref_rows =` from the
  `knw_grade_species()` call: 1 failure; removing `& ref_rows %in% TRUE` in `knw_grade()`: 2 failures. Both guards
  are tested.

## Findings

- **[bug] scripts/0325-publish.R:84** — the published `habitat_grade` table description still says the grade is
  "relative to the 95th percentile of accessible segments". After this diff the reference is the 95th percentile
  over accessible **stream-branch** segments (edge types 1000/1100/2000/2300). That string goes into the manifest of
  `knowledge/habitat_grade/v1` via `knw_publish()`, so the first publication of the corrected grades would carry a
  definition of the denominator that does not match the values (the two differ by 0.14 vs 0.52 for chinook). Same
  stale wording, lower stakes: `R/grade.R:26` `@param ref_quantile` ("the quantile of accessible segments' rate").

- **[fragile — evidence loss] scripts/0320-tune-run.R:64-66, 216** — the regrade this diff exists to trigger, if run
  as `SPECIES=CH` on 2026-10-19, writes `scripts/logs/habitat/20261019_tune_run-ch.txt` with `writeLines()`,
  overwriting the untracked log of the all-accessible run (`reference rate 0.5156`, the walks timing) that
  `planning/archive/2026-10-issue-65-grade-walks-every-segment/findings.md:98-110` cites as evidence for the decision. The file is `??` in git, so nothing
  recovers it. Commit or copy it before the rerun (or run under another SPECIES/date).

- **[fragile — low] scripts/0322-tune-grad-extend.R:256-263** — the sibling caller of `knw_grade_species()` keeps a
  candidate's `_grades.rds` whenever it has `dist_status`, and its saved columns carry no reference marker, so a
  grade table written by ec67685's code (all-accessible reference) would be reused as if current. Checked: none of
  the five `data/compare/grad_ext/*_grades.rds` on this disk has `dist_status` (all predate ec67685), so all will be
  regraded with the new reference; the hole only matters if 0322 ran at ec67685 on another machine and its files are
  copied here.
