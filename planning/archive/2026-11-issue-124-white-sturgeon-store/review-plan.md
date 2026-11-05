# Plan review (#124), Plan agent, 2026-10-31

The reply verbatim, extracted from the transcript by script. findings.md records how each finding was handled.

## Review of #124's plan (planning/active/task_plan.md) against #124, #127, `0270`, `0150`, CLAUDE.md and the #122 archive

I made no writes. Besides reading files I ran a few read-only checks:
- an `immutable=1` read of `zotero.sqlite`;
- `ls` and `md5` on files in `~/Zotero/storage`;
- `curl` GET and HEAD requests on the NWSRI reports page and one CrossRef query.

**Headline:** the #127 boundary is right. Two things need fixing before Phase 1 writes the CSVs: the UFFCA member row, and the `pdf = none` rule.

### Blocker
1. **The UFFCA report should not be a member under its personal key. It is the same report the group already holds, and the md5 test would wrongly call it distinct.**
   - What `0270` does with that key: it finds only the personal item (`0270:514-534`). It then searches the group by title through the Web API (`group_copy`, `0270:267-295`), and `/items/top` leaves out trashed items (CLAUDE.md:188).
   - What the database shows:
     - `KHRI3JZZ` is a `journalArticle` with no date, titled "A report prepared by the Upper Fraser Fisheries Conservation Alliance (UFFCA) and the Nechako Fisheries Conservation Program".
     - The trashed group copy `Z9BNRLJL` has the same title and the same PDF bytes (storageHash `9160086608fac6a6533b5533aba378ea` on both).
     - The live group item `AFM6VEG9` (`levy_nicklin2018ChinookSockeye`, "Chinook and Sockeye Salmon Conservation in the Netʃa Koh (Nechako) River…", 2018) has a different md5 (`9c71269e…`). Its stored file has the same name, though: "Levy and Nicklin - A report prepared by the Upper Fraser Fisheries Co.pdf".
   - So the plan's md5 check (task_plan.md:63-64) would say "distinct", and the live run would recreate the item someone already trashed, with its bad metadata (no year, so a BBT key with no year).
   - **Fix:** settle it by reading the content, not by md5. It is almost certainly the same report, so either use `levy_nicklin2018ChinookSockeye` as the member or leave it out. Never use `levy_nicklinreportprepared`. Update decision 2 (task_plan.md:46-47) to match.
2. **No `pdf = none` row can pass the "exit 0" proof unless it has a DOI and CrossRef holds an abstract.**
   - A non-DOI row never reads an abstract (`addition_item`, `0270:379-386`). A `none` row with no abstract ends as `ABSTRACT-MISSING` (`0270:453-454`), and any upper-case step makes the script exit 1 (`0270:509-511`).
   - That applies to the Babey thesis, to any grey-literature `none` row, and to a DOI whose CrossRef record has no abstract.
   - The task_plan.md:89 no-op dry run therefore cannot exit 0.
   - The only precedent is DOI rows that have abstracts (`data/temperature_additions.csv:10-13`).
   - **Fix (task_plan.md:57-59):** write `none` only for a DOI with a CrossRef abstract. Leave everything else out and list it in the no-PDF gap.
   - I checked one: McAdam 2005 (`10.1577/T04-199.1`) has a CrossRef abstract.

### Answers to the six questions
**Q1. Personal-library item and personal standalone PDF.**
- **Copying a personal item works.** When the key is in no group item, `0270` copies `hits[0]`, which can be from any library (`0270:527-542`). It builds the copy from that item's local fields (`item_json`, `0270:181-203`) and uploads the PDF from any library's item with the same title (`0270:544-547`, `local_pdf` `0270:129-161`). The bad-metadata problem in Blocker 1 still applies.
- **A personal standalone PDF works in an additions row, and no copy into the repo is needed.** `addition_pdf` reads `~/Zotero/storage/<key>/` without checking which library the key belongs to (`0270:393-400`).
  - `Y2RWLG9W` (Chronology-NFCP.pdf) and `733T5ZJV` (Nechako_Watershed_Strategy-31Oct2016-FINAL.pdf) are both stored files with exactly one PDF each.
  - So `zotero:Y2RWLG9W` and `zotero:733T5ZJV` work as they are.
  - If you keep the path form, follow the precedent `data/rag/pdf/<collection>/` (scripts/README.md:409, `data/rag/pdf/flow/`), not bare `data/rag/pdf/` (task_plan.md:65-66).

