# Audit r2: meaning of literature_evidence.csv data rows 1154-1189 and research/access_gradients.md

Read against (text via `pdftotext -layout`, drawn tables rendered): WDFW 2009 pp. 6-1, 6-2, 9-6, 9-7 (Table 9.2
rendered, PDF p. 103); WDFW 2019 pp. 2-6, 2-7 (Table 2.1 rendered, PDF p. 25), 2-10, 7-2, 7-4, 10-2, 10-6, 10-7
(Table 10.1 rendered, PDF p. 153), 10-26, 11-3, 11-4 (Table 11.1 rendered, PDF p. 182), 11-9, 12-2, glossary; Mount
et al. 2011 pp. 9-10 and references; Norris & Mount 2016 (revision history, pp. 1, 6); FSIG 1998 pp. 16, 23, 24;
Cannings & Ptolemy 1998 OCR (PDF p. 37 = printed p. 22); Powers & Orsborn 1985 pp. 10, 11, 17, 18; Bjornn & Reiser
1991 PDF pp. 3-4 rendered (printed pp. 86-88); Blank et al. 2020 pp. 217-222 (PDF pp. 1-6); MacPhee & Watts 1976 p. 24;
Rebellato et al. 2024 pp. 4-5 (Zotero WWN7VXP8); Sheer & Steel 2006 pp. 1657-1658 (Zotero 3NM3VKQA, to follow data
row 359's citation); bcfishpass 620dbe43 docs/01, 02, 03 and model/01_access/sql/model_access_*.sql; fresh aac96efe;
link 323207783 and origin/main `inst/extdata/configs/default/parameters_fresh.csv`; R/literature.R vocabulary;
scripts/0280 access grid. Round-1 fixes read from `git show 12c3e149` (old vs new field by field).

21 findings: 3 errors, 13 imprecisions, 5 ok-with-note. 6 sit inside round-1 fixes (R1, R2, R3, R4, R5, R7).

## Data rows

**R1. Rows 1163-1166, note (inside round-1 fix F1).** imprecision.
Says: "...'above 30%' to bull trout (Cannings and Ptolemy 1998, data row 1156)"; and in 1163-1164 "So for bull trout and
Dolly Varden the source it points to gives above 30 %, not 33 %."
Source: WDFW 2019 p. 7-4: "e.g., bull trout are often found above 30% gradient (Cannings and Ptolemy 1998)". Cannings
& Ptolemy p. 22 (data row 1156): "Bull trout can be found in high gradient areas (up to 30%)". So "above 30%" is WDFW's
restatement, not what Cannings and Ptolemy (or row 1156) say; and p. 7-4 names bull trout only, never Dolly Varden.
The parenthesis reads as if row 1156 states "above 30%".
Fix (1163-1166): "...and 'often found above 30%' to bull trout, citing Cannings and Ptolemy 1998, who write 'up to 30%'
(data row 1156)." In 1163-1164: "So for bull trout the source it points to gives about 30 %, not 33 %; it does not name
Dolly Varden."

**R2. Row 1154, note (inside round-1 fix F5).** imprecision.
Says: "The 2019 edition ... drops the narrow-channel clause (p. 7-2)."
Source: true of p. 7-2's natural-barrier list (Gradient and Waterfall only), but the 2019 edition keeps a narrow channel,
with no gradient, as an end of fish habitat: p. 10-2 "The scour width is < 0.61 meters for a distance of ≥ 160 meters in
Western Washington or < 0.91 meters for a distance of ≥ 160 meters in Eastern Washington" (a TD terminates); p. 10-26
"The following physical criteria indicate that a channel has become non fish-bearing: A scour width < 0.61 meters for a
distance greater than 160 meters in Western Washington...".
Fix: "...and drops the > 16 % narrow-channel barrier (p. 7-2); a scour width < 0.61 m (Western) or < 0.91 m (Eastern)
over 160 m remains, with no gradient, as the end of fish-bearing channel (pp. 10-2, 10-26)."

**R3. Rows 1170-1172, note (partly inside round-1 fix F10).** imprecision.
Says: "repeated as Table 10.1 on p. 10-7, whose header reads '5-7m' in the text layer, and as Table 11.1 on p. 11-4".
Source: the rendered pages print "5-7m" in the header of Table 10.1 (p. 10-7) and of Table 11.1 (p. 11-4); only Table 2.1
(p. 2-7) prints "5-7". It is the manual's typo, not a text-layer artefact, and the fix's placement of Table 11.1 after the
clause makes the clause read as 10.1's alone.
Fix: "(p. 2-7, repeated as Table 10.1, p. 10-7, and Table 11.1, p. 11-4, both of which print the header '5-7m')".

**R4. Rows 1173-1178, note (inside round-1 fix F17).** imprecision.
Says: "burst is 'activities which cause fatigue in 15 seconds or less' (p. 10), Hoar and Randall (1978)'s class, which
the report adopts, held for 5 to 10 s (p. 18)."
Source: the 5-10 s is Bell's, not part of Hoar and Randall's class: p. 17-18 "Bell (1973) suggests that burst speed can be
maintained for an estimated 5 to 10 seconds." The merged sentence attributes it to the class the report adopts.
Fix: "...(p. 10), Hoar and Randall (1978)'s class, which the report adopts; Bell (1973) estimates burst speed is held for
5 to 10 s (p. 18)."

**R5. Rows 1183-1184, note (inside round-1 fix F11).** imprecision.
Says: "...which the authors call short-duration and set beside Bell's burst range without naming its class (p. 222)".
Source: "short-duration" is on p. 217 (abstract: "We also observed the maximum short-duration swim speed of the fish") and
p. 219 ("observe the maximum short-duration swim speed"), not p. 222. And the Bell comparison is cutthroat's only (p. 222:
"The maximum swim speed observed in this study for Westslope Cutthroat Trout (3.55 m/s) ... is less than the upper limit
of the burst swim range (~4.12 m/s) for Cutthroat Trout reported by Bell (1991)"); for rainbow they write "(2.73 m/s) is
toward the upper end of values reported in other studies" (p. 222). Row 1183 (RB) therefore says something of the
rainbow value the source says only of the cutthroat one.
Fix (both rows): "The maximum speed over a 0.6 m flume segment (p. 222) of wild fish (15-30 cm FL) swimming volitionally,
which the authors call short-duration (pp. 217, 219) without naming its class;" then in 1184 "set beside Bell's burst range
for cutthroat (~4.12 m/s, p. 222)"; in 1183 "set beside other studies' rainbow values (p. 222)".

**R6. Row 1189 (new), life_history_form = migratory.** imprecision.
`knw_literature_vocab()`'s roxygen defines `migratory` as "for a source that says 'migratory' without separating fluvial
from adfluvial" (bull trout). WDFW writes "Sea Run Cutthroat" (anadromous); it never says "migratory". The vocabulary has
no anadromous form, and 1189 is the only `CT migratory` row.
Fix: leave life_history_form blank and keep "Sea-run" in the note, or extend the vocabulary (an `anadromous` value, or
widen `migratory`'s definition in the roxygen) as a change to the contract, and say so. Every other field of 1189 is right
(below).

**R7. Row 1188, note (inside round-1 fix F14).** imprecision.
Says: "Cutthroat statements that do not name the subspecies: data rows 1155, 1157, 1159, 1166."
The same commit added row 1189 (WDFW 2019's sea-run cutthroat, 20 %), which names no subspecies and is missing from the
list. (Also: row 1155's statement names none, but its cited source is a coastal cutthroat thesis, as 1155's note says.)
Fix: "data rows 1155 (whose cited thesis is on coastal cutthroat), 1157, 1159, 1166, 1189."

**R8. Row 1157, note.** ok-with-note (not a round-1 fix; text unchanged).
Says: "20 % for anadromous species after the 1998 Fish-stream Identification Guidebook (data row 1158)".
That is Mount et al.'s reading (p. 9: "Typically, grades exceeding 20% are considered a barrier for anadramous species
(B.C. Ministry of Forests 1998)"); the guidebook's 20 % is for all fish (p. 23: "Gradient is generally useful to identify
areas too steep for fish use: these usually are areas of ≥ 20% grade"), and row 1158 is coded FISH.
Fix: "...after the 1998 Fish-stream Identification Guidebook, whose 20 % is for all fish (data row 1158)".

## research/access_gradients.md

**S1. Lines 21 and 37-39: how Rebellato et al. set 15 %.** error.
Says (21): "15 % is the one set on evidence, from where chinook and coho records sit, beside Washington's 16 %." (37-39):
"cites Washington's 16 % for chinook, coho and sockeye, finds 98 % of chinook and 94 % of coho records in BC below a
maximum downstream gradient of 15 %, and on those results sets 15 % for all five salmon (Rebellato et al. 2024's rows)."
Source, p. 4: "No evidence of passable gradients for Chum or Pink salmon was available in the scientific literature.
Instead, observations of these species (n=4,511 Chum Salmon and n=3,695 Pink Salmon) ... For Pink Salmon, 96% of
observations had downstream locations with maximum gradients of 15% or less, and results for Chum Salmon were similar
(97%). To confirm whether literature-derived gradient thresholds for Chinook and Coho salmon reflected observed thresholds
in B.C., the same analysis was undertaken for these species. Results were similar in that 98% of Chinook ... and 94% of
Coho ... had a maximum downstream gradient of 15%. Based on these results, gradients ≥15% were considered barriers for all
Pacific salmon". The 15 % rests first on pink and chum records; chinook and coho were the check. "Below" should be "at
or below" ("15% or less"). Data rows 356-358 already say so ("set from BC observations of pink, chum, Chinook and coho").
"Rebellato et al. 2024's rows" names no row (round 1's F9 fixed the same phrase in row 1169 only).
Fix (21): "15 % is the one set on evidence: where BC records of pink and chum, then chinook and coho, sit (96-98 % at or
below 15 %), beside Washington's 16 %." (37-39): "...finds 96 % of pink and 97 % of chum records in BC at or below a
maximum downstream gradient of 15 %, confirms it with chinook (98 %) and coho (94 %), and on those results sets 15 % for
all five salmon (data rows 6-8, 355-358)."

**S2. Lines 70-71: chum and pink left open.** error.
Says: "Fish records above 5 % for chum and 12 % for pink are what would say which is right; that is the track's next
piece". The file never says that the 15 % it questions was itself set from those species' records (97 % of chum and 96 %
of pink observations at or below 15 %, Rebellato p. 4, data rows 357-358), which is the existing records evidence for
the higher number. A reader takes the records question as untested.
Fix: add "Rebellato et al. set 15 % from such records (97 % of chum and 96 % of pink at or below 15 %; data rows 357,
358), which do not say how many sit above 5 % or 12 %; that is the track's next piece."

**S3. Lines 19-20 and 33-36: where 20 % comes from.** imprecision.
Says: "20 % from BC's 1998 fish-stream rule and Washington's barrier manual, each a convention handed down without its
basis", and the 20 % bullet gives the 1998 guidebook and WDFW 2009/2019 only.
Source: the documented chain for bcfishpass's steelhead 20 % is the same CWF report as its 15 %: Rebellato p. 4, "steelhead
pass gradients up to 20% (Sheer and Steel 2006, WDFW 2009) ... gradients ≥20% were considered barriers for steelhead"
(data row 359); Sheer and Steel 2006 in turn cite WDFW 2000 (pp. 1657-1658: "Gradients greater than 20% (adult steelhead)
and 16% (adult Chinook salmon) function as natural physical limits ... (WDFW 2000)"; data row 63). No document read ties
bcfishpass's 20 % to the 1998 guidebook: bcfishpass cites it only for the 100 m interval (docs/02_model_access.md); the
guidebook's 20 % enters BC's lineage only through Mount et al., who did not adopt it. WCT's 20 % is uncited (row 1188).
Fix: "20 %, for steelhead, from Washington's barrier manual, through the CWF report (after Sheer and Steel 2006 and WDFW
2009; data rows 359, 63); BC's 1998 fish-stream rule uses the same 20 % for all fish (data row 1158). Westslope
cutthroat's 20 % is uncited."

**S4. Lines 23-24 and 72-73: trout and char "above their class".** error.
Says (23-24): "bull trout, Dolly Varden and resident trout are seen above their class" (25 %); (72-73): "Every source that
looks says bull trout, Dolly Varden and resident trout use reaches above their class."
Source: bull trout yes (Cannings & Ptolemy "up to 30%", p. 22; WDFW 2019 p. 7-4 "often found above 30%"). But WDFW 2019
says these fish "are expected to utilize habitat up 20%" and only "may pass through gradients as high as 33%" (p. 10-7),
and the 33 % its Chapter 7 sources is cutthroat's (Jauquet 2002), so WDFW, a source that looks, says they use reaches
below 25 %. No source places Dolly Varden above 25 %: FSIG says "well in excess of 20%" (p. 24), and p. 7-4 names bull
trout only. Rainbow is "sometimes ... well in excess of 20%" (FSIG). The table also holds Trotter 2000 (data row 116):
resident bull trout last-fish reaches at 7.5-22.5 %, below 25 %.
Fix (23-24): "bull trout and cutthroat are recorded above their 25 % class (30 %, 33 %), and every trout and char is
recorded above 20 %." (72-73): "Bull trout and cutthroat are recorded above 25 %, and every trout and char above 20 %;
WDFW still sets their use at 20 %. Whether link's 25 % blocks..."

**S5. Line 23: "chum (5 %) and pink (12 %) sit well below the 15 %".** imprecision.
Pink is 3 points below; only chum is well below.
Fix: "chum (5 %) sits well below, and pink (12 %) below, the 15 % BC applies to them".

**S6. Lines 52-53, table: bull trout and Dolly Varden cells.** imprecision.
Line 52 gives WDFW 2019 as recognising "often found above 30%" and cites row 1163, whose quote says "may pass through
gradients as high as 33%"; "often found above 30%" is p. 7-4, which no row codes. Line 53, "Dolly Varden ... as bull trout
in WDFW 2019", carries that bull-trout-only clause over to Dolly Varden.
Fix (52): "20 % used, passing to 33 % recognised, which its Chapter 7 gives bull trout as 'often found above 30%' (WDFW
2019 pp. 10-7, 7-4)". (53): "20 % used, passing to 33 % recognised (WDFW 2019; Chapter 7 does not name Dolly Varden);
well above 20 % (BC 1998)".

**S7. Lines 61-62: "Steelhead leap to 3.4 m and coho to 2.2 m".** imprecision.
Source: Bjornn & Reiser p. 86: "Reiser and Peacock (1985) computed maximum jumping heights of salmonids on the basis of
darting speeds"; Table 4.2 (p. 88) "Maximum jumping height". Computed maxima, not observed leaps, under a heading "What fish
are measured to pass".
Fix: "Reiser and Peacock (1985) computed from darting speeds that steelhead can leap 3.4 m and coho 2.2 m (through Bjornn
and Reiser 1991, p. 86; data rows 1181, 1182)."

