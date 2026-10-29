# Review round 3: the "Limits" bullet on link#326 / link#396, its guard, and PR #109's paragraph

## Checklist read

- The staged diff (`limit_diff.patch`; `git diff --cached --stat` is the same 10 insertions in `vignettes/habitat_thresholds.Rmd`) and PR #109's body paragraph "**The results describe link 0.66.0's segments**" (`gh pr view 109`).
- link at `origin/main` (fetched 2026-10-28): `inst/extdata/configs/default/config.yaml` lines 98-128 (`break_order`, `observation_breaks: top_per_species`); `inst/extdata/configs/bcfishpass/config.yaml` line 107 (`observation_breaks` absent = `all`); `inst/extdata/configs/default_tuned/config.yaml` line 21 (`extends: default`); `default_extrabreaks`/`default_rearbreaks` (`extends: ~`); `R/lnk_pipeline_break.R` break-source table (lines ~25-33); `NEWS.md` 0.69.2 (#396), 0.69.0 (#326), 0.68.1 (`fresh_default` = 0.68.0 build, 2026-10-17 kept as `fresh_default_20261017`); `research/bcfp_segmentation_parity.md` lines 70-92 and 125; `research/observation_breaks.md` lines 1-65.
- The build: `scripts/logs/habitat/20261027_evidence_build_ledger.csv` (rows 3-5, 10; md5 `90a98a2ca24955c8e993d36ec42b6355`, tracked); `inst/vignette-data/method.rds` `meta$ledger` and `meta$md5[meta$ledger]` (= the same md5); `vignettes/habitat_thresholds.Rmd` line 31 (`x <- readRDS(vd("method.rds"))`).
- Ancestry: `a17e917` and `ee21eb1` (both `Version: 0.66.0`, 2026-10-16). #326's merge `f043b983` (PR #391, 2026-10-27) and #396's merge `d167e966` (PR #397, 2026-10-28) are NOT ancestors of either (`git merge-base --is-ancestor`). The only #326-tagged ancestor, `c6e5bf8` (2026-10-11), is "Point #324 status and research at the filed follow-up #326", not the change.
- Not queried: the database (marked UNVERIFIED-BY-REVIEWER below).

## Enumeration

| # | Claim (where) | Source checked | Verdict |
|---|---|---|---|
| 1 | Guard comment: limits name the segments of link's 2026-10-17 build (Rmd chunk) | ledger row 3 `link_run_uid 20261017_004619-3f4c713b`; row 10 `schema fresh_default_20261017` | Holds |
| 2 | Guard comment: link 0.66.0 | ledger rows 4, 25 `0.66.0`; `git show a17e917:DESCRIPTION`, `ee21eb1:DESCRIPTION` both `0.66.0` | Holds |
| 3 | Guard comment: before link#326 and link#396 | `f043b983`, `d167e966` not ancestors of either build sha | Holds |
| 4 | Guard comment: "which this ledger records" | ledger rows 3-5, 10 | Holds |
| 5 | Guard: `x$meta$md5[x$meta$ledger]` is the ledger's md5 the bundle was built from | method.rds meta: ledger = `scripts/logs/habitat/20261027_evidence_build_ledger.csv`, md5 `90a98a2c…`; `md5 -q` of the file = same; Rmd line 31 binds `x` to method.rds | Holds (a bundle rebuilt on any other ledger fails the stop, i.e. fails toward revising the words) |
| 6 | Bullet: results are on the segments of link's build of 2026-10-17 | as 1 | Holds |
| 7 | Bullet: link has *since* changed where it cuts streams | NEWS 0.69.0 (#326, released 2026-10-27), 0.69.2 (#396, 2026-10-28) | Holds |
| 8 | Bullet: #326 = at steep sections only where a species present first can no longer get past | `lnk_pipeline_break.R` table, `gradient_minimal`: "each present species' post-lift natural barriers … reduced to the downstream-most position per flow path"; `falls`/`barriers_definite` still separate sources in `break_order` | Meaning holds; the word order "a species present first" misreads (Finding 1) |
| 9 | Bullet: #396 = at fish records only at each species' highest record on a stream | config.yaml 116-128 "on each stream line, each present species' farthest-upstream observation"; break table `observations` row (per `blue_line_key`) | Holds |
| 10 | Bullet: #326 more than halves the segments | parity.md line 92 "`default` segments drop 2.1 to 2.7-fold" | Holds (2.1-fold > 2) |
| 11 | Bullet: in the four groups link measured it on | parity.md lines 72-73 "`default` on PCEA, FINA, PARS and LKEL"; line 92 lists the same four | Holds (for `default`, the config the article is about; `bcfishpass` was measured on 11) |
| 12 | Bullet: #396 removes "a further" share | observation_breaks.md "before" counts PARS 46,341 and LKEL 3,378 equal parity.md line 92's post-#326 counts; measured at main after 0.69.0 | Holds |
| 13 | Bullet: 1 to 4 % | observation_breaks.md table: −0.7 to −3.6 %; NEWS 0.69.2 "0.7 to 3.6 %" | Holds as whole-percent rounding (0.7 → 1); see note |
| 14 | Bullet: in the five it was measured on | NEWS 0.69.2 / research: LKEL, BULK, UPCE, PARS, ELKR | Holds |
| 15 | Bullet: thresholds not yet tuned on those segments | ledger: tuning evidence on `fresh_default_20261017`; NEWS 0.69.0/0.69.2 "Owed: provincial re-model" | Holds |
| 16 | PR: results describe link 0.66.0's segments, the build of 2026-10-17 | as 1-2 | Holds |
| 17 | PR: from before link changed where it cuts streams | as 3 | Holds |
| 18 | PR: #326 gradient barriers cut only where a present species' access changes | NEWS 0.69.0 headline and first bullet; break table `gradient_minimal` | Holds |
| 19 | PR: falls, user-definite barriers and crossings still cut where they sit | NEWS 0.69.0 "independent falls, user-definite and subsurface sources still break where they sit"; `break_order` keeps `falls`, `barriers_definite`, `crossings` | Holds (not exhaustive, and does not claim to be) |
| 20 | PR: `default`'s segments fall 2.1 to 2.7-fold on the four groups measured | parity.md lines 72, 92 | Holds |
| 21 | PR: #396 fish records cut only at each species' highest record per stream | as 9 | Holds |
| 22 | PR: #396 "`default` only" | `default_tuned/config.yaml` line 21 `extends: default`; NEWS 0.69.2 "`default` sets it, and `default_tuned` inherits it"; bcfishpass keeps `all` | False as written: `default_tuned` breaks the same way (Finding 2) |
| 23 | PR: a further 0.7 to 3.6 % | as 12-13 | Holds |
| 24 | PR: on five groups | as 14 | Holds |
| 25 | PR: neither is in any build in the database yet | Not queried. Consistent with link NEWS 0.68.1 (`fresh_default` = 0.68.0 build of 2026-10-23, below 0.69.0) and the 0.69.0/0.69.2 "Owed" lines; #326/#396 measurement builds were on another host's database | UNVERIFIED-BY-REVIEWER (consistent with every record read) |
| 26 | PR: the code here (segment gradient, the gradient on every record) holds whatever the segments are | design claim; CLAUDE.md (#92: rules and curves read `segment_gradient`; `curve_grad` on every grade row) — nothing in either reads a segment count | Holds |
| 27 | PR: thresholds, grades and comparison are superseded once a build with both exists | a build's existence makes them describe segments link no longer makes; it does not supersede them until a retune on it exists. Bullet (claim 15) says this correctly | Misleading (Finding 3) |
| 28 | PR: the methodology article's limits say so | the staged bullet | Holds |
| 29 | PR: guarded on the ledger's md5 | as 5 | Holds |

Note on 13: "1 to 4 %" is conventional rounding of 0.7 and 3.6 and is not a finding; the PR's "0.7 to 3.6 %" is exact, so if the two texts are meant to agree, the bullet can read "0.7 to 3.6 %".

## Findings

1. **Bullet, word order (claim 8).** "at steep sections only where a species present first can no longer get past" reads as "a species that was present first". The code keeps a gradient break only where it is a present species' downstream-most barrier (after its lifts) on its flow path. Replace with:
   "at steep sections only at the first place, going upstream, that a species present in the group cannot get past"

2. **PR, "`default` only" (claim 22).** `default_tuned` extends `default` and inherits `observation_breaks: top_per_species` (link NEWS 0.69.2: "`default` sets it, and `default_tuned` inherits it"); only `bcfishpass` keeps every record. Replace "`default` only" with:
   "`default` and `default_tuned`, not `bcfishpass`"

3. **PR, "superseded once a build with both exists" (claim 27).** A new build makes the results describe segments link no longer makes; they are superseded only by a retune on it. Replace "the thresholds, grades and comparison are superseded once a build with both exists" with:
   "once a build with both exists, the thresholds, grades and comparison describe segments link no longer makes until they are retuned on it"
