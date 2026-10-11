# Meaning audit, late sources, round 1 (#44): data rows 1015-1070

Scope: the 56 rows the late drafter added (data row N is file line N + 1), from six sources, read against the source
page beyond the quoted sentence. Then the second-hand rows that the drafter says the originals contradict.

Rendered pages checked (scratchpad `aud/`):
- Hatfield & Bruce pp. 1012-1013. Every Table 3 sign, coefficient and R2 in rows 1015-1026 matches. Sign
  reading confirmed: the text layer's `2` is minus and `1` is plus.
- Raleigh et al. 1984 pp. 6, 8, 9, 19, 41, 45, 49 (PDF page = printed + 9).
- Hickman & Raleigh pp. 4, 5, 6 (PDF 12-14).
- McMahon pp. 4-6, mapped by tesseract (PDF 12-14).
- Ford et al. 1995 p. 53 (PDF 77), from the Zotero copy, to confirm the printed "55%". It is printed, not an OCR
  slip.

## Errors in rows 1015-1070

### 1046 (CT juvenile focal velocity 10-12 cm/s, Raleigh 1984 p. 9): `bound = optimum` on an observed span
- **What is wrong:** the page says "Griffith (1972) reported focal point velocities for juvenile cutthroat in Idaho
  of between 10 and 12 cm/sec, with a maximum velocity of 22 cm/sec". Nothing calls 10-12 optimal or preferred.
  It is where the fish were seen. The row's own note says "The usual span, not a limit". Coding it `optimum`
  promotes an observation to a best-suitability band.
- **Convention:** the table codes the same sentence shape as `range` + `dist` with a separate `max`. Data rows
  956/957 (Ford: "most redd building ... between 50 and 90 cm/s with an upper limit of 150 cm/s") do this. The
  brief says "a span of observed values is `range` with `kind` `dist`".
- **Fix:** `bound = range`, with `value_min` 10, `value_max` 12 and `kind dist` unchanged.
  - `note`: "Focal point velocities of juvenile cutthroat (Griffith 1972; the reference list names brook and
    cutthroat trout in small northern Idaho streams), given in the juvenile section of the rainbow trout model. An
    observed span, not a limit and not an optimum; the maximum observed is the next row. Same sentence as the
    22 cm/s row (next row)."

### 1049, 1050 (RB spawning velocity, Figure 2): `region = Not stated`, but p. 39 names the streams
- **What is wrong:** the note itself lists the curve's basis from p. 39, the text that builds the Figure 2
  velocity curve:
  - Lardeau River, British Columbia (Hartman & Galbraith 1970);
  - Deschutes River, Oregon (Smith 1973);
  - South Fork Feather River, California (Hooper 1973);
  - Idaho streams (Orcutt et al. 1968).

  The same source's fry and juvenile curve rows (1053, 1054) take their region from the text page. Round 2 made
  the same correction on the Raleigh 1986 curve rows (742 and nine others).
- **Fix (both rows):** `region = Lardeau River, British Columbia; Deschutes River, Oregon; South Fork Feather River,
  California; Idaho streams (p. 39)`. The notes stand.
- **Advisory, not an error:** 1051/1052 (depth) correctly stay `Not stated`. The p. 43 depth paragraph cites the
  same four studies but names no place.

### 1053 (RB fry velocity, Figure 3, p. 45): the note drops a coordinate
- **What is wrong:** the note lists "SI 1.0 at 0, 0.78 at 0.49, 0.19 at 0.98, 0.01 at 1.97-2.46 and 0 at 2.95 ft/s".
  The rendered page has a point between 0.98 and 1.97: **1.48, 0.04**. Without it, the note reads as a straight
  fall from 0.19 to 0.01. The coordinates are complete on the page (0.00/1.00, 0.49/0.78, 0.98/0.19, 1.48/0.04,
  1.97/0.01, 2.46/0.01, 2.95/0.00, 100/0.00).
- **Fix, `note`:** "Figure 3, fry (<2 inches) mean water column velocity SI curve, n = 619: SI 1.0 at 0, 0.78 at
  0.49, 0.19 at 0.98, 0.04 at 1.48, 0.01 at 1.97-2.46 and 0 at 2.95 ft/s, the upper zero-suitability edge
  (coordinates checked on the rendered page; the OCR drops the 2.46 line). Weighted, normalized frequencies of fry
  observations (p. 44). The quote is the coordinate columns as the OCR emits them."

