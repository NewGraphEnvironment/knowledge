# Code-check round 3: stream-branch reference (#65), staged diff6 + unstaged later-phase edits

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped); index for the rest.
- `code-check-r.md`: full sections "Read-back shape must match write-back shape", "`identical()` on two reader results
  tests the reader", "Rscript reads a script as it runs", "CSV whitespace"; the other ~85 headings read as index lines only.
- `code-check-spatial.md`: full section "FWA main flow is not edge type 1000 alone"; the other ~91 as index lines.
- `code-check-shell.md`: index only (67 headings; the diff has no shell).

Tests: `tests/testthat/test-grade_species.R` in a temp copy, `NOT_CRAN=true`: 4 blocks, 22 expectations, 0 failed,
0 errors. No database touched; `data/tune/*_grades.csv` read with `head -1` only (none carries `ref_population`
yet; the running job is `scratchpad/0320_frozen.R`, identical to the staged 0320, full pass, no `SPECIES`, so it
logs to `scripts/logs/habitat/20261019_tune_run.txt`).

## Findings

- **[bug: wrong statement]** `research/habitat_thresholds_tuned.md` Limits, new bullet (unstaged): "so its grade rests
  on the surface past its data, and most such segments read 1." The only measurement on file
  (`planning/archive/2026-10-issue-65-grade-walks-every-segment/findings.md`, "First CH regrade", table) gives river/lake km at **>= 0.8** as 49.0 % under the
  stream-branch reference (20.4 % under every-accessible). The share reading exactly 1 is at most that, so "most"
  is not supported by km; nothing records it by segment count. Measure it (count and km, river polygons alone
  rather than river + lake edges) or reword to the measured 49 % at 0.8 or more.

- **[bug: wrong statement]** `research/habitat_thresholds_tuned.md` Grade bullet (unstaged): "walked from its
  downstream end to the first river of the pick's size (10 m³/s where the pick has no exception)". In this repo
  the pick's size is `size_min` (CH: 0.75 m³/s); the walk goes to the pick's `exc_q` (CH: 3 m³/s), or the curve's
  `q` (10) when there is none (`R/grade_species.R:72`). Should read "the pick's exception river".

