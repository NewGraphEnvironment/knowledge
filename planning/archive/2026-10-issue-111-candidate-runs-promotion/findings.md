# Findings — Iterate on scores privately; promote a run (#111)

## Issue context

## Problem

Every retune rewrites the tracked tables (`data/tune/*.csv`, `data/compare/*.csv`, `data/thresholds.csv`), and
`tests/testthat/test-vignette-data.R` then fails until both articles' bundles are rebuilt and the prose that quotes them
is checked again. #92's chain was about 10 h of runs (scoring 43 min, grading about 87, comparison 269, GeoPackages 197)
and then five review rounds on the article prose, though the scoring alone answered which rule wins.

Retunes are now continuous: link's segmentation (`NewGraphEnvironment/link#326`, `NewGraphEnvironment/link#396`),
placement and flow changes are queued. So every iteration pays the cost of publishing, and the published state follows
whichever run happened last: #92's run was made on link 0.66.0's segments, which both link changes replace.

## Proposed

1. **A pick report in `DEV=1 0320`.** Per key: the pick against the published one (`data/tune/<key>_tune.csv`), its
   gradient limit, whether the published pick is still in the one-SE region, and how far the score moved. In the log and
   as a CSV under `data/tune/dev/`. This is what runs after a change upstream, on `0310`'s tables for the new build.
2. **Full runs write to an ignored candidate directory.** `0320` without `DEV` writes `data/tune/candidate/<run>/`
   (scores, grades, curves, seeds); `0330` takes `TUNE_DIR=` to compare a candidate, into
   `data/compare/candidate/<run>/`. Nothing tracked changes.
3. **A promote step, on the operator's word.** It copies one candidate run into the tracked `data/tune/` and
   `data/compare/`, then runs `0325`, `data-raw/vignette_chinook.R` and `data-raw/vignette_method.R` (method last). The
   articles and their review follow a promotion, and nothing else.
