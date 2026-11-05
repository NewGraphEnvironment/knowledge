# Review round 1 (#124 branch: sturgeon collection, store, and the `api()` retry)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all fourteen H3s under `## Mechanisms` (table rows skipped). Of the stand-alone
  rules, I read "Percent-encode a URL at construction, not at consumption", because the CSVs carry URLs. I did not
  read the other stand-alone headings: none names a tool or shape this diff uses.
- `code-check-r.md`: no headings read. The diff changes no R code. The CSVs are read by Python's `csv` module, and
  0150 reads only collection keys from Zotero.
- `code-check-shell.md`: no headings read. The diff has no shell code.
- `code-check-spatial.md`: no headings read. The diff has no spatial code.

## What was checked

- **`scripts/0153-reports-to-zotero.py` `api()`.** I ran a copy against a local stub HTTP server under
  `scratchpad/cc/apitest/`. A 429 with `Retry-After: 0` was retried, and the third try returned `(200, b'ok')`.
  Each retry re-sent the same body bytes and the same `Zotero-Write-Token`, so Zotero itself refuses to apply a
  replayed create. A 429 that never clears returns `(429, ...)` after exactly 6 requests. `Backoff` is honoured
  on both the success path and the final error path.
  - `api()` is called only with `BASE` (api.zotero.org) URLs: in 0153 lines 158, 206, 216, 229 and 252, and in
    every `z.api` call in 0270. The S3 upload in `upload()` (line 226) goes through `urllib` directly. So the API
    key is never sent to the storage endpoint, and an S3 error is not retried as if it were the API's (that is
    unchanged by this branch).
  - A retried PATCH that carries `If-Unmodified-Since-Version` is safe. If the first try had in fact landed, the
    retry gets a 412, which shows as `ADD-FAIL`. A re-run then reports `member`.
- **`data/sturgeon_additions.csv`.**
  - Format: 69 rows, 14 columns on every row, LF line endings, a trailing newline, no BOM, and no field with
    leading or trailing whitespace. The header matches what `addition_item()` reads.
  - Creators: no organisation name contains a comma, so splitting on `;` and then partitioning at the first comma
    never splits an organisation in two. Organisations become a `lastName` with an empty `firstName`, the same as
    the existing additions files.
  - Item types: `report` and `thesis` use fields valid for their type. The one DOI row has a blank `itemType` and
    `title`, which is correct because CrossRef supplies both.
  - Duplicate titles: three rows share the title "Working towards harm reducing…". They differ by year, and
    `group_copy()` compares year, so they stay three items.
  - `pdf` values: 61 are URLs. None contains an unencoded space or other unsafe character; `%20` is already
    encoded. Six are repo-relative paths under `data/rag/pdf/sturgeon/`, which is ignored by `.gitignore:6`. All
    six files exist on this machine. One is `zotero:733T5ZJV`, and its storage directory exists. No value is
    `none`.
- **`data/sturgeon_members.csv`.** 15 rows, 3 columns, no duplicate keys. One `pdf` is a URL; the rest are empty.
- **Docs.** The README claim that 0150 reads only items filed directly in a collection holds:
  `collection_keys()` in `scripts/0150-store.R` filters `collectionItems` on the named collection IDs and does not
  recurse into subcollections. The README's count of 84 keys matches 15 members + 69 additions.
- **Public-repo rule.** Neither CSV contains a home path, host, credential reference or private-repo link. The
  build log's `origin` column is truncated to `/User…`, so no username appears. The push log names
  `s3://fresh-bc/rag/`, which `CLAUDE.md` already names. The organisations in `creators` and `why` are the
  authors of published reports.

## Observation (not a finding)

- `float(e.headers.get("Retry-After") or 10)` raises `ValueError` if a 429 or 503 carries an HTTP-date
  `Retry-After`. I confirmed this with the stub. Zotero documents the header as seconds, so this is speculative.
  If it did happen, the exception would be caught by the per-report handler in 0153 and the per-member handler in
  0270, not abort the batch.

## Clean

No issues found.
