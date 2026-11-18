# Code-check round 5: enumeration (#174 knowledge, crate `nuseds-schema`)

Reviewed: knowledge `174-backlog-move-5-chinook-flow-windows-and` at f3efa48f against origin/main e9455d02 (origin/main
has not moved, fetched 2026-11-18 03:4xZ); crate `nuseds-schema` at 4311a8c. Probes were read-only. The suites ran in
detached worktrees under the scratchpad, removed afterwards; both trees were clean before and after.
- crate, whole suite: 28 files, 2827 pass, 0 fail, 0 err, 0 skip.
- knowledge: test-nuseds 21, test-receipt 99, test-publish 35, test-settings-register 272 pass; all 0 fail, 0 err,
  0 skip.

Versions: R 4.5.2, readr 2.2.0, remotes 2.5.0, pak 0.11.1. The installed crate 0.19.0 was built 2026-11-18 03:37:44 UTC,
3 s after 4311a8c. Its yaml md5 3a7f00fe matches the branch's, and its `crt_ingest_check_bytes()` deparses identically
to the branch's. It has no RemoteSha.

## Checklist read

- code-check.md: the prose of every H3 under `## Mechanisms`, all 14, with table rows skipped. Leaned on: "Written
  data outlives the fix"; "A guard that fails toward pass" ("Provenance, and repair"; "Where the guard sits"); "A
  proxy is not the property"; "A fixture that cannot reach the failure mode".
- code-check-r.md, read by heading: "CSV whitespace"; "`system2(stdout = TRUE)` warns"; "A database driver's value is
  not a base R type"; "Do not abort inside a handler for a warning raised from C++"; "`paste()` with a zero-length
  argument"; "Zero-length, empty, and unset" (code-check.md). The other headings were read at index level only.
- code-check-shell.md and code-check-spatial.md: index only (none applies).

## Places (held / open, with evidence)

Code under data-raw/, R/ and tests/ is unchanged since round 3: `git diff 6ebc7fd0 HEAD --stat -- data-raw R tests`
is empty, and only inst/receipt/nuseds.yaml changed under inst (at b6162fb4, reviewed in round 4). Since round 4
(dc95503a), only scripts/0340, the record and the log changed in knowledge. In crate, only crt_ingest.R, its Rd and the
NuSEDS test changed.

Types re-derived across a boundary
1. chinook_window_flow.R: the ids are made numeric before `ifelse()`/`match()`. HELD (code unchanged; round 4).
2. segment_window_flow.R: the ids are numeric. HELD (code unchanged).
3. timing_nuseds.R: every column is read as character. HELD (code unchanged).
4. knw_publish(types=) with 0340's `wrong` check. HELD. Re-measured on the latest build's Parquet: 38 string, 12
   double and 2 int32 columns. Zero columns differ from crate's declared types; act_id and evidence_kind are string.