**Q2. Item types, columns, and limits.**
- **Columns read.** `itemType, title, creators, date, institution, reportNumber, reportType, university, thesisType, place, url, bookTitle, pages, series, seriesNumber`. `DOI`, `creators` and `pdf` are read by direct lookup, so those columns must exist (`0270:374-386, 392, 430, 496`).
- **Creators.** Every creator becomes an `author`, split on `;` and then on the first comma. A corporate name containing a comma would be split in two.
- **Report:** supported.
- **Government document:** Zotero has no such item type, so use `report`.
  - Don't fill `series`/`seriesNumber` on a report. Those are book-section fields; a report's field is `seriesTitle`, which `0270` doesn't support.
  - Put "CSAS Science Advisory Report 2007/014" or "Species at Risk Act Recovery Strategy Series" into `reportType`/`reportNumber` instead.
- **Thesis:** supported through `university` and `thesisType`.
- **DOI rows:** CrossRef supplies all the metadata and always sets `journalArticle` (`0270:363`). A thesis or report DOI would be filed under the wrong type (CrossRef returned type `dissertation` for `10.24124/2022/59276`, a Nechako white sturgeon thesis). Use DOI rows for journal articles only.
- **Limits for ~65 rows:**
  - CrossRef is used only for the handful of DOI rows, so it is no concern.
  - The Web API is about 7 calls per new addition, roughly 450 in all. `z.api` has no handling for 429 responses or Backoff headers (`0153:85-95`). A throttled row fails that row with `ERROR`, and a re-run recovers it.
  - **Storage quota:** I measured the NWSRI page at 63 unique PDF links totalling **168 MB**, the largest 19 MB. The group's Zotero storage quota is unchecked. If the quota is exceeded, the file upload is refused and the row shows as `PDF-FAIL auth-fail 413` (`0153:199-202`). Check the group owner's storage before the live run.

**Q3. Is #127 the right boundary?**
- **Yes.** #127 measured that a copy of the main file alone will not open, so `db()` (`0270:65-106`) cannot produce a snapshot while a `-wal` file exists. `0150`'s reads use `immutable=1` (`0150:55`), and so does cred's build. Both miss new items and their PDFs.
- **The plan's Phase 1 dedupe (task_plan.md:62-64) needs Zotero reads.** A safe split:
  - **For "is it absent from the group?", use the Web API.** It is live; `/items/trash` covers the trashed copies, and attachment `md5` comes straight from the API.
  - **For "is it present?", an `immutable` read of the main file is fine for long-checkpointed items.** It only ever misses recent writes; it never invents rows. That is what I used to confirm the Levy hashes above.
  - **For personal files, hash `~/Zotero/storage/<key>/*.pdf` directly.**
- **Option for Al, not tested:** quitting Zotero should checkpoint the WAL, which would let `0270` and `0150` read a complete file without #127. `~/Zotero` currently also holds `-shm` and `.tmp-wal` files, so test this before relying on it.

**Q4. Must each member key resolve to exactly one group item?**
- **Yes.** Two or more live group items with the key gives `AMBIGUOUS`; no item in any library gives `MISSING` (`0270:518-523`). Trashed items are excluded (`0270:115-116`).
- **Shared keys pick the group copy.** For keys held in both libraries (Helm, Tredger, Albers), `group[0]` is used whenever a group item exists (`0270:525-526`). The personal copies are used only as a PDF source, and only when the titles match.
- **Members CSV detail:** the plan's "`PH5REA3P` with its PDF URL" (task_plan.md:67-68) must be written as the citation key `nechakowhitesturgeonrecoveryinitiative202420232024annual`, not the item key. Its URL (without `www.`) returns 200 `application/pdf`, 14 MB.

### Gaps
- **What to do with a trashed hit is undefined.** `0270` cannot see trashed items, so it will create a new item anyway. The plan should say: restore the trashed item (PATCH `deleted: 0`) and list it as a member, or record why a new one is acceptable (CLAUDE.md:186-192).
- **The Ferrington md5 test decides nothing.** `PPMDY4K7` hashes `f017203f…`; `farrington_lance2014`'s attachment `VJ3R55DR` hashes `449359da…`. The titles differ too ("Monitoring of Sturgeon" against "Development of Genetic…"). The plan should say what follows: either it is a separate document and gets an additions row `zotero:PPMDY4K7`, or it is out of scope.
- **NWSRI page facts to record in Phase 1:**
  - The links are relative (`uploads/Reports/…`), so they must be joined to the site root with `%20` encoding kept.
  - One link is dead: `uploads/Reports/3812%20Sturgeon%20Report%20Final.pdf` returns 404 HTML.
  - One file is linked twice: `022-7020 Final_lowres.pdf`, under both `uploads/files/` and `uploads/Reports/`.
  - "2013 White Sturgeon Ageing and Biochronology Report (Oct 2013)" is probably the Antill 2013 work already keyed.
  - "2021_Williamson-Toth-Gantner-2021-WhiteSturgeonMovement" may have a DOI.
