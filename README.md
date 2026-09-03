# knowledge

Watershed-group fisheries background for New Graph Environment: the past-report corpus,
provincial FISS data submissions, and the priority tables farmed out of both. The unit of work is
the **watershed group** (`wsg_code`), never a project or a client. Report repos consume snapshots
from here instead of carrying the pipeline.

Moved out of `fish_passage_template_reporting` in September 2026
([template#236](https://github.com/NewGraphEnvironment/fish_passage_template_reporting/issues/236));
the seeded history carries that repo's issue and PR numbers in full-repo form.

## Layout

```
pkg/            R package `knowledge` (install: pak::pak("NewGraphEnvironment/knowledge/pkg"))
scripts/        run-order scripts calling pkg and cred; README.md there is the run order
data/<wsg>/     per-group snapshots: crossings, reports, GNIS seeds, FISS sites, priorities
data/           cross-group tier: corpus_tags.csv, priority_farmed_all.csv, zotero_key_map.csv,
                rag_priorities.{gpkg,kml}
data/rag/       local cache of the ragnar stores (ignored); the source of truth is S3
planning/       PWF for work in flight and archived issues
comms/          cross-repo Claude threads
```

## Three tracks, one directory

| Track | Scripts | Notes |
|---|---|---|
| Report corpus: EcoCat discovery, PDF harvest, Zotero filing, ragnar store, content tags | `wf_*harvest.js`, `0150`, `0152`–`0154`, `0156` | store build/query/sync go through [`cred`](https://github.com/NewGraphEnvironment/cred) |
| FISS data submissions: enumerate, fetch, parse `.xls`, flag no-fish-captured, emit a layer | `0200`, `0210`, `0220` | opt-in; `0210` is gated on `FISS_FETCH=TRUE` |
| Priority farming: PSCIS pull, farm priority tables, reconcile to crossings, spatialize | `0100`, `0110`, `0140`, `0160`–`0162` | one join key to fish passage; planning at group scale across years |

## What is tracked, what is not

- **Tracked:** text snapshots (csv, md) and the small spatial deliverables (gpkg, kml, ~9 MB total).
- **Ignored, regenerable:** raw FISS `.xls` (`data/<wsg>/fiss_xls/`, from `fiss_xls_manifest.csv`).
- **Ignored, in S3:** the ragnar stores. `s3://fresh-bc/rag/` holds them with a `log.json`
  provenance manifest; `.Rprofile` sets `options(cred.store_source)` to it. Pull with
  `cred::crd_store_connect("<store>")`, push with `cred::crd_store_push()`. A local ingest
  (`0152`) must be followed by a push, because the next verified connect replaces an unpushed
  local store with the bucket copy.

## One discipline

No client or project identifiers in commit messages, issue titles, code or fixtures. The
watershed group is an argument. Context goes in `CLAUDE.md`, `comms/` and `planning/`, which
never leave this private repo. Code that graduates from `scripts/` into `pkg/` must be clean;
the scripts still carry legacy literals and are fixed forward as they are touched.
