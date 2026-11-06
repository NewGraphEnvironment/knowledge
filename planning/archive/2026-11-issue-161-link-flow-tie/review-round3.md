# Code-check round 3 (#161)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check.md: every H3 under `## Mechanisms`, read as prose with the table rows skipped. Read in full: "Written data
  outlives the fix", "One fact derived twice", "A fix lands in one of two callers that share a harness", "A fixture
  that cannot reach the failure mode", "Restore the bug and prove the guard fires", "Verification that reads its own
  output". Under "Rules that stand alone" only "Documentation Staleness" was read; none of the others matches anything
  in the diff.
- code-check-r.md: "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence
  check can each depend on it", "A database driver's value is not a base R type — and it fails twice", "`sort()` and
  `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent", "CSV whitespace: `trim_ws` and
  `strip.white` do not do what the name suggests", "Under `R CMD check`, tests run from a temp dir against the
  INSTALLED package", "A `data-raw/` script must load the source tree, not the installed package". About 140 headings
  not read, because they name no tool or pattern the diff uses.
- code-check-shell.md and code-check-spatial.md: index only. No heading names a tool or pattern the diff uses beyond
  what the R sections cover, so 0 sections were read in each.

## The mechanism behind round 2's finding

Round 2's finding was a fact that holds for one artifact applied to a consumer that works it out again. The parent flow
is fixed into the evidence tables at `0310` time. But `knw_grade_species()` does not read the evidence's flow: it
calls `knw_link_flow()` again, live, through `knw_link_segments()`. So "the change reaches them only with the next
build" was true for the evidence and false for the grades. The way to close it is to classify every consumer of the two
changed functions as live or stored, and then check each prose claim about when the fix takes effect against that list.

### Every consumer, and whether it recomputes or reads a stored table

Grep over `R/`, `scripts/`, `data-raw/`, `vignettes/` and `inst/`, counting code calls only (roxygen and comments
excluded):

| consumer | calls | live or stored | reached by the fix |
|---|---|---|---|
| `knw_link_segments()` (R/link_segments.R:83) | `knw_link_flow(conn, miss)` on segments with no flow of their own | **live** | at every call |
| `knw_grade_species()` (R/grade_species.R:96) → `0320` grading (scripts/0320-tune-run.R:645), every gradient (`segment`, `parent`, `fwa`) | `knw_link_segments()` | **live** | at the next grading, on any build; only keys sized by `mad_pick` (width keys read `channel_width`) |
| `scripts/0322-tune-grad-extend.R:282` (frozen) | `knw_grade_species()` | live | if it is ever rerun |
| `data-raw/walk_batch_check.R:79` (timing probe) | `knw_link_segments()` | live | if it is rerun; it publishes no decision |
| `0310` visits (scripts/0310-evidence-build.R:280) | `knw_link_flow()` → `visits_link` | **stored** (`data/fdis/derived`) | at the next `0310` |
| `0310` workbook sites (scripts/0310-evidence-build.R:408) | `knw_link_flow()` → `workbook_sites.csv` | stored | at the next `0310` |
| `0310` visit regulation (scripts/0310-evidence-build.R:308) | `knw_link_regulated()`, given wscode/localcode that may come from the parent | stored | at the next `0310` |
| `0310` walk-target regulation (scripts/0310-evidence-build.R:357) | `knw_link_regulated()` → `target_regulated` | stored | at the next `0310` |
| `0320` scoring and curves (`knw_tune_run`, `knw_rule_in`, `knw_tune_curve`) | read the evidence's `mad_pick`, `regulated` and `target_regulated` | stored | at the next `0310`, then a rescore |
| `0330` (R/compare_rules.R:308, :608) | `g.size` from the stored grade table; its own `mad_m3s` is the own flow only, with no parent fallback | stored (the grade table) | at the next grading, then a rerun of `0330` |
| `0325`, `0335`, `data-raw/vignette_chinook.R`, `data-raw/vignette_method.R`, `0299` | the grade tables and evidence as written | stored | at the next promotion of regraded tables or a new evidence build |
| `data-raw/link_flow_tie_check.R`, `tests/testthat/test-link_flow.R` | the functions themselves | live | yes (the check and the tests) |

Nothing grades or scores off `knw_link_regulated()` live. Its only callers are `0310` (stored) and the check and test.

### Each prose claim checked against that table

- research/database_builds.md:241-242, "The change reaches the visits at the next `0310`": holds for every stored row
  above, including the dam snap (regulation is used only at `0310`) and the workbook sites.
- research/database_builds.md:242-243, "and the grades at their next grading on any build, because grading reads each
  segment's parent flow live (`knw_link_segments()`)": holds. Grading is the only live path, and it is live on every
  gradient setup.
- research/database_builds.md:243, "about 630 parent-flow lines move on either database, all of them tied": checked
  against the read outputs (`scratchpad/tie/out/*_flow.csv`). On the host, old against new, all 632 differing lines
  have `flow_from = parent` and all 632 differ in `mad_pick`; none differs in codes alone. On the second database, old
  against new, all 636 differ in `mad_pick`. The log row's `flow_differ_all_tied` is TRUE. The claim holds.
- research/database_builds.md:244-245, "`0320`'s keep-check records nothing that names the tie rule, so a candidate
  graded before 0.4.32 is regraded, not resumed": the keep-check (scripts/0320-tune-run.R:604-614) compares rule,
  run_uid, walk, walk_md5, ref_edge, discharge_load, curve_prior_sd, grade_withheld, null_heldout_curve, evidence_md5
  and the curve's gradient. It does not compare `knowledge_commit`, so it would keep a pre-fix table. The consequence
  the sentence draws is right. "Records" is loose wording: the grade record and the receipt do carry the knowledge
  commit, but no check reads it. That does not change what an operator does, so it is not a finding.
- research/database_builds.md:263-265 and CLAUDE.md:547-551, "Until #162 is fixed … a promotion takes all its keys
  from one database", with research adding that pre-0.4.32 grades can differ on the tied segments: these are
  consistent with the table. Pre-fix grades stay plan-dependent, and post-fix grades are deterministic. Either tie
  choice is arbitrary, so a by-key promotion that sets post-fix grades beside kept pre-fix ones is no correctness
  problem, and the one-database rule already covers reproducibility.
- CLAUDE.md:548-550, "Grading reads the parent flow live, so the fix reaches grades at their next grading; `0320`'s
  keep-check cannot tell a grade made before it": both halves hold, as above.
- Roxygen and man (link_flow, link_regulated): these describe the new ORDER BY exactly as the SQL has it.

## Other checks that held

- Both ORDER BY clauses end on `linear_feature_id`, the FWA key. A wet pick is one row per segment (an accepted
  tradeoff).
- Live dam test: its reference takes the 3 nearest segments without a tiebreak. A tie of 3 or more would let that
  reference miss the lowest id, so I measured the build (read-only, 101 dams, LIMIT 6). Only 2 dams tie at rank 1, and
  both are 2-way ties, so LIMIT 3 covers them.
- The fixture test calls `.knw_link_flow_sql()` on temporary tables whose names it controls. Segment 10 has no flow
  row, so the join excludes it as its own candidate. The `DROP` defer runs before the cached connection is reused.
- `link_flow_tie_check.R`: `diff_keys()` refuses a different key set, every column is compared as character, and NA is
  written `""` on both sides. The committed meta log lacks the `n_parent` column the current read mode writes,
  because the runs came from the earlier version the compare-mode comment names. Mixing old and new read outputs in one
  compare would stop at `rbind`, loudly rather than silently, so it is not a finding.
- No machine or host name in the tracked diff. The labels are `host` and `second`.
- 0.4.32: DESCRIPTION and origin/main are both at 0.4.31, and nothing has landed on main since the branch point.

## Clean

No issues found.
