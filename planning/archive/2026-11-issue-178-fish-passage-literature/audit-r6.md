# Audit r6: round-5 changes to research/access_gradients.md and its research/README.md row

Scope: `git show 3ad2db67 -- research/` (round 5's fold). Line numbers are the file at HEAD 3ad2db67.

Read against: bcfishpass 254849fc README (2020-11-06), 8d9967c1 README (2020-11-16), 93e80f49 README (2021-05-20),
origin/main 620dbe43 `docs/02_model_access.md`, `docs/01_background.md`, `docs/06_credits_license.md`; link origin/main
`R/lnk_barrier_overrides.R`; Mount et al. 2011 pp. 9-10 (text layer); Cannings and Ptolemy 1998 (PWRE9XAM, the
"(up to 30%)" sentence); WDFW 2019 pp. 2-6, 2-7 (Table 2.1 rendered from PDF p. 25), 7-4, 10-6/10-7; Rebellato et
al. 2024 (WWN7VXP8, the PDF of Z8AUF79B) pp. 1, 4; data rows 6-8, 355-359, 1154-1158, 1160, 1163, 1167, 1168,
1170-1172, 1188, 1189.

8 findings: 0 errors, 3 imprecisions (F1, F2, F5), 5 ok-with-note. All 8 sit inside round-5 changes. Nothing outright
wrong found outside them. The loop does not end at this round.

## Inside round-5 changes

**F1. Lines 21-22 ("In short") and the research/README.md row: "crediting its gradient classes to "FPTWG" without
naming a document"; README row: "15 % for salmon and 20 % for steelhead and westslope cutthroat used by bcfishpass
since 2020, credited to "FPTWG" without naming a document".** imprecision. Inside round 5's fix for R1.
What bcfishpass credited to FPTWG was a data input, for six months:
- 254849fc README, under "## Requirements", beside Postgres, fwapg and bcfishobs: "gradient barriers at 15/20/30
  percent (from FPTWG)".
- Ten days later, 8d9967c1 (2020-11-16) rewords the same line: "gradient barrier points at 15/20/30 percent (data
  available from FPTWG on request)". So "from FPTWG" names where the barrier points (computed at those classes) came
  from.
- 93e80f49 (2021-05-20) removes the line; from then the README, and now `docs/02_model_access.md` line 4, credit
  FPTWG only for the approach: "`bcfishpass` is based on previous BC Fish Passage Technical Working Group (FPTWG) Fish
  Passage models - the basic logic for evaluating connectivity is much the same as in previous versions."

