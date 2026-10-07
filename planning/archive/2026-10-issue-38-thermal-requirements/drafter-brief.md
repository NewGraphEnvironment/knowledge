# Drafter brief: thermal requirements rows (#38, Phase 4)

The same brief goes to two drafters, each with one family of species. Working directory:
`/Users/airvine/Projects/repo/knowledge`.

| family | tag | species |
|---|---|---|
| trout and char | `tc` | WCT, BT |
| Pacific salmon and steelhead | `ps` | CH, CO, ST |

## What you produce (only these files; write nothing else in the repo)

In `planning/active/`:

1. `draft-<tag>-evidence.csv`: new rows to append to `data/literature_evidence.csv`, with exactly its
   header (20 columns; `metric` follows `unit`, `model_id` is last and stays blank).
2. `draft-<tag>-notes.md`: per species, per grid cell (below), what you found and where, or what you
   searched; anything a source says that the table cannot hold; anything you were unsure of.

Do not edit any other file. Do not run `0270`, `0150` or `git`. Do not spawn subagents.

## The job

For each of your species, find cited values for every **grid cell**:

| variable | life_stage | what fills it |
|---|---|---|
| `temperature` | `spawning` | an upper limit (`bound` `max` or `range`) |
| `temperature` | `spawning` | a lower limit (`min` or `range`) |
| `temperature` | `incubation` | upper, lower |
| `temperature` | `rearing` | upper, lower |
| `degree_days` | `incubation` | degree-days from fertilization to hatch (`metric` `to_hatch`) |
| `degree_days` | `emergence` | degree-days from fertilization to emergence (`to_emergence`) |
| `degree_days` | `rearing` | growing-season degree-days for first-summer growth (`growing_season`) |
| `degree_days` | `overwintering` | growing-season degree-days needed to reach a size that survives winter (`growing_season`) |

Write **every** value a source gives for a cell, not one per cell; an `optimum` is welcome as an extra row
but does not fill a limit cell. Where your search finds nothing for a cell, write one `none` row for it
(below). The table already holds rows: grep `data/literature_evidence.csv` for your species and
`temperature` before writing, and do not duplicate a row that is already there (same key, page, value,
stage).

`scripts/0280-literature-verify.R` prints the grid (`thermal:`) and lists the empty cells.

## Sources

Extracted text is in
`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/b9fd4034-f945-42c9-a979-e8b41fcdbc3f/scratchpad/txt/`:
`<key>.txt` (reading order, `\f` between pages) and `<key>.layout.txt` (`pdftotext -layout`, for tables).
Two scans have only `<key>.ocr.txt`: `bjornn_reiser1991HabitatRequirements` and the Metolius bull trout
report; quote those with `quote_source` `ocr`. Any other group key:
`python3 /private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/b9fd4034-f945-42c9-a979-e8b41fcdbc3f/scratchpad/keytext.py <citation_key>`.

The `temperature` ragnar store, if `data/rag/temperature.duckdb` is more than a few MB, can be searched:
`Rscript -e 's <- ragnar::ragnar_store_connect("data/rag/temperature.duckdb", read_only = TRUE); print(ragnar::ragnar_retrieve(s, "degree days emergence cutthroat", top_k = 8)[, c("origin", "text")])'`.
Do not use `cred::crd_search()` or `0150 ACTION=query`; both are broken. Grep is usually faster.

Start with: `hasnain_etalKeyEcological` (temperature metrics per Canadian species; read its definitions),
`richter_kolmes2005MaximumTemperature` (CH, CO, ST), `sauter_etal2001Issuepaper`, `bjornn_reiser1991HabitatRequirements`,
`raleigh_etal1986HabitatSuitablility` (its incubation section gives degree-days), `brett1971EnergeticResponses`,
`iacarella_etal2024Projectingexceedance`, `lusardi_etal2020Oversummergrowth` (CO); for trout and char,
`thorley_etal2022UpperFording`, `thorley_etal2021UpperFording`, `cope2020UpperFording`,
`canada_departmentoffisheriesandoceans2019Recoverystrategy`, `cleator_etal2009InformationRelevant`,
`WESTSLOPECUTTHROATTROUTOncorhynchusclarkilewisi2004`, `coleman_fausch2007ColdSummer`,
`coleman_fausch2007ColdSummera`, `chezik_etal2014Fishgrowth`, `mcphail_baxter1996reviewbull`,
`selong_etalEffectTemperature`, `u_s_fishandwildlifeservice2015Recoveryplan`,
`u_s_fishandwildlifeservice2010Endangeredthreatened`, `hill_etal2024Spatialstream`, `hill_etal2025Spatialstream`.
`bear_etal2005ThermalRequirements` and `bear_etal2007ComparativeThermal` have **no PDF**: never cite them
directly. A value another document attributes to Bear et al. is a secondary citation (below).

## Row rules (read `pkg/R/literature.R`; the reader refuses a bad row)

