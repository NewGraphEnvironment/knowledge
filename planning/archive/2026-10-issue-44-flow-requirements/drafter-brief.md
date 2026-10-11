# Drafter brief: flow-need, depth and velocity rows (#44, Phase 4)

The same brief goes to two drafters, each with one family of species. Working directory:
`/Users/airvine/Projects/repo/knowledge`.

| family | tag | species | also |
|---|---|---|---|
| Pacific salmon and steelhead | `ps` | CH, CO, SK, ST | **every** group-code row (below) |
| trout, char and grayling | `tc` | BT, GR, WCT | RB and CT rows where sources give them |

## What you produce (only these files; write nothing else in the repo)

In `planning/active/`:

1. `draft-<tag>-evidence.csv`: new rows to append to `data/literature_evidence.csv`, with exactly its header
   (20 columns; `metric` follows `unit`; `model_id` is last and stays blank).
2. `draft-<tag>-notes.md`: per species and grid cell (below), what you found and where, or what you
   searched. Also anything a source says that the table cannot hold, and anything you were unsure of.

Do not edit any other file. Do not run `0270`, `0150` or `git`. Do not spawn subagents.

## The job

For each of your species, find cited values for every **grid cell**:

| variable | life_stage | what fills it |
|---|---|---|
| `instream_flow` | `spawning`, `incubation`, `rearing`, `overwintering`, `migration` | a flow need: `bound` `min`, `range` or `optimum` |
| `depth` | `spawning`, `migration` | a lower limit: `min` or `range` |
| `velocity` | `spawning`, `rearing` | an upper limit: `max` or `range` |

SK has no `instream_flow` rearing or overwintering cell and no `velocity` rearing cell, because it rears in
lakes. Write SK rows for those if a source gives them, but no `none` rows.

Write **every** value a source gives for a cell, not one per cell. A depth optimum or a velocity minimum is
welcome as an extra row, but it does not fill the cell. Where your search finds nothing for a cell, write one
`none` row for it (below). The table already holds rows, so grep `data/literature_evidence.csv` for your
species and `depth`, `velocity` and `instream_flow` first, and do not duplicate an existing row (same key,
page, value and stage). It has two BT velocity rows (497, 498) and the Gottesfeld `SALMON` migration row (121).

`scripts/0280-literature-verify.R` prints the grid (`flow:`) and lists the empty cells.

### What a flow need is, and what it is not

- **`instream_flow`** is the water a life stage needs while it is in the stream: a minimum flow, a flow
  standard, an optimum flow from a PHABSIM or WUA curve, or a percent of MAD for a stage.
- **`discharge`** is stream size: the MAD a model uses to say a stream is big enough. Do not write
  `discharge` rows. If a source gives a stream-size threshold, mention it in `notes.md`.
- **`depth` and `velocity`** are what a fish meets at a site: a redd, a passage riffle, a rearing position.
  A channel's bankfull or mean depth is stream size. Leave it out, or if you must record it, use `m bankfull`
  and say why in `notes.md`.

## Sources

Extracted text is in
`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/f39c7eb7-ec59-4e3f-9d55-3cbc6a358fe6/scratchpad/txt/`:
`<key>.txt` is reading order with `\f` between pages; `<key>.layout.txt` is `pdftotext -layout`, for tables.
Five scans have only `<key>.ocr.txt` (the same OCR text the gate checks), and are quoted with
`quote_source` `ocr`:
- `bjornn_reiser1991HabitatRequirements`
- `neuman_newcombe1977MinimumAcceptable`
- `ford_etal1995LiteratureReviews`
- `stuart_chislett1979AspectsLife`
- `hubert_etal1985Habitatsuitability`

OCR drops decimal points and garbles symbols. A value whose digits the OCR mangled cannot be quoted: put it
in `notes.md` with the page, and prefer the original source where we hold it.

The `flow` ragnar store is `data/rag/flow.duckdb` (34 documents; it has no text for the Hubert scan). Search
it with:
`Rscript -e 's <- ragnar::ragnar_store_connect("data/rag/flow.duckdb", read_only = TRUE); print(ragnar::ragnar_retrieve(s, "minimum flow coho rearing percent MAD", top_k = 8)[, c("origin", "text")])'`.
Do not use `cred::crd_search()` or `0150 ACTION=query`; both are broken. Grep is usually faster.

The collection (`Fisheries/flow`, 35 items; keys in `data/flow_members.csv` plus these nine additions):
- `hatfield_etal2003Developmentinstream`: BC flow thresholds. Monthly percentiles of mean daily flow, for
  fish-bearing streams generally.
