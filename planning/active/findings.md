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