5. The leading-zero loop at its only caller. HELD (the `wrong` check is unchanged).
6. visits_species.csv is read without guess_max. HELD (code and file unchanged since round 4's measurement).
7. data/nuseds_release.csv is read with colClasses = "character" at both ends. HELD.

Encoding or shape chosen from the header
8. A UTF-8 release under the single-byte variant. HELD.
   - `crt_ingest_check_bytes()` now runs before readr's full read (crt_ingest.R, before `read_csv`), and the test
     inserts Á (C3 81) and expects "file is UTF-8". It passes, with no crash.
   - Note, not a defect: the test is whole-file `validUTF8()`, the same as round 1's check. A UTF-8 file that also
     holds one stray byte defined in cp1252 therefore passes and is read as mojibake. No encoding reads such a file
     right, and this is not a regression.
9. Bytes that are not UTF-8 under a UTF-8 variant. HELD (the code is unchanged, and the crt_ingest tests pass).
10. The byte check on a `.zip`, a multi-file zip and a `.gz`. HELD, measured in a throwaway Rscript.
    - A zip holding two CSVs: `read_file_raw()` and `read_csv()` both read the first entry, in either order.
    - A `.gz`: `read_file_raw()` decompresses it, giving 15 bytes with 1 high byte.
    - knw_nuseds_fetch refuses any zip that does not hold exactly one CSV.
11. cp1252 bytes under the NuSEDS variant. HELD.
    - The undefined bytes are found by iconv per distinct high byte. iconv finds exactly 81 8D 8F 90 9D for
      windows-1252 and CP1252, and the test refuses 0x81 with "does not define".
    - Every single-byte name a variant could declare was measured: latin1, ISO-8859-1, ISO-8859-15, latin-9,
      macintosh and cp437 give 0 undefined bytes, so they pass, and none crashes readr. ASCII gives 128, so any high
      byte is refused, which is right.
    - A multibyte name fails toward refusal: Shift_JIS gives 65 and GB18030 128, because a lead byte alone is
      incomplete. UTF-16LE does too, since `rawToChar` errors on its NULs. So such a variant would refuse valid files.
      No registered variant declares one: the only `encoding:` in crate's schemas is NuSEDS's windows-1252.
12. Canonical names against the variant's names lower-cased. HELD (the yaml is unchanged, md5 3a7f00fe).
13. readr trim_ws on POPULATION. HELD, negligible (code unchanged).

The record names the code that reproduces the run
14. chinook_window_flow's run record. HELD (unchanged since round 4).
15. segment_window_flow's clean check and record. HELD (unchanged).
16. 0340's clean check, every run, untracked files included. HELD (unchanged since round 4). One consequence fails
    closed: a deleted tracked record shows in `git status` and is refused. That makes the `rec <- NULL` branch
    unreachable on a clean tree. It would otherwise error at L108, where `nrow(NULL)` is NULL, before it writes
    anything.
17. The record's knowledge_commit. HELD.
    - The row names 0283d0f3, the HEAD when the run started (log: started 03:38:16Z; the commit was 03:38:15Z).
    - `git diff 0283d0f3 HEAD -- R scripts/0340-nuseds-build.R inst data/nuseds_README.md DESCRIPTION NAMESPACE` is
      empty. f3efa48f touched only the record and the log.
    - The row is now rewritten on every clean run (L101-120), so the mechanism round 4 named is closed.
18. crate's identity. HELD as a guard, with the owed release outstanding, which is not re-flagged.
    - PUBLISH=TRUE refuses a crate with no RemoteSha (L58-61). A local run records "commit none (a local build)",
      which is what the tracked row says today.
    - Install routes, read from the installers' code:
      - pak from GitHub writes RemoteSha (pkgdepends, `download_remote_git`). So does `remotes::install_github`.
      - Three routes write none, and a publish refuses them: R CMD INSTALL; `devtools::install()` /
        `remotes::install_local()` (whose `remote_metadata.local_remote` writes only RemoteType, Url and Subdir); and
        pak `local::` (whose `resolve_from_description` sets `RemoteSha = NULL`).
      - Note: pak from a CRAN-like repo writes `RemoteSha = <version>` (`get_standard_metadata`), a version string the
        guard would accept as a commit. It is unreachable today: crate is on neither CRAN nor an r-universe (both 404).
19. timing_nuseds takes the last record row's release. HELD (unchanged).

Guards that check a stand-in
20. 13 months on one pick source. HELD (unchanged).
21. `na.rm = TRUE` at L147. HELD (unchanged).
22. segment_window_flow's `expect_rows`. HELD, no defect.
23. The NuSEDS fixture fails rather than skips. HELD (test-nuseds: 0 skip).

Round 4's four fixes, one axis over
- (1) The byte scan before the read. HELD (places 8, 10 and 11).
- (2) crate's RemoteSha in crate_schema. HELD (place 18).
- (3)+(4) One row per release, rewritten each clean run, with zip_url and fetched carried forward:
  - Another release's row is kept. L118 drops only `f$release`, and a record with other columns stops `rbind`
    before anything is written.
  - A carried `fetched` is right today. The row's 2026-11-18 is the download's UTC date: the zip's mtime is
    2026-11-17 19:30 -0700, which is 02:30Z on the 18th.
  - **OPEN (finding 1):** a held zip with no row yet gets a blank URL and the run's date, which is then carried
    forward.

## Findings

- **[fragile] scripts/0340-nuseds-build.R:101-116 with R/nuseds_fetch.R:86-88 (`.knw_nuseds_held`, `url = NA`)**: the
  first record of a release whose zip is already held gets `zip_url = ""` and the rerun's date as `fetched`. L113-116
  then carry both forward on every later run.
  - Why the zip can be held with no row: the download writes the zip (nuseds_fetch.R L80), but the record is written
    only at L120. Every stop between them leaves a held zip and no row: crate refusing a shape it has not registered
    (in `knw_nuseds_records()`, the designed refusal for a reshaped release), the Maxan check, or a `stop()` in
    between.
  - What the rerun does after the fix: `knw_nuseds_fetch()` returns the held zip with `url = NA` and
    `downloaded = FALSE`. `old` is empty, so nothing is carried. The row records `zip_url = ""` and today's date.
  - Nothing else holds the URL or the download date: knw_nuseds_fetch writes no sidecar, and data/ is ignored.
  - This is round 4's finding 3 (b6162fb4 blanked the URL), one axis over. The fix carries the fields from an existing
    row, but the path that creates the first row from a held zip still re-derives them from the run.
  - Why it is likely: a new release in a new shape is exactly the case crate refuses first, so it is the likely route
    for the next release's row.
  - Remedy: have the download write the source URL and the download time beside the zip (for example
    `<release>/source.json`), and have `.knw_nuseds_held()` read them back. Or write the record row, URL and date
    included, as soon as the zip is copied.
  - **Rule:** code-check.md "Written data outlives the fix"; code-check.md "A fix lands in one of two callers that
    share a harness" (the downloaded and held paths into one row)
