# Code-check round 1: #127 branch (9e10a19...HEAD, planning/ excluded)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with table rows and evidence blocks skipped. From
  "Rules that stand alone" I used the index lines only (Documentation Staleness was the one that seemed to apply). I
  did not read the full sections of the rest of that file, about 30 headings.
- code-check-spatial.md: three headings in full: "A GeoPackage is a SQLite database, and that leaks in three ways",
  "The same leak reaches R and OGR SQL, and a GeoPackage's bytes are not its content", and "Restoring a GeoPackage
  from a copy: refuse sidecars before the first read, delete them before the copy-back". I used the index for the
  rest, about 100 headings, none of which touch this diff.
- code-check-r.md: I worked from the index lines for the headings this diff touches: `on.exit()` at top level,
  `dbConnect(SQLite(), path)` CREATES the file, `system2(stdout = TRUE)` warns, `tryCatch()` nests its handlers,
  `tempfile()` lives in the session tempdir, `identical()` on two reader results, a `data-raw/` script must load the
  source tree, and `[[` on a named atomic vector. I checked each against the code by reasoning and by the run below,
  but did not read their full sections. I did not open the other ~105 headings.
- code-check-shell.md: index only. The diff's only shell is `system2()` and `shQuote()` from R, which I checked by
  running it. I did not open the other ~110 headings.

## Method

- Read the diff, the changed sections of all three readers, `0153`'s import-time code, and the findings.
- Grepped the tracked tree for any other `zotero.sqlite`, `immutable`, `RSQLite` or `sqlite3` reader. There are none
  outside the three guards and cred.
- Ran `data-raw/zotero_copy_check.R` from a `git archive HEAD` copy in the scratchpad (`LIVE=FALSE STRESS_SECS=6`). It
  passed: every guard read every fixture's rows, and the stress accepted 75 of 75 copies per guard, all committed.
- In that same copy (never the checkout), deleted the stability condition from all three guards and ran
  `STRESS_SECS=20`. The R guards became `if (!copied) {` and 0270's became `if True:`. Both R copies were patched
  identically, so the deparse identity check still held.

## Findings

- **[severity: fragile]** data-raw/zotero_copy_check.R:171-217 and :240-241. The stress test cannot fail on the guard
  it exists to test.
  - **What the guard is:** in `scripts/0280-literature-verify.R:141`, `scripts/0150-store.R:75` and
    `scripts/0270-habitat-collection-build.py:119`, a copy is kept only when both files' mtime and size, the header's
    journal-mode bytes and the rollback-journal flag are the same before and after the copy.
  - **What I measured:** with that whole condition removed from all three guards, the 20 s stress still prints
    `PASS ... every stress copy it accepted was committed`. Each guard had 204 of 204 calls accepted and 0 not
    committed.
  - **What that means:** the stress has never been seen to fail. Nothing else in the script reddens when the stability
    check, the mode-byte comparison or the "clear the copy's -wal first" step is removed. The fixture runs use
    `tries = 1` on static files, so they cannot reach any of those either. Only the "copy the -wal" step is pinned
    (wal_pending and wal_exclusive expect 8 rows).
  - **Why it matters:** the PASS line and the findings present the stress as evidence that the stability guard keeps
    torn pairs out. As written, it shows the same result with or without the guard. A future edit that weakens the
    guard would stay green.
  - **Likely cause:** a copy torn by a checkpoint does not show up as `rows != max(itemID)` inside the window this
    writer produces. SQLite ignores WAL frames whose checksum or salt does not match, so a mismatched pair falls back
    to an older committed state, or else fails `quick_check`.
  - **A second, smaller gap:** the pass criterion is pooled over all three guards. Line 216 stops only when every guard
    gave up on every call, so one guard that never accepts a stress copy passes the stress vacuously, and the PASS
    line still speaks for it.
  - **Rule:** code-check.md "A fixture that cannot reach the failure mode" ; code-check.md "Restore the bug and prove
    the guard fires"

No other issues found.

- **The guard logic holds up:** I reasoned through every ordering of a main-file copy, a -wal copy, a checkpoint, a
  -wal restart, a TRUNCATE and a -wal that disappears. Each one changes a stat the guard compares, or is a consistent
  pair. R's `file.info()` mtime has sub-second resolution on this machine (`1793488226.37332`), and Python uses
  `st_mtime_ns`.
- **Other checks:**
  - 0150's `snapshot()` matches 0280's (the check script's deparse comparison passes).
  - 0270's one caller (`con = db()`) still works with the new `live=` first parameter.
  - 0153 does nothing at import except the key check.
