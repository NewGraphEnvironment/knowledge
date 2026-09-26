# Findings — Parse FISS life stage and individual-fish lengths into a per-site species x size-class evidence table (#18)

## Issue context

**If we do it:** a per-site evidence table with measured channel width and gradient, sampling effort, true absences, and fish size by species. It is the empirical input for CH/BT habitat-threshold calibration in link, and it gives BT a life stage we can check (0 of 11,524 provincial BT observation records carry one). **If we never do:** spawning and rearing evidence can't be separated for BT, and calibration uses presence-only points with no absences.

## Problem

`0220` parses the Fish Data Submission workbooks' Step 1 (Ref & Loc), Step 2 (Fish Coll.) and Step 4 (Stream Site Data). Two things it leaves behind:

- **Step 2 life stage** (per species per sampling event) is present in the sheet but not in `wanted_cols`, so `fiss_step2_fishcoll_<wsg>.csv` has none.
- **Step 3 (Individual Fish Data)** isn't parsed at all: fork/total length, weight, per-fish life stage.

The Step 2 life stage is the submitter's own call. It's coarse (fry/parr/juvenile/adult), and how carefully it was made varies by submitter. Length and weight give an actual size distribution per species per site, which is a better basis for splitting life stages consistently across submissions than trusting each label.

In the local `whse_fish.fiss_fish_obsrvtn_pnt_sp` (checked 2026-09-25), `life_stage` is populated for 0 of 11,524 BT records and 3,529 of 9,152 CH records.

## We already hold a province-wide FDIS export (found 2026-09-26)

Now at **`s3://fresh-bc/fdis/`** (private prefix; 99 MB, with a README and `MANIFEST.md5`), moved byte-identical from `Dropbox/New Graph/fiss/` on m4. Supplied by the Province for the 2021–22 channel-width / fish-density work. No use terms were attached; the purpose was advancing knowledge of fish–habitat relationships.

- `2020-11-16/`: `visits.csv` (62,892 visits: UTM, method, pass, fishing time, area length and width), `details.csv` (326,389 individual fish: length, weight, age, sex, maturity), `counts.csv` (114,217 species × age counts with min/max length), `habitat.csv` (26,565 sites: gradient, up to 7 channel widths, wetted widths, bed material, temperature). Joined on `KEY`.
- `2022-03-22-ef-export/`: six `Details*.csv` files of individual fish from electrofishing, with coordinates and watershed code.
- The 2020 export is **electrofishing only**, and only passes with a recorded fished-area length (`queries/Details.sql`). Other methods (minnow traps, angling, seine) and passes without an area are not in it, so the `.xls` track and the public layers still fill those gaps.
- `queries/*.sql` (the extraction queries) and `fiss-database-structure/` (the FDIS data model).

Individual fish with a length, 2020 export alone: **BT 15,257 of 15,309** (8,821 with weight, 9,741 with maturity code), **CH 4,769 of 4,910**, DV 8,848. The 2022 files add BT ~15k and CH ~5.5k; overlap with the 2020 export is not yet checked.

This is the main source. None of it (individual lengths, maturity, per-visit effort, measured site widths and gradient) is in the public FISS layers. The `.xls` track becomes a supplement for submissions made after the export dates.

## Scope: only what the province does not already serve

The point is to get more than government sources give us. Before building, list what is already published at fish or event level: BC Data Catalogue FISS layers (`fiss_fish_obsrvtn_pnt_sp`, `fiss_stream_sample_sites_sp`), the Fisheries Inventory Data Queries tool, and any FDIS exports. For each, record which fields it carries (life stage, length, weight, effort, measured width and gradient, zero catches). Build only the gap, and state that gap in the output table's README. If a field is already served in usable form, join to that source instead of re-parsing it.

## Proposed Solution

