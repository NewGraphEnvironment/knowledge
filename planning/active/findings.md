# Findings — Grayling: rebuild link's default from the literature and where grayling were caught (#140)

## Issue context

**If done:** grayling's starting rule rests on what the literature and grayling capture records say about where they rear and spawn, so the tuning refines a baseline we stand behind. **If never:** grayling's thresholds stay a refinement of numbers set to get started, and the tuning can only move them a short way from there.

## Problem

link's `default` for grayling (`configs/default/parameters_habitat_thresholds.csv`):

| stage | gradient max | channel width min | MAD min |
|---|---|---|---|
| rearing | 3.49 % | 1.5 m | 0.021 m³/s |
| spawning | 2.49 % | 4 m | 0.2 m³/s |

These values were set to get the work started, not chosen from a review of grayling habitat. link's own research says grayling's cut-offs were set on an older dataset and not redone (NewGraphEnvironment/link#343, which re-tunes their MAD minima on wet's flows). We hold 28 grayling rows in `data/literature_evidence.csv`, against 292 for chinook.

The tuning cannot correct a weak start on its own, because its pick is the smallest change to `default` that the data accept (#139). For grayling rearing, `default` is outside the region on both the full and the minimal network (#120). The picks then stay close to it:
- The published pick is `width>=2|g<=0.0549|none`.
- On the minimal network the pick is `width>=1.5|g<=0.0549|none`. It won because it changes only `default`'s gradient, though the published rule scores better.

Grayling spawning has too few records to tune (`no_response`).

## Proposed

One piece of the baseline review (#139). The order (Al, 2026-11-03): the literature and the capture tables come first, so grayling's register rows record a baseline we stand behind. The anchoring check (#141) runs on the current `default` before this changes it, as the "before" the retune is read against.

The "before", from #141 (`research/baseline_anchoring.md`; logs `scripts/logs/habitat/20261104_tune_anchor_check-*`). `default` (`width>=1.5|g<=0.0349|none`) is outside the region on both readings. Each pick is given as its distance behind the best (deviance / SE) and the parts it differs from the best in:

| reading | best-scoring rule (2 tied) | pick from `default` | pick from the flow start |
|---|---|---|---|
| published (#92) | `width>=1\|g<=0.0549\|Q50@D500` | `width>=2\|g<=0.0549\|none`, 5.7 / 10.4, size and exception | `mad>=0.021\|g<=0.0549\|none`, 11.6 / 13.9, size and exception |
| minimal network (#120) | `width>=2\|g<=0.0549\|Q50@D500` | `width>=1.5\|g<=0.0549\|none`, 9.3 / 10.9, size and exception | `width>=2\|g<=0.0549\|none`, 3.9 / 5.3, exception |

Step 4 reads its retune against this table: `data-raw/tune_anchor_check.R` on the retune's tables gives the "after".

- [ ] **1. Literature.** Grayling rearing and spawning habitat (gradient, channel size, flow, and the life history that shapes them: fluvial and adfluvial movement, overwintering) into `data/literature_evidence.csv` through `0270` and `0280`, from the `bull_trout_grayling` store (#122). Every row is audited for meaning, as CLAUDE.md asks.
- [ ] **2. Where grayling were caught.** FDIS visits by gradient class, channel width and MAD class on the published evidence, with the shares and their uncertainty. These are the tables `0290` and `0294` made for bull trout and chinook. Add the FISS workbook records where they add groups. FWCP's 2026 Upper Peace grayling synthesis (Hagen et al.) also maps critical habitat segments by life stage and core area, on EcoCat with the report: https://a100.gov.bc.ca/pub/acat/documents/r65150/AG_Segments_merged_1784660602388_5C8FC7930F.zip
- [ ] **3. A proposed `default` for link,** rearing and spawning, from 1 and 2. This creates the baseline register (`inst/method/baselines.csv` and its test, specified in #139) with grayling's values as its first rows: each carries its source and its standing, and the purpose of any width floor (biological or screening) is stated. It is filed in link beside link#343, with the evidence.
- [ ] **4. Retune grayling rearing from the proposed `default`,** and report whether the pick moves, whether the published rule stays in the region, and the anchoring check's three picks (#141) beside those it gave on the current `default`. A candidate run (`DEV=1 0320`, or a candidate `0320`); a promotion waits on Al's word.
- [ ] **5.** A short grayling section in `research/` (a new topic file, or one shared with bull trout), its row in `research/README.md`, and the standing in the thresholds table.

Relates to #139 (the baseline review it belongs to, and the register's specification), #141 (the anchoring check), #64 (the per-species template), #120 (the minimal-network picks), #122 (the bull trout and grayling store), NewGraphEnvironment/link#343.






## Exploration at the plan gate (2026-11-26)

- `data/literature_evidence.csv`: 30 GR rows (depth, velocity, instream_flow, one access gradient row with no value); no gradient, channel_width, discharge or spawning-site threshold row.
- `data/grayling_members.csv`: 21 members of `species/grayling` (#122), Hagen et al. 2026 among them; the `bull_trout_grayling` store is built from `VHWEK6RE,GELFSUTU`.
- This host has cred 0.7.0, ragnar 0.4.0 and Ollama (`nomic-embed-text`): store queries run here; builds and pushes run on m1.
- link 0.78.1 installed; GR `default` row: spawn gradient 0.0249, width 4, MAD 0.2; rear gradient 0.0349, width 1.5, MAD 0.021; edge types stream, canal. `default_tuned` (link#343) holds GR MAD minima 0.96 / 0.97 fitted on fwapg.
- `0320` reads link's thresholds from `LINK_REPO` at the build's commit (`git show`), and `knw_tune_grid()` takes a thresholds row: the next member's retune from a proposed start needs a way to pass a proposed row to a DEV run.
- `0291`'s spec (cloglog, `log(area)` covariate, data set, era, group) is the model for the capture tables; `knw_spawner_evidence()` is char-only.

## Phase 5 analysis spec, fixed 2026-11-26 before any fit by class

Written after counting the population (no outcome by class was looked at). Inputs: the published evidence
(`data/fdis/derived/{visits_link,visits_species}.csv`, md5s `c746c58…`, `6a2e28f…` as `data/thresholds.csv`'s
`evidence_md5`) and `data/fdis/build/fish.rds` (md5 `8cf2735…`, the run ledger's `md5_fish`); the script refuses
others. Population counts at writing: 11,678 visits in GR's range in 71 groups, 1,231 with GR; `access_gr` 0 / 1 / 2
on 3,919 / 3,727 / 4,032; 1,746 with no `cw_deploy`; 3,283 with no area.

- **Population:** visits in GR's range (`in_range`), not `blocked`; `access_gr` 1 or 2 (code 2 is set by GR records
  upstream, often these visits' own, so it is never a covariate or stratum; code 0 visits and the GR caught on them
  are counted and dropped, as `0290`); stream and canal edges (`segment_edge_type` 1000, 1050, 1100, 1150, 2000,
  2100, 2300, `0291`'s list); a fished area of 10-10,000 m² (`0291`'s trim). River-polygon edges (1250, 1350) are a
  sensitivity, connectors and lake lines are counted and dropped.
- **Columns:** the tuning's: `segment_gradient`, `cw_deploy`, `mad_pick` (`R/tune_run.R`).
- **Classes, three separate tables:**
  - gradient (%): 0-0.5, 0.5-1, 1-2, 2-2.49, 2.49-3.49, 3.49-5.49, 5.49-8, 8-12, > 12; reference 1-2;
  - width (m, `cw_deploy`): < 1.5, 1.5-2, 2-4, 4-8, 8-15, 15-30, > 30, and `none` (blank, its own class); reference 4-8;
  - MAD (m³/s, `mad_pick`): < 0.021, 0.021-0.05, 0.05-0.2, 0.2-0.5, 0.5-1, 1-5, 5-20, > 20; reference 0.2-0.5.
  Width and MAD classes are [lower, upper), as link's `>=` floors admit a value equal to the floor; gradient classes
  are (lower, upper], as link's `<=` limit admits a value equal to the limit.
- **Responses:** U, GR caught (`present`); F, any fish caught (`catch_status == "fish"`); C, GR caught among
  visits with any fish.
- **Model:** per table and response, binomial with cloglog link: `y ~ class + log(area) + data_set + era + wsg`, era
  from year (to 1994, 1995-2004, 2005 on), a nuisance term with one level dropped; groups where the response never
  or always occurs are left out and counted. A rate ratio per class is exp(coefficient) against the reference.
  A fit that does not converge in 100 iterations gives NA. Raw rates beside every model.
- **Intervals:** 200 bootstrap resamples of streams (`blue_line_key`), seed 140, all resamples drawn in order before
  socket-cluster fits, so the output does not depend on worker count.
- **Power:** a class is `ok` with ≥ 30 visits and ≥ 10 detections of the response, else `underpowered`.
- **Stop rule:** a response with fewer than 4 groups holding both outcomes is not modelled (raw rates only).
- **Spawning:** the months the population's visits were fished in, and GR length (`fish.rds`) by month in 10 mm
  bins. An age-0 table by class only if an audited literature row gives a first-summer length cut; otherwise none.
  Spring spawning (May-June in the literature to be checked) is mostly unsampled by summer electrofishing, which
  the write-up says.
- **Sensitivity (log only):** river-polygon edges included; logit link.
- **Output:** `data/gr_use.csv` (variable × response × class: visits, detections, raw rate, rate ratio and its
  interval, boots that fit, power) and `scripts/logs/habitat/<date>_grayling_use.txt` (the population funnel, the
  evidence md5s, the knowledge commit, groups modelled, sensitivity, spawning tables).

## Errors Encountered

| Error | Resolution |
|-------|------------|
