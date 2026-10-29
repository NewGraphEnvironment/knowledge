# Code-check round 1 (#101, branch review)

## Checklist read

- `code-check-python.md` (7 KB): in full.
- `code-check.md` (331 KB): the prose of all 14 H3s under `## Mechanisms` (table rows skipped). None of the 29
  stand-alone, Security or Spreadsheets/PDFs headings read (none names a tool or shape this diff uses).
- `code-check-r.md` (178 KB): read 6 headings (`$` on a list partial-matches; `tolerance` in testthat is RELATIVE;
  `paste()` with a zero-length argument; `vapply(..., USE.NAMES = FALSE)`; Tests that silently do not run; testthat
  counts an uncaught error under `error`). The `[[` on a named ATOMIC vector heading did not extract; its index line
  read. About 108 headings not read.
- `code-check-shell.md` (125 KB): no heading read (the diff has no shell code); all ~66 not read.
- `code-check-spatial.md` (156 KB): no heading read (no spatial code in the diff); all ~94 not read.

Checked: `.knw_bin_minutes()` arithmetic, the `if` inside the subtraction, `Filter`/renumbering and `$` reads on the
bin results (keys `flags`, `walk_s`, `setup_s`, `rule_s`, `error`: no prefix siblings); the near-river detection
against `preds_for()` (`default`, `other`, the structures; the table name `<ws>.near_river` is only put into a
predicate when `specs[[model]]` has rows, the same condition the walk runs on); link's `rules.yaml` at `102762da`
(CH's 1050/1150 rule is the only rearing rule without `near_river: false`; `rear_wetland_flow = wetland_flow` is CH's
alone in `dimensions.csv`); the test file run from a copy (`NOT_CRAN=true`, 0 failed, 0 error, 0 skipped). Every
research number recomputed from `-2`, `-3`, `-4` and `20261026_compare.txt`: the table (1.2/19.5/9.3/9.0;
1.4/0/19.2/11.2; 0.8/0/6.3/5.3), the shares (73.8, 60.4, 50.8 %), the door-alone agreement (0.1, 3.2, 2.3 points),
115.2 = the eight classify minutes, 27 min on the three measured keys (26.7), 176.9 = 162.9 + 14.0, and 2.5 h -> 1.6 h
all hold as computed. Planning files and the diff scanned with the #56 sweep's patterns.

## Findings

- **[bug: published number]** `research/database_builds.md:146-148`, and #101's body ("takes off about 30 of those
  minutes", "less what #112 dropped (about 85 classify minutes)") — the "about 85" applies #112's 47 % dropped share to
  CO and ST, but 47 % is the share for a key that drops **two** rules (`free` and `door_wetland`, under #92's picks).
  The minutes it is applied to are #87's host run (`20261026_compare.txt`), where CO and ST ran `free, door` only
  (lines 42 and 53: "under free, door"), so #112 drops one rule from them, like BT rearing (29 %) or WCT (33 %).
  Recomputed with BT's 29 % for CO and ST: CO 13.1 -> 9.3 and ST 10.1 -> 7.2 (not 6.9 and 5.4), so the remainder is
  about 89 min, not 85, and #112's drop about 26 min, not 30. The other five keys then save 25 to 29 min, not 23 to 27,
  and the total about 52 to 56. The bottom line still reads about 2.5 h -> about 1.6 h (151 - 54 = 97 min), but the
  85, the ~30 and the 23-27 as written mix #92's structures with #87's minutes. Either take the CO/ST drop share from a
  one-rule drop, or apply #92's structures to #92's minutes, and correct #101's body to match.

- **[bug: claim the code does not make]** `research/database_builds.md:152` ("the slowest worker's difference is the
  saving it projects"), `scripts/0330-compare.R:71` ("the slowest bin's difference being what reading default's flags
  would save"), and the log line at `R/compare_rules.R:276` ("the slowest would take %.1f of its %.1f") — the code
  projects `max(minutes) - max(minutes_without)`, the slowest bin now against the slowest bin after, which is the right
  wall-time saving. That is not the slowest bin's own difference whenever a different bin becomes the slowest without
  `default`, and the log line's "of its" pairs one bin's remaining minutes with another bin's total. Measured on a copy:
  bins 10 -> 4 and 9 -> 8 min give a projection of 2.0 (correct), while "the slowest bin's difference" is 6.0 and the
  line reads "the slowest would take 8.0 of its 10.0". On CH, where the walk dominates and bins are balanced by segment
  count rather than walk time, the slowest bin can change. Reword the three places to describe what is computed (the
  slowest bin's minutes, before and after).

- **[security: public discipline]** `planning/active/progress.md:27` — the resume command `cd ~/Projects/repo/knowledge
  && ...` is a home path in `planning/active/`, which CLAUDE.md says carries no home paths from 2026-10-16, and which the
  #56 sweep holds to its `local_path` class (`PARTIAL = {"planning/active/": ("project_repo", "local_path")}`, pattern
  `~/Projects|Projects/repo`). It will fail the sweep and travels into the archive on `/planning-archive`. Use a
  repo-root-relative form (`git fetch -q origin && git checkout <branch> && ...` from the repo root).

- **[fragile]** `planning/active/task_plan.md:115` — the Validation item tells the archive README to cite
  `scripts/logs/habitat/*_compare_stage_time*` as its evidence, but the script was retired and no such log exists; the
  measurement is `scripts/logs/habitat/20261028_compare_structures_check*` (and `20261026_compare.txt`). Following the
  box as written puts a dead evidence glob in the archive README. (Line 117's "Verification" paragraph likewise
  describes the retired run.)
