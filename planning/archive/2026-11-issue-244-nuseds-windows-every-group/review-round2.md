# Code-check round 2: branch 244-backlog-move-16-nuseds-spawning-windows (base origin/main 088cd31b, head 246e0d51)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped); none of
  the stand-alone rules read.
- code-check-r.md (by heading, 13 read, the rest not): "`ifelse()` with an all-NA test returns a logical vector,
  whatever `yes` and `no` are"; "`$` on a list partial-matches, so a longer sibling key answers for a missing one";
  "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent"; "`data.frame()`
  recycles a scalar against a zero-length column"; "A `data-raw/` script must load the source tree, not the
  installed package"; "Postgres row order is never fixed unless the query fixes it, ..."; "A URL handed to a reader
  goes through R's 60 s connection timeout"; "`download.file(quiet = TRUE)` never tells you the HTTP status — read
  it from `curl`"; "`match()` treats NA as a matchable VALUE, so two unknowns join to each other"; "`paste()` with
  a zero-length argument returns length ONE, not zero"; "Rscript reads a script as it runs, so never edit a script
  while a run of it is in flight"; "Read-back shape must match write-back shape"; plus the index line for
  "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`".
- code-check-shell.md: index only. No heading names a shape the diff's shell lines use beyond what the
  Mechanisms prose covers (tee, pipefail and exit status are in code-check.md "A wrapper's exit is not the work").
- code-check-spatial.md: index only. No heading applies (the one SQL lookup is an exact match on
  `fwa_watershed_code`; no geometry is read).

## Probes run (copies of the script in the scratchpad, outputs only there)

- A full run of the HEAD script reproduces the tracked `scripts/logs/timing/20261121_timing_nuseds_windows.csv`
  byte for byte (`cmp`), and the tracked `.txt` differs only in the OUT path printed.
- The zero-length paths round 1 fixed, on the HEAD script: `WSG=ADMS SPECIES=CH` writes OUT, prints "the timing
  table has no row ..." and exits 0 (round 1 crashed in `pmax()` here); `WSG=ZZZZ` stops with "no dated records
  for the groups and species asked"; `WSG=UFRA SPECIES=CO` passes the reach guard (round 1 stopped here, "gfe_id
  2477 is in no record") and exits 0; `WSG=adms,ufra SPECIES=ch` (lower case) runs the UFRA check, compares two
  rows and prints an empty "rows not compared" table without error.
- gfe_id: 0 NA in the Parquet; all 2,514 distinct values survive `as.character(as.numeric(x))`, so the
  character-vs-numeric match in the reach guard can't miss on scientific notation.
- No other step sits between the old and new position of the species filter that depends on it: the reach guard
  and the three printed counts (lines 90-91, 126-127) are the only things that now see every species. Nothing
  downstream reads those counts.

## Findings

- **[severity: fragile]** data-raw/timing_nuseds.R:42-46 (the RUN lines; scripts/README.md and
  scripts/logs/timing/README.md describe the same use) — The documented run tees into the day's tracked log and
  points `OUT=` at the day's tracked CSV, and the filter forms (`WSG=BULK,MORR SPECIES=CH ...`) are prefixes to
  that same command. So a filtered run, or a run that stops at a `check()`, a sha256 refusal or the reach guard,
  overwrites the committed full-run `20261121_timing_nuseds.txt` with its partial output: tee truncates the file at
  launch. A filtered run also overwrites `_windows.csv` with a subset, because OUT is written even when the checks
  were skipped. With no `pipefail`, the pipeline exits 0 when Rscript stops. In this same diff, 0340's RUN line got
  the remedy for this exact hazard: tee to `$TMPDIR` with `set -o pipefail`, then `cp` into `scripts/logs/` only
  after a run that succeeded. Its sibling here kept the old shape. Both files are tracked, so git can restore
  them, but a careless `git add` of the day's logs would commit a subset in place of the full run.
  Not a defect inside round 1's fixes (the RUN line predates them; fix 3 only moved where OUT is written).
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "A guard that
    fails toward pass" ; code-check.md "A wrapper's exit is not the work"

- **[severity: fragile]** data-raw/timing_nuseds.R:156-163 (`summ()`), with lines 23-24 of the header — The
  header says a window is taken "over its population-years with dates", and the columns are named `years_start`,
  `years_end` and `years_arrival`. But `summ()` counts and takes quantiles over records, and a population can have
  several records in one year, one per stream (`gfe_id`). CLAUDE.md says so: "a population, stream (`gfe_id`) and
  year is unique, and a population, species and year is not." Measured on the published v1 set after the script's
  own filters: 16 dated records in 2 populations share a population-year. LNTH coho population 46602 (Barriere River
  and Fennell/Saskum Creeks) has 33 start records over 27 distinct years. Its population row prints
  `years_start = 33`, those 6 extra records count in LNTH CO's group `years_start` (182) and its quantiles, and the
  shared years are 2008, 2010-2014. LFRA chum population 47925's duplicates are records without a start date
  (41 start records over 41 years), so they reach its `years_end` and end quantiles. None of the timing table's
  compared rows (BULK, MORR, UFRA, COTR) is affected, and the UFRA, COTR and BULK checks hold. The written CSV still
  carries a `years_*` count that disagrees with its name for these two populations and their groups.
  Not a defect inside round 1's fixes.
  - **Rule:** code-check.md "One fact derived twice"

## Round 1's fixes, checked

- (1) `WSG`: read at line 55, documented at 44-45 and in scripts/README.md; no other `GROUPS` reference remains
  in the script or the docs the diff touches. Validated only by the zero-keys stop, which fires on a typo (probe).
- (2) Species filter after the reach guard: correct. The reach guard now sees every species, the windows and keys
  are built only after the filter, and the windows are per species, so nothing crosses between species. Side
  effect, not a finding: under `SPECIES=` the three counts printed before the filter now count every species.
- (3) OUT before the comparison, zero-row timing table, zero keys: each path probed (above). `cmp` can't be empty
  once `nrow(tt) > 0`. `win` can't be empty once `nrow(keys) > 0`, because every key comes from a dated record
  that yields a group or an apart row. The empty `done` frame and the empty `table()` print cleanly.
