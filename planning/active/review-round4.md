# Code-check round 4: branch 111 (b1df1fa...85daf7d)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows skipped (scratchpad extract `mech.txt`). No
  other heading read (about 25 not read).
- code-check-r.md: Read-back shape must match write-back shape; `sort()`/`order()` collate by `LC_COLLATE`; `$` on a list
  partial-matches; `nzchar(NA)` is TRUE; `fs::file_move()` onto an existing directory; CSV whitespace; `identical()` on
  two reader results; `ifelse()` with an all-NA test; `[[` on a named atomic vector; `system2(stdout = TRUE)` warns;
  Rscript reads a script as it runs; a `data-raw/` script must load the source tree; `paste()` with a zero-length
  argument; `match()` treats NA (extract `rsel.txt`). 14 read, about 106 not read.
- code-check-shell.md, code-check-spatial.md: none read (no shell code in the diff; 0330's spatial code is unchanged
  apart from its paths). 0 read.

How I checked: I read the current R/tune_promote.R, R/run_ledger.R, scripts/0320, 0330, 0325, 0335,
data-raw/vignette_chinook.R and R/tune_run.R (statuses, what the smoke run covers, what the cache writes), and the
tests' fixture. I ran five probes on the tests' own fixture, from a `git archive HEAD` copy loaded with
`pkgload::load_all()` in the scratchpad (`r4/probe.R`, `r4/probe2.R`). No database was used, and nothing was written in
the repo except this file. I also read the mtimes of this machine's tracked figures, `floodplain.csv` and ignored
segments.

## Mechanism

I confirm the mechanism: presence, sort order or position taken as provenance. Round 3's fixes replaced "the file is in
the run" with three new proxies for "made by the step being promoted". Each holds in the case it was written for and
fails one step over:

1. **mtime order as provenance.** `take_drawn`, the floodplain check and the comparison freshness check compare mtimes.
   That works inside a candidate, where only 0320 and 0330 write. It fails in an archive (`replaced_<stamp>`), whose
   files came from the tracked tree, where git sets the mtime at checkout. On this machine
   `research/fig/compare_ch_rear_*.png` read 2026-10-26 against `CH_rear_segments.rds` 2026-10-27. `floodplain.csv` reads
   2026-10-28 11:26, though its last commit is 2026-10-19. A failed write is also newer than the segments.
2. **"Some log of the run graded k" as provenance for "the pass whose summary is promoted graded or kept k".** A pass
   rewrites every key's summary and curve before it grades any key. It writes its log only after a graded key, on
   `fail()` or at the end, so a pass that dies early leaves no log at all.
3. **A derived table taken as its own source.** `compare.csv`, `change.csv` and `checks.csv` are the per-key tables
   bound together at the end of a 0330 pass (One fact derived twice). The promotion takes a key's rows from the run's
   combined file. It does not check that those rows came from the per-key tables it promotes, and it does not apply
   round 3's rule for an unfitted key (take nothing) to them.

There is also a class not yet found: **two records of one fact checked on fewer fields than their producer uses.**
0320's keep-check decides that grades belong to a fit on ten fields. The promotion checks grades against the summary on
two (rule, evidence).

Every choice of a key set, file, run, ledger or log, after round 3:

