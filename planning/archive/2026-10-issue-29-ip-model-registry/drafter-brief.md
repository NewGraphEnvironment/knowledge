# Drafter brief: IP model registry and threshold rows (#29, Phase 3)

The same brief goes to three drafters. Each drafter gets one model family. Working directory:
`/Users/airvine/Projects/repo/knowledge`.

## What you produce (only these files; write nothing else in the repo)

All in `planning/active/`, where `<fam>` is your family tag:

1. `draft-<fam>-registry.csv`: rows to append to `data/ip_model_registry.csv`, using exactly its header (23
   columns).
2. `draft-<fam>-evidence.csv`: new rows to append to `data/literature_evidence.csv`, using exactly its header
   (19 columns, `model_id` last).
3. `draft-<fam>-tags.csv`: existing evidence rows that belong to one of your models. Columns are
   `data_row,model_id`, where `data_row` is the 1-based data row of `data/literature_evidence.csv` (header
   excluded). Follow the tag rule below.
4. `draft-<fam>-notes.md`:
   - each model you were assigned: registered, or skipped and why (no PDF, not a threshold model, and so on);
   - **how each model sizes streams**, the flow finding, with page refs:
     - the metric it thresholds on;
     - whether that was gauged, modelled or field-measured, and from what inputs;
     - any surrogate;
     - whether a discharge threshold was converted from or to width;
   - validation, and its result.

Do not edit any other file. Do not run `0270`, `0150` or `git`. Do not spawn subagents.

## Reading the PDFs

Extracted text of the group-library PDFs is in
`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3f18853b-1f81-4f74-b92f-745d7285faf6/scratchpad/txt/`.
There are two files per key:
- `<key>.txt`, reading order, with form feeds (`\f`) between pages;
- `<key>.layout.txt`, from `pdftotext -layout`, for tables.

For any other key, run
`python3 /private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3f18853b-1f81-4f74-b92f-745d7285faf6/scratchpad/keytext.py <citation_key>`.

`page` is the page number printed on the page (`C-7`, `13`). Where the document prints none, use the PDF page
and say "PDF page" in `note`.

## Evidence rows (`data/literature_evidence.csv` schema; read `pkg/R/literature.R` for the reader's rules)

- One row per value a model uses: species, life stage, variable, bound and value.
- **`model_id`** is a lower-case identifier for the model, e.g. `burnett2007`, `agrawal2005`,
  `lindley2006`, `woll2017`. Every row you write for a model carries its `model_id`.
- **`life_stage`** is one of `spawning`, `incubation`, `emergence`, `fry_migration`, `rearing`,
  `overwintering`, `outmigration`, `access`. A model that rates a reach for "juvenile summer rearing" is
  `rearing`. A model that does not separate spawning from rearing gets a row per stage it applies to. An
  upstream barrier or passability limit is `access`.
- **`life_history_form`:** CH is `stream_type` or `ocean_type`; leave it blank for other species unless
  the vocabulary has the form (`resident`, `fluvial`, `adfluvial`, `migratory`). Steelhead winter vs summer
  run goes in `note`.
- **`variable`:** `gradient` (percent, as written; a proportion such as 0.03 is stored as 3 and the gate
  allows ×100), `channel_width` (`m bankfull`, `m wetted`, `m` if unspecified, or `ft` as written),
  `discharge` (`m3/s`, or `cfs` as written), `drainage_area` (`km2`, `mi2`), `valley_width_index`
  (`ratio`), `temperature` (`degC`), `stream_order`, `substrate`, `depth`, `velocity`, `lake_area`,
  `wetland_area`, `bridge_distance`, `timing`.
- **`parameter`:** the link parameter it bears on, else blank. The parameters are:
  - `spawn_gradient_max`, `spawn_gradient_min`, `spawn_channel_width_min`, `spawn_mad_min`;
  - `rear_gradient_max`, `rear_channel_width_min`, `rear_mad_min`, `rear_mad_max`;
  - `rear_lake_ha_min`, `rear_wetland_ha_min`, `access_gradient_max`;
  - `cluster_bridge_gradient`, `cluster_bridge_distance`.

  An interior curve breakpoint that is not a 0-suitability edge has a blank `parameter`.
- **`bound`:** `min`, `max`, `range` or `optimum`. `min` sits on `value_min`, `max` on `value_max`, and
  `range`/`optimum` need both.
- **`kind`:**
  - `param` for a hard model rule;
  - `hsi` for a suitability-curve breakpoint, with **the suitability score at that breakpoint in `note`**;
  - `expert` for expert opinion;
  - `qual` for a qualitative statement, with no value. Use `qual` for a variable whose curve is printed only
    as a figure: one `qual` row per variable, quoting the text that names the variable. Never read numbers
    off a figure.
  - `none` rows are not yours. They carry no `model_id`.
