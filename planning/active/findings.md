# Findings — Chinook rearing as a vignette: how the threshold was chosen and what it draws, in plain language (#62)

## Issue context

**If done:** a reader who has never seen the tuning can follow, for chinook rearing, how the recommended rule was chosen and what it draws, in one pkgdown article that runs from saved tables: what link does now, the candidate rules, how a rule is scored on held-out watershed groups, the region the data cannot separate, the pick, the checks, the grade, and what changes on the ground. **If never:** the method lives only in `research/habitat_thresholds_tuned.md`'s specification bullets and the chinook file's 456 lines, both written for the person who did the work, and every adopter of the thresholds table re-derives the reading.

## Problem

- The research files are the durable verdict with provenance, and read as such: `habitat_thresholds_tuned.md`'s Method is five dense bullets ("held-out binomial deviance (cloglog, with log area, data set, era and the group), five stratified group folds"), and `chinook_rearing_tuned.md`'s vignette notes sit at line 442 of 456. Neither says in plain words why a threshold was chosen (#57 review, 2026-10-18).
- Chinook carries the fullest story: an earlier 55-group tuning (#54), a settled open floor (0.75 m³/s), the near-a-river exception that no other species needs, the largest regeneration comparison (125 groups), and a grade-weighted result that moves the other way from the kilometres (27,681 → 32,018 graded km on 12 % fewer km).
- knowledge's article answers "why this threshold"; link's answers "what this threshold draws". The thresholds table (`knowledge/thresholds/v1`) is the contract between them, and link's article waits on its configuration reading it (NewGraphEnvironment/link#346).

## Proposed

- [ ] `vignettes/chinook_rearing.Rmd` (`bookdown::html_vignette2`), in the plain-language order: what link does now; the rules asked about; how a rule is scored; the region; the pick and why it departs least from `default`; the stability checks; the curve and the grade; what it draws (one Bulkley map, the km table, the floodplain hectares); what the recommendation is not; one link to link's article when it exists.
- [ ] Data from a `data-raw/vignette_chinook.R` that saves the needed rows of `data/tune/CH_rear_*`, `data/compare/CH_rear_*` and one group's segments under `inst/vignette-data/`, so the article runs on CRAN-style checks with no database.
- [ ] A one-paragraph plain-language opening at the top of `research/habitat_thresholds_tuned.md`, above the specification, saying the same thing in prose; the specification stays.
- [ ] `research/chinook_rearing_tuned.md`'s "For a link vignette" section becomes a pointer to the article.

Depends on #57 (merged). Relates to NewGraphEnvironment/link#346.



## Exploration notes (what the next session would otherwise re-derive)

- **No vignette machinery yet.** No `vignettes/`, no `data-raw/`; `DESCRIPTION` has no `VignetteBuilder`, and
  knitr, rmarkdown, bookdown, ggplot2, png are not in Suggests. `.Rbuildignore` excludes `data/`, so nothing
  under `data/` reaches an installed package. `.github/workflows/pkgdown.yaml` already uses `needs: website`
  and `local::.`: Suggests are installed, vignettes build, and the Remotes (gq, flooded, fresh) are public.
  Nothing CI-side changes.
- **Sibling pattern (link, flooded):** `bookdown::html_vignette2`, `VignetteBuilder: knitr`, a hidden `load`
  chunk reading `system.file("vignette-data/…", package = …, mustWork = TRUE)`, data written once by a
  `data-raw/` script run against the database, `^data-raw$` (and flooded's `^doc$`, `^Meta$`) in
  `.Rbuildignore`, `fig.cap` on every figure, no `\@ref()` (a literal under pkgdown), no footnotes, loud
  `library()` calls rather than `requireNamespace` guards. No sibling has an `articles:` section in
  `_pkgdown.yml`; pkgdown lists the article itself.
- **pkgdown renders articles with `self_contained = FALSE`** (`pkgdown:::rmarkdown_setup_pkgdown`), so a png
  written to a tempfile and shown with `knitr::include_graphics()` is a broken image on the site. The map is
  drawn in an ordinary figure chunk: `knw_compare_map()` writes its png to a tempfile, the chunk reads it back
  with `png::readPNG()` and draws it with `grid::grid.raster()` at the png's own size (12 × 4.6 in at 150 dpi
  is 1800 × 690 px, what `tmap_save` wrote), so pkgdown copies it into `articles/chinook_rearing_files/`.
- **What the saved tables carry.** `data/tune/CH_rear_tune.csv` (2,795 rules: `ddev_best` = held-out deviance
  above the best; `se_diff` = √groups × sd of the per-group differences; `in_region` = `ddev_best ≤ se_diff`
  and converged; `pick`, `recommended`; `n_in`, `n_detect_in`, raw rates; `boot_region_share`,
  `boot_rec_share` over 200 group resamples), `CH_rear_summary.csv` (one row: nested-selection deviance
  totals 1,234.5 recommended / 1,347.0 `default` / 1,382.5 null; `seeds_same_rec` 0, `seeds_rec_in_region`
  4 of 4; `boot_rec_share` 0.22), `CH_rear_curves.csv` (3 marginal curves × 120 points: `rate`, `rel_rate`
  relative to the pick's threshold with CI, `threshold`), `CH_rear_groups.csv` (43 groups, folds),
  `data/thresholds.csv` (`CH_rear_v1` rows), `data/compare/CH_rear_{compare,change,checks}.csv` (full
  precision; `compare.csv` is the same rounded to 3 dp) and `floodplain.csv` (CH rows, 16 catalog groups).
- **What they do not carry.** (1) Per-seed and per-fold picks: in the ignored `data/tune/CH_rear_score.rds`
  (`$seeds`: seeds 55, 57, 58 recommend the same rule at 7 % instead of 9 %, seed 56 recommends
  `mad>=0.5|g<=0.0549|Q3@D2000`, the main pick is inside every seed's region and `default` outside;
  `$honest`: five folds, fold 4's pick scores 233.9 against `default`'s 230.3, the one fold it loses) and
  printed in the tracked `scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt:538-554`. (2) The grade's
  reference rate 0.1457 and the counts 856,244 accessible / 852,431 graded: log line 1446 only. (3) The
  scoring's inputs, `fwa_gradient`, `cw_deploy`, `mad_pick`, walks on `pick`, seeds 54 + 55:58, 200 bootstrap
  resamples, `d_floor` 200 m: function formals (`knw_rule_in()`, `knw_tune_run()`), not tables. (4) Visits per
  group: `data/fdis/` is ignored; the article gives 4,490 visits / 215 detections / 43 groups from `tune`.
- **Two population layers.** `summary`: 7,123 visits, 216 detections, 104 groups after the population
  filters; `tune`: 4,490 / 215 / 43, the modelled set (groups with both outcomes). Every count names which.
- **The pick criterion as the code applied it.** All 23 region rules have `departures = 3`, so "fewest
  departures from `default`" ties and `.tune_pick()` takes the lower score: the pick is the best-scoring rule,
  and `recommended` equals it because `exc_d = 1000 ≥ 200`. The article says: every rule the data cannot tell
  from the best departs from `default` in all three components, so the best scorer is recommended.
- **`data/compare/CH_rear_segments.rds` has no geometry** (5.76 M rows, 23 columns, ignored). `0330` joins
  `fresh_default.streams` geometry and water (`fwa_lakes_poly` ≥ 10 ha ∪ `fwa_rivers_poly`) at map time, with
  `st_zm(drop = TRUE)`, `id_segment` numeric, `rearing_default/tuned` → `flag_default/tuned`, and builds the
  floodplain-by-grade raster from the catalog's `bulk_floodplain.gpkg` (cached under `data/compare/catalog/`,
  fetched from the public bucket by `gpkg_of()` when absent) through `knw_floodplain_ha()` on **all** the
  group's segments and `flooded::fl_valley_join()`. Non-accessible segments carry no grade (0 of 70,955), so
  the raster is the same whichever subset the map keeps.
- **Measured in plan mode (BULK).** 87,641 segments, 1.05 M vertices, 14,642 km; accessible 16,686 segments,
  304k vertices, 5,164 km. As xz rds: accessible 2.04 MB raw, 0.84 MB at `st_simplify(dTolerance = 10)`
  (a 4 in panel at 150 dpi is ~250 m/px, so invisible); water 0.43 → 0.08 MB; a GeoPackage of the same is
  4 MB, so rds. The floodplain raster (88 s to build; 5,050 × 3,976 cells, 607,104 graded) is 0.47 MB as
  `INT1U` grade × 100, nodata 255, DEFLATE. Its join summary reproduces `floodplain.csv`'s BULK CH rows
  (35,847 / 26,126 / 54,642 ha), and graded cells × 0.09 ha = 54,639 = accessible ha − `ha_grade_na`.
- **`knw_compare_map()`** (`R/compare_map.R`) takes an `sf` with `accessible`, `stream_order`, `grade_class`,
  `flag_default`, `flag_tuned`, drops `!accessible` itself, builds its factors itself, and draws `fp_cells`
  with breaks on 0–1, so the article divides the raster by 100.
- **The site is public, the repo is not.** `gh repo view` says PRIVATE on 2026-10-18 although `CLAUDE.md`
  says public since #56; GitHub Pages serves publicly either way, `research/` is `.Rbuildignore`d, so this
  article is the first rendering of #57's results anyone outside can read. Intended by the issue; said here.
- link's article does not exist (NewGraphEnvironment/link#346 open, part 2 unstarted); the article points at
  the issue.

## Plan (approved 2026-10-18, reviewed by a Plan agent; `/planning-init 62` scaffolds from it)

### Phase 1: Vignette plumbing
- [ ] `DESCRIPTION`: `VignetteBuilder: knitr`; add `knitr`, `rmarkdown`, `bookdown`, `ggplot2`, `png` to Suggests
- [ ] `.Rbuildignore`: add `^data-raw$`, `^doc$`, `^Meta$`
- [ ] `vignettes/.gitignore` for knitr debris (`*.html`, `*.R`), as gq has; `data-raw/README.md`, one paragraph
- [ ] `pkgdown::check_pkgdown()` still clean (no `articles:` section needed)

### Phase 2: `data-raw/vignette_chinook.R` writes `inst/vignette-data/`
- [ ] Header in the `scripts/` style: reads `data/tune/CH_rear_{tune,summary,curves,groups}.csv`, the local
      ignored `CH_rear_score.rds` (`$seeds`, `$honest`), `data/thresholds.csv`,
      `data/compare/CH_rear_{compare,change,checks}.csv`, `floodplain.csv`, `fresh_default.streams` and
      `whse_basemapping` water through `PG*`, the catalog's `bulk_floodplain.gpkg` (fetched as `0330` does when
      not cached); needs `flooded` with #89; writes the three files below; run `Rscript data-raw/vignette_chinook.R`
      from the repo root with `pkgload::load_all()`, after any `0320`/`0330` rerun
- [ ] `chinook_rearing.rds`: one named list: `tune` (all 2,795 rules, the columns the article uses), `summary`,
      `groups`, `curves`, `thresholds` (CH rows), `compare` (all CH rows incl. `ALL`, full precision), `change`,
      `checks`, `floodplain` (CH rows), `seeds`, `honest`, and `meta`: link `run_uid`, `link_sha`, evidence
      version, the grade reference rate and counts (from the log line, with the log path), the scoring's
      constants read from the function formals (`cols`, `src`, seeds, `n_boot`, `d_floor`), `tools::md5sum()`
      of every source file at write time, and the date written
- [ ] `0320` also writes `<key>_seeds.csv` and `<key>_honest.csv` from `r$score` so the next run needs no rds
      (writer change only; this run's files come from `score.rds`, and the script asserts the seeds table
      equals the log's)
- [ ] `bulk_segments.rds` (xz): BULK accessible CH segments as an `sf`, EPSG:3005, `id_segment`, `blue_line_key`,
      `stream_order`, `accessible`, `grade`, `grade_class`, `flag_default`, `flag_tuned`, `length_metre`;
      `st_zm`, `st_simplify(dTolerance = 10)`; geometry pulled for all BULK segments (the raster join needs
      them), subset to accessible after
- [ ] `bulk_water.rds` (xz): lakes ≥ 10 ha and rivers as `0330`'s `water_of()`, simplified at 10 m
- [ ] `bulk_fp_grade.tif`: floodplain cells by the owning segment's grade, built as `0330` builds `fp_cells` on all
      BULK segments; `INT1U` grade × 100, `NAflag = 255`, DEFLATE; the script asserts the join summary equals
      `floodplain.csv`'s BULK CH rows before writing
- [ ] Record each file's size and the directory's in `progress.md` (about 1.6 MB; the installed-size NOTE counts
      `doc/` too, so read it if it appears and say so rather than trim)
- [ ] `tests/testthat/test-vignette-data.R`, skipped when the source tree's `data/` is absent (as
      `test-data-dir.R` skips): `meta$md5` equals `tools::md5sum()` of each live source file (the saved copy is
      stale after a rerun); the segments' km by rule equals `compare`'s BULK row (`length_metre` is carried, so
      simplification cannot move it); the raster's graded cells × 0.09 equals BULK accessible ha −
      `ha_grade_na` within 1 ha; the saved recommended rule equals `thresholds`' `CH_rear_v1` rule

### Phase 3: `vignettes/chinook_rearing.Rmd`
- [ ] `bookdown::html_vignette2` header and setup chunk as link's; hidden `load` chunk reading the three files
      through `system.file(mustWork = TRUE)`; `library(knowledge)` for `knw_compare_map()`
- [ ] Sections in the issue's order, each a reader's question: what link draws now (`default`'s four branches
      and three passes, in words); the rules asked about (the grid in words, 2,795 counted from `tune`); how a
      rule is scored (held-out groups, the folds from `groups`, what the deviance and the SE mean, the scoring
      inputs from `meta`, which population each count names); the region (the one-SE band; a figure of each
      component's profile from `tune`; the ranges computed, not typed); the pick (all region rules depart in
      three components, so the best scorer; the `default`-vs-recommended raw-rate table from `tune`); the
      stability checks (`seeds`, `honest` per fold incl. the fold it loses, bootstrap shares, worded as the data
      say); the curve and the grade (the three marginal curves from `curves` with thresholds marked; the grade
      definition and reference from `meta`; CH km by grade class from `compare`'s `ALL` row); what it draws (the
      Bulkley three-panel map through `knw_compare_map()`, read back as a figure chunk; the km table for all 125
      groups and BULK; `change` by reason; floodplain hectares for the 16 catalog groups and BULK); what the
      recommendation is not (limits, one list); one sentence pointing at link#346; #54's 55-group figures
      mentioned in one sentence at most, never restated as #57's
- [ ] Every number in the prose computed inline from the saved list, except the spec constants, which come from
      `meta`; every figure has `fig.cap`, every table `caption =`; no `\@ref()`, no footnotes; figures sized for
      the article column
- [ ] Render locally (`pkgdown::build_article("chinook_rearing")` into the ignored `docs/`), read the HTML and
      the map png: every `<img src>` resolves under `docs/articles/`, captions numbered, map legend names every
      class drawn and the floodplain legend shows five classes on 0–1, `footnote-ref` count 0, no literal `\@ref`

### Phase 4: The research files point at the article
- [ ] `research/habitat_thresholds_tuned.md`: one plain-language paragraph under the header line, above "The
      question"; the specification stays
- [ ] `research/chinook_rearing_tuned.md`: "For a link vignette" becomes a pointer to the article's URL
      (`https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html`) and to link#346; the
      `**Status:**` line stops saying "written to lift into a link vignette"
- [ ] `research/README.md` and the repo `README.md`'s "What is known" list name the article
- [ ] `scripts/README.md`: one line after `0330` naming `data-raw/vignette_chinook.R` as what refreshes the
      article's data after a rerun

### Phase 5: Audit, check, PR
- [ ] Row-by-row audit of the article's prose claims against the saved tables and the two research files
- [ ] `devtools::test()`, `devtools::check()` (installed-size NOTE read, not ignored), `lintr` on `R/`, the test
      and the data-raw script
- [ ] `/code-check branch`
- [ ] `/planning-archive`, `/gh-pr-push`; the PR's pkgdown run builds the article; after merge confirm the deploy
      provenance and that the article URL the research files cite answers 200


## Decisions taken (conventional defaults, stated)
- Three map panels (rules, grade, floodplain by grade), not two: the floodplain hectares are in the issue
  and the panel is what makes them legible; cost is one 0.47 MB raster and a `flooded` dependency in
  `data-raw/` only.
- rds (xz) for the vignette data, not GeoPackage: five times smaller for the same geometry.
- ggplot2 for the profile and curve figures, png + grid for the map read-back (both added to Suggests).
- Article and script names as the issue writes them: `vignettes/chinook_rearing.Rmd`,
  `data-raw/vignette_chinook.R`.
- Branch (next session): `62-chinook-rearing-as-a-vignette-how-the-thr`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
