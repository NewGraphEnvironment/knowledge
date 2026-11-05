# Task: Revise the cut-points draft after its review (#149, PR #153)

Al reviewed the rendered draft (2026-11-05) and asked for all of it to be done on the PR branch; the points are tasks in
#149's body, "Review of the draft". The first pass's record is `planning/archive/2026-11-issue-149-cut-points-article/`.

## Phase 1: Citations by convention
- [x] `data-raw/vignette_bib.R`: our packages (`link`, `fresh`, `wet`) from their own `citation()`, keyed by package name
  with the concept DOI (soul `writing.md`, "Name, link and cite the software"), the version still from the run; every
  article's keys moved to `@link`, `@fresh`, `@wet`; all three `.bib` files rewritten

## Phase 2: Map data
- [x] `data-raw/vignette_cut_points_places.R` also carries the map group's named streams (Freshwater Atlas), for labels

## Phase 3: The article, revised
- [x] Why before how: what knowledge does with link, why thresholds are tuned from fish records, why a cut at a catch
  matters; chinook as the worked example of a multi-species tuning, research notes linked early
- [x] The map earlier, on Esri World Topographic Map blended with World Shaded Relief (`gq::gq_basemap_tiles()`), with
  river names on both panels
- [x] The example figure before the frequency table, sleeker, in a pleasing palette; the table's lead-in says why it
  matters
- [x] The four tunings as a table with plain definitions; rule against habitat defined; the tuning's purpose before its
  mechanics; fewer exact counts; the other-species paragraph cut; no sentence that dates; Limits say what would
  separate the cut sources

## Phase 4: Check and publish
- [x] Render, check every figure at page width, republish the review copy
- [x] A blind reader's pass for what the article is for and what a reader takes away, before the accuracy review
- [x] `/code-check branch` on the revision: three rounds; round 3 found a defect inside round 2's fix and ended on its 57-claim enumeration, its three failures fixed and checked against their sources
- [x] soul issue (soul#745): the lessons for `writing.md` and `cartography.md`
- [x] `/planning-archive`, push, report
