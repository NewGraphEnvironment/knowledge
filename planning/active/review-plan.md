# Plan review — #173 (Plan agent, 2026-11-13)

Review of planning/active/task_plan.md for #173: findings against the issues and the code

I only read files. Nothing was modified and no R was run. For gq I read the source at ~/Projects/repo/gq, where origin/main is v0.21.0 and the local checkout is 0.18.0.

## The six questions, answered briefly

1. **Removing the fig_dir promotion.** It breaks nothing at runtime, but more needs editing than the plan lists:
   - The exported signature, its roxygen `@param` and the `@examples` call that passes `fig_dir` (R/tune_promote.R:46, 59, 62). R CMD check runs that example.
   - The archive place map (R/tune_promote.R:374-377).
   - Comments that name STAGE=maps (R/tune_promote.R:275, 332, 390).
   - The 0335 header (scripts/0335-promote.R:38) and scripts/README.md:122.
   - Two tests use a figure as their only subject: the "archive and undo" test (tests/testthat/test-tune_promote.R:246-267) and the round-4 test "an undo restores whatever the files' ages" (tests/testthat/test-tune_promote.R:396-402). Port them to the GeoPackage so the undo and copy.date coverage survives, rather than deleting them.
   - An existing `replaced_*` archive's `fig/` would then be left behind without a note. No candidate run sits in the main checkout's data/compare/candidate/ today; the database host was not checked.
2. **Context layers and the bundle.** New bundle files do not move any tracked source the md5s pin. Rerunning `data-raw/vignette_chinook.R` to add them would, though:
   - It rewrites `bulk_segments.rds`, whose md5 `method.rds` pins (data-raw/vignette_method.R:496), so test-vignette-data.R:100-106 fails unless the bytes are identical.
   - It also needs the run's schema, the ignored grade table and matching evidence and walk (data-raw/vignette_chinook.R:106-111, 161-169).
   - Write the layers from a separate script instead (details under Gap 9).
3. **Renaming STAGE=maps to STAGE=floodplain.**
   - Safe for code: logs are copied by `_compare.*\.txt$` (R/tune_promote.R:309) and the name `floodplain.csv` does not change. 0325 and the data-raw scripts do not read floodplain.csv or the maps log.
   - Text that needs editing: research pages (bull_trout:357, chinook_rearing:228, coho:119, grayling:210, habitat_thresholds:438, rainbow:220, steelhead:168), scripts/README.md:117-118, the 0330 header (lines 7, 32, 65, 71) and the R comments above.
   - The real problem is a different one (Blocker 2).
