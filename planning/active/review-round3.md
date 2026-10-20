# Code-check round 3 for #75 (knowledge 9bb77ef..8a41291, soul 416-readme-knowledge @ 72d0c66)

## Checklist read

- `code-check-python.md` (7 KB): read in full.
- The four `index_*.md` files (2-23 KB each): read in full (they are the index lines `CLAUDE.md` already carries).
- `code-check.md` (329 KB): the prose of all 14 H3s under `## Mechanisms`, without the `|` rows or evidence blocks
  (extracted, 61 KB, read end to end). The standalone, Security and Spreadsheets/PDF sections were not read.
- `code-check-r.md` (175 KB): read 2 headings: "A `data-raw/` script must load the source tree" (readme_figure.R)
  and "Regenerated binaries churn git" (`man/figures/readme-bulk.png`). Round 2's other four R headings were not
  re-read; nothing in this round's diff touches `.Rbuildignore`, cffr or `data/`.
- `code-check-shell.md` (121 KB) and `code-check-spatial.md` (154 KB): no heading's index line names a tool or
  shape this round's diff uses (no shell, no new sf/terra/GDAL code; one added `stopifnot()` clause in R). None read.

## Findings

- **[false-claim, minor] README.md:97-98**: "The comparison maps draw floodplains from stac_floodplains_bc" states over
  every comparison map what holds for one subset. The set, from the code:
  - `research/fig/compare_*.png`: 121 tracked. 102 are 1800 x 690 (three panels, the third the floodplain) and 19 are
    1200 x 690 (rules and grade only). `scripts/0330-compare.R:236` builds `fp_cells` only for catalog groups, and
    `R/compare_map.R:127` draws the panel only when it is given.
  - The README's own figure is a comparison map (`data-raw/readme_figure.R:16`, `panels = "rules"`) and draws none.
  - The article's two maps draw none (`vignettes/chinook_rearing.Rmd:429-430`; `data-raw/vignette_chinook.R:23-24`).
  - The interactive pages (`data/compare/maps/*.html`, ignored) have no floodplain layer (`R/compare_map.R:146-159`).

  A reader who has just seen the README map will take it as drawing floodplain too. The NOTICE (inst/NOTICE.md:16)
  got this right with "where a map has one"; the README sentence was written from that one member. Fix: narrow it to,
  for example, "The floodplain panels of the comparison maps in `research/fig/` come from stac_floodplains_bc." Or
  name what the package takes from it: floodplain hectares (`knw_floodplain_ha()`, `data/compare/floodplain.csv`) and
  those panels.

