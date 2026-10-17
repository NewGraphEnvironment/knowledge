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
