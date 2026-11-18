# Audit r4: meaning of literature_evidence.csv data rows 1154-1189, research/access_gradients.md and its index row

Read against: round-3 diff (`git show 57a88c42`, word diff of the CSV: rows 1154, 1156, 1163, 1164, 1184 changed);
WDFW 2009 pp. 6-1, 9-6, 9-7 (Table 9.2 in the text layer, hatching per stratum); WDFW 2019 pp. 2-3, 2-7, 7-2, 7-4,
10-1, 10-2, 10-6, 10-7, 10-25, 10-26, 11-4 (page = the footer printed after the text, as in rounds 2-3); Cannings and
Ptolemy p. 22; Mount et al. 2011 p. 9; FSIG 1998 pp. 16, 23, 24; Blank et al. 2020 pp. 217-222; Rebellato et al. 2024
p. 4 and reference [67]; data rows 6-8, 63, 114, 355-359; bcfishpass 254849fc (README, first tree), 5b7f8d1b,
0cb2febc (model.sql), 79b97e02, bd4ad32f, e5529440, ea6645c3, 620dbe43 docs/02_model_access.md, docs/03, and
model/01_access/sql/model_access_*.sql; fresh aac96efe (inst/extdata/parameters_fresh.csv); link 323207783 and
origin/main db4a7710 (default/parameters_fresh.csv, R/lnk_barrier_overrides.R, R/lnk_pipeline_prepare.R).

12 findings: 2 errors, 4 imprecisions, 6 ok-with-note. 10 sit inside round-3 fixes (N1-N7, N10-N12); both errors do.
The loop does not end at this round.

## research/access_gradients.md

**N1. Lines 13-14: "unless enough records of the species sit above it".** error. Inside round-3 fix F16.
link's lift (R/lnk_barrier_overrides.R, params from default/parameters_fresh.csv at origin/main) counts records of
`observation_species`, which is not "the species" for six of the thirteen, and lifts none by records for two:
- CH, CM, CO, PK, SK: 2 records since 1990 of any of `CH;CM;CO;PK;SK`; ST: 2 since 1990 of any of `CH;CM;CO;PK;SK;ST`
  (`WHERE o.species_code IN (<observation_species>) ... HAVING count(DISTINCT o.observation_key) >= <threshold>`).
- CT and DV: `observation_threshold` NA, so `threshold <- 0L` and the observation block (`threshold > 0`) never runs.
- BT, RB, WCT: 1 record of the species, any date; GR, KO: 2 of the species since 1990.
- It also lifts a barrier with any confirmed habitat of the species upstream (`habitat = habitat_arg` in
  lnk_pipeline_prepare.R line 588ff), and a control row blocks the record lift for the salmon, steelhead, GR and KO
  (`observation_control_apply` TRUE).
Round 3's F16 named the right mechanism but the fix's wording carries the wrong unit; it matters here because the
records above barriers are the file's next piece.
Fix: "...read over 100 m, unless fish records sit above it (two since 1990 of any salmon for each salmon, and of any
salmon or steelhead for steelhead; one of the species itself for bull trout, rainbow and westslope cutthroat; two since
1990 for grayling and kokanee; none count for cutthroat or Dolly Varden) or confirmed habitat does".

**N2. Lines 20-21 ("In short") and research/README.md line 12: "steelhead's 20 % from Washington's barrier manual".**
error. Inside round-3 fixes F7 (which kept the origin claim and narrowed it to steelhead) and F9 (which wrote it into the
index); F5's correction reached the 20 % bullet but not these two.
Says the 20 % comes from Washington's manual. The file's own bullet (lines 36-38) now says bcfishpass "has used 20 % for
steelhead since its first access model (2020); Rebellato et al. 2024 ... later document it from Sheer and Steel 2006 and
WDFW 2009". bcfishpass history: 0cb2febc (2020-12-08) `accessibility_model_steelhead` requires
`dnstr_barriers_gradient_20 IS NULL`; its first README (254849fc, 2020-11-06) lists among its requirements "gradient
barriers at 15/20/30 percent (from FPTWG)". So the 20 % predates the report by over three years, as the 15 % does, and
no document read says bcfishpass or the FPTWG took it from Washington; BC's own documented 20 % is Mount et al. 2011's
"grades exceeding 20% are considered a barrier for anadramous species (B.C. Ministry of Forests 1998)" (p. 9, data row
1157). Round 3 found exactly this for 15 % and fixed it there.
Fix (21): "25 % comes from BC's first fish-passage model, a convention handed down without its basis. bcfishpass has used
20 % for steelhead since 2020; the basis documented later (Rebellato et al. 2024) is Washington's barrier manual, which
gives none." (README): "steelhead's 20 % used by bcfishpass since 2020 and later documented from Washington's barrier
manual".

