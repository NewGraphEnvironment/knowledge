# Meaning audit, late sources, round 2 (#44): the 17 rows round 1 changed

Scope: data rows 936, 942, 943, 954, 955, 958, 959, 960, 961, 962, 963, 964, 1046, 1049, 1050, 1053, 1054 as
committed in f9895ec (data row N = file line N + 1). Each was read against the rendered source page, not round 1's
summary. Every "data row N" inside their notes was resolved against the file.

Pages rendered (scratchpad `r2/`):
- Raleigh et al. 1984 pp. 6, 8, 9, 28, 39, 41, 43, 44, 45, 47, 48, 49.
- Hickman & Raleigh 1982 pp. 5, 6 (PDF 13, 14; p. 6 top strip at 300 dpi).
- Ford et al. 1995 pp. 47, 49, 52, 53, 70, 72, 78 (PDF = printed + 24), and its reference list (OCR).

## The suspicion: row 954 against rows 1049/1050

Both numbers are on the source, in different places:
- **p. 39, text:** "The SI curve for spawning velocity (Fig. 2) assumes that velocities less than 1.0 or greater
  than 3.0 fps are unsuitable for rainbow trout spawning." Most redds were at 1.6-3.0 fps (Hartman and Galbraith).
  p. 44 repeats it: incubation velocities "which range from 1.0 to 3.0 fps ... will yield suitable apparent
  velocities".
- **p. 41, Figure 2 coordinates:** 0.0/0.0, 0.9/0.0, 1.6/1.0, 3.0/1.0, 3.1/0.0, 100.0/0.0. The plotted line leaves
  zero at 0.9 and returns to zero at 3.1.

So the text and the figure disagree by 0.1 ft/s at each end. At 1.0 ft/s the curve gives SI of about 0.14, not 0;
at 3.0 it gives 1.0, not 0.

- **Rows 1049 and 1050 are right.** They code the figure's coordinates (0.9-3.1 zero edges, 1.6-3.0 SI 1.0), and
  their notes already say the text (p. 39) puts the unsuitable edges at 1.0 and 3.0 ft/s.
- **Row 954 is wrong.** It says "Its spawning curve puts the unsuitable edges at 1.0 and 3.0 ft/s ... with SI 1.0
  from 1.6 to 3.0 ft/s (pp. 39, 41; data rows 1049, 1050)". The curve puts the zero edges at 0.9 and 3.1. 1.0 and
  3.0 are the text's edges. As written, 3.0 is both unsuitable and SI 1.0, and the note cites rows that say 0.9-3.1
  for 1.0-3.0. Fix below.

## Per row

### 936: holds
- Ford p. 72: "Griffith (1972) reported finding westslope cutthroat fry in velocities of 7 to 10 cm/s. Age 1+ and
  2+ fish were utilizing areas with average water velocities between 10 and 12.5 cm/s and a maximum of 22 cm/s."
  The sentence names no source of its own.
- Raleigh 1984 p. 9: juvenile cutthroat in Idaho, 10-12 and a maximum of 22 cm/sec (Griffith 1972).
- Hickman & Raleigh p. 5: "Focal point velocities for adult cutthroat trout on territorial stations in Idaho streams
  were primarily between 10 and 14 cm/sec, with a maximum of 22 cm/sec (Griffith 1972)".
- Raleigh's reference list: Griffith 1972 is brook and cutthroat trout in small streams in northern Idaho.
- Data rows 1046 and 1047 are the 10-12 and 22 cm/s rows.

### 942: holds
- Hickman & Raleigh p. 5: Hooper (1973) and Thompson (1972) 31-92 cm/sec, Hunter (1973) 11-40 cm/sec; "Average
  water column velocities for embryo development apparently range from 11 to 92 cm/sec."
- Ford p. 78 prints 11 and 90. Data row 1037 is the 11-92 row.

### 943: error (minor, page)
- The quoted sentence starts on p. 5: the last line of p. 5 ends "We assume that". It continues at the top of p. 6:
  "optimal velocities range from 30 to 60 cm/sec" (faint on the 300 dpi render, but legible).
- Data row 1037's note says the same thing: the sentence "runs onto p. 6".
- Everything else holds:
  - Ford p. 70, Table 4 (westslope cutthroat, adults): "Estimated optimal spawning velocity 30-60 cm/s".
  - The 30-60 value matches the original.
- **Fix, `note`:** "Estimated optimal spawning velocity range. Table 4 (p. 70) lists 30-60 cm/s as estimated optimal
  spawning velocity for westslope cutthroat. Matches the original, Hickman and Raleigh (1982) pp. 5-6, 'We assume
  that optimal velocities range from 30 to 60 cm/sec' (read on the rendered pages; the scan's OCR cannot be quoted
  for p. 6, so the original has no row of its own)."

### 954: error (inside round 1's fix)
- **What is wrong:** as above. The note attributes the text's 1.0/3.0 edges to the curve and cites rows 1049/1050,
  which hold 0.9/3.1. Its conclusion, "So Ford's 30-90 is a suitable span", is true of the p. 39/44 span but not of
  p. 8's suitable span (10-90). It should say which page.
