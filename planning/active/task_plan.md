# Task: FDIS site visits include surveys loaded twice under different collection ids (#35)

## Problem

The same survey sits in `data/fdis/derived/fdis_sites.csv` under two collection ids. Example pairs: `42511_102_1` / `65734_102_1`, `42510_101_1` / `65733_101_1`, `42509_105_1` / `65749_105_1`. Each pair matches on UTM, date, fished area, total catch and species caught.

Among the 17,606 visits 0290 keeps:
- 844 sit in 398 groups that match on that signature, which is **446 surplus visits**;
- 607 of the 844 are FDIS, 237 FDS;
- 4 of the pairs are among #33's 119 spawner-evidence visits (e.g. BBAR `46561_76_1` / `76685_76_1`: one 560 mm spent BT, 1999-09-28).

## Context (plan)

Some FDIS surveys sit in the site-visit table under two to four collection ids. Every visit count
downstream (#28's BT use curve and weights, #33's spawner rates, #52/#54's CH stream-size and rearing rule)
counts them more than once. 0293 and 0294 each detect duplicates with their own loose signature, and
0295, 0297 and 0298 filter on 0294's `dup_of`. That is one fact derived three ways. This fixes it once,
in 0230, and reruns the chain.

**Probe of the current build (2026-10-17, read-only, `data/fdis/build/*.rds`):**
- Issue's signature (UTM zone/E/N, date, pass count, per-pass fished length and width, per-species
  catch, catch status): 2,725 visits in 1,298 groups, so **1,427 surplus**. 1,245 are fish visits, 1,305
  zero-catch, 175 unknown. Group sizes: 2 to 4. Every group is a single data set, and every copy snaps to
  the same blue line key.
- **12 groups sit inside one collection id** (different site numbers). They are probably separate sites,
  so they are left alone.
- **Fish:** 460 groups have measured fish. 333 have identical fish on every copy; 32 differ slightly. In
  95, only one copy has fish, and in 94 of those it is the **higher** id. A "lowest id" rule would drop
  those fish. "Most measured fish, then habitat, then lowest collection id" loses no fish and no habitat
  in any group. Habitat is on more than one copy in 813 groups (it differs in 43).
- 0294's looser signature (UTM, date, summed area, total catch, species set) catches 159 more groups that
  the declared signature does not, because their per-pass effort or per-species counts differ.

**Decisions (user, plan gate):** drop the surplus copies in 0230 and keep a map; use the issue's
signature without fishing time; rerun the full chain, CH included, in this PR.

## Phase 1: Baseline reproduction (drift check before any code change)
- [x] Install link >= 0.55.0 (installed: 0.50.0; 0290 needs `lnk_species_pooling()`). Record the link,
      fresh and wet versions and the database schemas used.
- [x] Copy the current `data/fdis/derived/*.csv` and `data/fdis/build/*` to the scratchpad. Rerun
      0230, 0240, 0290, 0294 and 0296 on main's code. Compare md5 and row counts with the copies and
      the committed tracked outputs (`data/fdis_evidence.csv`, `data/fdis_summary_ch_bt.csv`, ledgers).
- [x] If they reproduce: the later dedup diff is the dedup alone. If they do not: rerun 0291–0293, 0295,
      0297 and 0298 too, and commit the reproduction as its own commit ("rerun at current inputs"), so
      the dedup commit's diff carries nothing else. Record what drifted in findings.

## Phase 2: Repeated surveys in 0230
- [x] Signature on each visit: UTM zone/E/N, date, `n_pass`, per-pass fished length and width (in pass
      order, as recorded), per-species `n_caught` and `catch_status`. A group is a repeat only when it
      has 2 or more members and every member has its own collection id. Groups that fail that test are
      counted and left alone.
- [x] Keep rule: most measured fish, then has habitat, then lowest numeric collection id, then
      `site_visit`. Drop the other copies from `sites`, `catch` and `fish`, before placement.
- [x] Write `data/fdis_repeat_surveys.csv` (tracked): dropped `site_visit`, kept `site_visit`, catch
      status, fish dropped, whether fish, habitat and fishing time are identical to the kept copy.
- [x] Ledger rows in `reconcile.csv`: groups, visits dropped (by catch status), fish rows dropped, groups
      whose copies differ in fishing time, fish or habitat, and single-collection groups left alone.
      Reconcile guards rewritten so passes and fish partition into kept plus dropped. Header WHY note.
