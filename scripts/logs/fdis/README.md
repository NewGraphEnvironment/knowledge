# FDIS track run logs

Console output of intentional, dated runs of `scripts/0230` (load, QA, network placement) and
`scripts/0240` (size classes, evidence table) over the FDIS electrofishing export. They are
retained as contemporaneous evidence of measurement runs, above all the reconcile table each run
passed. They are not accumulated by accident.

Filename: `yyyymmdd_fdis_<step>.log`, where `<step>` is `load` (0230) or `evidence` (0240).
Several runs on one day take a sequence segment after the date; a run with a setting carries it as a
detail (`load-snap500`, `load-place-false` for `PLACE=FALSE`, which builds only what precedes placement).
The `.txt` logs beside them are the `data-raw/` checks on the built tables (`snap_*`,
`fdis_downstream_end_check`).

Naming: `yyyymmdd_noun_verb-detail_target.ext` from 2026-09-26, the directory's first day.