**S8. Lines 63-64: "the order they give (chum lowest, steelhead highest) is the order of these speeds".** imprecision.
Powers & Orsborn's Table 1 (p. 11) gives pink and chum one row ("Pink & Chum", 7.7-15.0 ft/s, themselves estimated from
leaps, footnote a), so the speeds do not separate chum (5 %) from pink (12 %), the widest gap in WDFW's order; and the
speeds rank sockeye < coho < chinook (20.6, 21.5, 22.4 ft/s) where WDFW gives all three 16 %.
Fix: "the order they give (chum and pink lowest, steelhead highest) follows these speeds, though the speeds do not
separate chum from pink."

**S9. Line 63: "none of the sources makes that inference explicitly".** ok-with-note.
True of the sources of rows 1154-1189 for a reach-gradient limit from swimming speed, but the same table holds gradient-
over-length limits stated as findings: Cooney & Holzer 2006 "a 200-meter reach with a 20% gradient has been found to be
impassable for upstream migrants" (data rows 19, 409), and Sheer & Steel 2006 (row 63). Powers & Orsborn analyse chutes by
slope length and velocity (pp. 6, 30, 56) at site scale. Fix: scope it, "none of these sources derives a reach gradient
from such numbers".

**S10. Lines 83-84, Specification: Washington's drawn tables.** imprecision.
Says: "WDFW 2019's Table 2.1 (p. 2-7, repeated as Table 10.1, p. 10-7) and WDFW 2009's Table 9.2 (p. 9-7), which agree."
Round 1's fix to rows 1170-1172 was not carried here: Table 11.1 (p. 11-4) is a third copy; 2009's Table 9.2 marks
passability with horizontal lines (not crosses), has strata only to 16-20 % (no 20+), and adds bull trout and trout used to
20 %.
Fix: "...Table 2.1 (p. 2-7, repeated as Table 10.1, p. 10-7, and Table 11.1, p. 11-4) and WDFW 2009's Table 9.2 (p. 9-7,
hatched for passing, strata to 16-20 %), which agree for the seven anadromous species."

