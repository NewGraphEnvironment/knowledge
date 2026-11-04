# Task: Chinook article: answer and map first, the river effect as a figure, detail in tables; methods article opens with what the map was for (#143)


`vignettes/chinook_rearing.Rmd` runs to about 1,680 words of prose. It opens with the company name, puts the map near the end, and repeats the method that `vignettes/habitat_thresholds.Rmd` is the home for. "Why does a nearby river matter?" carries its point in a table of fitted rates, and the stricter-bar table is hard to read. The methods article starts straight into the steps, with no plain account of what the existing map was for.

The change is to prose only. Every figure and table below reads elements already in `inst/vignette-data/chinook_rearing.rds` (`surface`, `tune`, `checks`, `compare`, the Bulkley segments), so neither bundle is rebuilt and no promotion is needed. Neither bundle pins its own Rmd.


## Decided at the gate

- This branch takes the chinook article's structure and tone from #118 (and #64's chinook part); #118 keeps the file
  renames, the `_pkgdown.yml` menu and the bundle rebuild, after this (Al, 2026-11-03; written into #118's body).
- The stricter-bar table stays its own table in "How sure are we?", not a column of the before/after table (Al, 2026-11-03).
- Background on bcfishpass, link and fresh lives in the methods article's opening; the chinook article links it in one
  sentence (Al, 2026-11-03).
- bcfishpass links are pinned to commit `3bd2824c300c5f9c0c041380d412a52987df1ebb`: New Graph's and the Canadian Wildlife
  Federation's `parameters_habitat_thresholds.csv`, and `model/02_habitat_linear/sql/load_habitat_linear_ch.sql`.

## Constraints found in exploration

- **Register phrases stay verbatim.** `inst/method/settings.csv` rows `snap_limit`, `snap_limit_code` and `se_strict`
  name text in `vignettes/chinook_rearing.Rmd` ("nearest stream, kept when it lay within {value} m.", "kept when it lay
  within {value} m of the point", `se_strict <- {value}  #`), which `tests/testthat/test-settings-register.R` resolves.
  Editing the register would move `method.rds`'s pinned md5 and force a bundle rebuild (#118's problem), so the rewrite
  keeps those three strings exactly.
- **Citations must stay in prose.** `data-raw/vignette_bib.R` reads keys with `rbbt::bbt_detect_citations()`, which skips
  code chunks, and requires the chinook article to cite fwapg, bcfishpass, bcfishobs, link, fresh and wet
  (`all_tools = TRUE`). So the end methods table is a literal markdown pipe table with inline `r` numbers, not a kable.
- **kableExtra** is not in `Suggests`; the stricter-bar table's note and font need it (`pkgdown-publishing.md`: HTML kable +
  `kable_styling()` + `footnote()`).
- **Zotero** did not answer Better BibTeX's probe at planning time; the bib phase needs it running, and the Data Catalogue
  record needs an item in the group library (Web API, `ZOTERO_API_KEY`).

## Phase 1: Methods article opens simply (`vignettes/habitat_thresholds.Rmd`)
- [x] Replace the opening paragraph with three short ones: what the map was for (bcfishpass ranks where fieldwork goes among
      >500,000 crossings and dams; the Province publishes its access model; its habitat thresholds are in its repository,
      New Graph's and CWF's files pinned; set to screen sites), what tuning adds (link and fresh hold each rule as a config
      row; tuning scores rules against where crews caught fish, with room for the biology), what the article covers.
- [x] Move the one-SE and cross-validation citations (Breiman et al. 1984 as cited in Chen & Yang 2021, Hastie et al. 2009,
      Chen & Yang 2021, Bengio & Grandvalet 2004, Bates et al. 2024) into "How are two rules told apart?", in a few plain
      sentences.

## Phase 2: Chinook article rewritten (`vignettes/chinook_rearing.Rmd`)
- [x] 1. Opening: the answer, no company name; link and bcfishpass cited at first mention; numbers inline from `dflt`,
      `rec`, `all_row`; ends with a link to the methods article.
- [x] 2. The map straight after (static and site versions, chunks as now); its caption says how to read orange and green; the
      paragraph stays, because the site's interactive map has no caption (review 8).
- [x] 3. "What changes?": one before/after table (dials, km across the province, catch rate on and off the habitat from
      `checks`), with the overlap caveat as a table note. Replaces "What does link do now?" and "A check".
- [x] 4. "Why does a nearby river matter?": opens with bcfishpass's order-5 rule (pinned SQL link) and link `default`
      having it off; a figure from `x$surface`: x distance to a river ≥ 3 m³/s (log, 100 m to 50 km), y fitted chance of a
      catch, one line per flow, dashed line at `rec$exc_d`, lines below `rec$size_min` grey beyond it. One sentence beside it,
      guarded (lines within a few points near the river, spread past 1 km).
- [x] 5. "How sure are we?": the principle in plain words, linked to the methods article; the dial profile figure as now;
      the stricter-bar table rebuilt (rows: dials; columns: link now, 1 SE, 1.96 SE; short cells; changed cells bold; smaller
      font; close-call counts in a note); "Two other checks" as a three-row table with each check's direction.
- [x] 6. "Before you use it": same bullets, shorter; drop the earlier longer-ladder history; add the order-5 gap (the tuning
      never scored bcfishpass's exception, so the result beats link's `default`, not bcfishpass's rule).
- [x] 7. "How was this done?": a literal markdown table (records, placement keeping the register phrases, flow, slope,
      candidate dials, scoring, tie-break, what was left out), each row linking the methods article; every tool cited here.
- [x] 8. References, and a "Software and citation" section.
- [x] Keep `se_strict <- 1.96  #` and every existing `stopifnot()` whose sentence survives; drop guards only with their
      sentences (the `ge`/`grad_ext` ones if the history goes); add guards for each new sentence.

## Phase 3: Dependencies, references, render
- [x] Add `kableExtra` to `Suggests`.
- [ ] `Rscript data-raw/vignette_bib.R` with Zotero running; both `.bib` files rewritten. The Data Catalogue record stays a
      link, not a citation (Al, 2026-11-04), so no Zotero item is added.
- [ ] Install the branch (`R CMD INSTALL .`) and render both articles; read each rendered page, figures included at their
      published width.
- [ ] Word counts before and after, of the rendered text minus references (review 11), recorded in `findings.md`.

- [x] Fold in the plan review (`review-plan.md`): wording on bcfishpass's exception and New Graph's set, "none on stream
      lines", the unjoined cap point, a guard, and README's stale gradient and Learn-more line.

## Phase 4: Checks and PR
- [ ] `devtools::test()` (register, vignette-data), `pkgdown::check_pkgdown()`, a local `pkgdown::build_articles()`; no
      `footnote-ref` without a footnotes section.
- [ ] `/code-check branch`.
- [ ] `/planning-archive`, `/gh-pr-push` (SRED cross-reference per memory).

## Validation
- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

**How each change is proved:** every inline number and every pattern a sentence states is a `stopifnot()` in the chunk that
computes it, so the render fails if the bundle stops supporting it; `test-settings-register.R` proves the three register
phrases still resolve; `vignette_bib.R` refuses a key Zotero does not return and requires the six tools; the rendered pages
are read, not just built; the pinned bcfishpass links are fetched once to confirm they resolve.