- **`scale`** is `reach` or `segment` for model rules (a GIS segment is `segment`).
- **`region`** is free text, for example "Oregon Coast Range".
- **`cited_source`:** when the quote is a secondary account (Sheer et al. 2009 summarising someone's model),
  `citation_key` is Sheer's and `cited_source` names the original.

### Quotes: the gate is exact, so be exact

`scripts/0280-literature-verify.R` checks every quote against the cited PDF. A row that fails is a row that
is wrong.

- **`text` quotes** are verbatim running text of at least 20 characters. They are compared as token
  sequences after only light normalisation (case, quote marks, dashes, ligatures). To skip a stretch, split
  the quote with ` ... ` (each fragment at least 3 tokens, in order, close together). A `[bracketed insert]`
  is yours and is not matched. A quote may not stop inside a number or range.
- **`table` quotes** are the row's tokens in order, as they appear on the `-layout` text within three lines.
  No cell may be skipped. The quote needs at least one number and one word.
- **`ocr`** is only for a scan with no text layer.
- **Every value must be stated in the quote itself**, as written, with only the unit rescalings above.
  `value_not_in_quote` means the number is not in your quote.
- Hyphenated line breaks in the PDF are joined by the gate ("habi-\ntat" → "habitat"), and both forms are
  tried.

## Registry rows (`data/ip_model_registry.csv`; read `pkg/R/ip.R` for the full rules)

One row per `model_id` × species × life stage × form, for **every** model × species × stage for which you
wrote, or tagged, at least one evidence row. The gate fails a registry row with no evidence row, and an
evidence `model_id` × species × stage with no registry row.

- **`model`, `region`:** the same `model` text on every row of one `model_id`.
- **`flow_metric`:** what the model's thresholds are written on. One of `mean_annual_flow`,
  `summer_low_flow`, `channel_width` (bankfull or wetted; say which in `note`), `drainage_area`,
  `precipitation`, or `none` (the model uses no stream-size variable).
- **`flow_source`:** `gauged`, `modelled` or `field`. It is blank when `flow_metric` is `none`.
- **`flow_inputs`** (required when modelled): a `;`-separated list from `gauge`, `drainage_area`,
  `precipitation`, `hydrologic_model`, `field_measurement`. Field widths regressed on drainage area and
  precipitation are `field_measurement;drainage_area;precipitation`. MAF from a regression of gauges on
  drainage area and precipitation is `gauge;drainage_area;precipitation`.
- **`flow_surrogate`:** the metric used where the primary was unavailable. It must differ from
  `flow_metric`; otherwise leave it blank.
- **`valley_confinement`:** `valley_width_index` if the model uses valley width relative to channel width
  (valley constraint), else `none`.
- **`validation`:** `none`, `fish_observations`, `redd_surveys` or `density`.
  - If it is not `none`, fill `validation_result` (one sentence, including any statistic) and the validation
    quote (`validation_page`, `validation_quote`, `validation_quote_source`). Fill `validation_citation_key`
    only if that quote is in a different document.
  - If it is `none`, leave all of those blank and say what you read in `note`.
- **`citation_key`, `page`, `quote`, `quote_source`:** a verbatim quote supporting the flow claim (how the
  model sizes streams). For `flow_metric = none`, quote the variables the model does use.
  - `cited_source` if the quote is secondary.
  - Calibration (for example widths set from redd-count reaches) is not validation. Validation compares
    the model's output with fish.

## Tag rule for existing rows

Tag an existing evidence row with your `model_id` only when it states a value or variable the model itself
uses: `param`, `hsi`, `expert`, or a `qual` naming a model variable. Do not tag:
- data summaries (`dist`, `max_obs`);
- literature the model cites but did not adopt.

Rows already tagged (`rebellato2024`, `cooney_holzer2006`) stay as they are; you may add **new** rows for
those models.

## Checking your work: run the gate on a merged copy

```bash
SC=/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3f18853b-1f81-4f74-b92f-745d7285faf6/scratchpad
S=$SC/gate_<fam>
mkdir -p $S
python3 $SC/merge_drafts.py <fam> $S
cd $SC/gate_frozen && EVIDENCE=$S/evidence.csv REGISTRY=$S/registry.csv LOG=$S/log.csv \
  Rscript scripts/0280-literature-verify.R
```

`gate_frozen/` is a frozen copy of the gate and the package. Run it from that directory, never
`scripts/0280` in the repo, which may be edited while you work.

`merge_drafts.py` writes `evidence.csv` (committed table, plus your tags, plus your rows) and `registry.csv`
(committed plus yours). Iterate until the gate prints no failures for your rows. Coverage is not your
concern. The logs `$S/log.csv` and `$S/log_ip_registry.csv` show the status per row.

Thoroughness matters more than volume: every number a model uses for CO, ST, CH, SK, CM, PK or any other
species, at its stated life stage. Where a model only lists a variable without a number, one `qual` row.
