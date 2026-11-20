# Plan review for #176 (batch 11: #7, #34, #10), 2026-11-20

Spawned 2026-11-20T22:03:20Z (Plan agent, background, read-only), returned during Phase 2. Findings as the reviewer
gave them, each with the verdict reached here after a probe.

| # | kind | finding | verdict |
|---|---|---|---|
| 1 | Acceptance | Phase 2 compares against tracked md5s that cannot match: the reconciles name the database (`enumerate_db_source`, `clip_polygon_source`) and the GeoPackages are rewritten with `delete_dsn` | Already settled in Phase 1: the reference is the baseline run of the unchanged `0220`; GeoPackages compared as content; files whose content did not change are restored. Plan text updated |
| 2 | Gap | No run of the unchanged `0250` before the #34 fix, so drift from #91's `sites.rds` or the database would be blamed on #34; diff all four tables `0250` writes | Adopted: Phase 4 runs `0250` unchanged first and diffs the fix against that run |
| 3 | Gap | The readers of the #34 gradient are `scripts/0293` (heading "site gradient_pct is a fraction, #34") and `research/bt_spawning.md:99`; `research/fdis_export.md` does not describe it | Confirmed by grep; adopted |
| 4 | Scope | The per-group tables and GeoPackages keep the fraction under `average_gradient_percent`, and #248 publishes them | Adopted as documentation: `scripts/README.md` says so, and #248's body carries the conversion as owed work |
| 5 | Acceptance | The next `0310` gets a new `recipe_id` (`fiss_evidence` is a recipe input), so grade and fdis v3 receipts no longer name the same evidence input | Recorded and reported in the PR; nothing outside `0310` recomputes the hash (reviewer's grep, mine agrees). The receipt is doing its job: the input changed |
| 6 | Assumption | "Stop on a value above 1" never fires and cannot catch an unformatted 0.5 meaning 0.5 %; read all 25 reports' cell formats; set an implausible row NA and count it rather than stop the build; state the band first | Adopted: formats read for every report carrying a gradient; a raw value above 1 becomes NA, counted in the reconcile; band stated before the rerun |
| 7 | Gap | The fixture list in the plan contradicts the measured layouts | Plan text stale: the fixtures written are by layout (V2.0 31/23/18/20 with both banner spellings, pre-2012 26/6, header 17, per-fish 4, tissue). Plan updated |
| 8 | Assumption | xls via libxls renders numbers in text columns to 17 digits, xlsx to 15; formulas have no cached value in openxlsx; numeric cells must be written as numbers | Checked: the fixtures write literal numbers as numbers; numeric asserts go through `as.numeric()`; the xls fixture's gradient reads "0.025000000000000001", pinned in a test |
| 9 | Gap | Eight statuses, not seven; `no_rows` has two routes (the reference-number filter, and the key-only payload filter) | `sheets_error` and `empty_sheet` were already covered; adopted: a fixture for the first `no_rows` route |
| 10 | Scope | The column list was passed config and is now fixed: add `cols`; no site-table function; duplicated UTM window; small exports; the roll-up's name | `cols` adopted (`knw_fiss_select()`, `knw_fiss_parse_step()`); a site-table function, the UTM window and renames are out of scope (said in the PR); the exports stay as #7 names them |
| 11 | Assumption | #10: list every expected change (fetch log column order, converted names, three reconcile rows); a 4xx from ACAT passes silently; moving the old folder to a non-ignored sibling puts 77 submission workbooks one `git add -A` from the public repo | Adopted: the expected changes are listed in Phase 3, the old folder goes to the scratchpad, and the rollback is written down |
| 12 | Assumption | The template's copyright page reserves all rights; Al decided on template fixtures without that fact | Open decision for Al (labels and banners only, noted on #76); `task_plan.md` `## Open decisions` |
| 13 | Gap | Every name depends on `janitor::make_clean_names()`: test it over each layout's labels | Adopted |
| 14 | Ordering | Plan text stale; `findings.md` names the machine (fine in `planning/`, not in the PR); check run logs for home paths | Adopted |
