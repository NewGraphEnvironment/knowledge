# Task: An article on how link's cut points move the tuned rules, shown on our own data (#149)

link cuts streams into segments, partly where fish of the species it models were caught. So a site that caught fish tends to start a short segment of its own, and the slope a rule reads there is worked out over a stretch that begins at the catch. Measured on stream-branch sites that start a segment of their own:

| network | sites with fish | sites without |
|---|---|---|
| link 0.66.0's full network (published until 2026-11-04) | 86 % | 10 % |
| link 0.78.2's full network (published since #145) | 44 % | 7 % |
| link's minimal network (cut only at barriers and access gradients) | 3.4 % | 3.0 % |

The picks moved with the network. Chinook rearing's slope limit is 11 % on the first, 13 % on the second and 9 % on the third. On the same flows and range, the minimal network and the new full network pick different rules for four of seven keys, three of them outside the other's region (`research/minimal_network_tuning.md`, "The full network on the same flows and range"). This is written as a specification; it needs a public article.

## Context

link cuts streams where fish were caught, so a site with fish often starts its own short segment and the slope a
rule reads there begins at the catch (86 % → 44 % → 3.4 % of fish sites on #92's, #145's and the minimal network).
The picks moved with the network (chinook rearing 11 / 13 / 9 %; four of seven keys differ between the full and
minimal networks). All of this is in `research/minimal_network_tuning.md`, a specification. #149 asks for a public
pkgdown article led by figures of our own data, a short answering section in the methodology article, and a
`data-raw/` bundle with every prose number computed inline and checked. It takes over #120's last task.

**This session runs on m4, the database's host**, where both builds (`fresh_default` with `streams_parent`,
`fresh_default_minimal`), every #120 candidate run (`20261103_0838`, `20261104_0543`, `20261105_0436`,
`20261105_0437`), `data/fdis/derived{,_minimal,_parent}` and `data/compare/setups/CH_rear_setups.gpkg` are present.
Phases 1–2 (staging and the bundle) run here; phases 3–5 run on the other machine (decided below). The staging step
keeps the bundle off the database, and any machine holding the staged directory can rebuild it.

## Decided at the gate

- **Per-key table: chinook rearing alone, on all four setups** (Al, 2026-11-05, after first choosing every key and
  asking whether that was too much detail): the article teaches one mechanism, and chinook rearing is the only key
  with every setup. The other six keys get one sentence computed inline (the network moved the pick for four of
  seven keys, with how many lie outside the other network's region), linking `research/minimal_network_tuning.md`.
  A per-species treatment is the separate article #149 names as not in scope.
- Mechanism (mine, stated): the staged directory is `data/stage/cut_points/` (ignored); not pushed to the bucket in
  this PR, since the host can restage in minutes. The concept figure is a longitudinal profile of one real stream:
  each network's segments drawn as the straight slopes a rule reads, the catch marked, the tuned limits beside it.
  Maps are static tmap with gq registry styles (lakes, rivers), as `0330`'s and `setup_compare.R`'s are.
- **This session stops after phase 2** (Al, 2026-11-05): stage and bundle here on m4, commit, push the branch, and
  write a `### Resume` block in `progress.md`; phases 3–5 run on the other machine. The bundle
  (`inst/vignette-data/cut_points.rds`) is tracked, so the article needs nothing else from m4; the staged directory
  stays on m4 (ignored), and its md5 check in the tests runs only where it exists. A figure needing data outside the
  bundle means a short rerun of phases 1–2 here.
- The article stays a draft (`vignettes/_cut_points.Rmd`) until Al approves the rendered page; the methodology
  article's section and the rename to `cut_points.Rmd` land together on that approval, so the site never links a
  page it does not publish.

## Phase 1: Stage the inputs (on the host)

- [x] `data-raw/cut_points_stage.R`: writes `data/stage/cut_points/` with `MANIFEST.csv` (path, source, md5, bytes,
  rows, the link run ids and knowledge commit). Copies: `CH_rear_setups.gpkg`; `visits_link.csv` from
  `derived_parent` (all four gradients per site) and `derived_minimal`; `visits_species.csv` (byte-identical across
  the three builds; checked); each candidate run's `<key>_tune.csv` and `<key>_compare.csv` for the seven keys
  (minimal `20261103_0838`; the six other keys for the one sentence) and CH rearing's parent and Atlas runs. Queries: full and minimal segments (geometry,
  gradient, length, measures, parent id) on every blue line holding a stream-branch chinook-in-range site whose slope
  sits on opposite sides of 9 % or 13 % between any two setups. Refuses unless both builds are the runs the grade
  records name (`knw_build_record()`, `knw_parent_read()` provenance) and `knw_db_latency_check()` passes.
