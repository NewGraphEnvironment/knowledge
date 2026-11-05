# Code-check round 2 (#124)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables and evidence blocks skipped); from
  "Rules that stand alone", "Test the cold/create path of idempotent code, not just the warm no-op",
  "Percent-encode a URL at construction, not at consumption" and "Documentation Staleness"; the other 25
  headings not read (no tool, shape or pattern of theirs is in this diff).
- code-check-r.md: "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests"; the
  rest not read (the diff changes no R code; 0150-store.R was read as a consumer and is unchanged).
- code-check-shell.md: no heading read; the diff has no shell code (0 of its headings apply).
- code-check-spatial.md: no heading read; the diff has no spatial code (0 of its headings apply).

## What was checked beyond round 1

1. Docs against the scripts.
   - `scripts/README.md`'s `--collection sturgeon --parent 9U54XAND` line: 0270's argparse takes both
     flags and defaults `--members`/`--additions` to `data/<collection>_{members,additions}.csv`, so the
     two new files are read with no other flag.
   - `0150 ACTION=build STORE=sturgeon COLLECTIONS=WEUFTSDC`: 0150 takes `STORE` and `COLLECTIONS`, and
     `collection_keys()` matches a key or a name. A copy of the local zotero.sqlite shows `WEUFTSDC` is
     `sturgeon` under `9U54XAND` (`species`), which sits under `TRXPJHQE` (Fisheries), in library 9
     (group 4733734).
   - The claim that `0150` reads only items filed directly in each collection holds: the SQL joins
     `collectionItems` on the given collection IDs and does not recurse.
   - CLAUDE.md's "the same for `species/sturgeon`" carries the bull_trout/grayling sentence over correctly.
   - Build-log counts agree with the inputs: 15 members + 69 additions = 84 keys. 83 documents are in the
     store because tredger_etal1984 has no text. The collection's 86 rows are those 84 plus 2 trashed
     items.
2. CSV rows through 0270, end to end, checked against the items in the local database copy.
   - `addition_item()` passes `itemType`, `title`, `date`, `institution`, `reportNumber`, `reportType`,
     `university`, `thesisType`, `place` and `url` through unchanged, and every one is a valid Zotero
     field for `report` or `thesis`. The thesis row (babey2022) came out with university, thesisType,
     place, url and date set; the DFO 2007 report came out with institution, reportNumber, reportType,
     place and url.
   - The DOI row takes the CrossRef path and its empty columns are ignored. mcadam_etal2005 is in the
     collection.
   - `zotero:733T5ZJV` is a personal-library standalone (library 1, no parent). `addition_pdf()` reads
     `~/Zotero/storage/<key>/`, which is keyed by attachment and not by library. The directory holds one
     PDF, so this works even though 0270's docstring describes a group standalone.
   - Repo-relative paths resolve against the repo root, and `data/rag/` is git-ignored, so none of the
     PDFs is tracked.
   - Creators split on `;` and then on the first `,`. No creator holds a second comma, and corporate names
     become a lastName with an empty firstName, as the earlier additions files do.
   - Same-title rows (the three Carrier Sekani "Working towards..." reports) differ in year, so
     `group_copy()` keeps them distinct. All three are in the collection under separate keys.
   - No field has leading or trailing whitespace, no row is ragged, and no url or pdf value has a space or
     a non-ASCII character.
3. Other callers of `api()`. The only callers are 0153 itself (`existing_report_ids`, `upload`,
   `file_report`) and 0270, through `z`. No code in `scripts/`, `data-raw/` or `R/` expects an immediate
   429 or 503 from it. The Backoff sleep runs once per call and never inside a retry loop that repeats it;
   the S3 upload step in `upload()` calls `urlopen` directly and is unaffected.

## Clean
No issues found.