4. **Literature prior and the checks table.**
   - The prior: yes. There are 116 CH rearing rows in data/literature_evidence.csv (111 quoted, 50 with a model_id) and 9 in ip_model_registry.csv. The current page already cites rows by number (research/chinook_rearing_tuned.md:20-33: rows 37, 43, 45-50, 52-53, 57, 120, 403, 412, 470).
   - But there is no id column, and 11 CH-rearing rows share a citation/page/variable/parameter/bound key. Row numbers are not stable ids, and backlog batch 5 appends to and audits this CSV (planning/backlog.md:108). Choosing rows is hand work for the block. The generator can only assert, for each cited row, its expected content (citation_key, value).
   - The checks: no single table holds them in order with a direction. They are spread over the summary columns (`default_in_region`, `honest_dev_*`, `seeds_*`, `boot_rec_share`, `*_ddev`/`*_se`), CH_rear_honest/seeds.csv and data/compare/CH_rear_checks.csv (fdis_visits, bcfishobs_outside). `method.rds$stability` holds a subset (data-raw/vignette_method.R:508-509). No column anywhere says which way a check points. data/tune/*_smoke.csv (check, value, limit, pass) is a shape to copy.
5. **Uncovered tasks.** Yes, several (Gap 1 below).
6. **More than one PR.** Yes, see Scope.

## Blocker

1. **`gq_style_qml()` cannot style the comparison GeoPackage.** Phase 1 has it write the GeoPackage's QGIS styles, but the function returns a QML file shipped for one of gq's own layer keys. It takes `layer_key` and `template` only and errors on unknown keys (gq R/gq_style_qml.R:99-140, origin/main the same). No gq 0.21.0 export writes QML from a custom registry (NAMESPACE on origin/main). So the "rule class" and "grade class" styles from `inst/gq/compare.csv` have no QML source. The options are a knowledge-side QML writer driven by the registry, or a gq issue. Either way it is unplanned work and a candidate to split. Two more pieces are missing:
   - The GeoPackage has no column to classify on. `gpkg_one()` writes the raw segments (`rearing_default`, `rearing_tuned`, … at scripts/0330-compare.R:346-372); `rule_class` exists only in R (R/compare_map.R:153-161).
   - Writing a `layer_styles` table needs a planned route: sf non-spatial write or RSQLite. RSQLite is not in DESCRIPTION.
2. **Neither on-demand stage can run on a promoted run, and the floodplain table is stale.**
   - `TUNE_DIR` must be `data/tune/candidate/<run>` (scripts/0330-compare.R:101), and promotion moves a key's segments out of the candidate (R/tune_promote.R:284, 389-395). So "STAGE=gpkg stays as the on-demand step" and the owed "Run 0330 STAGE=floodplain … so data/compare/floodplain.csv is written" cannot run against the published run. Its output would also land in a candidate needing a promotion on Al's word.
   - CH rearing's floodplain rows are #65's (2026-10-19, commit 4534f404). The #145 promotion (91ae2f5d) drew no floodplain and kept them. floodplain.csv has no rule, run or config column to detect this (header: `flag,…,rule` where rule is `default`/`tuned`).
   - So "What it draws … floodplain ha" on the generated CH page would quote a superseded rule. Decide one of: (a) the page withholds floodplain hectares; (b) STAGE=gpkg/floodplain accept the promoted directories; (c) a new compare run plus promotion first. Add run, config_sha and tuned_rule columns to floodplain.csv in any case.
3. **GPKG opt-in breaks every documented `GPKG=FALSE` call.** The plan's proof says "anything else refuses", but CLAUDE.md:573-574, scripts/README.md:113 and the 0330 header (lines 32, 47, 70) all tell users to pass `GPKG=FALSE`. Accept FALSE as well. The parse also lives in a script (scripts/0330-compare.R:90), so for the planned test to exist it has to move into an `R/` helper.

## Gap

1. **Issue tasks in neither the plan nor the split-off issue:**
   - #81 task 5: each GeoPackage segment carries flow, width, gradient, distance, stream order and "which of link's rules kept it", including wetland area. Today's segments carry `edge_type` and the default branch, but not the waterbody area; vignette_chinook.R:322-333 computes that separately.
   - #81 task 3: the class column (kept/lost/gained), as Blocker 1.
   - #90 item 5: "a test fails when a figure is older than the tables it reads". The plan tests the page's run_uid only.
   - #90 item 7: one data bundle per key (generalising vignette_chinook.R); the readiness test before a key gets an article; example watershed groups ranked from the data.
   - #90 item 6: pointer files for the other seven `_tuned.md` files. The split-off body should name them.
   - #64 task 4: "Chinook rewritten to it first (with its vignette…)". The article is not touched. The backlog also says batch 7 is "the template … then coho" and that chinook's rewrite is #118's (planning/backlog.md:122-123). The plan swaps coho for chinook and puts coho in the split-off without saying so.
   - #64: the "season of flow" under Left open needs data/life_history_timing.csv, which the plan does not name. #64 also says the prior's standing comes from #139's register, and #139 is open.
   - #77 task 2 says "rerun data-raw/vignette_chinook.R". The plan should say why it does not.
2. **0335 still runs `data-raw/readme_figure.R`** (scripts/0335-promote.R:10, 161-162). Renaming it to `example_maps.R` needs that list changed, and also CLAUDE.md:608, scripts/README.md:127 and data-raw/README.md:9. If example_maps.R also draws the generated pages' map panels, a promotion would redraw page figures without regenerating the pages. Keep the README figure as its own target, or let tuning_reports.R own page figures. Either way, add "regenerate research/tuning/ pages" to 0335's "NOT DONE HERE" list (lines 30-32) and to CLAUDE.md's promotion paragraph (lines 613-616). Otherwise the new run_uid test fails after every promotion.
3. **Stale GeoPackages become the normal state.** With GPKG off by default, `plan_dir` keeps a fitted key's tracked GeoPackage when the run wrote none and only notes it (R/tune_promote.R:273-281). data/compare/gpkg/ will then routinely hold an older run's file with nothing marking it. Archive it on promotion, or write a run-stamp table into the GeoPackage. CLAUDE.md:120-121 describes gpkg/ as 0330's current output.
4. **Docs the plan's list misses:**
   - inst/NOTICE.md:13 and :26 (the research/fig maps and the floodplain panel)
   - data-raw/README.md:9
   - scripts/0335 header lines 10 and 38
   - scripts/README.md:122 and :127
   - man/knw_tune_promote.Rd
   - the knw_compare_map roxygen example (R/compare_map.R:48)
   - the frozen scripts that write the moved figures (scripts/0297-ch-rule-tune.R:122, scripts/0298-ch-rule-compare.R:444)
5. **New tracked sources need NOTICE rows and settled terms (CLAUDE.md:147-151):**
   - Esri tiles baked into `man/figures/readme-bulk.png` (shipped in the package) and into research/tuning/fig. NOTICE has no Esri row today; Esri's terms are free noncommercial use with attribution (R/compare_map.R:315-317). gq ≥ 0.19.0 sets a `credit` attribute on tiles; draw it and set the gq floor accordingly.
   - Town names: BC Geographical Names is "Access Only". The existing pattern reads it through bcdata and keeps names only (inst/NOTICE.md:17-22; data-raw/vignette_cut_points_places.R:82). The plan names `gns_geographical_names_sp` from the database.
   - The keymap's BC outline: gq has no province layer (gq R/gq_tmap_keymap.R:31-35). Name its source.
6. **Dependencies:**
   - `maptiles`, which `gq_basemap_tiles()` requires, is not in DESCRIPTION Suggests (DESCRIPTION:46-67).
   - The gq version is unpinned (Remotes only).
   - With colours in `inst/gq/compare.csv`, `knw_compare_mapgl()` and its tests (which run without gq today) need a fallback that reads the CSV directly, or gq becomes required for those functions.
   - The integer `match_expr` mapping (R/compare_map.R:245-251) depends on the registry keeping class order.
7. **chinook_rearing_tuned.md lines 1-231 have no stated destination.** They hold the current write-up: prior, evidence, rule, ladder, intercept fit, grade, structures. Only #54's record (lines 232-660) goes to the archive. Say what moves into the CH block or page and what is dropped. The plan's "every reference" pass must also cover research/chinook_stream_size.md, research/fdis_export.md and research/habitat_thresholds_tuned.md (git grep).
8. **What the generator asserts is undefined.** If the block's numbers are placeholders filled from tables, a number cannot "move"; the claims around it can, such as "default outside the region". The block needs recorded expectations, values or predicates, for the refusal and the planned mutation test to mean anything.
   - Some Evidence numbers come from ignored visits (research/chinook_rearing_tuned.md:37-44), not data/tune. Name the source; for CH it could be the chinook bundle.
   - The detection-curve and profile figures exist only as article chunks (vignettes/tuning-chinook-rearing.Rmd:254 "profile"). Reusing them for any key means extracting functions: a refactor of the article, which falls under CLAUDE.md's render-and-diff rule.
9. **Context layers belong in a separate script.** Write them with e.g. `data-raw/vignette_context.R` into new files, rather than rerunning vignette_chinook.R. Then:
   - add the files to the shipped-files list (tests/testthat/test-vignette-data.R:10);
   - pin their `map_group` to `chinook_rearing.rds$meta$map_group`.
10. **The "checks with direction" and "how firm" columns have no register.** They need one (e.g. under inst/method/). Any threshold that shapes the verdict needs a settings.csv row, or test-settings-register.R cannot see it (CLAUDE.md:47-50). This is also #90's readiness test.

## Ordering

1. Phase 2 rewrites the glob line in research/chinook_rearing_tuned.md:230, then Phase 3 moves that file. Do the move first, or skip that page in Phase 2.
2. The gq upgrade (Phase 0) can itself change the README figure: gq 0.18.0 changed per-class opacity drawing. Take the "defaults unchanged" baseline after the upgrade, not against the committed PNG.
3. The CH page would merge quoting floodplain hectares before the owed floodplain rerun (Blocker 2).
4. Phase 1 changes the GeoPackage and promotion before Phase 2 removes the 97 PNGs. That order is harmless, but the NEWS entry should cover all three breaking changes: the GPKG default flip, the removed `fig_dir`, and STAGE renamed. NEWS currently sits only in Phase 2. Consider keeping `STAGE=maps` as a refusal that names its replacement.

## Assumption

1. Phase 0's check "grade md5 matches CH_rear_grades_record.csv" cannot be done from the segments; the record is of the grade table. Compare the md5 of `../knowledge/data/compare/CH_rear_segments.rds` with `chinook_rearing.rds$meta$md5_local` and `method.rds$meta$md5_local`. Also, `COMPARE_DIR` is read only by 0336 and compare_structures_check.R. The new generator must take it, and vignette_chinook.R hardcodes `data/compare/` (line 350).
2. Pinning only `run_uid` is weak. In the summary, `run_uid` is link's build and `tune_run` is the tuning run (data/tune/CH_rear_summary.csv columns 35-36). A retune on the same link build would pass the test. Pin `tune_run`, and the compare's `config_sha`.
3. findings.md lists `gq_style_qml(layer_key, template)` as if it fits Phase 1. Its signature is the evidence that it does not.
4. On the plan's tick of #81's first open task against #79: #79's title is the one-SE heuristic, but NEWS 0.4.8 shows the mapgl/Esri map landed with it (NEWS.md:242-243). The tick holds, though the legend sits top-left, not bottom-left as #81 decided (R/compare_map.R:253-256).
5. `research/tuning/<key>.md` (e.g. CH_rear.md) differs from #90's `<species>_<stage>.md` and research/'s lowercase `<topic>.md` convention (research/README.md:4). Decide the name.

## Acceptance

1. "The site builds the three articles" never runs `map-static`, which runs only when not on the site (`eval = !on_site`, vignettes/tuning-chinook-rearing.Rmd:29, 153). Render it off-site after installing the branch, and check whether R CMD check (which builds vignettes) now needs network for tiles.
2. The site's article shows `knw_compare_mapgl()`, which has no scale control. #77's reader on the website still sees no scale. Consider `add_scale_control` in mapgl.
3. The basemap tests need network: skip them offline and on CRAN.
4. "Run twice, identical bytes" cannot hold for PNGs built from fetched tiles. Limit it to the .md, or record the tile inputs.
5. Tests that read `research/tuning/` must skip where research/ is absent (.Rbuildignore:15), as `has_src` does.
6. The GeoPackage style test should open a fixture, read `layer_styles`, check every registry class appears, and check that one style is marked default.

## Scope

Beyond the split already made, this is still two PRs' worth. Batch 6 carries:
- the 0330 refactor;
- the registry move;
- a QML writer gq lacks;
- four new map arguments with tiles, places and keymap sources and licences;
- a new context bundle;
- 97 removals;
- the promotion API change.

Batch 7 carries:
- the generator and its assertion design;
- figure functions extracted from the article;
- the checks/firmness register;
- the 22-key table;
- the chinook move.

By #173's own rule, carry batch 6 here and file batch 7 (template, generator, CH page) as the split-off. The six other keys stay a further issue or fold in. At minimum, split out the GeoPackage QML style (Blocker 1) and the promoted-run gpkg/floodplain route (Blocker 2) as their own issues. Each split-off body must name #173. #81's and #90's untouched tasks (Gap 1) should be ticked, moved or pointed to explicitly in Phase 4.

### Critical files for implementation
- /Users/airvine/Projects/repo/knowledge-wct/scripts/0330-compare.R
- /Users/airvine/Projects/repo/knowledge-wct/R/tune_promote.R
- /Users/airvine/Projects/repo/knowledge-wct/R/compare_map.R
- /Users/airvine/Projects/repo/knowledge-wct/scripts/0335-promote.R
- /Users/airvine/Projects/repo/knowledge-wct/data-raw/vignette_chinook.R (with data-raw/vignette_method.R:496 and tests/testthat/test-vignette-data.R)
- /Users/airvine/Projects/repo/gq/R/gq_style_qml.R (origin/main)
