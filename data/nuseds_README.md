# NuSEDS escapement records, with the kind of evidence each is

`knowledge/nuseds/v1/` holds Fisheries and Oceans Canada's NuSEDS (New Salmon Escapement Database System) All Areas
file as one Parquet table, `nuseds_records`. There is one row per estimate: a salmon population, on one stream, in
one year. The table adds one column, `evidence_kind`, saying what each record shows.

**Source.** DFO's
[NuSEDS dataset](https://open.canada.ca/data/en/dataset/c48669a3-045b-400d-b730-48aafe8c5ee6) on the Open Government
Portal, file `All Areas NuSEDS_<YYYYMMDD>.zip`. The release this version holds, and the md5 of the zip as received,
are in `manifest.json` and `receipt.json` beside the table. Contains information licensed under the
[Open Government Licence - Canada](https://open.canada.ca/en/open-government-licence-canada).

**What was done to it.** Nothing but this:
- the file was read through crate's registered NuSEDS shape (`crate::crt_ingest("dfo", "nuseds_all_areas")`);
- its column names were lower-cased;
- each value was typed by that shape: counts as numbers, the ids and the `DD-MON-YY` dates as written text;
- `evidence_kind` was added.

No row is dropped, merged or corrected.

**Keys.** `act_id` is unique. So is the combination of `pop_id`, `gfe_id` and `analysis_yr`. A population, species
and year is not unique: a population can be counted on several streams in a year. `fwa_watershed_cde` keys a
record to the BC Freshwater Atlas where DFO gives it.

**`evidence_kind`.** `adult_presence` decides it first. A present population takes the first of these that holds:

| value | meaning |
|---|---|
| `count_expert` | a spawner or return number above 0, by expert opinion, with no survey recorded |
| `count` | a spawner or return number above 0 |
| `presence_expert` | present by expert opinion, with no number and no survey recorded |
| `presence_survey` | present, with a survey method or a number of inspections recorded |
| `presence_unrecorded` | present, with none of the above recorded |

The other presence values give:
- `none_observed` (NONE OBSERVED);
- `not_inspected` (NOT INSPECTED);
- `unknown` (UNKNOWN or blank).

A survey counts as recorded where `enumeration_methods` or `no_inspections_used` is filled. The number is the larger
of `natural_adult_spawners` and `total_return_to_river`.

**How it was built.** By `scripts/0340-nuseds-build.R` in
[knowledge](https://github.com/NewGraphEnvironment/knowledge), with `knw_nuseds_fetch()` and `knw_nuseds_records()`.
The knowledge commit it was published from is in the manifest.
