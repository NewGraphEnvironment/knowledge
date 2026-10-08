# Draft notes: `tc` family (BT, GR, WCT; RB and CT extras), #44

`draft-tc-evidence.csv` holds 134 rows: 119 valued or qualitative, 15 `none`. Row numbers below are
draft rows (data row 686 + N once merged first). All 134 pass `0280` on the merged table
(`verified_text` 47, `verified_ocr` 42, `verified_table` 30, `none_row` 15), and every BT, GR and
WCT cell is filled in the printed `flow:` grid.

## Grid by species and cell

### BT

| cell | rows filling it | other rows |
|---|---|---|
| instream_flow spawning | `none` (120) | |
| instream_flow incubation | `none` (121) | `qual` 11 (McPhail & Baxter p. 21: sufficient winter flows prevent redds freezing) |
| instream_flow rearing | 28 (Hatfield 2002 Nechako chart, 55 % MAD, adult and juvenile) | |
| instream_flow overwintering | `none` (122) | |
| instream_flow migration | 27 (Nechako chart, adult passage 40-80 % MAD) | |
| depth spawning | 1 (24-58 cm, Hagen & Weber), 6 (min 10 cm, McPhail & Baxter), 12 (30-60 cm, Roberge), 20 (WA HSC zero edge 0.15 ft) | 2 (max 90 cm), 7, 9 (means), 15 and 21 (optima) |
| depth migration | `none` (123) | |
| velocity spawning | existing 497/498, plus 13 (max 0.7 m/s, Roberge), 16 (0.25-0.64 m/s, Ford), 23 (WA HSC 5.00 ft/s) | 8 (mean), 22 (optimum) |
| velocity rearing | 4, 10, 17, 18 (max), 19 (0-0.12 m/s), 25 (WA HSC 3.55 ft/s) | 3, 5, 14, 24 (optima); 26 (Bjornn & Reiser Table 4.10, 9 cm/s, no bound) |

### GR

| cell | rows filling it | other rows |
|---|---|---|
| instream_flow, all five stages | `none` (124-128) | 38: flows during an observed adult migration, Martin Creek (10-15 m3/s, `dist`, no bound) |
| depth spawning | 31 (0.15-0.45 m, Stewart), 41 (0.5-3.0 ft, Hubert), 42 (Hubert SI zero edge 0.4 ft) | 30 (max 1.0 m), 43 (optimum from 1.0 ft) |
| depth migration | 50 (Hubert, 0.4 ft minimal suitable depth), 51 (Fig. 5 zero edge 0.3 ft) | |
| velocity spawning | 29 (max 150 cm/s), 32, 33, 39, 40 (ranges), 46 (Hubert SI max 4.0 ft/s) | 44 (SI min 0.5 ft/s), 45 (optimum) |
| velocity rearing | 34 (max 80 cm/s), 36 (15-25 cm/s), 37 (fry found to 0.80 m/s), 48 (Hubert fry SI zero 0.6 ft/s), 52 (Ford, fry <0.8 m/s) | 35, 47, 49 (optima) |

### WCT

| cell | rows filling it | other rows |
|---|---|---|
| instream_flow, all five stages | `none` (129-133) | |
| depth spawning | 53 (0.2-0.40 m, 2004 account), 56 (0.10-0.75 m, DFO 2019 critical habitat, Alberta), 60 (Flathead means 17-20 cm) | |
| depth migration | `none` (134) | |
| velocity spawning | 54 (0.25-1.05 m/s), 57 (0.25-0.8 m/s, DFO 2019), 61 (means 30-36.7 cm/s) | |
| velocity rearing | 55 (fry <1 cm/s), 58, 59 (DFO 2019), 62 (Griffith fry 7-10 cm/s), 63 (age 1+-2+ max 22 cm/s) | 64 (optimum 10-12.5 cm/s) |

### CT and RB (extras, no grid cells)

