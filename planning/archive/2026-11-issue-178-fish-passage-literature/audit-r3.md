# Audit r3: meaning of literature_evidence.csv data rows 1154-1189 and research/access_gradients.md

Read against (text via `pdftotext -layout`; Table 2.1 of WDFW 2019 (PDF p. 25) and Table 9.2 of WDFW 2009 (PDF p. 103)
rendered): WDFW 2009 pp. 3-x fish use criteria, 6-1, 6-2, 9-6, 9-7; WDFW 2019 pp. 2-3, 2-6, 2-7, 2-10, 7-2, 7-4, 10-1,
10-2, 10-6, 10-7, 10-26, 11-3, 11-4, references; Mount et al. 2011 pp. 9-10; Norris & Mount 2016 pp. 2-3 and 2.1.3.1;
FSIG 1998 pp. 16, 23, 24; Cannings & Ptolemy 1998 OCR p. 22; Powers & Orsborn 1985 pp. 10, 11, 17, 18; Bjornn & Reiser
1991 OCR pp. 86-88; Blank et al. 2020 pp. 217-222 (QIPA3F2N); MacPhee & Watts 1976 p. 24; Rebellato et al. 2024 p. 4
(WWN7VXP8); Sheer & Steel 2006 pp. 1657-1658 (3NM3VKQA); bcfishpass 620dbe43 docs/01-03, model_access_*.sql, and its
history (254849fc 2020-11-06, 0cb2febc 2020-12-08, 4d0cbfcb 2021-05-31, 8734ff8a 2023-12-16); fresh aac96efe; link
323207783 and origin/main (parameters_fresh.csv, R/lnk_barrier_overrides.R); R/literature.R vocabulary; scripts/0280
ACCESS grid; data rows 6-8, 63, 114, 116, 355-359; research/README.md; round-2 diff (`git show HEAD`).

17 findings: 4 errors, 7 imprecisions, 6 ok-with-note. 9 sit inside round-2 fixes (F1, F2, F3, F5 in part, F6, F7,
F8, F10, F11). The loop does not end at this round.

## Data rows

**F1. Rows 1163-1164, note (inside round-2 fix R1).** error.
Says: "...'often found above 30%' to bull trout, citing Cannings and Ptolemy 1998, who write 'up to 30%' (data row 1156).
So for bull trout the chapter it points to gives about 30 %, not 33 %, and it does not name Dolly Varden."
Source: WDFW 2019 p. 7-4: "bull trout are often found above 30% gradient (Cannings and Ptolemy 1998)". The chapter says
*above* 30 %, which does not exclude 33 %; only the source it cites says "up to 30%" (Cannings & Ptolemy p. 22). R1's
proposed text said "the source it points to gives about 30 %"; the fix changed "source" to "chapter", so the sentence now
puts Cannings and Ptolemy's bound in Chapter 7's mouth, and "not 33 %" no longer follows from the chapter.
Fix: "So for bull trout Chapter 7 gives 'above 30%', resting on a source that says 'up to 30%'; neither states 33 %, and
the chapter does not name Dolly Varden."