- `hatfield_etal2002BritishColumbia`: BC instream flow standards, phase 1.
- `ptolemy_lewis2002Rationalemultiple`: BC multiple standards, percent MAD by stage, Q95.
- `lewis_etal2004Assessmentmethods`: BC assessment methods; check for habitat suitability criteria.
- `fisheriesandoceanscanada2013Frameworkassessing`: DFO 2013, instantaneous flow as a percent of MAD.
- `tennant1976InstreamFlow`: percent of average flow by season.
- `hubert_etal1985Habitatsuitability` (GR; OCR): grayling depth and velocity suitability by stage.
- `beecher_caldwell2022Instreamflow`: Washington preference curves for CH, CO, SK, ST, BT/DV and CT.
- `u_s_fishandwildlifeservice2007Flowhabitatrelationships`: Clear Creek, CA. CH and ST spawning flow–habitat.

Strong starts for salmon:
- `raleigh_etal1986HabitatSuitablility` (CH HSI and instream flow curves)
- `bjornn_reiser1991HabitatRequirements` (depth and velocity criteria table; OCR)
- `neuman_newcombe1977MinimumAcceptable` (OCR)
- `roberge_etal2002LifeHistory`
- `ford_etal1995LiteratureReviews` (OCR)
- `levy_slaney1993reviewhabitat`, `keeley_slaney1996QuantitativeMeasures`
- `warkentin_etal2022Lowsummer`, `eclipsegeomaticsltd_2016Upperbulkley`
- `northwesthydraulicconsultantsltd_hamiltonr_1993FinalReport`
- `amecenvironment&infrastructure2015Appendix5126D`
- `woelfle-erskine_etal2017Abiotichabitat`, `macisaac2010SalmonidsHydrologic`
- `gottesfeld_rabnett2007SkeenaFish`

Strong starts for trout and char:
- BT: `mcphail_baxter1996reviewbull`, `hagen_weber2019Limitingfactorsa`, `hagen_etal2020CriticalSpawning`,
  `hagen_etal2015Criticalhabitats`
- GR: `stewart_etal2007Fishlife`, `stuart_chislett1979AspectsLife` (OCR), `bottoms_etal2023Criticalhabitats`,
  `hagen_stamford2023ParsnipArctic`, `cutting_etal2018Linkingbeaver`
- WCT: `WESTSLOPECUTTHROATTROUTOncorhynchusclarkilewisi2004`,
  `canada_departmentoffisheriesandoceans2019Recoverystrategy`
- All of them: `roberge_etal2002LifeHistory`, `ford_etal1995LiteratureReviews`, `beecher_caldwell2022Instreamflow`

No PDF yet, so never cite these directly:
- `raleigh_etal1984Habitatsuitability` (rainbow trout HSI)
- Hatfield & Bruce 2000
- Bradford & Heinonen 2008
- McMahon 1983 (coho HSI)
- Hickman & Raleigh 1982 (cutthroat HSI)

A value another document attributes to one of these is a secondary citation (`cited_source`).

## Row rules (read `pkg/R/literature.R`; the reader refuses a bad row)

- **`species_code` is the species the value was measured on, or the group the source states.**
  - **Group codes (Al, 2026-10-07):** a standard or statement that names no species is coded for the scope it
    states: `FISH` (fish, aquatic life, fish-bearing streams), `SALMON` (Pacific salmon generally) or
    `SALMONIDS`. Such rows fill no grid cell. Write one row per statement, never one per species. Only the
    `ps` drafter writes group-code rows, so that the two drafts cannot duplicate them.
  - A value given for several named species at once is one row per named species, with the grouping in
    `note`.
  - Westslope cutthroat is `WCT`; generic cutthroat (Hickman & Raleigh) is `CT`, and so is WA's
    "cutthroat"; coastal is `CCT`. Resident rainbow trout is `RB`. Use `ST` only where the source says
    steelhead or anadromous *O. mykiss*. Washington's "bull trout/Dolly Varden" curve is `BT`, with the
    pooling in `note`.
- **`life_stage`:**
  - `spawning`: adults on the redd; redd depth and velocity.
  - `incubation`: egg to emergence; for flow, the flow that keeps redds wetted.
  - `rearing`: juveniles in summer.
  - `overwintering`
  - `migration`: adult upstream passage, including passage depth.
  - Adult holding is not `rearing`; put it in notes.
- **`variable`:** `instream_flow`, `depth`, `velocity`.
- **Units, as the source wrote them:**
  - depth: `m`, `cm` or `ft`;
  - velocity: `m/s`, `cm/s` or `ft/s`;
  - flow: `m3/s`, `cfs`, `percent MAD` (a percent of mean annual discharge, also "% LTMAD", or average flow
    in Tennant), `percentile` (the 90th percentile is a high flow) or `percent exceedance` (Q95, the flow
    exceeded 95 % of the time, is a low one).
  - Never convert. The gate checks the value against the quote, and only `percent MAD` accepts a proportion
    (0.2 for 20).
