# Code-check round 4: enumeration (#174 knowledge, crate `nuseds-schema`)

Reviewed: knowledge `174-backlog-move-5-chinook-flow-windows-and` at dc95503a, against origin/main e9455d02 and against
round 3's 6ebc7fd0; crate `nuseds-schema` at c694ba5. Probes were read-only. The suites ran in detached worktrees,
removed afterwards:
- crate test-crt_handler_dfo_nuseds_all_areas: 23 pass, 0 fail, 0 err, 0 skip; test-crt_ingest: 28 pass.
- knowledge test-receipt: 99 pass; test-nuseds: 21 pass; test-publish: 35 pass. All 0 fail, 0 err, 0 skip.

Versions: R 4.5.2, readr 2.2.0, vroom 1.7.1. Installed crate 0.19.0 was built 2026-11-18 03:27:27 UTC, its yaml md5
3a7f00fe = c694ba5's, and it carries no RemoteSha. Installed wet 0.4.36 matches tag v0.4.36, also no RemoteSha.

## Checklist read

- code-check.md: the prose of every H3 under `## Mechanisms`, with table rows skipped. Leaned on: "A guard that fails
  toward pass", including its "Provenance, and repair" and "Where the guard sits" paragraphs; "A fixture that cannot
  reach the failure mode"; "A proxy is not the property"; "Written data outlives the fix".
- code-check-r.md, read by heading: "Do not abort inside a handler for a warning raised from C++" (read; it does not
  fit, because the crash below has no handler of ours); "`system2(stdout = TRUE)` warns"; "CSV whitespace"; "A
  database driver's value is not a base R type"; "Copy a live SQLite database with its `-wal`" (index only). Other
  headings not read.
- code-check-shell.md and code-check-spatial.md: index only (none applies).

## Places (held / open, with evidence)

Code under data-raw/, R/ and tests/ is unchanged since round 3 (`git diff 6ebc7fd0 HEAD --stat -- data-raw R tests`
is empty). The round-3 fixes touched only scripts/0340, inst/receipt/nuseds.yaml, data/nuseds_release.csv and the
log; crate's fix touched only the yaml, the decisions note and a test.

Types re-derived across a boundary
1. chinook_window_flow.R L111-116, L136, L228: the ids are made numeric before `ifelse()` and `match()`. HELD.
2. segment_window_flow.R: the ids are numeric, and wet's readers return integers. HELD (code unchanged).
3. timing_nuseds.R reads every column as character. HELD (L26).
4. knw_publish(types=) with 0340's `wrong` check. HELD. Re-measured: the Parquet's own schema is 38 string (crate's 37
   plus evidence_kind), 12 double and 2 int32, with 0 columns differing from crate's types. act_id reads as text
   ("874256749").
5. The leading-zero loop at its only caller. HELD: the `wrong` check is unchanged.
6. visits_species.csv is read without guess_max. HELD. Re-measured: the read is all.equal to 0320's guess_max = 1e5
   read (500,819 rows), and the file's md5 6a2e28f1 is the summary's evidence_md5.
7. data/nuseds_release.csv is read with colClasses = "character" at both ends. HELD.

Encoding or shape chosen from the header
8. A UTF-8 release under the single-byte variant is refused. **OPEN (finding 1).** It holds for UTF-8 text whose
   continuation bytes are defined in cp1252: Ç (C3 87) is refused, measured. It does not hold for Á (C3 81), Ð (C3 90)
   and every other character with a continuation byte 0x81, 0x8D, 0x8F, 0x90 or 0x9D. For those, the full read in
   windows-1252 segfaults R before `crt_ingest_check_not_utf8()` runs (exit 139, measured).
9. Bytes that are not UTF-8 under a UTF-8 variant are refused. HELD (code unchanged; the crt_ingest tests pass).
10. The not-UTF-8 check on a `.zip`. HELD. The code is unchanged, and 0340 read the zip: 421,001 rows, not refused.
11. cp1252 bytes under the NuSEDS variant. Partly HELD, partly **OPEN (finding 1)**.
    - Defined bytes now decode correctly: 0x92 gives `MAXAN’S CREEK` through crt_ingest, 0x80 gives €, and 0xC8 gives
      È.
    - The five bytes cp1252 leaves undefined (0x81, 0x8D, 0x8F, 0x90, 0x9D) make readr/vroom raise "Invalid multibyte
      sequence" from C++, then segfault. `tryCatch()` cannot catch it. Under latin1 the same bytes read as U+0081 and
      so on, with no crash.