- **[false-claim by omission, minor] inst/NOTICE.md:14-21 and :28-29**: the new CC BY 4.0 section covers the maps
  only. There is a second tracked artifact derived from the catalog's floodplains: `data/compare/floodplain.csv`
  (313 lines, hectares by grade class per species × stage × catalog group).
  - It is written at `scripts/0330-compare.R:272` from `knw_floodplain_ha(gpkg_of(w), …)` (`:237`) on the catalog's
    `<wsg>_all_ff04/floodplain.gpkg` (`:103`, the CC BY 4.0 bucket per stac_floodplains_bc's `ATTRIBUTION.md`).
  - The FDIS section (`:28-29`) then reads as covering it: "the use, tuning and comparison tables … are New Graph
    Environment's work under this repository's licence". `floodplain.csv` sits in `data/compare/`, among the
    comparison tables.
  - This is the round 2 shape again: the section was written from the member in view (the panel) and not from the
    set of files the catalog read produces.
  - Fix: name `data/compare/floodplain.csv` in the floodplain section ("and the floodplain hectares in
    `data/compare/floodplain.csv`").

- **[incomplete, minor] data-raw/README.md:7** (and `data-raw/vignette_chinook.R:37`, which it copies): "Rerun it …
  after any `scripts/0320`, `0322` or `0330` rerun, and `test-vignette-data.R` fails until you do". The set of
  scripts whose rerun makes that test fail has a fourth member, 0325:
  - `vignette_chinook.R` hashes `data/thresholds.csv`'s CH rearing rows (`src["thresholds"]`, `:56`; `md5_rows`,
    `:168`).
  - The test checks those rows (`tests/testthat/test-vignette-data.R`, "the CH rearing rows … unchanged").
  - `scripts/0325-publish.R:65` writes `data/thresholds.csv`, with the CH rows' `link_run_uid`, `link_sha` and
    `evidence_version` taken from the newest ledger and the manifest (`:37-38`, `:19`).
  - A 0325 rerun on its own changes those rows whenever the ledger has moved, for instance a `PUBLISH=TRUE` run,
    which #75's body lists as still open.

  In the canonical order 0325 runs between 0322 and 0330, so "after 0330" usually covers it. A standalone 0325 rerun
  is not covered. Fix: "after any `scripts/0320`, `0322`, `0325` or `0330` rerun", in both places.

## Notes (not findings)

- **Soul item 4 against the knowledge README.** `conventions/readme.md` item 4 has Installation "followed by what a
  run needs (the database, env vars, credentials)".
  - Round 2's fix dropped the sentence "Others need a bcfishpass database, a Zotero Web API key, AWS credentials or
    Python". That sentence was true (`0153`/`0270` need `ZOTERO_API_KEY`, `0299` needs AWS, `0153`/`0270` are Python).
  - The README now names only the fwapg database and `PG*`; bcfishpass survives in Data and methods.
  - The soul amendment's evidence (readme.md, the knowledge#75 paragraph under "Check each claim") records that the
    plan review found the requirements sentence "silent on … a Zotero key, AWS credentials and Python". The shipped
    README is silent on them again.
  - Nothing here is false. It is a conformance gap the branch's purpose (#75: bring the README to the convention)
    may want closed. A narrow form that holds: "Some scripts need a Zotero Web API key, AWS credentials or Python;
    see each one's header".
- **CLAUDE.md:66 "`v2` is the published set"**: v1 is published too (`knowledge/fdis/v1/manifest.json` 200 per round
  2). "the newest published set" would be exact. This is a nit; the next sentence's "so today only with
  `VERSION=v2`" is true (`0299:56-57` accepts only v2|v3, and v3's manifest is 403).
- **Pre-existing, outside the branch's changed roxygen**: `R/compare_map.R:3-5` says each of the three readings is
  drawn as a static figure "and, when `html` is given, an interactive page". The interactive page draws rules and
  grade only (`:146-159`), with no floodplain. This line is not in the branch's diff.

## Enumeration: knowledge fixes since 9bb77ef (every added or reworded sentence)

| # | Where | Sentence / clause | Set(s) named and members | Verdict | Evidence |
|---|---|---|---|---|---|
| K1 | CLAUDE.md:65-66 | 0299 builds them as `knowledge/fdis/v3`, not yet uploaded | versions {v3} | TRUE | `0299:56` default v3; v3 manifest 403 (probed today) |
| K2 | CLAUDE.md:66 | `v2` is the published set, measured 2026-10-20 | published versions {v1, v2} | TRUE as "current"; v1 also published (note) | v2 manifest 200 today |
| K3 | CLAUDE.md:66-67 | `PULL=TRUE` restores a published version, so today only with `VERSION=v2`, the pre-#57 set 0291-0298 read | accepted versions {v2, v3} ∩ published {v1, v2} = {v2} | TRUE | `0299:50-57`; CLAUDE.md "0291–0298 are frozen on the published v2 tables" |
| K4 | README:12 | thresholds such as the smallest stream and the steepest gradient for juvenile chinook rearing | CH_rear_v1 components {size, gradient, exception_q, exception_d} | TRUE | `data/thresholds.csv` `rear_mad_min` (stream size by MAD), `rear_gradient_max` |
| K5 | README:16 alt | streams chinook can reach in the Bulkley | BULK accessible CH segments | TRUE | `compare_map.R:68`; `vignette_chinook.R` OUTPUT line "BULK accessible CH segments" |
| K6 | README:16 alt | coloured by both / default only / tuned only / neither | rule classes {kept, lost, gained, accessible-neither} | TRUE (4 of 4) | `compare_map.R:74-78, 82-83` |
| K7 | README:34-35 | scripts run in the order of `scripts/README.md` | scripts | TRUE | `scripts/README.md` tracked; absolute URL |
| K8 | README:36-37 | Many read a PostgreSQL fwapg database, found by `PG*` | 36 R/Python scripts; 25 connect | TRUE | grep of `dbConnect`/`pg()`/`RPostgres`: 25 of 36; the 11 that do not: 0140, 0161, 0210, 0260, 0270 (py), 0290-0292, 0296, 0297, 0299 |
| K9 | README:37 | the tuning also reads link's run and wet's flows there | tuning scripts {0320 (via knw_grade_species/knw_link_segments)} | TRUE | round 2 row 18, unchanged code |
| K10 | README:60-61 | on a stream line, the tuned rule passes a segment where gradient ≤ 9 % and (MAD ≥ 0.75 or a ≥ 3 m³/s river within 1 km downstream) | rule parts {size, gradient, exception_q, exception_d} | TRUE | `data/thresholds.csv` CH_rear_v1 rule `mad>=0.75\|g<=0.09\|Q3@D1000`; `R/rule_in.R` (round 2 row 24) |
| K11 | README:62 | access and link's other steps then apply as they do to `default` | stages {predicate, overlay, connectivity} | TRUE | CLAUDE.md CH rearing's three stages; `0330` regenerates both rules (header :10-12) |
| K12 | README:97-98 | The comparison maps draw floodplains from stac_floodplains_bc | comparison maps {121 research/fig compare PNGs (102 with a floodplain panel), README figure, article's 2 maps, interactive pages} | **FALSE as stated** (true of 102 of 121 + 0 of the rest) | see Findings |
| K13 | README:98-99 | Some crossing and report scripts also read a bcfishpass database | {0100, 0110, 0160} | TRUE | round 2 row 33; unchanged |
| K14 | _pkgdown.yml Tuning s1 | build around link's thresholds, score held-out, fit the curve at the pick, grade every segment | functions in the group | TRUE | round 2 row 54; `knw_tune_grid`, `knw_tune_score`, `knw_tune_curve`, `knw_grade*` |
| K15 | _pkgdown.yml Tuning s2 | building, scoring and fitting run in one call for every species and stage the evidence can speak to | `knw_tune_run` steps {grid, score, curve} | TRUE | `R/tune_run.R:1-6, 78-82`; no grade step |
| K16 | data-raw/README:3 | scripts that write the package's bundled data and figures | {vignette_chinook.R, readme_figure.R, make_hexsticker.R} (+ an input PNG) | TRUE | `git ls-files data-raw` |
| K17 | data-raw/README:3-4 | `vignette_chinook.R` writes the data for the article | outputs {chinook_rearing.rds, bulk_segments.rds, bulk_water.rds} | TRUE | header OUTPUT :32-34 |
| K18 | data-raw/README:4-5 | runs once against the saved tuning and comparison tables and the local database | inputs {data/tune/*, data/tune/grad_ext/*, data/thresholds.csv, data/compare/*, logs/ledger, fwapg} | TRUE (no floodplain now; logs unnamed but not excluded) | header INPUT :26-31; `:200` dbConnect; `:24` no floodplain |
| K19 | data-raw/README:5-6 | small files under `inst/vignette-data/`, so the article builds with no database under check and pkgdown | — | TRUE | round 2 |
| K20 | data-raw/README:7 | rerun after any 0320, 0322 or 0330 rerun; the test fails until you do | writers of hashed sources {0320, 0322, 0325, 0330} | **INCOMPLETE** (0325 missing) | see Findings |
| K21 | data-raw/README:9-10 | `readme_figure.R` draws the README map into `man/figures/` from the same bundled data; `make_hexsticker.R` the sticker; rerun the first after `vignette_chinook.R` | — | TRUE | `readme_figure.R:7-16`; `make_hexsticker.R:19` `man/figures/logo.png` |
| K22 | readme_figure.R:12-13 | asserts gq, the registry's lake layer and its tmap style | compare_map's fallback conditions {gq absent, reg NULL, lake NULL, style NULL/error} | TRUE (all four covered; `stopifnot` evaluates in order) | `compare_map.R:87-91` |
| K23 | NOTICE:10-12 | OGL-BC: FWA in the two rds (installed), and the Atlas's streams, lakes and rivers drawn in `readme-bulk.png` and the maps in `research/fig/` | research/fig maps {121 compare (streams + lakes ≥ 10 ha + rivers, `0330:209-212`), 3 `chinook_rearing_tuned_<wsg>` (streams only, `0298:420-444`)}; the curves PNG is not a map | TRUE | dimensions and producers enumerated |
| K24 | NOTICE:16-18 | the floodplain panel of `research/fig/compare_*.png`, where a map has one, is drawn from stac_floodplains_bc's floodplains | 102 three-panel maps | TRUE | `0330:236-257, 261-264`; `compare_map.R:127-132` |
| K25 | NOTICE:18 | published under CC BY 4.0 | catalog bucket products | TRUE | stac_floodplains_bc `ATTRIBUTION.md`: "everything under `s3://stac-floodplains-bc` … CC BY 4.0"; `0330:52,103` reads that bucket |
| K26 | NOTICE:18-20 | its delineation contains OGL-Canada (MRDEM-30, NRCan) and OGL-BC (FWA stream network) information | {MRDEM-30, FWA} | TRUE | `ATTRIBUTION.md` sci:citation and its table (IO LULC applies to land cover, not to `all_ff04`) |
| K27 | NOTICE:20-21 | the maps modify them: each cell shaded by the grade of the segment that owns it | — | TRUE | `0330:249-255` rasterise at 30 m, `fl_valley_join` nearest segment on the blue line key, grade |
| K28 | NOTICE (set) | the CC BY section covers what the repo carries from the catalog | catalog-derived tracked files {102 maps, `data/compare/floodplain.csv`} | **INCOMPLETE** | see Findings |
| K29 | links | stac_floodplains_bc site, CC BY 4.0 deed, fdis README | — | TRUE | 200, 200, 200 (probed today) |

Round 2 rows re-checked because a later fix touched their sentence or set: 7 (now K6, TRUE), 16 (sentence removed),
17 (K8), 35 (Data and methods: stac_floodplains_bc added, K12; hydrologic zones left out by decision), 37 and 44
(the NOTICE sets; K28), 42 (K23-K24), 58-59 (K18, K20).

## Enumeration: soul diff (origin/main...72d0c66), every new sentence

| # | Where | Sentence | Kind | Verdict | Evidence |
|---|---|---|---|---|---|
| S1 | Check-claims bullet | Link a repo file by absolute URL: pkgdown copies the README to the home page, where a relative link to a file outside the site breaks | rule | TRUE; no conflict | grep of soul `conventions/` for "relative" link guidance: none in readme.md, pkgdown-publishing.md or cartography.md |
| S2 | new bullet | A claim about what is published is checked against the store, not a script's default or an issue's audit: list the bucket, fetch the manifest | rule | no conflict | agrees with code-check.md "Fetch the authoritative copy" |
| S3 | evidence s1 | the issue's audit called `knowledge/fdis/v2/` stale because the script defaults to v3; the bucket held v1 and v2, v3's manifest 403, so the README names no version | evidence | TRUE | #75 body (struck item and its correction); v3 403 today; README:40 names `knowledge/fdis/` only |
| S4 | evidence s2 | the plan review found the requirements sentence silent on bcfishpass, wet's flows, a Zotero key, AWS credentials and Python | evidence | TRUE (a subset of B2, which also named cabd/bcfishobs) | `review-plan.md:8` |
| S5 | evidence s2 cont. | and the example's prose stating a tuned rule as fact about where chinook rear | evidence | TRUE | `review-plan.md:9` (B3) |
| S6 | evidence s3 | relative links to `scripts/README.md` and `research/README.md` would have broken on the home page | evidence | TRUE | round 2 B5; commit a3498ff |
| S7 | item 4 | a repo that installs a package and also publishes data says how to reach both | rule | no conflict | readme.md "Leave out …" excludes counts, not access |
| S8 | item 4 | where the store does not list, link a public document that does (a provenance note, a manifest), not a bare prefix | rule | no conflict (round 2's wording note on "does" stands) | — |
| S9 | item 9 | read each licence from the source's own catalogue record | rule | no conflict | — |
| S10 | item 9 | trace each tracked file to the script that writes it before naming its source | rule | no conflict | — |
| S11 | item 9 | where the package installs that data under `inst/`, the notice is `inst/NOTICE.md`, as in flooded | rule | TRUE | `flooded/inst/NOTICE.md` exists; pkgdown-publishing.md's root-page allowlist is a different case |
| S12 | item 9 evidence | `package_show` gave the four PSCIS layers, tracked in 11 groups, "Access Only" | evidence | TRUE | #76 table; 11 tracked `data/*/pscis_*.gpkg` |
| S13 | item 9 evidence | a NOTICE draft put site tables under the open licence that a script writes from EcoCat workbooks, not from the open layer | evidence | TRUE (round 2's unsupported cause removed) | `findings.md` "fiss_sites_* are written by 0220 from the EcoCat workbooks … a first NOTICE draft had them under OGL-BC; corrected"; `0220:40-43` |
| S14 | item 9 evidence | both went to knowledge#76 | evidence | TRUE | #76 body: PSCIS row and EcoCat submissions bullet |
| S15 | item 9 evidence | a root `NOTICE.md` is not installed, while `inst/vignette-data/` installs FWA geometry, so the notice moved to `inst/NOTICE.md` | evidence | TRUE | `review-plan.md:14-17` (G2); 9bb77ef moves `NOTICE.md` to `inst/NOTICE.md` |
| S16 | figure bullet | a map that fails a check only because of a shared mapping function may ship once the gap is filed against the function, with the caption saying what the map cannot show | rule, an explicit exception to the bullet's first clause | no contradiction now (the exception is stated) | cartography.md's checks are review steps; no rule there forbids shipping with a filed gap |
| S17 | figure bullet | assert gq in the figure script when the function falls back without it | rule | TRUE of knowledge | `readme_figure.R:12-13`; `compare_map.R:87-98` |
| S18 | new bullet | one panel of an article's figure can be the README figure, when the article's other panels serve a table the README does not carry | rule | no conflict | — |
| S19 | figure evidence s1 | the README map is the whole-group panel of the article's two-panel map; the zoomed panel's numbered examples belong to the article's table | evidence | TRUE | `chinook_rearing.Rmd:426-434` (the article's panel adds the window outline) |
| S20 | figure evidence s2 | `knw_compare_map()` draws no scale bar or keymap, in the article too, so it went to knowledge#77, and the caption names two towns | evidence | TRUE | #77 body; README:18 "around Smithers and Houston" |
| S21 | figure evidence s3 | falls back to a plain lake fill without gq, so `readme_figure.R` asserts gq's registry | evidence | TRUE | `compare_map.R:97`; `readme_figure.R:12-13` |
| S22 | structure | no `###` heading or rule first sentence changed | — | TRUE | the diff's 6 hunks touch bullets, list items 4 and 9, and evidence blocks only |