**N3. Line 33: "bcfishpass uses 25 % for bull trout (from 2021; ...)".** imprecision. Inside round-3 fix F15.
79b97e02 (2021-12-17) adds `barriers_gradient_25` only to stream breaking (`breakpoints.sql`); no model reads it then
(`git grep gradient_25 79b97e02` finds that file only). Bull trout first gets an access model, with
`definitebarriers_bt.sql` reading `barriers_gradient_25` and `_30`, in ea6645c3 (2022-01-13, "add prelim support for
bt/gr/rb"). Round 3's F15 wrote "25 % added in December 2021 (79b97e02)", true of the class, and the fix moved it onto
bull trout.
Fix: "bcfishpass uses 25 % for bull trout (from 2022; ...)".

**N4. Lines 72-74: "the order Washington's table gives (chum and pink lowest, steelhead and sea-run cutthroat highest)
follows these speeds".** imprecision. Inside round-3 fix F11.
The speeds (rows 1173-1182) are for steelhead, chinook, coho, sockeye and pink/chum; none of these sources gives sea-run
cutthroat a burst speed or leap. Round 3's F11 said so ("for which no speed is given"), and its fix then put sea-run
cutthroat inside the order that "follows these speeds".
Fix: "...the order Washington's table gives (chum and pink lowest, steelhead highest) follows these speeds, though the
speeds do not separate chum from pink; sea-run cutthroat, also at 20 %, has no speed in them."

**N5. Lines 5-6, header: "audited for meaning in four rounds".** imprecision. Inside round-3 fix F17.
Three rounds were complete when it was written; F17's own text said "Three rounds once this one is folded". Four holds
only if this round ends the loop, and it does not. Fix at fold time with the count of rounds actually run.

**N6. Lines 22, 37, 45: "Rebellato et al. 2024" and "the CWF report".** ok-with-note. Inside round-3 fix F5.
The report is first named at line 22 without "the CWF report", introduced as "(the CWF report)" at line 37, and
introduced again at line 45 ("Rebellato et al. 2024, the CWF report bcfishpass cites..."). CWF is never expanded
(Rebellato p. 1: "Canadian Wildlife Federation"). Fix: at line 22, "Rebellato et al. 2024 (a Canadian Wildlife Federation
report)"; drop the parenthesis at 37 and say "Rebellato et al. 2024, which bcfishpass cites for its salmon habitat
thresholds" at 45.

**N7. Lines 43-44: "since its first access model (2020), when its README listed gradient barriers at 15, 20 and 30 %
'from FPTWG'".** ok-with-note. Inside round-3 fix F5.
The README (254849fc, 2020-11-06) lists them under "Requirements", as input data, a month before the first access model
(0cb2febc, 2020-12-08), and assigns no species. "When" joins the two dates; the sentence does not claim more, but a
reader may take the README to have paired 15 % with salmon. Fix: "...since its first access model (December 2020); its
first README (November 2020) lists gradient barriers at 15, 20 and 30 % 'from FPTWG' among its inputs, with no species".
Quote style also differs from line 34 ('from FPTWG' there, "from FPTWG" here).

**N8. research/README.md line 12: "and nothing for grayling, kokanee or westslope cutthroat".** imprecision. Not a
round-3 fix: the clause stood before round 3 and every round left it.
The file gives grayling a culvert velocity (1.5 m/s, data row 1185) and westslope cutthroat a flume swim speed (3.55 m/s,
data row 1184); its table says "no gradient limit found" for both and "nothing found" only for kokanee.
Fix: "and no gradient limit for grayling, kokanee or westslope cutthroat".

