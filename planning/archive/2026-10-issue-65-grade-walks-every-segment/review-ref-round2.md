# Review: stream-branch reference for the grade (#65), round 2

Diff: `/tmp/codecheck.wdiHrA/diff5.patch` (staged vs HEAD ec67685), with round 1's fixes.

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped). The
  stand-alone, Security and Spreadsheet headings were read from the index only (none matches a tool or shape in
  this diff beyond "Documentation Staleness", applied from its index line).
- `code-check-r.md`: 12 headings read in full: Read-back shape must match write-back shape; `$` on a list
  partial-matches; `match()` treats NA as a value; `identical()` on two reader results; CSV whitespace; A
  `data-raw/` script must load the source tree; Under `R CMD check`, tests run from a temp dir; Tests that silently
  do not run; A `skip_if_not()` skips only its own block; `tolerance` is relative; Postgres row order; `ifelse()`
  with an all-NA test. About 108 headings not opened (their tools and shapes are not in the diff).
- `code-check-shell.md`: index only; no shell in the diff. 0 headings opened.
- `code-check-spatial.md`: 1 heading read in full ("FWA main flow is not edge type 1000 alone", because the diff
  selects on 1000/1100/2000/2300); the rest index only.

## What was checked and holds

- `tests/testthat/test-grade_species.R` on the staged tree in a temp copy (`NOT_CRAN=true`,
  `testthat::test_file()`): 4 blocks, 22 expectations, 0 failed, 0 error, 0 skipped.
- 0320 keep check: `head1` is a tibble read with `.default = "c"`, so `$ref_population` cannot partial-match and
  compares character to character; a 0-row table gives `character(0)` and is regraded. The regrade notice cannot
  match `^CH_rear grades:`.
- 0322 `done_rule()`: only the new writer writes `ref_population`, and it writes `dist_status` in the same rds, so
  dropping the `dist_status` test loses nothing. `gr$ref_population <- "stream_branch"` cannot meet a 0-row frame
  (`knw_grade()` stops first when no reference segment has a rate).
- The FWA edge-type rule: 1000/1100/2000/2300 drops double-line rivers (1250/1450) by design here; the set equals
  `knw_tune_run()`'s `edge_stream`, the population the curve was fitted on, and 0320 does not override it.
- 0325 `transmute()` drops `ref_population`, so the published schema is unchanged; 0330 reads six named columns.

## Findings

- **[bug — low] scripts/0325-publish.R:84** — round 1's fix to the published `habitat_grade` description says the
  grade is "read at the segment's own walked distance to the rule's river". Only rules with an exception have a
  river: `knw_tune_curve()` walks to `exc_q`, and to `q_default` (10 m³/s) when the pick has none
  (R/tune_curve.R:55), and `knw_grade_species()` does the same (R/grade_species.R:73). Six of the eight
  species × stage tables 0325 publishes have no exception (`data/tune/*_summary.csv` `rule_recommended`: BT_rear,
  CO_rear, GR_rear, RB_rear, ST_rear and WCT_rear end in `|none`; only BT_spawn and CH_rear carry a `Q`). So the
  manifest of `knowledge/habitat_grade/v1` would name a river for six tables whose rules have none. Something
  like "to the first river of the rule's exception flow, or of 10 m³/s where the rule has no exception" matches the
  code.

- **[fragile] scripts/0325-publish.R:71-80 (and scripts/0330-compare.R:131)** — the corrected description is now a
  claim about how the grade tables were made (every segment walked, reference over the stream branch). Nothing in
  0325 checks it: it binds every `data/tune/*_grades.csv` on disk and then drops `ref_population` and
  `dist_status` in `transmute()`. As of this review, none of the eight tables on disk carries `ref_population`
  and seven lack `dist_status` (only CH_rear has it). A 0325 run before the full 0320 regrade, or on a host given
  a stale table with the caches copied (0320's RUN note invites that), publishes the old grades under the new
  definition, with nothing to show it happened. 0330 reads the same files the same way, so its graded-km columns
  could also come from the old reference. The guard that holds this property sits only in 0320's keep-or-regrade
  step, which is not the step that publishes. A check before `bind_rows()` that every file has
  `ref_population == "stream_branch"` (which implies `dist_status`), stopping on any that does not, closes it.

Not findings (noted for the record):
- `ref_population` is a literal the callers write, not a value `knw_grade_species()` reports, so it vouches for the
  `ref_edge` default rather than for the call. No caller overrides `ref_edge` today.
- `data-raw/vignette_chinook.R` (unstaged, outside this diff) still reads the grade meta, including
  `reference rate`, from the hard-coded `20261017_tune_run-bt_ch_co_st.txt` log, so the article's grade numbers
  stay on the pre-#65 reference until it is pointed at the regrade's log.
