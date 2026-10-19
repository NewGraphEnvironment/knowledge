## Findings

Review of commit 70be3cf (the labelled examples on the zoomed map). I reproduced it by purling
`vignettes/chinook_rearing.Rmd` into a scratch directory and running the `load`, `km`, `zoom` and
`examples` chunks under `pkgload::load_all()`. I joined the three picked segments, and every
segment in the window, back to `data/compare/CH_rear_segments.rds` (BULK) for `edge_type` and the
`rearing_pre_*` flags. No repo file was modified.

Severity: B = the article states something false or the guard is missing, G = a gap that can make
a future render false, M = minor wording.

### F1 (G): the case filters do not encode the premise that the table explains, and in this window they admit segments it would explain wrongly

The table says each row shows "what each rule reads and what each decides": the stream test's
width and gradient for `default`, and flow, gradient and distance for the recommended rule. That
holds only if both verdicts came from the stream branch and neither the overlay nor the
connectivity pass changed them. The three filters in the `zoom` chunk check flags and thresholds
only. They do not check `edge_type`, and they cannot check pre- and post-connectivity agreement,
because `bulk_segments.rds` does not carry `rearing_pre_*`. Measured inside this very window:

- **"Kept by both"** admits 36 edge-1250 segments, river-polygon main lines that both rules keep
  through the river branch, at any width. The widest of them is 1,096 m inside the window.
- **"Lost: below the flow floor, no river close"** admits 4 segments whose loss is connectivity
  (`rearing_pre_tuned` TRUE, final FALSE). Two of them are edge 1050 (68658, 68659) with
  `dist_m` NA. Those two would print "not needed" under distance and be explained by their flow,
  although the flow floor never applies to an edge-1050 line.
- **"Gained: small stream near a river"** admits 2 segments that `default` dropped in its
  connectivity pass (`rearing_pre_default` TRUE). For those, `default`'s "not habitat" did not
  come from width.

The picks are correct today, only because they are the longest in-window candidates: 81390,
82916 and 33205 are all edge 1000 with pre equal to post for both rules (checked against the
source). The window and the picks are both chosen by code from regenerated data, so a rebuild can
silently pick a row that the table mis-explains.

Fix:
- carry `rearing_pre_default` and `rearing_pre_tuned` into `bulk_segments.rds`;
- add `edge_type %in% c(1000, 1100, 2000, 2300)` and pre == post for both rules to every case;
- or `stop()` when a pick fails either condition.

### F2 (G): "does not occur in this window" is prose, not computed, and "A fourth case" implies four cases where the code has five stream-test reasons

The sentence after the table is not checked by any code. It holds today: no in-window gained
segment has MAD ≥ 0.75, so no segment meets `compare_rules.R`'s "gradient between the two maxima"
(`size_tun & g_tun & w_ok & !g_def`). Two problems remain:

- Nothing fails if a re-chosen window contains one. Compute it, or `stop()` when the count is
  above zero.
- `x$change` has another stream-test gain that the article never names: "size: tuned passes,
  width fails or NULL", **439 km** province-wide, 422 km of it first-order. That is a stream whose
  flow passes the floor but which has no modelled width or one under 1.5 m. It does not occur in
  this window either. "A fourth case" reads as completing the set, and the code says the set is
  five, not counting connectivity and overlay (533 km gained, 301 km lost) and the river-polygon
  branch (230 km gained). Either name both absent cases, or drop the ordinal.

Related wording risk: 17 green segments in the window, about 3.9 km of the 21.5 km gained there,
are steeper than 5.49 % (gradient 5.5 to 8.8 %). They are admitted by the exception *and* the new
gradient maximum. By the code's reason ("exception" wins in the `ifelse` chain) the sentence is
true, but a reader who sees steep green lines may read "does not occur" as contradicted. Consider
"…that only the new gradient maximum admits (passing both size tests)".

### F3 (M): the distance header is a hard-coded literal and drops "at least" and "downstream"; the caption drops both too

- `` `To a river of 3 m³/s` `` types the 3. Every other figure in the article comes from
  `rec$exc_q`. Build the name from `rec$exc_q`, as the caption does for its other thresholds.
