# Code-check round 1 (#161): findings

## Checklist read

- code-check-python.md: read in full (nothing here applies: the diff has no Python).
- code-check.md: the index in full, plus the prose of every H3 under `## Mechanisms` (with the tables and evidence blocks skipped). I read these closely: "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two callers that share a harness" and "Restore the bug and prove the guard fires". Of the 26 non-Mechanism headings, I read none in full, because none names a pattern this diff uses.
- code-check-r.md: the index in full, plus the full section "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it". From the index I also checked the diff against "A database driver's value is not a base R type", "`sprintf("%g", x)` writes `Inf` and `NA` into SQL as bare words", "testthat counts an uncaught error under `error`", "A `skip_if_not()` skips only its own `test_that()` block", "Serialization loses meaning silently" (code-check.md) and "CSV whitespace". About 115 headings were not read in full.
- code-check-spatial.md: the index in full. I checked the diff against "FWA `upstream_route_measure` misses the next segment's start" and "FWA main flow is not edge type 1000 alone" from the index. No section was read in full; about 140 headings were not read.
- code-check-shell.md: the index only. The diff has no shell.

## What I checked

- `.knw_link_flow_sql()`: every placeholder is positional (`%1$s`, `%2$s`, `%3$s`), and there is no other `%` in the template. Apart from the new `ORDER BY ..., p.linear_feature_id`, the SQL matches the old inline query. Both callers (`knw_link_segments()` and `0310`) still reach it only through `knw_link_flow()`.
- Tie keys:
  - In `fwa_stream_networks_sp`, `linear_feature_id` is unique, so each pick now ends on a unique key. The exception is duplicate wet pick rows, a case the owner has already accepted.
  - The dam snap's lateral reads only the FWA table, so `(distance, linear_feature_id)` is unique there.
- Settings register: the `code:` phrases `AND p.edge_type NOT IN ({value})` (`R/link_flow.R`) and `s.edge_type NOT IN ({value})` (`R/link_regulated.R`) each still sit whole on one line.
- Fixture test:
  - It varies the insertion order, which is the axis the old ORDER BY depended on.
  - Its types match production: bigint, ltree and geometry columns.
  - Segment 10 has no flow row, so it cannot be its own parent candidate.
  - The live tests cover the production plan path: a GiST KNN scan plus an incremental sort, on PostgreSQL 17.5 / PostGIS 3.5.2.
- Dam test reference: it is computed by an independent query that ranks on `ST_Distance`, not on the function's ORDER BY.
  - A read-only probe found 2 dams with a 2-way tie and none with a 3-way tie, so its `LIMIT 3` window always holds every tied candidate.
  - Its `DISTINCT ON (cabd_id) ... ORDER BY cabd_id, linear_feature_id` is unique within each group.
- `data-raw/link_flow_tie_check.R`:
  - `sys.source` into one environment resolves `.knw_link_flow_sql` for the new `knw_link_flow`.
  - The keys of the flow, tied and dams files are all written with `%.17g` and read back as character, so the compare's `%in%` and `identical()` see the same spellings.
  - `na = ""` is applied the same way on every run.
- Logged numbers against the prose:
  - 2,831 parent lines and 1,800 tied lines.
  - Under the old code the two databases differ on 614 flow rows and 2 dams; under the new code, on 0.
  - Rerunning the new code changes 632 lines on the host and 636 on the second database ("about 630"), all of them tied.
  - Timings are no slower.
  - These match `research/database_builds.md` and `CLAUDE.md`. DESCRIPTION is 0.4.31, so "from 0.4.32" refers to the release bump.
- Other `<->` lookups in the repo:
  - `inst/sql/ch_dist_profile.sql:140` is the walk landing, which #162 tracks.
  - `data-raw/vignette_cut_points_places.R:123` is a place-label lookup, outside #161's scope and not touched by this diff.

## Clean

No issues found.