**N9. Line 61, bull trout cell: "20 % used, passing to 33 % recognised, which its Chapter 7 gives bull trout as 'often
found above 30%' (WDFW 2019 pp. 10-7, 7-4)".** ok-with-note. Not a round-3 fix.
"Which ... gives bull trout as" does not parse, and "its" comes before the WDFW 2019 it refers to. Fix: "20 % used and
passing to 33 % recognised (WDFW 2019 p. 10-7), where its Chapter 7 says bull trout are 'often found above 30%' (p. 7-4)".

**N10. Line 36-37: "bcfishpass has used 20 % for steelhead since its first access model (2020)".** ok-with-note. Inside
round-3 fix F5.
The bullet is for steelhead and westslope cutthroat; the same first model (0cb2febc) gives `accessibility_model_wct`
the 20 % too (`dnstr_barriers_gradient_20 IS NULL`), so westslope cutthroat's uncited 20 % is as old. Fix: "...for
steelhead and westslope cutthroat since its first access model (2020)".

**N11. Lines 22-23 and 80-81: "94 to 98 % of BC records ... at or below it"; "97 % of chum and 96 % of pink at or below
15 %".** ok-with-note. Line 80-81 inside round-3 fix F10 (the figures were carried, not introduced).
What Rebellato measured is each record's maximum downstream gradient (p. 4: "the maximum gradient of all downstream
locations was identified for each observation"; "had a maximum downstream gradient of 15%"), as line 46 says. "Records at
or below 15 %" reads as the gradient where the fish was caught. Fix: "...whose maximum downstream gradient is 15 % or
less" in both places.

## Data rows

