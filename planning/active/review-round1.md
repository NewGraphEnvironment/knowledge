# Code-check round 1: #121 branch (site_gradient_check.R, research/fdis_export.md, data-raw/README.md, log)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped). Rules-that-stand-alone, Security and Spreadsheets sections not read (none names a tool or shape this diff uses).
- code-check-r.md: "`system2(stdout = TRUE)` warns on a non-zero exit...", "`$` on a list partial-matches...", "Inside a dplyr verb, a column named like a local variable wins", "A `data-raw/` script must load the source tree...", "CSV whitespace: ...", "Rscript reads a script as it runs...". About 105 other headings not read (tools and shapes the diff does not use).
- code-check-shell.md: no headings read. The diff has no shell code.
- code-check-spatial.md: no headings read. The diff does no spatial operations; it reads precomputed FWA gradients from CSV.

## What I checked

- I ran a copy of the committed script (output path redirected to the scratchpad) against the published evidence. Its log matches the tracked log byte for byte except the HEAD sha on line 1, so every logged number comes from the committed code.
- I checked every number in the research section against the log, and reprobed the evidence where the prose says more than the log does: the negative-gradient edge types and wetland count, the second-reading ratio, the share at 3 % or less, and ST's band on its own ladder.
- Guards: the md5 guard and EVIDENCE_CHECK fail toward refusal (missing column, missing files, several md5s, unknown values of the switch all refuse). The rearing population guard passed on the real run, and every rearing key matched its tracked `n_visits`. No column in visits_link or visits_species shares a name with the locals that the data-masked verbs read (`edge_stream`, `area_range`, `ladder`, ...).
- Claims that verified: the negative edge types (1200, 1400, 1410, 1425; 34 in wetlands); the clamp in `R/tune_curve.R:81` and `R/grade.R:59`; `knw_rule_in()`'s `g >= 0` test in `R/rule_in.R:71`.

## Findings

- **[severity: bug]** data-raw/site_gradient_check.R:180-185 (`band_of`), with research/fdis_export.md (the "a third to two fifths" bullet and the Specification). The band is built from `formals(knw_tune_grid)$grid_grad`, but each key's tuning ladder also holds its default gradient (`R/tune_grid.R:80`: `grid_grad <- sort(unique(c(grid_grad, g_def, ...)))`). ST's published limit, 0.0849, is on ST's own ladder (data/tune/ST_rear_tune.csv: ..., 0.07, 0.0849, 0.09, ...) but not on the default one. So `match()` returns NA and the fallback builds ±(ladder[2] − ladder[1]) = ±0.01, which is the ladder's bottom step: (0.0749, 0.0949]. That is not "one step of the tuning's ladder either side", as the script header and the research Specification state. On ST's own ladder the band is (0.07, 0.09]: 33 visits, 42.4 % flip. The log's row reads 25 visits, 48.0 %. Every other key's limit is on the default ladder, and the extra rungs on its own ladder (BT_rear 0.1049 and 0.1349, GR 0.0349, RB 0.0849) do not neighbour its limit, so only ST's row is wrong today. Any future limit that is a key's own default gets the same arbitrary ±0.01 band.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: bug]** research/fdis_export.md, "What it shows", "At the limits": "a third to two fifths of visits flip". It does not hold for every key in the log. The segment `band_flips_pct` values are BT_rear 40.0, BT_spawn 34.3, CH 33.9, CO 40.7, GR 36.3, RB 35.3 and ST 48.0 (42.4 on ST's own ladder, above). The range is 34 to 48 % (34 to 42 % with ST corrected), so ST, and CO marginally, sit above two fifths. The same bullet opens "Over each species' scored visits" and then quotes BT spawning's 5,660 and 446. Those counts are from a population of 11,805 before the spawner and groups filters, against 513 scored visits (log lines 220-223), so they are not scored visits. The parenthetical "(before the spawner filter)" also omits the groups filter.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: bug]** research/fdis_export.md, "What the two numbers are": "the second reading within 0.60 to 1.58 times the first at 80 % of the 9,204". `agree(two$meas, two$meas2)` computes `m / g`, which is first / second (script lines 104 and 120). So 0.60 to 1.58 is the first reading as a multiple of the second. Reprobed on the evidence: second / first has p10 to p90 of 0.63 to 1.67, and only 79.1 % of the second readings lie within 0.60 to 1.58 times the first. The table row is labelled "measured/modelled" and so is right in its own terms; the sentence inverts it.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: bug]** research/fdis_export.md, "What it shows": "Sites with fish agree better (median difference 1.7 against 2.6 points)". The same log block (lines 164-174) shows sites with fish agreeing worse on three of the four statistics: rank r 0.642 against 0.678, log r 0.594 against 0.637, and a wider ratio spread (0.35 to 2.63 against 0.32 to 2.02). Only the median absolute difference favours them. The claim follows one check and leaves out three that point the other way (writing.md, "When explaining a decision, list every check and the way it points").
  - The next sentence, "the exception is short segments", compares the gradient-stratified table with the length table, and the length table is not stratified by gradient. So "because they are gentler" applies to it as well. On 50-250 m the median difference is also twice as large without fish (1.67 against 3.42 points), and only rank r (0.64 against 0.41 at 50 m or less) singles out short segments.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** research/fdis_export.md, "Negative segment gradients": "tested on every rule of every tuned key, set to 0, none changes a visit's in or out". The test is vacuous by construction. Every key's population is a subset of the stream branch, which none of the 55 negative visits is on (log line 309: "0 on the stream branch"), so `dn` has 0 rows for every key and `rule_flips` returns `0L` at `if (!nrow(dn))` without calling `knw_rule_in()` (script lines 232-235). The previous clause ("No species' scored population holds one, so no pick depends on one") is the true and sufficient statement. Presenting a 0-row test as a test over every rule overstates what was run, and the script prints no VACUOUS marker.
  - **Rule:** code-check.md "A fixture that cannot reach the failure mode"