| where | chooses | by | verdict |
|---|---|---|---|
| `knw_tune_promote()` per-key loop (81-90) | which keys need grades and a comparison | `status` against knw_tune_run()'s statuses | sound |
| per-key loop (95-101) | that the run's grades are this summary's fit | `rule`, `evidence_md5` | **too few fields: finding 3** |
| per-key loop (108) | the comparison is of the current grades | `mtime(compare) >= mtime(grades)` | sound in a candidate; in an archive it reads git's mtime (fails loud, a refusal) |
| `take_tune`, unfitted (201-202) | an unfitted key's files | summary, curve.rds, smoke.csv | summary and curve.rds sound; **smoke.csv is never written for a no-fit key: finding 5** |
| `take_tune`, fitted | a fitted key's files | everything with its prefix | sound for the fit's tables; smoke.csv can be a later failed smoke pass's (finding 5) |
| `take_cmp` (203) | an unfitted key's per-key comparison | none taken | sound |
| `.knw_rows_merge()` (336) | a promoted key's rows in the combined tables | the run's combined file, for fitted and unfitted keys alike | **finding 1 (unfitted), finding 2 (fitted, stale)** |
| `take_drawn` (206-210) | a fitted key's GeoPackage and figures | `mtime >= <key>_segments.rds` | sound in a candidate; **wrong in an archive, and a failed GeoPackage write passes: finding 4** |
| floodplain check (251-252) | whether the run's floodplain rows are current | `mtime >=` every promoted fitted key's segments | sound for fitted keys in a candidate; unfitted keys' rows: finding 1; archive: finding 4 |
| grading-log check (234-244) | that a fitted key's grades have a pass that made them | any `<k> grades:` line in any of the run's logs | proxy; blind to a pass that died before its first graded key (finding 3) |
| its archive exception (235-237) | the same for an undo | every tracked log | as accepted |
| 0320 pass name (122-130) | the order of passes | UTC start, 14 digits | sound. The date prefix and the pass come from two `Sys.time()` calls, but no reader needs them to agree |
| 0320 per-key log rewrite (447) | the record of a pass that died | log after each graded key | sound for graded keys; a pass that dies before its first graded key leaves no log (finding 3) |
| `0335` evidence guard (65-69) | that the rebuilds can run | derived tables present when the bundles run | sound for `bundles`; with `BUNDLES=FALSE` and no derived tables the evidence goes unchecked, though header line 21 says it is always checked (doc only) |
| `0335` SPECIES (54-58) | keys | summaries by species prefix | sound |
| 0330 STAGE=maps with SPECIES | which keys' floodplain rows the file holds | `jobs` (SPECIES only) | rewrites `floodplain.csv` with that subset alone; the promotion refuses a whole run on `lost` (loud), sound |
| `vignette_chinook.R` log (61-77) | the log of the pass that graded CH | `tune_run`, newest pass with a grade line | sound |
| `knw_run_ledger()` (0325, 0330, vignette_method) | the ledger | the summaries' `evidence_ledger`, else newest | sound; fallback as accepted |
| `0320` `ledger_path`, `dir_pub` | build; published side | newest name; tracked dir | intended / sound |

## Findings

- **[bug] R/tune_promote.R:261 with :336 (and :322). An unfitted promoted key keeps rows in the combined tables.**
  Round 3 made `take_cmp` take none of an unfitted key's per-key comparison. `.knw_rows_merge()` still takes
  `new$rows[new$key == k]` for every promoted key. So when the run's `compare.csv`, `change.csv`, `checks.csv` or
  `floodplain.csv` still holds the key's rows from an earlier pass's fit, those rows become tracked. That happens
  whenever 0330 was not rerun after the pass that stopped fitting the key, and nothing needs a rerun when the other
  keys' grades were kept. When the run's table is missing or `floodplain.csv` is stale (`next` at :258), the tracked
  rows of the now-unfitted key stay too. This contradicts the merge's own comment ("an unfitted one loses its rows")
  and round 1's rule.
  - Reproduced (`r4/probe.R` P1): with CH_rear's run summary set to `too_few_groups`, the promotion removed
    `CH_rear_compare.csv` but tracked `compare.csv` held 2 CH rows.
  - Suggested fix: drop the unfitted keys' rows in `.knw_rows_merge()` (rows only for `k %in% fitted`), and apply the
    same rule on the `next` path for the tracked rows.

- **[bug] R/tune_promote.R:245-262. A fitted key's rows in `compare.csv`, `change.csv` and `checks.csv` are taken from
  the run's combined file without checking they come from the per-key tables being promoted.** 0330 writes each key's
  per-key tables as the key finishes, and the combined tables only at the end of the pass. A 0330 killed between the
  two leaves new per-key tables next to a combined table carrying the previous comparison's rows. A full 0330 runs for
  hours (162.9 min), so a kill there is plausible: a dropped connection, Ctrl-C, a machine asleep.
  - The per-key checks pass: the compare is newer than the grades, and the tuned rule is unchanged after a regrade
    under the same pick. The merge then writes the old rows.
  - Reproduced (`r4/probe2.R`): tracked `CH_rear_compare.csv` km 91, 92, tracked `compare.csv` CH km 1, 2, 0 notes.
  - Round 3 added a staleness check for `floodplain.csv` only.
  - Suggested fix: refuse, or note and keep, a combined table older than any promoted fitted key's `<key>_compare.csv`.
    Better, since these three tables are the per-key tables bound and rounded, build each promoted key's rows from its
    per-key table as 0330 does.