- CT (65-78): Levy & Slaney Table 6 (Hunter 1973 criteria), Ford's cutthroat statements (Reiser & Bjornn
  1979; Hickman & Raleigh 1982), Beecher & Caldwell cutthroat spawning and juvenile curves, Bjornn & Reiser
  Table 4.10 (Thompson 1972). Ford's cutthroat text sits in the westslope chapter but cites generic-cutthroat
  sources, so it is coded `CT`; Ford's Table 4 restates the same numbers for westslope cutthroat and was not
  coded twice (notes on 67 and 70 say so).
- RB (79-119): Levy & Slaney Table 6 (Smith 1973); Ford's rainbow chapter (Raleigh et al. 1984, Gerrard
  stock, fry and juvenile velocities, the base-flow guideline as `percent MAD`); Beecher & Caldwell resident
  rainbow spawning curves and the O. mykiss juvenile curve (steelhead and resident pooled; the `ps` drafter may
  code the same curve as `ST`); Hatfield 2002 Nechako and Sinmax periodicity charts; AMEC 2015 Davidson Creek
  Table 14 (flow producing maximum habitat as `hsi` optimum, recommended IFN as `expert` min) and the 10 cm
  spawning depth.

## Searched with nothing to code

- BT spawning, incubation and overwintering flow: McPhail & Baxter, Hagen & Weber, Hagen et al. 2015 and
  2020, Roberge, Ford (OCR), Hatfield 2002 (Nechako lists bull trout spawning and incubation as "N/A"; Sinmax
  lists bull trout stages with no values), Ptolemy & Lewis 2002, and the flow ragnar store.
- GR and WCT flow needs: none of the species sources gives a value. Stewart et al. 2007 and Hagen & Stamford
  2023 discuss low flows and stranding qualitatively; the 2019 WCT recovery strategy lists reduced late-summer
  and winter flows and withdrawals as threats.
- Keeley & Slaney 1996 hold bull trout, cutthroat and rainbow depth/velocity data only in pooled regressions
  and figures. Neuman & Newcombe 1977 appendix tables (rotated) are unreadable in the OCR. Lewis et al. 2004
  and Hatfield 2002 Table 7 rainbow criteria (20 % rearing, 45 % spawning, 50 % adult migration, 40 % adult
  rearing) are a worked example, not a standard, so not coded.

## Things the table cannot hold, or I left out on purpose

- Stream size, not need: Hagen et al. 2015 calibration sites spanned 0.12-2.9 m3/s at survey (PDF page 38);
  Stuart & Chislett give Sukunka and Martin Creek discharges by month. Not coded.
- Adult habitat (no adult stage in the vocabulary): Stewart p. 20 adults prefer 61-108 cm/s and 110-152 cm,
  occur at 0-130 cm/s and 23-91 cm (Evans et al. 2002); Hagen & Stamford 2023: preferred adult grayling depth
  1.36 m and 0.36 m/s (Blackman 2004); Ford Table 8 adult bull trout and Table 4 adult cutthroat values;
  Hatfield's rainbow adult rearing standards (Nechako 55 % MAD, Sinmax 50 % "Binns model"). Hubert: adults
  0.9 ft/s mean occupied.
- Rearing and overwintering depth are not grid cells and were not coded (e.g. Hagen & Weber fry 10-18 cm,
  older juveniles 20-45 cm; Beecher juvenile depth curves; Hubert fry depth curve 0.2-3.0 ft, overwinter
  pools >4.5 ft; Hubert overwintering velocity <0.15 m/s; Beecher resident rainbow winter curves).
- GR passage velocities (not a grid cell): Stewart p. 29 culvert passage (blocked at 370 cm/s, 70 % passed at
  225 cm/s, 95 % at 213 cm/s; Tilsworth and Travis 1987) and Dryden and Stein's 91 cm/s culvert criterion;
  Cutting et al. 2018 (culvert passage below 2.1 m/s; dams with scour pools <65 cm as breach priorities).