**F2. Row 1154, note (inside round-2 fix R2).** imprecision.
Says: "...drops the > 16 % narrow-channel barrier (p. 7-2); a scour width < 0.61 m (Western) or < 0.91 m (Eastern) over
160 m remains, with no gradient, as the end of fish-bearing channel (pp. 10-2, 10-26)."
Source: p. 10-2 is a condition on which "A TD is terminated" ("The scour width is < 0.61 meters for a distance of ≥ 160
meters in Western Washington or < 0.91 meters for a distance of ≥ 160 meters in Eastern Washington"), a Threshold
Determination being a 200 m survey (p. 10-1); only p. 10-26 calls it non fish-bearing ("The following physical criteria
indicate that a channel has become non fish-bearing: A scour width < 0.61 meters for a distance greater than 160
meters..."). The note merges the two pages' statements into one. "Remains" also gives the width rule a lineage from the
2009 barrier it does not have: 2009 already carried a width rule apart from the barrier, as a fish-use criterion ("average
scour line widths (SLW) in excess of 0.6 meters ... provided the stream gradient is less than 20 percent", 2009 Fish Use
Criteria), which 2019 repeats on p. 2-3.
Fix: "...drops the > 16 % narrow-channel barrier (p. 7-2). A scour width < 0.61 m (Western) or < 0.91 m (Eastern) over
160 m, with no gradient, ends a threshold survey (p. 10-2) and marks a channel non fish-bearing (p. 10-26)."

**F3. Row 1184, note (inside round-2 fix R5).** imprecision.
Says: "...set beside Bell's burst range for cutthroat (~4.12 m/s, p. 222)".
Source p. 222: "it is less than the upper limit of the burst swim range (~4.12 m/s) for Cutthroat Trout reported by Bell
(1991)". 4.12 m/s is the range's upper limit, not the range, and the Bell is Bell (1991), whereas every other "Bell" in
rows 1173-1180 and the research file is Bell (1973) or the 1986 edition.
Fix: "...set beside the upper limit of Bell (1991)'s cutthroat burst range (~4.12 m/s, p. 222)".

**F4. Row 1156, note.** imprecision (not a round-2 fix; missed by both rounds).
Says: "WDFW 2009 and 2019 quote it as 'often found above 30% gradient'."
Source: WDFW 2009 p. 6-1 and 2019 p. 7-4 write "bull trout are often found above 30% gradient (Cannings and Ptolemy
1998)", a restatement, not a quotation: Cannings and Ptolemy write "up to 30%" (p. 22). Rows 1163-1166 now say this; row
1156 still calls it a quote, so the two notes disagree.
Fix: "WDFW 2009 (p. 6-1) and 2019 (p. 7-4) cite it for 'often found above 30% gradient', which it does not say."

## research/access_gradients.md

**F5. Lines 19-21, 34-35, 41-44: the CWF report as the origin of bcfishpass's 15 % and 20 %.** error (line 34-35 inside
round-2 fix S3; lines 20-21 reworded by S1).
Says (20-21): "15 % is the one set on evidence: where BC records of pink and chum, then chinook and coho, sit"; (34-35):
"Steelhead's 20 % reaches bcfishpass's values through the same CWF report as the salmon's"; (41-44) the report "sets 15 %
from BC records".
Source: bcfishpass applied 15 % to salmon and 20 % to steelhead from its first access model, 0cb2febc (2020-12-08:
`accessibility_model_salmon` requires `dnstr_barriers_gradient_15 IS NULL`, steelhead `dnstr_barriers_gradient_20`; same in
4d0cbfcb, 2021-05-31), and its first README (254849fc, 2020-11-06) lists "gradient barriers at 15/20/30 percent (from
FPTWG)"; its docs carried "Pacific salmon (all) | 15%, Steelhead | 20%" by 8734ff8a (2023-12-16). Rebellato et al. is
2024. Norris & Mount 2016 (the FPTWG model) offer 10/15/20/25/30 % as classes "users ... are then free to choose" (2.1.3.1)
and assign none to a species. So bcfishpass's 15 % and 20 % predate the report by three years: the report documents and
tests values bcfishpass already used (same organisation), it cannot be where bcfishpass took them from, and no document
read says who first assigned 15 % to salmon. R2's S11 noted the link was by matching value; the S3 fix then wrote it as a
lineage.
Fix (20-21): "15 % is the one with evidence behind it, though the evidence came after: bcfishpass used it for salmon from
2020, and Rebellato et al. 2024 later found 94 to 98 % of BC records of pink, chum, chinook and coho at or below it." (34-35):
"bcfishpass has used 20 % for steelhead since its first access model (2020); the CWF report (Rebellato et al. 2024) later
documents it from Sheer and Steel 2006 and WDFW 2009 (data row 359)..." (41-42): name the report once, "Rebellato et al.
2024, the CWF report bcfishpass cites for its salmon habitat thresholds and whose access values match bcfishpass's (used
since 2020), ...". Revise research/README.md with it (F9).

**F6. Line 21: "(96 to 98 % at or below 15 %)".** error (inside round-2 fix S1, whose proposed text carried it).
Source, Rebellato p. 4: pink 96 %, chum 97 %, chinook 98 %, "94% of Coho salmon observations (n= 20,653) had a maximum
downstream gradient of 15%". The sentence names coho, so the range is 94 to 98 %. (Line 44 has 94 % right.)
Fix: "(94 to 98 % at or below 15 %)".

