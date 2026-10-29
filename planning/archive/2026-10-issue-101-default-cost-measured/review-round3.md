# Code-check round 3 (#101, branch review)

## Checklist read

- `code-check-python.md` (7 KB): in full.
- `code-check.md` (331 KB): the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped).
  None of the 29 stand-alone, Security or Spreadsheets/PDFs headings read (none names a tool or shape this diff uses).
- `code-check-r.md` (178 KB): 7 headings read (`$` on a list partial-matches; `[[` on a named ATOMIC vector; `tolerance`
  in testthat is RELATIVE; Tests that silently do not run; testthat counts an uncaught error under `error`; `paste()`
  with a zero-length argument; A scalar helper called from `glue()` or `mutate()` recycles). About 107 not read.
- `code-check-shell.md` (125 KB): none read (the diff has no shell code).
- `code-check-spatial.md` (156 KB): none read (no spatial code in the diff).

## Mechanism

One computation (the code's projection, or one chain of arithmetic over the logs) is restated by hand in six places:
the research section, #101's body, #112's Outcome, `0330`'s header, the roxygen of `bin_minutes`, and the planning
files. Each place is a paraphrase or a re-derivation, not a copy of one source, and each was corrected on its own. So
the restatements drift in what they include, in three ways:

- **Population.** #92's structures were applied to #87's minutes (r1).
- **Operation.** "The slowest bin's difference" was written for `max - max` (r1). "Measures" was written for "projects"
  (r2).
- **Rounding.** A sum or range was built from printed, rounded parts (r2's "30").

This is `code-check.md`'s "Compression runs both ways": a restatement drops a condition that the source carries. It is
also "Written data outlives the fix": a fix to one copy leaves the others as they were. The tell in this branch is
`task_plan.md:40`. It states the projection with its condition ("with and without `default`'s steps (and the walk,
where only `default`'s predicate reads its table)"). Every later compression of that sentence drops the walk.

## Where the mechanism reaches, and the verdict on each

Recomputed from `-2` (BT), `-3` (CH), `-4` (WCT) and `20261026_compare.txt`.

**The research table.** These hold:

- the components: 1.2/19.5/9.3/9.0, 1.4/0/19.2/11.2 and 0.8/0/6.3/5.3;
- the shares: 73.8, 60.4 and 50.8 %;
- the `door` alone runs agree within 0.1, 3.2 and 2.3 points.

**The projection chain.** These hold:

- 115.2 is the eight keys' classify minutes (5.3, 27.4, 21.2, 27.1, 13.1, 7.4, 10.1, 3.6);
- #87 ran RB, BT rearing, CO, ST and WCT under `free, door`, and CH under three structures;
- after #112's drop, 89.2 min remain, so #112 dropped 26.0 (#101's "about 26");
- the three measured keys come to 26.7;
- the other five keys hold 48.7 min, so 24.8 to 29.4 at 51 to 60 %;
- the total is 51.5 to 56.1 (printed "about 52 to 56": 27 + 25 = 52 from rounded parts, inside "about");
- the full `0330` goes from 176.9 - 26.0 = 150.9 min (2.5 h) to 94.8 to 99.4 min (1.6 h).

**The near-river claims.** These hold, measured offline on link `102762da`'s configs with fresh 0.44.0, with no
database:

- only CH has near-river specs, on both models;
- only CH's rear `default` predicate reads the table;
- CH's tuned base (wetland-line rule removed with `.knw_is_wetland_line_rule()`) reads it on neither model.

So `drop_walk` is TRUE for CH rearing alone.

**`R/compare_rules.R`.** No defect.

- `.knw_bin_minutes()`: the arithmetic, the `if` inside the subtraction, and `$` reads with exact names.
- The near-river detection: the grep for `.near_river` matches `pred_of()`'s table name.
- The log line says "and the walk" and "projected".

**Test.** The expected values recompute: 5/5, 4/2 and 2/2.

The items below are the restatements that do not match the code.

## Findings

- **[bug: claim the code does not make]** The walk is left out of the projection's description in four places:
  - `research/database_builds.md:152-154`;
  - #101's body ("Measured", last sentence);
  - `scripts/0330-compare.R:70-72`;
  - `R/compare_rules.R:93-94` (and `man/knw_compare_rules.Rd:88-89`).

  Each says `0330` logs or returns each worker's minutes "with and without `default`'s own". For CH rearing, though,
  `minutes_without` also subtracts the walk: `drop_walk` is TRUE there, measured above, and `.knw_bin_minutes()`
  subtracts `x$walk_s`. CH is the key with the largest saving, and the walk is about half of its bin minutes (19.5 of
  39.0 on `-3`). The research's own table separates the walk from `default`'s own ("`default`'s share (with the
  walk)"). So a reader of these four sentences expects a projection about half the size of the one the log prints for
  CH.

  The return value also carries nothing that says whether the walk was dropped. A caller of `bin_minutes` therefore
  cannot tell which quantity `minutes_without` is. The log line and `task_plan.md:40` state the condition, and each of
  the four places should carry it too ("and, where only `default`'s predicate reads the near-river table, the walk").

  `0330`'s header has a second problem: "being what reading default's flags would save". That is the class r2 fixed in
  #101's body, a saving where the code logs "a projected … min" (no cache read, the untimed `assert_default` check and
  the stage overhead outside the bins).

- **[bug: claim the logs do not support]** #112's Outcome, last bullet: "51 to 74 % of a two-rule key's classify
  minutes". The 51 to 74 % is a share of summed worker minutes (copies, walks and rules). It is not a share of the
  classify stage's minutes, which are wall time.
  - #112's own bullet above it says "of the worker minutes".
  - #101's body says "of the classify stage's worker minutes".
  - The research says a share of worker minutes equals a share of wall time "only when the bins are balanced".

  As written, the line restates the share against the denominator the research warns against. It should read
  "worker minutes".

- **[fragile: planning record]** `planning/active/task_plan.md:41`: "the saving being the slowest bin's drop". This is
  the wording r1 corrected in the research, in `0330` and in the log line (the code takes `max(minutes) -
  max(minutes_without)`, not one bin's drop). It travels into the archive on `/planning-archive`.

- **[fragile: checkbox against landed work]** `planning/active/task_plan.md:92-96`: the Phase 3 box is `[x]` for
  "`default`'s share of the classify stage and of each key's wall time". The research gives shares of summed worker
  minutes, and it says outright that these are wall-time shares only when the bins are balanced. No wall-time share was
  landed. The Validation item "PWF checkboxes match landed work" would pass it as written.
