# Task: Chinook rearing as a vignette: how the threshold was chosen and what it draws, in plain language (#62)

## Problem

- The research files are the durable verdict with provenance, and read as such: `habitat_thresholds_tuned.md`'s Method is five dense bullets ("held-out binomial deviance (cloglog, with log area, data set, era and the group), five stratified group folds"), and `chinook_rearing_tuned.md`'s vignette notes sit at line 442 of 456. Neither says in plain words why a threshold was chosen (#57 review, 2026-10-18).
- Chinook carries the fullest story: an earlier 55-group tuning (#54), a settled open floor (0.75 m³/s), the near-a-river exception that no other species needs, the largest regeneration comparison (125 groups), and a grade-weighted result that moves the other way from the kilometres (27,681 → 32,018 graded km on 12 % fewer km).
- knowledge's article answers "why this threshold"; link's answers "what this threshold draws". The thresholds table (`knowledge/thresholds/v1`) is the contract between them, and link's article waits on its configuration reading it (NewGraphEnvironment/link#346).

Plan approved 2026-10-18 and reviewed by a Plan agent before it was written into the issue body; the
phases below are that plan verbatim.

## Phase 1: Vignette plumbing
- [ ] `DESCRIPTION`: `VignetteBuilder: knitr`; add `knitr`, `rmarkdown`, `bookdown`, `ggplot2`, `png` to Suggests
- [ ] `.Rbuildignore`: add `^data-raw$`, `^doc$`, `^Meta$`
- [ ] `vignettes/.gitignore` for knitr debris (`*.html`, `*.R`), as gq has; `data-raw/README.md`, one paragraph
- [ ] `pkgdown::check_pkgdown()` still clean (no `articles:` section needed)

## Phase 2: `data-raw/vignette_chinook.R` writes `inst/vignette-data/`
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

## Phase 3: `vignettes/chinook_rearing.Rmd`
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

## Phase 4: The research files point at the article
- [ ] `research/habitat_thresholds_tuned.md`: one plain-language paragraph under the header line, above "The
      question"; the specification stays
- [ ] `research/chinook_rearing_tuned.md`: "For a link vignette" becomes a pointer to the article's URL
      (`https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html`) and to link#346; the
      `**Status:**` line stops saying "written to lift into a link vignette"
- [ ] `research/README.md` and the repo `README.md`'s "What is known" list name the article
- [ ] `scripts/README.md`: one line after `0330` naming `data-raw/vignette_chinook.R` as what refreshes the
      article's data after a rerun

## Phase 5: Audit, check, PR
- [ ] Row-by-row audit of the article's prose claims against the saved tables and the two research files
- [ ] `devtools::test()`, `devtools::check()` (installed-size NOTE read, not ignored), `lintr` on `R/`, the test
      and the data-raw script
- [ ] `/code-check branch`
- [ ] `/planning-archive`, `/gh-pr-push`; the PR's pkgdown run builds the article; after merge confirm the deploy
      provenance and that the article URL the research files cite answers 200

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (each commit, or once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

## Decisions taken (conventional defaults, stated)
- Three map panels (rules, grade, floodplain by grade), not two: the floodplain hectares are in the issue
  and the panel is what makes them legible; cost is one 0.47 MB raster and a `flooded` dependency in
  `data-raw/` only.
- rds (xz) for the vignette data, not GeoPackage: five times smaller for the same geometry.
- ggplot2 for the profile and curve figures, png + grid for the map read-back (both added to Suggests).
- Article and script names as the issue writes them: `vignettes/chinook_rearing.Rmd`,
  `data-raw/vignette_chinook.R`.
- Branch: `62-chinook-rearing-as-a-vignette-how-the-th` (the slug rule cuts one letter shorter than the issue predicted).