**F7. Lines 19-20: "20 % from Washington's barrier manual".** imprecision (inside round-2 fix S3).
The class is steelhead and westslope cutthroat (line 14); only steelhead's 20 % has a documented Washington basis (data
rows 359, 63). Westslope cutthroat's is uncited (line 39, data row 1188), and the summary's "Grayling and kokanee have no
source at all" leaves westslope cutthroat out of the sourceless.
Fix: "...and steelhead's 20 % from Washington's barrier manual, each a convention handed down without its basis.
Westslope cutthroat's 20 %, grayling's and kokanee's 15 % have no source at all."

**F8. Lines 23-24 and 79-80: "every trout and char is recorded above 20 %"; "Washington still sets their use at 20 %".**
imprecision bordering error (inside round-2 fix S4, whose proposed text carried it).
Source: the only above-20 % statement covering several trout and char is FSIG p. 24: "cutthroat trout, bull trout, Dolly
Varden char and sometimes rainbow trout have been observed to occur in very steep streams, well in excess of 20%
gradient". Steelhead, a trout, is blank (impassable) at 20+ in WDFW 2019 Table 2.1 (rendered p. 2-7; data row 1168), and
no source gives westslope cutthroat a gradient (data row 1188). "Their use at 20 %": WDFW sets resident trout and bull
trout/Dolly Varden use at 20 % (p. 10-7), but steelhead and sea-run cutthroat use only to 12 % (Table 2.1).
Fix (23-24): "bull trout and cutthroat are recorded above their 25 % class, and cutthroat, bull trout, Dolly Varden and
sometimes rainbow above 20 %." (79-80): "Bull trout and cutthroat are recorded above 25 %, and cutthroat, bull trout, Dolly
Varden and sometimes rainbow above 20 % (BC 1998); Washington still sets resident trout and bull trout/Dolly Varden use at
20 %."

**F9. research/README.md line 12, the index row for this file.** error (not a round-2 fix: round 2 corrected the file and
not its index, so the index now contradicts it in three places).
Says: "20 % from BC's 1998 fish-stream default and Washington's barrier manual" (S3 removed the 1998 default from the
lineage); "15 % from where chinook and coho records sit (Rebellato et al. 2024)" (S1: pink and chum first; and F5 here);
"char and resident trout above their class" (S4: Dolly Varden and rainbow are not recorded above 25 %).
Fix: rewrite the row from the file's revised "In short", e.g. "...25 % from BC's Fish Passage GIS Version 1 (Mount et al.
2011, after a personal communication on bull trout in Cannings and Ptolemy 1998), 20 % for steelhead from Washington's
barrier manual, 15 % used by bcfishpass since 2020 and later supported by BC records of pink, chum, chinook and coho
(Rebellato et al. 2024); ... bull trout and cutthroat recorded above 25 % ...".

**F10. Lines 76-78: chum and pink.** imprecision (inside round-2 fix S2).
Says: "BC's 15 % is three times Washington's chum limit. Rebellato et al. set 15 % from such records (97 % of chum and
96 % of pink at or below 15 %; data rows 357, 358), which do not say how many sit above 5 % or 12 %".
(a) The fix removed the sentence about "Fish records above 5 % ... and 12 %", so "such records" has no antecedent.
(b) This is the file's first and only "Rebellato et al.": lines 34 and 41 say "the CWF report", so a reader cannot tie the
two. (c) "which do not say": the records themselves would say; it is the report that does not report how many sit above
5 % or 12 % (p. 4 gives only the share at or below 15 %).
Fix: "Rebellato et al. set 15 % from BC fish records (97 % of chum and 96 % of pink at or below 15 %; data rows 357,
358) and do not report how many sit above 5 % or 12 %: that is the track's next piece...", with the report named as
Rebellato et al. 2024 at line 34 or 41 (F5).

**F11. Lines 68-70: "the order they give".** ok-with-note (inside round-2 fix S8/S9).
After "none of these sources derives a reach gradient from them", "they" reads as the passage sources (Bell, Powers and
Orsborn, Reiser and Peacock), which give no gradient order; the order meant is Washington's table's. Also "steelhead
highest": the table gives sea-run cutthroat the same 20 %, for which no speed is given.
Fix: "the order Washington's table gives (chum and pink lowest, steelhead and sea-run cutthroat highest) follows these
speeds, though the speeds do not separate chum from pink."

**F12. Line 59, rainbow/cutthroat cell: "(WDFW 2019, after Jauquet 2002)".** ok-with-note.
The 33 % for cutthroat after Jauquet is coded only from WDFW 2009 (data row 1155, p. 6-1); WDFW 2019 states it on p. 7-4,
which no row codes. The cell names one edition and cites the other's row. Fix: "(WDFW 2009 and 2019, after Jauquet 2002)".

