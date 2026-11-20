# Plan review of #175 (Plan agent, 2026-11-20), with verdicts

Findings as returned, condensed; each probed before folding.

| # | Kind | Finding | Verdict |
|---|---|---|---|
| 1 | Blocker | `knw_archive_plan()` archives a run: every key's `_grades.csv` must be present and match its record, so the re-archive needs `PULL=TRUE GRADES=TRUE` (~11 GB); run 0336 from the worktree root so the tracked ledger resolves | Confirmed (R/archive.R:206-210). Folded: GRADES pull into the worktree |
| 2 | Blocker | `bcfishobs_fdis_match.csv` is not an archived evidence file; m1's copy is the 2026-10-22 build | Confirmed (`.knw_archive_evidence_files`). Folded: the check regenerates it with `knw_bcfishobs_match()` on the published sites and catch, logging the bcfishobs snapshot |
| 3 | Gap | No 0230 rerun is needed for the archive: fish.rds and catch.rds already match every ledger; compare catch to `md5_catch` | Confirmed by the rerun (fish 8cf27351, catch a31fd7bb, both the ledgers'). The rerun's sites.rds differs from the published one at 245 of 51,587 visits (fresh 0.53.0 on m1 against the published build's 0.52.0): placement does not reproduce here, recorded as a finding; the published sites.rds is restored into this checkout's build |
| 4 | Gap | passes.rds and pass_catch.rds are not archived, so the new 0240 stops on any restored checkout | Confirmed. Folded: 0240 writes the pass CSVs only where 0230's passes are present and says so otherwise; 0299 already refuses a v3 missing them. Not archived: built from the export before placement, no ledger to hold them to |
| 5 | Gap | reruns rewrite tracked files | Confirmed: fdis_evidence.csv and fdis_summary_ch_bt.csv moved under m1's placement (restored); fdis_repeat_surveys.csv and fdis_maturity_check.csv unchanged. Folded: 0240 on the published sites.rds must leave every tracked output byte-identical |
| 6 | Gap | `knw_archive_put()` compares the compressed md5; if m1's zstd gives other bytes it re-sends ~11 GB and makes the published batch noncurrent | Confirmed (put compares `md5sum(body)` of the recompressed table). Folded: compress each grade table and compare with the index's `object_md5` before any put; stop if one differs |
| 7 | Gap | the cap needs the blue line's top measure, a separate query | Folded with the gate answer (Al, 2026-11-20): the span lives in the checks, not in fdis_sites.csv |
| 8 | Ordering | commit before the worktree; carry the index rows back | Already so (archive code committed at 0fc41e38 before the worktree); index rows carried back |
| 9 | Ordering | 0240 runs once, after Phase 3 | Folded |
| 10 | Assumption | FDIS-keyed bcfishobs points likely come from the visit's own UTM, so the comparison measures two snaps, not the catch location | Folded: the check reports what it can show; #137's question 2 rests on the fished span |
| 11 | Assumption | `fwa_streams_watersheds_lut` maps each segment to one polygon and the upstream-area table counts both banks, so bottom-minus-polygon understates change | Folded: reach-level local area (polygons sharing the segment's wscode and localcode) interpolated by measure along blue_line_key; lakes and double-line river skeletons apart; parent-fallback segments and segments with no lookup row excluded and counted |
| 12 | Assumption | m1's network is not verified as the published build | Folded: visits from the restored published visits_link and fdis_sites; network from whse_basemapping; flows from the discharge table, whose comment names the published load |
| 13 | Scope | #225 also names knw_fiss_visits() summing workbook passes | Declined: the workbook passes are the second source split to #245 |
| 14 | Scope | near-river flow flips not counted | Declined: that exception reads the flow of the river a walk reaches, not the visit's segment; question 1's 1-10 m3/s class covers its resolution |
| 15 | Scope | #23 rewrite: v3 as the manifest home; CPUE | Folded: #23 body notes CPUE derives from published columns |
| 16 | Acceptance | WCT rearing missing from the listed thresholds | Folded: every key's flow threshold read from thresholds.csv |
| 17 | Acceptance | span columns would stale method.rds's md5_local pin on fdis_sites.csv | Put to Al: the span stays in the checks; the published column waits for move 12's method-bundle rebuild |