12. Canonical names against the variant's names lower-cased. HELD (identical, re-measured from the installed yaml).
13. readr's trim_ws on POPULATION. HELD, negligible (code unchanged).

The record names the code that reproduces the run
14. chinook_window_flow's run record: head 2dee554e has the same R/, script and rule file as HEAD (diff 0 lines). It
    records wet 0.4.36 (a tag) and the daily build. HELD.
15. segment_window_flow's clean check covers the script, R/ and the timing CSV, untracked files included. Its record
    names the commit, wet's build and wet's version. HELD.
16. 0340's clean check. HELD.
    - It now runs on every run, untracked files included, over R/, the script, inst/receipt, the README and the
      record.
    - Everything 0340 reads is in that pathspec. load_all sources R/. knw_receipt_keys reads inst/receipt. knw_publish
      reads no other inst file (grep). The zip is hashed into the recipe.
    - DESCRIPTION and NAMESPACE are outside it. DESCRIPTION's version reaches only the receipt, and a PUBLISH run's
      whole-tree check covers it.
    - Note, not a defect: the local receipt says `dirty: true`. The cause is the tracked log that the documented `|
      tee scripts/logs/nuseds/<date>_...txt` rewrites at launch, which `.knw_git_state()` counts under scripts/. On a
      day whose log is already committed, a PUBLISH run is therefore refused. That fails closed.
