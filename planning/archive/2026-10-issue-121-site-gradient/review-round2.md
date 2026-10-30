# Code-check round 2: #121 branch (site_gradient_check.R, data-raw/README.md, research/fdis_export.md)

## Checklist read

- `code-check-python.md`: in full (nothing in it applies; the diff has no Python).
- `code-check.md` (334,881 bytes): the prose of every H3 under `## Mechanisms`, table rows skipped: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice (opening only). None of the 18 `Rules that stand alone`, Security or Spreadsheets headings read (none names a tool or shape the diff uses).
- `code-check-r.md` (190,768 bytes): 10 headings read: `system2(stdout = TRUE)` warns on a non-zero exit…; CSV whitespace…; `$` on a list partial-matches…; A `data-raw/` script must load the source tree…; Inside a dplyr verb, a column named like a local variable wins; `match()` treats NA as a matchable VALUE…; `paste()` with a zero-length argument…; `summarise()` and `mutate()` evaluate in order…; `ifelse()` with an all-NA test…; `tolerance` in testthat is RELATIVE…. About 95 other headings not read.
- `code-check-shell.md` (131,937 bytes): no heading read (the diff has no shell; `git` is called through `system2`, covered by the R heading above).
- `code-check-spatial.md` (155,517 bytes): no heading read (no spatial code).

## What was checked and held

Every number in the new research section was compared with `scripts/logs/habitat/20261030_site_gradient_check.txt`
(the script is unchanged between the log's commit e07f8ce and HEAD 5b3cb60). All of these match: the yardstick figures
(0.90 rank r, 9,389 with both, 9,204 above 0, ratio 0.60 to 1.58, second reading higher 46.5 %), the three-row table,
p90 9.3 against 13.0, the 87/67/23 % shares, length and order classes, the river/wetland/lake rank r values, every
flip share and band (34 to 42 % is 33.9 to 42.4 across the seven keys), the catch figures, the per-species
caught/not-caught flip shares (the claim holds for all seven keys, not only the three quoted), 55 negatives, the
−13.6 to −0.01 % range, 52 on their own line, 45 and 22 readings on a limit, 29,335 and 487.

Probes against the published evidence (read only): no measured gradient is negative or above 1; all 45,529 rows of
`visits_link.csv` are placed and have a segment gradient; the 644 half-zero rows are within the card's first row (644
in row 1, 88 in row 2, from `data/fdis/2020-11-16/habitat.csv`), so "0 and 4 % reads 2 %" is right; the stream-branch
yardstick (0.895, 0.882, 0.60–1.00–1.58) barely differs from the all-visits one the table prints. The code claims hold:
`knw_rule_in()` requires `g >= 0`; `R/tune_curve.R:81` and `R/grade.R:59` clamp to `[0, 0.2]`; the script's
`knw_rule_in()` call uses the same `cols`, `src` and `edge_stream` as 0320's (0320 passes only `cols`, and its default
gradient column is the one the script sets to 0). The ST band is now (0.07, 0.09] from its own tune table's ladder,
and the rearing populations match the tracked `n_visits` for all six rearing keys.

## Findings

- **[fragile]** research/fdis_export.md:307-308 — "so its figure is over every BT rearing-range visit before that
  filter". The round-1 fix names only the spawner filter, but the BT spawning population is also before the groups
  filter (the log's own block title says "before the spawner and groups filters"). That is why it holds 11,805 visits
  (5,660 measured) against BT rearing's 9,344 (4,427 measured). The range is the species' range (`visits_species.csv`
  has one `in_range` per species, not per stage), so "BT rearing-range" reads as BT rearing's scored population, which
  it is not: a reader checking 5,660 against the 4,427 quoted two lines up finds two populations for the same visits.
  Say "every BT visit in its range on the stream branch, not blocked, before the spawner and groups filters".
  The fix touched the wording but kept the same omission.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression drops the condition that made
    it true)

- **[fragile]** research/fdis_export.md:322-323 — "all on edge types the stream branch excludes (1200, 1400, 1410,
  1425; 34 in wetlands)". The log does not have these numbers. It prints only "0 on the stream branch". A probe
  confirms them (edge types 1200:8, 1400:29, 1410:15, 1425:3; `wb_wetland` 34; none on a stream edge type), but the
  section's provenance line names only the log, so nothing committed reproduces them. Either add the edge-type and
  waterbody tabulation to the script's negative-gradient `say()`, or say in the prose that they come from a separate
  read. Separately, "0 on the stream branch" does not by itself establish "on edge types the stream branch excludes":
  the stream branch also excludes by waterbody and fished area.
  - **Rule:** code-check.md "Verification that reads its own output" (re-derive each published number from the
    artifact it names)

