# Code-check round 3 (terminating enumeration): #190 branch (reviewer, 2026-11-10)

## Checklist read

- `_checklist.txt`: read in full. That covers the whole index of `code-check-python.md` (7 rules) and every index line
  of `code-check-r.md` (~120), `code-check-shell.md` (~85), `code-check-spatial.md` (~95) and `code-check.md`
  (Mechanisms, Rules that stand alone, Security, Spreadsheets and PDFs). The diff has no R, shell or spatial code, so
  no section of those three files applies.
- `code-check.md`, `## Mechanisms`: I read the prose of all fourteen H3s and skipped the `|` evidence rows. They are:
  A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property (including
  "A verbatim-quote gate certifies the words, not the meaning of the row built around them, so audit meaning row by
  row and end on an enumeration"); Verification that reads its own output; A guard's scope, escape hatches, and
  remedies (including "Terminate by enumeration, not by a reviewer saying you have converged"); A fix lands in one of
  two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what
  generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things;
  The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One
  fact derived twice.
- I also read `planning/active/review-round1.md` and `review-round2.md` in full.

## Method

I enumerated every field instead of sampling.

- **Matching rows to items.** I matched each additions row to its item in `_pdfmap.csv` by title. 47 of 49 matched
  directly. Row 28's title is shared with the member `lamson2020EvaluationCurrent`, so I took the 2016 item
  `ZBN2D69S` (UF-F16-105). Row 33 matched by key `CQZTEEXK`, because the local Zotero title is still the pre-PATCH
  form, as round 2 recorded.
- **Building each line.** For each non-empty field, the snippet is a whole stripped line of `pdftotext -f p -l p`
  output for the row's own PDF.
- **Checking each snippet.** A separate pass reran `pdftotext` per page and confirmed every snippet is a substring of
  a line on its page. 0 of 289 non-special lines failed.
- **Image-only covers.** Rows 26 and 41 have covers with no text layer. I rendered both and read them. Their cover-only
  fields are `NOT PRINTED`, with what the image reads given in the verdict.
- **Short lines.** Three snippets are whole lines shorter than 12 characters, because the document prints the value
  nowhere else: row 28 `UF-F16-105`, row 30 `March 2016` and row 32 `March 2020`. Their verdicts say so.
- **Field counts.** title 49, creators 49, date 49, institution 49, reportType 49, place 36, reportNumber 9. The
  additions have no non-empty university, thesisType or DOI. Every non-empty field has exactly one line, checked
  mechanically against the CSV.
- **Empty `place` rows.** Thirteen rows have an empty `place`: 8, 17, 22, 23, 26, 27, 28, 29, 31, 32, 33, 41 and 43. I
  read each one's title page or cover and its citation line for a place of the institution. None prints one, so there
  are no `MISSING` lines.
  - Teck rows: "Submitted to: Teck Coal Limited" or "Prepared for: Teck Coal Limited" with no address, and citation
    lines with no place.
  - FWCP rows 28, 29, 31 and 32: only the preparer's address.
  - Memo row 43: "TO: Teck Coal Limited".
- **Members.** For the 9 members with a PDF, I read each PDF's first page against the work its key names.

## Findings

- **[fragile (data)]** `data/westslope_cutthroat_additions.csv:9` (additions row 8, Upper Fording synthesis,
  `V57ESMCK`): `reportType` is "Report prepared for Teck Coal Limited by Evaluation of Cause Team". The document's own
  "When citing the Evaluation of Cause Report use:" line (p2) reads "… Westslope Cutthroat Trout population. **Final
  report** prepared for Teck Coal Limited by Evaluation of Cause Team. December 2021."
  - The row's wording is the one in two other places: the Harmer synthesis's title page (row 33) and the Upper Fording
    SME reports' quotation of this line (row 10's p6 reads "Report prepared for Teck Coal Limited by Evaluation of
    Cause Team.").
  - It is the same shape as round 2's row 26 finding: a series wording, not the row's own citation. Elsewhere the file
    carries a document's status word where its own line has one (row 32, "Draft final report prepared for …").
  - The value is not false, only not the document's. Fix: "Final report prepared for Teck Coal Limited by Evaluation of
    Cause Team", with the matching PATCH of the item. Optionally narrow `date` to `2021-12`, since the same line gives
    "December 2021".
  - **Rule:** code-check.md "A proxy is not the property" (a verbatim gate certifies the words, not the meaning of the
    row built around them: audit meaning row by row and end on an enumeration)

No other line is WRONG and none is MISSING. Rounds 1 and 2 fixed rows 26, 30, 31, 32, 33, 41, 43 and 47-49, and each
of those fields now matches its own document (see those rows' lines in the TSV).

## Notes (checked, not findings)

- **Row 22 `reportType`.** The citation line ends "… by Golder Associates Ltd. Draft for discussion." The issued cover
  (19136042/RO3, April 22 2021, "Issued: April 20, 2021" in its distribution list) carries no draft mark, so leaving
  the stale "Draft for discussion" out is right. The row's `reportNumber` takes p3's `19136042/R03` (digit zero); the
  cover prints `RO3` with the letter O.
- **Row 4 `place`.** "Vancouver, British Columbia" is the news release's dateline, the only place the release prints.
  Row 3 gives ECCC Gatineau from page metadata. Each follows its own source, a dateline being the conventional place
  for a release.
- **Row 26 `date` and `institution`.** The date (2021-05-10) and "Teck Coal" are from the image cover. The text
  Preferred Citation gives "2020 … November 9 2020" (a draft's) and "Teck Coal Fording River Operations", which the
  row's `reportType` now follows. Both values are the document's own.
- **Row 23 creators.** The signature page's OCR drops Henry's name ("ce"). He is named on p28 ("Henry, C., &") and p30
  ("Mr. Chris Henry is a hydrogeologist …"); Humphries signs on p2.
- **Row 33.** The local `zotero.sqlite` still holds `CQZTEEXK` under its pre-PATCH title, as round 2 noted. The CSV
  row matches its document.
- **Round 2's stale line.** `findings.md:206` now reads "(Harmer Creek Evaluation of Cause Team)", so that finding is
  fixed.

## Members (pdf)

All 9 PDFs are the works their keys name:

- `b_c_ministryofenvironment2014ManagementPlan`: BC MoE plan, Dec 2013, updated Aug 2014.
- `brown1998Fallearly`: Env. Biol. Fishes 55, 1999.
- `cope_etal2016UpperFording`: Population Assessment and Telemetry, Dec 2016.
- `cope_etal2017UpperFording`: Population Monitoring Project 2017.
- `elkriveralliance2020ElkRiver`: WCT Research Initiative 2019 Report.
- `lamson2020EvaluationCurrent`: Final Report UKE-F19-F-2682.
- `muhlfeld_etal2016GeneticStatus`: TAFS 145:1093-1109.
- `schweigert_etal2017COSEWICassessment`: COSEWIC 2016.
- `taylor_mochnacz2013ProtocolNative`: Banff protocol, December 2013.

## TSV

`planning/active/review-round3-evidence.tsv`: 300 lines, which is the header plus 299 data lines (290 additions-field
lines + 9 members `pdf` lines).

| verdict | lines |
|---|---|
| OK | 298 |
| WRONG | 1 (row 8 reportType) |
| MISSING | 0 |

Snippet sources: 4 lines are `CATALOGUE` (accepted sources), 6 are `NOT PRINTED` (4 on image-only covers, 2 that
describe the item's form), and 289 are verbatim lines.
