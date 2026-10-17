# Findings — FDIS site visits include surveys loaded twice under different collection ids (#35)

## Issue context

**If we do it:** each FDIS survey counts once in the site-visit table, so effort, catch and detection are not double-weighted where a survey was loaded twice. **If we never do:** about 2.5 % of the visits behind #28's use curve and #33's spawner evidence are second copies. The effect on a rate is small, but it lands unevenly by agency and data set, and every downstream count carries it.

## Problem

The same survey sits in `data/fdis/derived/fdis_sites.csv` under two collection ids. Example pairs: `42511_102_1` / `65734_102_1`, `42510_101_1` / `65733_101_1`, `42509_105_1` / `65749_105_1`. Each pair matches on UTM, date, fished area, total catch and species caught.

Among the 17,606 visits 0290 keeps:
- 844 sit in 398 groups that match on that signature, which is **446 surplus visits**;
- 607 of the 844 are FDIS, 237 FDS;
- 4 of the pairs are among #33's 119 spawner-evidence visits (e.g. BBAR `46561_76_1` / `76685_76_1`: one 560 mm spent BT, 1999-09-28).

## Proposed solution

1. In `scripts/0230`, detect repeated surveys on a declared signature: UTM, date, fished length and width, pass count, and per-species counts. Keep one copy, chosen by a stated rule such as the lowest collection id. Count the drop in the 0230 ledger.
2. Check whether the 2022 Details files repeat the same fish under both ids, before deciding which copy holds the fish.
3. Rerun 0240, 0290–0293. Report how #28's weights and #33's rates move.

Found in code-check of #33 Phase 1. Relates to #18, #28, #33.


## Probe of the current build (2026-10-17, read-only)

Scripts: scratchpad `probe35.R`, `probe35b.R`, `probe35c.R` (not committed) over `data/fdis/build/*.rds`
(built 2026-09-26) and `data/fdis/2020-11-16/visits.csv`.

- Issue's signature (UTM zone/E/N, date, n_pass, per-pass fished length x width, per-species n_caught,
  catch_status): 2,725 visits in 1,298 groups, 1,427 surplus. With fishing time added: 1,242 groups,
  1,365 surplus. Group sizes 2 (most), 3, 4.
- 12 groups sit inside one collection id (1 with time in the signature): left alone.
- Every group is one data set (FDIS>FDIS, FDS>FDS); agency agrees in 96 %; the site-number part agrees
  in 94 %; every copy snaps to the same blue_line_key.
- Fish (2022 Details): of the 460 groups with measured fish, 333 are identical on every copy, 95 have fish
  on one copy only (on the lowest collection id in 1 of 95), and 32 differ otherwise (small differences,
  e.g. 63 vs 62 fish). So "lowest id" would lose measured fish. Keep rule "most fish, then habitat, then
  lowest id" loses no fish and no habitat in any group (measured with the with-time signature).
- Habitat on more than one copy: 813 groups, identical in 767 (with-time figures: 810 / 767).
- 0290's 17,606 kept visits: 810 are in a group, and 429 would be dropped (with-time signature).
- 0294's looser signature (UTM, date, area_m2, n_caught_all, species set) adds 159 groups (323 visits)
  that the declared one does not: per-pass effort split or per-species counts differ.
- Installed link is 0.50.0; 0290 needs >= 0.55.0. link repo main is 0.66.0. 0298 pins link inputs to
  62fae0bb via `git show`, so the link checkout does not move its inputs.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1: reproduction and the moving database (2026-10-17)

- link installed 0.50.0 -> 0.66.0 (pak); fresh 0.39.0 (as in 0298's 2026-10-15 log); wet 0.4.5.
- 0230 (240 s) and 0240 (8 s) on main's code reproduce sites/catch/fish.rds, reconcile.csv and
  fdis_sites.csv exactly; tracked outputs unchanged. 0250 (11 s) reproduces too.
- 0290 fails: `a held-out WSG is in fresh_default: it would be calibration`. fresh_default now holds
  241 WSGs, all 8 held-out ones included; pg_stat shows its tables written 06:25-07:20 UTC today by a
  client on the database host's Docker bridge, still running (zz_lnk_streams_chwk, 4 active
  queries). Not this session's.
- Readers of fresh_default: 0290, 0294, 0296 (builds), 0293 (steep large-spawner patch block, joins by
  id_segment), 0298 (all of it). 0291, 0292, 0297 read only derived tables; 0295 reads bcfishobs and
  discharge.

## Phase 2/4: new build (2026-10-17)

- 0230: 51,605 visits (from 53,018); 1,286 groups, 1,413 dropped (657 fish, 660 zero, 96 unknown);
  1,487 passes and 4,370 fish rows with them; fish differ in 132 groups, habitat in 112, fishing time
  in 47; 12 single-collection groups kept.
- New fdis_sites.csv == old minus the 1,413 dropped rows, column for column.
- 0250: fish matched by length 91,986 -> 91,960; sites in FDIS 2,952 and EF fish dropped 100,297 both
  unchanged; data/fiss_evidence.csv unchanged; data/fiss_fdis_overlap.csv: 2 reports move by 1-25 fish.
- 0240: CH present 1,377 -> 1,359 visits (with gradient 151 -> 138); char present 7,043 -> 6,867;
  char spawner evidence 348 -> 340.
- Filter: bt_use_visits 17,606 -> 17,165 (441 dropped), ch_mad_visits and ch_rule_visits 21,862 ->
  21,306 (556), ch_rule_walks 372,687 -> 372,645. In 3 surveys the kept copy had failed the build's
  own drops, so the survey leaves those tables, as a rebuild would.

## Final rule, rebuilt (2026-10-17, commit 11c0009)

- 0230: 51,587 visits; 1,308 groups, 1,431 dropped (623 fish, 623 zero, 185 unknown); 1,504 passes,
  3,591 fish rows and 9,597 of 990,606 counted fish with them; fish differ in 114 groups, habitat in
  115, fishing time in 33; 89 groups pair a zero with an unknown copy (the zero kept); 0 groups lose
  maturity-coded fish; 65 groups kept for differing site numbers without identical fish, 13 inside
  one collection.
- New fdis_sites.csv == old minus the 1,431 dropped, column for column.
- 0250: 91,986 -> 91,961 fish matched by length; in_fdis 100,297 and overlap sites 2,952 unchanged
  (review C4); fiss_evidence.csv and its reconcile unchanged.
- Filter: bt_use_visits 17,606 -> 17,184 (422 dropped; 3 surveys leave because the kept copy had
  failed 0290's drops); ch_mad_visits / ch_rule_visits 21,862 -> 21,325 (537); walks 372,687 -> 372,645.
