# Draft notes: ps family (CH, CO, SK, ST and every group-code row), #44 Phase 4

`draft-ps-evidence.csv` holds 191 rows (185 cited, 6 `none`). Merged after data row 686 and run through
`0280`, they are data rows 687-877, and every one passes: 99 `verified_text`, 47 `verified_table`,
39 `verified_ocr` and 6 `none_row`, with no failure anywhere in the merged table. Every CH, CO, SK and ST
cell appears in the `flow:` grid, so the only cells still empty are the trout-and-char family's (BT, GR, WCT).
Log: scratch `merge-ps/verify.csv`.

Searched: all 35 items of the `Fisheries/flow` collection, by grep of the extracted text (`txt/`, OCR for the
five scans) and by queries to `data/rag/flow.duckdb`. Wherever the extracted text was ambiguous I checked
the table on a rendered page (Bjornn & Reiser Tables 4.1, 4.5 and 4.10, p. 89; Raleigh et al. pp. 5, 7, 10;
MacIsaac p. 472).

## Per species and cell

"Fills" means the row meets the cell under `0280`'s rules. Extras (a velocity minimum, a depth maximum,
migration velocity, overwintering velocity) are listed where they matter.

### CH (chinook)

| cell | rows | where |
|---|---|---|
| instream_flow spawning | 4 | Hatfield 2002 Table 7 example (45 % MAD) and Appendix A Nechako (22 %); USFWS 2007 Clear Creek WUA peak 650 cfs (Canyon) and recommendation >600 cfs |
| instream_flow incubation | 2 | Hatfield 2002 Table 7 (20 %), Appendix A Nechako (20 %) |
| instream_flow rearing | 5 | Hatfield 2002 Table 7, Nechako (20 %); Warkentin 2022 Nicola: 10.6 m3/s, 36 % MAD, 17.2 m3/s (mean August) |
| instream_flow overwintering | 1 | Hatfield 2002 Appendix A Nechako (20 %) |
| instream_flow migration | 1 | Hatfield 2002 Table 7 example (100 % MAD). Thin: a worked example for a 5.8 m3/s stream |
| depth spawning | 15 (+2 optima) | Bjornn & Reiser Table 4.5 (summer >=30 cm), Nechako redds (>=0.45 m; pit depths 0.46-1.20 m); Levy & Slaney (fall, spring >=24 cm); Raleigh Figs 5, 10, 11, 12, 13; Beecher & Caldwell Figs 1a (two curves), 2a; Roberge (Dauble 4.0-8.1 m); USFWS 2007 |
| depth migration | 4 | Bjornn & Reiser Table 4.1 (fall, spring and summer chinook 0.24 m); Ptolemy & Lewis 30 cm (see uncertainties) |
| velocity spawning | 18 (+3 optima) | Bjornn & Reiser Table 4.5, Nechako; Raleigh Figs 5, 8-13 and text (0.2-1.15 m/s, Andrew & Geen spring and fall); Beecher & Caldwell 1b (two curves), 2b; USFWS 2007 |
| velocity rearing | 17 (+3 optima) | Bjornn & Reiser Table 4.10 (5 rows); Raleigh Figs 6, 7, 14-19 and text (0-60 cm/s); Beecher & Caldwell 3b; Roberge (<0.15 m/s); MacIsaac (0.25 m/s, fry displacement in troughs) |

### CO (coho)

| cell | rows | where |
|---|---|---|
| instream_flow spawning, incubation, rearing, overwintering | `none` x 4 | see "Empty cells" |
| instream_flow migration | 1 | Gottesfeld & Rabnett p. 7: average September flow <1 m3/s impairs coho and sockeye reaching spawning areas |
| depth spawning | 2 | Levy & Slaney Table 6 (>=18 cm); Beecher & Caldwell 4a (0.15 ft) |
| depth migration | 1 | Bjornn & Reiser Table 4.1 (0.18 m) |
| velocity spawning | 2 | Bjornn & Reiser Table 4.5 (30-91 cm/s); Beecher & Caldwell 4b (max 5.0 ft/s) |
| velocity rearing | 4 (+2 optima) | Bjornn & Reiser Table 4.10 (3); Roberge (Bravender & Shirvell 0.0-0.78 m/s); optima: Murphy <0.3 m/s, Neuman & Newcombe 0.7 ft/s |

Extras: Bjornn & Reiser migration velocity 2.44 m/s; Roberge overwintering velocity <0.3 m/s.

### SK (sockeye)

