# FDIS electrofishing export: contents, defects, and what it adds

**Verified:** 2026-09-26 (Provenance: 2026-10-16; Where it lives, Repeated surveys and the evidence table: 2026-10-17) · **Issues:** #18 (built from), #56 (published), #35 (repeated surveys), NewGraphEnvironment/link#284 (consumer) ·
**Produced by:** direct reads of `s3://fresh-bc/fdis/` and the public BCGW layers (WFS
`DescribeFeatureType`, local `whse_fish`) · **Status:** evidence built (`scripts/0230`, `scripts/0240`); first calibration read below.

## Provenance

The Province of British Columbia supplied extracts of its Fisheries Data Information System (FDIS),
exported on 2020-11-16 and 2022-03-22, to New Graph Environment for the 2021–22 channel-width and
fish-density work with Poisson Consulting. No use terms were attached; the purpose was to advance
knowledge of fish–habitat relationships in BC. The files lived only on a shared drive until they were
moved byte-identical to `s3://fresh-bc/fdis/` on 2026-09-26; `MANIFEST.md5` there is the checksum
record. On 2026-10-16 the Province agreed to the extract being public, provided it carries a note of
when and from where it was received (#56).

## Where it lives

- `s3://fresh-bc/fdis/`: the extract as received (`2020-11-16/`, `2022-03-22-ef-export/`), the export
  queries, the FDIS data-model documents, `MANIFEST.md5`, and `README.md`, the provenance note, whose
  tracked source is `data/fdis_README.md`. `fissr_explore.sqlite`, a 2021 working database that is not
  part of the extract, and the old `derived/` copies moved to the bucket's private `archive/fdis/`, with
  the original `MANIFEST.md5`; the one in `fdis/` is that record less the sqlite line (26 files).
- `s3://fresh-bc/knowledge/fdis/v2/`: the visit-level tables built here (`fdis_sites`, `bt_use_visits`,
  `ch_mad_visits`, `ch_rule_visits`, `ch_rule_walks`) and `fdis_repeat_surveys` (below) as Parquet, with a
  `manifest.json` naming each table's rows, checksum, producing script and source CSV, the commit it was
  published from, and the version it supersedes. `scripts/0299` writes them, and with `PULL=TRUE`
  restores `data/fdis/derived/` from them. `v1/` is the release before #35: it counts repeated surveys
  once per copy, and `fdis_repeat_surveys` maps its `site_visit` ids to v2's.
- Both prefixes are readable without credentials once the bucket policy grants them; the bucket does not
  list, so start from the manifest.

## Contents and join structure

Every file keys on `KEY` = `fshclctn_id _ site_number _ sequence_number _ method_number _ haul_or_pass`,
which is **one electrofishing pass**. A **site visit** is the first three parts.

| file | rows | grain | notes |
|---|---:|---|---|
| `2020-11-16/visits.csv` | 62,892 | pass | UTM, dates, fishing time (s), fished length/width (m), EF settings, agency |
| `2020-11-16/habitat.csv` | 26,565 | pass | `GRADIENT11..22` (%), `CHANNELWIDTH1..7`, `WETTEDWIDTH1..7` (m), bed material, temperature; no saved query |
| `2020-11-16/details.csv` | 326,388 | fish | species, length (mm), weight, age, sex, egg count, maturity |
| `2020-11-16/counts.csv` | 114,217 | pass × species × age | number caught, min/max length |
| `2022-03-22-ef-export/Details*.csv` | 341,607 | fish | same fields as `details` plus UTM, watershed code, gazetted name |

- **The 2022 fish files contain every 2020 fish row.** Compared as a multiset on (KEY, species,
  length), 0 of 326,388 2020 rows are missing from 2022, and 2022 adds 15,219. The 2022 files are
  the fish table; the 2020 files supply visits, effort and habitat.
- Of the 2020 detail keys, 19,669 of 19,817 have a visit row; habitat covers 23,254 of the 62,892 visits.
- **Passes per site visit:** 53,018 site visits in the export, before repeated surveys are dropped (below). 47,270 have one pass; the rest have 2–8
  (depletion passes). Distributions built per pass would weight multi-pass sites up to 8×, so the
  evidence grain is the site visit, with effort summed over its passes.

## Units and codes

- Fish `LENGTH`: millimetres, "forked or total" per the FDIS data dictionary
  (`fiss-database-structure/FDIS_columns.csv`). The export does not say which, per fish. Salmonids
  are conventionally measured fork length; treat it as length of unknown type.
- `MATURITY_CODE` values in BT/CH rows: blank, `IM`, `U`, `MT`, `M`, `SP`, `ST`. The code table
  (`FDIS_Z_MATURITY_CD`) was not exported. The meanings used here are the RISC fish-collection codes,
  **inferred, not read from the export**: immature, unknown, maturing, mature, spawning, spent.
- Gradient: percent. Of 25,692 `GRADIENT11` values the median is 3, the 95th percentile 22, and the maximum 990.
- Channel width: metres. Of 25,835 `CHANNELWIDTH1` values the median is 2.2 and the 95th percentile 24; `9999` occurs as a sentinel.

## Known defects (flagged in the build, never silently dropped)

Every no-data encoding is declared once, at the top of `scripts/0230` (measured field by field
in /code-check round 3, `planning/archive/2026-09-issue-18-fdis-evidence/review-round3.md`):

| field | no-data encodings found | handling |
|---|---|---|
| `NUMBER_CAUGHT` | 9999 (23 rows), 99999 (48) | count NA; the catch still counts as presence |
| `FISHING_TIME`, `FISHING_AREA_LENGTH/WIDTH` | 9999, 9999.9 | NA, `flag_effort_sentinel` (91 sites) |
| `UTM_EASTING/NORTHING` | 0, out-of-BC values (14 eastings < 100,000; 32 northings < 5.2 M) | `flag_no_utm`, not placed |
| `WATER_TEMPERATURE` | values to 556 | NA outside −1 to 35 °C |
| `MINIMUM/MAXIMUM_LENGTH` | 0 | NA |
| `GRADIENT*` | 990 etc.; 0.00 on blank forms | > 100 NA; 0 kept only when the row has a width |
| `CHANNELWIDTH*`, `WETTEDWIDTH*` | 9999, 0 | ≥ 500 or 0 → NA |
| `SPECIES_CODE` | 115 codes, each classified in `data/fdis_species_codes.csv` (names from `whse_fish.species_cd`): `NFC`/`ZZZ` no fish caught; `ANODON` mussel and `CRA` crayfish not fish; `SP`, `AF` block both absences, `SA`/`AO` block CH, `TR` (trout fry < 70 mm) blocks char; `SLV` counts as char | an unclassified code stops the run |
| `NUMBER_CAUGHT` = 0 on a species row | 21 rows | not a catch unless fish were measured |
| `NEW_WATERSHED_CODE` | mainstem-only codes (`230-000000-…`) | not used as a placement check |

Undecided: 644 habitat rows have one gradient slot at 0 and the other above 0. The data can't
say whether that 0 is a reading or an unfilled slot; it is kept as a reading.


- 4,770 visits have no fished-area length, although the saved `Visit.sql` filters on it. The
  export was not produced exactly by that query, or the query changed.
- 1,084 visits have no UTM.
- Junk dates: years 0200, 0220, 0912, 2028, 2029.
- Sentinel and outlier habitat values: gradient to 990 %, width 9999 m.

## Repeated surveys (#35)

Some surveys were loaded under two to four collection ids: the same UTM, date and per-pass effort, and the
same catch, under ids thousands apart (`42511_102_1` and `65734_102_1`). `scripts/0230` keeps one copy.

- **Signature:** UTM, date, pass count, fished length and width of each pass in order, and the catch by
  species. An empty catch matches whether NFC was recorded or not. Fishing time is not in it; copies
  differ in time in 33 groups, and the map says which.
- **When a match counts:** every member has its own collection id, and the members share a site number or
  hold identical measured fish. 65 groups with different site numbers and no identical fish could be
  adjacent sites at one rounded UTM, and 13 sit inside one collection; their members stay as separate
  visits.
- **The copy kept** has the most measured fish, then the most maturity-coded fish, then a known catch,
  then habitat, then the lowest collection id. The fish are not reliably on the lowest id: in 94 of the
  95 groups where one copy alone has measured fish, it is the higher one. A habitat value the kept copy
  lacks moves to it from a dropped copy (5 pairs: 3 kept copies with no habitat record, 2 whose record
  lacks a gradient, a width or a temperature), and 0230 stops if any habitat value would leave with a
  dropped copy. The placement check reads the 50k watershed codes of every copy, which sit on the fish
  rows.
- **What one copy gives up:** 78 measured fish rows held only on a dropped copy (mostly the same fish
  with another weight or code), 3 maturity-coded fish (none char), 1 species measured only on a dropped
  copy, and 3 count length bounds. Merging copies would count the identical fish twice. A sweep of every
  visit column over the 1,431 pairs finds no other value held only on a dropped copy.
- **Measured** (`scripts/logs/fdis/20261017_03_fdis_load.log`): 1,308 groups; 1,431 visits dropped (623
  fish, 623 zero catch, 185 unknown), with 1,504 passes, 3,591 measured fish rows and 9,597 of 990,606
  counted fish; 51,587 visits remain. In 114 groups the copies' measured fish differ, in 115 their
  habitat, and 89 pair a zero copy with an unknown one.
- **The 2022 fish files** repeat the same fish under every id in 326 of the 440 groups with measured
  fish. In 94 the fish sit under one id only (the copy kept), and in 20 the copies' fish differ slightly
  (a weight, a maturity code, a fish).
- `data/fdis_repeat_surveys.csv` lists every other member of each matching group, with the copy kept and
  whether it was dropped.
- Effect downstream (rerun 2026-10-17): #28's BT rearing weights moved by at most 0.02, #33's spawner
  rate ratios stayed within 0.81–1.16 with a WSG term, and CH detection by stream size did not change
  its detections. Details are in `habitat_weights.md`, `bt_spawning.md`, `chinook_stream_size.md` and
  `chinook_rearing_tuned.md`.

## What this adds over the public layers

| field | `fiss_fish_obsrvtn_pnt_sp` / `bcfishobs` | `fiss_stream_sample_sites_sp` (68,842 sites) | FDIS export |
|---|---|---|---|
| species presence | yes | no | yes |
| life stage | coarse, often blank (BT 0 of 11,524) | no | via length + maturity |
| individual length / weight | no | no | **yes** |
| maturity / sex | no | no | **yes** |
| effort (time, fished area) | no | surveyed length only | **yes, per pass** |
| measured channel width / gradient | no | yes, one value per site | yes, repeated measures per pass |
| fish tied to the habitat measured at the same pass | no | no | **yes** |
| zero catch | no | no | inferable (pass with effort, no fish rows) |

The public sample-sites layer already has measured width and gradient, so the value here is not
those numbers alone. It is fish size and maturity **at the pass where width and gradient were
measured**, plus effort. That is what separates spawning-size from rearing-size evidence against
the same channel measurements.

Not checked: the Fisheries Inventory Data Queries web tool, which is interactive only.

## Scope limit

Electrofishing only. Minnow traps, angling, seines, snorkel and gill nets are absent, which biases
against large-river and lake use. Adult CH in mainstems will be under-represented relative to
their true spawning habitat.

## What the evidence says so far (2026-09-26; counts after #35, 2026-10-17, `scripts/0240`)

Site-visit counts, measured site gradient, against the thresholds link runs now:

| group × class | sites | with gradient | above rear max | above spawn max | below rear cw min |
|---|---:|---:|---:|---:|---:|
| CH present (any size) | 1,359 | 138 | 25 % (> 5.49) | 30 % (> 4.49) | 14 % |
| char present (any size) | 6,879 | 1,956 | 11 % (> 10.49) | 34 % (> 5.49) | 9 % |
| char spawner evidence | 340 | 254 | 16 % | **41 %** | 4 % |

- **CH is rearing-only here.** EF caught 2 CH ≥ 150 mm in the whole export.
- **Size is not maturity for char.** A third of SP/ST-coded char are 80–200 mm, so a length break alone cannot separate spawners; spawner evidence uses maturity plus month.
- **Measured vs modelled width** is comparable at only 3,637 sites after #35 (3,820 when written), where the FWA width is `MODELLED`. FWA's `FIELD_MEASURMENT` widths are these same FISS sites (69 % identical). There the log correlation is 0.54 (also after #35) and the p10–p90 ratio 0.44–2.58 (as written on 2026-09-26).
- **Site gradient is a point measure**; model thresholds apply to a segment's average. Before any of these shares move a threshold, link#284 has to compare against the segment gradient the model actually uses.

## Supplement: Fish Data Submission workbooks (#21)

`scripts/0250` adds Step 3 individual fish from the submission workbooks 0220 parses, in the
`fdis_evidence.csv` shape (`data/fiss_evidence.csv`, `source = "fiss_xls"`). Across the five
groups harvested so far, most electrofished workbook fish are already in this export (45 of 68
reports match ≥ 90 % by date, place, species and length), which is how the export was built. What
the workbooks add is other years at resurveyed index sites (Peace boat EF 2012–2016) and other
methods (angling, gill net, minnow trap, snorkel). No workbook in those five groups postdates 2020,
so the post-export gap is not closed by them yet.