- **[bug] R/tune_promote.R:95-101 (and the log check at :232-244). A key's grades are held to its summary on rule and
  evidence only, so grades from an earlier pass's curve are promoted under a refit's summary.** 0320 writes every key's
  summary and `_curve.rds` (:333-341) before it grades any key. A resumed pass after a change to the curve, the gate or
  the prior (CLAUDE.md: such a change "regrades every key", 53 min cold) that dies before reaching a key leaves that key
  in a mixed state. Its grades are the earlier pass's and its summary is the refit's, with the same rule and evidence
  but a different `grade_withheld` or `curve_prior_sd`.
  - The promotion passes:
    - the rule and evidence match;
    - the comparison is newer than the old grades;
    - the earlier pass's log carries `<k> grades:`;
    - if the dead pass graded no key it wrote no log at all, and the log check cannot see it.
  - Nothing after it compares those fields with the summary. 0325's `mispick` checks rule, run_uid, evidence and
    curve_grad, and it withholds by the grade table's own flag (`withheld` at 0325:141). vignette_chinook checks
    presence only.
  - So the published grades follow the old gate while `thresholds.csv` and the article follow the new one.
  - 0320's own keep-check (:400-410) treats exactly these fields as what makes a grade table belong to its fit.
  - Reproduced (`r4/probe.R` P3): summary `grade_withheld = TRUE`, `curve_prior_sd = 1`; grades `FALSE` and `2.5`.
    Promoted.
  - Suggested fix: hold the run's grades to the summary on every keep-check field the summary carries (`rule`,
    `run_uid`, `evidence_md5`, `curve_grad`, `curve_prior_sd`, `grade_withheld`, `null_heldout_curve` numerically).

- **[bug] R/tune_promote.R:206-210 and :251-252, on an undo (RUN=replaced_<stamp>). The mtime tests read git's checkout
  times in an archive, so an undo does not restore the replaced figures (or does, by chance, for `floodplain.csv`).** An
  archive holds the tracked tree's files. Tracked figures and `floodplain.csv` carry the time git last wrote them, while
  the archived segments carry 0330's.
  - Reproduced (`r4/probe.R` P4): with the tracked figure older than the tracked segments, the case on this machine
    today (the figures were not redrawn for #73), the undo left the promoted figure in `research/fig/`. The original
    stayed stranded in the archive, and the note read "left in the run, from an earlier pass or comparison".
  - The roxygen promises a promotion is undone by promoting the archive, except for logs and files added where none
    stood. Replaced figures are neither.
  - The same proxy passes a GeoPackage that failed partway. `gpkg_one()` (0330:252-268) unlinks and rewrites group by
    group, and on error it returns a message and leaves the partial file. That file is newer than the segments, so
    `take_drawn` moves it over a complete tracked one. The 0330 log says FAILED, and the promotion does not read it.
  - Suggested fix: in an archive, take everything (the archive's contents are by construction what the promotion
    replaced). For a candidate, consider reading the comparison log's per-key result rather than mtimes.

- **[fragile] R/tune_promote.R:201. `_smoke.csv` is taken as what the last pass wrote for an unfitted key, but 0320
  never writes one for it.** knw_tune_run() smokes only the keys in `prep`, which excludes the three no-fit statuses
  (R/tune_run.R:151-206). 0320 writes `<key>_smoke.csv` only where `smoke` is non-NULL (:223-231). So a run's smoke table
  for a no-fit key is always an earlier pass's fit's. The claim at :199-201 ("when the smoke run scored it") was never
  measured.
  - Reproduced (`r4/probe.R` P5): the earlier pass's smoke table became the tracked `CH_rear_smoke.csv`.
  - The same holds for a fitted key after a resumed pass that failed its smoke run. `fail()` comes after the smoke
    tables are written, so the run holds that failed pass's smoke tables next to the previous pass's summary and grades.
  - No code reads the smoke tables, but they are tracked (16 files).
  - Suggested fix: take only the summary and curve.rds for an unfitted key.