### 1054 (RB juvenile velocity, Figure 4, p. 49): the note drops a coordinate
- **What is wrong:** the note lists "0.24 at 1.48, 0.02 at 2.46-3.44". The rendered page has **1.97, 0.08** between
  those points (coordinates: 0.00/1.00, 0.49/0.99, 0.98/0.59, 1.48/0.24, 1.97/0.08, 2.46/0.02, 3.44/0.02, 3.50/0.00).
- **Fix, `note`:** "Figure 4, juvenile mean water column velocity SI curve, n = 546: SI 1.0 at 0, 0.99 at 0.49, 0.59
  at 0.98, 0.24 at 1.48, 0.08 at 1.97, 0.02 at 2.46-3.44 and 0 at 3.50 ft/s, the upper zero-suitability edge
  (coordinates checked on the rendered page). From Moyle et al. (1983) observations of juveniles 2.0-4.7 inches
  long (pp. 47-48). The quote is the coordinate columns as the OCR emits them."

## Advisory (defensible as written; Al's call)

- **1028** (FISH rearing, min 10 % MAD, `expert`): this is a review's reading of diversion experiments, not a
  recommendation. The note says so. `qual` would avoid presenting a threshold the authors never set. Leave as is,
  or recode `kind = qual` and blank bound, value, unit and metric. The drafter flagged the same doubt.
- **1035** (CO fry winter velocity <15 cm/s, `dist`): the page says the fish "seek" slow water, which is
  selection, so it is nearer `pref` than `dist`. Minor.
- **1033, 1034** (`pref`, Smith 1973 via McMahon): the page's own word is "Preferred", so `pref` follows the page.
  Data rows 952-953 code Smith's numbers `expert` because Bjornn & Reiser present them as criteria. The two are
  not inconsistent, because each follows its page.
- **1055:** "at 45° F" may qualify both clauses of the sentence. 1056 carries it, 1055 does not. Optionally append
  "at 45 F" to the 1055 note.
- **1044:** worth adding to the note that p. 39 and Figure 2 put the unsuitable edges at 1.0 and 3.0 ft/s (30.5 and
  91 cm/s). That is a second possible source for Ford's "30 to 90" (see 954 below).
- **1015-1026:** the shared sign example ('21.002, 10.796') is the *brown trout fry* interval. It is correct as an
  illustration of the glyph rendering, but it sits in chinook, rainbow and steelhead rows. Optionally write
  "(brown trout fry's 80 % interval reads ...)". None of the 12 notes names data rows 810-817 and 827, the
  site applications that cite this paper. The drafter's reason (no primary valued row) is sound.