So the ongoing participle ("has used ... since 2020, crediting") carries a credit past May 2021, and "its gradient
classes" says the classes were credited where the README credits barrier data at those classes. The README row goes
further: its participle attaches the credit to the species values (15 % for salmon, 20 % for steelhead and westslope
cutthroat), and the README line names no species. Also, "FPTWG" is used in the file (lines 22, 36, 46) and the row
without ever being expanded; bcfishpass expands it (`docs/02_model_access.md` line 4).
Fix (lines 21-22): "bcfishpass has used 15 % for salmon and 20 % for steelhead and westslope cutthroat since 2020; its
first README took gradient barriers at 15, 20 and 30 % as data "from FPTWG", the province's Fish Passage Technical
Working Group, naming no document and no species;". README row: "...used by bcfishpass since 2020, whose first README
took barriers at 15, 20 and 30 % as data from the province's Fish Passage Technical Working Group, naming no document
or species,". Optionally at line 46, after "with no species": "(ten days later: "data available from FPTWG on
request")".

**F2. Lines 23-24: "15 % alone has evidence behind it, gathered later: Rebellato et al. 2024 ... found that 94 to 98 %
of BC records ...".** imprecision. Inside round 5's fix for R2.
The records were not gathered later. Rebellato et al. p. 4: "observations of these species (n=4,511 Chum Salmon and
n=3,695 Pink Salmon) from the Known Fish Observations layer in the BC Geographic Warehouse were linked to the FWA
Stream Network layer stream features by "bcfishobs"". Those are existing provincial records; what came after 2020 is
the analysis, published February 2024 (p. 1, "Published Date February 2024"). Round 4's wording ("though the evidence
came after") was looser but did not say the records were collected later; "gathered" does.
Note on "alone" (same sentence, round 5's word): the evidence covers four of the class's seven species. Row 356's note:
"the 15 % rule was set from BC observations of pink, chum, Chinook and coho"; sockeye was not analysed, and the next
sentence names grayling and kokanee but not sockeye. Not wrong for the class as a whole, given the next sentence and
the table's 16 % for sockeye.
Fix: "15 % alone has evidence behind it, though the analysis came later:" (or "published later").

**F3. Lines 20-21: "25 % comes from BC's first fish-passage model, resting on a personal communication about bull
trout."** ok-with-note. Inside round 5's change to the In short.
Mount et al. 2011 p. 10: "Considering these values, Stream Gradient Segments with slopes greater than 25% were
considered barriers", where "these values" (p. 9) are two: "grades exceeding 20% are considered a barrier for
anadramous species (B.C. Ministry of Forests 1998)" and "some species (e.g., Bull Trout and Dolly Varden/ Cutthroat)
can utilize reaches with a sustained slope of 25–30% (Cannings and Ptolemy 1998)". Cannings and Ptolemy's sentence
ends "(P. Bech, pers. comm.)". So the 25 % rests on both values, and only its step above the guidebook's 20 % rests on
the book's personal communication. The compression is defensible, since that is the only value above 20 % Mount
considered, and lines 32-35 give the whole chain.
Fix (optional): "25 % comes from BC's first fish-passage model, whose step above the guidebook's 20 % rests on a
personal communication about bull trout."

**F4. Line 23: "Washington's barrier manual adopts the same 20 % for steelhead for its own purposes, citing no
source."** ok-with-note. Inside round 5's fix for R2.
"for its own purposes" holds: p. 7-4, "for the purpose of this manual the 20% gradient threshold is used as the upper
limit for most adult salmonids"; p. 2-6, Table 2.1 is used "For the purposes of assigning potential species use at a
fish passage feature". "citing no source" holds for Table 2.1 (rows 1170-1172: "No source cited"; nothing beside it on
pp. 2-6, 2-7). But "adopts the same 20 %", right after bcfishpass's 20 %, can read as Washington taking bcfishpass's
number, while Washington's is older: the 2009 edition's Table 9.2 draws the same limits (row 1170's note), and Sheer
and Steel 2006 cite Washington's 2000 manual (line 40, row 63).
Fix (optional): "Washington's barrier manual, earlier, also gives steelhead 20 %, for the manual's own purposes and
citing no source."

**F5. Line 64, bull trout cell: "found to 30 % (Cannings and Ptolemy, pers. comm.; WDFW 2019's Chapter 7 cites them
as "often found above 30%", p. 7-4)".** imprecision. Inside round 5's fix for R5.
The fix rightly shows the two clauses share one ancestor, but dropped R5's "more than they say", so the cell now sets
"to 30 %" beside "above 30%" and leaves the reader to notice they differ. WDFW 2019 p. 7-4: "bull trout are often
found above 30% gradient (Cannings and Ptolemy 1998)"; Cannings and Ptolemy: "Bull trout can be found in high gradient
areas (up to 30%) ... (P. Bech, pers. comm.)". Row 1156's note: WDFW "cite it for 'often found above 30% gradient',
which it does not say"; row 1163: "'above 30%', resting on a source that says 'up to 30%'". Also, pre-existing in the
same cell: "Cannings and Ptolemy, pers. comm." reads as a communication from them; it is P. Bech's, reported in their
book.
Fix: "found to 30 % (Cannings and Ptolemy, after a personal communication; WDFW 2019's Chapter 7 cites them for
"often found above 30%", p. 7-4, which they do not say)".

**F6. Lines 76-77: "the order Washington's table gives (chum and pink lowest, steelhead highest) follows these speeds,
though the speeds do not separate chum from pink."** ok-with-note. Inside round 5's cut of R9's clause.
Rendered Table 2.1 (p. 2-7): steelhead and sea-run cutthroat share the top rank, both crossed 12-16 and 16-20 and blank
at 20+ (row 1189: "as steelhead"). No speed is given for sea-run cutthroat (Powers and Orsborn's Table 1 and Bjornn and
Reiser hold none), so "follows these speeds" holds only for the six species with speeds. The cut clause disclosed that;
with it gone, nothing does. "steelhead highest" is true but tied.
Fix (optional): "(chum and pink lowest, steelhead and sea-run cutthroat highest) follows these speeds where they are
given, though ...".

