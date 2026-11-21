# Progress — Backlog move 16 (#244)

## Session 2026-11-20

- Plan-mode exploration — phases approved by user (gate: mainstems reported apart plus a named-reach table; no
  NuSEDS-only rows; 0340's log written outside the repo and copied in)
- Created branch `244-backlog-move-16-nuseds-spawning-windows` off origin/main; claimed #244 in-flight
- Scaffolded PWF baseline from issue #244 with approved phases
- Next: start Phase 1
- Phase 1 (#230): 0340's RUN line tees to `$TMPDIR` inside a `pipefail` subshell and copies the log in only after a
  run that succeeded; checked with a stub Rscript (status 1: nothing copied; status 0: copied; pipefail does not leak)
- Plan review (background Plan agent) landed after Phase 1: it read an older tree, so its PUBLISH-placement, pipefail
  and README findings were already handled; taken in: reach table keyed by `gfe_id` (the Fraser's one code runs
  through every Fraser group), BULK's both counts pinned (28/27), a "migration row has no end" outcome, a named reach
  not listed apart elsewhere, Phase 1's verification restated. Parquet date strings parse as DD-MON-YY with NA for blanks
  (the run's `doy()` refused nothing)
- Phases 2-3: `data-raw/timing_nuseds.R` rewritten; run from a copy on m1 (00:50-00:51 UTC, 33 s): 480 group x species
  keys in 126 groups, 6,112 window rows; UFRA, COTR and BULK chinook checks reproduce. Season year from 04-01 (09-01
  for ST), since ~3,000 coho and chum spawning ends fall in January-March
- Phase 4: committed run `scripts/logs/timing/20261121_timing_nuseds.{txt,_windows.csv}` (UTC date; from a copy of the
  committed script at 749f8cfd); scripts/README.md timing note and the timing logs README updated. The backlog ticks
  moved to "Owed at the end": `/gh-pr-merge` writes them with the PR URL
- `/code-check branch` round 1 (3 findings, all real, each reproduced): `GROUPS=` never reaches R under bash (renamed
  `WSG`, as `segment_window_flow.R` did in #174); `SPECIES=` filtered before the reach guard, so `SPECIES=CO` stopped on
  gfe_id 2477 (filter moved after the guard); a filtered run with no table rows crashed before writing `OUT` (OUT now
  written after the checks and before the comparison, which stops cleanly on no rows; no keys refuses). Verified:
  `WSG=ADMS SPECIES=CH` and `SPECIES=CO` exit 0 and write; the full run's windows CSV is byte-identical to d015364c's
- Round 2 (2 fragile findings, none inside round 1's fixes, which it verified on every zero-length path): the script's
  RUN line still tee'd into the day's tracked log (now the 0340 shape: `$TMPDIR`, pipefail, copy in after a full run
  that succeeded); `years_*` counted records, not population-years (16 dated records of two populations share one), so
  the columns are `n_start`, `n_end`, `n_arrival` and the header says what a record is
