# Findings — BT spawning evidence by gradient and channel size: FISS first, then literature and spatial layers (#33)

## Plan-mode exploration (2026-10-02)

What exploration found:
- **Spawner evidence can be split by kind.** `data/fdis/build/fish.rds` (0230) has per-fish
  `maturity_code`. For BT/DV fish: SP 82, ST 10, M 1,002, MT 1,778, IM 6,866; U and blank are most.
  0240 currently collapses this into one `spawner_evidence` row per visit (374 rows in
  `data/fdis_evidence.csv`). The kinds are SP/ST, M in Aug–Oct, M in other months, and adult size
  alone.
- **The visit table already exists.** `data/fdis/derived/bt_use_visits.csv` (0290) has the visits on
  link segments, with pooling, effort, zero catch, `spawning`/`rearing`, segment gradient and width,
  MAD and role. The model helpers in `scripts/0291` (classify, `modelled()`, `class_weight()`, the
  stream bootstrap on PSOCK workers) are the pattern to copy. Scripts don't graduate to `pkg/` until
  they've run twice.
- **FISS workbooks add little for spawning.** `data/fiss_evidence.csv` char rows are mostly Peace
  mainstem boat-EF adults and subadults, with 4 spawner-evidence rows. Report them, don't model them.
- **Literature gaps are confirmed.**
  - In the library with PDFs, not yet read for BT spawning: Retzer 1989 (Williston tributaries), the
    Metolius bull trout report, Rocky Creek, MacPherson 2024. The Hagen series is used only for
    survey-design rules.
  - In the library without a PDF: COSEWIC 2012, D'Angelo & Muhlfeld 2011, Muhlfeld 2012, Pearce 2019.
  - Missing, citations confirmed via CrossRef: Baxter & Hauer 2000 (CJFAS, 10.1139/f00-056),
    Baxter & McPhail 1999 (Can J Zool, 10.1139/z99-090), Shepard et al. 1984 (Flathead,
    BHL 10.5962/bhl.title.130558).
  - To locate: Fraley & Shepard 1989 (Northwest Science), the USFWS 2015 recovery plan and the 2010
    critical habitat rule.
- **The spatial layer.** The Peace QGIS project references
  `gis/data_secure/wlrs/bt_critical_habitat_williston/bt_critical_habitat.gpkg`, with layers
  `BT_Williston_critical_spawning_segments_230112` and `Williston_critical_juvenile_segments_230112`.
  It is not on m1 or in S3, and m4 was unreachable. You said it's on m4: pull it later, last, and
  never block on it. It is a data_secure WLRS layer, so only aggregates leave this repo.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Issue context

**If we do it:**
- link's BT spawning thresholds (`spawn_gradient_max` 0.0549, `spawn_channel_width_min` 2 m) get fish evidence behind them, or a measured reason to move. Whether they move is decided in link (see "What this delivers, and what link decides").
- The rule that links BT rearing to spawning gets something to stand on.

**If we never do:**
- The spawning thresholds rest on a thin literature table: three BC reach studies, and no review giving a number.
- BT rearing keeps inheriting them through the spawning-connection rule.

## Problem

#28 measured BT rearing use and found no spawning-side counterpart. The evidence on hand is thin on both sides:

- **FISS / FDIS.** 348 sites have char spawner evidence (a spawning or spent maturity code, or a mature fish in Aug–Oct). 42 % of those with a site gradient sit above `spawn_gradient_max`.
  - #28's side table shows spawner evidence per BT visit is higher on steep segments (9 of 63 at 10.49–12.49 %, 9 of 75 above 14.49 %) than at 0–2 % (23 of 791).
  - Read naively, that says BT spawn in steep water. The likelier reading: **BT spawn in low-gradient patches and push up through steep reaches to reach them.** A ripe fish caught on a steep segment may be in transit.
  - Electrofishing also samples adult migrants poorly.