Checked and correct, beyond the above:
- **1015-1026:** all 12 equations, R2, the 13-species count (p. 1009), the Figure 2-3 units ("natural logarithms
  of cubic feet per second") and the region list (p. 1007).
- **1027, 1029-1032:** p. 1027's "no specific target species" sentence. Pages 169, 170, 171 and 174 are confirmed
  against the layout headers.
- **1036:** Figure 1 (p. 10) has no flow variable.
- **1037, 1038:** p. 5 confirmed on the render ("11 to 40", "11 to 92"). Table 1's related-species sentence is on
  p. 21. The spawning-site definition is on p. 23.
- **1039-1042:** "≥ 50%" on the render of p. 6. V14 on p. 19 is linear from 0 to 1.0 at 50 %.
- **1043:** pp. 7-8 and V18 (p. 21).
- **1044, 1045:** p. 8.
- **1048:** p. 28, steelhead site area.
- **1049-1052:** Figure 2 coordinates and the p. 43 depth text.
- **1055, 1056:** p. 48, n = 78 and 122.
- **1057-1070:** every Table 2-1 and Table 3-1 cell. Methods are p. 17 (redd centre, early July) and p. 48 (0-150 mm,
  late August to early September 2009-2010), with ICRRR 2008 on p. 49. Bear Lake cutthroat *O. clarkia utah* as
  printed.
- **Cross-references** ("previous/next row" pairs 1033/1034, 1044/1045, 1046/1047, 1055/1056; data rows 751, 942,
  943, 954, 960, 961-964): all resolve.

## Second-hand rows

Every second-hand row below records Ford et al. 1995 faithfully. Each Ford quote is confirmed in the OCR, and
p. 53's "55%" also on the render. The question is what to do where Ford misstates the original. The proposal
follows one rule:
- **Convert in place to `qual`** where Ford's number or species is not what the original prints, and the original
  now has its own row. Leaving the value would put a second, wrong number for the same fact into the grid.
- **Amend the note only** where Ford's number matches the original, or the mismatch is not established.

Recommendation first; the alternative for every conversion is "amend note only, keep values".

A `qual` row must carry no value and no metric (`literature.R`: `qual_value`, `idle`). So a conversion blanks
`bound`, `value_min`, `value_max`, `unit` and `metric`, sets `kind = qual`, and keeps species, stage, quote,
page and cited_source.

### 954 (Ford p. 52: RB "optimal water velocity range is 30 to 90 cm/s", citing Raleigh et al. 1984): convert
- **Original:**
  - Raleigh 1984 p. 8: "The optimal water velocity above rainbow trout redds is between 30 and 70 cm/sec.
    Velocities less than 10 cm/sec or greater than 90 cm/sec are unsuitable."
  - p. 39 and Figure 2 (p. 41): unsuitable below 1.0 and above 3.0 fps (30.5 and 91 cm/s), with SI 1.0 from 1.6
    to 3.0 fps.
- **What Ford did:** 30-90 is not called optimal anywhere. It is either p. 8's optimum floor joined to its
  unsuitable edge, or p. 39's suitable span converted to cm/s. Either way it is a suitability span labelled
  optimal.
- **Fix:** `kind = qual`. Blank `bound`, `value_min` and `value_max`; `unit` blank.
  - `note`: "Ford et al. call 30-90 cm/s Raleigh et al.'s (1984) optimal spawning velocity. The original's optimum
    is 30-70 cm/s, with velocities below 10 or above 90 cm/s unsuitable (p. 8; data rows 1044, 1045). Its spawning
    curve puts the unsuitable edges at 1.0 and 3.0 ft/s, about 30 and 91 cm/s, with SI 1.0 from 1.6 to 3.0 ft/s
    (pp. 39, 41; data rows 1049, 1050). So Ford's 30-90 is a suitable span, not an optimum, and no value is drawn
    here."

### 955 (Ford p. 52: RB "water depths between 0.15 and 2.5m"): convert
- **Original:** Raleigh 1984 prints no 0.15-2.5 m span.
  - 2.5 m is Figure 2's 8.2 ft upper SI-1.0 edge (p. 43: "depths less than 0.6 and greater than 8.2 feet are
    assumed to be unsuitable ... although 8.2 feet may not be the upper limit").
  - 0.15 m matches the 15 cm in the spawning-site definition (p. 28). It is not the curve's lower edge, 0.6 ft
    (0.18 m).
  - The round-2 advisory also applies: Ford's sentence calls only the velocity optimal, so `optimum` on this row
    was already a stretch.
- **Fix:** `kind = qual`. Blank `bound`, `value_min` and `value_max`; `unit` blank.
  - `note`: "Ford et al. give 0.15-2.5 m as the depths Raleigh et al. (1984) paired with the optimal spawning
    velocity, and add that the main consideration with depth is enough flow for incubation and emerging fry.
    Raleigh et al. print no such span. 2.5 m is the 8.2 ft upper edge of the spawning depth curve, whose lower edge
    is 0.6 ft (pp. 41, 43; data rows 1051, 1052). 15 cm is the minimum depth in the model's spawning-site definition
    (p. 28; data row 1048). No value is drawn here."

### 960 (Ford p. 49: RB juveniles 5-13 cm, 10-12 cm/s, max 22, citing Raleigh et al. 1984 and Rose 1986): convert
- **Original:** Raleigh 1984 p. 9: "Griffith (1972) reported focal point velocities for juvenile cutthroat in Idaho of
  between 10 and 12 cm/sec, with a maximum velocity of 22 cm/sec". It gives no length.
- **Rose (1986)** is "Growth decline in subyearling brook trout (Salvelinus fontinalis) after emergence of rainbow
  trout" (Ford's reference list, p. 5393 of the OCR text). That is a growth study, the probable source of the
  5-13 cm. The velocities are Griffith's cutthroat.
- **Fix:** `kind = qual`. Blank `bound`, `value_min` and `value_max`; `unit` blank. `species_code` stays RB, because
  this is Ford's statement about rainbow trout.
  - `note`: "Ford et al. give 10-12 cm/s and a maximum of 22 cm/s for rainbow trout juveniles 5-13 cm long, citing
    Raleigh et al. (1984) and Rose (1986). Raleigh et al. give exactly these numbers for juvenile cutthroat in Idaho
    (Griffith 1972; p. 9; data rows 1046, 1047), with no length. Rose (1986) is a study of brook trout growth after
    rainbow trout emergence (Ford's reference list). So the velocities are not a rainbow trout measurement, and no
    value is drawn here."

### 961, 963 (Ford p. 53: base flow "greater than 55%" excellent, RB rearing / overwintering): convert
- **Original:** Raleigh 1984 p. 6, rendered page: "A base flow ≥ 50% of the average annual daily flow is considered
  excellent ..., a base flow of 25 to 50% is considered fair". V14 (p. 19) reaches SI 1.0 at 50 %.
- **Ford's version:** Ford prints 55 (confirmed on the render of Ford PDF p. 77). That leaves 50-55 % unclassed in
  Ford's own sentence. The 55 is a transcription error, and data rows 1039/1041 now carry the original's 50.
- **Fix (both rows):** `kind = qual`. Blank `bound`, `value_min`, `unit` and `metric`.
  - `note` (961, "late summer" in 961; "winter" in 963): "Excellent class, late summer base flow, as Ford et al.
    print it: 'greater than 55%' of average annual daily flow, with 25-50 % fair and below 25 % poor, citing Raleigh
    et al. (1984). The original prints '≥ 50%' for excellent (p. 6; data row 1039 [963: 1041]), so Ford's 55 leaves
    50-55 % unclassed and is not the source's value; no value is drawn here. In the rainbow trout chapter; the
    sentence itself says 'trout'. Printed page 53 (the OCR reads '33')."

### 962, 964 (the 25 % fair edge): amend note only
- Ford's 25 matches the original, so the value stands.
- **Fix, `note`:** replace the current text with: "Lower edge of the fair class, late summer [964: winter] base
  flow: below 25 % is poor. The base or lowest flow of late summer or winter months, as a percent of average annual
  daily flow (mean annual discharge), rated for trout habitat, citing Raleigh et al. (1984). The 25 % edge matches
  the original (p. 6; data row 1040 [964: 1042]); Ford's '>55 %' excellent class does not (the original prints
  '≥ 50%'; data row 961 [964: 963]). In the rainbow trout chapter; the sentence itself says 'trout'. Printed page
  53 (the OCR reads '33')."

### 942 (Ford p. 78: CT spawning 11-90 cm/s, "studies reported in Hickman and Raleigh"): amend note only
- **Original:** Hickman & Raleigh p. 5 (rendered): Hooper (1973) and Thompson (1972) 31-92 cm/s, Hunter (1973)
  11-40 cm/s; "Average water column velocities for embryo development apparently range from 11 to 92 cm/sec". Ford's
  90 is two units off, and data row 1037 carries 11-92. Recommendation: keep the value, because the gap is small
  and Ford's span is otherwise the original's. Converting is the consistent alternative under the rule above.
- **Fix, `note`:** "Spawning velocities from studies reported in Hickman and Raleigh (1982). The original gives 11-92
  cm/s, as average water column velocities for embryo development (p. 5; data row 1037), so Ford's upper 90 is
  2 cm/s low."

### 943 (Ford p. 78: CT optimum 30-60 cm/s): amend note only
- **Original:** Hickman & Raleigh p. 6 (rendered; the OCR has no text for it): "We assume that optimal velocities
  range from 30 to 60 cm/sec". Ford matches. There is no primary row, because the page cannot be quoted.
- **Fix, `note`:** "Estimated optimal spawning velocity range. Table 4 (p. 70) lists 30-60 cm/s as estimated optimal
  spawning velocity for westslope cutthroat. Matches the original, Hickman and Raleigh (1982) p. 6, 'We assume that
  optimal velocities range from 30 to 60 cm/sec' (read on the rendered page; the scan's OCR cannot be quoted, so the
  original has no row of its own)."

