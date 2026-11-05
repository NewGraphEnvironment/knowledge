# Final review, round 3: the publish delta (7968c98..HEAD)

Scope: `scratchpad/publish.diff`. The draft `vignettes/_cut_points.Rmd` becomes `vignettes/stream_splits.Rmd`, its .bib
becomes `stream_splits.bib`, a new `#cuts` section goes into `vignettes/habitat_thresholds.Rmd`, the dashed square is
gone from the inset, and the references are updated in `data-raw/vignette_bib.R`, `CLAUDE.md`, `data-raw/README.md`
and `research/minimal_network_tuning.md`. Work was read-only; the only write is this file.

## Checklist read

- code-check-python.md: in full (no Python in the delta).
- code-check-r.md, by heading: "Moving prose into a code chunk hides it from tools that scan the document",
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it",
  "`R CMD build` ships every top-level directory not in `.Rbuildignore`",
  "`.Rbuildignore` has no comment syntax — every line is a live regex". I did not read the other ~150 headings,
  because nothing in the delta uses their tools.
- code-check-shell.md and code-check-spatial.md: no heading read. The delta has no shell, and its only spatial change
  removes one `tm_borders` layer. I did not read about 200 and 270 headings in those files.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, without their tables, plus "Documentation Staleness"
  from the index.

## Mechanical checks

- **Stale names.** `git grep -e '_cut_points' -e 'cut_points.bib' -e 'cut_points\.Rmd' -e 'cut_points.html'` outside
  `planning/archive` and `scripts/logs` has no hits. The remaining `cut_points` hits are the internal names (bundles,
  scripts, tests) that CLAUDE.md says stay. `vignettes/` holds only the three published articles and their .bibs.
- **Package build.** `.Rbuildignore` excludes only `^vignettes/_`, so `stream_splits.Rmd` now goes into the tarball
  and is built as a vignette. It needs `gq`, `tmap`, `png`, `kableExtra`, `sf`, `dplyr` and `ggplot2`, which are all
  in Imports or Suggests. `gq::gq_basemap_tiles()` needs `maptiles`. That is only a Suggest of gq, but tmap Imports
  it, so CI installs it.
- **pkgdown.** No `vignettes/_*.Rmd` is left, so the draft gate's loop finds nothing and `continue`s. `_pkgdown.yml`
  has no `articles:` index, so the article is listed without a config change. No `<!-- -->` lines were added to
  `.Rbuildignore`.
- **Chunk labels.** The three articles have no duplicate labels (`grep … | uniq -d` is empty). The new chunk `cuts`
  and the names `cp` and `cp_lim` do not collide with anything else in the methodology article.
- **Renders.** I copied each Rmd and its .bib to `scratchpad/render3/` and rendered them against the installed
  package. Its bundle md5s match the branch: cut_points.rds 003c7a90…, cut_points_places.rds a04b84fb…, method.rds
  f6c38536…. Both renders finished with 0 warnings. Neither page has `???` or an unresolved citation, and neither
  has a footnote.
- **Links.** All four resolve in the rendered HTML:
  - `id="cuts"` exists in habitat_thresholds.html.
  - habitat_thresholds.html has `href="#cuts"` (from Limits) and `href="stream_splits.html"`.
  - stream_splits.html has `href="habitat_thresholds.html#cuts"`.
  - The research file's URL, `https://newgraphenvironment.github.io/knowledge/articles/stream_splits.html`, is
    `_pkgdown.yml`'s `url` plus `articles/<name>.html`. It goes live when the site deploys.
- **.bib.** Only the header changed, and it now reads exactly what `bib_write()` would write for the new name. The new
  section cites nothing, so `habitat_thresholds.bib` does not need regenerating.
- **Tests.** `NOT_CRAN=true … test_file("tests/testthat/test-vignette-data.R")` has 18 tests and 1 failure: the
  known environmental "every ignored source of the methodology article, where present, is unchanged". There are 2
  skips. The working tree is clean.

## Claim enumeration

The bundle is `inst/vignette-data/cut_points.rds`.
- `setups`: published `grad_max` 0.13, minimal 0.09.
- `other_keys`: `network_moved` is BT_rear size+gradient, BT_spawn gradient+exception, CH_rear gradient, CO_rear
  same, GR_rear same, ST_rear size, WCT_rear same.

method.rds `picks` CH_rear = `mad>=0.75|g<=0.13|Q3@D1000`; `meta$written` 2026-11-04, `meta$commit` f6b6d0a. cut_points.rds
`meta$written` 2026-11-05, `meta$commit` 4590e2f.

