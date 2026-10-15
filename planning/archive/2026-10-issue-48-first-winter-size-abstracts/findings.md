# Findings: first-winter size rows (#48)

## What arrived (2026-10-15)
Al saved into `data/rag/pdf/`:
- `Relating Size of Juveniles to Survival Within And AmongPopulati.pdf`: Zabel & Achord 2004, Ecology 85:795-806
  (doi:10.1890/02-0719), one of the seven.
- `EstimatingFreshwater...KlamathRiverCohoSalmon.pdf`: Manhard et al. 2018, USFWS Arcata TR 2018-33. Its overwinter
  survival models vary by year and site; no size covariate (grep for length/size finds none). No rows.
- `for chron.pdf`: Hartman, Scrivener & McMahon 1987, Forestry Chronicle 63:159-164 (doi:10.5558/tfc63159-3), a scan.
  Restates Holtby's Carnation Creek coho result (fall size -> winter survival) qualitatively. No rows.
- `ofr20211085.pdf`: USGS OFR 2021-1085, radio-tagged catchable hatchery rainbow trout (22-31 cm FL), Cowlitz. Off
  topic; not added.
- `Lusardietal2020.pdf`: already a member (`lusardi_etal2020Oversummergrowth`).

## CrossRef abstracts (checked 2026-10-15)
| work | DOI | abstract |
|---|---|---|
| Holtby 1988 | 10.1139/f88-060 | yes |
| Smith & Griffith 1994 | 10.1577/1548-8659(1994)123<0747:SORTDT>2.3.CO;2 | none |
| Meyer & Griffith 1997 | 10.1139/z97-007 | yes |
| Brakensiek & Hankin 2007 | 10.1577/T06-211.1 | yes |
| Bradford et al. 2001 | 10.1139/z01-165 | yes |
| Connolly & Petersen 2003 | 10.1577/1548-8659(2003)132<0262:BINABF>2.0.CO;2 | none |
| Zabel & Achord 2004 | 10.1890/02-0719 | none (PDF held) |

## Secondary citations in held PDFs
`pdftotext` over the 139 PDFs of the temperature, habitat_modelling and flow collections, grepped for the four
authors' names: only Quinn & Peterson 1996 (p. 1560) cites Smith & Griffith 1994, qualitatively (larger rainbow
trout survived better at warmer temperatures with rocky cover). No held PDF prints the 100 mm cutoff.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| 0280 `abstract_but_pdf_held` on six items with no attachment | NA parent ids of standalone PDFs; `%in%` (above) |

## 0280: every key carried NA PDFs (found 2026-10-15)
`resolve()` matched PDFs with `group_pdfs$itemID == ids`. A standalone PDF has no parent, so its `itemID` is NA,
and `==` returned NA for each of the group's 229 standalone PDFs, which `[` turned into NA entries in every key's
file list. `sort(files)` dropped them, so PDF rows never showed it; the first abstract rows, which test
`length(files)`, all failed `abstract_but_pdf_held` on items with no attachment. Fixed with `%in%`.