| cell | rows | where |
|---|---|---|
| instream_flow spawning, incubation | `none` x 2 | see "Empty cells" |
| instream_flow migration | 1 | Gottesfeld & Rabnett p. 7 (as coho) |
| depth spawning | 2 | Levy & Slaney Table 6 (>=15 cm, estimated from other species); Beecher & Caldwell 7a (0.15 ft) |
| depth migration | 1 | Levy & Slaney Table 2 (0.18 m) |
| velocity spawning | 2 | Bjornn & Reiser Table 4.5 (21-101 cm/s, estimated from other species); Beecher & Caldwell 7b |

Extras: Bjornn & Reiser migration velocity 2.13 m/s; Roberge spawning depth <1 m (an upper bound).
No source gave a rearing or overwintering flow need or a rearing velocity for SK, and those cells are not
on the grid.

### ST (steelhead)

| cell | rows | where |
|---|---|---|
| instream_flow spawning | 5 | Hatfield 2002 Appendix A Ash (45 %) and Cheakamus (34 %); USFWS 2007 WUA peaks 350 and 600 cfs, and 200 cfs (>91 % of maximum WUA) |
| instream_flow incubation | 2 | Ash, Cheakamus (20 %) |
| instream_flow rearing | 11 | Ash, Cheakamus (20 %); Ptolemy & Lewis meta-analysis and PHABSIM optima (Ash 12 % fry, 29 % parr, 4.0 and 9.0 m3/s; Little Qualicum 48 %; Carnation 0.19 and 1.06 m3/s, 128 %); Hatfield 2002 Salmon River least-risk flow 5.5 m3/s |
| instream_flow overwintering | 2 | Ash, Cheakamus (20 %) |
| instream_flow migration | 4 | Hatfield 2002 Table 5 summer steelhead passage 50-100 %; Ash winter passage 45 %, summer passage 50-100 %; Cheakamus 34 % |
| depth spawning | 4 (+1 optimum) | Levy & Slaney Table 6 (>=24 cm); Beecher & Caldwell 8a; Roberge (0.2-1.5 m); USFWS 2007 (0.4-28.5 ft) |
| depth migration | 1 | Levy & Slaney Table 2 (0.18 m) |
| velocity spawning | 4 (+1 optimum) | Bjornn & Reiser Table 4.5 (40-91 cm/s); Beecher & Caldwell 8b; Roberge (0.6-0.8 m/s); USFWS 2007 |
| velocity rearing | 4 | Bjornn & Reiser Table 4.10 (Sheppard & Johnson <25 cm/s; Stuehrenberg 3-26); Beecher & Caldwell 9b; Roberge Table 57 (<0.15 m/s, see uncertainties) |

Extra: Bjornn & Reiser migration velocity 2.44 m/s.

### Group-code rows (fill no cell)

- **FISH (29):** Tennant 1976 Table 1, both seasons (12 rows), plus "Ten percent ... minimum instantaneous
  flow"; Hatfield 2002 Table 5 (rearing, overwintering, incubation 20 %; migration and spawning 30-200 %;
  spawning equation as `qual`; the 55 % linear stand-in); Ptolemy & Lewis (10 % severe threshold, confined-
  channel optimum 10 %, 20 % standard for rearing and overwintering); Hatfield 2003 (90th percentile of mean
  daily flow in the lowest-flow month); DFO 2013 (30 % MAD instantaneous); Neuman & Newcombe (Okanagan
  modification of the Montana method, 15 % October-March and 30 % April-September).
- **SALMONIDS (14):** Raleigh et al. p. 5 base flow (>=50 % excellent, <25 % poor); Ptolemy & Lewis spawning
  and migration 30-200 % ("applies to large trout and Pacific salmon") plus its equation as `qual`, and passage
  depth 24 cm for "larger fish"; Bjornn & Reiser (Thompson's spawning-bar criteria of 18 cm and 0.3-3.0 m/s;
  fry <10 cm/s and 4-18 cm fish up to about 40 cm/s); Neuman & Newcombe (Oregon Game Commission riffle 1.0-1.5
  and pool 0.3-0.8 ft/s); Keeley & Slaney (spawning >10 cm deep and >10 cm/s).
- **SALMON (4):** Levy & Slaney (DFO guideline of 1.0 m/s as the largest velocity suitable for upstream
  migration); Raleigh et al. (Divinin: no spawning shallower than 0.2 m); Neuman & Newcombe (salmon spawn at
  up to 7 m).
- The existing Gottesfeld `SALMON` migration row (data row 121) is not duplicated. The coho and sockeye rows
  come from the next paragraph, on p. 7.
