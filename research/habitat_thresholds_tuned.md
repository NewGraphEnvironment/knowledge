# Habitat thresholds tuned for every species and life stage in one run

**Verified:** 2026-11-04 (#145: every key retuned, regraded and recompared on link's 2026-11-03 build and wet's
2026-10-24 flows, promoted as run `20261104_0543`; its section opens the results, and the sections after it are #92's);
2026-10-27 (#92: every key retuned and regraded on #91's evidence, each visit scored on the gradient of
the link segment it sits on, with the Atlas line's gradient scored as a sensitivity); 2026-10-25 (#73: every key retuned on the evidence rebuilt on wet's 2026-10-19 flows with the walk ending at
the river's bank, on a gradient ladder to 30 %, with the grid's fit absorbing the groups and a prior on its data-set and
era terms; graded with the curve's prior under a gate; recompared under link's through-wetland structures); first
tuned 2026-10-17 (#57); regraded 2026-10-19 (#65); the one-SE wording and the picks at 1.96 SE 2026-10-20 (#79) ·
**Issues:** #57 (this; replaced #59), #65, #79, #73 (folding #68, #80 and #81's run-time pieces; #83 and #84 are its
scorer work; #85, #86 and #87 the speed work it spawned), #91 (the evidence's placement) and #92 (the segment
gradient, and the retune on #91's evidence), #112 (the structures a comparison runs), #145 (the retune on link's
2026-11-03 build); the one-species tunings it supersedes are #28
(`habitat_weights.md`), #33 (`bt_spawning.md`), #52 (`chinook_stream_size.md`) and #54 (`chinook_rearing_tuned.md`);
link reads the result through NewGraphEnvironment/link#346 · **Produced by:**
- #145's run: `scripts/logs/habitat/20261103_link_settle.csv`, `20261103_evidence_build_ledger.csv`,
  `20261104_tune_run-20261104_0543-*.txt` (with its `-grad_fwa` sensitivity), `20261104_compare-20261104_0543.txt`
  and `20261104_promote-20261104_0543.txt`; the tables in `data/tune/` and `data/compare/` are its own;
- `scripts/0300`: the wait for link's province-wide `default` run (`scripts/logs/habitat/20261017_link_settle.csv`);
- `scripts/0310`: the evidence build (`scripts/logs/habitat/20261027_evidence_build_ledger.csv`, #91's; #73's was `20261022_…`; tables built as
  `knowledge/fdis/v3`, not yet uploaded);
- `scripts/0320`: the tuning run (`data/tune/<sp>_<stage>_{tune,summary,honest,seeds,curves,groups,smoke}.csv`; #92's
  run `scripts/logs/habitat/20261027_tune_run.txt`, and its Atlas-gradient sensitivity `20261027_tune_run-grad_fwa.txt`
  into `data/tune/grad_fwa/`; #73's rescore's grading `20261023_tune_run.txt`, its regrade with the curve's prior and
  the grade gate `20261024_tune_run.txt`; #57's `20261017_tune_run-*` and #65's `20261019_tune_run.{txt,out}` are the earlier runs);
- `scripts/0325`: `data/thresholds.csv` and `data/thresholds_groups.csv` (rewritten from #145's tables by its
  promotion); the Parquet sets `knowledge/thresholds/v1` and `knowledge/habitat_grade/v1` are still #73's (published
  from the database's host on 2026-10-25, commit `bf41ebd`, with BT spawning and CO, ST and WCT rearing left out of the
  grade set) until #145's tables are published;
- `planning/archive/2026-10-issue-65-grade-walks-every-segment/check_{off_branch,connector_share}.R`: the grade off
  the stream branch and the connector's share of the walked distance (Limits; #65's measurement);
- `scripts/0330`: `data/compare/*.csv` (`compare`, `change` and `checks`, composed over every key; log
  `scripts/logs/habitat/20261027_compare.txt`); `floodplain.csv` and `research/fig/compare_*.png` are #65's.