**S11. Line 37: "The CWF report behind bcfishpass's salmon thresholds".** ok-with-note.
bcfishpass names Rebellato et al. 2024 for its habitat-model thresholds ("Sources for these values for Pacific salmon and
steelhead are documented in Table 1 of [Rebelatto et al (2024)]", docs/03_model_habitat_linear.md) and lists it in
docs/01_background.md; its access table (docs/02_model_access.md) cites nothing. The 15 %/20 % link is by matching value
(and shared authors), not a citation. Fix: "The CWF report bcfishpass cites for its salmon habitat thresholds, whose access
values its access table matches, ...".

**S12. Line 56, grayling cell.** ok-with-note.
"1.5 m/s in a 30 m culvert stopped every fish under 300 mm" omits what row 1185 now says: of 301-340 mm fish only 3 of 40
and 2 of 21 passed (p. 24), and the culvert is 30.5 m. Fix: "...stopped every fish under 300 mm and all but 5 of 61
longer ones".

**S13. Line 15: path.** ok-with-note.
"link's `configs/default/parameters_fresh.csv`" is `inst/extdata/configs/default/parameters_fresh.csv`. Values match
origin/main exactly (BT, CT, DV, RB 0.25; ST, WCT 0.20; CH, CM, CO, PK, SK, GR, KO 0.15).

## Checked and found right

Data rows, every field (bar the findings above):
- 1154: WDFW 2009 p. 6-1 list (3.7 m fall; > 20 % for 160 m; > 16 % for 160 m with SLW < 0.6 m W / < 0.9 m E); 2019 p. 7-2
  "≥ 20% for ≥ 160 meters without resting areas" and "> 3.7 meters"; bcfishpass 100 m (docs/02).
- 1155: p. 6-1, max_obs, Jauquet 2002 (p. 6-2 reference: coastal cutthroat, South Puget Sound, M.Sc. thesis).
- 1156: p. 22 (PDF p. 37 footer "22"), pers. comm. P. Bech; the WDFW restatement remark.
- 1157: kind param (consistent with row 114); page 10 ("and Ptolemy 1998). Considering these values" opens p. 10); p. 9
  context; Mount's "B.C. Ministry of Forests. 1998" is the Fish-stream Identification Guidebook (reference list); Norris &
  Mount 2016 p. 6 "25% was used as the maximum gradient for fish passage in Version 1"; they cite Mount's article title as
  Version 1's description.
- 1158: p. 23 quote; 100 m representative length p. 16; p. 24 statement.
- 1159-1162: qual, no value, unit now blank; p. 24; note and "sometimes" for rainbow.
- 1163-1166: values, p. 10-7, "Also on p. 2-7" (paragraph under Table 2.1), "(See Chapter 7)" ending the sentence on both
  pages, Chapter 7.2 on p. 7-4 (text after the 7-3 footer), Jauquet for 33 %; 1165-1166 life_history_form resident; p. 2-10
  species field "Resident Cutthroat/Rainbow Trout, Sea run Cutthroat"; p. 12-2 "resident cutthroat/rainbow trout = 0.04";
  2009 Table 9.2 footnote 2 "Includes resident rainbow and cutthroat trout" (p. 9-7).
- 1167: p. 10-6 quote and 160 m sentence; Table 10.1 sockeye crossed 7-16 % (rendered).
- 1168: p. 10-6; the plain text layer reads "1220%" (confirmed with `pdftotext` without -layout).
- 1169: p. 11-3 quote and "(see Table 11.1)"; Table 11.1 chum green 0-3, crossed 3-5 (rendered); row 357 is CM 15 %.
- 1170-1172: CH 16, CO 16, PK 12 from rendered Table 2.1; Tables 10.1 and 11.1 identical cells (rendered); 2009 Table 9.2
  (rendered): chum to 5, pink to 12, coho/sockeye/chinook to 16, steelhead/searun to 20, Bull Trout and Trout shaded in
  every stratum to 16-20.
- 1173-1178: Table 1 burst values, p. 11, ft/s, burst, Bell (1973); Hoar and Randall adoption (p. 10); footnote a; "One
  row, two species".
- 1179-1180: 3-4 ft, p. 11, footnote attribution remark.
- 1181-1182: 2.2 m and 3.4 m, p. 88 (rendered), "computed ... on the basis of darting speeds" on p. 86 (rendered), elided
  cell = sustained 1.04-3.23, steelhead darting 4.18-8.08 OCR'd "4,188.08", chinook 2.4 / sockeye 2.1 OCR'd "24".
- 1183-1184: values 2.72 and 3.55 (p. 217 abstract), 2.73 in Results and Discussion (p. 222), 0.84 m/s both species,
  15-30 cm FL (nominal; 15.0-30.5 RB, 15.0-29.0 WCT), lab, Montana, metric unstated.
- 1185: p. 24 quote, 3 of 40 (4-7 C) and 2 of 21 (9-10 C), Table 10 is 1-day tests of 1974 migrants.
- 1186: GR added at 0.15 by link 323207783 (2026-05-02, #107) with the salmon class; row 1185 cross-reference.
- 1187: new sentence: p. 2-10 lumps "Sockeye/Kokanee"; Tables 2.1/10.1/11.1 are titled anadromous; no kokanee gradient
  statement in WDFW 2019 (grep of every "kokanee").
- 1188: bcfishpass WCT 20 % uncited (docs/02 table); rows 1166, 1184 cross-references.
- 1189: species CT, life_stage access, gradient, access_gradient_max, max 20, percent, expert, Washington, p. 2-7, quote
  in the text layer, reach, and the note (used 0-12 %, crossed 12-20 %, blank 20+, rendered on all three tables; as
  steelhead; resident form row 1166). Only life_history_form is questioned (R6).
- Every data-row cross-reference in the 36 notes opens on the row it names.

Research sentences found right:
- Header: rows 1154-1189, the gate and log path, passage_limits files exist.
- Line 13-15 class values (origin/main), 100 m window (fresh `frs_break` default `distance = 100L`).
- Line 19 "none of the classes is a measured passage limit"; "25 % comes from BC's first fish-passage model".
- Lines 22, 41-42: grayling and kokanee have no source; entered link's configuration on the salmon class in 2026
  (link 323207783).
- Lines 28-32: Version 1 used 25 % for every species (row 1157); its authors' 20 % (guidebook) and 25-30 % (Cannings and
  Ptolemy) basis; Cannings and Ptolemy say bull trout to 30 % on a pers. comm.; bcfishpass 25 % for BT (docs) and CT, DV,
  RB (model_access_ct_dv_rb.sql, GRADIENT_25/30); Norris and Mount call it Version 1's and say the model "has not been
  field verified as a predictor of fish habitat" (p. 1, section 2.1).
- Lines 33-36: guidebook default, 100 m, no study; WDFW 2009 > 20 % for 160 m; 2019 steelhead 20 %; no westslope limit.
- Lines 37-38: Rebellato cites WDFW 2009 for chinook, sockeye and coho 16 % (p. 4); 98 % / 94 % figures.
- Lines 40-41: Washington passes chinook, coho, sockeye to 16, pink to 12, chum to 5 (rows 1167, 1169-1172).
- Table rows for chinook/coho/sockeye, pink, chum, steelhead, rainbow/cutthroat (incl. sea-run 20 %, row 1189),
  westslope (3.55 m/s maximum in a flume), kokanee; every data row number in the table.
- Lines 59-61: burst ranges (13.7-26.5; 10.2-22.4 as "10 to 22"; 7.7-15.0 from 3-4 ft leaps; Bell 1973 via Powers and
  Orsborn).
- Lines 68-69: BC 100 m vs Washington 160 m; a limit sustained over 160 m is the less strict.
- Line 70: 15 % is three times chum's 5 %.
- Lines 75-76: Jauquet 2002, Reiser and Peacock 1985, Bell 1973 seen only as cited.
- Lines 80-82: bcfishpass docs table vs SQL (CT, DV, RB at 25 % in the SQL only); fresh aac96efe (2026-03-18) created
  parameters_fresh.csv with RB, CT, DV at 0.25; link 323207783 (2026-05-02) added GR and KO at 0.15; none cites a source.
- Lines 85-86: `knw_literature_read()` refuses a parameter or model_id on leap_height/swim_speed rows; 0280's ACCESS grid
  counts each of the 13 species' access_gradient_max rows.
- Line 87: habitat_literature.md line 40 carries the quoted sentence.

Not verifiable from the sources: "a sweep of about 50 passage sources (#234)" (rows 1186-1188); "Lauritzen et al. 2010
... no CrossRef abstract" (1187); "Mesa et al. 2008 ... paywalled with no abstract" (research line 75).
