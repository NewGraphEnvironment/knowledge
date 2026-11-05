# Review round 2 (revision after b84b0de, at HEAD 6b2f758), #149

Scope: `revision.diff` (b84b0de..HEAD, planning excluded), read against the full working-tree files:
`vignettes/_cut_points.Rmd`, `data-raw/vignette_bib.R`, `data-raw/vignette_cut_points_places.R`, `inst/NOTICE.md`,
`vignettes/cut_points.bib`, and the key changes in `chinook_rearing.Rmd`, `habitat_thresholds.Rmd` and their `.bib` files.
I rendered `_cut_points.Rmd` from a scratch copy against the installed bundles (their md5s match the tree's). It exited 0,
the Esri tiles fetched, and the references resolved with no `(key?)`. I pulled out the three figures and looked at each,
stripped the HTML to text, and recomputed every number and claim from `cut_points.rds` and `cut_points_places.rds`.
`test-vignette-data.R`, `test-data-dir.R` and `test-settings-register.R` ran with `NOT_CRAN=true`. The only failure was
the known environmental one ("every ignored source of the methodology article...").

## Checklist read
- code-check-python.md: in full (no Python in the revision).
- code-check.md: the opening prose of every H3 under `## Mechanisms` (all fourteen, table rows skipped). I applied
  "A proxy is not the property" and "One fact derived twice" to the two round-1 fixes. Rules that stand alone: none read
  in full; none applies beyond Documentation Staleness, which I checked from its index line.
- code-check-r.md, by heading, 4 read: "Moving prose into a code chunk hides it from tools that scan the document",
  "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent", "`$` on a list
  partial-matches, so a longer sibling key answers for a missing one", "Regenerated binaries churn git even when nothing
  changed". The other ~115 headings were not read: they name tools the revision does not use.
- code-check-spatial.md, by heading, 1 read in full: "sf: `st_intersection()` / `st_difference()` return a
  GEOMETRYCOLLECTION that QGIS will not draw". I checked three more against the code from their index lines only: "sf:
  reproject the polygon to get a lat/lon bbox, never transform the projected bbox corners" (`basemap()` transforms the
  buffered polygon, which is correct), "`atan2(0, 0)` is 0..." (only a zero-length label stretch could hit it), "A name
  is not a key: `GNIS_NAME`..." (the streams are named within one group, as in round 1). The other ~95 were not read.
