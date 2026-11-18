# Audit r1: meaning of literature_evidence.csv data rows 1154-1188

Read against: WDFW 2009 (pp. 6-1, 9-7), WDFW 2019 (pp. 2-6, 2-7, 2-10, 7-1 to 7-4, 10-6, 10-7, 11-3, 11-4, 12-2;
Tables 2.1, 10.1, 11.1 rendered), Mount et al. 2011 (pp. 9-10), Norris & Mount 2016 (Version 1 passages),
FSIG 1998 (pp. 16, 18, 23, 24), Cannings & Ptolemy 1998 OCR (p. 22, grayling account pp. 46-47),
Powers & Orsborn 1985 (pp. 10-12, 17-18), Bjornn & Reiser 1991 (PDF page 3-4 rendered: printed pp. 86-89),
Blank et al. 2020 (pp. 217-222), MacPhee & Watts 1976 (p. 24), Bell 1986 (text layer, grep only).

20 findings: 4 errors, 9 imprecisions, 7 ok-with-note.

## Errors

**F1. Rows 1163-1166, note: "no source is cited for either."** error.
The sentence the rows quote ends "(See Chapter 7)" (p. 2-7 and p. 10-7: "...as well as fish passage for salmonids
(See Chapter 7)."). Chapter 7, p. 7-4: "e.g., bull trout are often found above 30% gradient (Cannings and Ptolemy
1998) and cutthroat trout have been found in gradients up to 33% (Jauquet 2002), for the purpose of this manual the
20% gradient threshold is used as the upper limit for most adult salmonids." So the 33 % is sourced, through the
cross-reference, to Jauquet 2002 for cutthroat; and for bull trout/Dolly Varden (rows 1163-1164) chapter 7 gives
"above 30%" from Cannings and Ptolemy, not 33 %.
Fix: "The 20 % limit is the manual's own; its 'as high as 33%' points to Chapter 7 (p. 7-4), which attributes 33 % to
cutthroat (Jauquet 2002, data row 1155 for the 2009 edition) and 'above 30%' to bull trout (Cannings and Ptolemy 1998,
data row 1156)." In 1163-1164 say the 33 % is cutthroat's in the source it points to.

**F2. Rows 1165-1166, note: "'Resident trout' is undefined in this edition."** error.
The 2019 edition names the category twice: p. 2-10, Species field: "Species include: Chinook, Chum, Sockeye/Kokanee,
Coho, Pink, Steelhead, Resident Cutthroat/Rainbow Trout, Sea run Cutthroat, Bull/Dolly Varden Trout."; p. 12-2:
"sea run cutthroat trout = 0.037, resident cutthroat/rainbow trout = 0.04."
Fix: "'Resident trout' is the manual's resident cutthroat/rainbow trout (p. 2-10, p. 12-2); the 2009 edition's
Table 9.2 footnote reads 'Includes resident rainbow and cutthroat trout' (p. 9-7)."

**F3. Rows 1181-1182, note: "'computed ... on the basis of darting speeds' (p. 87)."** error.
The sentence ("Reiser and Peacock (1985) computed maximum jumping heights of salmonids on the basis of darting
speeds; these heights ranged from 0.8 m for brown trout to more than 3 m for steelhead (Table 4.2).") is on printed
p. 86 (rendered PDF page 3, left page headed "86 BJORNN AND REISER"; p. 87 holds Figure 4.2 and "Streamflow").
Fix: (p. 86).

**F4. Row 1181, note: "the elided cell is the darting speed."** error.
The quote is "Coho salmon 0-1.04 ... 3.23-6.55 2.2". Table 4.2 (p. 88) columns are Cruising 0-1.04, Sustained
1.04-3.23, Darting 3.23-6.55, Maximum jumping height 2.2. The darting speed is in the quote; the elided cell is the
sustained speed.
Fix: "the elided cell is the sustained speed (1.04-3.23 m/s)."

## Imprecisions

**F5. Row 1154, note: "The 2019 edition keeps the rule (p. 7-2)."** imprecision.
2019 p. 7-2: "Natural barriers that are the upper limit of adult salmonid upstream access are defined as: Gradient - a
stream reach with a sustained gradient of ≥ 20% for ≥ 160 meters without resting areas; Waterfall - a single, near
vertical drop > 3.7 meters in height". It keeps the 20 %/160 m rule (as >= 20 %, without resting areas) and the 3.7 m
fall, but drops the >16 %/160 m narrow-channel clause the note lists in the sentence before.
Fix: "The 2019 edition keeps the 20 % for 160 m rule (as >= 20 %, 'without resting areas') and the 3.7 m fall, and
drops the narrow-channel clause (p. 7-2)."

**F6. Row 1157, kind: expert.** imprecision.
Mount et al. 2011 set 25 % as their GIS model's barrier threshold ("Stream Gradient Segments with slopes greater than
25% were considered barriers", p. 10): a parameter someone chose for a model. Row 114 codes the same threshold from
Norris and Mount 2016 as `param`.
Fix: kind = param. (Optionally cross-reference data row 114 in the note.)

**F7. Rows 1159-1162, unit: percent on a `qual` row with no value.** imprecision.
These four are the only `qual` rows in the table that carry a unit (165 other qual rows leave it blank, e.g. row 115).
Fix: blank unit.

**F8. Rows 1165-1166, life_history_form blank.** imprecision.
The source names the form: "Resident trout ... are expected to utilize habitat up 20%" (p. 10-7), defined as resident
cutthroat/rainbow trout (p. 2-10). The table already codes RB `resident` on 12 rows.
Fix: life_history_form = resident on 1165 and 1166.

**F9. Row 1169, note: "Table 10.1 (p. 10-7) draws chum using 0-3 % and passing 3-5 %."** imprecision.
The quoted sentence itself points to a third copy: p. 11-3 "...do not include chum in upstream reaches (see Table
11.1)". Table 11.1 (p. 11-4, rendered) draws the same chum cells. And "Rebellato et al. 2024's rows" names no row: the
chum row is data row 357.
Fix: "Table 11.1 (p. 11-4), to which the sentence points, draws chum using 0-3 % and passing 3-5 %, as Tables 2.1 and
10.1 do. BC's class for chum is 15 % (Rebellato et al. 2024, data row 357)."

**F10. Rows 1170-1172, note: "repeated as Table 10.1 on p. 10-7 ... The 2009 edition's Table 9.2 (p. 9-7) draws the
same limits."** imprecision.
(a) The table is repeated a third time as Table 11.1 (p. 11-4), cells identical (rendered). (b) 2009 Table 9.2 has
strata 0-1 to 16-20 only, no 20+ column, and shades use/hatches passability rather than green/crossed yellow; it also
adds "Bull Trout" ("Includes resident and anadromous bull trout/Dolly Varden") and "Trout" rows shaded as used to 20 %.
Its chum 5, pink 12, coho/sockeye/chinook 16 and steelhead/searun 20 % match, but "every species blank at 20+" cannot
be drawn from it.
Fix: "(repeated as Table 10.1, p. 10-7, and Table 11.1, p. 11-4)"; "The 2009 edition's Table 9.2 (p. 9-7), whose
strata stop at 16-20 %, draws the same limits for these seven, and has bull trout and resident trout using every
stratum to 20 %."

**F11. Rows 1183-1184, metric: burst.** imprecision.
Blank et al. never name a speed class: "We also observed the maximum short-duration swim speed of the fish" (p. 217);
"The maximum observed swim speed within an 0.6-m flume segment, vf,ij" (p. 222). They contrast it with Bell's burst
range ("it is less than the upper limit of the burst swim range (~4.12 m/s) for Cutthroat Trout reported by Bell
(1991)", p. 222) without calling their own value burst. By the vocabulary, a speed whose class the source does not
state is `unstated`.
Fix: metric = unstated, note "the maximum speed over a 0.6 m flume segment, which the authors call short-duration and
set beside Bell's burst range (p. 222)"; or keep burst and say in the note it is our reading.

**F12. Row 1183, value 2.72 without the paper's other figure.** imprecision.
The abstract (p. 217) prints 2.72 m/s; Results (p. 222: "vf,ij, was 2.73 m/s for Rainbow Trout") and Discussion
(p. 222: "the maximum observed swim speed in this study (2.73 m/s)"; "velocities <2.73 m/s for Rainbow Trout") print
2.73. The row quotes the abstract and is silent on the discrepancy.
Fix: add to the note "Results and Discussion print 2.73 m/s (p. 222)." (Value may stay 2.72 since it is what the
quote states.)

**F13. Row 1185, note.** imprecision.
The note says only that 1.5 m/s stopped every fish under 300 mm. The same paragraph (p. 24) continues: "For longer
fish (301-340 mm) 1.5 m/s blocked the upstream migration of all but 3 out of 40 fish (4-7 C), and 2 out of 21 fish
(9-10 C)." The result is from 1-day tests (Table 10, 1974 migrants). As written, a reader may take 1.5 m/s as a
size-specific bound rather than a velocity that also blocked about 92 % of the largest fish tested.
Fix: append "Of longer fish (301-340 mm), 3 of 40 (4-7 C) and 2 of 21 (9-10 C) passed (p. 24); 1-day tests (Table 10)."

## Ok-with-note

**F14. Row 1188 (WCT none), note.** ok-with-note.
The search claim holds (no listed source names westslope cutthroat with a gradient limit), but the note names only
WDFW 2019 and Blank et al. Several listed sources give cutthroat, unqualified, a gradient statement: Mount et al. 2011
"Bull Trout and Dolly Varden/Cutthroat ... 25-30%" (p. 9, row 1157); FSIG "cutthroat trout ... well in excess of 20%"
(p. 24, row 1159); WDFW 2009 "cutthroat trout have been found in gradients up to 33% (Jauquet 2002)" (p. 6-1, row 1155,
coastal cutthroat); WDFW 2009 Table 9.2 "Trout ... resident rainbow and cutthroat trout" used to 20 % (p. 9-7).
Fix: add "Cutthroat statements that do not name the subspecies: data rows 1155, 1157, 1159, 1166."

**F15. Row 1187 (KO none), note.** ok-with-note.
WDFW lumps the two: "Sockeye/Kokanee" in its species field (2019 p. 2-10) and production values ("sockeye/kokanee
salmon = 3.00", p. 12-2). Table 2.1's sockeye row is in a table of "anadromous salmonid utilization", so the none claim
holds, but a reader could take WDFW's sockeye 16 % (rows 1167) as kokanee's.
Fix: add "WDFW lumps sockeye/kokanee in its species codes (2019 p. 2-10) but its gradient table is for anadromous
species; its sockeye 16 % (data row 1167) is not stated for kokanee."

**F16. Rows 1179-1180, cited_source: Bell (1973).** ok-with-note.
Table 1 is titled "Fish speeds ... as reported by Bell (1973)" (p. 11); footnote a ("Pink & Chum salmon values
estimated from leap heights of 3 to 4 ft at waterfalls") does not say whether the estimate is Bell's or Powers and
Orsborn's. Bell 1986 (held) does not print it in its text layer. Attribution to Bell is a reading of the title.
Fix: note "footnote a is not attributed; the table's title credits Bell (1973)."

**F17. Rows 1173-1178, note: "burst is 'activities which cause fatigue in 15 seconds or less' (p. 10)".** ok-with-note.
True, but that class is Hoar and Randall's (1978), which Powers and Orsborn adopt ("The classification of speeds
published by Hoar and Randall (1978) which will be used in this study", p. 10); footnote b says Bell's columns were
"cruising and sustained" (Bell's own third class is darting, Bell 1986 text). Optional: name Hoar and Randall.

**F18. WDFW 2019 Table 2.1 sea-run cutthroat not coded.** ok-with-note (coverage, not meaning).
Table 2.1/10.1/11.1 draw "Sea Run Cutthroat" passing 12-20 % (limit 20 %), and the notes of rows 1170-1172 quote it,
but no row codes it; row 1166 (CT, 20 %) is resident trout from the text paragraph. Steelhead (1168), sockeye (1167)
and chum (1169) are coded from the text instead. Consider an anadromous CT row from Table 2.1.

**F19. Rows 1173-1182, region: Pacific Northwest.** ok-with-note.
Neither Bell's speeds nor Reiser and Peacock's computed heights are tied to a region in Powers and Orsborn (pp. 10-11)
or Bjornn and Reiser (pp. 86-88); "Pacific Northwest" describes the reports' audience (BPA; western North America),
not where the numbers were measured. Acceptable if that is the table's convention for compiled design values.

**F20. Claims not checkable against the listed sources.** ok-with-note.
Row 1154 "where bcfishpass reads 100 m"; row 1186 "it entered link's config with the salmon class"; row 1187 "BC's
15 % rides the salmon class" and "Lauritzen et al. 2010 ... has no CrossRef abstract"; row 1188 "bcfishpass's 20 % is
uncited"; rows 1186-1188 "a sweep of about 50 passage sources (#234)". These are statements about our tooling or our
search, not about the cited source; not verified here.

## Checked and found right (every field)

- 1155 (CT 33 %, WDFW 2009 p. 6-1, max_obs, cited Jauquet 2002; reference list confirms coastal cutthroat, South
  Puget Sound thesis).
- 1156 (BT 30 %, Cannings & Ptolemy p. 22, P. Bech pers. comm.; no DV/cutthroat gradient in the book; WDFW 2009 p. 6-1
  and 2019 p. 7-4 both say "often found above 30%").
- 1158 (FISH 20 %, FSIG p. 23; 100 m representative length p. 16; no study cited; p. 24 statement correct).
- 1160, 1161, 1162 and 1159: every field right except unit (F7).
- 1163, 1164: right except the note (F1).
- 1167 (SK 16 %, p. 10-6; 160 m sentence same page; Table 10.1 draws SK passing 7-16 %).
- 1168 (ST 20 %, p. 10-6; elided "12-20%" correct).
- 1169: value, page (11-3), kind right; note F9.
- 1170, 1171, 1172: values read from rendered Table 2.1 (CH 16, CO 16, PK 12) right; page 2-7 right; note F10.
- 1173-1178: Table 1 burst column values (ST 13.7-26.5, CH 10.8-22.4, CO 10.6-21.5, SK 10.2-20.6, PK/CM 7.7-15.0
  fps), page 11, unit ft/s, metric burst, footnote a and "5 to 10 seconds" (p. 18, Bell 1973) all right.
- 1179, 1180: 3-4 ft range, page 11 right (F16 only).
- 1181, 1182: values (CO 2.2 m, ST 3.4 m) and page 88 right against the rendered table; chinook 2.4 and sockeye 2.1
  confirmed; steelhead darting OCR remark right. Notes F3, F4.
- 1184 (WCT 3.55 m/s, p. 217; Results p. 222 also 3.55): right except metric (F11).
- 1186 (GR none): claim holds in WDFW 2009/2019 (no grayling gradient), Mount, FSIG (grayling named, no gradient),
  Cannings & Ptolemy grayling account (no gradient), Powers & Orsborn, Bjornn & Reiser, Bell 1986 (grayling swimming
  speeds charted, no gradient); MacPhee & Watts velocities only.
- Restatement check: none of the 35 rows restates an earlier row of the same citation_key. Only Bjornn & Reiser
  1991 has earlier rows (54, 141-143, 162, 629-636, 687-719, 900, 951); none is from Table 4.2 or p. 86. Row 1157
  (Mount 2011) and row 114 (Norris & Mount 2016) state the same 25 % from different works; not a duplicate.