- The `qual` conversion stands. Ford p. 52 reads as quoted, and nothing in Raleigh calls 30-90 optimal.
- **Fix, `note`:** "Ford et al. call 30-90 cm/s Raleigh et al.'s (1984) optimal spawning velocity. The original's
  optimum is 30-70 cm/s, with velocities below 10 or above 90 cm/s unsuitable (p. 8; data rows 1044, 1045). Its IFIM
  section says the spawning velocity curve assumes velocities below 1.0 or above 3.0 ft/s (about 30 and 91 cm/s) are
  unsuitable, with most redds at 1.6-3.0 ft/s (p. 39; also p. 44). The plotted curve, Figure 2, has SI 0 at 0.9 and
  3.1 ft/s and SI 1.0 from 1.6 to 3.0 ft/s (p. 41; data rows 1049, 1050). Ford's 30-90 matches p. 39's suitable
  span, not an optimum, and no value is drawn here."

### 955: error (inside round 1's fix; same mechanism as 954)
- **What is wrong:** "2.5 m is the 8.2 ft upper edge of the spawning depth curve, whose lower edge is 0.6 ft" mixes
  edge types.
  - On the curve (p. 41) 0.6 ft is the SI-0 edge, but 8.2 ft is the last SI-1.0 point; the SI-0 edge is 8.3 ft.
  - The 0.6/8.2 pair is the text's (p. 43): "depths less than 0.6 and greater than 8.2 feet are assumed to be
    unsuitable for spawning (although 8.2 feet may not be the upper limit; Fig. 2)".
- The rest holds:
  - Ford p. 52 adds "the main consideration with depth is that spawning areas have sufficient flow of water for
    incubation and for the fry upon emergence".
  - p. 28 renders "covered by flowing water ≥ 15 cm deep".
- **Fix, `note`:** "Ford et al. give 0.15-2.5 m as the depths Raleigh et al. (1984) paired with the optimal spawning
  velocity, and add that the main consideration with depth is enough flow for incubation and emerging fry. Raleigh
  et al. print no such span. The text treats depths below 0.6 ft or above 8.2 ft (about 0.18 and 2.5 m) as
  unsuitable, 'although 8.2 feet may not be the upper limit' (p. 43). Figure 2 has SI 0 at 0.6 and 8.3 ft and SI 1.0
  from 0.7 to 8.2 ft (p. 41; data rows 1051, 1052). So Ford's 2.5 m is the text's 8.2 ft edge, and 0.15 m is not the
  0.6 ft lower edge. 15 cm is the minimum depth in the model's spawning-site definition (p. 28; data row 1048). No
  value is drawn here."

### 958: holds
- Ford p. 47: "Recently emerged fry ... less than 30 cm/s and prefer velocities less than 8 cm/s. Fry will move to
  deeper, faster water as they grow, using interstices between rocks, debris piles, and aquatic vegetation for
  cover." No source is named.
- Raleigh p. 8 reads exactly as quoted.
- Raleigh's reference list: Griffith 1972 is brook and cutthroat trout in northern Idaho; Horner & Bjornn 1976 is
  "Survival, behavior, and density of trout and salmon fry in streams".
