## Findings

Draft 2, round 2. Six defects. Two sit inside round 1's fixes (F1, F2) and one in a line a fix rewrote (F3). One is a rendering defect round 1's enumeration missed (F4). Two are low, in the test and roxygen fixes (F5, F6).

### F1 (article). The connectivity pass is not "no spawning within 10 km"
Round 1's F2 fix reordered the sentence to "Reaches confirmed by hand are then added, and any rearing with no spawning within 10 km is removed." The order now matches `R/compare_rules.R:196-204`. The content does not match the code.

link's `parameters_fresh.csv` gives CH `cluster_rearing = TRUE`, `cluster_direction = both`, `cluster_bridge_gradient = 0.05` and `cluster_bridge_distance = 10000`. fresh's `.frs_cluster_both()` (`R/frs_cluster.R:402` on); the stated rule is in `frs_cluster()`'s `@param bridge_gradient`. It keeps a rearing cluster when either of these holds:
- **Phase 2:** spawning lies anywhere upstream of the cluster (`FWA_Upstream`, no distance limit and no gradient test; "Upstream check is boolean").
- **Phase 3:** spawning lies downstream on the mainstem within 10 km, and no segment of 5 % or steeper lies between them. Segments that are both rearing and spawning are always kept.

So the sentence is wrong both ways. Rearing with spawning 30 km upstream is kept. Rearing with spawning 2 km downstream, behind a segment steeper than 5 %, is removed.

The project `CLAUDE.md` ("link's CH rearing") carries the same shorthand, so the article probably inherited it from there. Fix: "... then rearing cut off from spawning is removed: it stays only where chinook spawning lies upstream, or downstream within 10 km with no segment of 5 % or steeper between." Consider correcting `CLAUDE.md` too.

(Checked against the fresh 0.40.0 checkout. The installed fresh is 0.39.0. The fresh that ran the link run was not checked, but `.frs_cluster_both`'s two phases are documented as the bcfishpass-parity design.)

### F2 (article). "without any record having tested it there" is false
Round 1's F3 fix added this to the limits bullet: "river polygons take the new gradient maximum without any record having tested it there". Earlier the article says "untested: no visit scored here is in a river polygon."

The tuning score holds none, which is true. But the article's own FDIS check ("Two checks", 10,515 visits, edges including 1250/1350, `compare_rules.R:314`) holds 2,272 accessible visits on river-polygon lines. Seventy-three of them flip from not-habitat to habitat under the recommended rule:
- All are edge 1250 with `wb_river` TRUE in `visits_link.csv`, in 11 groups (SQAM 44, LISR 9, COMX 6, KLUM 6, ...).
- Their gradients run 5.53 % to 8.86 %, which is exactly the band between the two maxima.
- None caught chinook. They are part of the 4,661 visits behind the "17 %".

So records do sit where the new maximum acts, and they run against it (0 of 73), though thinly. At the 1.5 % rate elsewhere, about one catch would be expected. Recomputed by repeating `compare_rules.R`'s check filter on `data/compare/CH_rear_segments.rds` and `data/fdis/derived/{visits_link,visits_species}.csv` (n = 10,515 reproduced).

Fix: say the rule was scored on no river-polygon visit. Then say the check's 73 FDIS visits on river-polygon reaches between 5.49 % and 9 % are added by the new maximum, with no catch among them. Make both lines say this.

### F3 (article). "each threshold is where habitat and non-habitat separate best on held-out groups": 9 % is the edge of the grid
This sentence came from round 1's F4 fix. For flow (0.75), Q (3) and D (1 km), the best value is interior to the values tried. For the gradient it is not. Nine percent is the steepest maximum tried, and the profile is still falling at that edge:
- 5.49 %: +47.2
- 7 %: +1.6
- 9 %: 0

(`tapply(tune$ddev_best, tune$grad_max, min)`; the profile figure shows the same.)

The records say 9 % beats every lower value tried, not that 9 % is where separation peaks. A steeper maximum was never scored. The article lists the grid but never draws this out, and the "cut on a slope ... the region gives the range" bullet implies values on both sides. Fix: say 9 % is the steepest maximum tried and steeper ones were not scored. Either qualify "each threshold" or name the gradient as the exception.

### F4 (rendered page). The km table's nesting is lost, so "first-order streams" reads as a share of all gains
The Rmd marks levels with leading spaces (`"  of which ..."`, `"    of which first-order streams"`, `vignettes/chinook_rearing.Rmd:300-302`). Pandoc trims cell whitespace. In `docs/articles/chinook_rearing.html` (rows near line 390), "of which first-order streams 6,952" therefore renders as a sibling of "of which small streams near a river (the exception) 9,666", both apparently under "Gained".

The value is `gain_exc_1`, the exception gains on order-1 streams. All order-1 gains total 7,478 km (connectivity 102.6, exception 6,952.1, size 422.0, gradient 0.7, river polygon 1.0; `data/compare/CH_rear_change.csv`). A reader takes 6,952 as all first-order gains, which it is not. Round 1's #71 marked this row "holds" without reading the render. Fix: make the label carry the nesting, e.g. "of those exception reaches, on first-order streams". Or indent with non-breaking spaces or an em dash prefix, and check the HTML.

### F5 (test, low). The `mark` test proves only that `mark` changes the image
Round 1's fix added `expect_false(identical(readPNG(one), readPNG(plain)))`. Mutation checks, in a copy, with `test_file` after `load_all`:
- `outline <- NULL` fails block 4 (1 failure), so the guard fires for a dropped outline.
- `tm_shape(mark, is.main = TRUE)` passes all 4 blocks (0 failures). That mutation makes the window the map's extent, so the overview zooms to the box: the regression a reader would see in the article's left panel.

Round 1 also asked for dark pixels along the box's edge. That half was not added. Fix: assert that the box's edge pixels, at the known panel coordinates, are dark in `one` and white in `plain`. Or assert that the segment pixels outside the box are unchanged.

### F6 (roxygen, low). The `png` fix reproduces the old inaccuracy one step over
`@param png` now reads "the `panels` asked for, side by side or as `ncol` sets". Round 1's point was that a `"floodplain"` panel without `fp_cells` is not drawn. The default call (`panels` = all three, `fp_cells = NULL`) draws two, so "the panels asked for" is still wrong in the default case. "as `ncol` sets" also misdescribes `ncol`, which is panels per row (`compare_map.R:122-125`). Fix: "the `panels` drawn (floodplain only with `fp_cells`), `ncol` to a row".

### Checked, no defect
- **Fix F2's order.** Overlay then connectivity, as in `compare_rules.R:196-204`.
- **Fix F3's premise.**
  - Printed `frs_habitat_predicates()` on link's default with `gradient[2] <- 0.09`: the river disjunct becomes `gradient BETWEEN 0 AND 0.09`; the wetland and lake disjuncts carry no thresholds and are unchanged.
  - River polygons do move: "other (river-polygon branch or mixed)" gains 229.7 km.
  - No tuning visit is in a river polygon: `wb_river` is TRUE only on edges 1250/1350/1450 in `visits_link.csv`, none of them a stream edge.
- **Fix F4's "cannot show a step".** True: `te()` plus `s(grad)`.
- **The other numbers I recomputed** (profile minima, region rows, checks rates 795/4661, 85/5854, 773/5717, 107/4798) agree with the article.
- **The map.** The window is outlined on the overview, and the zoom panel is square.
