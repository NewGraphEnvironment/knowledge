# FDIS electrofishing export: contents, defects, and what it adds

**Verified:** 2026-09-26 · **Issues:** #18 (built from), NewGraphEnvironment/link#284 (consumer) ·
**Produced by:** direct reads of `s3://fresh-bc/fdis/` and the public BCGW layers (WFS
`DescribeFeatureType`, local `whse_fish`) · **Status:** source audit complete; evidence table in `scripts/0230`–`0240`.

## Provenance

The Province supplied extracts of the Fisheries Data Information System (FDIS) to New Graph for the
2021–22 channel-width and fish-density work with Poisson Consulting. No use terms were attached;
the purpose was to advance knowledge of fish–habitat relationships in BC. The files lived only in
Dropbox (m4). They were moved byte-identical to `s3://fresh-bc/fdis/` (private prefix) on
2026-09-26; `MANIFEST.md5` there is the checksum record.

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
- **Passes per site visit:** 53,018 site visits. 47,270 have one pass; the rest have 2–8
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

- 4,770 visits have no fished-area length, although the saved `Visit.sql` filters on it. The
  export was not produced exactly by that query, or the query changed.
- 1,084 visits have no UTM.
- Junk dates: years 0200, 0220, 0912, 2028, 2029.
- Sentinel and outlier habitat values: gradient to 990 %, width 9999 m.

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