- Generic "trout" (no species code): Bjornn & Reiser / Levy & Slaney Table 4.1 (Thompson 1972) passage
  criteria for "trout" 0.12 m depth, 1.22 m/s and "large trout" 0.18 m, 2.44 m/s; Bjornn & Reiser "smaller
  trout 6-10 cm" spawning depth; Ptolemy & Lewis Binns (1982) rating for "large resident trout" (CSFP >55 %
  MAD best, <10 % worst). The `ps` drafter holds group codes; none of these is FISH, SALMON or SALMONIDS.
- Not quotable: McPhail & Baxter p. 5 spawning velocity "0.030.8 m-s" (the text layer fuses 0.03-0.8 into
  one token) and p. 12 Sexauer (1994) "<0.\n15m-s" (a number broken across lines); Bjornn & Reiser Table 4.5
  rainbow and cutthroat rows are garbled in the OCR (taken from Levy & Slaney's clean reproduction instead);
  Ford Table 10 bull trout redd depth/velocity by stream is jumbled in the OCR; Hubert Fig. 4 juvenile/adult
  curves are unreadable; Stewart Fig. 4 prints spawning velocity "<1.5 cm/s" (evidently m/s), not coded.
- Not duplicated: Roberge p. 80 spawning velocity 0.14-0.52 m/s (row 497 already notes it); Ford p. 169 and
  Table 12 grayling spawning velocity 0.3-1.5 m/s (same Krueger 1981 source as row 39); Hubert p. 5 fry
  0.8 m/s (secondary of Stuart & Chislett, row 37); Ford Table 8 bull trout spawning velocity 0.25-0.65 m/s
  (same McPhail & Murray data as row 16); the 2004 WCT account's 22 cm/s (repeats Ford, row 63).

## Unsure

- Row 6 codes McPhail & Baxter's "from less than 10 cm to over 1.0 m" as a `min` of 10 cm. Some redds were
  shallower, so it is the shallow end as written, not a floor; the note says so. Drop it if that reads as a
  lower limit it is not.
- Roberge p. 80 says velocities "> 0.23 m/s and 0.31 m/s are not preferred" by young-of-the-year and
  juveniles without saying which goes with which; no row drawn from it.
- Rows 17/18 (Ford: juveniles in runs <0.5 m/s) and McPhail & Baxter p. 11 (30 % of juveniles in runs
  >50 cm/s by August) report McPhail and Murray (1979) differently. Both notes say so.
- Row 55 (WCT fry <1 cm/s): the 2004 account attributes it to westslope cutthroat via Ford, but Ford traces it
  to Moore and Gregory (1988b) in Cascade Mountains streams, which may not be westslope cutthroat.
- Row 63 (WCT age 1+-2+ max 22 cm/s): Ford names no source for the sentence; it follows Griffith (1972).
- Row 15 (Ford Table 8 "preferred spawning depth") is coded `optimum` as labelled, though the span looks like
  observed redd depths.
- Row 38 (GR migration flows 10-15 m3/s) is flows at which adults were seen migrating, not a need, so it has
  no bound and fills nothing.
- Hatfield 2002 chart rows carry `metric = unstated`; the charts give "Flow Standard (%mad)" with no
  statistic. Months could not be read reliably from the chart layout, so notes name none.

## Gate defect hit while checking (not worked around in the gate)

`0280`'s `table_pages()` errors out (`NA/NaN argument` at `(at + 1):min(...)`) when a table quote's first token
equals the last token of a document's layout stream, because the window `(at + 1):...` runs past the end and
returns an `NA` index that becomes `at`. The AMEC 2015 appendix ends with "Page 1", so any table quote starting
"1 ..." (e.g. "1 July – 31 August ...") kills the whole run. My AMEC quotes start at "July"/"December" instead.
The `ps` drafter quoting AMEC Table 14/15 rows that start with "1 ..." will hit the same crash. This is for the
caller to fix or file; I did not edit `0280`.

`precheck.py` in the scratchpad (`tc/`) approximates the gate for fast iteration; it does not read number
words, so it flags row 119 ("ten centimetres"), which the gate verifies.