- **Dry runs don't fetch addition PDFs.** A dry run returns "would create" before fetching an addition's PDF (`0270:421`). The Phase 1 `curl` check is the only test of those URLs before the live run. Repeat it before Phase 2 if the branch sits parked for long.
- **Undecided items:**
  - The two NWSRI webpages (`6CRM75L3`, `3CVKLDY8`) and the Upper Fraser critical habitat order (findings.md:53) are neither included nor excluded.
  - Phase 4 should state that `WEUFTSDC` does not join the `habitat_modelling` build. That build already names the bull_trout and grayling collections (scripts/README.md:126).

### Public-repo checks (Q5)
- Nothing in the plan puts non-public material in tracked files.
- `planning/active` has no hits for the #56 `local_path` pattern.
- I ran all 63 NWSRI URLs through the sweep's `project_repo` regex (public_sweep.py:28): no hits.
- **Gap — build log:** #122's build logs printed full home paths for every ingested PDF, and they had to be rewritten as `~/` (#122 review rounds 2-3). Phase 3 (task_plan.md:84) should require the same redaction, and run the `local_path` pattern over the new logs by hand, because the sweep skips all of `scripts/logs/` (public_sweep.py:37). The plan does cover trimming the push log (task_plan.md:88).
- **Text in the CSVs:** `why`/`source` text must not name a client or project for the "Nechako side-channel work" (CLAUDE.md:104-106). The `url` column for the personal standalones should be a public source URL or left empty.

### Ordering
- **The "blocked by #127" task belongs in #124's body now**, as decision 1 says (task_plan.md:44), not in Phase 4 (task_plan.md:94). The branch may sit parked before Phase 4 is reached.
- **cred is a separate gate.** #127 only raises cred's blind spot with a reprex. If cred is still unfixed when #127 merges, `crd_store_build` will still read `immutable`. Phase 2's "or follow whatever #127 settled for cred" (task_plan.md:74-75) should become a hard gate: a released cred fix, or a confirmed checkpoint before building.

### Assumptions
- **Exploration only shows what is present.** Its "absent" claims (the federal documents, Rood & Neill, Hay) came from an `immutable` read. Re-check them against the Web API before adding rows.
- **The personal standalones haven't been deduped.** `Chronology-NFCP.pdf` and the 2016 Watershed Strategy are not shown to differ from group items such as `nfcptechnicalcommittee2023NechakoFisheries` and `fraserbasincouncil2015NechakoWatershed`.
- **`group_copy` false matches:** many NWSRI reports have generic titles under the same corporate author. Phase 2's check of every `exists` gkey (task_plan.md:76-77) covers this; keep it.

### Scope
- **Adding PDF-less journal articles exceeds decision 3.** Decision 3 is "every technical report on the page that has a PDF" (task_plan.md:48). Adding McAdam, Smith and French & Chambers by DOI as `pdf = none` goes beyond it (task_plan.md:57-59), and `0150` drops them from the store anyway. Get Al's yes, or record them in the gap list only.
- **The two personal standalones (task_plan.md:65-66) are not in decision 2's curated list** (task_plan.md:45-47). Add them to the decision or drop the step.

### Acceptance
- **The three smoke queries have no pass criterion** (task_plan.md:86-87). Name the keys each should return in its top 5 (for example, the NHC substrate and sediment reports and Rood & Neill if found for side-channel loss; McAdam 2005 and Antill 2013 for recruitment).
- **Missing before/after table.** Add one like #122's (live items and items with a PDF in `WEUFTSDC`), plus the total MB uploaded.

### Critical Files for Implementation
- scripts/0270-habitat-collection-build.py
- scripts/0150-store.R
- scripts/0153-reports-to-zotero.py (`api`, `upload`)
- planning/active/task_plan.md
- data/temperature_additions.csv (has the widest column set and the only `pdf = none` precedent)
