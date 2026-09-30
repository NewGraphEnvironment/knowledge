# Code-check round 2, Phase 2 (0270 + 0153 `upload()` split), 2026-09-29

Reviewer: general-purpose subagent. No repo file other than this one was written. No Zotero write was made; only
GETs were issued. `0270` was run only with `--dry-run`. The Zotero DB was read only through `db()`'s copy, plus
raw reads of the live header bytes (the same read `db()` makes).

## Verdict on the questions asked

- **The re-run finds every previous copy.** `--dry-run` exited 0 in about 2 minutes and printed
  `77 members, 10 additions | exists 10 | member 87 | no-pdf 15 | pdf 72`.
  - All 10 additions report `exists, member, pdf present`, keyed to the items the first run created (for example
    Isaak `X9HPSBV4`, Gill `8B95AXD2`). No `would create` appeared.
  - The copied members now resolve through the group path, because their synced copies carry the key.
    - `agrawal_etalPREDICTINGPOTENTIAL` resolves to `7BIC5WW2`.
    - `beamer_etal2013JUVENILECHINOOK` resolves to `TTV53WE3`.
    - `beamer_etalFRESHWATERHABITAT` resolves to `QPQV4UFQ`.
  - That means the dry run did not exercise `group_copy()` on those members. So I called `group_copy(item_json(...))`
    directly on the non-group source items:
    - agrawal, from library 6 (`A4SLUPQH`), returned `7BIC5WW2`.
    - beamer_2013, from library 1 (`9DNWY4LA`), returned `TTV53WE3`.
- **`_first_last` and `_year` compare like with like on the paths this script takes.**
  - A copy is compared against the same source it was built from: a CrossRef addition against a CrossRef-built
    item, and a DB body against a DB-built item.
  - The raw DB date `2013-00-00 2013` is stored by the API as `2013`. Both give `2013`.
  - An empty date gives `None` and is lenient. The agrawal date is empty.
  - A single-field `name` creator (fieldMode 1) round-trips as `name` on both sides.
  - An empty CrossRef org author is skipped on both sides.
  - A pre-existing item with different author formatting could still miss the match on a *first* run. That is not
    a re-run duplicate path, and it does not occur in today's data.
- **No other exit or fail-open path.**
  - `get_json` raises, and the per-row `except Exception` catches it.
  - Every failure step is upper case, and `isupper()` is true for `PDF-FAIL`, `PDF-MISSING`, `ADD-FAIL`,
    `COPY-FAIL`, `CREATE-FAIL`, `AMBIGUOUS`, `MISSING` and `ERROR`.
  - The remaining `sys.exit`s are in `db()` and `find_collection()` before any write, and on the final summary.
  - The `upload()` extraction in 0153 is a pure move. The `attach()` path is unchanged.
- **The change-counter check does not detect a commit under Zotero's locking mode.** See the finding below.

## Findings

- **[fragile]** `scripts/0270-habitat-collection-build.py:72-79` (`db()`): the header change counter does not move
  on most commits while Zotero is running, so round-1 finding 5 is not fixed. The guard passes a copy taken across
  a write.
  - Zotero opens its database in exclusive locking mode, hardcoded: `const DB_LOCK_EXCLUSIVE = true;` and
    `PRAGMA main.locking_mode=EXCLUSIVE` in `chrome/content/zotero/xpcom/db.js` inside
    `/Applications/Zotero.app/Contents/Resources/app/omni.ja`. There is no pref override in `prefs.js`.
  - In exclusive mode SQLite updates the counter only once per lock hold, or when page 1 itself is written, for
    example when the file grows. It does not update it on an ordinary commit.
  - Measured with Python's sqlite3, five in-place `UPDATE` commits, each run printing (counter before, counter
    after, whether the file mtime changed):
    - `NORMAL`: `(2001, 2002, True) … (2005, 2006, True)`. The counter moves on every commit.
    - `EXCLUSIVE`: `(29, 29, True)` five times. The file is rewritten every time and the counter never moves.
  - On the live file, the counter read 11267 at both 18:33 and 18:35. The journal header was zeroed, which is
    consistent with exclusive mode.
  - So a sync commit that lands during the ~158 MB `copyfile` passes the `counter() == before` test. The guard is
    back to `quick_check` alone, which round 1 showed cannot see a torn copy.
  - The silent outcome is still the one round 1 named: a lowercase `no-pdf`, or a stale key lookup.
  - Fix: compare `os.stat(live).st_mtime_ns` and `st_size` before and after the copy. The mtime moved on every
    exclusive-mode commit above. Also require the first 8 bytes of `zotero.sqlite-journal` to be zero on both
    sides, which was round 1's other half and was dropped. A rollback journal gets its magic header before SQLite
    overwrites any database page, so a transaction left open after a cache spill shows up there, even though the
    mtime is stable during the copy.

Nothing else found. The other four round-1 fixes hold. No security issues: the API key is not printed or put in a
URL or argv.
