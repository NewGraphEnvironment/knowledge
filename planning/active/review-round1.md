# Review round 1, #194 branch (base 89ee4d3a)

## Checklist read

- code-check-python.md: in full.
- code-check.md: all fourteen H3s under `## Mechanisms`, prose read (tables and evidence blocks skipped);
  from "Rules that stand alone", "Percent-encode a URL at construction, not at consumption" and
  "Documentation Staleness". The other 22 non-Mechanisms headings not read (no matching tool or shape in the diff).
- code-check-r.md: "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests" (1 of 121 read).
  The diff has no R code; the other 120 not read.
- code-check-shell.md: index only, 0 of 71 headings read (no shell code in the diff).
- code-check-spatial.md: index only, 0 of 94 headings read (no spatial code in the diff).

## What was checked

- `scripts/0270-habitat-collection-build.py`: the only change adds `publicationTitle`, `volume` and `issue` to the
  fields an additions row without a DOI carries. Additions files lacking those columns are unaffected (`row.get(k)`).
- `data/bull_trout_additions.csv` (144 rows) parsed with Python's `csv` as 0270 does: header holds every column 0270
  indexes directly (`DOI`, `title`, `creators`, `pdf`); itemTypes are `report` (130), `journalArticle` (9), `thesis` (5);
  no field is set that Zotero rejects for its itemType (report: institution/reportNumber/reportType/place/pages/url;
  thesis: university/thesisType/place/url; journalArticle: publicationTitle/volume/issue/pages/url); the 8 DOI rows go
  through CrossRef and the one DOI-less article (Fraley & Shepard 1989) carries its journal fields; creators split
  cleanly on `;` with balanced braces and at most one comma per person; every `pdf` is a local path that exists; no
  leading/trailing whitespace, no embedded newline, BOM or NBSP; LF endings, final newline.
- Re-run duplicates: rows sharing a normalized title (Peace River BT spawning, Kootenay Lake exploitation, Kinbasket
  juvenile) differ by first creator or year, which `group_copy()` checks; in dryrun3c all 174 rows resolve to 174
  distinct group keys, with no `would create/add/upload`.
- `data/bull_trout_members.csv`: the `mcmahon` URL is percent-encoded (`%20`); the new member `pdf` paths exist;
  they are read only when the group item lacks a stored PDF.
- `data/zotero_attachment_verdicts.csv`: the two `replace` rows match the header and the existing #151 `replace` row's
  shape (`item`, `attachments` = the old attachment, `file` = repo-relative path, empty `fields`), which `do_replace()`
  reads.
- Docs: CLAUDE.md and scripts/README.md claims checked against the data and logs (VHWEK6RE in the habitat_modelling and
  bull_trout_grayling build lists; COSEWIC 2012 and 2025, SARA South Coast and Western Arctic pages, BC 2023 plan,
  Alberta 2009 update, US 2010 rule and 2015 plan all present; 76 % / 3.6 GiB / 0.9 matches findings.md).
- Public-repo scan of every added line (CSV, docs, planning, `scripts/logs/rag/2026111[2-5]*`): no `/Users/`, user
  name, host name, credential path or private-repo link. The only `/User…` strings are tibble-truncated `origin`
  cells in `20261113_pull_habitat_modelling.log`, which show no user name (the same as the merged westslope log).

## Clean

No issues found.