- **[fragile]** research/fdis_export.md:335-336 — "Log and ratio statistics use pairs where both are above 0 (487 of
  16,279 are not)". 487 is the segment row's count. For the Atlas-line row in the same table it is 337 (log,
  `zero_pairs`). This is a quantity stated for the whole table that holds for one row only.
  - **Rule:** none

- **[fragile]** data-raw/site_gradient_check.R:243 — `dn <- d[d$segment_gradient < 0, , drop = FALSE]` subsets with a
  logical index that can be NA. A visit with an NA `segment_gradient` becomes an all-NA phantom row. `nrow(dn)` then
  counts it as a negative visit, and the rule test feeds it to `knw_rule_in()`. With an exception rule, that call stops
  with "visits have no walk" because the key pastes to `"NA NA"`. This build has no NA segment gradient, so the branch
  never runs here (the log prints NA for every key). But the header names a rerun with `EVIDENCE_CHECK=FALSE` on
  another build (#120), and that is the case this guard exists for. The sibling at line 231 uses dplyr `filter()`,
  which drops NA. Use `which(d$segment_gradient < 0)` or `%in% TRUE`. The rule-test arm has never executed on real
  input, so this is also the one path in the script no run has exercised.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things" (a value that is absent folded
    into a definite one); code-check.md "A fixture that cannot reach the failure mode" (an arm never executed)

- **[fragile]** data-raw/site_gradient_check.R:41, 62-66 — the provenance stamp does not cover the run's other
  inputs:
  - `TUNE_DIR` is never written to the log. A run with `TUNE_DIR=data/tune/candidate/<run>` logs exactly what a run
    on the tracked tables logs, yet its ladders and bands (`band_of`) and the negative-gradient rule tests come from
    the candidate.
  - `dirty` checks only `data-raw/site_gradient_check.R` and `R/`. An uncommitted `data/thresholds.csv` (the limits,
    `n_visits` and the evidence md5 the published check reads) or `data/tune/*_tune.csv` is not marked.

  Log `TUNE_DIR` with `home_rel()` beside `EVIDENCE_DIR`, and add `data/thresholds.csv` and the tune directory to the
  `git status` paths.
  - **Rule:** code-check.md "A guard that fails toward pass" (Provenance, and repair)

- **[fragile]** data-raw/site_gradient_check.R:62-65 — `system2(..., stdout = TRUE)` on `git rev-parse` and
  `git status`. When git fails (no checkout, a broken index), `system2` returns `character(0)` with a status attribute
  and a warning instead of raising.
  - The `dirty` test then reads as clean. That is the direction the stamp exists to catch.
  - `head_sha` becomes `character(0)`, so the first `say()`'s `sprintf()` returns `character(0)` and the log's first
    line, which carries the provenance, silently vanishes.

  Check `attr(x, "status")` on both calls.
  - **Rule:** code-check-r.md "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a
    `tryCatch(error =)` around it never fires"; code-check.md "A guard that fails toward pass"

- **[fragile]** data-raw/site_gradient_check.R:72, 177 — the refused log goes to `sub("\\.txt$", "_refused.txt",
  path_txt)`, but `.knw_free_path()` freed only the success name. A refused run never creates the success file, so a
  second refused run on the same day gets the same `path_txt` and overwrites the first refusal's log. 0320 frees the
  refused name itself (`.knw_free_path(sub(... "_tune_refused" ...))`, scripts/0320-tune-run.R:178). This script
  copied `compare_structures_check.R`'s form, which has the same overwrite.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

- **[fragile]** data-raw/site_gradient_check.R:218-228 — the block "by the species' outcome" splits every key on
  `present` (the species caught). For `BT_spawn` the tuning's outcome is spawner evidence (`S`), not presence. Its two
  rows are BT presence, and the TRUE row is identical to `BT_rear`'s (588 pairs, the same statistics), but the log
  labels them as BT spawning's outcome. The prose does not use them, but the log is the cited evidence. Label it "by
  whether the species was caught", or drop the spawning key from that block.
  - **Rule:** none

No security issues. Nothing else found in the script's arithmetic (band edges, the `<=` convention, floating
equality of `x/100` against the published limits, the rearing population guard) or in the README paragraph.
