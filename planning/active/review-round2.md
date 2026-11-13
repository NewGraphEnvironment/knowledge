# Code-check round 2 (#173, batch 6), branch at 4e871765 against merge-base eac16623

## Checklist read

- code-check-python.md: not opened; the diff adds no Python.
- code-check.md: the prose of every H3 under `## Mechanisms`, with the table rows skipped. All 14 read in full except the
  back half of "Serialization loses meaning silently" and "One fact derived twice", which I only skimmed.
  "Rules that stand alone", Security and Spreadsheets/PDFs: headings only (none applies to this diff).
- code-check-r.md, read by heading (8 sections in full):
  - "A `data-raw/` script must load the source tree, not the installed package"
  - "A database driver's value is not a base R type — and it fails twice"
  - "`nzchar(NA)` is TRUE — non-empty checks silently pass NA"
  - "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"
  - "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it"
  - "`clusterApply()` returns `NULL` for no tasks, not an empty list"
  - "A `function(...)` mock hides arguments the real callee no longer accepts"
  - "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are"
  - Of about 120 headings, about 112 were not read: their index lines name no tool, shape or pattern this diff uses.
- code-check-shell.md and code-check-spatial.md, by heading:
  - I read the index lines.
  - I checked the diff against "sf: `st_intersection()` / `st_difference()` return a GEOMETRYCOLLECTION", "A GeoPackage is a SQLite database, and that leaks in three ways" and "Paths" from the index text, without opening their full sections.
  - About 230 other headings were not read.

## What I ran

- The round-1 fixes:
  - `.knw_segment_water()` against the local fwapg `fresh_default` for BULK, LFRA and NECR: every river, lake and wetland row now has an area, with no NA.
  - No `waterbody_key` is shared between the rivers, lakes, wetlands and man-made polygon tables, so the coalesce order cannot pick the wrong table.
- `gpkg_one()`, extracted from scripts/0330, on two socket workers. It used 3,000 real BULK segments and the helpers passed in as 0330 passes them. Each GeoPackage gets:
  - `segments`, with `water` and `water_ha` (rivers have an area);
  - `run`;
  - `layer_styles`, with rule_class as the default style.
- Four test files, in a detached worktree with `NOT_CRAN=true`: test-compare_map, test-env_flag, test-tune_promote and test-vignette-data. None failed or errored; 3 tests were skipped.
- test-settings-register, test-data-dir, test-archive and test-floodplain_ha: all pass.
- `R CMD check` (no tests, vignettes or examples): Status OK.
- The installed gq's `gq_qgis_style()` returns one character QML string, so `c(rule_class =, grade_class =)` keeps its names.
- gq main exports every gq function the article and the tests reach outside the two unreleased ones.
- `gq_basemap_blend()` returns a credit that is a single string.

## Findings

- **[severity: bug]** data-raw/vignette_context.R:37 (and the claim at :16) — `town_concise <- c("CITY", "TOWN", "VILG", "DIST")`. "DIST" is not a concise code in the Canadian Geographical Names Database.
  - The service's code list (`/codes/concise.json`) has CITY, TOWN, VILG, MUN1, MUN2 and UNP, and no DIST.
  - BC's district municipalities are coded MUN1 ("Other Municipal-District Area-Major Agglom.").
  - So the filter keeps cities, towns and villages and drops every district municipality, though the header says they are included.
  - On BULK, measured just now against the service and the local fwapg outline:
    - Houston (MUN1, at the Bulkley–Morice confluence) and New Hazelton (MUN1) both lie inside the group outline (`ST_Within` TRUE).
    - Neither is in `bulk_context.rds`, which holds Hazelton, Smithers and Telkwa.
    - Houston is the group's second town and the upper Bulkley's only one.
  - The README figure and the chinook article's static map therefore leave out the town that places the upper half of the group. This is what #77's "every map places its reader" is for.
  - The service's code is the source of truth: the set was reasoned about the service rather than read from its code list.
  - Fix: add MUN1, not DIST, after checking what MUN1 adds elsewhere, then regenerate the bundle and the README figure. MUN2 adds First Nations band offices and council sites, a separate choice.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: security]** planning/active/review-plan.md:126-131 — six bullet lines give absolute paths under a user home directory: the user name and the local checkout layout, one of them a sibling repository's path.
  - The repo is public.
  - CLAUDE.md ("One discipline: everything here is public") says `planning/` carries no home paths from 2026-10-16.
  - The #56 `public_sweep.py` searches `planning/active/` for local paths, so it will flag this file on the branch.
  - Fix: rewrite them as repo-relative paths (`scripts/0330-compare.R`, gq's `R/gq_style_qml.R`) before the push or the archive.
  - **Rule:** none

## Round-1 fixes, reviewed

1. **The styles are built before any work.**
   - `gpkg_styles` is computed at line 104, after the STAGE and STRUCTURES checks and before `pg()`, the ledger, the latency check and any `unlink`.
   - `.compare_qgis_styles()` now checks both gq functions.
   - The workers receive the object; they never call the check.
   - The source test pins the order and the absence of a second call.
   - One axis over, I found no other late registry or gq dependency in the GPKG path. `.compare_rule_labels()` reads the package's own registry, which `load_all` serves from the source tree.
2. **Rivers carry their area.**
   - The join is verified on three groups.
   - `vignette_chinook.R` now uses the helper. Its key types still match: an int4 `waterbody_key` from the `bigint = "numeric"` connection, against the helper's numeric.
   - Its anyNA guard still catches an unknown type.
3. **The credit check holds.**
   - `is.character(credit), length(credit) == 1L, nzchar(credit)` stops on a NULL credit.
   - A credit of `NA_character_` would still pass. gq never returns one, since `basemap_credit()` builds the string from `maptiles::get_credit()`, so this is not a finding.
