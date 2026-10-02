# Task: BT spawning evidence by gradient and channel size: FISS first, then literature and spatial layers (#33)

## Problem

#28 measured BT rearing use and found no spawning-side counterpart. The evidence on hand is thin on both sides:

- **FISS / FDIS.** 348 sites have char spawner evidence (a spawning or spent maturity code, or a mature fish in Aug–Oct). 42 % of those with a site gradient sit above `spawn_gradient_max`.
  - #28's side table shows spawner evidence per BT visit is higher on steep segments (9 of 63 at 10.49–12.49 %, 9 of 75 above 14.49 %) than at 0–2 % (23 of 791).
  - Read naively, that says BT spawn in steep water. The likelier reading: **BT spawn in low-gradient patches and push up through steep reaches to reach them.** A ripe fish caught on a steep segment may be in transit.
  - Electrofishing also samples adult migrants poorly.
- **Literature (#19).** Reach-scale BC spawning gradients of 0.6–4 % from three studies (O'Brien 1999, Bustard & Schell 2002, Cope & Morris 2001), and Hagen's Williston survey-design rules. No review gives a numeric limit.
  - The Hagen redd-count and critical-habitat series, Baxter's spawning-site work, and the US redd-survey and critical-habitat literature are under-read or missing.

Track 3's layer is on m4 (user, 2026-10-02): pull it last, never block on it. Only aggregates leave this repo (WLRS data_secure).

## Revisions after plan review (2026-10-02, `review-plan.md`; adopted inside the mandate)
- **Response.**
  - Restricted to Aug–Oct visits where at least one BT carries a maturity code (B2).
  - Nuisance terms: month (A2) and log(n coded BT), on top of log(area), data_set, era and WSG. Agency is a sensitivity.
  - August and Sep–Oct are reported separately (A1).
- **Evidence kinds.** Every response is split by fish size: adult ≥ 350 mm, or smaller (B1). Strongest-kind order: SP/ST > M Sep–Oct > M Aug > M other months > adult size only (G6). M outside Aug–Oct is a migrant class.
- **U** is refitted on the spawning ladder; nothing is reused from 0291 (G1).
- **Transit test** becomes a descriptive table for large spawners only (B1, B3):
  - an access-independent patch definition (≥ 200 m of segments ≤ 0.0549, width ≥ 2 m, spawn edge types);
  - upstream network search through fwapg;
  - censoring reported;
  - no inference.
- **Labels and checks.**
  - Output is labelled evidence rates, never weights (S1).
  - Plus: a measured-site-gradient sensitivity (S2), width by source (A5), an assert that 0240's spawner rows are reproduced (A4), and the input md5 logged (A6).
- **Phase 2:**
  - read the newly filed PDFs;
  - add Pearce 2019 and Montana FWP redd counts to the search;
  - report US evidence by region;
  - order: file → sync → read → build → rows → gate (G2–G4, O2).
- **Phase 3:**
  - layer provenance stated (A8);
  - ignored path (A9);
  - USFWS GIS and state layers recorded as pending (G5).
- **Acceptance.** Every number traces to a log line (AC1). A power table per cell (AC3). The "passing through vs spawning in place" question is answered as underpowered unless the large-fish counts say otherwise (AC2).
- **A7** (`fiss_evidence.csv` gradient as a fraction) is filed as its own issue.

## Phase 1: Spawner evidence on link segments (Track 1)
- [x] `scripts/0293-bt-spawn-evidence.R`. Analysis spec fixed in the header before the first fit:
  - Join per-fish maturity (`fish.rds`) and visit month (`fdis_sites`) to 0290's visit table.
    Pooling is per visit, the same codes as 0290.
  - Per visit, record spawner evidence by kind: SP/ST any month; M Aug–Oct; M other months; adult
    (≥ 350 mm) Aug–Oct with no maturity code. A visit takes its strongest kind.
  - Spawning ladder classes on segment gradient: ≤ 2, 2–4, 4–5.49, 5.49–8, 8–10.49, > 10.49 %.
    Channel width classes: < 2, 2–5, 5–10, > 10 m, where width is not null.
  - Two responses, the #28 split: BT caught (reuse 0291's numbers), and spawner evidence given BT
    caught, on SP/ST plus M Aug–Oct.
  - Model: binomial cloglog with log(area), data_set, era and WSG. Weights against the ≤ 5.49 %
    classes. Stream bootstrap on PSOCK workers. Power rule: ≥ 30 visits and ≥ 10 detections.
- [x] **Transit test.** For each spawner-evidence visit on a segment > 0.0549, measure the distance
  along the same blue line to the nearest segment upstream and downstream at ≤ 0.0549, and to the
  nearest link `spawning` segment. Null comparison: BT-present visits without spawner evidence on the
  same gradient classes.
  - Same-blue-line search only in v1; tributary junctions are a stated limit.
- [x] FISS workbook spawner rows (`data/fiss_evidence.csv`) reported as a table, not modelled.
- [x] Outputs:
  - `data/bt_spawn_evidence.csv`, aggregates only;
  - the log `scripts/logs/habitat/<date>_bt_spawn_evidence.txt`;
  - a re-run that reproduces the CSV byte for byte.

## Phase 2: Literature (Track 2)
- [x] Read for BT spawning gradient, width, substrate, upwelling and redd site:
  - the library PDFs not yet used: Retzer 1989, Metolius, Rocky Creek, MacPherson 2024;
  - a re-read of the Hagen series (2015, 2020, Weber 2019, Sary 2023, Spendlow 2019) for redd-site
    values, not survey rules.
- [x] Acquire and file to the group library (Web API, `Fisheries/habitat_modelling` via
  `data/habitat_modelling_additions.csv` and `0270`):
  - Baxter & Hauer 2000, Baxter & McPhail 1999, Shepard et al. 1984 (BHL);
  - Fraley & Shepard 1989, the USFWS 2015 recovery plan and the 2010 critical habitat rule;
  - PDFs for COSEWIC 2012, D'Angelo & Muhlfeld 2011, Muhlfeld 2012.
  - A paywalled item with no access is noted, not chased.
- [ ] Rebuild and push the `habitat_modelling` store with the new documents (`0150` build, then push).
- [x] Add rows to `data/literature_evidence.csv`. 0280 gate; a meaning audit per row; every note's
  numbers and pages enumerated against the cited page.

## Phase 3: Williston critical spawning segments (Track 3, last, never blocking)
- [ ] When m4 is reachable: copy `bt_critical_habitat.gpkg` to a private `s3://fresh-bc/` prefix with
  an md5, and list its layers and fields.
- [ ] `scripts/0294-bt-critical-spawn-segments.R`: place the critical spawning and juvenile segments
  on link segments (fresh_default; Williston WSGs). Report, length-weighted:
  - segment gradient and width distributions;
  - the share link flags `spawning` / `rearing`;
  - the share above `spawn_gradient_max` and below `spawn_channel_width_min`.
- [ ] If m4 is not reachable by Phase 4, record Track 3 as pending in the #33 body and the research
  file, and ship without it.

## Phase 4: Write-up and handoff
- [ ] `research/bt_spawning.md`:
  - what the evidence supports for BT spawning gradient and width;
  - the transit-test result;
  - what electrofishing cannot say;
  - dead ends.

  Provenance line, README index row, CLAUDE.md Layout and the scripts/README run order.
- [ ] Draft the link follow-on issue: spawning thresholds and the spawning-connection rule, scored the
  link#284 way, with aggregates only (link is public). Kept in `planning/active/`, not filed.
- [ ] Revise the #33 body with the answer.

## Validation

- [ ] `devtools::test("pkg")` passes
- [ ] 0280 gate clean
- [ ] `/code-check` on each commit, each loop ended by enumeration when a round finds a defect inside a fix
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive`, then `/gh-pr-push`