- code-check-shell.md: 0 read (no shell in the revision).

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:142-144 — The revision's new opening says `knowledge` "chooses link's
  thresholds from fish records: for each species and life stage, it finds the rule that best predicts where
  electrofishing crews caught the fish and where they did not". That is not how the code chooses a rule, and it is false
  for most of the shipped keys. The pick is the close call nearest link's standard rule, and the best scorer only among
  equals. The article says so itself at lines 482-484, and the pre-revision draft said it in one place ("the one that
  changes link's standard rule least, and among equals the best scorer"). Across the tracked tunings
  (`data/tune/*_tune.csv`, the `recommended` row's `ddev_best`), only CH_rear and WCT_rear pick the best scorer (0).
  BT_rear sits 1.34 behind the best, BT_spawn 4.58, CO_rear 0.33, GR_rear 10.03 and ST_rear 5.39. So for 5 of the 7
  fitted keys, the "each species and life stage" the sentence names, the chosen rule is not the one that best predicts
  the catches. The linked methodology article does not describe the choice as "best predicts" either. No guard covers
  the sentence. Fix: word it by the code's definition, for example "it finds, among the rules that predict about as well
  as the best, the one nearest link's standard settings". Or scope it to chinook rearing, where the pick is the best
  scorer (guarded at line 92).
  - **Rule:** writing.md "State each claim by the code's definition" ; writing.md "Check that each guard covers the set its
    sentence names"

## Checked and holding (not findings)
- **The transfer fix (round 1, finding 1).** `transfer_net = 1 - parent_km / minimal_km = 1 - 86,607.61 / 87,605.84 =
  1.14 %`, which prints "1.1 %". It is computed inline, so the printed value is exact by construction, and
  `0 < transfer_net < transfer_pct` holds. `tr$parent_km` is the parent setup's pick km (guarded within 0.05 km), and that
  pick is the minimal network's rule exactly (guarded), so "a rule tuned on the minimal network ... run on the full one"
  is the right population. `tr$minimal_km` (87,605.84) agrees with the minimal setup's own `tuned_km` (87,605.85), so
  "than on the minimal network itself" holds. The next sentence (the stretches only the minimal network draws are small
  streams near large rivers, because of where the allowance measures its distance from) matches the linked research
  section: "All of the 1,042 km fails the flow floor and passes ... only by the near-river exception ... all of it in
  small streams near large rivers". The 0.4 km connectivity stage is noted there.
- **The strip-label fix (round 1, finding 2).** The at-site labels now print `grad(gradient, 2)`: 11.82 / 5.61 (Taylor
  Creek), 6.33 / 9.05 (Kiteen River stream), 9.34 / 7.95 (Skeena stream). At two decimals each lands on the side of 9 %
  its bar's colour shows, and each pair straddles 9 %, as the prose and caption say. In the rendered figure the colours
  match the legend's `cut()` classes, (−∞, 9], (9, 13] and over 13. No guard asserts the printed sides; that is fragile
  only if the bundle changes.
- **The example-selection rule in the caption** holds. With the 50 m floor and UFRA excluded, the three groups with the
  largest crossing gaps (|full − parent|) are KLUM 0.0621, LNAR 0.0272 and LSKE 0.0139, which are the bundle's examples.
  Without the floor, WORC and HERR (37 m and 38 m segments) would lead, so the caption is right to state the floor.
  `st$crosses` agrees with a recomputation on the two limits.
- **"In the second panel ... ends 79 m above the visit"**: LNAR is the one example whose full slope is gentler, which
  makes it the second facet (the facet levels follow `ex` order). −30.27 + 109.27 = 79 m, and the guard covers the
  steeper segment above and the minimal segment that averages it in.
- **Map.** 2,150 / 76 / 19 km. The order ≤ 3 shares are guarded. The zoom cell picked by segment centroids, (6, 3), is
  also the cell with the most km when segments are clipped to the grid (8.8 km against 8.1 km), so the caption's "the
  15 km square holding the most km" holds either way. Both scale bars measure correctly against the panel widths. "Chosen
  before drawing as the one where the tunings compared in this article disagree over the most km" matches the research
  note (MORK, 236 km of disagreement across the four setups). The differing pieces are short (median 139 m).
- **Profile.** 10.8 % over 90 m, 3.4 % over 570 m ("from near the mouth": it starts at 13.8 m), Atlas line 15.8 % over
  3.0 km. The open circle at 519 m sits on the same 494-584 m full segment.
- **Counts and roundings.** "Roughly 7,800" (7,823), "about 400" (guarded within 50), "only 7" (guarded < 10), "about
  4,900 visits in 45 watershed groups" (4,858; `sum(both_out) == n_visits` guarded), "225 ... and 7". "Under 3 %" holds
  (2.82 %). "13 other rules with a 13 % limit" holds. Table 2's yes/no cells match `in_region` and the research note's
  verdicts, including the Atlas line's narrow miss on the published region. Every close call has `departures == 3`, so
  "the choice is the best scorer" holds for chinook rearing.
- **Table 1.** The labels are new. "Cut at every record" and "at each species' highest record" read against the
  article's definition of a record (a record of a species link models), and the footnote names each build's link
  version (0.66.0, 0.78.2, 0.78.1).
- **`vignette_bib.R`.** `v` is a list with the exact names `link`, `fresh` and `wet`, so there is no partial match. Both
  sorts use `method = "radix"`. `bib_package()`'s field split and its trailing comma before `}` render under pandoc, and
  the references show "Version 0.78.2" and "Version 0.52.0" with the concept DOIs. Every citation key sits in prose, none
  in a chunk. No `irvine2026*` key is left outside `planning/`. `all_tools = FALSE` for the cut-points article, so not
  citing `wet` there is allowed.
- **`vignette_cut_points_places.R`.** The streams come back as EPSG:3005 LINESTRING. NOTICE names the named streams
  under the Freshwater Atlas's OGL-BC. The places' meta carries no path or host. `bundle_md5` matches the installed
  `cut_points.rds`, which the article guards.
- No host names, home paths or client identifiers appear in the revision diff or in either rds.
