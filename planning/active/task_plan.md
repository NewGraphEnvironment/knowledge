# Task: One-SE region: state it as a heuristic, publish 1.96 beside it, and give the article references (#79)

The tuning keeps every rule within one standard error of the best (the "region") and picks the region rule closest to link's `default`. The article says "a gap under one standard error cannot be told from noise". The sources say otherwise:

- The rule was "first proposed for selecting the right sized tree" (Chen & Yang 2021, §1.3, citing Breiman et al. 1984). Hastie, Tibshirani & Friedman (2009) give its only rationale: it "acknowledges the fact that the tradeoff curve is estimated with error, and hence takes a conservative approach" (p. 61); §7.10 (p. 244) uses it with no citation, and its own example picks 9 predictors where the true model has 10.
- Chen & Yang (2021, §6): "there is no evidence confirming that the 1se rule can consistently outperform the regular CV"; the SE it uses can be 100 % over- or underestimated; it helps sparse variable selection and often hurts estimation.
- Bengio & Grandvalet (2004): no unbiased estimator of the variance of K-fold cross-validation exists. Bates, Hastie & Tibshirani (2024): the usual CV variance is too small and its intervals undercover; a nested scheme fixes it.

The threshold decides the result. Recomputed from `data/tune/*_tune.csv` with the same pick rule (fewest departures from `default`, then score, 200 m exception floor), the 1-SE picks reproduce the published ones; at 1.96 SE five of eight species × stages keep `default`:

| rule | `default` behind best (SE) | pick at 1 SE | pick at 1.96 SE |
|---|---|---|---|
| BT rear | 1.58 | MAD ≥ 0.35, ≤ 10.49 % | `default` |
| BT spawn | 1.06 | MAD ≥ 0.75, ≤ 5.49 %, river exception | `default` |
| CH rear | 2.40 | MAD ≥ 0.75, ≤ 9 %, river within 1 km | MAD ≥ 0.75, ≤ 5.49 %, no exception |
| CO rear | 2.47 | MAD ≥ 0.03, ≤ 4 % | width ≥ 1.5, ≤ 4 % |
| GR rear | 0.89 | `default` | `default` |
| RB rear | 2.36 | width ≥ 3, ≤ 9 % | width ≥ 3, ≤ 8.49 % |
| ST rear | 1.42 | MAD ≥ 1, ≤ 8.49 % | `default` |
| WCT rear | 1.33 | width ≥ 1.5, ≤ 4 % | `default` |

The article also has no bibliography (no `bibliography:`, no `[@key]`), and the README's Data and methods names fwapg, bcfishpass and bcfishobs without their author.

## Context

The tuning keeps every rule within one SE of the best and calls a smaller gap "noise". The literature gives 1 SE no
such standing (Breiman et al. 1984; Hastie et al. 2009; Chen & Yang 2021; Bengio & Grandvalet 2004; Bates et al.
2024), and the threshold changes the result: at 1.96 SE, five of eight species × stages keep `default`, and CH rearing
loses its near-a-river allowance. The article (`vignettes/chinook_rearing.Rmd`, ~2,450–2,650 words, 11 sections)
also cites nothing, and the README does not credit fwapg's, bcfishpass's and bcfishobs's author. Outcome: a shorter
article in plain words with the 1.96 table and a bibliography, an interactive Bulkley map on the website, a
`thresholds.csv` that says which rules hold at 1.96, and the Zotero items it cites.

## Decided at the gate

- Al, 2026-10-20 (issue body): keep 1 SE, publish 1.96 beside it; bibliography in the article, none in the README;
  README authorship clause; #80's flow comparison stays out; website-only interactive map (Carto Voyager or
  OpenFreeMap), static map kept for print; the Zotero collections as listed in the issue.
