# Audit of late rows, round 3 (#44): the round-2 fixes

Scope: the notes rewritten by round 2 (`dbaceb0`), data rows 943, 954, 955, 960, 962, 964 and 1053 of
`data/literature_evidence.csv` (data row N = file line N + 1). Every number, page reference, quoted phrase and
`data row N` pointer was checked against the rendered pages themselves:

- Raleigh et al. 1984 (`data/rag/pdf/flow/p16021coll3_240.pdf`, PDF page = printed + 9), printed pp. 6, 8, 9,
  28, 39, 41, 43, 44, 45 at 150 dpi.
- Hickman & Raleigh 1982 (archive.org copy, md5 870bd2b7...), printed pp. 5 and 6 (PDF 13-14). The first line of
  p. 6 was also cropped at 300 dpi.
- Ford et al. 1995 (Zotero T3KBBEF3; OCR text): pp. 49, 52, 53, 70 (Table 4), 78 and the reference list (Rose 1986).
  Page numbers were taken from the footer lines in the OCR.

All 23 `data row N` pointers in the seven notes point at the row they describe: 961, 963 (Ford's excellent class);
1037; 1039 to 1042; 1044 to 1052.

I looked for one thing in particular: a note that puts two nearly identical statements from different places into
one parenthesis.

## 943: holds

- Table 4 starts on p. 70; the "69" footer comes before it and "70" after it. The table is for westslope cutthroat
  and gives "Estimated optimal spawning velocity 30-60 cm/s".
- Hickman & Raleigh's sentence breaks across the page: p. 5 ends "... 11 to 92 cm/sec. We assume that" and p. 6
  opens "optimal velocities range from 30 to 60 cm/sec." So "pp. 5-6" is right.
- The p. 6 line is faint even at 300 dpi, but "30" and "60" can be read, and Ford agrees with them.
- Neither text file has the p. 6 words. A grep for "optimal velocities" finds nothing, and the OCR after line 535 is
  noise. So "the scan's OCR cannot be quoted for p. 6" is true.
- The only `hickman_raleigh1982` rows are the 11-92 cm/s range and the 15 cm depth. So "the original has no row of
  its own" is true.

## 954: error, inside round 2's fix

The note reads: "Its IFIM section says the spawning velocity curve assumes velocities below 1.0 or above 3.0 ft/s
(about 30 and 91 cm/s) are unsuitable, with most redds at 1.6-3.0 ft/s (p. 39; also p. 44)."

**Evidence:**

- **p. 39** (Spawning velocity) is where all of this comes from.
  - Hartman and Galbraith (1970), Lardeau River: "most redds were associated with velocities ranging 1.6 to 3.0 fps".
  - Smith (1973), Deschutes River: 95 % of redds in 1.6-3.0 fps.
  - Hooper (1973): 1.4-2.7 fps.
  - Orcutt et al. (1968): 2.3-2.5 fps.
  - Then: "The SI curve for spawning velocity (Fig. 2) assumes that velocities less than 1.0 or greater than 3.0 fps
    are unsuitable for rainbow trout spawning."
- **p. 44** is a different statement, in the Egg incubation velocity paragraph: "given suitable spawning velocities
  (Fig. 2), it may be assumed that egg incubation velocities above redds which range from 1.0 to 3.0 fps ... will
  yield suitable apparent velocities among embryos." It says nothing about which velocities are unsuitable, about
  the spawning curve, or about 1.6-3.0 / most redds.

**What is wrong:** this is the merge the brief asked me to look for. "(p. 39; also p. 44)" closes a sentence that
contains both the spawning curve's unsuitable edges and "most redds at 1.6-3.0". That credits p. 44 with both.
p. 44 actually has a separate, positive claim, the suitable egg-incubation velocity over redds. A smaller problem:
"most redds at 1.6-3.0" is given as the section's own finding, but it is two studies' result (Lardeau, Deschutes).
The other two studies reported different ranges.

The conversions are right: 1.0 ft/s = 30.5 cm/s and 3.0 ft/s = 91.4 cm/s. The p. 8 and p. 41 clauses also hold:

- p. 8: "between 30 and 70 cm/sec. Velocities less than 10 cm/sec or greater than 90 cm/sec are unsuitable".
- p. 41: Figure 2 coordinates 0.9/0.0, 1.6/1.0, 3.0/1.0, 3.1/0.0.

**Corrected note:**

> Ford et al. call 30-90 cm/s Raleigh et al.'s (1984) optimal spawning velocity. The original's optimum is 30-70 cm/s, with velocities below 10 or above 90 cm/s unsuitable (p. 8; data rows 1044, 1045). Its IFIM section reports most Lardeau River redds at 1.6-3.0 ft/s (Hartman and Galbraith 1970) and 95% of Deschutes River redds in that range (Smith 1973), and says the spawning velocity curve assumes velocities below 1.0 or above 3.0 ft/s (about 30 and 91 cm/s) are unsuitable (p. 39). Its egg incubation section separately takes 1.0-3.0 ft/s above redds as giving suitable velocities among embryos (p. 44). The plotted curve, Figure 2, has SI 0 at 0.9 and 3.1 ft/s and SI 1.0 from 1.6 to 3.0 ft/s (p. 41; data rows 1049, 1050). Ford's 30-90 matches p. 39's suitable span, not an optimum, and no value is drawn here.

## 955: holds

- **Ford p. 52:** "optimal water velocity range is 30 to 90 cm/s, in water depths between 0.15 and 2.5m. However,
  the main consideration with depth is that spawning areas have sufficient flow of water for incubation and for the
  fry upon emergence". This matches the note's first sentence.
- **Raleigh p. 43** (Spawning Depth): "depths less than 0.6 and greater than 8.2 feet are assumed to be unsuitable
  for spawning (although 8.2 feet may not be the upper limit; Fig. 2)". The quoted phrase is verbatim. The
  conversions are right: 0.6 ft = 0.18 m and 8.2 ft = 2.50 m.
- **Raleigh p. 41:** depth coordinates 0.6/0.0, 0.7/1.0, 8.2/1.0, 8.3/0.0. These are rows 1051 and 1052.
- **Raleigh p. 28:** "covered by flowing water ≥ 15 cm deep". This is row 1048.
- Neither Raleigh text file has a 0.15-2.5 m span (grep), which supports "print no such span".
- The note keeps the text edge (p. 43) and the plotted edge (p. 41) in separate sentences, each with its own page.

## 960: holds

- **Ford p. 49:** "Studies reported by Raleigh et al. (1984) and Rose (1986) indicate that larger juvenile fish, 5 to
  13 cm in length, are found in velocities between 10 and 12 cm/s with a maximum of 22 cm/s". This is in the rainbow
  trout chapter.
- **Raleigh p. 9** (Juvenile): "Griffith (1972) reported focal point velocities for juvenile cutthroat in Idaho of
  between 10 and 12 cm/sec, with a maximum velocity of 22 cm/sec". No length is given. These are rows 1046 and 1047.
- **Ford's reference list:** "Rose, G.A. 1986. Growth decline in subyearling brook trout (Salvelinus fontinalis)
  after emergence of rainbow trout (Salmo gairdneri)."

"Griffith's cutthroat values" rests on the exact numerical match. Rose (1986) itself was not read, and the note
does not claim it was.

## 962: holds

- **Ford p. 53:** "the base or lowest flow of late summer or winter months. A base flow of greater than 55% of the
  average annual daily flow is considered excellent, 25 to 50% is considered fair and less than 25% is considered
  poor for maintaining good trout habitat (Raleigh et al. 1984)".
  - The page footer reads "33" in the OCR, between the "52" and "54" footers. So "the OCR reads '33'" is right.
- **Raleigh p. 6** prints "A base flow ≥ 50% of the average annual daily flow is considered excellent", with 25 to
  50 % fair and < 25 % poor.
- Each pointer names the right side:
  - 1040 is Raleigh's rearing 25 % row.
  - 961 is Ford's rearing excellent row.
  - 1039 is Raleigh's rearing excellent row.

  So round 2's separation of the review's row from the original's row is correct.

## 964: holds

The same check as 962, for the overwintering rows. 1042 is Raleigh's overwintering 25 % row, 963 is Ford's
overwintering excellent row and 1041 is Raleigh's overwintering excellent row. The page and quotes are the same as
for 962.

## 1053: holds

- **Raleigh p. 44:** "Moyle et al. (1983) observed fry (≤ 2 inches in length) in Cherry and Eleanor Creeks (n=404),
  Putah Creek (n=134), and Deer Creek (n=81)". These add to 619. The paragraph goes on: "Weighted mean frequencies
  were calculated for each velocity and then normalized".
- **Raleigh p. 45**, Figure 3, mean water column velocity, n = 619: 0.00/1.00, 0.49/0.78, 0.98/0.19, 0.04 at 1.48,
  0.01 at 1.97 and 2.46, and 0.00 at 2.95. Every value in the note matches.
- The OCR text runs "1.97 0.01 / 2.95 0.00 6 l / 100.00 0.00" with no 2.46 line. So "the OCR drops the 2.46 line"
  is true.

checked 7 rows, 1 with errors, 1 inside round-2 fixes