- **Literature (#19).** Reach-scale BC spawning gradients of 0.6–4 % from three studies (O'Brien 1999, Bustard & Schell 2002, Cope & Morris 2001), and Hagen's Williston survey-design rules. No review gives a numeric limit.
  - The Hagen redd-count and critical-habitat series, Baxter's spawning-site work, and the US redd-survey and critical-habitat literature are under-read or missing.

## Proposed solution

Three tracks. **Track 1 starts now and is not held up by 2 or 3.** A weak first result is fine; it is the baseline the others test.

**1. FISS evidence (start here).**
- Reuse #28's visit table: visits on link segments, pooled BT presence, effort, zero catch, access.
- Add per-visit spawner evidence from `data/fdis_evidence.csv` and the FISS submission workbooks (`data/fiss_evidence.csv`, #21, other gear types), split by kind:
  - maturity code SP or ST;
  - M in Aug–Oct;
  - adult size alone (kept apart: not spawning evidence by itself, per #18).
- Spawner evidence per visit by segment gradient and channel width, with #28's split (any BT caught; spawner evidence given BT caught).
- **Transit test.** For each spawner-evidence visit on a segment above `spawn_gradient_max`, measure the distance to the nearest upstream and downstream segment at or under it. If steep-water spawners sit close below low-gradient patches, that supports "passing through" over "spawning there".
- Expect a poor answer for spawning, and say so. The value is a first measured number, with its biases named.

**2. Literature (in parallel).**
- Read the group-library PDFs not yet used for BT spawning: Retzer 1989 (Williston tributaries), the Metolius River bull trout report, Rocky Creek, MacPherson et al. 2024. Re-read the Hagen series for redd-site gradient and width, not only survey-design rules.
- Find and file the missing ones:
  - Baxter's spawning-site papers (confirm citations first);
  - Fraley & Shepard 1989 and Montana FWP redd counts (Flathead, Swan);
  - the USFWS bull trout recovery plan and critical habitat documents;
  - PDFs for COSEWIC 2012, D'Angelo & Muhlfeld 2011, Muhlfeld et al. 2012 and Pearce et al. 2019, which are in the library without one.
- Add rows to `data/literature_evidence.csv` through the 0280 gate, with the meaning audit.

**3. Spatial layers (when available; not blocking).**
- The Peace layers we already hold: Hagen's redd and critical-habitat mapping. Confirm what they contain before planning on them.
- Other sources: USFWS critical habitat GIS, state redd-survey layers.
- Redd locations on FWA give the segment gradient and width where BT actually spawned. That is the evidence electrofishing can't give.

## What this delivers, and what link decides

Same split as #28 and #23: this repo builds evidence that holds whatever model is run; link makes the model call.

- **Here (knowledge):**
  - the Track 1 evidence tables and log, as aggregates;
  - new literature rows through the 0280 gate;
  - any redd or critical-habitat layers placed on FWA;
  - a `research/` write-up of what the evidence supports and what it cannot say, including the transit test result.
- **In link (a follow-on issue, drafted here and filed when the evidence is in):**
  - whether `spawn_gradient_max` or `spawn_channel_width_min` should move, scored the way link#284 scores thresholds;
  - whether the spawning-connection rule for BT rearing should change.

  This is also the input link needs before choosing between the two ways of applying #28's rearing weights.

## Limits to state
- Electrofishing undersamples migratory adults and finds no redds.
- Maturity-code meanings are inferred from RISC codes.
- The steep classes have small numbers.
- US spawning habitat may differ from BC's, so report it by region.

Relates to #28, #18, #19, #21, NewGraphEnvironment/link#284

## Phase 1 — spawner evidence on link segments (2026-10-02, `scripts/0293`; revised after code-check round 1)

All figures are from `data/bt_spawn_evidence.csv` and `scripts/logs/habitat/20261002_bt_spawn_evidence.txt`. Visit table md5 `b32e526204b01a60dfe5ecf6f0b5e04d`.

**Population and kinds**
- 411 of the 14,463 population visits are a second copy of a survey loaded twice (#35). They are kept, as 0290 keeps them; a sensitivity drops them.
- Visits by strongest kind: M Aug 63, M Sep–Oct 49, M other months 25, SP/ST 7 (includes one repeated survey), adult size only 79 (`U`-coded large fish now count as uncoded).
- The spawner flag reproduces 0240's spawner rows on 119 visits (assert passed).
- **Coding.** The share of BT visits with any maturity-coded BT is 0.27 at 0–2 % against 0.40–0.45 in steeper classes. The S population (Aug–Oct, at least one coded BT) is 560 visits; 485 are modelled, in 23 WSGs.

**Rates**
- **Raw S** rises with gradient: 0.146, 0.188, 0.182, 0.293, 0.302, 0.352 on all 560 visits; 0.174 → 0.422 on the modelled 485.
- **Adjusted S rate ratios** (WSG, coding effort, month, data set, era, area) against the count-weighted ≤ 5.49 % classes:
  - 1.10 / 1.04 / 0.75 / 1.22 / 0.94 / 1.14;
  - intervals of roughly 0.2–3.6, with some bootstrap lower bounds of 0 where sparse resamples separate.
- **The rise is between WSGs, not within them.**
  - Without the WSG term, the ratios run 0.87 → 3.07.
  - With coding effort and month only, they run 0.83 → 3.72.
  - With the WSG term alone, they are 0.76–1.28.
  - So coding effort and month do not remove it; the WSG term does. Within WSGs, no gradient effect is detectable.
  - Between WSGs, it is open whether steep-terrain groups hold more spawners, or differ in crews and survey design in ways that coding effort and month do not capture.
- **Sensitivities** are point estimates only, ranging 0.34–1.90: without the top two agencies (Timberland 20, Kokanee 18 of 119 evidence visits); August only; no river polygons; repeated surveys removed (0.84–1.22); measured site gradient.

**Size**
- Large spawners (≥ 350 mm): 8, 9, 6, 5, 3, 3 visits by class. Every class is underpowered.
- Small spawners: 18, 19, 11, 17, 11, 17. Raw rates 0.10 → 0.32; adjusted ratios 0.80–1.43, with wide intervals.
- Sep–Oct only is underpowered from 4–5.49 % up.

**BT caught (U)** on the spawning ladder: 0.90, 1.17, 1.04, 0.80, 0.75, 0.59. This repeats #28's taper.

**Width (raw S by segment width class and source)**
- Spawner evidence at < 2 m: 7 of 41 field-measured visits, 3 of 17 modelled. The highest rate is 5–10 m, 0.35 on both sources.
- Below 2 m there are 10 spawner-evidence visits, 8 of them small fish. Of those 10, 7 are also steeper than 5.49 %: 2 large in Sep–Oct, 3 small in Aug, 2 small in Sep–Oct.
- "Spawner" here includes M-coded fish in August, which the plan review noted mixes migration with spawning.

**Large spawners on steep segments, descriptive**
- 11 visits, which are 10 distinct surveys (BBAR `46561_76_1` / `76685_76_1` is one survey).
- "Patch" = ≥ 200 m at ≤ 0.0549, width ≥ 2 m, stream edges. "Upstream" = anywhere upstream in the WSG.
- 4 have no patch upstream: KOTL 11.1 %, UFRA 15.7 %, COTR 10.2 %, PARS 11.0 %. Round 1 checked all of FWA without a WSG filter and found no upstream channel outside the WSG.
- 5 distinct surveys have a patch on the same blue line, 780–5,394 m upstream.
- 1 (CLRH) has patches upstream, but none on its own blue line within 10 km.
- Transit fits some of these fish. For the four with no patch upstream, these segments do not support transit. Segments with no modelled width are excluded by the width rule, so a real patch may be missed. How much channel lies upstream of each was measured by review, not logged, and is not reported here.

**FISS workbooks:** 4 char spawner rows (UPCE, MURR, LNTH ×2), reported only. Their site gradient is a fraction (#34).

**Read for #33.** Electrofishing spawner evidence does not discriminate BT spawning gradient within WSGs. It neither supports nor contradicts `spawn_gradient_max`. Mature BT, mostly small, turn up on steep segments and in a few streams narrower than 2 m. That fits resident spawning beyond link's spawning thresholds, but the counts are small and August fish may be migrants. Redd data (Track 3) and the literature are the evidence that can speak to spawning gradient.

## Phase 2 — literature (2026-10-02)

**Filed to the group library** (`0270`, live: added 2, created 2):
- Two existing library items newly added to `Fisheries/habitat_modelling`: the Metolius report (`BHHDYTJI`) and Rocky Creek (`GDTHZCLF`).
- Two new items with PDFs:
  - the USFWS 2015 recovery plan, `u_s_fishandwildlifeservice2015Recoveryplan` (`X5XQUDTX`);
  - the 2010 critical habitat final rule (75 FR 63898), `u_s_fishandwildlifeservice2010Endangeredthreatened` (`294UBXMS`).
- Both synced and got citation keys without a restart.

**Not acquired**, listed so a person can fetch them by hand:
- Baxter & Hauer 2000 (CJFAS, 10.1139/f00-056) and Baxter & McPhail 1999 (Can J Zool, 10.1139/z99-090): paywalled, no open-access copy per OpenAlex. These are the core spawning-site and upwelling papers.
- Shepard et al. 1984 (Flathead, BHL 10.5962/bhl.title.130558): open, but BHL returns 403 to scripted downloads.
- Fraley & Shepard 1989 (Northwest Science): open at WSU (hdl 2376/1698), but the download link renders in JavaScript.
- COSEWIC 2012: the candidate URL guessed during the search was wrong; not found.
- Pearce et al. 2019 (Williston First Nations information gathering): in the library with no PDF.
- Montana FWP redd counts: not searched (agency reports, no index reached).

**Rows** (`data/literature_evidence.csv` data rows 490–510; drafter notes `draft-spawn-notes.md`):
- 21 of the 23 drafted rows landed. The 2 `hagen_weber2019` depth rows were dropped: depth is not a link parameter, and the gate has no cm→m rescale.
- Rows 70–71 ("no source found" for BT spawning gradient max/min) now also name both USFWS documents as searched: neither gives a number, and the rule declines to set ranges (p. 63931).
- Gate: 510 rows pass (`scripts/logs/habitat/20261002_literature_verify.csv`).
- Parent check of row 504: the 5–9 °C is cited to Goetz 1989 on the page, matching its `cited_source`.

**What the literature adds to the spawning question:**
- **Gradient.** "Low-gradient stream reaches with loose, clean gravel" (Fraley & Shepard 1989 via the 2010 rule and the 2015 plan) is the only US gradient statement. It is qualitative, and no number exists anywhere searched.
- **Resident and small migratory spawners use smaller, steeper streams:**
  - the 2010 rule restating McPhail & Baxter 1996;
  - Hagen & Spendlow 2019 p. 30: smaller populations of large-bodied spawners in shorter, steeper tributaries.
- **Width.** Hagen et al. 2020 p. 49 (expert): redds of large migratory BT in stream sections as small as 2 m wetted width. Same lead author as the existing 2 m row, so not independent.
- **Passage.** Hagen et al. 2015 p. 9: juvenile densities much higher above chutes and bedrock canyons. This bears on the "push up steep reaches" idea for migration.
- **Groundwater, cold water and alluvial valleys** dominate the site-selection statements: the Metolius report, Hagen & Sary 2023, the 2015 plan, and the 2010 rule's hyporheic statements.
  - The vocabulary has no groundwater variable, so pure groundwater statements were not recorded, and others went in as `temperature` or `valley_width_index` qual rows.
  - This is a vocabulary gap worth an issue.

**Contradictions noted by the drafter:**
- Fraley & Shepard's spawning-onset temperature is cited as 9 °C in existing rows and 10 °C in the 2010 rule.
- The 4–10 °C range is attributed to Goetz 1989 in the 2010 rule and to Howell et al. 2010 in the 2015 plan.
- Redd depth is given as 24–58 cm (Hagen & Weber 2019) and 30–60 cm (the existing Roberge row), both from the same 1996 review.

### Code-check, Phases 1–2 (rounds 1–2 and the enumeration)

| round | findings | fixed | inside a previous fix? |
|---|---|---|---|
| 1 (`review-p1-round1.md`) | 4 real + 3 minor | all | — |
| 2 (`review-p12-round2.md`) | 4 Phase 1 wording items + 5 row items | all | **yes**: the findings rewrite |

Round 1:
- repeated surveys (#35);
- "explained by where and how" overstated;
- numbers missing from the log;
- a header that misdescribed the patch query;
- the FISS label, U-coded large fish, the power label, and point-estimate sensitivities.

Round 2:
- "almost no channel upstream", untrue for KOTL and UFRA;
- figures that came from the review rather than the log;
- an open-explanations line that contradicted the sensitivities;
- the header's 2.5 % and the spec disclosure;
- the row 508 note misattributing McPhail & Baxter's 9 °C;
- the row 505 note's Swan River claim;
- row 490's page context, row 500's "adfluvial", and the region on rows 501–502.

**Mechanism:** prose written beyond the logged result, from memory or from a reviewer's probe.

**Ended by enumeration:**
- Round 2 enumerated all 32 Phase 1 numbers and claims against the log and CSV (30 matched; the 2 mismatches are fixed above, and the claims they carried were removed rather than re-sourced).
- It audited all 21 rows field by field against their pages (5 note or region fixes, applied).
- After the fixes, the 0280 gate passes on 510 rows.