**F13. Lines 45-46: "the Washington manual it cites does give pink and chum limits ... (data rows 1167, 1169-1172)".**
ok-with-note.
Rebellato cites WDFW 2009 (p. 4; reference [67], the 2009 manual); rows 1167 and 1169-1172 are the 2019 edition. The 2009
Table 9.2 (p. 9-7, rendered) does draw chum to 5 %, pink to 12 % and chinook, coho, sockeye to 16 %, as rows 1170-1172's
note says. Fix: "...does give pink and chum limits, in its Table 9.2 (p. 9-7), as the 2019 edition's tables do: ... (data
rows 1167, 1169-1172)".

**F14. Lines 1, 49: "what fish are measured to pass".** imprecision (not a round-2 fix).
Most of the section's table is Washington's expert tables, which cite no source (rows 1170-1172: "No source cited"); the
measurements are a pers. comm. (1156), FSIG's observations (1159-1162), one flume (1184) and one culvert test (1185). The
heading claims measurement for conventions, which is what the file argues they are not. Fix: "What the sources give, by
species" (and the title "what the sources say fish pass").

**F15. Lines 31-32: "bcfishpass kept 25 % for bull trout".** ok-with-note.
"Kept" implies continuity from Version 1; bcfishpass's first gradient classes were 15/20/30 % "from FPTWG" (README
254849fc, 2020-11-06), with 25 % added in December 2021 (79b97e02). The value is Version 1's, and Norris & Mount 2016 say 25 %
"is still the gradient barrier threshold most often used" (2.1.3.1), so the by-value link holds; the verb overstates it.
Fix: "bcfishpass uses 25 % for bull trout (from 2021) and, in its SQL, ...".

**F16. Line 13: "link blocks a species above the first stretch of stream steeper than its access gradient".** ok-with-note.
link lifts a gradient barrier with enough records of the species above it (`observation_threshold`,
`observation_date_min` in parameters_fresh.csv, applied by `R/lnk_barrier_overrides.R`), so the block is not the first
steep stretch where records sit above it. This matters to the file because records above modelled barriers are its next
piece. Fix: "...steeper than its access gradient, read over 100 m, unless enough records of the species sit above it".

**F17. Lines 5-6, header: "audited for meaning in two rounds".** ok-with-note.
Three rounds once this one is folded; `planning/archive/` for #178 does not exist until the archive step. Fix at fold time.

## Checked and found right

Round-2 changes, word by word:
- Row 1154: "drops the > 16 % narrow-channel barrier (p. 7-2)": p. 7-2's list has Gradient and Waterfall only; 0.61 m /
  0.91 m and 160 m on pp. 10-2, 10-26 (pages from footers; only the merge and "remains" are flagged, F2).
- Row 1157: "whose 20 % is for all fish": FSIG p. 23 "areas too steep for fish use: these usually are areas of ≥ 20%
  grade" and the default for fish streams; Mount p. 9 cites "B.C. Ministry of Forests 1998" for anadromous species.
- Rows 1163-1166: "often found above 30%" verbatim from p. 7-4, "citing Cannings and Ptolemy 1998, who write 'up to 30%'"
  (p. 22, data row 1156); "does not name Dolly Varden" (p. 7-4 names bull trout only). Only the "about 30 %" clause fails (F1).
- Rows 1170-1172: the text layer prints "5-7" in Table 2.1 (p. 2-7) and "5-7m" in Tables 10.1 (p. 10-7) and 11.1
  (p. 11-4); placement now covers both.
- Rows 1173-1178: "Hoar and Randall (1978)'s class, which the report adopts" (p. 10, "will be used in this study"); "Bell
  (1973) estimates burst speed is held for 5 to 10 s (p. 18)": "Bell" ends p. 17, "(1973) suggests that burst speed can be
  maintained for an estimated 5 to 10 seconds" opens p. 18.
- Rows 1183-1184: 0.6 m segment on p. 222 ("within an 0.6-m flume segment"); "short-duration" on pp. 217 (abstract) and
  219; the paper names no class (no "burst", "sprint" or "prolonged" applied to its own speeds); rainbow "toward the upper
  end of values reported in other studies" (p. 222); 2.73 in Results and Discussion (p. 222).