- Al, 2026-10-20 (plan gate; plan approved and "go all phases to pr"): `thresholds.csv` gains two columns, `rule_196` (the pick at 1.96 SE) and `holds_196`
  (TRUE where that pick keeps the row's value). Still `knowledge/thresholds/v1`: nothing is uploaded yet (s3 holds
  only `knowledge/fdis/`, measured 2026-10-20).
- Mechanism (mine): the 1.96 pick is one exported function, `knw_tune_repick()`, used by the article, the research
  files and `knw_thresholds_table()`; the interactive map is a new exported `knw_compare_mapgl()` that returns the
  widget, which `knw_compare_map(html =)` saves; software versions in the `.bib` come from the evidence ledger, not
  from the shared Zotero items (one item serves many reports).
- Duplicate merge: the masters are the three `software` items keyed `norris2024smnorris{fwapg,bcfishpass,bcfishobs}`,
  the only keys any local checkout cites (1, 8 and 26 files); every other copy is cited nowhere locally.

## Phase 1: Zotero (group library 4733734, Web API)
- [ ] New subcollection `statistics/model_selection`; add Chen & Yang 2021 (DOI 10.3390/stats4040051), Bengio &
      Grandvalet 2004 (JMLR 5), Bates et al. 2024 (JASA, DOI 10.1080/01621459.2023.2197686), Hastie et al. 2009
      (ESL 2nd ed., DOI 10.1007/978-0-387-84858-7), Breiman et al. 1984 (metadata only), metadata from CrossRef or
      the publisher, no hand-written abstracts; attach the PDFs held in a local folder where each is the work
      itself (check the ESL file is more than its table of contents)
- [ ] `software`: glmnet (Friedman, Hastie & Tibshirani 2010, JSS, as `citation("glmnet")` gives it); link, fresh,
      wet, flooded from each `CITATION.cff`; stac_floodplains_bc (no `CITATION.cff`: from its DESCRIPTION/README)
