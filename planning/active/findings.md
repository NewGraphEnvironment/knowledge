# Findings — Backlog move 9: Access gradients and gradient on the ground (#178)

## Issue context

**If we do it:** link's access gradients are traced to their sources and checked against records, the tuning population follows link's access with leave-one-out, and gradient is read over fixed windows and against the floodplain edge. **If we never do:** every tuning rests on inherited access classes, excludes resident populations above barriers, and reads a gradient whose length depends on the catch.

**Open** since 2026-11-18: link's override table (NewGraphEnvironment/link#434) and its known-record rule (NewGraphEnvironment/link#400) closed on 2026-11-17. #70's fixed-window and lidar step still waits on fresh's fixed-window gradients (NewGraphEnvironment/fresh#257), so the plan splits it off as its own issue. #132's literature step can start before them.

### Batch 14. Access

| issue | title |
|---|---|
| #132 | Where link's access gradients come from, and whether they hold |
| #131 | Tune on link's access with its overrides, leaving each visit out of its own |

### Batch 15. Gradient on the ground

| issue | title |
|---|---|
| #70 | Gradient on the ground: field-measured against the Freshwater Atlas, fixed-window gradients, then lidar |
| #71 | Distance and gradient from the floodplain edge (ff02, ff04) for small streams near large rivers |


---

