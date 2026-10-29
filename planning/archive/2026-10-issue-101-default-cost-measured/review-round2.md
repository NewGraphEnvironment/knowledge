# Code-check round 2 (#101, branch review)

## Checklist read

- `code-check-python.md` (7 KB): in full.
- `code-check.md` (331 KB): the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped).
  None of the stand-alone, Security or Spreadsheets/PDFs headings read (none names a tool or shape this diff uses).
- `code-check-r.md` (178 KB): 6 headings read (`$` on a list partial-matches; `tolerance` in testthat is RELATIVE;
  `paste()` with a zero-length argument; `[[` on a named ATOMIC vector; Tests that silently do not run; testthat counts
  an uncaught error under `error`). About 108 not read.
- `code-check-shell.md` (125 KB): none read (the diff has no shell code).
- `code-check-spatial.md` (156 KB): none read (no spatial code in the diff).

## What was checked

- `.knw_bin_minutes()`: the arithmetic, the `if` inside the subtraction, the `Filter()` on `rule_s`, and `$` reads on
  the bin results (keys `flags`, `walk_s`, `setup_s`, `rule_s`, `error`; no prefix siblings). The test file run from a
  `git archive` copy with `NOT_CRAN=true`: 46 pass, 0 failed, 0 error. Mutation table on the copy: always dropping the
  walk (1 failed), never dropping `default` (2 failed), no `Filter()` (1 error). Each guard has a red arm.
- The near-river detection in `knw_compare_rules()`: `jobs[[1]]$preds` holds `default`, `other` and the structures for
  both models. `other` reading the table puts `other` in `near_rules`, which keeps the walk (correct, because every
  rule's table reads `pr$other`). Neither `fresh:::.frs_run_connectivity` nor `fresh::frs_habitat_overlay` (0.44.0)
  mentions `near`, so dropping the walk spares nothing another step needs.
- Every research and #101 number recomputed from `-2` (BT), `-3` (CH), `-4` (WCT) and `20261026_compare.txt`:
  - the table: 1.2/19.5/9.3/9.0, 1.4/0/19.2/11.2 and 0.8/0/6.3/5.3;
  - the shares: 73.8, 60.4 and 50.8 %;
  - `door` alone within 4 points: 0.1, 3.2 and 2.3;
  - 115.2 = the eight keys' classify minutes;
  - #87's CO and ST under `free, door` (log lines 42 and 53);
  - the remainder after #112's drop: 89.1 min, so #112 dropped 26.1;
  - the three measured keys: 26.7;
  - the full `0330`: 176.9 - 26.1 = 150.8 min (2.51 h), and 94.7 to 99.4 min (1.58 to 1.66 h) after the saving;
  - #112's Outcome line, 51 to 74 %;
  - GR's tracked pick `width>=2|g<=0.0549` against `default`'s `width>=1.5|g<=0.0349`.
  All hold except the range below.
- Round 1's fixes:
  - no remaining "85", "about 30 of", "23 to 27" or "slowest bin's difference" / "of its" wording in the tree outside
    `review-round1.md`, or in #101's or #112's body;
  - `progress.md`'s resume command is repo-relative;
  - the Validation glob names `20261028_compare_structures_check*`.
- The #56 sweep (`tree`): the only hits in this branch's files are `review-round1.md:50,53` (accepted). The other hits
  are older files (`test-tune_score.R`'s `m1`, the PNG bytes).

## Findings

- **[bug: published number]** `research/database_builds.md:148`, and #101's body ("25 to 30 on five keys that borrow
  BT's and WCT's shares"): the five unmeasured keys' remainder is 48.7 min (RB 3.74, BT spawning 21.2, CO 9.25, GR 7.4,
  ST 7.13). At 51 to 60 % that is 24.7 to 29.4 min, or 24.9 to 29.3 with the rounded shares. So the range is "25 to 29",
  which is what round 1 prescribed. Its fix wrote "30", and that top end is not supported. The total, "about 52 to 56"
  (51.4 to 56.1), and the 1.6 h still hold, so only the range's top end is wrong, in both places.

- **[bug: claim the code does not make]** #101's body, "Measured" section, last sentence: "`0330` now logs ... the
  slowest worker's minutes less the slowest without them, so the next run measures the saving directly." The code does
  not measure a saving. It subtracts `default`'s timed seconds (and the walk) from each bin and logs the result as "a
  projected %.1f min off a rerun that reads default's flags". That figure leaves out reading a cache and the untimed
  `assert_default` check, and it holds the other rules' times fixed. The research file says "projects", which is right.
  Only a run that reads a cache would measure the saving. Something like "so the next run projects the saving from its
  own per-worker times rather than borrowed shares" would match the code.

No defects in `R/compare_rules.R`, the test or `scripts/0330-compare.R`.