- No group statement on flow needs was found in the trout-and-char sources (grep for % MAD, mean annual
  discharge, instream flow and minimum flow across all of them).

One CM row: Raleigh et al. Figure 2. Its passage depth curve (zero at 9.1 cm) is Sautner et al.'s (1984)
chum salmon criteria from the Susitna River, which Raleigh adopts for chinook (p. 51). It is coded with the
species it was measured on, so it fills no chinook cell.

## Empty cells

Six cells hold `none`: CO spawning, incubation, rearing and overwintering instream_flow, and SK spawning and
incubation instream_flow. What came closest:
- Hatfield 2002 Appendix A charts coho (Ash, Cheakamus, Sinmax) and sockeye (Nechako, Sinmax) timing but gives
  them no flow standard. The flow-standard column is blank for those rows.
- Beecher & Caldwell 2022 (p. 55) withdrew the Washington coho rearing curves because peak modelled habitat did
  not track coho production (Beecher et al. 2010).
- Ptolemy & Lewis (p. 15) give Carnation Creek coho rearing flows of about 1-20 % MAD and the 0.8 % MAD low
  of 1994 as observations, not as a need.
- Northwest Hydraulic Consultants 1993, in its recommendations: "Instream flow needs for fish ... have not been
  established for the salmon streams." It mentions a Mitchell River structure for sockeye incubation flows but
  gives no value.
- Gottesfeld & Rabnett: "Bulkley River and Maxan Creek often do not have sufficient flow to allow sockeye
  passage" (no value).

## What the table cannot hold, or I left out

- **Smolt (downstream juvenile) migration flows.** Hatfield 2002 Table 7 has chinook juvenile migration at
  45 %. Appendix A has Nechako chinook smolt outmigration at 50 %, Ash steelhead smolt passage at 45 % and
  Cheakamus at 34 %. Table 5 has smolt migration at 50 %. `migration` means adult upstream passage, so none of
  these is written.
- **Other activities in Appendix A:** Nechako chinook "wetland/side-channel refuge" at 100 % (April-June),
  and resident rainbow, white sturgeon and bull trout rows.
- **Adult holding:** Raleigh et al. Figure 3 (Burger et al. 1982, Kenai River) is migration-holding depth and
  velocity. Holding is not `rearing`, so it is not written.
- **Adult steelhead 51 % MAD** (Ptolemy & Lewis p. 26, Ash River meta-analysis optimum for adults) is not a
  rearing need.
- **Rearing depths** are not a grid cell, so I did not draw the fry and juvenile depth curves (Raleigh Figs
  6, 7, 14, 16, 17, 19; Beecher & Caldwell 3a, 9a), the Table 4.10 depth cells, or Woelfle-Erskine et al.'s
  coho over-summer pool-depth threshold (higher survival in pools >0.48 m deep). Depth maxima were also left
  out (Beecher 1a, large-river curve back to 0 at 10 ft; Roberge chinook <1.5 m and 5.0 m, Chapman 1943).
- **Means with no bound:** Bjornn & Reiser Table 4.10 means (Hanson; Moyle & Baltz; coho focal points of 13-14
  cm/s); Raleigh (Smith 1973: 0.43 and 0.50 m/s); Keeley & Slaney rearing means and ranges of study means
  (17.5 cm/s, 3.0-48.8 cm/s).
- **Equations:** two are written as `qual` rows: Hatfield 2002 (1.56 x MAD^0.63) and Ptolemy & Lewis, printed
  "148*{MAD)-036" with the exponent garbled; their Figure 15 fit is y = 144.95x^-0.3509. Keeley & Slaney's
  depth and velocity regressions on fish length are not written.
- **Values a source gives only as a word:** Tennant's "Thirty percent" (good survival) and "Sixty percent"
  (excellent to outstanding). The gate reads number words only up to ten, but Table 1 carries both levels.
- **Hatfield 2003, highest-flow month at the 20th percentile.** A month with no life stage, so it is in the
  note of the 90th-percentile row rather than a row of its own.
- **Restatements not repeated:** Hatfield 2003 Table 7 repeats Hatfield 2002 Table 5 word for word, so
  it is not written again. Ptolemy & Lewis's 20 % and 30-200 % standards are written, and their notes say they
  are the same standard. Neuman & Newcombe's list of the Montana method (10 / 30 / 60 %) is a secondary
  citation of Tennant, whose own paper is written instead. The Okanagan variant's 10 % short-term flow repeats
  Tennant.
