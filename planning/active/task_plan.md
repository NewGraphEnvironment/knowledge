# Task: First-winter size rows from the seven paywalled #47 candidates (#48)

#47's searchers rated seven works useful that had no open PDF. One has since been saved (Zabel & Achord 2004);
the other six are still paywalled. Al (2026-10-15) chose to use publisher abstracts where a PDF cannot be had
(option 1, flagged abstract rows) together with secondary citations in PDFs already held (option 3).

CrossRef carries an abstract for four of the six: Holtby 1988, Meyer & Griffith 1997, Brakensiek & Hankin 2007,
Bradford et al. 2001. Smith & Griffith 1994 and Connolly & Petersen 2003 have none.

## Phase 1: `abstract` quote source
- [x] `pkg/R/literature.R`: `quote_source` gains `abstract` (a quote from the publisher's abstract, held as the
  Zotero item's abstract because no PDF is); an abstract quote is running text (20-character floor) and carries
  no `page`. Roxygen says what it is and that it is a fallback.
- [x] Tests: vocabulary has it; a short abstract quote fails; an abstract row with a page fails; restore-the-bug.
- [x] `scripts/0280-literature-verify.R`: an `abstract` row resolves its key in the group, reads the item's
  `abstractNote`, and matches with the same token matcher (`verified_abstract`). It fails when the item has no
  abstract, and when the item has a PDF (quote the PDF then).
- [x] `scripts/0270-habitat-collection-build.py`: a DOI addition carries CrossRef's deposited abstract (JATS tags
  stripped); `pdf = none` marks an abstract-only addition, which is not a missing PDF. Blank stays a failure.

## Phase 2: Zotero and the store
- [x] `data/temperature_additions.csv`: the four abstract-only DOIs (`pdf` none); Zabel & Achord 2004, Manhard et
  al. 2018 (USFWS TR 2018-33) and Hartman, Scrivener & McMahon 1987 (Forestry Chronicle) with their saved PDFs.
  Not added: USGS OFR 2021-1085 (catchable-size hatchery rainbow trout, off topic); Lusardi et al. 2020 is already
  a member.
- [x] `0270 --collection temperature --dry-run`, then live; log under `scripts/logs/habitat/`.
- [x] Rebuild and push the `temperature` store once Zotero has synced; verify on a fresh connect.

## Phase 3: Rows
- [ ] Draft (about nine rows): Holtby 1988, Meyer & Griffith 1997, Brakensiek & Hankin 2007, Bradford et al. 2001
  from abstracts; Zabel & Achord 2004 from the PDF; Smith & Griffith 1994 as cited by Quinn & Peterson 1996.
- [ ] Blind meaning audit (Explore reader, canary first); fix; audit the fixes.
- [ ] `0280` passes with the new rows; log.

## Phase 4: Write-up
- [ ] `research/thermal_requirements.md`: the size section names the new rows and says which are abstract-only.
- [ ] `CLAUDE.md` above the marker: the `abstract` quote source convention.
- [ ] #48 body reconciled.

## Validation
- [ ] Tests pass
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