- **[fragile]** `NEWS.md` (unstaged) describes only the walk change. It says nothing of the reference now being
  taken over the stream branch (CH: 0.516 over every accessible segment, 0.139 over the stream branch; every
  grade's denominator changes), nor of `knw_grade(ref_rows =)` / `knw_grade_species(ref_edge =)`. Instead it says
  `knw_grade_species()` "drops its unused `edge_stream` argument" while this branch adds `ref_edge` with that same
  default `c(1000L, 1100L, 2000L, 2300L)`, so a reader of the release note sees the edge list removed. The plan's
  own spec for the entry (task_plan Phase 3: "the grade walks every graded segment; v1 corrected before
  publication; the two roxygen fixes") omits it too, so following the plan ships the omission.

- **[fragile]** Six species research files are outside the plan's Phase 3 and will keep #57's capped-grade
  figures after the regrade, with no "provisional" hedge: `research/bull_trout_tuned.md:28-30,44-45,53,57,60-61`,
  `coho_rearing_tuned.md:27-29,34,37` (including "reference rate 0.514, the highest of any species, so grades
  spread", a rank and a causal claim), `grayling_rearing_tuned.md:21-23,27`, `rainbow_rearing_tuned.md:27-30,34,38`,
  `steelhead_rearing_tuned.md:23-24,28,31`, `westslope_cutthroat_rearing_tuned.md:20-22,27,30`. And
  `bull_trout_tuned.md:66-67` states the method: "graded against the best accessible segments", now the best
  accessible stream-branch segments. task_plan Phase 3 names only `habitat_thresholds_tuned.md` and
  `chinook_rearing_tuned.md`.

- **[fragile]** `scripts/0330-compare.R:123-131` with `STAGE=maps`: the new guard reads `data/tune/*_grades.csv`,
  but `STAGE=maps` takes `floodplain.csv`'s graded ha and the grade and floodplain map panels from
  `data/compare/<key>_segments.rds` of the last full run (L213ff: `seg_all <- readRDS(...)`, `knw_floodplain_ha()` on
  its `grade`). Between 0320's regrade and a full 0330, `STAGE=maps` passes the guard and writes graded ha from the
  pre-#65 grades. The guard's comment ("the graded km read the grade tables 0320 wrote") holds for the full run
  only. The segments rds carries no marker, so either refuse `STAGE=maps` when any `<key>_segments.rds` is older
  than its `<key>_grades.csv`, or have the full run carry `ref_population` into the segments it saves and check that.

- **[fragile]** `data-raw/vignette_chinook.R:47,141-154` (plan Phase 2: "point `path_log` at the new CH tuning
  log"). `meta$grade` (shipped in `inst/vignette-data/chinook_rearing.rds`) is parsed from the log's
  `CH_rear grades:` line, and 0320 writes that line (`scripts/0320-tune-run.R:208`) with "reference rate %.4f" and
  no population. Two logs dated 2026-10-19 now carry a `CH_rear grades:` line on the same evidence ledger:
  `20261019_tune_run-ch.txt` (the superseded every-accessible regrade, reference 0.5156) and the running pass's
  `20261019_tune_run.txt`. Every check in the script (ledger on line 1, one grades line, groups equal to
  compare's) passes on either, and the name the plan uses ("the new CH tuning log") fits the wrong one better.
  Not printed by the article today, so the cost is a wrong value in the bundle's meta and in any `findings.md`
  figure copied from a log. Print the population in the line (`reference rate 0.1390 over stream_branch`) and
  require it in data-raw.

## Mechanism

One fact, "how this grade was made" (walk set, river size, reference population), has no producer that states
it. The code that makes the grade (`knw_grade_species()`) returns rates and a reference value; everything that
says how they were made is a hand restatement written beside it, and every guard reads a proxy for it:

1. **Restatements written from the case in front of the author.** Round 1's stale 0325 description, round 2's
   "the rule's river" (written from CH, which has an exception; six of eight do not), and this round's "the
   pick's size", "most such segments read 1" and the NEWS entry are the same act: prose about a population written
   from its most familiar member (CH, the one regraded and measured) and checked against no producer.
2. **Gates on a proxy, and a marker the caller asserts.** First `"dist_status" %in% names()` (a column's presence
   standing for the walk set), now `ref_population == "stream_branch"`, a literal 0320 and 0322 write by hand.
   It vouches for `ref_edge`'s default, not for what the call did; it agrees with `knw_tune_run()`'s
   `edge_stream` default (the curve's actual population) only because the two defaults happen to be the same
   list. Nothing ties them: the curve object does not record `edge_stream`, and data-raw reads it from
   `formals(knw_tune_run)`, a third copy of the default. The list also appears literally in `R/rule_in.R:62`,
   `scripts/0322:341`, the 0325 description and the test.
3. **The guard reads one artifact and the consumer another.** 0330's guard reads `data/tune` grade tables;
   `STAGE=maps` consumes `data/compare` segments. data-raw consumes a log line that names no population.

So each round fixes the instance a reviewer named, and the class recurs one artifact over (description, then
gates, then logs, maps and the species files). Closing it means emitting the provenance where the grade is
made, not restating it: `knw_grade_species()` returning `ref_edge` (and the walk's `q`) beside `reference`,
0320 writing that value rather than a literal, the log line printing it, and every consumer checking the emitted
value. That is a design change for the author to weigh, not a defect in this diff on its own.

## Enumeration

Grep (run 2026-10-19 on the working tree, staged + unstaged):

```
grep -rniE "95th|percentile|ref_quantile|reads 1|reference rate|knw_grade|_grades\.(csv|rds)|grade table|habitat_grade|dist_status|walk(s|ed)? (every|only)|distance cap|50 km|dist_cap" R scripts data-raw vignettes research NEWS.md man tests inst
grep -rn "edge_stream\|1000L, 1100L\|1000, 1100\|ref_edge\|ref_rows\|ref_population" --include=*.R --include=*.Rmd --include=*.md --include=*.Rd .
grep -n -iE "reference rate|graded|grade" research/*_tuned.md
grep -rln "grade" R/ scripts/*.R data-raw/
grep -n -i "grade" vignettes/chinook_rearing.Rmd research/README.md _pkgdown.yml
```

(The vignette has no "grade" at all; logs under `scripts/logs/` are dated records and not judged; `planning/` is
the record, not judged; literature `percentile` hits are unrelated and dropped.)

| place | what it states or relies on | verdict |
|---|---|---|
| `R/grade.R:3-10` roxygen | rate / ref_quantile over accessible segments `ref_rows` marks; "top of the reference segments reads 1" | consistent |
| `R/grade.R:14-18` | missing distance = cap; `knw_grade_species()` walks every gradable accessible segment | consistent (walk set is a superset) |
| `R/grade.R:26-31` `@param ref_quantile`, `ref_rows` | as code L67-72 | consistent |
| `R/grade.R:67-72` code | reference over accessible & ref_rows & rate | consistent with docs |
| `R/grade_species.R:3-10` | walks every accessible segment with a gradient to `exc_q`, else curve `q` | consistent (L69-72) |
| `R/grade_species.R:12-16` | `dist_m` is the exception's distance; pick's `exc_q` wins | consistent |
| `R/grade_species.R:18-23` | extrapolation; reference over stream branch; "river polygons at 0 m set it, 0.14 to 0.52" | consistent with findings (0.139 to 0.516; river and lake edges together set it, 95th 0.880) |
| `R/grade_species.R:25-29` | `none`/`no_parent`/`too_many_hops` keep NA; `no_walk` outside walk set | consistent (L66, L78-80) |
| `R/grade_species.R:41-43` `ref_edge` | "the edge types of the curve's visits (`knw_tune_run()`'s `edge_stream`)" | true by equal defaults only (mechanism 2) |
| `R/compare_rules.R:5-8,18-23,36-38` | exception reads `dist_m` walked by `knw_grade_species()` to `exc_q`; grades give graded km | consistent |
| `R/floodplain_ha.R`, `R/compare_map.R`, `R/link_segments.R` | use `grade` as given; no statement of how made | consistent |
| `R/tune_curve.R:9,26-33,48,55,64` | cap 50 km, `q_default` 10, censoring | consistent with grade docs and 0325 |
| `man/knw_grade.Rd`, `man/knw_grade_species.Rd` | regenerated copies of the above | consistent |
| `man/knw_compare_rules.Rd:40,81` | as compare_rules | consistent |
| `tests/testthat/test-grade_species.R:1,102-120` | walk set; stream-branch reference; off-branch graded | consistent, passing |
| `tests/testthat/test-tune_curve.R:58-78` | "top of the accessible network reads 1" with default `ref_rows = NULL` | consistent |
| `scripts/0320-tune-run.R:22-31` spec | percentile over stream branch's edge types since #65; every accessible segment with a gradient walked | consistent |
| `scripts/0320-tune-run.R:39-40` OUTPUT | each graded segment at its own walked distance, with `dist_status` | consistent (omits `ref_population`; not wrong) |
| `scripts/0320-tune-run.R:182-200` keep check | requires `dist_status` and `ref_population == "stream_branch"` | consistent; marker is a literal (mechanism 2) |
| `scripts/0320-tune-run.R:204-208` writer, log line | writes the marker; log line prints reference with no population | writer consistent; log line is the data-raw finding |
| `scripts/0322:19-26` header | "Grades made before #65 (no dist_status) ... so done_rule() regrades them" | stale but not false: `done_rule()` now tests `ref_population` and also regrades every-accessible tables |
| `scripts/0322:30-33` header | regrading moves the 95th-percentile reference | consistent |
| `scripts/0322:254-264` `done_rule()`, `:276-283` writer | marker written and required | consistent |
| `scripts/0322:331-375` beside v1 | reads 0330's segments for habitat flags and `knw_size`/`knw_dist`, no grade | does not rely on how grades were made (exception verdicts are walk-set invariant) |
| `scripts/0325:72-79` guard | refuses tables without the marker | consistent |
| `scripts/0325:91` description | own walked distance; exception river or 10 m³/s; 95th pct of accessible stream-branch segments (edge types listed) | consistent |
| `scripts/0325:94` note | "Expected-use grades for every segment ... (knowledge#57)" | consistent (no method claim) |
| `scripts/0330:123-131` guard | "the graded km read the grade tables 0320 wrote" | consistent for the full run; not for `STAGE=maps` (finding) |
| `scripts/0330:136-145` full-run read | reads the guarded tables | consistent |
| `scripts/README.md:58-60` (unstaged) | each accessible one at its own walked distance to the pick's river | consistent ("the pick's river" = exc_q or 10) |
| `data-raw/vignette_chinook.R:18-22` (unstaged comment) | distance measured on every accessible segment with a gradient since #65 | consistent |
| `data-raw/vignette_chinook.R:47,141-154` | `meta$grade` from a fixed log's grades line | relies on the log being the stream-branch run; unverifiable (finding) |
| `data-raw/vignette_chinook.R:155` | `edge_stream` from `formals(knw_tune_run)` | default, not the run's value (mechanism 2) |
| `data-raw/vignette_chinook.R:173-186` surface | `knw_grade()` rates only; reference unused | consistent |
| `vignettes/chinook_rearing.Rmd:445-458` (unstaged) | distance column: NA reads "no river found"; caption "reads it only where the flow falls short" | consistent: every example is accessible with a gradient, so NA is a walk status, not `no_walk` |
| `research/habitat_thresholds_tuned.md:29-30` (unstaged) | own distance; #65 corrected the cap | consistent |
| `research/habitat_thresholds_tuned.md:72-80` Grade (unstaged) | percentile over stream branch; walk "to the first river of the pick's size" | reference consistent; "pick's size" wrong (finding) |
| `research/habitat_thresholds_tuned.md:113-122` Grades table | #57 reference rates and km | stale; scheduled numbers (not a finding) |
| `research/habitat_thresholds_tuned.md:192-195` | graded ha "reads every segment ... at the 50 km cap ... provisional" | stale; scheduled in Phase 3 |
| `research/habitat_thresholds_tuned.md:206-210` Limits (unstaged) | extrapolation; "most such segments read 1"; 0.14 to 0.52; 0.4 % | "most read 1" unsupported (finding); rest consistent with findings |
| `research/habitat_thresholds_tuned.md:1-2` header | Verified 2026-10-17, logs `20261017_tune_run-*` | stale; scheduled ("Verified date") |
| `research/chinook_rearing_tuned.md:29-39` | reference 0.146, 76 %, "provisional until #65" | stale; scheduled |
| `research/{bull_trout,coho,grayling,rainbow,steelhead,westslope_cutthroat}_*tuned.md` | #57 reference rates, graded km/ha, class shares; BT "graded against the best accessible segments" | stale and unscheduled (finding) |
| `research/README.md:18,22` | "the 0-1 grade"; width rule grades measured streams only | consistent |
| `_pkgdown.yml:44` | "grade every segment by expected use" | consistent |
| `NEWS.md:1-9` (unstaged) | walk change only; "drops its unused `edge_stream` argument" | incomplete; misleading beside the new `ref_edge` (finding) |
| `NEWS.md:34-36` (0.4.5 entry) | `knw_grade()` and grade tables introduced | historical, consistent |
| `inst/vignette-data/chinook_rearing.rds` `meta$grade` | #57 log values | stale until data-raw reruns; see the data-raw finding |
| `CLAUDE.md` | no statement of how a grade is made (grade tables ignored under `data/tune/`) | consistent |

Nothing else in R/, scripts/, data-raw/, vignettes/, research/, NEWS.md or man/ states how a grade is made or
depends on it. Every "stale; scheduled" row is a number or hedge that task_plan Phase 3 names and that awaits the
running job.
