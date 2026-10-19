## Findings

Round 3 of the review of the labelled examples (commits 70be3cf, f50c108, 693fcef), closed by
enumeration. I purled `vignettes/chinook_rearing.Rmd` into a scratch directory and ran the `load`,
`km`, `zoom` and `examples` chunks under `pkgload::load_all()`. I re-derived `R/compare_rules.R`'s
change reasons from `data/compare/CH_rear_segments.rds` (125 groups, 5,757,827 segments). I derived
`default`'s CH rear predicate with `fresh::frs_habitat_predicates()` from link's `configs/default`
at the run's commit (a17e917; `rules.yaml` is identical to link's working tree), and read
`fresh_default.streams` and the FWA polygon tables read-only for BULK's branch waterbodies. The only
repo file written is this one.

Severity: M = a sentence or comment whose set is not the set the code defines. Neither finding
changes a rendered number.

### F1 (M): "The rest of the change comes from the hand-entered reaches and the connectivity pass" names a cause that cannot separate the two rules

The sentence restates `compare_rules.R`'s reason label "connectivity or overlay". The code defines
that row as `pre_d == pre_t`: both predicates give the same verdict, and the final flags still
differ. The overlay cannot produce such a difference. `fresh::frs_habitat_overlay()` (0.39.0) runs
`SET <type> = TRUE` on the user-habitat table's keys, conditioned only on the flag being FALSE or
NULL. It is called with the same table under both rules, so it marks the same reaches in both.
Spawning, the other input to the connectivity pass, is `pred_other` (default's spawning) under both
rules. Only the connectivity pass, acting on the rearing clusters each predicate drew, can leave
the two rules different here.

Measured on `CH_rear_segments.rds`, splitting the row by the pre flags:

| direction | pre (default, tuned) | km |
|---|---|---|
| gained | TRUE, TRUE | 533.1 |
| gained | FALSE, FALSE | 0.1 |
| lost | TRUE, TRUE | 300.6 |

- 533.1 of the 533.2 km gained and all 300.6 km lost are segments that both predicates already
  call habitat. On them the hand-entered reaches change nothing, and the connectivity pass kept
  one rule's copy and dropped the other.
- The remaining 0.1 km was hand-entered under both rules and dropped by the connectivity pass
  under `default` only. That is still a connectivity difference.

Earlier, the article says "Reaches confirmed by hand are then added". A reader can take this
sentence to mean that the recommended rule adds or keeps different hand-entered reaches. It does
not.

Fix: "The rest of the change comes from the connectivity pass, which keeps different clusters under
each rule (533 km gained, 301 km lost)". The label in `compare_rules.R` is outside this diff. If it
changes, the vignette's `grepl("^connectivity", …)` still matches.

### F2 (M): the data-raw header says the walk distance is "measured only where the exception could admit the segment", but the walk also covers stream edges in wetlands, which the exception cannot admit

`knw_grade_species()`'s `cand` (`R/grade_species.R` lines 50–51) is:
`accessible & edge_type %in% edge_stream & gradient within [0, grad_max] & !size_ok`.
It does not exclude the branch waterbodies. `compare_rules.R`'s stream branch `sb` does: CH's rear
stream rule has no `in_waterbody: false`, so `sb` excludes river polygons, wetlands of 1 ha or
more, and lakes and reservoirs of 100 ha or more. On a segment off `sb`, the recommended rule is
fresh's predicate (`p_tuned_base`), and the exception plays no part.

- **Measured in BULK.** 730 segments (117.8 km) on stream edges inside wetlands of 1 ha or more
  carry a `dist_m` in `bulk_segments.rds`. None has a river polygon or lake. None has differing
  pre flags, so no count in the article moves.
- **Same claim, other homes.** `knw_grade_species()`'s roxygen ("accessible stream-branch
  segments") makes the same claim. It is outside this diff, and the header inherits it.
  `compare_rules.R`'s `ex_ok` reads the same column for its "exception" reason. Round 2 measured
  the wetland stream-edge changes as connectivity-only, apart from 36 m.
- **The table caption holds.** Its sentence ("measured only where the exception could apply")
  describes the table's rows. Those rows are filtered to `!in_waterbody`, and there `cand` and the
  exception's reach coincide.

Fix: in the data-raw header, write "measured on accessible stream-edge segments inside the gradient
maximum that fail the size test (the exception's candidates, and also stream edges in wetlands of
1 ha or more, which it cannot admit)", or restrict `cand` to the branch. The roxygen fix belongs
with it.

## Enumeration

How the list was made complete: every added or changed line of the diff, taken hunk by hunk over
the six files (`R/compare_map.R`, `data-raw/vignette_chinook.R`, `man/knw_compare_map.Rd`, the test,
the vignette; the `.rds` through the columns the data-raw script writes), and every rendered line the
changed code produces. In the article that is the headline (it calls the changed `words()`), the
seeds sentence (it also calls `words()`), the map caption, the example table and its caption, and
the paragraph after the table. Each unit below is a clause carrying a fact or a filter condition.

| # | unit | verdict | defined by |
|---|---|---|---|
| 1 | `compare_map.R` roxygen: `labels` is `NULL` or an `sf` of points with a `label` column | holds | `chk_s3_class`, `check_names(labels, "label")` |
| 2 | roxygen: drawn as markers on every static panel | holds | `marks` joins `outline`, which every static panel adds |
| 3 | Rd mirrors roxygen | holds | `man/knw_compare_map.Rd` |
| 4 | test: markers change between 0 and 5 % of pixels; no `label` column errors | holds | round 1 restored the defect and the test fired |
| 5 | data-raw: carries edge type, link's segment gradient and channel width | holds | `s.edge_type`, `s.gradient`, `s.channel_width`, the columns both predicates read |
| 6 | data-raw: wet's MAD | holds | `mad = knw_size` = `grades$size` = `mad_pick` |
| 7 | data-raw: walk distance "measured only where the exception could admit the segment" | **wrong (F2)** | `grade_species.R` `cand`: 730 BULK wetland stream-edge segments carry a distance |
| 8 | data-raw: each rule's verdict from the habitat test alone, before the hand-entered reaches and the connectivity pass | holds | `rearing_pre_connect` set at `compare_rules.R` line 194, before the overlay (198) and the connectivity pass (203); the access gate is in it, and every saved row is accessible |
| 9 | data-raw: whether the segment lies in any waterbody | holds | `in_waterbody = !is.na(waterbody_key)` from `fresh_default.streams` |
| 10 | headline: "a gradient of at most 9 %, and either a mean annual flow of at least 0.75 m³/s or a river of at least 3 m³/s within 1 km downstream" | holds | `tuned_sql` on `sb`: `grad_ok AND (size_ok OR ex)`; rule `mad>=0.75\|g<=0.09\|Q3@D1000` |
| 11 | headline: default "a gradient of at most 5.49 %, and a channel at least 1.5 m wide" | holds | fresh predicate: `gradient BETWEEN 0 AND 0.0549 AND channel_width BETWEEN 1.5 AND 9999` |
| 12 | seeds sentence via `words()`: 5.49 %, 0.5 m³/s, 3 m³/s within 2 km downstream | holds | `seed_other` rule `mad>=0.5\|g<=0.0549\|Q3@D2000` |
| 13 | zoom comment: one example per case, the one with the most length inside the window | holds | `which.max(len_in)`, `len_in` from `st_crop` geometry |
| 14 | comment and filter: on the stream test's own edges | holds | literal `c(1000, 1100, 2000, 2300)` equals CH rear's `edge_types_explicit` at a17e917 |
| 15 | comment and filter: in no waterbody, stricter than the stream branch | holds (the list omits reservoirs of 100 ha or more, which `sb` also excludes; "stricter" still holds) | `!in_waterbody`; `sb` excludes only branch waterbodies |
| 16 | comment and filter: neither verdict changed by the hand-entered reaches or the connectivity pass | holds | `pre == flag` for both rules; the overlay only adds and the connectivity pass only drops, so pre == post means the final verdict is the predicate's |
| 17 | case "Kept by both": `fd & ft & mad >= 0.75 & width >= 1.5 & gradient <= 5.49 %` | holds | with 14–16, default passes its stream test and the recommended rule passes by flow; pick 81390 (edge 1000, order 6, 19.29 m, 0.06 %, MAD 3.64) |
| 18 | case "Lost: below the flow floor, no river close" | holds | filter ⊂ the change reason "size: width passes, tuned fails, no exception" (w_ok and g_def follow from fd on `sb`); pick 82916 (6.70 m, 2.16 %, MAD 0.485, 6,791 m) |
| 19 | case "Gained: small stream near a river" | holds | filter ⊂ reason "exception" (g_tun follows from ft on `sb`); pick 33205 (order 1, no width, MAD 0.00049, 944 m) |
| 20 | marker on the in-window part of each pick | holds | `st_point_on_surface` of the cropped geometry: distance 0 to each, all three inside the box; in the PNG, 1 is on blue, 2 on orange, 3 on green |
| 21 | map caption: "with the numbered examples the table below describes" | holds | `labels = ex_pts` on the zoom panel only |
| 22 | table caption: "what each rule reads and what each decides" | holds | 17–19 plus 16 |
| 23 | caption: default needs ≥ 1.5 m and ≤ 5.49 % | holds | as 11; the 9999 m maximum is immaterial |
| 24 | caption: recommended ≤ 9 % and either ≥ 0.75 m³/s or a ≥ 3 m³/s river within 1 km downstream | holds | as 10 |
| 25 | caption: distance to the first such river downstream, measured only where the exception could apply | holds for the rows (see F2) | `knw_link_walks()` first flow ≥ `exc_q`; rows are `!in_waterbody` |
| 26 | header "Flow (m³/s)", cells 3.6, 0.48, 0.00049 | holds | `mad`, `formatC(fg, 2)` |
| 27 | header "Channel width (m)", cells 19, 6.7, "none modelled" | holds | NA widths are all order 1, and fwapg models order > 1 only; the " 19" padding is trimmed by HTML |
| 28 | header "Gradient", cells 0.06 %, 2.16 %, 2.23 % | holds | `s.gradient`, which both predicates read |
| 29 | header "Downstream to a river", cells "not needed", "6.8 km", "940 m" | holds | Kept: MAD ≥ 0.75, so not a candidate; `signif(6791, 2)`, `signif(944, 2)`; "no river found" can print only for Lost (round 2) |
| 30 | columns default and Recommended | holds | `flag_default`, `flag_tuned`, equal to pre for the picks |
| 31 | "The examples show what both rules keep and the two largest changes" | holds (not computed; round 2's optional guard was not taken) | the Lost and Gained picks fall in the two largest rows, 24,542 and 9,666 km |
| 32 | "Two smaller gains through the stream test" | holds | the only other stream-edge gain reasons; stream-edge proxy against `sb` differs by 36 m (round 2) |
| 33 | "streams between 5.49 % and 9 % steep, which only the new gradient maximum admits (1,398 km)" | holds | `size_tun & g_tun & w_ok & !g_def`; 1,397.9 km |
| 34 | "flow passes the floor where default's width test fails or has no width (439 km)" | holds | `size_tun & g_tun & !w_ok`; 439.1 km |
| 35 | "comes from the hand-entered reaches and the connectivity pass (533 km gained, 301 km lost)" | **wrong (F1)** | numbers hold (533.2, 300.6); the overlay cannot separate the rules |
| 36 | "from river polygons and mixed causes (230 km gained)" | holds | "other": 229.6 km on edges 1250/1350/1450, 0.1 km on edge 1000 |

### The change table's reasons are all accounted for

The change table's reasons, re-derived from the segments (the values equal the article's `x$change`):

| direction | reason | km | where the article names it |
|---|---|---|---|
| lost | size: width passes, tuned fails, no exception | 24,542.3 | km table, and example 2 |
| gained | exception (size fails, river within D) | 9,665.8 | km table, and example 3 |
| gained | gradient between the two maxima | 1,397.9 | unit 33 |
| gained | connectivity or overlay | 533.2 | unit 35 |
| gained | size: tuned passes, width fails or NULL | 439.1 | unit 34 |
| lost | connectivity or overlay | 300.6 | unit 35 |
| gained | other (river-polygon branch or mixed) | 229.7 | unit 36 |

The two reasons the code can emit and the data does not, "gradient: tuned maximum lower" and lost
"other", are empty because the tuned maximum is higher. The sums close: lost 24,542 + 301 = 24,843,
and gained 9,666 + 1,398 + 533 + 439 + 230 = 12,266. Both match the km table.

Latent, not a defect for fixed data: if a later build produced a lost "other" row, nothing would
name it. A missing named row would leave its `grepl()` empty, and `n0(numeric(0))` would render a
blank number.