- [ ] Merge duplicates: find every fwapg, bcfishpass and bcfishobs copy by title and URL (title search finds 2, 2 and
      4 against the issue's 3, 3 and 5); give each master both collection memberships, a `dc:replaces` relation to
      each copy, and a consistent title; trash the copies
- [ ] Read back through the Web API and a guarded `zotero.sqlite` copy: items, collections, attachments, BBT keys;
      record every key in `findings.md`

## Phase 2: the 1.96 pick, as code
- [x] `R/tune_repick.R`: `knw_tune_repick(tune, se_mult = 1, d_floor = 200)` — region = converged and
      `ddev_best <= se_mult * se_diff`, pick by fewest departures then score, `d_floor` as `.tune_pick()`; runnable
      example
- [x] Tests: on a small hand-built table (k moves a rule in and out; the floor); on the source tree, k = 1 returns
      `recommended` for all eight `data/tune/*_tune.csv`, and k = 1.96 returns the issue's column; restore-the-bug
      check that each test fires
- [x] `knw_thresholds_table()`: `rule_196` and `holds_196` per row; test; rerun `scripts/0325-publish.R` locally
      (no `PUBLISH`), and check the `thresholds.csv` diff is only the two columns
- [x] `_pkgdown.yml` reference entry, `devtools::document()`, `pkgdown::check_pkgdown()`

## Phase 3: research files
- [x] `research/habitat_thresholds_tuned.md` and `research/chinook_rearing_tuned.md`: "within one SE" stated as a
      parsimony heuristic fixed before the run, with its sources; the 1.96 table (producer: `knw_tune_repick()` on
      `data/tune/*_tune.csv`), dated; also `research/grayling_rearing_tuned.md` and `research/README.md`'s "cannot
      tell" wording (plan review)

## Phase 4: the interactive map
- [x] `knw_compare_mapgl(segments, water, title, background = c("voyager", "openfreemap"))`: hex colours for the
      "neither" and "not graded" classes (MapLibre rejects `grey80`/`grey85`); rules legend bottom-left, layer switch
      top-right; a grade legend shown with the grade layer; a click popup per segment (class, grade, average flow,
      channel width, gradient, distance to the rule's river, stream order, which of link's conditions kept it under
      each rule, and whether the hand-entered reaches or the connectivity step changed it)
- [x] `knw_compare_map(html =)` saves that widget; tests (every colour stop is hex, positions, popup column,
      background choice); render one page and look at it in a browser

## Phase 5: the article's data
- [x] `data-raw/vignette_chinook.R`: add `tune_all` (the eight tune tables' columns `knw_tune_repick()` reads, each
      file's md5 in `meta$md5`), each BULK segment's kind of water (stream, river polygon, wetland ≥ 1 ha, lake ≥
      100 ha; FWA waterbody join), the province-wide km and median grade of CH rearing through wetlands of 1 ha or
      more (the issue measured about 10,200 km, median 0.03), and the run's versions from the ledger (link 0.66.0,
      fresh 0.39.0, the fwapg sha, wet's `discharge/fwa/v1` build); rerun it, and assert every element it did not
      change is `identical()` to the old bundle
- [ ] `data-raw/vignette_bib.R`: write `vignettes/chinook_rearing.bib` with rbbt from the keys the Rmd cites (group
      library), set software versions from `meta`, refuse an unresolved key; commit the `.bib` (CI has no Zotero)
- [x] `tests/testthat/test-vignette-data.R`: the new elements

## Phase 6: the article
- [x] Word count before (prose outside chunks and YAML, each inline `r` as one word; same command after)
- [x] Restructure to the issue's eight sections plus References, in its plain words; cut the profile plot, the zoom
      panel, the examples table, the bootstrap percentages, the small causes of change (one sentence)
- [x] The close-call sentence: one SE as a parsimony rule of thumb fixed before the run, cited; the 1.96 table
      computed inline with `knw_tune_repick()`, saying plainly that CH keeps its flow floor but loses the near-a-river
      allowance at 1.96
- [x] "What the comparison is against" sentence (link's width rule in every group; flow cut-offs scored as
      candidates); the wetland sentence in "Before you use it", with no pointer to pending work
- [x] Map: `knw_compare_mapgl()` when `IN_PKGDOWN` is `"true"`, coordinates rounded and only the popup fields; the
      static map otherwise
- [ ] `bibliography: chinook_rearing.bib`, `[@key]` citations (link, fresh, wet, fwapg, bcfishpass, bcfishobs,
      FDIS, the one-SE sources) and a References section; `stopifnot()` on every quoted number the rewrite keeps or adds
- [x] Word count after against the 1,400 target, and what set the floor

## Phase 7: README and link
- [x] README Data and methods: fwapg, bcfishobs and bcfishpass are Simon Norris's (Hillcrest Geographics),
      bcfishpass with contributions from many groups, as link's README words it
- [x] link#346 body: the thresholds table's `rule_196` and `holds_196`, and which rules hold

## Owed at the end (reported, done after merge)

- [ ] None planned: the upload (`PUBLISH=TRUE` 0325) stays with link#346, #80 and #81 carry their own work

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- `knw_tune_repick()`: k = 1 reproduces all eight published picks, k = 1.96 the issue's table; each test made to fail
  once by restoring the bug.
- `thresholds.csv`: the diff against main is the two new columns only.
- Article: `pkgdown::build_article("chinook_rearing")` with `IN_PKGDOWN=true` — the References section is in the
  HTML (`id="refs"` with entries), no unresolved `[@` or `???`, the widget draws (Chrome screenshot), page size near
  the measured ~5 MB (~1 MB compressed); a plain `rmarkdown::render()` takes the static path; `devtools::test()`,
  `lintr::lint_package()`, `pkgdown::check_pkgdown()` clean; render before/after compared so only intended prose moved.
- Zotero: every created item, attachment, collection and merge read back; BBT keys resolve within the group library.