- **[severity: bug, minor]** research/fdis_export.md, "What it shows": "it reads higher than the site at 67 % of sites measured at 3 % or less". 67.4 % is the log's `(0,0.03]` bin, which leaves out the 130 visits measured at exactly 0 (86.9 % model higher, log line 125). Over every site at 3 % or less (5,487) it is 67.8 % (reprobed), which rounds to 68 %.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: bug]** data-raw/site_gradient_check.R:171-176. The population-mismatch refusal writes its log to `path_txt`, the success name `<date>_site_gradient_check.txt`, and then stops. CLAUDE.md (Database access) says a refused run writes under a `_refused` name, outside the patterns later steps read, "any new refusal does the same". The md5 refusal at line 68 follows that rule; this one does not. A refused run's log is therefore indistinguishable by name from a completed one, and research/fdis_export.md cites the log by that very name.
  - **Rule:** none

- **[severity: fragile]** data-raw/site_gradient_check.R:61-62, with scripts/logs/habitat/20261030_site_gradient_check.txt:1. The provenance stamp is `git rev-parse HEAD` alone, and the tracked log says "knowledge 51f46b1". At 51f46b1 the script did not exist: it was first committed in 69f048a. So the run happened on an uncommitted working copy, and the sha names a tree that cannot reproduce the log. Numbers are unaffected: my rerun of the committed script reproduces the log except that line. But the stamp does not detect a dirty tree, so it will misattribute the next run the same way. Recording `git status --porcelain -- data-raw/site_gradient_check.R R/` beside the sha would fix that, or the script could refuse to run with uncommitted code, as `data-raw/vignette_method.R` does.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: security, low; a discipline call, not a written violation]** scripts/logs/habitat/20261030_site_gradient_check.txt:1 carries `~/Projects/repo_aside/knowledge_published_inputs_20261028/data/fdis/derived`. `home_rel()` turns the home directory into `~` but keeps the user's local directory layout. CLAUDE.md bans home paths outright only in `planning/`; `public_sweep.py`'s `local_path` pattern (`~/Projects`) does not scan `scripts/logs/`; and 20261028_compare_structures_check-*.txt already carries `~/Projects/repo/knowledge/...`. So this matches precedent rather than breaking a rule. I am flagging it because the caller asked and because it is the only surface the sweep skips. Logging the path relative to the repo, or only the md5s, would avoid it.
  - **Rule:** none

## Not issues (checked)

- md5 guard and EVIDENCE_CHECK: they fail toward refusal, and the `!x %in% y` precedence is correct.
- flip arithmetic: `(meas <= t) != (g <= t)` matches knw_rule_in's `<=`. NAs are excluded through `ok`. An integer percent divided by 100 equals the parsed limit exactly (correctly rounded division), so the on-limit counts are consistent.
- The rearing populations equal the tracked `n_visits` for all six rearing keys.
- All other numbers in the research section match the log.
