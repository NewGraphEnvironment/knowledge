# Code-check round 1 (#216, branch diff 86088f67...HEAD)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables and evidence blocks skipped); and three
  stand-alone rules: "Test the cold/create path of idempotent code, not just the warm no-op", "A preview flag is only
  safe if it previews", "Documentation Staleness". The other stand-alone, Security and Spreadsheets/PDFs headings were
  not read (about 22): nothing in the diff uses what they name.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: no headings read. The diff has no R, shell or spatial
  code (one Python file, two CSVs and Markdown), so no heading names a tool, shape or pattern it uses.

## What was checked

- `addition_item()`'s `override`, run offline from the shipped module with only `crossref_item()` stubbed (a dummy
  key so 0153 loads; no network): each of the five override rows takes the row's title, creators or date and keeps the
  DOI and the stubbed abstract; a field outside `OVERRIDABLE` (`foo`) and an overridable field the row leaves empty
  (`volume`) both raise ValueError, which `main()` tallies as `ERROR` and exits non-zero on; blank tokens
  (`" ; title ;"`) are skipped. The check runs before `group_copy()` and before the dry-run return, so a dry run
  catches a bad override.
- Existing behaviour: no other `data/*_additions.csv` has an `override` column, so `row.get("override")` is None
  and every other collection still builds exactly `crossref_item()` for a DOI row. Nothing else in scripts/, R/,
  data-raw/ or tests/ reads the additions files.
- Ordering: the override commit (440ebcbf) comes before the first dry run and the live filing, and the group items
  now hold the override values (read from a guarded copy of zotero.sqlite with its -wal): 8F58A8NG, NQVDVEQA,
  QKK2RXN9, UB6D7BRC, ICWJ6ZZR. So no item was created with CrossRef's wrong fields before the fix ("Written data
  outlives the fix" does not apply).
- Re-run idempotence: `group_copy()` matches on the override title and creators, which are what was stored;
  live2/dryrun4 show every row `exists, member, pdf present`.
- CSVs: every row has the header's column count; every `pdf` path exists and starts with `%PDF`. The override values
  match the title pages (pdftotext p1-2) for MacKenzie 2002, Royle & Nichols 2003, Tyre 2003 and Royle 2004.
  Dorazio & Erickson's override title is the published one, not the manuscript's, which matches the decision in
  findings.md.
- Python floor: the file parses under the system's Python 3.9 (the new f-string uses double quotes outside and
  single quotes inside its braces).
- Prose against code:
  - The 0270 docstrings, and scripts/README's override line, describe what `addition_item()` does: the DOI and
    CrossRef's abstract stay, and a row with no `override` is CrossRef's alone.
  - The statistics tree in the group library is exactly LP4R4VYR, 73PNRGJF (detection, 24 items), K2P7XGFG and
    Z7JP8UN2, none in the trash. These match the README build line and CLAUDE.md.
  - "0150 reads only items filed directly in a collection" is true: `collection_keys()` joins `collectionItems` on
    the named ids with no recursion. It also `unique()`s keys, so the two members filed in both survey_design and
    detection go to cred once.
  - No tracked text still calls `statistics_*` "the sole input of the `statistics` store".
- Public discipline: the diff adds no host, home path, credential or private-repo reference.

## Clean

No issues found.
