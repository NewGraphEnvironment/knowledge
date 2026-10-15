# Code-check round 3 — #52 branch (e8d7bcf...HEAD)

## Mechanism

Every finding in rounds 1-2, and every one below, has the same shape: **the number in a sentence was
checked against the output, but the word that frames it was not.** The framing words (a quantifier such
as "most", "every", "only", "is"; a comparative such as "smaller", "better"; a class label such as
"regulated rivers", "draining straight to the sea"; the population noun "detections" vs "visits") were
chosen to carry the narrative, and each one silently makes a second claim about a population that the
number beside it does not measure. Fix rounds checked the number they were fixing and wrote new framing
around it unchecked, so two of the defects below were introduced by fixes (line 72 was added in a fix
commit; line 144 is round 2's "fits better" re-worded to "describes better", the same unmeasured
comparison). The issue's Result section is a restatement written from an earlier draft, so it carries
the framing the write-up has since softened ("most" survives there and in the Short answer; the Meaning
section already says "about half").

Reach of the mechanism: every sentence in the write-up, the README row, the #52 Result section and the
three script headers that states a number, share, range, direction, quantifier or comparison. All were
enumerated and checked against `data/ch_mad_use.csv`, the two logs, and a recomputation from
`data/fdis/derived/ch_mad_visits.csv` (0295's filters reproduced in a scratch script; 19,077 / 978,
67 WSGs / 15,626, 34 distance WSGs / 7,319 all reproduced exactly) plus read-only fwapg queries.

**Sentences checked: 126** (write-up 92, counting each table row as one; README row 4; issue Result 15;
0294/0295/SQL headers 15). **Failing: 5.**

## Findings

- **[bug]** research/chinook_stream_size.md:37 — "it is most of the small-stream signal." The bullet two
  lines above gives 52 of 107 (48.6 %), which is not most; with `none` included it is 52 of 118 (44 %),
  and of all 153 small-stream CH detections in the analysed visits it is 34 %. Even keeping ambiguous
  placements it is 65 of 120 (54 %). The Meaning section (line 141-142) says "about half" for the same
  52/107, so the write-up contradicts itself. Say "about half".

- **[bug]** GitHub #52 Result section — "Small streams near a large river carry most of the small-stream
  CH." Same numbers: 52 of the 107 detections with a large river downstream (49 %), 52 of 153
  small-stream detections overall (34 %). False as written; inherited from the Short answer's "most".

- **[bug]** research/chinook_stream_size.md:72 — "Regulated visits are a smaller share" (of a class's
  visits than of its detections) is stated generally but fails in 4 of 9 classes: 10-30 m³/s has
  regulated visits 12.3 % against regulated detections 7.5 % (the opposite direction), and 3-10
  (0.9 % vs 0 %), 0.28-0.5 (0.1 % vs 0 %) and < 0.1 (0.04 % vs 0 %) also run the other way
  (`regulated_visit_share` vs `regulated_detect_share` in ch_mad_use.csv, mad_pick/ch_caught). It holds
  for 0.1-0.28, 0.5-1, 1-3, 30-100 and ≥ 100 only. Added in a fix commit. Restrict it to the classes
  named, or name 10-30 as the exception.

- **[bug]** research/chinook_stream_size.md:131 — "FDIS, whose ≥ 100 m³/s share (54 %) is the Nechako
  survey." The ≥ 100 class holds 531 of the 978 FDIS CH visits (54.3 %); the Nechako survey is 432 of
  them (44 % of all, 81 % of the class). 99 detections in that class are other surveys (e.g. a second
  Triton CHES project, 13; LSKE, 6). Same "class described by its largest part" shape as round 2's "to
  the sea". Say "mostly the Nechako survey (44 of the 54 points)".

- **[bug]** GitHub #52 Result section — "Above 30 m³/s the classes are regulated rivers." Regulated
  visits are 66 % of the 30-100 class and 81 % of ≥ 100 (153 and 149 unregulated modelled visits, with
  12 and 41 CH); regulated detections 83 % and 92 %. The write-up says "dominated by", which the
  numbers support; "are" does not.

- **[fragile]** research/chinook_stream_size.md:143-145 — "It describes the pattern in these records
  better than a single floor does, but no rule was fitted or scored against a floor here." Round 2
  flagged "fits better" as unmeasured; the re-wording keeps the comparative and the sentence itself
  says it was not measured. The measured content is the per-group rates (near 14.5 %, far 0.8 %,
  0.1-0.5 overall 3.2 %); state those as the reason rather than a "better" no fit supports.

## Checked and holding (the sentences most at risk under the mechanism)

- "Beyond 500 m, small streams have the rate of the < 0.1 m³/s class" (0.8 % vs 0.9 %) compares the
  34-WSG distance population with the 67-WSG MAD population. On a matched base (same 34 WSGs) it is
  0.84 % vs 0.98 %; over all analysed visits 0.51 % vs 0.74 %. Close on every base, so it holds.
- "higher rate than in any MAD class below 30 m³/s": 14.5 % vs a maximum of 6.9 %, holds on any base.
- 32 WSGs / 11 both / 8 near / 13 far: identical on analysed and modelled bases.
- 1,243 `none` = 558 at hops 0 (9 CH) + 685 with hops (2 CH): reproduced.
- "One stream (the Nechako, one 2010 survey) holds 432" (0295 header): the stream's total is also 432
  (CHES 236 + NECR 196), so stream and project agree.
- 0.1-0.28 regulated detections: CHES 14 + NECR 2, all `side_channel` with `flow_from = own`: as stated.
- 30-100 top project is BC Hydro 2007 on blue line 356363618 (Bridge River, SETN, regulated); the Bridge
  holds 56 of the class's 71 detections, so the README row's attribution holds.
- Cross-check 13 % vs 16 %: restricted to the 106 range WSGs the bcfishobs share is 559/4,218 = 13.3 %,
  so the province-wide base does not move it.
- Sensitivity range 0.08-0.74 and the two exceptions (barriers 1-3 at 0.84; old MAD ≥ 100 at 0) are the
  complete set across the listed sensitivities.
- CABD 38 dams with a degree of regulation, Kenney 621 %, Terzaghi 53 %, 101 qualifying dams; evidence
  data rows 118-119 (file lines 119-120) and 412 (line 413); BULK/MORR the only timing groups; 2 CH
  ≥ 150 mm (fdis_export.md:111): all hold.

No code defects found (0294, 0295, ch_dist_large.sql re-read; the accepted items not re-flagged).