- [x] Probe 0250's FDIS overlap: no FISS fish matched only a dropped copy. Rerun 0250 if its per-group
      inputs are cached; otherwise record the probe.

## Phase 3: One definition downstream
- [x] 0293: remove the `first_copy` signature and the `first_copy_only_35` sensitivity. Header points to 0230.
- [x] 0294: remove the `dup_of` block and column. Log how many visits its old signature would still have
      flagged. 0295: remove `v_dup` and `sens_duplicates_kept`. 0296, 0297, 0298: drop the `dup_of`
      column types and filters.
- [x] 0299: `s3_id` becomes `knowledge/fdis/v2` (rows and columns change; v1 stays as published).
      Update the table descriptions to drop the "not deduplicated" sentence. Update `CLAUDE.md`'s FDIS
      note and data-root list, and `scripts/README.md` if its wording names duplicates.

## Plan correction (2026-10-17, user-approved): fresh_default moved underneath

A provincial link run was rewriting `fresh_default` during Phase 1 (55 -> 241 WSGs, all 8 of
link#284's held-out WSGs in it), so 0290 stops ("a held-out WSG is in fresh_default") and 0294, 0296
and 0298 would read a different network. 0230, 0240 and 0250 reproduced byte for byte. 0290, 0294
and 0296 give each visit its own row, and the new `fdis_sites.csv` is exactly the old one minus the
1,413 dropped copies, so the copies are removed from the existing visit tables
(`planning/active/fdis_repeat_filter.py`) instead of rebuilding them. 0293's steep-patch block
(reads fresh_default by id_segment) is carried from its 2026-10-02 log; 0298 reruns only if 0297's
pick changes. Rebuilding on the new fresh_default is a follow-up issue.

- [x] Filter bt_use_visits, ch_mad_visits, ch_rule_visits (dup_of removed) and ch_rule_walks; only mapped copies leave
- [ ] File the follow-up issue for rebuilding 0290, 0294, 0296 and 0298 on the provincial fresh_default

## Phase 4: Rerun the chain (commit first; run frozen copies of the scripts in the background)
- [ ] 0230 → 0240 → 0290 → 0291 → 0292 → 0293; 0294 → 0295; 0296 → 0297 → 0298. Logs land in
      `scripts/logs/habitat/` under today's date. Measure each runtime with `date -u`.
- [ ] Commit tracked outputs: `data/fdis_evidence.csv`, `fdis_summary_ch_bt.csv`, `bt_rear_use_curve.csv`,
      `habitat_weight_bt_rear.csv`, `bt_spawn_evidence.csv`, `ch_mad_use.csv`, `ch_rule_*.csv`, figures and logs.

## Phase 5: Report the moves
- [ ] Before/after tables: #28 weights per gradient class, #33 rates and ratios, CH detection by MAD class,
      the tuned rule's pick and score, and 0298's km change.
- [ ] `research/fdis_export.md`: a "Repeated surveys" section with the probe figures, the rule and the fish
      check. Refresh its counts table. Revise every number that moved in `research/habitat_weights.md`,
      `bt_spawning.md`, `chinook_stream_size.md` and `chinook_rearing_tuned.md` (grep each for the old
      values, row by row), and update their Verified lines.
- [ ] Edit #35's body with the outcome (figures, rule, link to research).

## Phase 6: Publish v2
- [ ] `0299` dry run, then `PUBLISH=TRUE` from a clean tree to `s3://fresh-bc/knowledge/fdis/v2/`. Check
      manifest row counts against the CSVs. If auto mode refuses the upload, hand over the bare command.
- [ ] `research/fdis_export.md` "Where it lives" names v2, and says v1 predates the dedup.

## Validation
- [ ] `devtools::test()` passes (`test-data-dir.R` still holds with the new data-root csv)
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive`, then `/gh-pr-push`

## Critical files
`scripts/0230-fdis-load.R`, `0293`, `0294`, `0295`, `0296`, `0297`, `0298`, `0299`, `CLAUDE.md`,
`research/fdis_export.md`, `habitat_weights.md`, `bt_spawning.md`, `chinook_stream_size.md`,
`chinook_rearing_tuned.md`; new `data/fdis_repeat_surveys.csv`.

## Verification
Reconcile guards in 0230 (passes and fish partition into kept plus dropped; `fdis_repeat_surveys.csv`
rows = visits dropped). `anyDuplicated` of the signature among kept visits is 0. 0290's ledger
`visits_in` falls by exactly the dropped count. Phase 1's reproduction makes every before/after move
attributable to the dedup alone.
