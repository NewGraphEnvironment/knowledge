# Drafter brief: grayling habitat rows and grayling life history (#140, Phases 3 and 4)

Working directory: the repo root (branch `140-grayling-rebuild-link-s-default-from-the`).
Two drafters, each with one product. Read the repo's `CLAUDE.md` first, its "Drafting evidence or registry rows"
section in full: every convention there binds you.

| tag | product |
|---|---|
| `rows` | new Arctic grayling (`GR`) rows for `data/literature_evidence.csv` |
| `life` | a draft of `research/grayling_life_history.md`, every statement quoted |

## What you produce (only these files; write nothing else in the repo)

In `planning/active/`:
- `rows`: `draft-rows-evidence.csv` (rows to append, with exactly the header of `data/literature_evidence.csv`, 20
  columns) and `draft-rows-notes.md` (per grid cell below: what you found and where, or what you searched; what a
  source says that the table cannot hold; anything you were unsure of; every original a review cites for a value
  you used that is not in the source list below, with the review's page).
- `life`: `draft-life.md` (the research file) and `draft-life-notes.md` (what you searched, what you left out and
  why, and every original cited by a review you quoted that we may want to hold).

Do not edit any other file. Do not run `0270`, `0150`, `git` or anything that writes outside `planning/active/` and
the scratchpad below. Do not spawn subagents.

## Why

link's `default` for grayling was set to get started (rearing: gradient ≤ 3.49 %, channel width ≥ 1.5 m,
MAD ≥ 0.021 m³/s; spawning: ≤ 2.49 %, ≥ 4 m, ≥ 0.2 m³/s). The next step proposes values we stand behind, from what
the literature and grayling capture records say. Your rows and file are the literature half. They state what each
source says, never what link should use.

## Sources