### 958, 959 (Ford p. 47: RB fry "less than 30 cm/s", "prefer less than 8 cm/s"): amend note only
- **Ford's text:** the sentence names no source.
- **The match:** it and the next sentence ("Fry will move to deeper, faster water as they grow, using interstices
  between rocks, debris piles, and aquatic vegetation for cover") follow Raleigh 1984 p. 8 closely: "Fry utilize
  velocities less than 30 cm/sec, but velocities less than 8 cm/sec are preferred (Griffith 1972; Horner and Bjornn
  1976)".
- **The cited studies:** Griffith (1972) is brook and cutthroat trout in northern Idaho. Horner & Bjornn (1976) is
  "trout and salmon fry", species unnamed. Rainbow trout cannot be ruled out, so this is a caveat, not a
  misattribution.
- **Fix, `note` 958:** "Recently emerged fry. The sentence names no source; it matches Raleigh et al. (1984) p. 8
  ('Fry utilize velocities less than 30 cm/sec, but velocities less than 8 cm/sec are preferred'), whose cited
  studies are Griffith (1972), brook and cutthroat trout in northern Idaho, and Horner and Bjornn (1976), trout and
  salmon fry of unnamed species. So the species measured is uncertain."
- **Fix, `note` 959:** "Recently emerged fry prefer velocities below 8 cm/s. The sentence names no source; see the
  previous row: it matches Raleigh et al. (1984) p. 8, whose cited studies are Griffith (1972, brook and cutthroat
  trout) and Horner and Bjornn (1976, trout and salmon fry), so the species measured is uncertain."

### 936, not 940 (Ford p. 72: WCT age 1+/2+, 10-12.5 cm/s, max 22): amend note only
- **Row number:** the drafter's notes call this "DR 940". Data row 940 is CT spawning depth 6-40 cm (Reiser &
  Bjornn), which has no problem. The 22 cm/s westslope row is data row **936**.
