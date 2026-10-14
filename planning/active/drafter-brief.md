# Drafter brief: growing-season and first-winter size rows (#47)

The same brief goes to two drafters, each with one family of sources. Working directory:
`/Users/airvine/Projects/repo/knowledge`. The table now has 1,102 data rows; yours are appended after them.

| family | tag | sources (citation keys) |
|---|---|---|
| trout and char | `tc` | `thorley_branton2022SubjectMatter`, `hocking_etal2022SubjectMatter`, `mochnacz2021Thermalecology`, `coleman_fausch2007ColdSummera` and `coleman_fausch2007ColdSummer` (size statements only: their degree-day rows are data rows 557–559), `thorley_etal2022UpperFording` (the 30 mm statement only), `hartman_scrivener1990Impactsforestry` (the trout passages only: Table 14 and anything on age-0 trout size or winter survival) |
| Pacific salmon and steelhead | `ps` | `holtby_scrivener1989Observedsimulated` (pp. 62–81 of a whole-volume PDF), `hartman_scrivener1990Impactsforestry` (coho passages only), `riley_etal1998Habitatbasedassessment`, `ebersole_etal2006JuvenileCoho`, `ebersole_etal2009ModelingStream`, `quinn_peterson1996influencehabitat` |

Background on each source, and what the searchers read in it, is in `planning/active/search-tc.md` and
`planning/active/search-ps.md`. Those are leads, not verified rows: read the PDF text for every statement.

## What you produce (only these files; write nothing else in the repo)

In `planning/active/`:

1. `draft-<tag>-evidence.csv`: new rows to append to `data/literature_evidence.csv`, with exactly its header.
2. `draft-<tag>-notes.md`: per source, what you filed and what you did not and why; anything a source says that the
   table cannot hold; anything you were unsure of.

Do not edit any other file. Do not run `0270`, `0150` or `git`. Do not spawn subagents.

## The job

The question is what a growing season must deliver for age-0 salmonids to survive their first winter:

- `degree_days` rows, `life_stage` `rearing` (first-summer growth) or `overwintering` (survival to or through the
  first winter, recruitment to age 1). `metric` is the window: `growing_season` only where the source uses Coleman
  & Fausch's window (start when the weekly mean stays above 5 C, end below 4 C) or computes GSDD with `gsdd`;
  `to_hatch`/`to_emergence` from fertilization; `annual` for a calendar-year sum; otherwise `unstated`, with the
  window the source gives in `note` (Holtby's February–March or March–September thermal summations are `unstated`
  with the window in the note). Every degree-day note gives the base temperature and the window.
- `fish_length` rows (new in #47): a body length the source ties to first-winter survival or recruitment, in `mm`,
  `metric` `fork_length`, `total_length` or `unstated` (whichever the source measured; a conversion the source itself
  prints, such as 30–35 mm TL = 28–33 mm FL, is a second row with its own metric, both noting the other). Life stage
  `overwintering` for a size at the onset of winter that survival depends on. `bound` `min` for a size below which
  survival is poor; a size range the source states as one threshold ("a minimum of 30–35 mm TL") is `min` with
  `value_min` the lower end, and the note gives the span. Nothing fills a grid cell; that is expected.
- A relation with no threshold (a regression of survival on fall length, of length on GSDD) is still worth a row
  when it is what the source has: a `qual` row (no value, unit or bound; `metric` blank) whose quote is the relation
  and whose note states the equation and its fit as printed. Never compute a value the source does not print (no
  solving a regression for the length at zero survival).
- A source's observed values (fish lengths at a GSDD, GSDD at a site) are `dist` rows only where the source ties
  them to survival or recruitment; otherwise leave them in your notes.
- Counter-evidence (size did not predict survival) is a `qual` row too: it is what stops a consumer applying a size
  threshold blindly.

## Sources

Extracted text is in `/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3130e260-3b67-4e93-a484-21efb9d8b606/scratchpad/kt/txt/`: `<key>.txt` (reading order, `\f` between pages) and `<key>.layout.txt`
(`pdftotext -layout`, for tables). `holtby_scrivener1989Observedsimulated.txt` is the whole proceedings volume:
find the chapter (pp. 62–81) by its title. Any other group key:
`python3 /private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3130e260-3b67-4e93-a484-21efb9d8b606/scratchpad/kt/scratch_keytext.py <citation_key>` (writes into that `txt/`).

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
  proxy), `degree_days`, and `fish_length` (#47: a body length in `mm`; `metric` `fork_length`, `total_length` or `unstated`).
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

**#47: write no `none` rows.** The coordinator revises the existing growing-season `none` notes. The rules below are
kept for reference only.


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


### Specific to #47

- Teck reports and theses print page numbers in the page header or footer: use the printed number, else the PDF page.
- A report that applies Coleman & Fausch's CRCT values to WCT is coded `WCT` only for what it measured on WCT; a
  restated CRCT value is either left out (it is already a row) or coded `CRCT` with `cited_source` and a note saying
  the report applies it to WCT.
- Hartman & Scrivener (1990) Table 14 pools age-0 steelhead and cutthroat trout: one row per named species
  (`ST`, `CT`) with the pooling in `note`, or a single statement left in notes if the table does not separate them.
- `region`: the stream and province or state as the source gives it ("Harmer and Grave creeks, Elk Valley, BC").

## Checking your drafts

```bash
S=/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/3130e260-3b67-4e93-a484-21efb9d8b606/scratchpad
python3 $S/kt/merge_drafts.py <tag> $S/merge-<tag>
EVIDENCE=$S/merge-<tag>/evidence.csv REGISTRY=$S/merge-<tag>/registry.csv LOG=$S/merge-<tag>/verify.csv \
  Rscript scripts/0280-literature-verify.R
```

Every one of your rows (data rows after 1102) must pass in `verify.csv`, and the run must not print any new
failure. Fix and re-run until it does. Before you finish, re-read each row against its page: right species, stage,
bound, metric and unit, and a note that does not claim more than the page says. Make the LAST LINE of your reply
the path of your notes file and nothing else.