**F7. Lines 5-6, header: "audited for meaning in rounds until one found nothing inside an earlier round's fix
(`planning/archive/` for #178)".** ok-with-note. Inside round 5's fix for R4.
The stopping rule is now named correctly. But the sentence is past tense and not yet true: round 5 found 9 inside
round-4 fixes, and this round finds 8 inside round-5 changes. `planning/archive/` holds no #178 directory yet (the
audits are in `planning/active/audit-r1..r5.md`). Both become true only when the loop ends and the PWF is archived.
Fix: none now; confirm both at the last fold (optionally give the round count then).

**F8. Lines 15-16: "Its overrides lift some of these barriers where fish records or confirmed habitat sit above them,
by rules that differ by species."** ok-with-note. Inside round 5's fix for R6.
Content holds: `lnk_barrier_overrides()` "determine[s] which gradient/falls barriers should be skipped", on
observations upstream (per-species `observation_threshold`, `observation_date_min`, `observation_species`, control on
or off) and on "Any confirmed habitat (spawning or rearing flagged) upstream of a barrier"; "some" and "differ by
species" are true (CT and DV get none in `default`, per R5's check). The only note: "Its" follows a parenthesis ending
in a CSV path, so its antecedent (link) is two clauses back.
Fix (optional): "link's overrides lift ...".

## Outside round 5's changes

No outright error found.

## Checked and found right

- Lines 13-15: link's classes (15 % CH, CM, CO, PK, SK, GR, KO; 20 % ST, WCT; 25 % BT, RB, CT, DV), unchanged by the
  move of the overrides into their own sentence; the colon's list now attaches to the access gradient (R6 resolved).
- Lines 15-16: overrides cover gradient barriers (`lnk_barrier_overrides.R` header, "gradient/falls barriers"), on
  records and confirmed habitat upstream, with per-species rules.
- Line 17: "Those cuts" still reads as the barriers after the reordering.
- Lines 20-21: 25 % is Version 1's (Mount et al. 2011 p. 10; row 1157); the personal communication is about bull trout
  only (Cannings and Ptolemy, "Bull trout can be found ... (up to 30%) ... (P. Bech, pers. comm.)"; row 1156).
- Line 22: "without naming a document": no bcfishpass README revision or doc names a document for the classes; docs
  name the FPTWG as a group and link its web page (`docs/01_background.md` line 38, `docs/06_credits_license.md` line 7).
- Line 23: "citing no source" for Washington's steelhead 20 % (Table 2.1, pp. 2-6/2-7; rows 1170-1172); p. 10-6's
  steelhead sentence (row 1168) cites nothing either.
- Lines 24-25: Rebellato et al. 2024, "Technical Report / Canadian Wildlife Federation / February 2024" (p. 1); 96 %
  pink, 97 % chum, 98 % chinook, 94 % coho (p. 4; rows 7, 357, 358); content unchanged by the rewrap.
- Lines 46-47: "under 'Requirements'": 254849fc's heading is "## Requirements", and the gradient line sits in that list,
  verbatim "(from FPTWG)", with no species (R7 resolved).
- Line 64: "WDFW 2019's Chapter 7 cites them" is accurate as to the citation (p. 7-4, "(Cannings and Ptolemy 1998)");
  "20 % used and passing to 33 % recognised (WDFW 2019 p. 10-7)" against p. 2-7/10-7's resident-trout paragraph (row
  1163). The cell's data rows (1156, 1160, 1163) hold each claim.
- Lines 76-77: Table 2.1's order (chum 5, pink 12, chinook/coho/sockeye 16, steelhead 20), and one "Pink & Chum" speed
  row.
- README row: unchanged parts (25 % lineage, Washington's species limits, Rebellato's four species, no gradient limit
  for grayling, kokanee or westslope cutthroat) still match the file.

Every finding above sits inside a round-5 change: F1, F2, F4 and F5 inside round-5 fixes for R1, R2 and R5; F3 inside
round 5's rewrite of the In short; F6 inside its cut of R9's clause; F7 inside its fix for R4; F8 inside its fix for R6.
