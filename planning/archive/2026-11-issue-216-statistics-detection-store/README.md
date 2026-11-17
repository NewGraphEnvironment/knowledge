# #216: statistics store, the methods literature for detection and occupancy

## Outcome

- **Collection:** the group library's new `statistics/detection` (`73PNRGJF`) holds 24 works with their PDFs:
  occupancy, removal, eDNA, camera surveys and diversity, including Hutchinson et al. 2015, added mid-run.
- **Store:** `statistics` is now built from the whole statistics tree (decided at the gate): `LP4R4VYR`,
  `73PNRGJF`, `survey_design` (`Z7JP8UN2`) and `model_selection` (`K2P7XGFG`). It was rebuilt and pushed.
- **Gap:** 7 works with no PDF found, kept as a gap rather than filed (Al, after the search): Zippin 1958,
  Carle & Strub 1978, Moran 1951, Riley & Fausch 1992, and the three books.
- **How the PDFs were found** (Al's revision at the gate): course and author copies, CORE, SciSpace, publisher-free
  Wiley through Chrome on the second machine, and Al's ResearchGate downloads. Three are manuscripts, and their
  notes say so.

Learned:
- **CrossRef metadata is wrong often enough to need a remedy.** Five records disagreed with their title pages
  (titles in capitals, a split surname, an institution listed as an author, a lowercased "eDNA"), and CrossRef's
  pretty-printed `<scp>` markup turned "Hill" into "H ill".
  - 0270 gained an opt-in `override` column, which round 2 extended to items already filed.
  - Round 3 showed that 0270 recognised a held item by exactly the fields an override changes. It now matches on
    the DOI first.
- **OpenAlex abstracts are not a fallback.** Zippin 1958's carries another paper's text, and Carle & Strub's is
  garbled OCR.
- **One document is missing.** ragnar 0.3.1's chunker fails on Hedger et al. 2013's line-numbered manuscript;
  0.4.0 fixes it. The rebuild under 0.4.0 is #223.

## Measurement

| | before | after |
|---|---|---|
| `statistics` documents / chunks | 4 / 6,579 | 31 / 11,113 |
| `statistics` file | 94.6 MB | 153.9 MB |
| `statistics/detection` items with a PDF | – | 24 (19.0 MB) |
| `survey_design` items with a PDF | 0 | 2 (the shared members) |

- The build held to the expectations written before it ran: 32 keys, the same 15 items left out with "no live PDF",
  0 dropped. The 4 old documents rechunked (2CIVEIL4 went from 56 to 52 chunks), as #194 saw.
- The push's multipart ETag matched the file at 8 MiB parts.
- Each 0270 live run was followed by a dry run with 0 `would` lines.
- Query checks, reported only:
  - goodness of fit missed MacKenzie & Bailey 2004;
  - removal with falling capture probability hit Peterson et al. 2004;
  - multi-scale eDNA occupancy found 2 of 3;
  - richness and coverage returned 3 of the expected family.
- Code-check: round 1 clean; round 2 found 2 defects; round 3 found 1, inside round 2's fix. The loop ended on an
  enumeration of the 11 sites where 0270 compares rebuilt metadata with what the group holds
  (`enumeration_round3.md`).

## Evidence

`scripts/logs/rag/2026111[67]_*` (0270 dry and live runs, the measure, the expected outcome, the build, the queries,
the push); `enumeration_round0.tsv` (every row against its PDF and every library); `review-plan.md`,
`review-round*.md`, `enumeration_round3.md`.

## Owed

- knowledge#223: rebuild `statistics` under ragnar 0.4.0 so Hedger et al. 2013 joins (blocked by cred#43). It is
      filed as its own issue, so this item is done when that issue exists.

Closed by: the PR for #216
