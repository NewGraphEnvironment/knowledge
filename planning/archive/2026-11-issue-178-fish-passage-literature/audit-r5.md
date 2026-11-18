# Audit r5: round-4 changes to research/access_gradients.md and its research/README.md row

Scope: `git show 1c6b882b -- research/` (round 4's fold; HEAD f1934e6b touches only task_plan.md). Line numbers
are the file at HEAD.

Read against: link origin/main db4a7710 (`inst/extdata/configs/default/parameters_fresh.csv`,
`overrides/user_habitat_classification.csv`, `R/lnk_barrier_overrides.R`, `R/lnk_pipeline_prepare.R`); bcfishpass
254849fc (README "Requirements"), 5b7f8d1b, 0cb2febc (`02_model/sql/model.sql`), 79b97e02, ea6645c3
(`definitebarriers_bt.sql`), and 620dbe43 `docs/02_model_access.md` and `docs/03_model_habitat_linear.md`;
Rebellato et al. 2024 (WWN7VXP8, the PDF of Z8AUF79B) pp. 1 and 4; WDFW 2019 text layer pp. 2-6/2-7, 7-2, 7-4,
10-6/10-7; Powers and Orsborn 1985 Table 1 (p. 11); data rows 6-8, 63, 355-359, 1154-1173, 1180, 1184-1189.

9 findings: 0 errors, 5 imprecisions, 4 ok-with-note. All 9 sit inside round-4 fixes (R1-R9), the 5 imprecisions
among them. Nothing found outside round 4's fixes. The loop does not end at this round.

## Inside round-4 fixes

**R1. Lines 21-22 ("In short") and research/README.md row: "bcfishpass has used 15 % for salmon and 20 % for
steelhead and westslope cutthroat since 2020, with no source named".** imprecision. Inside the round-4 fix for N2.
bcfishpass does name one. Its first README (254849fc, 2020-11-06), under "Requirements": "gradient barriers at
15/20/30 percent (from FPTWG)". Its access doc (620dbe43 `docs/02_model_access.md` line 4): "`bcfishpass` is based on
previous BC Fish Passage Technical Working Group (FPTWG) Fish Passage models". The file itself quotes "from FPTWG" at
lines 36 and 46. What no bcfishpass text gives is a document, or a source for which species gets which class: the
README line names no species, and the docs/02 table ("Pacific salmon (all) 15%, Steelhead 20%, Westslope Cutthroat
Trout 20%, Bull trout 25%") cites nothing. "No source named" is wider than that.
Fix (line 22): "...since 2020, crediting the classes to the province's Fish Passage Technical Working Group but citing
no document for which species gets which;". README row: "...used by bcfishpass since 2020 with no document cited,".
Line 46's "FPTWG" then gets its expansion here, at first use.

**R2. Lines 22-23: "Washington's barrier manual gives steelhead the same 20 %. 15 % is the one with evidence behind
it".** imprecision. Inside the round-4 fix for N2.
Round 4 dropped "each a convention handed down without its basis", which was what set 15 % apart. As the In short
reads now, Washington's 20 % looks like support for steelhead's class, and the reader has no reason left to call 15 %
"the one". The Washington table cites nothing: data rows 1170-1172 say "No source cited", and the table has drawn
cells only (WDFW 2019 p. 2-7: "Crossed-out yellow cells indicate that the species can pass through the reach..."; no
reference beside it). Line 75 says only that none of the sources derives a gradient from speeds.
Fix: "Washington's barrier manual gives steelhead the same 20 %, citing no study for it."

**R3. Lines 14-15: "records of any salmon count for each salmon".** imprecision. Inside the round-4 fix for N1.
The sentence is true only if "salmon" means the five Pacific salmon. The file uses the word before it says which
species it means ("15 % for salmon", line 22; "the five salmon", line 45), and line 16 lists kokanee in the same
class. In link (parameters_fresh.csv, origin/main):
- CH, CM, CO, PK and SK each take `observation_species` `CH;CM;CO;PK;SK`.
- KO takes `KO` only, so kokanee records do not lift for sockeye and sockeye records do not lift for kokanee. Kokanee
  is O. nerka, and WDFW lumps sockeye and kokanee in its species codes (data row 1187).
- ST takes `CH;CM;CO;PK;SK;ST`, but no salmon takes ST. Rebellato et al. call steelhead "salmon" ("steelhead
  (hereafter referred to as 'salmon')", p. 3), and on that reading the sentence is false.

The same `observation_species` list also governs the confirmed-habitat lift (`h.species_code IN (<obs_sp_sql>)` in
`lnk_barrier_overrides.R`), so "count" holds for habitat as well as records.
Fix: "records of any of the five Pacific salmon count for each of them (and for steelhead, with its own)".

**R4. Lines 5-6, header: "audited for meaning in rounds until one found no error inside an earlier round's fix".**
imprecision. Inside the round-4 fix for N5.
The loop's stopping rule, as round 4 applied it ("10 sit inside round-3 fixes ... The loop does not end at this
round", counting imprecisions and ok-with-notes), is that a round finds nothing inside an earlier round's fix. "No
error" names only one severity class: a round with only imprecisions inside fixes, like this one, would satisfy the
header and still not end the loop. The past tense is also true only once the loop has ended.
Fix: "...audited for meaning in rounds until one found nothing inside an earlier round's fix". At the last fold,
optionally add the count ("in N rounds, the last finding nothing inside an earlier fix").

**R5. Line 64, bull trout cell: "found to 30 % (Cannings and Ptolemy, pers. comm.); 20 % used and passing to 33 %
recognised (WDFW 2019 p. 10-7), where its Chapter 7 says bull trout are 'often found above 30%' (p. 7-4)".**
imprecision. Inside the round-4 fix for N9.
The quote is verbatim, but the cell presents it as WDFW's own statement beside Cannings and Ptolemy's, as two
findings. p. 7-4 reads "bull trout are often found above 30% gradient (Cannings and Ptolemy 1998)", and Cannings and
Ptolemy write "up to 30%" (p. 22; data row 1156, whose note says WDFW cites it for "'often found above 30%
gradient', which it does not say"). Data rows 1163 and 1164 say the same: "for bull trout Chapter 7 gives 'above
30%', resting on a source that says 'up to 30%'". The cell's two clauses share one ancestor, and the second misstates
it.
Fix: "...where its Chapter 7, citing Cannings and Ptolemy, says bull trout are 'often found above 30%' (p. 7-4), more
than they say".

**R6. Lines 13-17: the overrides parenthetical now stands between "access gradient" and the list of classes.**
ok-with-note. Inside the round-4 fix for N1.
"...unless link's overrides lift it (... cutthroat or Dolly Varden): 15 % for chinook, ..." reads as if the colon's list
belonged to the overrides. Round 4 lengthened the clause the colon follows, from six words to about forty.
Fix: give the overrides their own sentence after the classes: "link blocks a species above the first stretch of stream
steeper than its access gradient, read over 100 m: 15 % for ... (link's ...). Its overrides lift a barrier where fish
records or confirmed habitat sit above it, by rules that differ by species: ...".

**R7. Line 46: "lists gradient barriers at 15, 20 and 30 % 'from FPTWG' among its inputs".** ok-with-note. Inside the
round-4 fix for N7.
The README's heading is "Requirements", a list that also holds "Postgresql/PostGIS", "Python >=3.7" and "bcdata". The
gradient-barrier line is the list's one data input after fwapg and bcfishobs, so "inputs" is not wrong, but it is not
the README's word.
Fix (optional): "among its requirements".

**R8. Lines 21-23 ("In short") and README row: the only precedent named for steelhead's 20 % is Washington's.**
ok-with-note. Inside the round-4 fix for N2.
The nearer precedent in the lineage bcfishpass credits (FPTWG models) is BC's own. Mount et al. 2011, Version 1, an
FPTWG model, p. 9: "grades exceeding 20% are considered a barrier for anadramous species (B.C. Ministry of Forests
1998)" (data row 1157; the file's line 33 says so). Naming Washington alone in the summary is true, but it points the
reader across the border for a number that BC's first model had already written down for anadromous fish.
Fix (optional): "...; BC's first model had 20 % for anadromous species after the 1998 guidebook, and Washington's
barrier manual gives steelhead the same 20 %, neither citing a study."

**R9. Lines 76-77: "none is given for sea-run cutthroat, which the table ranks with steelhead".** ok-with-note.
Inside the round-4 fix for N4.
The clause is true of the speeds the paragraph names: Powers and Orsborn's Table 1 (p. 11) lists steelhead, chinook,
coho, sockeye and "Pink & Chum" only, and Bjornn and Reiser give steelhead and coho. But the evidence table holds one
cutthroat burst figure, Bell (1991)'s "upper limit of the burst swim range (~4.12 m/s) for Cutthroat Trout", quoted by
Blank et al. 2020 p. 222 (data row 1184's note), form unstated. That is 13.5 ft/s, below the bottom of steelhead's
burst range (13.7-26.5 ft/s), so the one cutthroat speed held does not put cutthroat with steelhead. Not wrong as
written.
Fix (optional): "...and none is given for sea-run cutthroat, which the table ranks with steelhead (the one cutthroat
burst figure held, Bell 1991's, form unstated, tops out near steelhead's lowest)".

## Outside round 4's fixes

None found. See the reader's pass below.

## Checked and found right

Round-4 changes, word by word:
- Lines 14-15, overrides (N1):
  - "fish records or confirmed habitat above it": `lnk_barrier_overrides()` lifts on observations upstream
    (`fwa_upstream`, 20 m buffer) and on any confirmed spawning or rearing upstream, and `lnk_pipeline_prepare.R`
    passes `habitat = habitat_arg`.
  - "rules that differ by species": thresholds of 1 or 2 records, date floors of 1990 or none, and control on or off,
    by species.
  - "none lift a barrier for cutthroat or Dolly Varden": CT and DV have `observation_threshold` NA, so `threshold <-
    0L` and the observation block never runs. The default bundle's `user_habitat_classification.csv` holds only CH, CM,
    CO, PK, SK, ST and WCT rows, so in `default` nothing at all lifts CT or DV.
- Lines 21-22: "bcfishpass has used 15 % for salmon and 20 % for steelhead and westslope cutthroat since 2020". 0cb2febc
  (2020-12-08) is the first commit with `accessibility_model_*` (`git log -S`): salmon `dnstr_barriers_gradient_15 IS
  NULL`, steelhead `_20`, wct `_20`. The 5b7f8d1b "working model" (2020-11-18) has no per-species classes.
- Lines 23-25: "Rebellato et al. 2024, a Canadian Wildlife Federation report" (p. 1 "Technical Report / Canadian
  Wildlife Federation / February 2024"). "94 to 98 % of BC records of pink, chum, chinook and coho have a maximum
  downstream gradient of 15 % or less" (p. 4: pink "96% of observations had downstream locations with maximum
  gradients of 15% or less", chum "similar (97%)", "98% of Chinook ... and 94% of Coho salmon observations ... had a
  maximum downstream gradient of 15%"; Known Fish Observations in the BC Geographic Warehouse).
- Line 35: "from 2022": `gradient_25` first appears in 79b97e02 (2021-12-17) in `breakpoints.sql` only. Bull trout
  first reads it in ea6645c3 (2022-01-13) `definitebarriers_bt.sql`, and the first `_bt` SQL of any kind is
  ea6645c3. "its first gradient classes, in 2020, were 15, 20 and 30 %, 'from FPTWG'": 254849fc README, verbatim
  "(from FPTWG)".
- Lines 38-39: 20 % for westslope cutthroat in the same first model (`accessibility_model_wct`, ELKR). "Rebellato et al.
  2024 later document steelhead's from Sheer and Steel 2006 and WDFW 2009" (p. 4; data row 359). "Rebellato et al. 2024"
  is introduced once, at line 24, and the parenthesis and second introduction are gone (N6).
- Lines 45-47:
  - "(December 2020)": 0cb2febc.
  - "first README (November 2020)": 254849fc, 2020-11-06.
  - "with no species": that README line names none.
  - "which bcfishpass cites for its salmon habitat thresholds": 620dbe43 `docs/03_model_habitat_linear.md` line 16,
    "Sources for these values for Pacific salmon and steelhead are documented in Table 1 of Rebelatto et al (2024)".
  - Quote style now matches line 36.
- Line 64: "20 % used and passing to 33 % recognised (WDFW 2019 p. 10-7)", against p. 10-7 under Table 10.1: "Resident
  trout and bull trout/Dolly Varden are expected to utilize habitat up 20% ... recognized that they may pass through
  gradients as high as 33% ... (See Chapter 7)". "often found above 30%" is verbatim on p. 7-4. The sentence now
  parses (N9's grammar point).
- Lines 76-77:
  - Burst speeds: steelhead 13.7-26.5, chinook 10.8-22.4, coho 10.6-21.5, sockeye 10.2-20.6, pink and chum 7.7-15.0
    (estimated from 3-4 ft leaps).
  - The table's order: chum 5, pink 12, chinook/coho/sockeye 16, steelhead and sea-run cutthroat 20 (rows 1170-1172,
    1189).
  - "do not separate chum from pink": one "Pink & Chum" row.
  - "the table ranks [sea-run cutthroat] with steelhead": Table 2.1's last two rows, both to 20 %.
- Line 84: "97 % of chum and 96 % of pink with a maximum downstream gradient of 15 % or less" (p. 4; rows 357-358).
- README row: "15 % for salmon and 20 % for steelhead and westslope cutthroat used by bcfishpass since 2020"; "BC
  records of pink, chum, chinook and coho later supporting 15 % (Rebellato et al. 2024)"; "no gradient limit for
  grayling, kokanee or westslope cutthroat" (table rows: "no gradient limit found", "no gradient limit found",
  "nothing found"; data rows 1184-1188). N8's fix is right.

Reader's pass, whole file, outside round 4: link's per-species classes (origin/main: BT, CT, DV, RB 0.25; ST, WCT
0.2; CH, CM, CO, PK, SK, GR, KO 0.15); Version 1's 25 % for every species and its 20 %/25-30 % sources (rows 1156,
1157); Washington 2009's 20 % over 160 m (row 1154); the 1998 guidebook's default, 100 m and no study (row 1158);
Washington's pink and chum limits in Table 9.2 and the 2019 tables (rows 1167, 1169-1172); grayling and kokanee
entering link in 2026 (rows 1186-1187); every table row, including "resident cutthroat/rainbow" (rows 1165-1166:
"'Resident trout' is the manual's resident cutthroat/rainbow trout"), the grayling culvert figures (row 1185: 3 of 40
+ 2 of 21) and westslope cutthroat's 3.55 m/s (row 1184); the Reiser and Peacock leaps; "less strict" over 160 m;
"three times" (15/5); the not-held list; the Specification bullets. Nothing new beyond R1-R9.
