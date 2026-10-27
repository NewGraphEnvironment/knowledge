# Task: A stepwise methodology article: the pipeline in order, with diagrams, function links and a settings register (#93)


The method is spread over scripts, package functions in four repos and long research files, and it is hard to follow
end to end. Asking one step at a time "which function, which setting, why that value?" has already found three
problems: the article misdescribes how FDIS sites reach the network and where the flows come from (#89), sites are
placed nearest-then-reject when candidate snapping would keep good placements (#91), and the rules are tuned on the
Freshwater Atlas line's gradient while link applies its own segment gradient (#92). A stepwise account written to
answer those questions at every step is an audit as much as documentation, and there are likely more to find.


## Context

The tuning method is spread over scripts, functions in four repos and long research files. Walking it one step at a
time has already found three defects (#89 placement/flows/gradient wording, #91 snapping, #92 gradient source). The
plan parked in #93's body (2026-10-27, with Al) is the draft; its `## Decisions` are settled. This plan is that draft
checked against the code as it stands today (main `80ea4c1`).

## Decided at the gate (from #93's body, Al, 2026-10-27; approved at the gate 2026-10-27)

- Scope is #89 and #93. #91, #92, the retune and #90 are separate; they appear in the register as pointers.
- The CSVs document; scripts and functions keep their values; a test holds the two together. No script reads
  `settings.csv`.
- Counts wait for the retune: the article is built and reviewed on today's run (#73's), and goes on the site only
  after the #91/#92 retune redraws it. #89's chinook-article corrections ship now.
- Clarity first: package shown by box colour; hex stickers inside boxes only if they don't crowd the labels.
- The article documents the pipeline as it runs today (`fwa_indexpoint()`, the Atlas line's gradient).

## What the code check changed in the parked plan

1. **The snap constants already exist.** `scripts/0230-fdis-load.R:54-55` has `snap_tol_m <- 500` and
   `snap_flag_m <- 100`, so no lifting is needed. But the comment on 55 says "farther snaps are flagged, not dropped",
   while `knw_fdis_quality()` (`R/fdis_quality.R:42`) drops them (5,242 in the 2026-10-22 ledger). The comment is
   corrected in Phase 1, as part of #89's placement fix. That is a first audit finding.
2. **Some register values live in other repos**, outside `formals()` of a knowledge function: the connectivity
   bridge (10 km, 0.05) is per species in link's `configs/default/parameters_fresh.csv`; wet's `far_low` (0.2) has no
   default and is set in wet's `scripts/pcic_routed_lib.R`. So `where` gets two more kinds (below).
3. **The draft can be kept off the site without holding the branch:** pkgdown 2.2.0 skips any vignette whose name
   starts with `_` (`pkgdown:::package_vignettes`), and `^vignettes/_` in `.Rbuildignore` keeps it out of the tarball.
   It lands as `vignettes/_tuning_method.Rmd`; publishing is a rename after the retune.
4. **Phase 5 moves to the owed list (proposed change).** Replacing the research file's Method with a link before the
   article is on the site would point at nothing a reader can open. Phase 1 corrects the Method in place now; the
   replacement happens with the publish rename.
5. **No Graphviz on this machine:** DiagrammeR, DiagrammeRsvg and rsvg are not installed, and there is no `dot`. They
   are installed for `data-raw/` only (not Suggests): the article includes the committed SVGs, so CI needs none.

## Phase 1: #89 — say how the evidence reached the network

- [x] `vignettes/chinook_rearing.Rmd` "What records were used?" (lines 122-131): placement by `fwa_indexpoint()`
      (500 m search, kept within 100 m and in FDIS's 1:50k watershed), then link's segment at that point; flows as
      wet's `pick` (PCIC VIC-GL routed by Raven, carried onto Atlas streams by the crosswalk in New Graph's fwapg fork;
      wet's balance elsewhere); bcfishobs only for the outside check; the gradient the tuning read (`fwa_gradient`,
      the Atlas line's) versus link's segment gradient.
- [x] (moved to Owed: the Zotero write is blocked) Citations: check whether the group library holds PCIC's VIC-GL / Raven routing and the fwapg fork; add any that
      are missing through the Web API (or let wet's citation carry them if wet's docs cite them); rerun
      `data-raw/vignette_bib.R` (Zotero running).
- [x] `research/habitat_thresholds_tuned.md` Evidence and Method: the same three corrections.
- [x] `research/modelled_discharge.md` refreshed to the loaded build `94deeb5` (routed 1981-2010), read from the table
      comment and wet at that SHA; header's Verified line updated.
- [x] `scripts/0310-evidence-build.R`: a ledger row `wet_loaded_build` from
      `obj_description('discharge.fwa_v1_segment_monthly'::regclass)` beside `wet_manifest` (no rerun).
- [x] `scripts/0230-fdis-load.R:55` comment: far snaps are flagged here and dropped by `knw_fdis_quality()`.
- [x] Verify: render the chinook article before and after, strip to text, diff: only the evidence paragraph moves;
      `test-vignette-data.R` still green (no data change).

## Phase 2: the two CSVs and the register test

- [x] `inst/method/pipeline.csv`: one row per step (step, label, package, scripts, functions, inputs, outputs, issue),
      the 11 steps of #93's table.
- [x] `inst/method/settings.csv`: key, step, value, unit, where, source (source / convention / inherited / measured),
      tested, issue. First rows: snap search 500 and limit 100 (`script:scripts/0230-fdis-load.R:snap_tol_m`,
      `…:snap_flag_m`; inherited, untested, #91); gradient source (`fn:knw_tune_curve:cols`, #92); prior SD 2.5
      (`fn:knw_tune_run:prior_sd`, also `_score`, `_curve`); one-SE region (`fn:knw_tune_repick:se_mult`) and the 1.96
      reading; seed 54, five folds, seeds 55:58, 200 bootstraps, `d_floor` 200 (`fn:knw_tune_run:*`); area 10-10,000 m²,
      `min_wsg` 5, `power_wsg` 10; walk river sizes (`fn:knw_link_walks:q_grid`); 50 km cap
      (`fn:knw_tune_curve:dist_cap_m`); grade reference 0.95 (`fn:knw_grade:ref_quantile`); the bridge
      (`ext:link:inst/extdata/configs/default/parameters_fresh.csv:cluster_bridge_distance`); wet's `far_low` 0.2
      (`ext:wet:scripts/pcic_routed_lib.R:routed_far_low`). Final list from a walk of each step's code, not this list.
- [x] `tests/testthat/test-settings-register.R`, `where` kinds:
  - `fn:<fn>:<arg>` — a knowledge default, `formals()`; runs everywhere.
  - `script:<path>:<name>` — a top-level assignment found by `parse()`; skipped without the source tree.
  - `ext:<pkg>:<path>:<name>` — another repo's file; not tested here; the render script prints the run's SHA beside
    it (from the ledger's `run_link_sha` etc.).
  - `record:<field>` — a value a run recorded; checked by the render script against the run, not the test.
  Fails on a value mismatch or a `where` that names nothing; every row's kind is one of the four.
- [x] Prove it fires: change one CSV value and one script value in a temp copy, each goes red.

## Phase 3: render script and diagrams

- [x] Install DiagrammeR, DiagrammeRsvg, rsvg (data-raw only).
- [x] Prototype: two steps' boxes with fresh's and link's stickers (`man/figures/logo_small.png` in each repo) inside
      Graphviz boxes; keep stickers only if labels stay readable at article width, otherwise colour alone.
- [x] `data-raw/vignette_method.R` writes `inst/vignette-data/method.rds` and the SVGs: flow chart from
      `pipeline.csv`; record funnel from `scripts/logs/habitat/20261022_evidence_build_ledger.csv` (51,587 in; not
      placed 1,563, far snap 5,242, ws50 1,088, …; in range per species) to modelled per species from
      `data/thresholds.csv`; data-lineage diagram (FDIS, Atlas via fwapg, PCIC, wet, link, bcfishobs); per-step counts;
      provenance (commit, date, ledger and table md5s), as `vignette_chinook.R` does.
- [x] Extend `test-vignette-data.R`'s md5 check to `method.rds`'s sources.

## Phase 4: the article (draft, off the site)

- [x] `vignettes/_tuning_method.Rmd`, "How the thresholds are tuned": the flow chart; per step the block (what it
      does, linked functions in knowledge/fresh/link/fwapg reference pages, counts in/kept/dropped with reasons,
      settings rows); the funnel; lineage; the two worked examples (one site snapped; one rule through predicate,
      overlay, connectivity on a few BULK segments, from `bulk_segments.rds` if it carries enough); the register table
      with untested/inherited rows first. Every number computed inline, principle before each result (CLAUDE.md).
- [x] `^vignettes/_` in `.Rbuildignore`.
- [x] Write the publish step into #92's body (the retune that redraws it): rerun `vignette_method.R`, rename to
      `vignettes/tuning_method.Rmd`, then the research Method replacement.

## Owed at the end (reported, done after merge)

- [ ] Cite PCIC's VIC-GL (Schnorbus 2018), Raven (Craig et al. 2020) and the fwapg fork in the chinook article:
      `planning/archive/<this archive>/zotero_create_89.py` creates the three items (blocked 2026-10-27: the Zotero key
      could not be read from its credential store); then cite them in "What records were used?", rerun
      `data-raw/vignette_bib.R` (Zotero running) and check the fork item's title does not start "fwapg"
      (`vignette_bib.R`'s `key_for("^(smnorris/)?fwapg")`). Written into #89's body.

- [ ] Publish after the #91/#92 retune: rerender, drop the `_` prefix, replace
      `research/habitat_thresholds_tuned.md`'s Method with a link (the parked plan's Phase 5).

## Validation

- [x] Tests pass
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: chinook article text diff (Phase 1); register test red on a planted mismatch in each kind
it checks (Phase 2); `pkgdown::build_articles()` locally shows no `articles/_tuning_method.html` / `tuning_method.html`
and `R CMD build` tarball has no `vignettes/_*` (Phase 4); the draft renders with `rmarkdown::render()` after
`load_all()` and is read at article width; `pkgdown::check_pkgdown()`; the #56 `public_sweep.py` over the branch.