Extracted text, one file per citation key, is in
`<scratchpad>/txt/`:
`<key>.txt` is reading order with `\f` (form feed) between pages; `<key>.layout.txt` is `pdftotext -layout`, for
tables. Page numbers: the number printed on the page; where none is printed, the PDF page, said in `note` ("PDF
page").

Grayling sources held, strongest first for habitat:
- `stewart_etal2007Fishlife` (NWT life history and habitat review; the table already holds 8 of its rows)
- `hagen_etal2015Criticalhabitats` (critical habitats, Williston)
- `hagen_etal2026futureArctic` (FWCP 2026 Upper Peace synthesis: habitat by life stage and core area)
- `stamford_etal2017FWCPArctic` (FWCP synthesis)
- `mcpherson2020Habitatuse` (habitat use thesis)
- `house2021Interdisciplinaryapproaches` (thesis)
- `hagen_stamford2023ParsnipArctic`, `hagen_gantner2020AbundanceTrend`, `hagen_etal2019TrendAbundance`
- `stuart_chislett1979AspectsLife` (Nation River life history, 1979), `tack1980Migrationsdistributions` (Alaska)
- `bottoms_etal2023Criticalhabitats`, `cutting_etal2018Linkingbeaver`, `hubert_etal1985Habitatsuitability` (HSI)
- `cannings_ptolemy1998RareFreshwater`, `martins_etal2020SpatialEcology`, `martins_etal2022SpatialEcology`,
  `carr_etal2020ImpactsVarying`, `beaudry2014Assessmentassignment`, `t_silva_etal2017futurefish`,
  `willsonVariationSalmonid`, `whyte_etal1997Restoringfish`, `culling1999BurntRiver`

The `bull_trout_grayling` ragnar store is at `data/rag/bull_trout_grayling.duckdb` (197 documents). Search it with
`Rscript -e 's <- cred::crd_store_connect("bull_trout_grayling", dir = "data/rag", verify = FALSE); r <- cred::crd_search(s, "grayling spawning gradient", top_k = 8); print(r[, c("citation_key", "method", "text")])'`.
A row whose `method` is `bm25` is a failed search: say so in notes and grep instead. Grep is usually faster.

A source not in this list may be cited only as `cited_source` on a row quoting a document we hold (a secondary
citation), and listed in your notes.

## `rows`: the job

Read `R/literature.R` (the reader refuses a bad row) and the existing rows: grep `data/literature_evidence.csv` for
`^GR,` (30 rows: depth, velocity, flow needs, one access row) and for BT's `gradient` and `channel_width` rows, which
show how a reach-scale statement, a site measurement and a `none` row are coded. Do not duplicate an existing row
(same key, page, value and stage).

Grid cells, each with the link parameter it bears on (the `parameter` column):

| variable | life_stage | parameter | what fills it |
|---|---|---|---|
| `gradient` | `spawning` | `spawn_gradient_max` | an upper limit, a range or where spawners or redds were found |
| `gradient` | `rearing` | `rear_gradient_max` | the same for juveniles (age 0 and older) in summer |
| `channel_width` | `spawning` | `spawn_channel_width_min` | a lower limit, a range or the widths used |
| `channel_width` | `rearing` | `rear_channel_width_min` | the same |
| `discharge` | `spawning` | `spawn_mad_min` | stream size as discharge (MAD or a stated flow) |
| `discharge` | `rearing` | `rear_mad_min` | the same |

Write **every** value a source gives for a cell, from each source, and a `qual` row for a statement with no value
that bears on a cell ("spawning occurs in low-gradient tributaries"). Where your search finds nothing for a cell,
write one `none` row (kind `none`, no value, unit, key or quote; the `note` names exactly what was searched, never
that no value exists). Extra rows are welcome where a source gives them: `stream_order`, `lake_area` (an adfluvial
population's lake), `substrate` (spawning), `groundwater`, `elevation`, and overwintering habitat (`life_stage`
`overwintering`, with no `parameter`), and spawning or rearing `depth` and `velocity` from a source the table does
not already quote for that stage. Leave temperature out (a separate topic).

Row rules beyond CLAUDE.md's:
- `species_code` `GR`; `life_history_form` `fluvial` or `adfluvial` where the source states it, blank where it does
  not (the vocabulary has no `lacustrine`: a lake-resident population's form goes in `note`).
- Spawning timing and temperature at onset are not rows here: the `life` drafter quotes them in the research file.
- `life_stage`: `spawning` (adults at spawning sites, redds or egg deposition), `incubation`, `rearing` (age 0 and
  juveniles in summer; adults' summer feeding is not `rearing`: put it in notes, or a row with `life_stage` `adult`
  if the vocabulary has it), `overwintering`, `migration`.
- `bound`: `max`/`min` for a limit, `range` for a span between two limits, `optimum` for a preferred span; blank
  for a value that is neither (a measured gradient at one site). `kind`: `dist` where fish were found, `pref` a
  preference from use and availability, `expert` a stated criterion or definition (a critical-habitat definition
  that says "≤ X %" is `expert`), `hsi`, `max_obs`, `qual`, `none`.
- `scale`: `site` for a redd or microhabitat, `reach` for a reach or stream, blank where unstated.
- Units: `percent` for gradient (a source's "m/km" stays out unless printed as percent: note it instead), a width unit
  (`m bankfull`, `m wetted`, `m`) as the source says, `m3/s` for discharge. Never convert; the gate checks the
  value against the quote.
- `region` free text (river, basin, province or state). `cited_source` names the original when you quote a
  review's report of another study, and CLAUDE.md asks you to read the original instead wherever we hold it.
- `model_id` blank. Append order: group your rows by variable, then stage.

## `life`: the job

Model the file on `research/bull_trout_life_history.md` (its header, its structure, its quote form
`"passage" (citekey, p. N)`), read in full first. Cover, for Arctic grayling, with BC and the Peace (Williston,
Parsnip, Upper Peace) first wherever the sources speak to them:
- the forms (fluvial, adfluvial, lacustrine) and how they mix;
- migration: spring movement to spawning, summer feeding, fall movement to overwintering, and the cues and dates;
- spawning: timing, temperature at onset as a stated fact (not a threshold row), sites and their gradient, size,
  substrate, depth and velocity as stated, natal fidelity;
- incubation, emergence, and age-0 habitat (margins, side channels, low velocity), and where fry drift or move;
- juvenile and adult summer habitat, including stream size and gradient;
- overwintering habitat;
- what limits them (temperature, barriers, flow), only as the sources state it.

Where a statement is also a value the `rows` drafter writes (a spawning gradient, a width), quote it here as a
statement and say in `draft-life-notes.md` that it is also a candidate row; the evidence table holds the values.

Every factual sentence carries a quote. A statement no held source makes is left out and listed in notes. Keep the
plain-language lead short; the file is a reference, not an argument.

## Quotes: the gate is exact

`scripts/0280-literature-verify.R` checks every quote against the cited PDF.
- **`text` quotes** are verbatim running text, at least 20 characters, compared as token sequences after light
  normalisation (case, quote marks, dashes, ligatures). Skip a stretch with ` ... `; each fragment at least 3 tokens,
  in order, close together. A `[bracketed insert]` is not matched. A quote may not stop inside a number or a range.
- **`table` quotes** are a table row's tokens in order, as on the `-layout` text, within three lines, no cell
  skipped, with at least one number and one word.
- **Every value must be printed in the quote itself**, as written.
- A line-end hyphen the text layer drops (`lateAugust`) is a sign the page needs OCR: quote it with `quote_source`
  `ocr` (rows) or `, OCR` after the page (life), as `bull_trout_life_history.md` does.

### Meaning is what fails, not words

The gate proves a quote is verbatim and a value sits in it. It cannot see a row or sentence that says the wrong
thing around a true quote. On #29 every quote verified and an audit still found 22 errors of meaning; on #198, 44
in three rounds, most of the later ones inside earlier fixes (a dropped hedge, a life stage mixed up, a place a fix
invented). Before you finish, re-read each row or sentence against its page: right species, stage, form and place;
a limit kept apart from where fish happened to be; the hedge kept; a note or sentence that claims no more than the
page.

## Checking your draft

```bash
S=<scratchpad>
# rows
{ cat data/literature_evidence.csv; tail -n +2 planning/active/draft-rows-evidence.csv; } > $S/merge-rows.csv
EVIDENCE=$S/merge-rows.csv LOG=$S/verify-rows.csv QUOTED= Rscript scripts/0280-literature-verify.R
# life
QUOTED=planning/active/draft-life.md LOG=$S/verify-life.csv Rscript scripts/0280-literature-verify.R
```

What you need: every one of your rows (data rows after 1189) or quotes passes in the log. A failure elsewhere is
not yours; name it in notes. A run can take minutes on a first OCR.