- **`metric`** is required on every valued `instream_flow` row. It names the flow statistic the need is held
  to:
  - `instantaneous`
  - `daily_mean` (for a percentile of daily flows, say which month in `note`)
  - `7day_low` (the `note` must give the return period, e.g. 7Q10)
  - `monthly_mean`, `monthly_median`
  - ~~`seasonal_mean` (Tennant's Oct–Mar and Apr–Sep)~~ **Wrong (audit round 1):** Tennant asks for
    *instantaneous* flows (p. 10, item 1); his seasons say when a level applies, not the statistic. The 12
    Tennant rows are `instantaneous`, and `seasonal_mean` left the vocabulary.
  - `unstated` whenever the source does not say. Never infer one.

  `depth` and `velocity` take no metric. A `qual` row takes none either.
- **Months:** there is no month column. A flow need's season comes from its life stage. Months the source
  names go in `note` ("August–September").
- **`bound`:**
  - `min` or `max` for a limit, and `range` for a span between two limits.
  - **`optimum` for any optimum, preferred or best span:** a PHABSIM or WUA peak flow, Tennant's "optimum
    range", a band at ≥80 % of maximum WUA, a preferred depth. Never code an optimum span as `range`, because
    a `range` reads as two limits.
  - An HSI breakpoint that is neither an edge of zero suitability nor a limit has a blank `bound`; give its
    suitability in `note`.
- **A regression or equation** (optimum flow = a·MAD^b; a percentile formula): if the source tabulates
  values, write those. Otherwise write a `qual` row with the equation in `note`.
- **`kind`:**
  - `param`: a value a model or standard sets.
  - `expert`: a recommendation, criterion or standard; Tennant and the BC thresholds are `expert`.
  - `hsi`: a habitat-suitability-curve breakpoint.
  - `dist`: where fish were found, e.g. redd depths measured.
  - `pref`: a preference from use and availability.
  - `max_obs`, `qual` (a statement with no value) and `none` as their names say.
  - A WUA or PHABSIM optimum flow is `hsi`, because it comes from suitability curves; its `note` names the
    method.
- **`scale`:** `site` for redd, microhabitat or passage measurements; `reach` for a reach or stream flow;
  blank where the source does not apply it to a place.
- **`region`:** free text, plus the stock if named.
- **`cited_source`:** when you quote a document that reports someone else's value (Bjornn & Reiser citing
  Thompson 1972), `citation_key` is the document you quote and `cited_source` names the original.
- **`page`:** the page number printed on the page. Where none is printed, use the PDF page and say "PDF page"
  in `note`.
- **`parameter` and `model_id` stay blank** on every row you write.

### `none` rows

Write one per empty cell after your search: `species_code`, `life_stage`, `variable`, and the `bound` the cell
needs (`min` for a flow need or a depth, `max` for a velocity); `kind` `none`. Leave value, unit, metric, key,
quote, quote_source and model_id blank. The `note` says exactly what was searched — "Searched the #44 flow
collection (35 items) and <named PDFs>; no <species> <stage> <flow need>." — and never that no value exists in
the literature.

### Quotes: the gate is exact

`0280` checks every quote against the cited PDF.

- **`text` quotes** are verbatim running text, at least 20 characters, compared as token sequences after light
  normalisation (case, quote marks, dashes, ligatures).
  - Skip a stretch with ` ... `; each fragment must be at least 3 tokens, in order, and close together.
  - A `[bracketed insert]` is not matched.
  - A quote may not stop inside a number or a range.
- **`table` quotes** are a table row's tokens in order, as on the `-layout` text, within three lines. No cell
  may be skipped, and the quote needs at least one number and one word.
- **`ocr` quotes** are checked like text, against the OCR.
- **Every value must be printed in the quote itself**, as written. If a symbol rendered as a stray letter or
  digit breaks a number, quote up to the number and say so in `note`.

### Meaning is what fails, not words

The gate proves a quote is verbatim and a value sits in it. It cannot see a row that says the wrong thing
around a true quote. On #29 every quote verified, and a row-by-row audit still found 22 errors of meaning. On
#38 an audit found 13 errors in 22 rows of one family.

Before you finish, re-read each row against its page:
- right species, or group;
- right stage;
- a need rather than stream size;
- right bound, with an optimum kept apart from a limit;
- right metric and unit;
- a note that does not claim more than the page says.

## Checking your drafts

```bash
S=/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/f39c7eb7-ec59-4e3f-9d55-3cbc6a358fe6/scratchpad
python3 $S/merge_drafts.py <tag> $S/merge-<tag>
EVIDENCE=$S/merge-<tag>/evidence.csv REGISTRY=$S/merge-<tag>/registry.csv LOG=$S/merge-<tag>/verify.csv \
  Rscript scripts/0280-literature-verify.R
```

The gate exits non-zero while the other family's cells are empty, and that is expected. What you need is
that every one of your rows (data rows after 686) passes in `verify.csv`, and that every cell of your species
in the printed `flow:` list is filled. Fix and re-run until both hold. A run takes a few minutes, mostly on a
first OCR.
