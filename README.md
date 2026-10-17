# knowledge

Fisheries background for British Columbia, assembled per **watershed group**: what past reports,
provincial fish records and the literature say about where fish live, and the habitat thresholds that
evidence supports. Three things live here together:

- an R package, `knowledge`, with the readers and builders that have proved themselves on more than one
  region;
- the scripts that build the evidence tables, in run order (`scripts/README.md`);
- the evidence itself (`data/`) and what is known from it (`research/`).

The evidence for the habitat thresholds the [link](https://github.com/NewGraphEnvironment/link) habitat
model uses is gathered here, and candidate thresholds are tested against fish records.

## Install

```r
pak::pak("NewGraphEnvironment/knowledge")
```

The package reads the evidence tables by path, so most work happens in a clone, with the package loaded
from the source tree:

```r
pkgload::load_all()   # from the repo root
ev <- knw_literature_read("data/literature_evidence.csv",
                          species_code = "BT", variable = "temperature")
```

## What is known

[`research/`](https://github.com/NewGraphEnvironment/knowledge/tree/main/research) holds one file per
topic, revised in place as the evidence moves:

- [FDIS electrofishing export](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/fdis_export.md):
  the provincial Fisheries Data Information System extract, its join structure, defects, and what it adds
  over the public layers
- [Habitat literature](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/habitat_literature.md):
  where each modelled Chinook and bull trout threshold comes from, and how cited quotes are verified
- [Intrinsic-potential models](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/ip_models.md):
  what each Pacific Northwest model thresholds on and how it sized streams
- [Bull trout rearing use](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/habitat_weights.md)
  and [bull trout spawning](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/bt_spawning.md)
  by gradient and channel size
- [Chinook by stream size](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/chinook_stream_size.md)
  and [a tuned Chinook rearing rule](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/chinook_rearing_tuned.md)
- [Thermal requirements](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/thermal_requirements.md),
  [stream temperature models](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/stream_temperature.md),
  [flow requirements](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/flow_requirements.md)
  and [modelled discharge](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/modelled_discharge.md)

The [research index](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/README.md) lists them all.

## Layout

```
R/, man/, tests/  the R package `knowledge`
scripts/          run-order scripts; scripts/README.md is the run order
data/<wsg>/       per-group snapshots: crossings, reports, GNIS seeds, FISS sites, priorities
data/             cross-group tables: literature evidence, IP model registry, life-history timing,
                  FDIS and FISS evidence, tuned-rule results, the farmed priority tables
research/         what is known, one topic per file
planning/         work in flight and archived issues
```

## Three tracks

| Track | Scripts |
|---|---|
| Report corpus: EcoCat discovery, PDF harvest, Zotero filing, a searchable store, content tags | `wf_*harvest.js`, `0150`, `0152`–`0154`, `0156` |
| Fish records: FISS data submissions (`.xls`, no-fish-captured sites) and the FDIS electrofishing export, each as evidence by species and size class | `0200`–`0250` |
| Habitat thresholds: cited literature, intrinsic-potential models, use curves and tuned rules from fish records on modelled stream segments | `0260`–`0298` |

Priority tables farmed out of past reports and reconciled to PSCIS crossings (`0100`–`0162`) feed field
planning at group scale.

## Data

- **Tracked:** text snapshots (csv, md) and small spatial deliverables (gpkg, kml).
- **Regenerable, not tracked:** raw FISS `.xls` (`data/<wsg>/fiss_xls/`, from `fiss_xls_manifest.csv`).
- **On S3** (`fresh-bc`, `us-west-2`), read by manifest because the bucket does not list:
  - `fdis/`: the FDIS electrofishing extract as received from the Province of BC, with its provenance
    note and checksums;
  - `knowledge/fdis/v2/`: the visit-level tables built from it, as Parquet with a `manifest.json`;
  - `rag/` (not public): the searchable report-text stores.
- **Databases:** scripts that query PostgreSQL connect through the standard `PGHOST`, `PGPORT`,
  `PGDATABASE`, `PGUSER` and `PGPASSWORD` environment variables; each script's header names the schemas
  it needs (an [fwapg](https://github.com/NewGraphEnvironment/fwapg) load, and for some a
  [bcfishpass](https://github.com/NewGraphEnvironment/bcfishpass) database).
- **Zotero:** store builds read a local, synced Zotero data directory; filing to the group library reads
  a Web API key from `ZOTERO_API_KEY`.

## Conventions

The watershed group is an argument, never a project or a client: no client or project identifiers go in
code, fixtures, commit messages or issue titles. Code graduates from `scripts/` into the package only
once it has run on two regions.

The repository began in September 2026 with history seeded from an earlier fish-passage reporting
template, so issue and PR numbers in that seeded history refer to the template, not to this repository.

## License

MIT for the code. Data sources carry their own terms; the FDIS extract is published with the Province's
agreement (see its provenance note).