| # | Sentence (file) | Backed by | Covers it? |
|---|---|---|---|
| 1 | Heading "Does where link cuts a stream change the rules?" (habitat_thresholds) | a question | n/a |
| 2 | "It can." | the chunk's stopifnot: CH limits differ, and some other key moved | yes |
| 3 | "A rule's slope test reads each segment's own slope" | the article's own method (`segment_gradient`, #92); thresholds.csv `curve_grad` = segment_gradient | yes, by the source; the section has no guard for it |
| 4 | "link's full network cuts some streams at fish records, so a site that caught fish often starts a short segment whose slope is worked out from the catch upstream" | the Limits bullet below it in the same article (44 % against 7 %; 305 m against 466 m, from method.rds `segment_at_site`, guarded there) | yes |
| 5 | "Tuned on link's minimal network, which leaves out those cuts, chinook rearing's steepest slope is 9 % rather than 13 %" | inline from `cp$setups` (minimal 0.09, published 0.13); the guard `published > minimal`; stream_splits.Rmd:167 says the minimal network leaves out the cuts at fish records | the numbers are computed inline, so yes. But nothing ties the 13 % to this article's own CH pick (finding 2) |
| 6 | "the network moves the rules of some other species and stages too" | `cp$other_keys`: BT_rear, BT_spawn, ST_rear moved (two species, two stages) | true for the bundle. The guard is `any()`, so it passes for one moved key, which would make "species and stages" plural false (finding 2) |
| 7 | "[Splitting streams …](stream_splits.html) shows it on our own records" | the linked article | yes |
| 8 | Limits: "How far the cuts move the rules is [above](#cuts)." | the section above | yes |
| 9 | habitat_thresholds:463 "This article's data were written on 2026-11-04 at commit f6b6d0a" (unchanged, but the delta changed what it covers) | method.rds `meta` only | **no**: the #cuts numbers come from cut_points.rds, 2026-11-05 at 4590e2f (finding 1) |
| 10 | stream_splits: title, VignetteIndexEntry "Splitting streams at fish records shifts the steepest slope mapped as habitat" | setups: 13 % full against 9 % minimal, guarded in the article's opening chunk | yes |
| 11 | stream_splits caption: "The lower panel enlarges the box outlined above." | `draw(..., frame_box = zoom_box)` draws a black border on the overview | yes |
| 12 | stream_splits: "The methodology article answers this article's question in brief ([…](habitat_thresholds.html#cuts))." | the new section | yes |
| 13 | CLAUDE.md:53 the stream_splits entry, with its title | the file and its title | yes |
| 14 | CLAUDE.md:59 "The methodology article's "Does where link cuts a stream change the habitat definitions?" (`#cuts`)" | the actual heading reads "…change the rules?" | **no** (finding 3) |
| 15 | CLAUDE.md:60 "Its maps fetch Esri tiles when it builds, so a build needs network" | `gq::gq_basemap_tiles(... "Esri.WorldTopoMap" ...)` in the map chunk | yes |
| 16 | CLAUDE.md:60-61 "Internal names (bundles, scripts, tests) keep `cut_points`" | git grep | yes |
| 17 | CLAUDE.md:41 (unchanged) the methodology article "reads `inst/vignette-data/method.rds`… A promotion reruns it" | now it also reads cut_points.rds, which a promotion does not rebuild | incomplete (folded into finding 3) |
| 18 | data-raw/README.md:37-38 "write the data for the cut-points article (`vignettes/stream_splits.Rmd`; #149)" | file names | yes |
| 19 | data-raw/vignette_bib.R:3-4, 31 and 141-142: the article and OUTPUT names | the calls | yes |
| 20 | research/minimal_network_tuning.md:206-208 the article's title, URL and file | the title, pkgdown url and file | yes |

## Findings

- **[severity: bug]** vignettes/habitat_thresholds.Rmd:463 — The sentence "This article's data were written on
  `r x$meta$written` at commit `r x$meta$commit`" reads method.rds's provenance only (2026-11-04, f6b6d0a). Since
  this delta, the article also reads `cut_points.rds` (lines 396-406), which was written on 2026-11-05 at 4590e2f.
  So the page now dates and attributes the #cuts section's two numbers to a bundle they do not come from. Either
  name both bundles' dates and commits, or have the `#cuts` section print `cp$meta$written` and `cp$meta$commit`.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "Documentation Staleness"

- **[severity: fragile]** vignettes/habitat_thresholds.Rmd:400 — The guard does not cover the set its sentences
  name. There are three gaps:
  - `any(... != "same")` passes when only one other key moved, while line 406 says "the rules of some other
    species and stages" in the plural. The bundle has three moved keys over two species and two stages, and
    stream_splits.Rmd:116 pins `n_moved == 3`.
  - `cp_lim()` returns `numeric(0)` for a missing setup row, and `stopifnot(numeric(0) > numeric(0))` passes, so
    a missing row would print " %" instead of stopping.
  - Nothing checks that `cp`'s "published" setup is this article's own CH rearing pick. The two agree today:
    `cp$setups$pick[setup == "published"]` and `pk$pick[pk$key == "CH_rear"]` are both
    `mad>=0.75|g<=0.13|Q3@D1000`. But a promotion reruns method.rds and not cut_points.rds. After a promotion
    that moves CH rearing, the section would still say "rather than 13 %" beside a table showing the new rule,
    and no check would fire.

  The bundle's md5 is pinned, so none of this is false today. The guard is still narrower than the claims it
  backs. A fix: `stopifnot(length(cp_lim("published")) == 1, length(cp_lim("minimal")) == 1,
  identical(cp$setups$pick[cp$setups$setup == "published"], pk$pick[pk$key == "CH_rear"]))`, plus a count of moved
  keys and species of at least 2.
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "Zero-length, empty, and unset are three different things" ; code-check.md "Written data outlives the fix"

- **[severity: fragile]** CLAUDE.md:59 — The stream_splits entry names the methodology section "Does where link cuts a
  stream change the habitat definitions?". The heading as built (habitat_thresholds.Rmd:393, and the stream_splits
  link text at line 583) reads "Does where link cuts a stream change the rules?". A reader searching for the named
  heading finds nothing. Also, the methodology entry at CLAUDE.md:41 still says that article reads
  `inst/vignette-data/method.rds` and that "a promotion reruns it". It now also reads `cut_points.rds`, which a
  promotion does not rebuild, and the entry does not say so.
  - **Rule:** code-check.md "Documentation Staleness"

/Users/airvine/Projects/repo/knowledge/planning/active/review-final-round3.md
