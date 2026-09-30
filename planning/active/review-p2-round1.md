# Code-check round 1, Phase 2 (0270 + 0153 `upload()` split), 2026-09-29

Reviewer: general-purpose subagent. No repo file other than this one was written. No Zotero write was made; only
GETs were issued. `0270` was run only with `--dry-run`, from a copy of the DB.

## Verdict on the questions asked

- **Re-run safety and idempotency.** The re-run is safe on the current data. `--dry-run` (1m49s, exit 0) reports
  `77 members, 10 additions | exists 10 | member 87 | no-pdf 15 | pdf 72` and plans no write. The server
  collection `U9ZCZ6RN` holds 87 top items. All 77 member keys resolve to exactly one group item, and no member key
  names different titles in different libraries (checked on a DB copy), so the non-group copy path is not reached.
- **Dropping an item from a collection.** No path does this. The PATCH sends the item's current `collections` plus
  the new one, under `If-Unmodified-Since-Version`, so a 412 fails loudly (`ADD-FAIL`) instead of overwriting.
  Standalone PDFs are not re-parented.
- **Setting a citation key by hand.** No path does this. `citationKey` is skipped and `Citation Key:` lines are
  stripped from Extra. No source library carries `bibtex:`, `tex.citationkey` or `citekey` lines; the only one is
  a `bibtex[shortauthor=…]` line in the group itself, which is never a copy source. CrossRef and grey-literature
  items carry no Extra.
- **Does the refactor change 0153?** No. The only change is a pure extraction: `attach()` now ends in
  `return upload(parent_key, data, fname)`, and the moved body is byte-identical. Return strings and the raising
  behaviour are unchanged. The `KeyError` on an auth reply with no `prefix` could already escape and is still
  caught by 0153's per-report `try`.
- **Partial failure.**
  - *Item created, then the PDF fetch fails.* The run reports `ERROR` without the new key. The re-run finds the
    item by title and attaches the PDF. This is what actually happened with Isaak (`X9HPSBV4`).
  - *PATCH returns 412.* The run reports `ADD-FAIL` and exits non-zero; the re-run adds the item.
  - *Network error mid-upload.* The exception is caught per member (`ERROR`). The attachment row left with no md5
    is ignored by `has_pdf()`, so the re-run makes a new attachment, which the md5 dedup satisfies. The orphan
    attachment row stays in the library. It is junk, not data loss.

## Findings

- **[fragile]** `scripts/0270-habitat-collection-build.py:208-214` (`group_copy_by_title`, used for member copies
  at :375 and for additions at :299): the idempotency key is the exact title alone, with no creator, year or DOI
  check.
  - On a re-run, any other group item carrying the same title is taken as "the copy". It is added to the
    collection, and if it has no PDF it receives this row's PDF: a wrong-PDF path.
  - Generic grey-literature titles make this plausible. `q=Bull trout Salvelinus confluentus` already returns 12
    group items today, of which only Gill `8B95AXD2` matches exactly.
  - The lookup reads only the first 25 hits (`limit=25`, sorted by the API's default rather than by relevance). An
    exact match that ranks lower is missed, and a duplicate item is POSTed.
  - Empty title: `body.get("title", "")` with an untitled source item sends `q=` and compares `"" == ""`. That
    matches any untitled top item, such as a standalone note or attachment, which is then PATCHed into the
    collection and used as an upload parent.
  - Harmless on today's data, but it is the one path that could put the wrong PDF onto an item.
  - Fix: also compare the year and the first creator's last name, or the DOI when there is one. Refuse an empty
    title. Or write the created key back to the CSV and treat that key as the identity afterwards.

- **[fragile]** `scripts/0153-reports-to-zotero.py:190`, together with `0270:239` and `0270:292`: `upload()`
  derives `contentType` from the filename. `has_pdf()` (`0270:202`) counts only `application/pdf`.
  - 0270's filenames do not guarantee a `.pdf` suffix:
    - `local_pdf` returns a local basename as is, and never checks the bytes for `%PDF`. The local DB has 3
      attachments typed `application/pdf` whose file is a `.zip` or is named `pdf`, for example
      `viveiros2010FishPassage` → `…Maps….zip`.
    - A URL whose last path segment has a query string or no extension loses the suffix.
    - `[:120]` truncates `.pdf` off a long name.
  - In any of these cases the file is uploaded as `application/octet-stream`. `has_pdf()` never counts it, so every
    re-run creates another attachment: not idempotent, and 0150 never sees a PDF. In the `.zip` case a non-PDF is
    uploaded as the item's "PDF".
  - No current member or addition is affected; all 35 uploaded names end in `.pdf`.
  - Fix, in 0270 only: check the local file for `%PDF`, force `name` to end in `.pdf` before calling
    `z.upload()`, or let `upload()` take `ctype` as an argument.

- **[fragile]** `0270:334-335` and `:343-346` against `0270:174-178`: `get_json()` calls `sys.exit()` on any
  non-200. `SystemExit` is a `BaseException`, so the per-member `except Exception` ("one member must not abort the
  batch") does not catch it.
  - A single 404, for example an item trashed on the server that the local snapshot still maps, aborts the whole
    run mid-batch with no summary.
  - A transient 429 or 5xx on any of the ~160 GETs does the same. There is no Backoff or Retry-After handling.
  - The failure is loud and the run is resumable, so no data is lost. But the stated guarantee does not hold, and a
    run can stop between an item's POST and its `ensure()`. That state is recoverable only by the title lookup
    above.
  - Fix: raise an ordinary exception in `get_json()`.

- **[fragile]** `0270:278-288` (`addition_pdf`, `zotero:` rows): when the local `storage/<key>/` directory is
  missing or holds more than one PDF, the function returns `None`, and `ensure()` reports lowercase
  `no-pdf: none local`. The run then exits 0.
  - For an additions row, a PDF was explicitly named, so this is a failure reported as the accepted "no PDF
    anywhere" state. That is a guard that fails toward pass.
  - This is likely on a machine whose Zotero downloads files on demand and has not yet fetched that standalone.
  - Only the first creation is affected; once a PDF is stored, `has_pdf()` short-circuits.
  - Fix: return an upper-case status, for example raise `ValueError` as the URL branch does.

- **[fragile]** `0270:55-76` (`db()`): `PRAGMA quick_check == "ok"` on a byte copy does not prove the copy is a
  single committed state.
  - `quick_check` checks B-tree structure, not whether pages come from one transaction. `zotero.sqlite-journal` is
    persistent here: it is present with a zeroed header while Zotero runs.
  - A copy taken during a commit can pass and still be torn. Its silent outcome is a lowercase `no-pdf`, or a
    stale key lookup.
  - Cheap discriminator: read the file change counter (header bytes 24–27) of the live file before and after the
    copy. Retry unless the two are equal and the journal header is zeroed.
  - Separately, each call leaks a ~151 MB copy: the `mkdtemp()` directory is never removed, and two snapshots
    were present in `/tmp` at review time.

No security issues found. The API key is read from env or the 0600 file and never printed. Commits and URLs carry
no identifiers.