- Row 1188: list now includes 1189; 1155's thesis is "Coastal cutthroat trout (Oncorhynchus clarki clarki) diet in South
  Puget Sound" (both editions' references).
- Row 1189: life_history_form blank; the vocabulary has no anadromous form (R/literature.R line 82-83); Table 2.1 rendered:
  sea-run cutthroat green 0-12, crossed 12-20, blank 20+, the same as steelhead; quote in the text layer.
- Research, round-2 text found right: link path and values (origin/main: BT, CT, DV, RB 0.25; ST, WCT 0.2; CH, CM, CO, PK,
  SK, GR, KO 0.15); Rebellato p. 4 figures (96, 97, 98, 94 %) and "No evidence of passable gradients for Chum or Pink
  salmon was available in the scientific literature"; steelhead "(Sheer and Steel 2006, WDFW 2009)" (data row 359); Sheer
  and Steel's 20 %/16 % sentence cites "(WDFW 2000)" (pp. 1657-1658; data row 63's cited_source also lists Steel and Sheer
  2003, which belongs to the preceding sentence, outside this audit's rows); WDFW 2009 "exceeding 20% for 160 or more
  meters" (data row 1154); FSIG 100 m (p. 16) and no study; Version 1 25 % for every species (Mount p. 10, Norris & Mount);
  "has not been field verified" (Norris & Mount 2.1); the DV and bull trout cells' 33 % and Chapter 7 wording; grayling
  cell's 30.5 m culvert and "all but 3 out of 40 fish (4-7 C), and 2 out of 21 fish (9-10 C)" (MacPhee and Watts p. 24);
  Reiser and Peacock "computed maximum jumping heights of salmonids on the basis of darting speeds" (Bjornn and Reiser
  p. 86), Table 4.2 coho 2.2, steelhead 3.4; the Specification's Table 11.1 and "hatched ... strata to 16-20 %" (Table 9.2
  rendered: horizontal lines, strata 0-1 to 16-20, the seven anadromous species agree with Table 2.1, Bull Trout and Trout
  shaded throughout, footnotes 1 and 2); "bcfishpass `docs/02_model_access.md` (the table, with no citation)".
- Research, unchanged text found right: 100 m (bcfishpass docs/02 cites the Fish Stream Guidebook for it; fresh
  `frs_break` default); "less strict" over 160 m; 15 % three times 5 %; fresh aac96efe (2026-03-18) created
  parameters_fresh.csv with RB, CT, DV at 0.25; link 323207783 (2026-05-02, PR link#107) added GR and KO at 0.15;
  bcfishpass SQL: BT GRADIENT_25/30, CT/DV/RB GRADIENT_25/30, ST and WCT GRADIENT_20+, salmon GRADIENT_15+;
  `knw_literature_read()` refuses a parameter or model_id on leap_height/swim_speed rows (R/literature.R line 284); 0280's
  ACCESS list is the 13 species and counts any row with the parameter (qual rows included); habitat_literature.md line 40
  carries the quoted sentence; every data-row number in the file opens on a row that says what the sentence uses it for
  (bar F12, F13).

Last pass, every field of rows 1154-1189: species codes, life stages (access; 1185 migration), variables, parameters
(blank on capability rows 1173-1184 and on 1185), bounds, values and units against the sources; kinds (max_obs 1155-1156,
param 1157, qual 1159-1162, lab 1183-1185, none 1186-1188, expert elsewhere); regions; citation keys resolve to the PDFs
read; pages from printed footers (WDFW 2009 footers sit at page foot: Table 9.2 is PDF p. 103 = 9-7, the barrier list
6-1; WDFW 2019 7-2, 7-4, 10-6, 10-7, 11-3, 11-4, 2-7, 2-10; Powers and Orsborn 10, 11, 18; Bjornn and Reiser 88; Blank
217; MacPhee and Watts 24; FSIG 23, 24; Mount 10; Cannings and Ptolemy 22); quotes verbatim in the text or OCR layer;
quote_source (table for 1173-1178, ocr for 1181-1182); scales; cited_source. Nothing beyond F1-F4.

Not verifiable from the sources: who first assigned 15 % to salmon and 20 % to steelhead in BC (F5); the "sweep of about
50 passage sources" (rows 1186-1188); Lauritzen et al. 2010's and Mesa et al. 2008's availability.