4. **`CLAUDE.md`.** The bundle scripts rerun after a promotion, not after any `0320`/`0325`/`0330` rerun. A full retune
   and a promotion each start on the operator's word, not on an agent's judgement that a change upstream calls for one
   (Al, 2026-10-28: "We have several updates to make so we will be retuning continuously. We need to dial it so I help
   decide when we are retuning").

## Where it runs

Scoring (`DEV=1 0320`) is CPU-bound and runs on any machine; `0310`'s visit walks, the grade and `0330` are database-bound and run on the database's host (#110). Scoring reads `data/fdis/derived/` (ignored), so the machine that scores needs the tables `0310` wrote for the build being checked, copied from the host when `0310` ran there. Check them against the run's `evidence_md5` (`data/tune/<key>_summary.csv`: the md5s of `visits_link.csv`, `visits_species.csv` and `walks.csv`) before scoring. On 2026-10-28 the scoring machine for this issue already held #92's tables, md5s matching.

## Acceptance

- `DEV=1 0320` writes the pick report and leaves the tracked tree unchanged (`git status` clean).
- A full `0320` and `0330` leave the tracked tree unchanged.
- A promotion moves exactly the tracked tables and bundles, and `devtools::test()` is green after it.
- `0325`, `0330` and `knw_thresholds_table()` still read only the tracked directories, non-recursively (as they do with
  `grad_ext/` and `grad_fwa/`), so a candidate is never published by accident.

Related: #92 (PR #109), #84 (smoke gates first), #81 (GeoPackages opt-in).

## Exploration (2026-10-28)

- `0320` writes every output to `dir_out` (`data/tune`, or `data/tune/dev` under `DEV=1`) and its log to
  `scripts/logs/habitat/` (tracked), so even `DEV=1` leaves a new file in a tracked directory today.
- `0320` reads the previous pick from tracked `data/tune/*_tune.csv` whatever `dir_out` is (`previous`), which is the
  published side a pick report needs.
- `0330` reads `data/tune/*_curve.rds` and `*_grades.csv`, writes `data/compare/` and, under `STAGE=maps`,
  `research/fig/` (tracked); its combined `compare/change/checks.csv` are composed from the per-key tables on disk.
- Readers of the tune log: `data-raw/vignette_chinook.R` takes the newest `_tune_run.*\.txt` in `scripts/logs/habitat`
  that graded its key and pins its md5; `0325` lists every tune log in its provenance. So a promotion must copy the
  candidate's log there.
- `0325`, `data-raw/vignette_method.R` read the newest evidence ledger; `vignette_chinook.R` the one the tune log names.
- `knw_thresholds_table()` lists `tune_dir` non-recursively (`R/thresholds_table.R`).
- Local evidence md5s equal #92's `evidence_md5` (`1bd35829…;009698d7…;99f499bb…`), so `DEV=1 0320` runs here.
- Timing: `DEV=1` CH alone 1.7 min on 8 workers (20261027_tune_run-ch-dev.txt); #92's full scoring 42.6 min, whole
  0320 130.3 min, 0330 466.1 min with GeoPackages (CH rearing compare 44.1 min).

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `cp: invalid option -- 'c'` cloning the round-trip candidate | GNU coreutils is first on PATH here; `/bin/cp -c` clones |
| Undo test: an undo in the same second as its promotion archived into the archive it was restoring from | Archive name made unique (`_2`, `_3`) |

## Code-check: the mechanism behind rounds 1-2 (2026-10-28)

Both rounds' inside-a-fix defects stood a proxy in for a property: "fitted" read from `rule_recommended` being present
(caught `curve_failed`), and "latest" read from a file name's sort (a same-day `-ch` pass tied with the all-species one;
a legacy fallback took a candidate's log). Every choice of the kind in the changed code, after round 2:

| where | chooses | by | verdict |
|---|---|---|---|
| `knw_tune_promote()` per-key loop | which keys must carry grades and a comparison | `status` against `knw_tune_run()`'s seven statuses | fixed: no-fit-by-design passes, fitted/underpowered need a rule, the rest refused |
| `knw_tune_promote()` `fitted` | whose compare-side files and rows may be removed | `status` not in the no-fit set | fixed |
| `0325` `fitted_keys` | which keys publish values | `status %in% c("fitted", "underpowered")` | unchanged, now the same split |
| `data-raw/vignette_chinook.R` log | the log of the run that graded CH | the summary's `tune_run`, then the pass number 0320 writes | fixed: passes numbered across a run (`-p<n>`) |
| same, legacy fallback | the log for tables from before `tune_run` | newest name, candidate logs excluded | fixed |
| `knw_run_ledger()` fallback | the ledger for tables from before `evidence_ledger` | newest name | as before the branch (only today's tables reach it) |
| `0320` `ledger_path` | the build a new run scores | newest name | intended: a run is made on the newest build |

### After round 3

Round 3 narrowed the mechanism: presence (or sort order) taken as provenance. It reached a place the table above did
not list, the candidate directory itself: a resumed run keeps what a later pass stopped writing. Rows added:

| where | chooses | by | verdict |
|---|---|---|---|
| `knw_tune_promote()` `take_tune` | an unfitted key's files from the run | the three files 0320 writes for one (summary, curve record, smoke) | fixed: the rest stays in the run, noted |
| `take_cmp` | an unfitted key's comparison files | none taken | fixed |
| `take_drawn` | a fitted key's GeoPackage and figures | drawn at or after the key's `_segments.rds` | fixed: older ones stay, noted |
| combined `floodplain.csv` | the run's floodplain rows | drawn after every promoted key's last comparison | fixed |
| grading-log check | that a fitted key's grades have a pass that says it made them | a `<key> grades:` line in the run's logs (an archive: the tracked logs) | added |
| `0320` pass name | which pass graded last | UTC start time `p<YYYYMMDDHHMMSS>`, across hosts and days | fixed (round 2's per-directory count collided across hosts) |
| `0335` evidence check | that the rebuilds can run | the derived tables present when they will | fixed: refused up front |

### After round 4: provenance by construction, not by inference

Round 4 found round 3's fixes had swapped one stand-in for others (file age, "some log graded it", a derived table read
as its own source). The fix moved provenance to the writers: a pass clears what it will rewrite, so presence in a
candidate means "written by the key's last pass". Every file a pass writes per key, after round 4:

| writer | file | cleared before the pass writes | if the pass dies first | promotion's check |
|---|---|---|---|---|
| 0320 | `_smoke`, `_tune`, `_curves`, `_groups`, `_seeds`, `_honest`, `_summary`, `_curve.rds` | at pass start, for the pass's species | key has no summary: not promotable | - |
| 0320 | `_score.rds` | kept (cache keyed on population, grid, evidence, settings; not code, as before) | - | - |
| 0320 | `_grades.csv` | kept only through the keep-check's ten fields; removed after scoring for a key with no curve | old grades beside a new summary | every keep-check field the summary carries (rule, run, evidence, gradient, withheld, prior, null deviance); walk and flow load across the set and live |
| 0330 | `_compare`, `_change`, `_checks`, `_segments.rds`, `gpkg/<key>.gpkg`, `fig/compare_<key>_*` | at the key's job start | key has no comparison: refused | rule, comparison after grades (inside a candidate; an archive exempt) |
| 0330 | GeoPackage written part way | removed on its error | - | - |
| 0330 | `compare/change/checks.csv` | at full-pass start, written at its end | absent: refused | rows by key, a fitted key left out refused, an unfitted key's dropped |
| 0330 | `floodplain.csv`, figures (STAGE=maps) | at full-pass start; a key's figures before its drawing | absent: tracked rows kept for fitted keys (noted), dropped for unfitted | as above |
| 0320 / 0330 | logs | never written over (UTC-start pass name, numbered) | 0320's log rewritten after each graded key | a fitted key needs a grade line in the run's logs (an archive: the tracked ones) |

Remaining uses of file age: the comparison-after-grades check, inside a candidate only, where 0320 and 0330 are the only
writers. A dry run of a promotion of a clone of the published run passes every check (2026-10-28 19:27 UTC).

### After round 5: every write into a run directory

Round 5 found the drawings (STAGE=maps, the GeoPackages) and a kill mid-write outside round 4's table. The rule now
covers every write in `0320`, `0330` and the functions they call (`grep` of write_csv / saveRDS / writeLines / st_write /
file.rename / saveWidget, 2026-10-28):

| writer | file | how it lands | a pass killed first leaves | promotion |
|---|---|---|---|---|
| 0320 | `_smoke.csv` | cleared before the smoke run | old one gone; nothing else touched | taken with a fitted key |
| 0320 | `_tune`, `_curves`, `_groups`, `_seeds`, `_honest`, `_summary`, `_curve.rds` | cleared after the smoke gate passes | a key with no summary, or one missing a file | refused unless the full set is there (fitted) or only summary + curve record (unfitted) |
| 0320 | `_score.rds` | cache (`R/tune_run.R`), as before | - | moved with the key |
| 0320 | `_grades.csv` | keep-check (eleven fields) or written whole (`.knw_write_whole()`); removed for a key with no curve | old grades of another fit | refused unless every keep-check field the summary carries agrees |
| 0320 | `pick_report.csv`, logs | overwritten / never written over, log after each graded key | - | logs copied; a fitted key needs a grade line |
| 0330 | `_segments.rds`, `_checks`, `_change`, `_compare` | cleared at the key's job start, each written whole, `_compare` last | no `_compare.csv`: refused | rule; written after the grades (inside a candidate) |
| 0330 | `gpkg/<key>.gpkg` | `<key>.part.gpkg`, renamed when every group is in | the last complete one, or none | taken whole |
| 0330 | `fig/compare_<key>_*.png` | drawn into `fig/.part_<key>/`, moved in when the key is drawn | the last complete set | taken whole |
| 0330 | `compare/change/checks.csv` | cleared at full-pass start, written whole at its end, `compare.csv` last | absent: refused | rows by key |
| 0330 | `floodplain.csv` | rows of the keys a pass compares or draws replaced (`floodplain_write()`), written whole | other keys' rows intact | a fitted key the run did not draw keeps its tracked rows, noted; an unfitted key's dropped |
| 0330 | `maps/*.html`, logs | not promoted / numbered | - | - |

File age is read only inside a candidate: the comparison-after-grades check here, and 0330's own STAGE=maps and
STAGE=gpkg checks that the segments postdate the grades. A dry run of a promotion of a clone of the published run passes
every check (19:39 UTC).
