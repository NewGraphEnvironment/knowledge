# Plan review for #174 (Plan agent, 2026-11-18), with disposition

Reviewer: Plan subagent, read-only, against the issues and the code; its reply was copied here by the session.
Verdicts are the session's, each checked against the code or a probe before folding.

## Blocker
- **B1. Crate step vs crate#74 (one variant, lower snake names, dates as strings).** Folded: plan rewritten to
  what crate#74 registers. The 49-column copies are our scripts' renamed output, not a release as received.
  The `crate-nuseds` worktree is this session's own (created for #74).
- **B2. crate#41's read-as-character fix.** Folded: the crate PR carries it, with a test that fails on the
  old read (the grouping-mark case; a blank-then-value column did not fail, because readr 2 samples its guess
  rows across the file). Also found: the file is Latin-1, so a variant now declares its `encoding`.

## Gap
- **G1. wet's readers have no `pick`.** Folded: visits read `visits_link$pick_source`; rivers read `pick` from
  `discharge.fwa_v1_segment_monthly` through the connection, as `.knw_link_flow_sql` does.
- **G2. 26 visits take their flow from a parent.** Folded: look the parent up again, or drop them and report
  the count.
- **G3. The daily check needs each river's group.** Folded.
- **G4. Population guard.** Folded: stop unless 7,823 / 235 / 111 / 45 (`data/tune/CH_rear_summary.csv`).
- **G5. MAD baseline guard.** Folded: `knw_rule_in()` must reproduce the published rule's in/out first.
- **G6. `knw_publish()` takes a CSV and uploads no README.** Folded: 0340 writes a CSV; README source is a
  tracked `data/nuseds_README.md` with its own upload step.
- **G7. Receipt test and docs.** Folded.
- **G8. .gitignore.** Folded. `data/tune/flow_window/*.csv` are tracked on purpose (small tables).
- **G9. Timing claims go in `literature_evidence.csv` as `timing` rows, checked by 0280.** Folded.
- **G10. The upload is a production write.** Folded: `PUBLISH=TRUE` gate, bare command for Al if refused.
- **G11. ckanr in DESCRIPTION in Phase 1.** Folded.
- **G12. `wet_window_stats()` needs a `Date` column; a 7-day minimum over 30-year mean days is no dry-year low
  flow.** Folded: #42's piece is the daily-basis window mean; the 7-day minimum goes with dry years into the
  split issue (it needs per-year daily flow, which wet does not publish per segment). No wet issue: wet's
  function is right for what it is for.
- **G13. The Cottonwood item may be in a store.** Folded: check the stores before changing its creators.

## Ordering
- **O1. The crate release blocks the PR.** Folded: Phase 2 runs while the crate PR waits.
- **O2/AC1/AC2. The stop rule must be complete before its commit, and the script must refuse an uncommitted
  rule.** Folded.
- **O3.** As G11. **O4. Restore CH_rear only (`KEYS=CH_rear`).** Folded.

## Assumption
- **A1. Daily parts may not be the 2026-10-24 load.** Folded: monthly through the connection, refused unless
  the load equals the grade record's; the daily build is recorded beside it, as a check only.
- **A2. NuSEDS keys unverified.** Folded: assert population x species x year is unique; pick UFRA's and COTR's
  populations by FWA code inside the group, never by name.
- **A3. `evidence_kind` classes.** Folded: an `unknown` class, and a precedence rule written in the function.
- **A4. #96's window columns.** Folded: start `START_SPAWN_DT_FROM`, end `END_SPAWN_DT_TO` else
  `END_SPAWN_DT_FROM`, month-day only.
- **A5. Daily reads over HTTPS untimed.** Folded: timed on one group first.
- **A6. A zip holding more than one file.** Folded: the fetcher refuses it.

## Scope
- **S1. task_plan.md named a client project repo.** Folded before any push: the line is rewritten and the two
  local commits rebuilt so no revision carries it.
- **S2. Phase 1 is large.** Noted; #96's migration rows split out if the literature grows.
- **S3. "no `data/`" was wrong**: only the ignored `data/fdis/` is missing. Folded.

## Acceptance
- **AC3.** Row count is the sum over groups of segments x complete windows x 2. Folded.
- **AC4.** One variant, plus a test that an unknown header is refused. Folded.
- **AC5.** 0280 reports 0 unresolved timing sources. Folded.
