# Timing table run logs

Console output of intentional runs of `scripts/0260` (seed `data/life_history_timing.csv` from the
reporting template's Gantt CSV). Each records the template commit it read, the rows it merged,
dropped or re-cited, and the invariants it passed. Retained as the record of which input produced
the table, not accumulated by accident.

Filename: `yyyymmdd_timing_seed.log`. Several runs on one day take a sequence segment after the date.

`data-raw/timing_nuseds.R`'s runs (#96, #240) are here too: `yyyymmdd_timing_nuseds.txt`, its console output (NuSEDS
windows per group, species and population, and the timing table beside them), and from 2026-11-21
`yyyymmdd_timing_nuseds_windows.csv`, the same windows as a table, one row per group x species x scope.

Naming: `yyyymmdd_noun_verb-detail_target.ext` from 2026-09-28, the directory's first day.