- **`species_code` is the species the value was measured on.** Westslope cutthroat is `WCT`. Colorado River
  cutthroat (Coleman & Fausch 2007) is `CRCT`, never `WCT`: say in `notes.md` where a WCT document applies a
  CRCT value. Resident rainbow trout is `RB`; `ST` only where the source says steelhead or anadromous
  *O. mykiss*. A value given for "salmonids" or several species at once is one row per named species,
  with the grouping in `note`.
- **`life_stage`:** `spawning`, `incubation` (egg to hatch, or to emergence where the source does not
  separate them), `emergence`, `rearing` (juvenile summer), `overwintering`, `migration`. Adult holding is
  not `rearing`; leave it out or put it in notes.
- **`variable`:** `temperature` (water), `air_temperature` (an air temperature, including a model's air
  proxy), `degree_days`.
- **`metric`** (required on every valued row of those three variables):
  - temperature statistics: `daily_max`, `daily_mean`, `mwmt` (maximum weekly maximum), `7dadm` (7-day
    average of daily maxima), `mwat` (maximum weekly mean), `7dec` (7-day equivalent constant), `weekly_mean`,
    `monthly_mean`, `august_mean`, `summer_mean`, `annual_mean`, `constant` (a laboratory exposure at a held
    temperature: UILT, growth optimum at constant temperature), `unstated`;
  - degree-day windows: `growing_season` (as Coleman & Fausch 2007 define it, which `gsdd` implements),
    `to_hatch`, `to_emergence`, `annual`, `unstated`.
  - Use `unstated` whenever the source does not say which statistic. Never infer one.
  - A ramped critical thermal maximum (CTmax) is not `constant`: use `unstated` and say "CTmax" in `note`.
- **Degree-day rows need a `note` that gives the base temperature** ("base 0 °C", "base 5 °C", or "base not
  stated") and how the source defines the window.
- **`bound`:** `max` or `min` for a limit; `range` for a span (it fills both upper and lower cells);
  `optimum` for a preferred or optimal span. A degree-day requirement ("at least 800") is `min`; a span is
  `range`; a single typical value is `range` with equal min and max.
- **`kind`:** `param` (a value a model or standard sets), `expert` (a recommendation or criterion),
  `dist` (where fish were found), `max_obs`, `pref`, `hsi`, `qual` (a statement with no value), `none`.
- **`scale`:** `site`, `reach`, `segment`, `network`, or blank for a laboratory value.
- **`region`:** free text; "laboratory" for a lab study, plus the stock if named.
- **`cited_source`:** when the quote is a document reporting someone else's value (Richter & Kolmes citing
  Hicks 2000), `citation_key` is the document you quote and `cited_source` names the original.
- **`page`:** the page number printed on the page. Where none is printed, the PDF page, and say "PDF page" in
  `note`.

### `none` rows

One per empty cell after your search: `species_code`, `life_stage`, `variable`, and `bound` (`max` or `min`)
for a limit cell or `metric` (the window) for a degree-day cell; `kind` `none`; no value, unit, key, quote,
quote_source or model_id. The `note` says exactly what was searched — "Searched the #38 temperature
collection (44 items) and <named PDFs>; no <species> <stage> <upper limit>." — and never that no value
exists in the literature.

### Quotes: the gate is exact

`0280` checks every quote against the cited PDF.

- `text` quotes are verbatim running text, at least 20 characters, compared as token sequences after light
  normalisation (case, quote marks, dashes, ligatures). Skip a stretch with ` ... ` (each fragment at least
  3 tokens, in order, close together). A `[bracketed insert]` is not matched. A quote may not stop inside a
  number or range.
- `table` quotes are a table row's tokens in order, as on the `-layout` text within three lines; no cell
  skipped; at least one number and one word.
- **Every value must be printed in the quote itself**, as written. A degree sign rendered as a letter or
  digit (`°e`, `8`) breaks a number: quote up to the number and say so in `note`, as existing rows do.
- °F only: the table has no °F unit. Use the °C the source prints beside it; if it prints none, put the row
  in notes, not in the table.

### Meaning is what fails, not words

The gate proves a quote is verbatim and a value sits in it. It cannot see a row that says the wrong thing
around a true quote. On #29 every quote verified and a row-by-row audit still found 22 errors of meaning.
Before you finish, re-read each row against its page: right species, right stage, right bound, right
metric, and a note that does not claim more than the page says.

## Checking your drafts

```bash
S=/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/b9fd4034-f945-42c9-a979-e8b41fcdbc3f/scratchpad
python3 $S/merge_drafts.py <tag> $S/merge-<tag>
EVIDENCE=$S/merge-<tag>/evidence.csv REGISTRY=$S/merge-<tag>/registry.csv LOG=$S/merge-<tag>/verify.csv \
  Rscript scripts/0280-literature-verify.R
```

The gate exits non-zero while the other family's cells are empty. That is expected: what you need is
that every one of your rows (data rows after 510) passes in `verify.csv`, and that every cell of your
species in the printed `thermal:` list is filled. Fix and re-run until both hold.