**N12. Row 1184, note: "set beside the upper limit of Bell (1991)'s cutthroat burst range (~4.12 m/s, p. 222)".**
ok-with-note. Inside round-3 fix F3.
Correct as written (p. 222: "less than the upper limit of the burst swim range (~4.12 m/s) for Cutthroat Trout reported
by Bell (1991)"). The same paragraph first sets 3.55 m/s beside Peterson et al. 2013 ("similar to the average water
velocity that Coastal Cutthroat Trout ... were able to overcome in the culvert test bed flume study"), which the note
omits. Not wrong; optional fix: "set beside Peterson et al. 2013's coastal cutthroat culvert velocities (similar) and the
upper limit of Bell (1991)'s cutthroat burst range (~4.12 m/s; p. 222)".

## Checked and found right

Round-3 changes, word by word:
- Row 1154: p. 7-2 lists only Gradient (≥ 20 % for ≥ 160 m "without resting areas") and Waterfall (> 3.7 m); p. 10-2
  "A TD is terminated when ... The scour width is < 0.61 meters for a distance of ≥ 160 meters in Western Washington or <
  0.91 meters ... in Eastern Washington", TD defined on p. 10-1 as a Threshold Determination; p. 10-26 "The following
  physical criteria indicate that a channel has become non fish-bearing: A scour width < 0.61 meters for a distance
  greater than 160 meters". "Over 160 m" covers both pages' wording; the two statements are now separate. No 16 % rule
  anywhere in 2019's text layer.
- Row 1156: "often found above 30% gradient" verbatim in 2009 p. 6-1 (above the "Chapter 6 ... 6-1" footer) and 2019
  p. 7-4; Cannings and Ptolemy p. 22 (running head "22 Rare Freshwater Fish") "up to 30%", so "which it does not say"
  holds.
- Rows 1163-1164: p. 10-7 sentence ends "(See Chapter 7)"; Chapter 7 (p. 7-4) gives bull trout "often found above 30%"
  and cutthroat "up to 33%"; for bull trout neither the chapter nor Cannings and Ptolemy states 33 %; no Dolly Varden in
  Chapter 7; the resident-trout paragraph also on p. 2-7 (under Table 2.1, footer 2-7).
- Row 1184: 4.12 m/s is the upper limit of the burst range, Bell (1991) (reference list "Bell MC. 1991. Fisheries
  handbook of engineering..."); p. 222 is the page (running footers 221/222 bracket it).
- Research: "15 % used by bcfishpass since 2020" (0cb2febc `accessibility_model_salmon`: `dnstr_barriers_gradient_15 IS
  NULL`; the 15 % table exists from 254849fc); "its first classes, in 2020, were 15, 20 and 30 %" (254849fc tree:
  barriers_gradient_15/20/30.sql only); "no document read says who first gave salmon 15 %"; "Rebellato et al. 2024, the
  CWF report bcfishpass cites for its salmon habitat thresholds" (bcfishpass docs/03 line 16 cites "Rebelatto et al
  (2024)" Table 1); "found no literature limit for pink or chum" (p. 4); 96, 97, 98, 94 % and 94 to 98 %; Washington's
  16 % for chinook, coho and sockeye (p. 4, citing WDFW 2009); Rebellato's reference [67] is the 2009 manual; Table 9.2 is
  on p. 9-7 (after the 9-6 footer) and hatches chum to 3-5, pink to 7-12, coho, sockeye and chinook to 12-16, steelhead
  and sea-run cutthroat to 16-20, footnotes 1 and 2; steelhead "pass gradients up to 20% (Sheer and Steel 2006, WDFW
  2009)" (p. 4; data row 359); "WDFW 2009 and 2019, after Jauquet 2002" (2009 p. 6-1, 2019 p. 7-4); "Bull trout and
  cutthroat are recorded above 25 %, and cutthroat, bull trout, Dolly Varden and sometimes rainbow above 20 % (BC 1998)"
  (FSIG p. 24, Cannings p. 22, WDFW p. 7-4); "Washington still sets resident trout and bull trout/Dolly Varden use at
  20 %" (p. 10-7); "Westslope cutthroat's 20 % and grayling's and kokanee's 15 % have no source at all" (rows 1186-1188);
  "Rebellato et al. set 15 % from BC fish records ... and do not report how many sit above 5 % or 12 %" (p. 4 reports
  only the 15 % share); the title and the heading "What the sources give, by species".
- Index row: "25 % from BC's Fish Passage GIS Version 1 (Mount et al. 2011, after a personal communication on bull trout
  in Cannings and Ptolemy 1998)"; "15 % used by bcfishpass since 2020 and later supported by BC records of pink, chum,
  chinook and coho (Rebellato et al. 2024)"; the Washington list; "bull trout and cutthroat recorded above 25 %".

Reader's pass, unchanged text found right: link's classes per species (origin/main parameters_fresh.csv); Mount p. 9
("Typically, grades exceeding 20% are considered a barrier for anadramous species (B.C. Ministry of Forests 1998) ...
Bull Trout and Dolly Varden/Cutthroat) can utilize reaches with a sustained slope of 25-30% (Cannings and Ptolemy
1998)"); FSIG 100 m (p. 16), < 20 % default (p. 23), "not legally required to be surveyed" and "well in excess of 20%"
(p. 24); WDFW 2009 "exceeding 20% for 160 or more meters"; bcfishpass docs/02 table (salmon 15, ST 20, WCT 20, BT 25,
no citation) and 100 m after the Fish Stream Guidebook; access SQL (BT 25/30, CT/DV/RB 25/30, ST 20+, WCT 20+, salmon
15+); fresh aac96efe (2026-03-18) parameters_fresh.csv with all 11 species, RB, CT, DV at 0.25; link 323207783
(2026-05-02, #107) adds GR and KO rows; table cells for chinook/coho/sockeye, pink, chum, steelhead, Dolly Varden,
westslope cutthroat, grayling (5 of 61 = 3 of 40 + 2 of 21), kokanee; the burst and leap figures; every data-row number
in the file opens on a row that says what the sentence uses it for.

Rows 1154-1189 beyond round 3's changes: re-read every note; nothing new beyond N12.

Not verifiable from the sources: who first assigned 15 % to salmon and 20 % to steelhead in BC (N2).

Findings inside a round-3 fix: N1, N2, N3, N4, N5, N6, N7, N10, N11 (in part), N12; the two errors (N1, N2) and
three of the four imprecisions (N3, N4, N5) are among them.