- **What 936 is:** the sentence names no source. The numbers trace to Griffith (1972), whose fish Ford calls
  westslope on the same page:
  - Raleigh 1984 p. 9 gives 10-12 and max 22 cm/s for juvenile cutthroat in Idaho (data rows 1046, 1047).
  - Hickman & Raleigh p. 5 gives 10-14 and max 22 cm/s for adult cutthroat on territorial stations.
  - Roberge (data row 937) gives 10-12.5 for juveniles, citing Griffith (1972).
- WCT stands.
- **Fix, `note`:** "Age 1+ and 2+. The sentence follows Griffith (1972) on westslope cutthroat fry and names no source
  of its own; the 2004 WCT account (p. 6) repeats the maximum for westslope cutthroat, citing Ford et al. 1995. The
  same maximum traces to Griffith (1972), cutthroat in small northern Idaho streams: Raleigh et al. (1984) p. 9 give
  10-12 and 22 cm/s for juvenile cutthroat (data rows 1046, 1047), and Hickman and Raleigh (1982) p. 5 give 10-14
  and 22 cm/s for adults."

audited 56 rows, 5 with errors; second-hand rows: 12 changes (5 conversions to `qual`: 954, 955, 960, 961, 963;
7 note amendments: 936, 942, 943, 958, 959, 962, 964)

## Mechanisms

1. **A note listing curve coordinates drops a point** (1053, 1054). The point always sits on a steep, decaying
   tail, where a summary feels complete without it. List every coordinate pair from the render, or say "selected
   points".
2. **The region field is filled for some curves of a source and not others** (1049/1050 against 1053/1054). This
   is the same defect round 2 found in Raleigh 1986. When a curve's text names its streams, the region comes from
   that text, for every curve.
3. **An observed span gets the label of the best class** (1046). `optimum` is for a span the source calls optimal
   or preferred, or the top of a class scheme. "Reported ... between X and Y, with a maximum of Z" is `range` +
   `dist`, as in 956.
4. **A review relabels a suitability span as optimal, or moves a number by one step** (954, 955, 961/963, 960).
   This is invisible from the review alone; the original's page is the only check, and the drafter's tracing caught
   all of them.
5. **A row number in a note or report drifts** ("DR 940" for 936). Resolve every data-row number against the file
   before citing it.