**Status:** measured; nothing applied in link. One file per species holds the species' reading of #73's run, which
neither #92 nor #145 revised, so where a pick or grade below differs from a species file, this file is the current one,
and its #145 section the newest:
`bull_trout_tuned.md`, `chinook_rearing_tuned.md` (#54's file, with the province-wide rescoring at its head),
`coho_rearing_tuned.md`, `grayling_rearing_tuned.md`, `rainbow_rearing_tuned.md`, `steelhead_rearing_tuned.md`,
`westslope_cutthroat_rearing_tuned.md`.

**In plain words.** link calls a stream segment rearing or spawning habitat for a species with a yes-or-no
test: big enough, and not too steep. This run asked, for each species and life stage the electrofishing record
can speak to, which version of that test best predicts where the fish were caught in watersheds held out of the
fit. For each one it tried a ladder of size floors (by flow or by width) and gradient limits, and, for small
streams, an allowance for a river close downstream. It scored every version on held-out watershed groups,
kept every version within one standard error of the best (a rule of thumb fixed before the run, not a
boundary of noise), and recommended the one of those closest to link's current test. Each version was scored on the
gradient of the link segment a fish was caught on, the one link applies its test to (#92). link's current test is not
among them for any species. On link's segments of its 2026-11-03 build (#145), with lines through wetlands put through
the same test as streams (link's `stream`), the picks draw less rearing habitat than its current test for four of the six
rearing keys (from 3 % less for coho to 25 % less for steelhead), more for grayling (11 %) and westslope cutthroat
(19 %), and a quarter more for bull trout spawning (24 %). Rainbow trout, which that build does not model, is retired. A
grade from 0 to 1 then gives the use to expect on each segment, read at that segment's own distance to a river (#65
corrected a first build that read most segments at the distance cap), and is published only where the curve behind it
predicts held-out groups better than no rule at all: for coho, westslope cutthroat and bull trout spawning it does not,
so they carry a rule and no grade. The package article on chinook rearing
(https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html) walks through one species from the
question to the map; the specification below is the record.

## The question

link's `default` draws habitat as on/off at a size floor and a gradient maximum per species and stage, set from
bcfishpass and the literature. #28 and #54 tuned two of those rules one species at a time, each with its own
build and its own scripts, on the 55 groups link had run. link's province-wide `default` run
(NewGraphEnvironment/link#246, `run_uid 20261017_004619-3f4c713b`, 241 groups) makes one build and one run
possible: which rule does the electrofishing evidence support for each species and stage, how far can each value
move before the data can tell, and what does a segment just inside or just outside a cut deserve?

## Evidence

FDIS electrofishing site visits (`fdis_export.md`), placed on link's segments: 51,587 visits, 49,928 placed on the
Atlas, 45,529 kept on a segment, one row per visit and species. Placement (#91): `scripts/0230` snaps each visit with
`fresh::frs_point_snap()` to the nearest stream and to the streams its 1:50k code names, keeps an unconfirmed pick to
200 m and a code-confirmed one to 500 m, and never lands on an unmapped, placeholder or watershed-group-boundary
connector (6010) line; `knw_link_place()` then takes link's segment at the visit's measure (`fdis_export.md`,
"Placement", has each drop and the comparison with #73's `fwa_indexpoint()` placement, which kept 40,552). bcfishobs plays no part in the snap, but link breaks its streams at bcfishobs observations
(`lnk_pipeline_break()`), 29 % of them FDIS's own for the twelve species codes link models (64,735 of 225,153; 44 % across
all species), so it shapes the segment a visit takes and where it starts. The row carries catch, size classes, presence and whether an absence is blocked by a code that
could hide the species (`knw_fdis_species()`). Each visit carries link's access code and habitat flags per
species (re-gated on `streams_access`; link#349's disagreement is ledgered per run), wet's annual flow by source
(`modelled_discharge.md`; the default, `pick`, is PCIC's VIC-GL runoff routed by Raven on PCIC's network on 86.7 % of
the kept visits and wet's water balance on 13.3 % (where routed does not reach, or carries under 0.2 of the balance on
the segment's own line), build `94deeb5`; routed flow reaches Atlas segments through the
PCIC crosswalk on the `newgraph` branch of NewGraphEnvironment/fwapg, fork PRs NewGraphEnvironment/fwapg#6, fwapg#10, fwapg#21, fwapg#26 and fwapg#32, which
upstream fwapg does not carry), the width link reads on an unmeasured stream, regulated reach, the natural barriers
downstream per species, and walks to the first river of 1–50 m³/s on each flow source, each ending at a double-line
river's bank (#73). Presence-only bcfishobs records never score a rule; `knw_bcfishobs_match()` ties 24,000 of them to
their FDIS visits by collection, species and date, and the rest give the outside check. The Fish Data Submission
workbooks add 871 placed sites, 92 of them with electrofishing effort.

### Which gradient is scored (#92)

**Verified:** 2026-10-27 on #91's evidence (`fresh_default_20261017`) · **Produced by:**
`data-raw/segment_gradient_check.R` (`scripts/logs/habitat/20261027_segment_gradient_check.txt`).

From #92, a visit is scored on its link segment's gradient (`segment_gradient`), the gradient link applies a rule to,
rather than on its whole Atlas line's (`fwa_gradient`), which is kept as a sensitivity. Al chose it on 2026-10-27,
after the two measurements below.

- **The segment at a visit depends on the catch.** link breaks streams at the bcfishobs observations of the species
  it models in each group, and a visit that caught one of them is usually such an observation, so its segment often
  starts at the visit and runs upstream to the next break. On the
  tuning's stream branch (29,335 visits), 86.2 % of visits that caught fish sit on such a segment, against 10.2 % of
  empty ones. The median segment is 113 m long for visits that caught fish and 305 m for empty ones. Per species, 80.7 %
  of the visits where chinook were present sit on such a segment, against 44.6 % where they were absent, and 94.2 %
  against 37.8 % for bull trout. Short segments read gradients further from the Atlas line's: on segments of 10 m or
  less, 13.5 % read 0 and the median gap is 0.015, against 0.0017 on segments over 500 m. By catch, though, the gap is
  the same (median 0.0083 for visits with fish and without, SD 0.077 and 0.078): the segment's length follows the
  outcome, and its gradient's departure from the Atlas line's does not, by any catch. By each species' own outcome it
  can: the median gap is smaller where the species was present for CO (0.0079 against 0.0115), GR (0.0023 against
  0.0043), ST (0.0086 against 0.0113) and WCT (0.0076 against 0.0164), and about equal for BT, CH and RB. The gradient class at one of `default`'s cut-offs differs between the two gradients on 7.8–12.1 % of
  visits.
- **link does not cut at `default`'s cut-offs.** `default` breaks at observations, gradient barriers, falls, definite
  barriers, habitat endpoints and crossings, and its gradient breaks come only from the access classes (15, 20, 25 and
  30 %). Over the schema's 9,997,708 stream-branch segments, the count in the half-point band below each rearing or
  spawning maximum is 0.99–1.03 times the count above it. The 15 % access class is 0.94, slightly more above than
  below. So segment gradients are not lined up with `default`'s rule.

Fixed-window gradients, which would not depend on where a catch cut the stream, are #70's (on fresh#257). They can
test whether the outcome-linked segment length moves a threshold.

## Method

The method is the methodology article, "Choosing habitat thresholds from where fish were caught"
(<https://newgraphenvironment.github.io/knowledge/articles/habitat_thresholds.html>, `vignettes/habitat_thresholds.Rmd`,
#93): every step, what it does and why, with each number that shapes a result in `inst/method/settings.csv`, where its
value lives and whether it has been tested. It replaced the specification that stood here. `scripts/0320`'s header
keeps the analysis spec beside the code. The parts each issue settled are named in that header and in the register's
`issue` column. From #92 the rules and curves read link's segment gradient ("Which gradient is scored", above).

## The run promoted on 2026-11-04 (#145)

**What changed.** link built a new provincial `default` network (run `20261103_163715-269b585a`, link 0.78.2, all 241
groups). Every key was retuned, graded and compared on it with wet's 2026-10-24 flows, and the run (`20261104_0543`)
was promoted. Each key scores the same visits as on #92's run (the same count, detections and groups for all seven), so
what moved is what those visits read: link's segments and the flow load. The network's share alone is measured against link's minimal network in
`minimal_network_tuning.md` ("The full network on the same flows and range"). The sections after this one are #92's run,
kept as that reading's record.

**Rainbow trout rearing is retired on this build.** link models neither rainbow trout nor kokanee here: their access
columns are empty on every segment, so no rule for them could be graded or applied. Rainbow trout's keys and kokanee
spawning are `not_modelled` (no fit, no grade; kokanee rearing keeps `no_stream_rule`), and rainbow trout rearing's
tables, comparison and maps left the published set. Its last rule,
`width>=3|g<=0.3|none`, is in git history and the bucket's archive.

**How to read a pick.** Each key keeps every rule within one standard error of the best (its region) and recommends
the one closest to link's `default`. A pick that moved from #92's to a rule both runs count in their regions is a
reshuffle of near-equal rules, not a new finding.

| species × stage | visits (detections), groups | recommended rule | region | `default` | pick holds in | #92's pick |
|---|---|---|---|---|---|---|
| BT rearing | 9,344 (1,281), 76 | MAD ≥ 0.1, ≤ 25 %, none | 176 rules: MAD 0.1–0.5, 11–30 % | out, +218.8 (SE 75.1) | 3 of 5 seeds | ≤ 30 % |
| BT spawning | 513 (108), 22 | width ≥ 2, ≤ 11 %, none | 140: width 1–3 or MAD 1, 11–30 % | out, +12.3 (SE 8.0) | 1 of 5 | ≤ 13 %, a ≥ 1 m³/s river within 500 m |
| CH rearing | 4,858 (234), 45 | MAD ≥ 0.75, ≤ 13 %, a ≥ 3 m³/s river within 1 km | 169: MAD 0.1–1, 7–30 %, every one with the exception | out, +252.6 (SE 96.7) | 5 of 5 | ≤ 11 % |
| CO rearing | 4,628 (1,211), 63 | MAD ≥ 0.1, ≤ 5.49 %, a ≥ 3 m³/s river within 2 km | 54: MAD 0.03–0.35, 3–9 % | out, +118.8 (SE 44.2) | 5 of 5 | the same |
| GR rearing | 1,355 (229), 27 | width ≥ 1.5, ≤ 5.49 %, none | 1,189: width 1–4, 3–30 % | out, +15.7 (SE 13.5) | 2 of 5 | width ≥ 2 |
| ST rearing | 1,530 (90), 11 | MAD ≥ 1, ≤ 8.49 %, a ≥ 1 m³/s river within 250 m | 265: MAD 0.15–1 or width 4, 3–30 % | out, +45.8 (SE 26.9) | 2 of 5 | the same |
| WCT rearing | 1,238 (577), 6 | MAD ≥ 0.03, ≤ 25 %, none | 56: MAD 0.03, 20–30 % | out, +50.9 (SE 33.5) | 5 of 5 | the same (underpowered) |
| RB rearing and spawning, KO spawning | — | — | — | — | — | not modelled on this build |
| CH, CM, CO, GR, PK, SK, ST, WCT spawning | — | — | — | — | — | no electrofishing response |
| CM, KO, PK, SK rearing | — | — | — | — | — | no stream rule in `default` |

- **Four picks moved, and three of the moves are more than a reshuffle.** Bull trout rearing's (limit 30 to 25 %) lies
  in #92's region (2.8 behind #92's best, SE 10.6), so the two runs cannot tell those rules apart. The other three new
  picks lie outside #92's region, so the runs disagree: bull trout spawning (limit 13 to 11 %, and the near-river
  exception dropped; 4.8 behind, SE 2.9), chinook rearing (11 to 13 %; 8.3 behind, SE 4.3) and grayling rearing
  (width 2 to 1.5 m; 10.0 behind, SE 5.5). Coho, steelhead and westslope cutthroat keep #92's rule. On the Atlas line's
  gradient (`data/tune/grad_fwa/`, never graded), all seven keys pick #92's sensitivity picks again.
- **`default` is still outside every region**, grayling's by the narrowest margin (1.16 SEs, against 2.87 on #92's).
- **Nested selection** (pick on four folds, score the fifth) beats `default` for BT rearing, CH and CO, and loses to
  it for GR (915.3 against 902.2) and ST (427.9 against 399.0), as on #92's; bull trout spawning's beats `default` on
  both runs (420.8 against 425.1; #92's 424.8 against 425.2). Two keys flip against the other references: bull trout spawning's
  choosing now beats no rule (420.8 against 424.6), where #92's did not, and westslope cutthroat's now loses to both
  `default` and no rule (1,446.5 against 1,442.6 and 1,431.3), where #92's beat both (1,428.1 against 1,444.9 and
  1,431.3).

### At 1.96 SE

| species × stage | `default` behind the best, in SEs | pick at 1 SE | pick at 1.96 SE | from link's flow start, at 1.96 SE | rules within 1 SE → 1.96 SE, of |
|---|---|---|---|---|---|
| BT rearing | 2.91 | MAD ≥ 0.1, ≤ 25 % | MAD ≥ 0.1, ≤ 10.49 % | the same as from the width start | 176 → 1,446, of 8,385 |
| BT spawning | 1.53 | width ≥ 2, ≤ 11 % | `default` | MAD ≥ 0.041, ≤ 5.49 % | 140 → 7,021, of 7,095 |
| CH rearing | 2.61 | MAD ≥ 0.75, ≤ 13 %, Q3 within 1 km | the same as at 1 SE | MAD ≥ 0.28, ≤ 13 %, the same exception | 169 → 2,297, of 6,149 |
| CO rearing | 2.69 | MAD ≥ 0.1, ≤ 5.49 %, Q3 within 2 km | width ≥ 1.5, ≤ 5.49 %, Q1 within 500 m | MAD ≥ 0.03, ≤ 3 % | 54 → 1,296, of 6,622 |
| GR rearing | 1.16 | width ≥ 1.5, ≤ 5.49 % | `default` (width ≥ 1.5, ≤ 3.49 %) | MAD ≥ 0.021, ≤ 3.49 % | 1,189 → 6,680, of 7,740 |
| ST rearing | 1.70 | MAD ≥ 1, ≤ 8.49 %, Q1 within 250 m | `default` | MAD ≥ 0.02, ≤ 8.49 % | 265 → 6,678, of 7,224 |
| WCT rearing | 1.52 | MAD ≥ 0.03, ≤ 25 % | `default` | MAD ≥ 0.03, ≤ 8.49 % | 56 → 7,211, of 7,224 |

Four of seven keep `default` at 1.96 (BT spawning, GR, ST and WCT), each with a 1.96 region holding most of the grid,
so the stricter bar cannot separate the rules there. Chinook's pick does not move at 1.96; bull trout rearing's goes
back to `default`'s 10.49 % limit with its flow floor, and coho's to `default`'s width and limit with a nearer
exception. `knw_tune_repick()` on `data/tune/<key>_tune.csv` gives every cell; the run writes the picks to each
summary as `rule_recommended_196` and `rule_recommended_flow_196`.

### Grades

The grade is published only where the curve behind it predicts held-out groups better than no rule at all. Four keys
pass that gate: BT rearing (the curve 6,039.3 against 6,414.8 for no rule, on the curve's own visits), CH (1,159.9
against 1,502.6), GR (808.3 against 822.6) and ST (398.7 against 432.7). Three carry a rule and no grade: CO (4,474.9
against 4,416.8) and WCT (1,536.7 against 1,430.4), as on #92's, and now BT spawning (404.4 against 403.9; #92's passed
by 8.0). Each key's grade log is in `scripts/logs/habitat/20261104_tune_run-20261104_0543-p20261104054300.txt`.

### On link's segments

Both rules regenerated through link's steps on every group the species' habitat table covers (`data/compare/`, the
`door` structure for lines through wetlands; log `scripts/logs/habitat/20261104_compare-20261104_0543.txt`):

| species × stage | accessible km | `default` km | tuned km | change | lost | gained (by the exception) | graded km, `default` → tuned |
|---|---|---|---|---|---|---|---|
| BT rearing | 583,183 | 246,739 | 188,769 | −23.5 % | 70,439 | 12,469 (0) | 113,589 → 105,988 |
| BT spawning | 583,183 | 134,366 | 166,401 | +23.8 % | 0 | 32,035 (0) | no grade |
| CH rearing | 233,629 | 102,951 | 88,458 | −14.1 % | 30,698 | 16,205 (13,383) | 52,727 → 58,905 |
| CO rearing | 168,080 | 89,887 | 87,009 | −3.2 % | 10,790 | 7,912 (5,615) | no grade |
| GR rearing | 258,519 | 77,786 | 86,398 | +11.1 % | 325 | 8,937 (0) | 44,907 → 49,445 |
| ST rearing | 180,033 | 83,588 | 63,015 | −24.6 % | 26,809 | 6,236 (5,817) | 42,943 → 41,967 |
| WCT rearing | 35,246 | 20,478 | 24,398 | +19.1 % | 907 | 4,827 (0) | no grade |

- **Bull trout spawning now draws a quarter more, not half as much again** (+23.8 % against #92's +49.5 %): its
  limit fell from 13 to 11 % and it lost the exception. Chinook draws 14.1 % less (−15.9 % on #92's). Grayling's rule
  adds 11.1 % through its slope limit (5.49 % against `default`'s 3.49 %, with the same 1.5 m width); #92's added 3.4 %
  with a 2 m width floor.
- **FDIS detection** on each rule's habitat against accessible stream outside it, `default` then tuned: BT rearing
  16.9 % against 6.5 %, then 19.8 against 5.6; CH 14.4 against 2.3, then 17.6 against 1.3; CO 29.4 against 11.9, then
  33.2 against 8.9; GR 15.1 against 5.2, then 14.8 against 4.2; ST 4.6 against 0.5, then 6.7 against 0.3; WCT 31.6
  against 24.3, then 30.9 against 19.0. These visits overlap the ones scored, so this is consistency, not a test.
- **The bcfishobs records FDIS does not hold** (never scored), as records per km of each rule's habitat over its share
  of accessible km, rise under the tuned rules for BT rearing (2.45 → 3.88), CH (2.48 → 3.09), CO (1.78 → 1.88) and ST
  (2.22 → 2.83); are level for BT spawning (3.04 → 3.05); and fall for GR (3.54 → 3.22) and WCT (1.55 → 1.47), whose
  rules add km that hold fewer records per km. The ratio rewards a rule for drawing less, so it is not a claim about
  extent (`data/compare/checks.csv`).
- The maps and the floodplain table were not redrawn, as for #73 and #92 (#65's, below); the promotion removed
  rainbow trout rearing's maps and rows.

## Results (#92's run, 2026-10-27)

| species × stage | visits (detections), groups | recommended rule | region | `default` | pick holds in | power |
|---|---|---|---|---|---|---|
| BT rearing | 9,344 (1,281), 76 | MAD ≥ 0.1, ≤ 30 %, none | 161 rules: MAD 0.1–0.5, 11–30 %, with or without the exception | out, +227.3 (SE 76.9) | 4 of 5 seeds | fitted |
| BT spawning | 513 (108), 22 | width ≥ 2, ≤ 13 %, a ≥ 1 m³/s river within 500 m | 36: MAD 1 or width 1.5–2, 11–30 %, Q 1, D 0.1–1 km | out, +11.4 (SE 7.5) | 3 of 5 | fitted, **weak** |
| CH rearing | 4,858 (234), 45 | MAD ≥ 0.75, ≤ 11 %, a ≥ 3 m³/s river within 1 km | 164: MAD 0.1–1, 7–30 %, Q 1–10, D 1–5 km | out, +242.7 (SE 98.9) | 4 of 5 | fitted |
| CO rearing | 4,628 (1,211), 63 | MAD ≥ 0.1, ≤ 5.49 %, a ≥ 3 m³/s river within 2 km | 38: MAD 0.03–0.35, 3–9 %, Q 1–10, D 0.5–5 km | out, +115.5 (SE 43.8) | 5 of 5 | fitted |
| GR rearing | 1,355 (229), 27 | width ≥ 2, ≤ 5.49 %, none | 1,656: MAD 0.021 or width 1–4, 4–30 %, with or without the exception | out, +19.3 (SE 6.7) | 1 of 5 | fitted |
| RB rearing | 13,869 (3,740), 132 | width ≥ 3, ≤ 30 %, none | 29: width 2–3, 13–30 %, with or without the exception | out, +293.4 (SE 94.6) | 5 of 5 | fitted |
| ST rearing | 1,530 (90), 11 | MAD ≥ 1, ≤ 8.49 %, a ≥ 1 m³/s river within 250 m | 425: MAD 0.15–1 or width 2–4, 3–30 %, with or without the exception | out, +45.1 (SE 27.6) | 2 of 5 | fitted |
| WCT rearing | 1,238 (577), 6 | MAD ≥ 0.03, ≤ 25 %, none | 97: MAD 0.03, 11–30 %, with or without the exception | out, +52.1 (SE 32.1) | 5 of 5 | underpowered |
| CH, CO, GR, RB, ST, WCT spawning | — | — | — | — | — | no electrofishing response |
| KO, SK rearing; CM, PK | — | — | — | — | — | no stream rule in `default` |

Every row is #92's (scored and graded 2026-10-27 on #91's evidence, `fresh_default_20261017`, each visit read on its
link segment's gradient; the same grids as #73's: 8,385, 7,095, 6,149, 6,622, 7,740, 7,740, 7,224 and 7,224 rules).
The visits rose with #91's placement (45,529 kept against 40,552). "Pick holds in" counts the main seed and the extra
fold seeds whose recommendation is this exact rule; a seed that recommends a neighbour (the same floor at another
limit) is not counted. Against #73's picks, RB's is unchanged; CH's limit falls from 13 to 11 % and WCT's from 30 to
25 %; BT spawning and ST gain an exception; BT rearing's floor falls from 0.35 to 0.1 m³/s at 30 % rather than 25 %;
coho's moves from MAD ≥ 0.03 at 4 % to MAD ≥ 0.1 at 5.49 % with an exception; and grayling's moves off `default`.

Four readings across the table:
1. **`default` is outside the one-SE region for every key**, grayling's now included (2.87 SEs behind the best, where
   #73 found it inside). For BT rearing, CH, CO, ST and WCT the evidence prefers sizing streams by flow (a MAD floor)
   to `default`'s 1.5 m width; GR and RB keep width and raise it, to 2 m and 3 m, and BT spawning keeps `default`'s
   2 m. The flow floors run from 0.03 m³/s (WCT) and 0.1 (BT rearing, CO) to 0.75 (CH) and 1 (ST).
2. **The gradient limit moves up for six keys and stays for two:** up from `default`'s to 30 % for BT rearing and RB,
   25 % for WCT, 13 % for BT spawning, 11 % for CH and 5.49 % for GR; unchanged for CO (5.49 %) and ST (8.49 %). Where
   the limit is at or next to the ladder's top (BT rearing, RB, WCT), the region runs from 11 or 13 % to 30 %, so the
   data say that a limit near `default`'s costs and do not say where the limit is; none of those three is a claim that
   the species rears on 30 % slopes.
3. **Four picks carry the near-a-river exception**: CH (as in #73), CO, ST and BT spawning. In the regions of BT
   rearing, GR, RB, ST and WCT, rules with and without it sit together, so for those keys the exception is a tie-break,
   not a finding.
4. **Two rows are thin, one is weak and one underpowered:** ST (90 detections, 11 groups) and BT spawning (108
   detections, 22 groups) are thin. BT spawning is weak: nested selection, which picks on four folds and scores the
   fifth, sums to 424.8 against 424.6 for no rule (and 425.2 for `default`). WCT has 6 groups (`underpowered`). Nested
   selection also puts GR's choosing behind `default` (916.9 against 904.3) and behind no rule (906.4), and ST's
   behind `default` (416.3 against 403.0) though ahead of no rule (439.2): for both, the choosing on four folds does
   worse on the fifth than `default` does. Their picks stand as the grid's reading; what each can claim is in its
   species file, which is #73's.

### Which gradient: the regions under the Atlas line's (#92's run)

`GRADIENT=fwa_gradient` reruns the scoring on the main fold seed with each visit read on its whole Atlas line's
gradient, as #73 did (`data/tune/grad_fwa/`, log `scripts/logs/habitat/20261027_tune_run-grad_fwa.txt`; no grades).
The limits in each one-SE region, and each pick:

| species × stage | segment gradient (the main reading): pick; limits in the region | Atlas line's gradient: pick; limits in the region |
|---|---|---|
| BT rearing | MAD ≥ 0.1, ≤ 30 %; 11, 13, 13.49, 15, 20, 25, 30 % | MAD ≥ 0.1, ≤ 25 %; 20, 25, 30 % |
| BT spawning | width ≥ 2, ≤ 13 %, Q1 within 500 m; 11, 13, 15, 20, 25, 30 % | width ≥ 2, ≤ 13 %, none; 11, 13, 15, 20, 25, 30 % |
| CH rearing | MAD ≥ 0.75, ≤ 11 %, Q3 within 1 km; 7, 9, 11, 13, 15, 20, 25, 30 % | MAD ≥ 0.75, ≤ 15 %, Q3 within 1 km; 7, 9, 11, 13, 15, 20, 25, 30 % |
| CO rearing | MAD ≥ 0.1, ≤ 5.49 %, Q3 within 2 km; 3, 4, 5.49, 7, 9 % | MAD ≥ 0.1, ≤ 4 %, Q3 within 2 km; 3, 4, 7, 11, 20, 25, 30 % |
| GR rearing | width ≥ 2, ≤ 5.49 %; 4, 5.49, 7, 9, 11, 13, 15, 20, 25, 30 % | width ≥ 1.5, ≤ 5.49 %; 3, 3.49, 5.49, 7, 9, 11, 13, 15, 20, 25, 30 % |
| RB rearing | width ≥ 3, ≤ 30 %; 13, 15, 20, 25, 30 % | width ≥ 3, ≤ 30 %; 20, 30 % |
| ST rearing | MAD ≥ 1, ≤ 8.49 %, Q1 within 250 m; every limit from 3 to 30 % | MAD ≥ 1, ≤ 8.49 %, none; every limit from 3 to 30 % |
| WCT rearing | MAD ≥ 0.03, ≤ 25 %; 11, 13, 15, 20, 25, 30 % | MAD ≥ 0.03, ≤ 30 %; 3, 4, 5.49, 7, 13, 15, 20, 25, 30 % |

The size floor of every pick but grayling's is the same under both gradients, and so is RB's whole rule. The limits
move within each other's regions: every pick's limit under one gradient is inside the other's region, except coho's
5.49 %, which the Atlas gradient's region skips (it holds 4 and 7 %). The exception comes and goes with the gradient for
BT spawning and ST: under the Atlas gradient both regions hold rules with and without it (BT spawning 639 with, 8
without), and both picks are without it. So the gradient read moves
which neighbour is picked and leaves the regions overlapping; it does not move a floor, except grayling's between
1.5 and 2 m, both inside each other's region.

### At 1.96 SE (#79, 2026-10-20; replayed on #92's tables 2026-10-27; #145's table is above)

One standard error is a rule of thumb, not a test. Its sources are Breiman et al. 1984, who proposed it for pruning trees, as cited in Chen & Yang 2021, §1.3, since no copy is held; Hastie, Tibshirani & Friedman 2009, pp. 61 and 244, whose only rationale is that the curve "is estimated with error, and hence takes a conservative approach". Chen & Yang (2021, §6) find "no evidence
confirming that the 1se rule can consistently outperform the regular CV", with an SE that can be off by 100 % either
way; no unbiased estimator of K-fold cross-validation's variance exists (Bengio & Grandvalet 2004), and the usual
estimate is too small (Bates, Hastie & Tibshirani 2024). The threshold was fixed before the run and is kept. The pick at
1.96 SE is read from the same tables (`knw_tune_repick()` on `data/tune/<sp>_<stage>_tune.csv`; the run writes it to
each key's summary as `rule_recommended_196`, and from link's flow start as `rule_recommended_flow_196`):

| species × stage | `default` behind the best, in SEs | pick at 1 SE | pick at 1.96 SE | from link's flow start, at 1.96 SE | rules within 1 SE → 1.96 SE, of |
|---|---|---|---|---|---|
| BT rearing | 2.96 | MAD ≥ 0.1, ≤ 30 % | MAD ≥ 0.15, ≤ 10.49 % | the same as from the width start | 161 → 1,340, of 8,385 |
| BT spawning | 1.52 | width ≥ 2, ≤ 13 %, Q1 within 500 m | `default` | MAD ≥ 0.041, ≤ 5.49 % | 36 → 7,051, of 7,095 |
| CH rearing | 2.45 | MAD ≥ 0.75, ≤ 11 %, Q3 within 1 km | MAD ≥ 0.75, ≤ 5.49 %, the same exception | MAD ≥ 0.28, ≤ 5.49 %, the same exception | 164 → 2,456, of 6,149 |
| CO rearing | 2.64 | MAD ≥ 0.1, ≤ 5.49 %, Q3 within 2 km | width ≥ 1.5, ≤ 5.49 %, Q1 within 1 km | MAD ≥ 0.03, ≤ 5.49 %, Q1 within 1 km | 38 → 1,570, of 6,622 |
| GR rearing | 2.87 | width ≥ 2, ≤ 5.49 % | width ≥ 1.5, ≤ 5.49 % | MAD ≥ 0.021, ≤ 5.49 % | 1,656 → 2,612, of 7,740 |
| RB rearing | 3.10 | width ≥ 3, ≤ 30 % | width ≥ 2, ≤ 8.49 % | the same as from the width start | 29 → 263, of 7,740 |
| ST rearing | 1.63 | MAD ≥ 1, ≤ 8.49 %, Q1 within 250 m | `default` | MAD ≥ 0.02, ≤ 8.49 % | 425 → 6,627, of 7,224 |
| WCT rearing | 1.62 | MAD ≥ 0.03, ≤ 25 % | `default` | MAD ≥ 0.03, ≤ 8.49 % | 97 → 7,192, of 7,224 |

- **Three of eight keep `default` at 1.96** (BT spawning, ST and WCT), and for each the 1.96 region holds over 90 %
  of the grid, so keeping `default` there says the stricter bar cannot separate the rules, not that the records
  support `default`. Five move off it, and every one of them moves back toward it: BT rearing keeps a flow floor at
  `default`'s 10.49 %; CH keeps its floor and exception at `default`'s 5.49 %; CO goes back to width 1.5 m at 5.49 %,
  `default`'s own size and limit, with a 1 km exception; GR keeps `default`'s 1.5 m width at 5.49 %; RB keeps width at
  2 m and 8.49 %, `default`'s limit. `default` itself is outside at 1.96 for all five (2.45 to 3.10 SEs behind).
- **From link's flow start** (#80: `default`'s width floor written as the MAD it stands for), the 1.96 pick keeps a
  flow floor for every key but RB, whose pick is the width start's, and `default`'s gradient limit for every key but GR
  (5.49 % against 3.49).
- `data/thresholds.csv` carries the 1.96 pick per rule as `rule_196`, and per component whether it keeps the value
  as `holds_196` (a size row also needs the same size variable). A component equal to `default`'s value holds
  trivially, and a MAD row's `link_parameter` is not what a width rule at 1.96 would set.

**CH's open floor (#54) stays at 0.75 m³/s**, the best rule's and the pick's at 1 and 1.96 SE, with the region's
floors running from 0.1 to 1.

## Grades (#92's run)

| species × stage | segments (groups) | accessible km | graded km | grade-weighted km | reference rate | km under 0.2 | km at 0.8–1 |
|---|---|---|---|---|---|---|---|
| BT rearing | 8.41 M (158) | 576,908 | 571,305 | 171,195 | 0.216 | 56 % | 11 % |
| BT spawning | 8.41 M (158) | 576,908 | 319,633 | 195,932 | 0.218 | 0 % | 9 % |
| CH rearing | 5.76 M (125) | 225,152 | 224,459 | 64,010 | 0.139 | 67 % | 22 % |
| CO rearing | 4.92 M (100) | 147,795 | withheld: curve 4,483.9 against 4,416.8 for no rule | | | | |
| GR rearing | 4.21 M (82) | 258,576 | 146,128 | 72,906 | 0.097 | 22 % | 24 % |
| RB rearing | 10.33 M (210) | 509,975 | 277,539 | 128,015 | 0.412 | 27 % | 19 % |
| ST rearing | 4.14 M (79) | 155,357 | 154,855 | 43,915 | 0.139 | 59 % | 17 % |
| WCT rearing | 1.19 M (16) | 35,285 | withheld: curve 1,533.4 against 1,430.4 for no rule | | | | |

Every row is #92's grade of 2026-10-27: each accessible segment walked to the river's bank and read on the flows wet
republished on 2026-10-19 (wet `94deeb5`, the load #73 graded on), the reference over edge types 1000, 1100, 2000 and
2300, the curve fitted with the grid's prior (`curve_prior_sd` 2.5) on the segment gradient, and the gate comparing the
curve's held-out deviance with no rule's on the curve's own visits. Six keys pass it, by BT rearing 378.9, CH 335.0,
RB 761.9, ST 32.8, GR 14.2 and BT spawning 8.0; coho's curve is 67.1 behind no rule and WCT's 103.0, so both are
withheld. Against #73, steelhead (its curve was 140 behind) and BT spawning (19.4 behind) now pass, and coho and WCT are
still withheld. BT spawning's margin is the smallest, and its grade sits on a thin row (108 detections) whose nested
selection is behind no rule (Results, reading 4); 1,177 of its 319,633 graded km (0.4 %) grade under 0.2.

A width rule grades only measured streams: fwapg models width where `stream_order > 1`, so GR and RB leave every
unmeasured first-order stream `NA` (RB: 6.26 M of 10.33 M segments; GR: 2.62 M of 4.21 M), as BT spawning's table
does (5.10 M of 8.41 M with no width). A MAD rule grades almost everything (BT rearing: 33,992 segments
with no flow even from a parent). Against #73's grades the references move with the pick and the gradient: BT rearing
0.221 → 0.216, CH 0.146 → 0.139, GR 0.081 → 0.097, RB 0.448 → 0.412.

Revised 2026-10-19 (#65). #57's grades read every segment the exception could not admit at the 50 km distance
cap, and six of the eight keys walked no segment at all; every segment now reads its own distance, and the
reference is the stream branch's 95th percentile. The regrade also read the flows wet republished on
2026-10-19 (NewGraphEnvironment/wet#103, about ±5 % on most segments), after the thresholds had been tuned on the load
before it; #73 retuned on them.

## What each rule changes on link's segments (#92's run)

`scripts/0330` regenerates `default` and the tuned rule through fresh's predicate, the user-habitat overlay and
connectivity on scratch copies of every group the species' habitat table covers (`knw_compare_rules()`; the
regenerated `default` equals fresh's own predicate on every segment), and reads the grade beside each segment.
Kilometres are accessible stream under `streams_access`, flagged rearing or spawning by each rule; graded km is
km × grade (`data/compare/compare.csv`, `change.csv`, `checks.csv`; totals are each key's `ALL` row). Every row is
#92's, against link 0.68.3's `default` (`configs/default` at `102762da`, read on the archived schema
`fresh_default_20261017`; log `scripts/logs/habitat/20261027_compare.txt`), and under the structure each species file
records for through-wetland lines (edge 1050/1150, link#364): `door` for every key, link's `stream`, which puts those
lines through the gradient and size test. The free pass, the structure the rules were scored under, draws more for
every rule that has a size floor (BT rearing 198,792 km, CH 91,201, CO 80,949, RB 194,307, ST 55,156, WCT 24,498; GR
and BT spawning, whose `default` has no through-wetland rule, have one structure). CH, CO and ST, whose tuned rules
carry the exception, have a third, `door_wetland`, the exception on through-wetland lines only (CH 66,698 km, CO
71,101, ST 41,954). The figures for `free` and `door_wetland` here and in the species files are #92's, which ran every
structure; since #112 `0330` compares `default` and `door` alone unless `STRUCTURES=all`, so a later run refreshes them
only on that setting.

| species × stage | accessible km | `default` km | tuned km | change | lost | gained | graded km, `default` → tuned |
|---|---|---|---|---|---|---|---|
| BT rearing | 576,908 | 244,328 | 186,367 | −23.7 % | 69,699 | 11,737 | 118,421 → 109,826 |
| BT spawning | 576,908 | 133,382 | 199,364 | +49.5 % | 0 | 65,982 | 76,138 → 103,802 |
| CH rearing | 225,152 | 99,186 | 83,435 | −15.9 % | 30,477 | 14,726 | 50,081 → 55,654 |
| CO rearing | 147,795 | 79,829 | 77,964 | −2.3 % | 9,205 | 7,341 | no grade |
| GR rearing | 258,576 | 77,740 | 80,352 | +3.4 % | 4,610 | 7,223 | 44,868 → 47,766 |
| RB rearing | 509,975 | 219,156 | 180,951 | −17.4 % | 49,797 | 11,593 | 108,312 → 99,609 |
| ST rearing | 155,357 | 70,980 | 51,803 | −27.0 % | 24,556 | 5,379 | 35,925 → 34,619 |
| WCT rearing | 35,285 | 20,632 | 24,355 | +18.0 % | 913 | 4,636 | no grade |

1. **Five tuned rearing rules draw less than `default`**, from 2.3 % less for coho to 23.7 % less for bull trout and
   27.0 % for steelhead; grayling's draws 3.4 % more, westslope cutthroat's 18.0 % more, and bull trout spawning's
   49.5 % more. The loss is the size floor: segments that pass `default`'s width test and fail the tuned floor with no
   exception (BT rearing 61,172 of its 69,699 km lost, RB 44,368 of 49,797, CH 24,250 of 30,477, ST 21,562 of 24,556,
   CO 7,562 of 9,205, GR 4,351 of 4,610), with through-wetland lines that pass `default`'s door and fail the tuned one
   next (BT rearing 8,114 km, CH 6,127, RB 5,429, ST 2,833, CO 1,577).
2. **The gains are the exception, the gradient limits and the flow floors.** The exception adds 29,973 km for BT
   spawning, 12,221 for CH, 5,184 for CO and 5,037 for ST, most of it on order-1 streams (BT spawning 21,036 of the
   29,948 km `change.csv` puts to the exception, CH 7,974 of 11,560, CO 4,104 of 4,851, ST 4,205 of 4,912), and 41 km of
   it, or less, through a river in another group for every key. The raised limits add 35,500 km of stream between 5.49 and
   13 % for BT spawning (its rule contains `default`: the same 2 m width, nothing lost; 380 km of that gain is order 1),
   11,402 for RB, 6,836 for BT rearing, 6,528 for GR, 3,037 for WCT and 1,708 for CH. A flow floor admits streams
   `default`'s width test fails: 3,280 km for BT rearing, 1,986 for CO, 1,157 for WCT. Connectivity and the overlay
   move under 1,400 km for every key.
3. **Graded km falls with km for bull trout rearing, rainbow and steelhead, and rises for chinook, grayling and bull
   trout spawning.** Chinook's tuned 83,435 km carry 55,654 graded km against `default`'s 50,081 on 99,186, the rule
   trading small low-grade streams for the near-river exception: its 0–0.2 class falls from 42,073 to 16,848 km and its
   0.8–1 class rises from 41,052 to 44,912. Bull trout rearing's rule sheds the grade's low end the same way (0–0.2
   56,198 → 30,151 km; 0.8–1 57,723 → 61,710). The grade is fitted on the same visits, so this is consistency, not a
   check.
4. **Checks** (`checks.csv`). FDIS detection on each rule's segments against accessible segments outside it,
   `default` then tuned (`door`): RB 33.7 % against 15.3 %, then 34.8 against 16.6; BT rearing 16.9 against 6.5, then
   19.8 against 5.6; CH 14.9 against 2.2, then 18.4 against 1.4; CO 30.1 against 13.1, then 33.5 against 10.1; GR 15.1
   against 5.3, then 15.0 against 4.6; ST 5.1 against 0.6, then 7.4 against 0.3; WCT 31.8 against 23.7, then 30.9
   against 20.0. On the bcfishobs records FDIS does not hold (A/B matches, presence only, never scored), the share of
   their locations on accessible stream edges that falls on the rule's segments, over the rule's share of accessible
   stream-edge km, rises under five tuned rules: RB 2.34 → 3.03, BT rearing 2.45 → 3.90, CH 2.46 → 3.15, CO 1.75 →
   1.82, ST 2.19 → 2.81. It is level for GR (3.56 → 3.64, +0.08, interval −0.01 to +0.22) and falls for BT spawning
   (3.04 → 2.51, −0.53, −0.64 to −0.43) and WCT (1.56 → 1.45, −0.11, −0.15 to −0.07): the km those two rules add hold
   fewer records per km than `default`'s. The ratio rewards a rule for drawing less, so it is not a claim about extent.
   `free` and `door` differ by under 0.01 in the ratio and by under 1 point in either FDIS share for every key.
   `door_wetland` reads a higher ratio for CH (4.32), CO (2.11) and ST (4.08), as a narrower rule does, and for CH and
   CO leaves more FDIS detections outside it than that spread (2.6 % against `door`'s 1.4, 11.7 against 10.1; ST 0.6
   against 0.3, within it), so for those two the checks point opposite ways; the structure is link's call.

**Maps and the floodplain table were not redrawn for #73 or #92** (`0330 STAGE=maps`); both are #65's, on the run's own configs
and the picks of 2026-10-19 (`width>=3|g<=0.09` for RB, `mad>=0.35|g<=0.1049` for BT rearing, and so on), and are kept
here as the record of that reading.

**Maps.** `research/fig/compare_<sp>_<stage>_<wsg>.png` for every floodplain-catalog group the species covers and
three groups per species chosen by criteria fixed before drawing (largest gained share, largest lost share, most
`default` km): habitat by rule (kept, lost, gained), grade class, and the floodplain shaded by its segment's grade.
`data/compare/maps/` holds the interactive pages (ignored). `data/compare/gpkg/<key>.gpkg` (ignored) is #92's view
of each comparison for QGIS (#81).

**Floodplain as a unit** (`data/compare/floodplain.csv`, #65). For the 23 groups whose whole-network floodplain the
stac-floodplains-bc catalog holds (`<wsg>_all_ff04`; NewGraphEnvironment/floodplains#123 for the rest),
`knw_floodplain_ha()` gives every 30 m floodplain cell one owning segment, the nearest among the claiming blue
lines' segments through `flooded::fl_valley_join()`, and sums hectares beside each rule's habitat; graded ha is
ha × the owning segment's grade. Hectares beside accessible stream are the group's whole accessible floodplain.

| species × stage | catalog groups | ha beside accessible stream | beside `default` habitat | beside tuned | change | graded ha, `default` → tuned |
|---|---|---|---|---|---|---|
| RB rearing | 23 | 781,723 | 663,464 | 560,759 | −15 % | 273,535 → 243,741 |
| BT rearing | 22 | 894,237 | 746,145 | 565,706 | −24 % | 260,172 → 216,596 |
| BT spawning | 22 | 894,237 | 354,423 | 275,002 | −22 % | 253,726 → 199,664 |
| CH rearing | 16 | 588,216 | 426,681 | 340,929 | −20 % | 206,011 → 207,639 |
| CO rearing | 10 | 329,838 | 272,429 | 242,163 | −11 % | 168,866 → 158,795 |
| GR rearing | 3 | 137,000 | 96,530 | 96,530 | 0 | 32,386 → 32,386 |
| ST rearing | 4 | 143,349 | 108,807 | 74,948 | −31 % | 35,822 → 34,802 |
| WCT rearing | 4 | 129,911 | 122,584 | 117,691 | −4 % | 89,778 → 85,858 |

Set against the km on the same catalog groups on #65's run, the floodplain fell less than the km for BT rearing (24 %
against 37 %), CO (11 against 14), RB (15 against 20), ST (31 against 45) and WCT (4 against 24): the streams those
rules dropped carried less floodplain per km than the habitat `default` draws. For CH (20 against 19) and BT spawning
(22 against 19) the two fell about together. Graded ha followed graded km, rising only for CH. (Revised 2026-10-18,
#62: this paragraph first compared catalog-group floodplain with all-group km. Revised 2026-10-19, #65: graded km and
ha are from the regrade, every segment at its own distance and the reference over the stream branch, on the flows wet
republished that day. The flow republish also moved each MAD rule's habitat by under 0.3 % (BT spawning −231 km, CH
+34, ST +60, BT rearing −49, CO −9); every moved verdict is a segment whose flow crossed the floor or whose exception
distance crossed its limit, or a connectivity cascade from one. Width rules did not move.) #92's picks differ from #65's for
every key, so no row describes the recommended rule.

## Limits

- **Juveniles, electrofished, on the stream branch.** Spawning has a response for char only, and that one is weak.
  River polygons, wetlands and lakes keep `default`'s tests under every rule.
- **The score rewards separation, not extent** (as #54 said): the tuned rules are narrower than `default` where
  the floor moves up.
- **Thin rows, and the rows with no grade.** ST (90 detections, 11 groups) and WCT (6 groups) carry their labels;
  BT spawning should not be applied. CO and WCT publish a rule and no grade: their curves predict held-out groups
  worse than one constant rate on the visits they were fitted to, so they could not rank segments. ST and BT spawning
  pass that gate on #92's run by 32.8 and 8.0, where on #73's they failed it; #73's measurement of steelhead's curve
  (`steelhead_rearing_tuned.md`: the joint smooth overfit one group holding a third of its detections) has not been
  repeated on #92's.
- **The grade off the stream branch is an extrapolation.** The curve was fitted on stream-branch visits
  outside lakes, wetlands and river polygons; a river-polygon segment often reads it at 0 m from the river it is
  part of (48 % of river-polygon km within 1 m for GR, 79 % for CH on #65's grades) and at flows few visits had, so its
  grade rests on the surface past its data: on #73's grades, CH's river-polygon lines are 43,497 of its 224,459 graded
  km and 31,542 of them grade 0.8 or more, against 9,684 of the stream branch's 147,668. Main-flow lines through lakes
  and wetlands (edge type 1200) read their river within 1 m on 10–18 % of their graded km (WCT 62 %), and 4–34 % of
  their km grades 0.8 or more (WCT 79 %); off the stream branch is 24–36 % of each key's graded km and 21–79 % of its
  km at 0.8 or more (#65's measurement, `check_off_branch.txt` in its archive, not repeated for #73), so
  `habitat_grade/v1` carries `stream_branch` to say which segments the curve's visits support. The reference is taken
  over the stream branch so that river polygons do not set it: over every accessible segment, they would make up
  66–89 % of the top 5 % for CH, CO, ST and WCT and raise the reference 1.4 to 4 times (CH's from 0.14 to 0.52, leaving
  0.4 % of stream km at 0.8 or more); for BT, GR and RB they are 19–34 % of it and the two references are within 7 %
  (#65).
- **Distance is to the river's bank (#73).** The walk (`inst/sql/ch_dist_profile.sql`) ends where a tributary meets a
  double-line river, by fresh 0.42.0's rule: a connector inside the river's polygon (edge type 1400/1450) is never a
  target, the connector run and the jump's crossing inside the target's polygon are left out, and every other hop's
  gap counts. Checked against fresh's own walk on BULK (`data-raw/walk_bank_check.R`, 2,460 starts): 0 differ by the
  bank rule, 92.6 % of the 2,006 starts both walks found agree within 0.01 m, and the rest are the two walks' entry
  conventions. The correction is positive on 67 % of found starts, median 31.8 m, 90th percentile 66.1 m, largest
  599 m (#65 had estimated the connector at a median of 14–88 m). A distance of 0 still occurs where the segment is
  itself a river-polygon line or sits at the bank (within 1 m of it, BT rearing 53,897 km, CH 51,257; at exactly 0, 31,109 and
  30,027), where the curve is read past its data. #65's measurement of the centreline walk is in its archive (`check_connector_share.txt`).
- **Width rules leave first-order streams ungraded**; a consumer summing graded km over a width-ruled species
  (GR, RB) sums measured streams only.
- **One link run, one flow load.** Every grade carries `run_uid 20261017_004619-3f4c713b`; link recomputed UPET twice
  after the waiter released and before the build read, and the build's UPET visits place identically on the result.
  Every grade table records the flow load it was read on (wet `94deeb5`, built 2026-10-19), and `0325` refuses to
  publish when the live table's comment names another; the schema the run read is the archived
  `fresh_default_20261017` (link#361 renamed it while #73 ran).
- **The access gate.** Grades and the comparison are gated on `streams_access`; link's `accessible` disagrees on
  1.6–3.5 % of habitat-accessible segments for most species, 17 % for RB and 90 % for KO (link#349), ledgered per
  run. For RB the disagreement is whole groups: in 23 of its 210 groups (BRID CANO CARP CLRH CRKD FINA FINL FIRE
  FOXR INGR LEUT LOMI MAHD MESI MURT NATR OSPK PARA PARS PCEA TURN UEUT UOMI; 37,895 km of stored rearing) every
  segment has `access_rb = 0`, and two more (TOOD, UNRS) draw no km under `default`, so 25 groups carry no graded and
  no compared RB km; GR has three groups with no km (BULL ELKR TURN) and BT one (TURN).
- **Regenerated, not stored.** The comparison's `default` is fresh's predicate rerun, which differs from the flags
  link stores by 55,242 km for RB, 9,243 for BT rearing, 2,942 for CH, 2,142 for GR, 1,932 for CO, 1,674 for ST, 1,497
  for BT spawning and 196 for WCT (`compare.csv`, `stored_vs_default_differ_km`); the stored flags are not what any rule
  here is compared with, and `default`'s CH rearing has no rows in link's own log, so its stored flags are never the
  reference (CLAUDE.md, "link's CH rearing").