Backlog: `planning/backlog.md`, move 9. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `mcp__zotero__zotero_search_items`: missing ZOTERO_LIBRARY_ID and ZOTERO_API_KEY | Not a route (soul#590; kdot#42 removes the server). Read the group library from `zotero.sqlite` read-only, or through `/zotero-lookup`, `/zotero-api`, `/lit-search` |

## PSCIS gradient fields (2026-11-18)

`bcdata::bcdc_describe_feature()`: `WHSE_FISH.PSCIS_HABITAT_CONFIRMATION_SVW` has no gradient or slope field (41
columns: habitat value, verified length, comments, links). `WHSE_FISH.PSCIS_ASSESSMENT_SVW` has `STREAM_SLOPE`,
`CULVERT_SLOPE` and `CULVERT_SLOPE_SCORE`. So #70's "PSCIS habitat confirmations" step reads the assessment layer's
stream slope; confirmation gradients exist only in the reports (#235).

## Phase 2: expectations, written before sourcing (2026-11-18)

What each class should rest on, if the lineage is sound:
- **15 % (CH, CM, CO, PK, SK, GR, KO):** the anadromous salmon limit in the CWF BC report (Rebellato et al. 2024,
  held), from WDFW's 2009 barrier manual (16 % for CH, SK, CO; held as `BUYCVFJG`). Expect no source for GR or KO at
  15 %: they are freshwater species carried on the salmon class.
- **20 % (ST, WCT):** steelhead from the same WDFW/Rebellato line; WCT expected to have no gradient source of its
  own (borrowed from steelhead or from a resident-trout convention).
- **25 % (BT, RB, CT, DV):** the provincial Fish Passage GIS method's Version 1 limit (Norris and Mount 2016, held:
  "25% was used as the maximum gradient for fish passage in Version 1"), itself expected to cite trout passage or
  expert judgement, not a measured limit.
- **What fish are measured to pass:** leap height and burst speed in the classic passage literature (Powers and
  Orsborn 1985; Reiser et al. 2006; Bell's handbook; Castro-Santos 2005; Kondratieff and Myrick 2006; Lauritzen et
  al. 2010), and last-fish gradients in headwater studies (Trotter 2000, held; Adams et al. 2000 for brook trout
  in steep channels). Expect leap limits in metres and burst speeds in m/s, not percent gradients: a gradient limit
  is an inference from them over a reach length, and that inference is what the records review tests.

## Phase 2: the classes' lineage (2026-11-18)

- **bcfishpass** (`docs/02_model_access.md`, checkout at 620dbe43, 2026-10-01) gives the classes as a table with no
  citation: Pacific salmon 15 %, steelhead 20 %, westslope cutthroat 20 %, bull trout 25 %. Its gradient-barrier
  method reads slope over 100 m upstream of each vertex; the same page's prose says "eg 25% for salmon", which its
  own table contradicts. Gradient barriers are generated at 5, 7, 10, 12, 15, 20, 25 and 30 %
  (`model/01_access/gradient_barriers/README.md`). Its habitat page points to Rebellato et al. 2024's Table 1 for
  salmon and steelhead thresholds.
- **Rebellato et al. 2024** (`BC_report_formatted_final.pdf`, held, rows exist): "Chinook, Sockeye and Coho salmon
  pass gradients up to 16% (WDFW 2009), whereas steelhead pass gradients up to 20%", and "gradients ≥15% were
  considered barriers for all Pacific salmon".
- **Norris and Mount 2016** (held, a BT row exists at 25 %).
- Held passage-performance sources found by `0150`-equivalent `crd_search()` over `habitat_modelling`, `bull_trout`
  and `westslope_cutthroat` (all hybrid, none degraded): Katopodis and Gervais (swimming performance database),
  Blank et al. 2020 (rainbow and westslope cutthroat in an open-channel flume), Trotter 2000 (last-fish gradients),
  D'Angelo and Muhlfeld 2011 (BT and WCT distribution, waterfall barriers), the Upper Fording River fish-passage
  stressor report (WCT movement, culvert and drying reach).

## The classes for GR, KO, RB, CT and DV (2026-11-18)

- **bcfishpass's code** carries more than its docs: `model/01_access/sql/model_access_ct_dv_rb.sql` blocks CT, DV
  and RB at `GRADIENT_25` and `GRADIENT_30`, beside `model_access_bt.sql` (25 %), `model_access_st.sql` and
  `model_access_wct.sql` (20 %) and `model_access_ch_cm_co_pk_sk.sql` (15 %). No file cites a source.
- **fresh** first carried RB, CT and DV at 0.25 in aac96efe (2026-03-18, #56, the coho pipeline), as bcfishpass's
  values; the commit names no source.
- **GR and KO** have no bcfishpass access model. Both entered link's `configs/default/parameters_fresh.csv` at 0.15
  in 323207783 (2026-05-02, link#107, "Derive species presence cols from CSV header"); fresh's own table gained KO in
  4325cd4c (2026-04-10, #121, SK/KO spawning-lake proximity). Neither commit names a source: both freshwater species
  ride the anadromous salmon class.

## WDFW 2009, read directly (2026-11-18)

`wdfw00061.pdf` (240 pages, fetched from WDFW's publications page into the ignored `data/rag/pdf/passage_limits/`):
- **p. 6-1, natural barriers** "that would exclude most adult salmonids": a waterfall > 3.7 m, "a stream reach having
  a sustained gradient exceeding 20% for 160 or more meters", or > 16 % for 160 m in a channel < 0.6 m wide (Western
  Washington) or < 0.9 m (Eastern). Then: "bull trout are often found above 30% gradient (Cannings and Ptolemy 1998)
  and cutthroat trout have been found in gradients up to 33% (Jauquet 2002), for purposes of this manual, the 20%
  gradient threshold has been accepted as the upper limit for most adult salmonids."
- **p. 9-7, Table 9.2** (PDF page 103, read from the rendered page: passability is drawn, not printed): the passable
  strata end at 5 % for chum, 12 % for pink, 16 % for coho, sockeye and chinook, 20 % for steelhead and sea-run
  cutthroat; bull trout (with Dolly Varden) and resident rainbow and cutthroat are shaded as using every stratum to
  20 %, the table's top. p. 9-4: "coho salmon ... may ascend stream reaches up to16%".
- So the 16 % that Rebellato et al. 2024 cite is WDFW's coho, sockeye and chinook stratum; WDFW's chum (5 %) and
  pink (12 %) limits are lower than the 15 % class BC applies to them, which the existing CM and PK rows (Rebellato's
  15 %) do not show. Gradients are over a sustained 160 m, not bcfishpass's 100 m.

## Norris and Mount 2016, read directly (2026-11-18)

`norris_mount2016Fishpassage` (attachment `MRPUF7JW`): "Barriers to fish passage include sustained (>100 linear
meters) channel gradients of a user specified percentage (... the model default is a choice of any 5% increment
between 10% and 30%. The gradient cut-off in Version 1 was simply 25%) ... Although this model is simple and has not
been field verified as a predictor of fish habitat" (§2, text line ~127); and in §2.1.3.1: "25% was used as the
maximum gradient for fish passage in Version 1 of the model and is still the gradient barrier threshold most often
used." No species is named and no source is cited: 25 % is the provincial fish-habitat model's species-blind cut-off,
which bcfishpass applies to BT, RB, CT and DV.

## The outside literature (sourcing sweep, 2026-11-18)

A background agent's sweep (50 sources, `scratchpad` file not tracked; read levels FULL, ABSTRACT, SECONDARY per
source) and checks of its load-bearing quotes:
- **Mount et al. 2011** (Streamline Watershed Management Bulletin 14(2), p. 9; checked in the PDF): "Typically,
  grades exceeding 20% are considered a barrier for anadramous species (B.C. Ministry of Forests 1998).
  Nevertheless, some species (e.g., Bull Trout and Dolly Varden/Cutthroat) can utilize reaches with a sustained
  slope of 25–30% (Cannings and Ptolemy 1998). Considering these values, Stream Gradient Segments with slopes
  greater than 25% were considered barriers." This is BC's 25 %, which Norris and Mount 2016 call Version 1's.
- **BC Fish-stream Identification Guidebook 1998** (2nd ed., v2.1; the gov.bc.ca PDF 404s, read from the Wayback copy;
  checked): "areas of ≥ 20% grade" are too steep for fish use; reaches "< 20% will be designated as fish streams by
  default"; cutthroat, bull trout, Dolly Varden and sometimes rainbow "observed to occur in very steep streams, well
  in excess of 20% gradient". No study cited for the 20 %.
- **Cannings and Ptolemy 1998** is held (`cannings_ptolemy1998RareFreshwater`, two PDFs on one item: `N2IJDSIN`
  Bib77170.pdf and `PWRE9XAM` the OCRed copy, md5s differ). Its only gradient statement found: "Bull trout can be
  found in high gradient areas (up to 30%) where you would not expect to find other game fish species (P. Bech, pers.
  comm.)". Nothing on Dolly Varden or cutthroat gradients was found in it, so Mount et al.'s "Bull Trout and Dolly
  Varden/Cutthroat ... 25–30%" widens its source, and the source is a personal communication.
- **Bjornn and Reiser 1991** Table 4.2 (held, a scan; OCR cached in `data/rag/ocr/0a10…ac4.txt`, so rows quote it as
  `ocr`): darting speeds and maximum jump heights by species after Bell 1986 and Reiser and Peacock 1985.
- **Powers and Orsborn 1985** Table 1 (BPA; checked): Bell's speeds by species; "Pink & Chum salmon values estimated
  from leap heights of 3 to 4 ft at waterfalls".
- No primary source gives 15 % for salmon (WDFW's 16 % is the nearest), or any limit for grayling or kokanee, or 25 %
  for rainbow, or 20 % for westslope cutthroat.