- `knw_link_walks()` walks **downstream** from the segment's downstream end to the first segment
  whose flow is **at least** `q`. The header ("To a river of 3 m³/s") and the caption ("or a
  river within 1 km") both lose "downstream", and the header loses "at least". `words()` earlier
  in the article says "a river of at least 3 m³/s within 1 km downstream". A reader of the table
  can take "within 1 km" as any direction.

### F4 (G, latent): the label "not needed" is also printed where the exception was needed but the walk found no river

`dist_m` is NA in two cases:
1. the segment is not a walk candidate (`grade_species.R` lines 49–50), where "not needed" is
   true;
2. it was walked and `status != "found"` (the sea first, `no_parent`, `too_many_hops`), where the
   exception was needed and failed.

The "Lost" filter deliberately admits `is.na(dist_m)`, so a Lost pick with an unfound walk would
read "not needed", the opposite of why it was lost. It does not happen in this render: the Kept
pick passes the size test and the Lost pick has 6,791 m. Print the two NA cases differently, for
example "no river found" when `mad < rec$size_min`, or keep only non-NA distances for the Lost
case.

## Enumeration (every factual unit the change adds)

| unit | verdict | defined by |
|---|---|---|
| roxygen `@param labels`: "an `sf` of points with a `label` column" | holds | `chk_s3_class` and `check_names(labels, "label")` |
| roxygen: "drawn as numbered markers on every static panel" | holds | `marks` joins `outline`, which all three static panels add; the html branch is not static. "numbered" is the article's use; the code draws any text |
| Rd mirrors roxygen | holds | man/knw_compare_map.Rd |
| test: markers change between 0 and 5 % of pixels | holds, and it fires | measured: two label-free renders differ by 0; with labels 0.00079; labels in EPSG:4326 are reprojected and give the same 0.00079 |
| test: an `sf` with no `label` column errors | holds | `check_names` |
| data-raw comment: carries edge type, link's segment gradient and channel width | holds | `s.edge_type`, `s.gradient`, `s.channel_width` from the persist schema's `streams`, the columns both predicates read |
| data-raw: "wet's MAD" | holds | `knw_size` = `grades$size` = `mad_pick` (wet's `pick` annual flow, parent fallback; `link_flow.R`) |
| data-raw: walk distance "measured only where the exception could admit the segment" | holds as written (NA also covers unfound walks; see F4) | `grade_species.R` `cand` |
| zoom-chunk comment: "one example per case … most length inside the window" | holds | `which.max(in_w$len_in[i])`; `len_in` from `st_crop` geometry. Sum of `len_in` equals sum of `st_length(seg_z)` (219,020.6 m), no duplicate ids |
| comment: marker on the in-window part | holds | `st_point_on_surface(seg_z[...])`; distance from each point to its cropped segment is 0 |
| case name "Kept by both" (81390) | holds for this pick; filter too wide (F1) | edge 1000, order 6, width 19.29, gradient 0.0006, MAD 3.64; pre = post both rules |
| case name "Lost: below the flow floor, no river close" (82916) | holds for this pick; filter too wide (F1) | edge 1000, width 6.70 ≥ 1.5, gradient 0.0216 ≤ 0.0549, MAD 0.485 < 0.75, dist 6,791 > 1,000; pre = post |
| case name "Gained: small stream near a river" (33205) | holds for this pick; filter too wide (F1) | edge 1000, order 1, width NA, MAD 0.00049, dist 944 ≤ 1,000, gradient 0.0223 ≤ 0.09; pre = post |
| row 1 explains both verdicts: default by width and gradient, recommended by flow | holds | as above; neither the overlay nor the connectivity pass changed it |
| row 2 explains both verdicts | holds | as above |
| row 3 explains both verdicts: default fails for no width, recommended passes by the exception | holds | `coalesce(channel_width BETWEEN …, FALSE)`; `knw_dist <= 1000` |
| header "Flow (m³/s)" | holds | `knw_size`, the value `size_ok` reads |
| header "Channel width (m)", and "none modelled" for NA | holds | in `bulk_segments` every NA width is order 1 (5,230 NA, all order < 2; 0 NA at order ≥ 2), and fwapg models width only where order > 1 |
| header "Gradient" is link's segment gradient | holds | `s.gradient`, read by `grad_ok` and by fresh's predicate |
| header "To a river of 3 m³/s" | wrong in form (F3) | literal 3; omits "at least" and "downstream" |
| cell "not needed" (row 1) | holds here; label wrong in general (F4) | not a walk candidate (passes size) |
| cells "6.8 km", "940 m" | holds | `km_d(signif(dist, 2))` of 6,791 and 944 |
| columns `default` and Recommended | holds | `flag_default`, `flag_tuned` (post-connectivity), equal to pre for the picks |
| caption: default's 1.5 m and 5.49 % | holds for the stream test | `dflt$size_min`, `dflt$grad_max` |
| caption: recommended 9 %, 0.75 m³/s, or a river within 1 km | holds; omits downstream and ≥ 3 m³/s (F3) | `rec$…` |
| caption: "Distance is measured only where the exception could apply" | holds | `grade_species.R` `cand` |
| map caption: "with the numbered examples the table below describes" | holds | `labels = ex_pts` on the zoom panel only |
| sentence: fourth case 5.49 %–9 % "does not occur in this window" | holds today, not computed; omits the fifth reason (F2) | 0 in-window gains with MAD ≥ 0.75 |
| sentence: "across the province it adds 1,398 km" | holds | `ch$km_all` for gained "gradient between the two maxima" = 1,397.86 |

Code: the `ex` assembly returns NULL with every case empty and then fails on `ex$label`. That is
acceptable for fixed data. The rendered markers sit on their lines (checked at crop); marker 3
covers about a third of its 1.3 km segment but the segment stays traceable.

Checklist: the 760 KB checklist file is the concatenated conventions. I worked from the index
already loaded with the repo instructions (mechanisms "A proxy is not the property", "Restore the
bug and prove the guard fires", literals versus computed values) and did not read the full file.