17. The record's knowledge_commit. The row is HELD now: b6162fb4 holds 0340, and `git diff b6162fb4 HEAD -- R
    scripts/0340-nuseds-build.R inst data/nuseds_README.md DESCRIPTION NAMESPACE` is empty. The mechanism round 3 named
    ("never rewritten once its release is in it") is **OPEN (finding 4)**: the current row is right only because the
    file was emptied by hand at b6162fb4.
18. crate's identity in the recipe and the record. Partly HELD, partly **OPEN (finding 2)**.
    - The yaml md5 pins the types and the encoding.
    - The R code that reads the file is named only by `crate 0.19.0`, which is the version string of a release (tag
      v0.19.0) that has neither the yaml nor the encoding read (`git show v0.19.0:R/crt_ingest.R | grep -c encoding` →
      0). That code is crt_ingest's encoding read and its two checks, the handler, and the registry row.
19. timing_nuseds takes the last record row's release. HELD: the value is the same with one row or several per release,
    and the output is printed.

Guards that check a stand-in
20. 13 months on one pick source. HELD (L139-141 unchanged).
21. `na.rm = TRUE` at L147. HELD (guaranteed by 20).
22. segment_window_flow's `expect_rows`. HELD, no defect.
23. The NuSEDS fixture fails rather than skips. HELD (test-nuseds: 0 skip).

Fixes from round 3, one axis over
- Fix (1), the 0340 dirty check: HELD as a check (place 16). Re-recording through it opened a new instance: **OPEN
  (finding 3)**, zip_url erased.
- Fix (2), crate_schema: HELD for the yaml. **OPEN (finding 2)** for crate's R code. crate_schema does not change when
  crate's NuSEDS handling changes in R: e0ba477 and 18668de have the same yaml md5 (cb47933a) and the same version
  (0.19.0), and 18668de added `crt_ingest_check_not_utf8()`. Both give one crate_schema.
- Fix (3), windows-1252: HELD for the defined bytes. **OPEN (finding 1)**: it changed the not-UTF-8 guard from a clean
  refusal to a crash for part of UTF-8.

## Findings

- **[bug] crate R/crt_ingest.R:138-146 with inst/extdata/schemas/dfo/nuseds_all_areas.yaml (`encoding:
  windows-1252`)**: a byte that cp1252 leaves undefined (0x81, 0x8D, 0x8F, 0x90, 0x9D) crashes R instead of being
  refused.
  - What happens: readr 2.2.0 / vroom 1.7.1 raise "Invalid multibyte sequence" from inside `_vroom_vroom_`, and the
    process then segfaults (exit 139). `tryCatch(error =)` around `crt_ingest()` does not survive it.
  - Cases measured through crt_ingest on the fixture: a lone 0x81 in a later cp1252 release, and a UTF-8 release
    containing Á or Ð.
  - Why the UTF-8 case matters: those characters' continuation bytes are 0x81 and 0x90, so the round-1 guard
    (`crt_ingest_check_not_utf8()`) never gets to run. It sits after the full read. Under latin1 the same UTF-8 file
    was refused cleanly, so this is a regression of that guard for part of UTF-8.
  - Why the tests miss it: the new test inserts 0x92, and the UTF-8 test transliterates to ASCII or uses Ç (C3 87).
    Every one of those bytes is defined in cp1252.
  - Remedy: run the byte scan before the full read. Refuse valid UTF-8 there, as now, and refuse any byte the declared
    encoding leaves undefined, naming its offset. Only then call readr. vroom's crash is upstream: draft an issue there,
    and do not post it without approval.
  - **Rule:** code-check.md "A fixture that cannot reach the failure mode" ; code-check.md "A guard that fails toward
    pass" ("Where the guard sits": the check sits after the operation that can fail first)

- **[fragile] scripts/0340-nuseds-build.R:52-56, data/nuseds_release.csv, receipt config `crate_schema`**: crate's
  code is identified by its version string, and that version names a release that cannot read the file.
  - What it records: `crate 0.19.0 schema md5 3a7f00fe…`. The md5 pins the yaml.
  - What it misses: the decoding and checks in crt_ingest, the handler and the registry row are identified only by
    "0.19.0". The installed crate is a branch build with no RemoteSha, and tag v0.19.0 lacks the yaml and the encoding
    read.
  - Measured: e0ba477 and 18668de produce one crate_schema although 18668de changed crt_ingest.
  - Consequence 1: when crate's release lands, a rerun of release 20260601 gets a new crate_schema. The record key
    (release × crate_schema, L96) then appends a second row for the same release. The old row keeps naming a crate
    nobody can install.
  - Consequence 2: between dev installs at one version, a change to crate's R reading leaves recipe_id unchanged.
  - Remedy: identify crate by its commit. Install from GitHub so `packageDescription("crate")$RemoteSha` is set, and
    refuse an install without one, or hash the installed R code. When the release lands, re-record the row rather than
    append beside it.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "Written data outlives the fix"

- **[fragile] data/nuseds_release.csv (zip_url ""), scripts/0340-nuseds-build.R:93-95 with R/nuseds_fetch.R:84
  (`url = NA` when held)**: re-recording the release erased the only record of where the zip came from.
  - Before: the row at 6ebc7fd0 carried `https://api-proxy.edh-cde.dfo-mpo.gc.ca/…/All%20Areas%20NuSEDS_20260601.zip`.
  - After: the row written from the held zip at b6162fb4 has `zip_url = ""`. No other tracked file holds that URL,
    outside tests and the plan.
  - The `fetched` date is likewise the run's date, not the download's.
  - Cause: both fields are re-derived from this run (`f$downloaded`), not carried from the first fetch. Any re-record of
    a held release (a new crate_schema, finding 2) blanks them again.
  - Remedy: restore the URL in the row, and carry zip_url and fetched forward from an existing row for the same release
    and md5 when the zip is held.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[fragile] scripts/0340-nuseds-build.R:95-101**: the record's key includes crate's identity but not knowledge's
  commit, so after a knowledge code change the record keeps the old commit.
  - What a rerun does: after a commit that changes R/nuseds_records.R (say, the evidence_kind classification) without
    changing the row count, the rerun finds `same` TRUE. It checks only `rows` and leaves the old `knowledge_commit` in
    place.
  - Meanwhile the run rewrites nuseds_records.csv and the receipt from the new commit. The record no longer names the
    code that ran, which L40-41's comment says it must.
  - This is the mechanism of round 3's finding 1, second half. The current row is correct only because the file was
    emptied at b6162fb4 and re-recorded once.
  - Remedy: rewrite the matched row's knowledge_commit (and crate_schema) on every clean run, or add the commit to the
    key.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "A guard that fails toward pass"
    ("Provenance, and repair")