- **Baxter (1961):** "salmon needed 30-50 % of the average annual flow for passage ... up to 70 % for passage
  up headwater streams" (Bjornn & Reiser p. 87). The fish are Atlantic salmon in Scottish rivers, which is not
  Pacific `SALMON`, so this is not written. Sautner et al. (1984) chum passage depths (0.12 and 0.09 m) are left
  for whoever writes CM.
- **Kosakoski & Hamilton (1982)**, cited by Warkentin: 19 % MAD and 5.66 m3/s year-round for the Nicola. Only
  their failure to reach replacement is noted.
- **Washington toe-width method** (Hatfield 2002, Ptolemy & Lewis): a power function of toe width, with no
  tabulated values.
- **Neuman & Newcombe** appendix tables of depth and velocity at redds by species: the scan is rotated and the
  OCR is unreadable (Appendix 3, depth and velocity requirements for spawning salmonids). No values could be quoted.
- **USFWS 2007, other items:** the introduction's flow recommendations (200 cfs October-June, 150 cfs
  July-September; USFWS 2001); the alternative chinook depth criteria from the sensitivity analysis; the Upper
  Alluvial chinook WUA, still rising at the top of the modelled range (900 cfs).

## Stream-size thresholds (`discharge`, not written)

- Beecher & Caldwell choose a chinook curve by mean annual flow: large rivers when MAF >3,000 cfs,
  Columbia-Snake when MAF >100,000 cfs.
- Ptolemy & Lewis (p. 27): the Washington toe-width method supports 20 % MAD for streams with MAD <141 cms.
- Hatfield 2003: maximum diversion at the 80th percentile of daily flow (a diversion rule, not a size threshold).
- Bankfull or mean channel depths were not met in my sources, so no `m bankfull` rows.

## Left to the trout-and-char draft (RB)

- Beecher & Caldwell Figure 9b combines steelhead and resident rainbow juveniles.
- USFWS 2007 HSC and WUA are for "steelhead/rainbow trout" together.
- I wrote these as ST with the pooling in the note. Each also holds for RB, which belongs to the other draft.
  If that draft does not take them, RB rows from the same quotes are needed.
- AMEC 2015 has rainbow trout and kokanee only.
- Ford et al. 1995 has resident rainbow and kokanee only; it holds no anadromous salmon section.

## How Bjornn & Reiser and Levy & Slaney are split

The Bjornn & Reiser scan's OCR garbles every ">=" depth in Table 4.5 ("224", "als", "zlS", "zd") and several
cells of Table 4.1 ("O18", "244"). Levy & Slaney 1993 Tables 2 and 6 reproduce both tables in a text layer.
- The original is cited wherever its OCR quote carries the value.
- Levy & Slaney is cited only for the cells the OCR loses: chinook (fall and spring), coho, sockeye and
  steelhead spawning depths; sockeye and steelhead passage depths.
- No value is therefore counted twice. Both notes name the reproduction.

## Unsure

- **Ptolemy & Lewis p. 27, "summer Chinook at 30 cm" as a passage depth (row 819).** Bjornn & Reiser give
  0.24 m for summer chinook passage and >=30 cm for summer chinook spawning depth, so this may be the spawning
  criterion misattributed. The row is kept with that caveat in its note.
- **Roberge Table 57, young-of-the-year steelhead velocity <0.15 m/s (row 783).** The steelhead text gives no
  such velocity. The chinook text gives exactly that from Everest & Chapman, so the steelhead cell may be
  carried over from chinook.
- **Hatfield 2002 Table 7 (rows 830-833)** is labelled an example for a 5.8 m3/s stream. It is the only CH
  migration flow need. Appendix A applies the same criteria to real streams.
- **Life stage of year-round FISH standards** (DFO 2013 30 % MAD, Hatfield 2003 90th percentile, Tennant 10 %
  instantaneous): set to `rearing` because a stage is required. Each note says so.
- **Raleigh p. 5 base-flow rows (760-761)** are set to `overwintering` for the reason in their note. The
  model's V11 also applies to embryos and juveniles in late summer. Metric `unstated`: an average annual base
  flow fits no metric.
- **Neuman & Newcombe 0.7 ft/s (row 787)** has two readings; the note gives both.
- **MacIsaac, Irvine 1986 coded `lab` (row 871)** because the page says "the other studies used
  gravel-bottomed troughs".
- **Bjornn & Reiser Table 4.5 for sockeye** is "estimated from criteria for other species" (footnote b). It is
  coded SK because the table states it for sockeye, and the notes say it is not a measurement.
- **Tennant region:** the paper's detailed studies were on streams in Montana, Wyoming and Nebraska; the region
  field says so.
