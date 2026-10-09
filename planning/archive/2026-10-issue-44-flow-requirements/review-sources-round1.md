# Review: five flow sources filed to Fisheries/flow (staged diff), round 1

Reviewer: subagent, 2026-10-09. Read-only; `0270 --collection flow --dry-run` was the only script run.

## Findings

- **[severity: bug]** research/flow_requirements.md:14 — the Status line says "Four sources arrived after the rows
  were drafted and are not yet read for rows", but the list it points to (lines 121–130) names **five** undrafted
  sources: Hatfield & Bruce, Bradford & Heinonen, McMahon, Raleigh 1984 and Braithwaite. Four is the count of
  the earlier gap list that was filled (Hickman & Raleigh is still missing). Braithwaite is new and also undrafted,
  so the count should be five.

- **[severity: bug]** research/flow_requirements.md:131–132 — "Not obtained: Hickman & Raleigh 1982 … USGS lists no
  digital copy, a DTIC search found none, and the USFWS digital library … has been retired." Each clause is true
  (pubs.usgs.gov/publication/fwsobs82_10_5 says it has no digital link, and digitalmedia.fws.gov now redirects to
  fws.gov/search/images with a 403), but the report **can** be obtained. The Internet Archive holds it as item
  `doi-report_i-499782-105`, "Habitat Suitability Index Models: Cutthroat Trout … FWS/OBS-82/10.5 … February 1982".
  It has `doi-report_i-499782-105.pdf` (4.5 MB, "Text PDF") and a DjVu OCR text whose first lines read
  "HABITAT SUITABILITY INDEX MODELS: CUITHROAT TROUT / Fish and Wildlife Service". To download it:
  `https://archive.org/download/doi-report_i-499782-105/doi-report_i-499782-105.pdf`. The note also says this
  is the source likeliest to fill a WCT cell, so the gap is avoidable and worth closing: add an additions row
  (report, FWS/OBS-82/10.5, Hickman, Terry; Raleigh, Robert F., 1982-02) with that PDF.

- **[severity: fragile]** research/flow_requirements.md:121 — Raleigh et al. 1984 sits under "In the collection
  since 2026-10-09", but it was already a collection member before (`3VBWEZZV`, a member row in the earlier
  build). What arrived on 2026-10-09 is its PDF (log: `member, pdf uploaded`). This is a minor misstatement.
  Bullet wording such as "obtained (or, for Raleigh 1984, given its PDF) on 2026-10-09" would be accurate.

- **[severity: fragile]** scripts/logs/habitat/20261009_flow_store_push.txt:121–126 — the store pushed to
  `s3://fresh-bc/rag/flow.duckdb` records `head_sha 7694eca`. At that commit `data/flow_additions.csv` has 9
  additions and `flow_members.csv` gives Raleigh no PDF, so the manifest names a commit that cannot rebuild the
  39-document store. The changes that produced it are only staged. The pushed artifact will outlive this, so
  after committing, consider re-running the push to restamp the manifest, or say in the commit message which
  commit the store was really built from.

## Checked and found correct

- **0270 `addition_item()`.** A row field is copied only when `row.get(k)` is truthy, so:
  `habitat_modelling_additions.csv`, which lacks both new columns, gets `None` and skips them. No report row in
  either additions file has `university` or `thesisType` filled in. The one thesis row has an empty
  `institution`, `reportNumber` and `reportType`. I checked every non-DOI row in `flow_additions.csv` against the
  Zotero field set for its type, and none sends a field its type rejects. DOI rows go through CrossRef and ignore
  the row's fields. Nothing else reads the additions CSVs. A future report row that fills `university` would be
  rejected by the API with `CREATE-FAIL` and nothing written, which is loud and not silent.
- **Idempotency.** `0270 --collection flow --dry-run` reports `26 members, 13 additions | exists 13 | member 39 |
  pdf 39`. All four new additions resolve through `group_copy()` to the keys the live run created (H76NT4AD,
  36P8AUWU, KKURZK5S, 27VAM7NU) with `pdf present`, and none would be created again.
- **Existing additions rows.** I parsed HEAD and the index. The 9 old rows are identical apart from two new
  empty fields each, and the header gains `university,thesisType` between `reportType` and `place`.
- **Metadata against the title pages:**
  - **Hatfield & Bruce 2000:** NAJFM 20:1005–1015, DOI matches the PDF's cite line. The abstract confirms
    "PHABSIM optima for four life history stages of four salmonid species" regressed on MAD.
  - **Bradford & Heinonen 2008:** CWRJ 33(2):165–180, DOI matches. The referenced PDF is the 16-page article
    without the T&F cover. A 17-page cover-page duplicate sits unused in the same gitignored directory.
  - **McMahon 1983** (OCR of p.1/3/4): FWS/OBS-82/10.49, September 1983, "Habitat suitability index models: coho
    salmon", Thomas E. McMahon, U.S. Fish and Wildlife Service, Washington, DC. All fields match.
  - **Raleigh et al. 1984** (OCR): FWS/OBS-82/10.60, January 1984, "Habitat suitability information: rainbow
    trout", Raleigh, Hickman, Solomon, Nelson. This matches the existing item's creators and the
    `raleigh_etal1984Habitatsuitability` key, so it is the right PDF for that member.
  - **Braithwaite 2011:** DigitalCommons@USU "5-2011", Master of Science, Utah State University, Logan, Utah,
    etd/950. All fields match. The abstract says "Bear Lake cutthroat trout Oncorhynchus clarkia utah" (the
    source's misspelling), so the research note's "Bear Lake (Bonneville) cutthroat, *O. clarkii utah*, not
    westslope" is correct.
- **Citation keys.** I looked up all five in a copy of zotero.sqlite, scoped to group 4733734, and each key the
  research file names exists on the item the log names.
- **Counts.** "39 items, all with a PDF" matches the build log (`member 39 | pdf 39`), the store log
  (`docs: 39`) and the push manifest (`documents: 39`). 26 members plus 13 additions is 39.
- **Logs.** The three logs hold no keys, tokens or credentials. They contain local `/Users/airvine/Zotero/storage`
  paths and the bucket name, which `CLAUDE.md` already names, in a private repo.
- **PDFs.** Every `pdf` path is under `data/rag/` (gitignored), and no PDF is staged.

## Note (not a defect in this diff)

The store holds **no text** for the McMahon coho scan (0 characters in `documents.text` of the pushed
`flow.duckdb`, the same as the Hubert grayling scan and four other older items). The Raleigh 1984 scan has only a
garbled text layer. Neither will turn up in a store search. Rows from them have to go through `0280`'s OCR path
(`quote_source = ocr`), as the Hubert rows did. The research file does call both "a scan", but a drafter relying
on the store would miss them.

/Users/airvine/Projects/repo/knowledge/planning/active/review-sources-round1.md