- [x] `.gitignore` gains `data/stage/`; a test pins it ignored.
- [x] Run it; log to `scripts/logs/habitat/<date>_cut_points_stage.txt`.

## Phase 2: The bundle

- [ ] `data-raw/vignette_cut_points.R` → `inst/vignette-data/cut_points.rds` (one named list, geometry simplified,
  EPSG:3005). Reads only the staged directory (held to its manifest md5s) and tracked tables (`data/tune/<key>_tune.csv`,
  `data/compare/compare.csv`, `20261105_setup_compare-ch_rear.csv`, the `segment_gradient_check` logs). Holds:
  - the premise table (sites starting their own segment, fish / empty, on #92's, #145's and the minimal network);
  - chinook rearing: each setup's tune-table columns that `knw_tune_pick_report()` reads, and `default` and pick km
    per setup, so the article computes picks, regions and km inline; for the other six keys only each network's pick
    and its standing in the other's region (for the one sentence);
  - the concept stream: one stream's segments on both networks and its Atlas line, with its sites;
  - real examples: sites where the cut moves the slope across a tuned limit, chosen by criteria fixed in the script
    before drawing (chinook-in-range stream-branch sites with fish whose full-network slope is on the other side of
    the limit from their parent's, the largest gap per group, three groups), and the group map (MORK, the most km of
    disagreement, the criterion `setup_compare.R` fixed);
  - `meta`: md5s of tracked sources (`md5`) and of staged inputs (`md5_local`), commit, date, run ids.
  - Refuses with uncommitted code or registers, as `vignette_method.R` does.

- [ ] Commit, push the branch, append the `### Resume` block to `progress.md` (the run-to-PR mandate for phases 3–5
  restarts when the block is pasted on the other machine).

## Phase 3: The article (draft) — on the other machine

- [ ] `vignettes/_cut_points.Rmd`, `bookdown::html_vignette2`, headings as the reader's questions, answer first:
  1. What does link's cut do to the slope at a fish site? (concept profile figure; premise table)
  2. Where does it bite on our own data? (example sites, side-by-side maps per setup; MORK map)
  3. How far did the tuned rules move? (chinook rearing on four setups: pick, region verdicts, km; one sentence on
     the other six keys)
  4. What does it mean for someone using the thresholds? (which network each published rule was tuned on; what
     changes applied on another; the transfer cost through the parent, 1.2 %)
  5. Limits.
  - Every number inline from the bundle, each checked by `stopifnot()`; a caption names every mark; species in
    lower case; packages cited at first mention.
- [ ] References: `data-raw/vignette_bib.R` writes `vignettes/cut_points.bib` if the article cites a work or package
  (Zotero must be running; if it is not on this machine, the article cites packages only through `citation()`).

## Phase 4: Tests and pins

- [ ] `tests/testthat/test-vignette-data.R`: the bundle ships; tracked sources unchanged since it was saved; staged
  inputs unchanged where present; the examples meet their stated criteria; chinook's table has its four setups, and
  the other-keys sentence's counts come from seven keys.
- [ ] `CLAUDE.md` Layout: one entry for the article, its bundle and its staging script; `data-raw/README.md` row;
  `research/minimal_network_tuning.md` links the article.

## Phase 5: Render, review, publish

- [ ] Install the branch, render the draft and the methodology article; check figures at their published width
  (cartography self-review), the footnote/cross-ref traps, word count.
- [ ] Publish the rendered draft as a private Artifact and offer Al the link, before the merge.
- [ ] On Al's approval: rename to `vignettes/cut_points.Rmd`, add the methodology article's short section
  ("Does where link cuts a stream move the rules?", two or three sentences, linking the article; the article links
  back), and the Limits bullet on segments points to it. Without approval by PR time, both stay owed.

## Owed at the end (reported, done after merge)

- [ ] Tick #120's last task when this lands (it stays listed there until then).
- [ ] If the article is still a draft at merge: its rename and the methodology section.
- [ ] File "the same layout for the species" when reached (named in #149, not in scope).

## Validation

- [ ] Tests pass (`devtools::test()`, and `NOT_CRAN=true` single-file runs read by PASS count)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the staging log shows each md5 and the build ids; the bundle refuses a staged file whose md5 differs
(mutation: alter one byte, expect the refusal); the article renders with every `stopifnot()` passing; the
`test-vignette-data.R` checks fire when a tracked source is altered (restore-the-bug); `pkgdown::check_pkgdown()` and
the draft gate in `pkgdown.yaml` pass; the rendered page reviewed on a phone-width view.

