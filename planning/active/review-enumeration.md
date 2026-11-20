# The enumeration that ended the code-check loop for #175 (2026-11-20)

Round 2 found defects inside round 1's fix, so a quiet round could not end the loop. Rounds 3 to 5 named two mechanisms
(review-round3.md): (a) a number whose stated population differs from the one counted, and (b) a write or a remedy
guarded less strictly than the default it falls to, written from a wrong belief about what a restored build holds.
Round 4 enumerated every quantitative claim for (a) (review-round4.md, enumeration (a)); round 5 re-checked every row
for `research/discharge_resolution.md`, and no number in the prose changed after it. Every row that did not hold in
rounds 3 to 5 was a finding and was fixed. This file closes (b): every write, stop and remedy path in `0230`, `0240`
and the two data-raw checks, each exercised on this machine after round 5's fixes (commands and output: the session's
`enum_runs.txt`, summarised here), against the published build (`sites.rds` 39f751b1, `fish.rds` 8cf27351, `catch.rds`
a31fd7bb, `fdis_sites.csv` 2de46c60).

| # | path | expected | shown |
|---|---|---|---|
| 1 | `0230` with `PLACE=false` (any value but unset, TRUE, FALSE) | refuses before any work | refused (round 2's fix) |
| 2 | `0230 PLACE=FALSE`, all four outputs present and equal | writes nothing, no database | "wrote nothing; kept ..." with an unreachable `PGHOST` |
| 3 | `0230 PLACE=FALSE`, `fish.rds` or `passes.rds` of other contents present | refuses, writes nothing | refused both times; files untouched |
| 4 | `0230 PLACE=FALSE` on a restored build (no `catch.rds`, no passes) | writes those, keeps `fish.rds` | wrote catch, passes, pass_catch; all six build files byte-identical (`scripts/logs/fdis/20261119_fdis_load-place-false.log`) |
| 5 | `0230`'s stops on what precedes placement | run on both paths, before the gate | moved above the gate; both paths ran clean |
| 6 | `0230` full run | rewrites `sites.rds` (pre-existing, #246) | same outputs as the first rerun; published `sites.rds` and `reconcile.csv` put back |
| 7 | `0240` with `ONLY=bad` | refuses | refused |
| 8 | `0240 ONLY=passes` | writes the two pass CSVs and nothing else | CSVs byte-identical; `fdis_sites.csv` mtime unchanged; tracked tables unchanged |
| 9 | `0240` (either path), passes absent | pass CSVs removed, message names the remedy | removed; message shown |
| 10 | `0240` (either path), passes of other visits | pass CSVs removed, stop before any other write | stopped in `write_passes()`, CSVs gone, `git status` of `data/` clean |
| 11 | remedy for 10: remove the passes, `PLACE=FALSE 0230`, `ONLY=passes 0240` | passes and CSVs as the build's | `passes.rds` byte-identical to before, CSVs at their md5s |
| 12 | `0240` full path | every CSV and tracked table as before | byte-identical |
| 13 | downstream check, `sites.rds` of another placement | stops, names the restore | stopped (853c... against the ledger) |
| 14 | downstream check, `catch.rds` missing one site's species | stops, says remove and rebuild | stopped at 1 site |
| 15 | downstream check, `catch.rds` of equal contents and other bytes (xz) | runs, same log | ran; log unchanged but its time line |
| 16 | flow check, visits of another build | stops, names the restore | stopped |
| 17 | every run instruction in the changed docs (CLAUDE.md 59 and 309-318, scripts/README.md, R/archive.R, 0336's header, 0240's messages, the downstream check's RUN line and stop, #219's and #246's bodies) | executable as written on a restored build | each is one of rows 2, 4, 8, 11 or 14's remedy; round 5's enumeration (b) table and this run |

Nothing in the set sits above its source of truth: each write is preceded by the check that guards it, and each
remedy, run as written, restores the published build's bytes.
