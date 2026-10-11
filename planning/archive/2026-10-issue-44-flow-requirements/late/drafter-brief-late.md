# Drafter brief: the six late flow sources (#44, after the PR opened)

One drafter, tag `late`. Working directory: `/Users/airvine/Projects/repo/knowledge`.

**Read first, in this order:**
1. `planning/archive/2026-10-issue-44-flow-requirements/drafter-brief.md`. This is the full brief: grid cells,
   row rules, quote rules and the gate check. Everything in it applies, with the corrections below.
2. `pkg/R/literature.R` and CLAUDE.md's "Drafting evidence or registry rows" section.
3. `planning/archive/2026-10-issue-44-flow-requirements/audit-ps-round1.md`, `audit-tc-round1.md` and
   `audit-round2.md`: the errors found in the first 325 rows. Do not repeat them.

## Your sources (all in `Fisheries/flow`; text in the scratchpad `txt/` as before)

| key | what | text |
|---|---|---|
| `hatfield_bruce2000PredictingSalmonid` | PHABSIM optimum flow regressed on MAD, by species and stage, western North America | `.txt`, `.layout.txt` |
| `bradford_heinonen2008LowFlows` | low flows and instream flow needs in small Canadian streams | `.txt` |
| `mcmahon1983Habitatsuitability` | coho HSI (FWS/OBS-82/10.49) | scan, `.ocr.txt` only, `quote_source` `ocr` |
| `raleigh_etal1984Habitatsuitability` | rainbow trout HSI (FWS/OBS-82/10.60) | scan with a garbled text layer; quote from `.ocr.txt` with `ocr` |
| `hickman_raleigh1982Habitatsuitability` | cutthroat HSI (FWS/OBS-82/10.5) | as Raleigh 1984 |
| `braithwaite2011effectstream` | cutthroat habitat preference, Strawberry River, Utah (MSc thesis) | `.txt` |

Write rows for **any species** these sources give. The grid species are CH, CO, SK, ST, BT, GR and WCT.
- Rainbow trout is `RB`, `ST` only where the source says steelhead or anadromous.
- Generic cutthroat is `CT`; `WCT` only where the source says westslope. Braithwaite's fish are Bear Lake
  (Bonneville) cutthroat, *O. clarkii utah*: code them `CT` and name the subspecies in the note.
- Standards that name no species take the group codes `FISH`, `SALMON` and `SALMONIDS`.

**Primary rows for values already in the table second-hand.** Data rows 810–817 and 827 cite Hatfield & Bruce
2000; 942–943 cite Hickman & Raleigh; 954, 955 and 960–964 cite Raleigh et al. 1984. A row from the original is
welcome. Its note names the second-hand rows ("the original of data rows 954, 955"). Do not edit those rows.

## Corrections and conventions settled since the first brief

- **`metric`.** Values for `instream_flow` are `instantaneous`, `daily_mean`, `7day_low`, `monthly_mean`,
  `monthly_median` and `unstated`. `seasonal_mean` is gone. Use `unstated` unless the page names the statistic.
  "Minimum monthly flow" does not say whether it is a mean or a within-month minimum, so it is `unstated`.
- **`bound`.**
  - **Three-class schemes.** The best class ("excellent") is `optimum`. The lower edge of an acceptable class
    is `min`.
  - **Observed spans.** A span of observed values (redd depths) is `range` with `kind` `dist`, and the note
    says it is observed, not a limit.
  - **Stream-size-dependent minimums.** A minimum that varies with stream size, given as two ends (30–200 %
    MAD), takes **no bound**, keeps both values, and the note says why.
  - **Regressions.** A regression with no tabulated value is a `qual` row with the equation in the note. If
    Hatfield & Bruce tabulate predicted optima for named MADs, or give species-and-stage coefficients, write
    the coefficients in the note. Write a value only where the paper prints one.
- **HSI curves.** The zero-suitability edges are limits (`min`, `max`, or one `range` for the pair, as you
  prefer). The SI 1.0 span is `optimum`. An interior breakpoint has a blank `bound`, with its SI in the note.
  - Pick one convention per source and keep it.
  - For a curve that pools two species (steelhead and resident rainbow), write one row per named species in
    your own draft, with each pair cross-referencing the other by draft position. I renumber the
    cross-references at merge.
- **Notes.**
  - **This row's page only.** A note says what this row's own page says. Do not borrow a method sentence from
    a neighbouring table or section, or summarise another source.
  - **Trace before attributing.** Trace a secondary attribution before using it for species or region. A
    region is a place the page names, or "Not stated".
- **Life stage.**
  - `spawning`: redds.
  - `incubation`: egg to emergence.
  - `rearing`: juvenile summer.
  - `overwintering`.
  - `migration`: adult upstream passage only. Smolt outmigration and adult holding are not written; say so
    in notes.
- **`none` rows.** Do not write `none` rows. The grid is already full. If a late source fills a cell that holds
  only a `none` row (CO flow needs, GR and WCT flow needs, BT and WCT passage depth), say so in your notes.
  I decide what happens to the `none` row.

## Produce, and check

In `planning/active/`:
- `draft-late-evidence.csv`, with the committed header (20 columns, `model_id` blank);
- `draft-late-notes.md`: per source, what you wrote, what you left out and why, anything unsure, and which
  `none` cells your rows now fill.

Check:

```bash
S=/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/f39c7eb7-ec59-4e3f-9d55-3cbc6a358fe6/scratchpad
python3 $S/merge_drafts.py late $S/merge-late
EVIDENCE=$S/merge-late/evidence.csv REGISTRY=$S/merge-late/registry.csv LOG=$S/merge-late/verify.csv \
  Rscript scripts/0280-literature-verify.R
```

Every one of your rows (data rows after 1014) must pass in `verify.csv`, and the gate must exit 0. Then audit
the meaning of each row against its page before you finish.

Do not edit any other file. Do not run `0270`, `0150` or git. Do not spawn subagents.
