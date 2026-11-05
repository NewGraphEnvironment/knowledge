# Code-check round 3 (#124)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (all fourteen), plus three stand-alone headings this
  review leans on: "Extracted PDF text carries corrupted glyphs, and a tolerant parser turns them into wrong numbers",
  "Percent-encode a URL at construction, not at consumption", "A stored value is not wrong just because the raw
  number looks wrong". The rest not read (none names a tool or shape in this diff).
- `code-check-r.md`: no heading read. The diff changes no R code, and the logs are R output only.
- `code-check-shell.md`: no heading read. The diff has no shell.
- `code-check-spatial.md`: no heading read. The diff has no spatial code.

## Scope of the metadata audit

All 69 rows of `data/sturgeon_additions.csv` were checked. 68 were read against their PDF: the copies Zotero holds for
the filed items (the paths in the scratchpad's `origins.txt`) and the six local files under `data/rag/pdf/sturgeon/`.
`pdftotext` gave the first four pages, and the cover was rendered as an image where its title is a picture (rows 33
and 34). The DOI row (line 69) types no metadata; its PDF is McAdam et al. 2005, TAFS 134:1448-1456, DOI
10.1577/T04-199.1, which matches. Checked on each row: title, creators, date, institution, report number and type.
Two rows are wrong. Both were confirmed in the group library from a copy of `zotero.sqlite` (with its `-wal`): the
live run filed them as written.

## Findings

- **[severity: bug]** `data/sturgeon_additions.csv:34`: the 2008 Lheidli T'enneh report (`2008AFSAR1090.pdf`) has
  the wrong title. The cover, rendered, and the running header on every page read "2008 Assessment of Upper Fraser
  White Sturgeon; Critical Habitat Identification and Refinement of Population Status". The row reads "...critical
  habitat identification, population assessment and capacity development", which is the 2007 report's title (line
  36, `2007_CH_Assessment_CSTC.pdf`, whose cover does say that). It was copied from the sibling row. The group item is
  `KSCZP9JS`, filed with the wrong title, and its Better BibTeX key derives from that title. Fix: correct line 34, and
  PATCH `KSCZP9JS`'s title through the Web API, which is a write for Al.
  - **Rule:** code-check.md "A proxy is not the property" (it audits the meaning row by row, ending on an
    enumeration). Also the repo CLAUDE.md, "Drafting evidence or registry rows": "Copy a sibling's fields only after
    checking them".

- **[severity: bug]** `data/sturgeon_additions.csv:48`: the 2005/06 Habitat Stewardship Program report
  (`Final_Report_0506_HSP_Final.pdf`) is dated `2006-03`. Its cover and title page both read "April 2006" (pdftotext
  lines 31 and 65; the PDF was created 2006-06-12). Its two sibling reports really are dated March: line 44 is March
  2007 and line 49 is March 2005. So the month looks inherited from that pattern rather than read off the page. The
  group item `QPIC5D8X` is filed as `2006-03`. Fix: `2006-04` on line 48, and a PATCH of `QPIC5D8X`'s date.
  - **Rule:** code-check.md "A proxy is not the property" (row-by-row audit). Also the repo CLAUDE.md on copying a
    sibling's fields.

- **[severity: security]** `planning/active/progress.md:55`: "The Zotero key moved to [path redacted after this review]" names the
  directory that holds a credential, in a tracked file of a public repo. The repo CLAUDE.md, "One discipline", bars
  credential file paths from tracked files. Its `planning/` allowance covers "what was removed, hosts and our other
  repositories", not where a live key now sits. #56 removed this exact path from `0153`, and `public_sweep.py` has a
  `key_path` pattern for it. But that pattern is exempt for `planning/active/`
  (`PARTIAL` keeps only `project_repo` and `local_path` there), and all of `planning/archive/` is exempt. So no sweep
  will ever report this line, and `/planning-archive` would keep it for good. Fix: drop the path, for example "The
  Zotero key moved; storage is unlimited (Al)."
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies": the sweep's exemption covers exactly the
    file that carries the hit.

- **[severity: fragile]** `planning/active/task_plan.md:55` says the 61 NWSRI downloads that returned `%PDF` came to
  "(168 MB)". `planning/active/findings.md:60` gives "174 MB with the recovery plan" for the same set. 168 MB is the
  plan reviewer's earlier figure for all 63 links (`review-plan.md:51`), not this measurement. Measured from the filed
  copies: the 59 technical-report additions total 172.5 MB, plus Antill 2013 (0.81 MB) and French 2005 (1.22 MB),
  which makes 174.5 MB for the 61, and the recovery plan adds 0.94 MB. No grouping gives 168 MB. The evidence record
  disagrees with itself, so the task_plan figure should be corrected. Every other number checked holds:
  - the 70 sources at 222.8 MB (206.9 + 14.4 + 1.5);
  - 15 members and 69 additions (64 + 5);
  - 12 added + 69 created + 3 existing = 84;
  - 43 + 27 + 14 = 84;
  - 83 origins;
  - 83 documents and 10,964 chunks, and md5 `7c8359e5…`, against the logs;
  - 151,531,520 bytes;
  - nine manifest stores.
  - **Rule:** code-check.md "One fact derived twice".

No home path (`/Users/`, `~/Projects`), host, client identifier or private-repo link was found in `planning/active/`
or the other tracked files in the diff. The `~/Zotero/...` and `~/` mentions are generic, and the build log's
`/User…` origins are truncated by the tibble printer.

Nothing new was found in `api()` (`0153`) beyond rounds 1 and 2.
