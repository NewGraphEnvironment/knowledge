## Findings

Round 2 of the review of the labelled examples (commit f50c108, the round-1 fixes). I purled
`vignettes/chinook_rearing.Rmd` into a scratch directory and ran the `load`, `km`, `zoom` and
`examples` chunks under `pkgload::load_all()`. I joined the window's segments and
`data/compare/CH_rear_segments.rds` to `fresh_default.streams` for `waterbody_key` (read-only
queries), and reproduced `R/compare_rules.R`'s change reasons from the segments file. No repo
file other than this one was written.

Severity: G = a gap that can make a future render false, M = minor wording.

### F1 (M): "Two smaller kinds of gain are not among them" reads as the complete list of what is not shown, but the change table has three more rows, one of them larger than a named "smaller" gain

`x$change` province-wide, km:

| direction | reason | km |
|---|---|---|
| lost | size: width passes, tuned fails, no exception | 24,542 |
| gained | exception (size fails, river within D) | 9,666 |
| gained | gradient between the two maxima | 1,398 |
| gained | connectivity or overlay | 533 |
| gained | size: tuned passes, width fails or NULL | 439 |
| lost | connectivity or overlay | 301 |
| gained | other (river-polygon branch or mixed) | 230 |

"The two largest changes" holds: the Lost and Gained examples are the top two rows. The two
"smaller kinds of gain" are the right members, and they are the only other **stream-test** gains.
But the sentence does not say "stream test", so it reads as listing everything else the examples
leave out. It omits the 533 km gained through the hand-entered reaches and the connectivity pass,
which is more than the 439 km it names as smaller. It also omits 230 km gained on river polygons
and mixed causes, and 301 km lost through the connectivity pass. This is round 1's F2 one step
over: the ordinal is gone, but the set it stood for is still implied.

Neither the set nor the ranking is computed. Nothing checks that the shown reasons are the two
largest. Nothing checks that "gradient between the two maxima" is non-empty either: it assumes
`rec$grad_max > dflt$grad_max`.

Fix: write "Two smaller stream-test gains…" and add one clause for the rest, built from `ch`
("the hand-entered reaches and the connectivity pass account for 533 km gained and 301 km lost,
and river polygons for 230 km"). Optionally `stop()` when the two example reasons are not the
two largest rows of `ch`.

### F2 (M): the data-raw header says the pre flags are "before the connectivity pass", but they are taken before the hand-entered reaches too

`compare_rules.R` sets `rearing_pre_connect = rearing` at line 194, right after the predicate,
and before `frs_habitat_overlay()` at line 198. The flag is therefore the predicate's verdict
alone. `fresh`'s overlay writes only `SET <type> = TRUE` on the habitat column, and no function
in `fresh` (0.39.0) touches `*_pre_connect`. The vignette's comment states this correctly
("neither rule's verdict changed by the hand-entered reaches or the connectivity pass"). The
data-raw header understates it, and the vignette's claim about the hand-entered reaches rests on
the broader meaning.

Fix: "each rule's flag from its predicate alone, before the hand-entered reaches and the
connectivity pass".

The filter's logic holds. The overlay only adds and the connectivity pass only drops, so pre ==
post implies that the final verdict is the predicate's.

### F3 (G, latent): "on the stream test's own edges" matches the stream test's edge types, but not its branch, which also excludes waterbody polygons

The literal `c(1000, 1100, 2000, 2300)` matches link's `configs/default/rules.yaml` CH `rear`
stream rule (`edge_types_explicit`). The CH rear stream rule has no `in_waterbody: false`, so
the recommended rule's stream branch (`sb` in `compare_rules.R`) also requires that the segment
lie in no river polygon, no wetland of 1 ha or more, and no lake or reservoir of 100 ha or more.
Off that branch, the recommended rule is fresh's predicate (width test or wetland test), not the
flow test. Measured:

- 75,491 edge 1000/1100/2000/2300 segments in the 31 groups lie in such a waterbody, all of them
  wetlands. In BULK there are 1,133, and 31 of them (edge 1000) are inside the window, past the
  new filter.
- None can be a Lost or Gained pick today. Both rules decide them by the same wetland test, and
  their changes province-wide are connectivity-only, except one 36 m edge-2000 segment in ALBN.
  None meets "Kept by both" either: the window's largest MAD among them is 0.25.
- Latent: after a rebuild or a re-chosen window, a wetland segment with MAD ≥ 0.75 and width ≥
  1.5 m would pass "Kept by both". Its row would then say the recommended rule read its flow,
  where the rule read fresh's width or wetland test. The verdict would be right and the
  explanation wrong.

The edge set is also a typed literal. Round 1's F3 was the same kind of finding.

Fix: carry an in-branch flag (or `waterbody_key` in branch polygons), together with the stream
rule's edge types, into `bulk_segments.rds` from `data-raw` (which already reads from the
database), and filter on it. Otherwise, `stop()` if a pick is in a branch waterbody.

### F4 (M): the caption's "or" can be read as waiving the gradient

"the recommended rule needs a gradient of at most 9 % and a flow of at least 0.75 m³/s, or a
river of at least 3 m³/s within 1 km downstream". The rule is `grad_ok AND (size_ok OR exc)`
(`tuned_sql`), and the walk is made only within the gradient maximum (`grade_species.R` `cand`).
The sentence can be read as "(gradient and flow) or river". `words()` in the article's headline
has the same structure. Suggest "a gradient of at most 9 % and either a flow of at least … or a
river of at least … within 1 km downstream", in both places.

## Checked and holds

- **The pre flags in `bulk_segments.rds`.** They equal `CH_rear_segments.rds`'s
  `rearing_pre_default`/`rearing_pre_tuned` for all 16,686 BULK segments, with no NA. The
  meta `md5_local` matches the segments file. In BULK, pre ≠ post on 1,227 segments for
  `default` and 689 for the recommended rule, so the filter does real work.
- **The picks.** They are unchanged (81390, 82916, 33205). All three are edge 1000 with no
  `waterbody_key`, and pre equals post for both rules.
- **"no river found".** It is exact wherever it can print. Only the Lost case admits an NA
  distance. A Lost pick has `default` TRUE on a stream edge with pre == post, so its gradient is
  at most 5.49 % (within 9 %). It is accessible (`bulk_segments` keeps only accessible
  segments, the same gate as `knw_link_segments()`), and its MAD is non-NA and below 0.75. It is
  therefore a walk candidate (`cand`), and its distance is NA only when `status != "found"`.
- **"not needed".** It is exact for Kept: MAD ≥ 0.75 means it passes the size test and is not a
  candidate. NA MAD cannot reach the `if ()`, because every case requires a non-NA comparison of
  `mad`.
- **`gain_grad` and `gain_flow`.** Each is a single `ch` row. The rendered values, 1,398 km and
  439 km, equal `x$change` province-wide. `^gradient` cannot pick up the lost "gradient: tuned
  maximum lower" row, because the direction filter excludes it.
- **The caption's distance wording.** "the first such river downstream, measured only where the
  exception could apply" matches `knw_link_walks()` (the first flow ≥ `exc_q` downstream) and
  `cand`. The header and cells render as expected: "not needed", "6.8 km", "940 m".