- Advisory: Hickman & Raleigh p. 6 has the same sentence for cutthroat ("Fry utilize velocities of less than 30
  cm/sec, but less than 8.0 cm/sec are preferred (Griffith 1972; Horner and Bjornn 1976)"). That strengthens the
  note's conclusion that the species measured is uncertain. Optionally append: "Hickman and Raleigh (1982) p. 6 give
  the same sentence for cutthroat."

### 959: holds
Same evidence as 958. `optimum`/`pref` follows Ford's "prefer".

### 960: holds
- Ford p. 49: "Studies reported by Raleigh et al. (1984) and Rose (1986) indicate that larger juvenile fish, 5 to 13
  cm in length, are found in velocities between 10 and 12 cm/s with a maximum of 22 cm/s."
- Ford's reference list: "Rose, G.A. 1986. Growth decline in subyearling brook trout ... after emergence of rainbow
  trout".
- Advisory: Ford p. 47 also cites Rose (1986) for the diet of introduced rainbow trout fry in southeastern Ontario,
  so Rose did observe rainbow trout. The note's "the velocities are not a rainbow trout measurement" rests on the
  exact match with Griffith's cutthroat numbers, which is strong but inferential. A softer wording: "So the
  velocities are Griffith's cutthroat values, not a rainbow trout measurement".

### 961: holds
- Ford p. 53 render: "A base flow of greater than 55% ... excellent, 25 to 50% ... fair and less than 25% ... poor
  ... (Raleigh et al. 1984)". The OCR's page footer reads "33".
- Raleigh p. 6 render: "A base flow ≥ 50% of the average annual daily flow is considered excellent". Data row 1039
  is that row.
- The `qual` row has blank bound, value, unit and metric.

### 962: error (inside round 1's fix)
- **What is wrong:**
  - "Ford's '>55 %' excellent class does not (the original prints '≥ 50%'; data row 961)". The parenthesis makes
    data row 961 the original's ≥ 50 % row. Row 961 is Ford's own excellent row (now `qual`); the original's is
    data row 1039.
  - '>55 %' is in quote marks, but Ford prints "greater than 55%".
- **Fix, `note`:** "Lower edge of the fair class, late summer base flow: below 25 % is poor. The base or lowest flow
  of late summer or winter months, as a percent of average annual daily flow (mean annual discharge), rated for trout
  habitat, citing Raleigh et al. (1984). The 25 % edge matches the original (p. 6; data row 1040). Ford's excellent
  class, 'greater than 55%' (data row 961), does not: the original prints '≥ 50%' (data row 1039). In the rainbow
  trout chapter; the sentence itself says 'trout'. Printed page 53 (the OCR reads '33')."

### 963: holds
As 961. Data row 1041 is the original's winter ≥ 50 % row.

### 964: error (inside round 1's fix; same as 962)
- **Fix, `note`:** "Lower edge of the fair class, winter base flow: below 25 % is poor. The base or lowest flow of
  late summer or winter months, as a percent of average annual daily flow (mean annual discharge), rated for trout
  habitat, citing Raleigh et al. (1984). The 25 % edge matches the original (p. 6; data row 1042). Ford's excellent
  class, 'greater than 55%' (data row 963), does not: the original prints '≥ 50%' (data row 1041). In the rainbow
  trout chapter; the sentence itself says 'trout'. Printed page 53 (the OCR reads '33')."

### 1046: holds
- p. 9, "Juvenile." paragraph of the rainbow trout model: "reported focal point velocities ... of between 10 and 12
  cm/sec, with a maximum velocity of 22 cm/sec". `range` + `dist` is right.
- "next row" resolves to data row 1047 (max 22). Region Idaho.

### 1049: holds
- Figure 2 coordinates (0.9/0.0, 1.6/1.0, 3.0/1.0, 3.1/0.0) match.
- The note's "The text (p. 39) puts the unsuitable edges at 1.0 and 3.0 ft/s" is exact.
- The p. 39 streams in `region` match: Lardeau River BC, Deschutes River OR, South Fork Feather River CA, Idaho
  streams.
- Advisory: no other row's `region` carries a page pointer. The sibling curve rows cite studies, e.g. 1053 "(Moyle
  et al. 1983)". A form consistent with them: "Lardeau River, British Columbia (Hartman and Galbraith 1970);
  Deschutes River, Oregon (Smith 1973); South Fork Feather River, California (Hooper 1973); Idaho streams (Orcutt et
  al. 1968)". Format, not meaning.

### 1050: holds
As 1049. SI 1.0 is 1.6-3.0 ft/s. Same region advisory.

### 1053: error (minor; wording carried through round 1's rewrite)
- Every coordinate now matches the render, including 1.48/0.04. The OCR does drop the 2.46 line (`1.97 0.01` is
  followed by `2.95 0.00`).
- **What is wrong:** "fry (<2 inches)". p. 44 prints "Moyle et al. (1983) observed fry (≤ 2 inches in length)". The
  drafter's text had it; round 1's rewrite repeated it.
- **Fix, `note`:** replace "fry (<2 inches)" with "fry (≤ 2 inches)". The rest is unchanged.

### 1054: holds
- Coordinates match the render (0.00/1.00, 0.49/0.99, 0.98/0.59, 1.48/0.24, 1.97/0.08, 2.46/0.02, 3.44/0.02,
  3.50/0.00).
- 2.0-4.7 inches is on p. 47.
- The Figure 4 data description continues on p. 48 ("Data from all streams were used to generate the velocity
  curve (Fig. 4)").
- The region matches the p. 47 stream list.

## Data-row references
Every number in the 17 notes resolves to an existing row on the right fact, with two exceptions:
- 954 cites 1049/1050 for 1.0/3.0 edges they do not hold.
- 962/964 label 961/963 as the original.

Resolved: 936→1046, 1047; 942→1037; 943 (none); 954→1044, 1045, 1049, 1050; 955→1051, 1052, 1048;
960→1046, 1047; 961→1039; 963→1041; 962→1040, 961; 964→1042, 963; 1046→1047 (next row).

Back-pointers (1037, 1039-1042, 1044, 1047) also resolve.

## Mechanism
Three of the six errors (954, 955, 962/964 counted as one shape) come from one move: a fix restates a figure in
words and merges two sources that say almost the same thing.
- Text edge vs plotted edge (954, 955).
- Ford's row vs the original's row (962, 964).

Name the page and the row for each number separately; never give one parenthesis to two sources.

checked 17 rows, 6 with errors (943, 954, 955, 962, 964, 1053), 6 inside round-1 fixes (five introduced by round 1's
text; 1053's "<2 inches" inherited from the drafter and repeated by round 1's rewrite)
