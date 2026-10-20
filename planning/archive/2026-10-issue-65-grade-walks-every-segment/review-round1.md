# Code-check round 1: #65 staged diff

## Checklist read

- code-check-python.md: in full.
- code-check.md: all five indexes read in full; in code-check.md, the prose of every H3 under `## Mechanisms`
  (tables and evidence blocks skipped). Of the 26 sections under "Rules that stand alone", "Security" and
  "Spreadsheets and PDFs", none read in full (none bears on this diff: no shell, CI, credentials, URLs or YAML).
- code-check-r.md: read in full "Read-back shape must match write-back shape", "Tests that silently do not
  run", "`$` on a list partial-matches", "`paste()` with a zero-length argument", "Under `R CMD check`, tests
  run from a temp dir against the INSTALLED package", "`match()` treats NA as a matchable VALUE", "A `pkg::`
  call in a test ... if `pkg` is undeclared", "A `function(...)` mock hides arguments", "`ifelse()` with an
  all-NA test". 87 other headings not read past their index line.
- code-check-shell.md: index only (0 sections read; the diff has no shell).
- code-check-spatial.md: index only (0 sections read; the diff calls no spatial tool; the FWA edge-type
  entries were checked against the index line only).

Ran `tests/testthat/test-grade_species.R` in a temp copy with `NOT_CRAN=true`: 16 expectations, 0 failed,
0 errors, 0 skipped. DESCRIPTION declares duckdb, mgcv (Suggests), tibble, DBI (Imports) and
`testthat (>= 3.2.0)`, so the test's `::` calls and `local_mocked_bindings(.package =)` are covered.

## Findings

- **[severity: bug]** R/grade_species.R:56. The new walk set (`accessible & !is.na(size) & size > 0 &
  !is.na(gradient)`) drops a population the old one walked: accessible stream-branch segments inside the
  gradient maximum whose size is NA or 0. The old `cand` used `!size_ok`, and `size_ok` is FALSE when the size
  is NA, so these segments were walked. Their `dist_m` is what `knw_compare_rules()` uses for the exception:
  `coalesce(s.knw_dist <= exc_d, FALSE)` inside `sb AND grad_ok AND (size_ok OR ex)`
  (R/compare_rules.R:128-131, :159). The tuned predicate admits a segment with MAD 0 or NA when a river lies
  within `exc_d`. After this change those segments have `dist_m = NA`, so the exception can never admit them
  and the tuned rule loses them. The change reasons use the same column (`ex_ok`, :283).
  Measured on the current local tables (`data/compare/*_segments.rds`; `knw_size` NA or <= 0, `knw_dist <=
  exc_d`, accessible):
  - CH rearing (Q3@D1000): 649 segments. 648 are `rearing_pre_tuned`, and 638 (172.7 km) are in the final
    tuned flag; 324 of those count as "gained" against `default`.
  - BT spawning (Q3@D2000): 3,297 segments. 2,700 (957.4 km) are in the final tuned flag; 2,156 count as gained.

  This breaks the plan's premise (task_plan.md, "The rule verdicts cannot move"): Phase 2's identical-km check
  on the 0330 tables would fail after a multi-hour regrade. If that failure were waved through, the comparison
  would understate both rules. 0322's candidate compares are affected the same way. The new test bakes the
  narrowing in: test-grade_species.R:57 asserts that segments g (NA size) and i (zero size), both accessible
  stream segments at 2 % gradient, are not walked.
  Fix: keep the exception's population inside the walk set. Walk every accessible segment with a gradient
  (or the union of the gradable set and the old exception candidates). The grade still drops a no-size
  segment, because `knw_grade()` drops it. Then make the test require g and i to be walked.

- **[severity: fragile]** scripts/0322-tune-grad-extend.R:255-260 (`done_rule`). A candidate whose compare is
  already on file under the same rule is kept. Those grades predate #65, and `_grades.rds` saves no
  `dist_status`, so nothing can tell them apart. 0320 gained exactly this gate (`"dist_status" %in%
  names(head1)`). A partial 0322 rerun mixes candidates graded under the old walk set with ones graded under
  the new one. Their graded km, and with the finding above their tuned km too, then compare across two
  different walk sets without saying so. The header comment records that the old grades exist but does not
  gate on them. Nothing that publishes reads `grad_ext/`, so the risk is confined to the #67 record.
  Fix: save `dist_status` in the rds and require it in `done_rule()`, or require a regrade.

Checked and clean:
- The new counts names. `data-raw/vignette_chinook.R:152` parses `segments=`, `accessible=`, `graded=` and
  `no_size=` out of the log; all are still emitted, and no new name ends in one of them. Nothing reads the
  old `found=` or `walked=`.
- `scripts/0330-compare.R` reads explicit `col_select` columns; 0325 `transmute`s explicit columns; the
  `dist_status` column passes through both harmlessly.
- `curve$q` is present in every saved curve (q = 3 for BT_spawn and CH_rear, q = 10 for the rest) with no
  `$` partial-match risk.
- The `paste` keys never carry NA. `knw_link_walks()` asserts its row count, so every start matches.
- `ifelse` over an empty `hit` assigns a zero-length vector harmlessly.
- No remaining caller passes `edge_stream=`.