0. Build the evidence table from `s3://fresh-bc/fdis/` first; dedupe the 2022 files against the 2020 export on `KEY`.
1. Add the Step 2 life-stage column(s) to `wanted_cols` in `0220`, keeping the submitter's label as-is.
2. Parse Step 3: species, fork/total length, weight, life stage, age if present, keyed to `site_key` and the Step 2 sampling event.
3. **Derive our own life stage from size.** Use the length (and length-weight) distributions per species, and by region where the sample supports it, to set size-class breaks. Keep the breaks in one CSV with their basis (distribution modes and/or cited values from knowledge#19), not in code. Report where the derived class and the submitter's label disagree; that disagreement rate tells us how far to trust the Step 2 labels at sites with no Step 3 data.
4. Emit a cross-group evidence table in `data/`: one row per site × species × size class, carrying `avg_channel_width_m`, `average_gradient_percent`, effort (EF seconds/length), count, the source of the class (derived from lengths or submitter label), and the NFC flag. Add `blue_line_key` / `downstream_route_measure` from the existing spatial step so link can join it to segments.
5. Run it on the groups already fetched (COTR, UNTH, LNTH, UPCE, PINE), then widen.

The table is a snapshot link reads as input; the calibration itself happens in link.

Relates to NewGraphEnvironment/link#284, NewGraphEnvironment/link#283


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1 source audit (2026-09-26)

- 2022 `Details*` ⊇ 2020 `details` as a multiset on (KEY, species, length): 0 missing, +15,219 rows.
- 53,018 site visits; 5,748 have 2–8 passes. Evidence grain = site visit, effort summed.
- Public `fiss_stream_sample_sites_sp` (68,842 sites) already has measured width/gradient; FDIS adds fish size, maturity and effort at the same pass.
- The maturity code table was not exported; RISC meanings inferred. Length type (fork/total) unknown per fish.
- Full write-up: `research/fdis_export.md`.

## Plan review (Plan agent, 2026-09-26): reproduced before acting

- CH in EF details: 5,728 fish, median 60 mm, 90th percentile 82 mm, 2 fish ≥ 150 mm, 0 SP/ST. CH gives **rearing evidence only**.
- `counts` holds 41,916 CH, 36,446 of them in pass × species pairs with no detail rows. Abundance comes from counts.
- 26,584 `NFC` rows in counts: zero catch is explicit.
- BT maturity: blank 5,616, IM 4,971, U 2,919, MT 1,224, M 588, SP 54, ST 9. SP/ST total 63.
- Char codes: BT 15,381, DV 8,886, BT/DV 427, DV/BT 77, DVxBT 8.

## Phase 2–3 run (log `scripts/logs/fdis/20260926_fdis_load.log`)

- 53,018 site visits; 51,981 with valid UTM; 51,450 placed within 500 m; 5,322 snapped > 100 m (flagged). (Final figures, after code-check round 3.)
- Catch status (final): 30,076 fish, 22,390 zero, 552 unknown. Earlier: 30,087 / 22,390 / 541 (round 3), 30,049 / 22,389 / 580 (round 1). 65 same-pass NFC conflicts (after code-check round 1 removed 139 NFC rows from the fish table; before: 30,130 / 22,308 / 157).
- Placement check: FDIS gazetted name = FWA GNIS name on 94.6% of the 7,894 sites carrying both. The 50k-code xref (final, codes with any level below the basin) flags 1,360 of 12,654 checkable sites; before round 3 it flagged 2,701 of 16,986 checkable sites (median snap 36 m vs 8 m for matches).
- **The FWA "field measurement" channel width is these same sites.** On 12,688 sites with source `FIELD_MEASURMENT`, 69% equal our measured width exactly. Measured-vs-modelled can only be compared where the source is `MODELLED`: 3,820 sites, log correlation 0.54, median ratio 0.98, p10–p90 ratio 0.44–2.58. So the modelled width is off by more than 2× at about one site in five. That is relevant to fresh#29 and to any channel-width threshold.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Inline `Rscript -e '…sub(…"\\1"…)'` returned 1 site | Probes moved to scratch `.R` files; the script's `site_of()` was unaffected |
| Site-level NFC "conflict" counted a depletion pass 2 with no fish (1,506) | Conflict defined at pass level (157, then 65 after the NFC-row fix) |

## Phase 4–5 run (log `scripts/logs/fdis/20260926_fdis_evidence.log`)

- Char (BT + DV + hybrid codes) length: age-0 mode 40–80 mm (Jul–Sep), parr 80–200, then a long tail to 900 mm. Spring and fall medians of 372–486 mm are migrating adults.
- Maturity check, char: IM is 55.7% fry, 42.9% juvenile, 1.3% subadult, 0.1% adult. SP/ST (n = 92 classed) is 32.6% juvenile (80–200 mm), 39.1% subadult, 28.3% adult. So 67% of SP/ST are ≥ 200 mm, and a third of spawning-coded char are under 200 mm: dwarf residents or DV.
- CH: 4,765 measured with a visit record (5,587 in the whole fish table), 99% < 120 mm, 18 ≥ 120 mm. 87% of counted CH (37,189) have no length. Rearing evidence only.
- Site-level shares vs current thresholds (measured site gradient):
  - CH present, any size (final): 1,377 sites (151 with measured gradient). 23% above rear gradient max 5.49 %; 14% below rear cw min 1.5 m.
  - Char present: 7,043 sites (2,080 with gradient). 11% above rear max 10.49 %.
  - Char spawner evidence (SP/ST, or M in Aug–Oct): 348 sites (260 with gradient). **42% above spawn max 5.49 %**, median 4.5 %, q90 13 %.
- Caveat for every number above: site gradient is a point measure over a short reach, while model thresholds apply to a segment's average gradient. The FDIS gradient units and method codes aren't exported.

## /code-check round 1 (planning/active/review-round1.md)

| Error | Resolution |
|-------|------------|
| 139 `NFC` rows in the 2022 fish table were counted as fish: 81 sites marked "fish", conflicts inflated | `is_nfc` flag; excluded from catch, used as NFC evidence |
| `mean_ok()` dropped recorded 0 % gradients (937 readings; 390 sites NA, 620 biased high) | Gradient means keep 0 |
| 6 CH with length 0 were classed as fry | Class test requires length > 0 |
| Size-break note "17 of 4,765" read as the whole table (5,587) | Population stated: fish with a visit record |

## /code-check round 2 (planning/active/review-round2.md)

| Error | Resolution |
|-------|------------|
| Inside the round-1 fix: keeping 0 % gradients admitted 28 blank-form habitat rows (all widths 0 or empty), 27 site visits | Zero gradient kept only when the row has some width > 0 |
| CH older_juvenile basis said 17 / 3; the class boundary gives 18 ≥ 120 mm and 4 ≥ 145 mm | Corrected (my histogram bins were misread) |

## /code-check round 3: enumeration (planning/active/review-round3.md)

Mechanism: each field has its own no-data encoding, and each validity test was written inline from the first sentinel seen for that field. A caught sentinel became NA, and `coalesce(…, 0)` then turned "count unknown" into "none caught". The reviewer enumerated every raw field 0230/0240 read, and found nine leaks (F1–F9): 9999 counts; `ZZZ`; effort sentinels; easting 0; water temperature to 556; `SP` asserting absence; 99999 counts → 0; min/max length 0; mainstem-only 50k codes. Fixed by one declared no-data table at the top of 0230, with presence carried apart from counts. The enumeration covered the whole candidate set, so it ends the loop.

## /code-check round 4 (planning/active/review-round4.md): five defects inside round 3's fixes

| Error | Resolution |
|-------|------------|
| Mainstem filter tested digits 10–45, so it also dropped level-1 codes (3,496 sites) | Digits 4–45: 3-digit basin, then seven 6-digit levels |
| Only `SP` blocked absence; `SA`, `AO`, `AF`, `SLV`, `TR` (and crayfish `CRA`, found in the full list) were unhandled | All 115 export codes classified in `data/fdis_species_codes.csv` from `whse_fish.species_cd`; an unclassified code stops the run. This enumerates the species-code set and ends the loop |
| A species row with count 0 became a catch (7 sites "fish", one false char presence) | Not a catch unless fish were measured |
| Site `n_caught_all` read 0 when every count was a sentinel | NA, with `flag_count_unknown` |
| Sentinel-count CH presences dropped from `fdis_evidence.csv` | Unmeasured rows keep NA |

Judgement call flagged to the user: `TR` (unidentifiable trout fry < 70 mm) blocks a char absence claim at 402 sites, a conservative choice.
