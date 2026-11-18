# Code-check round 3: #174 branch (knowledge) and crate `nuseds-schema`

Reviewed: knowledge `174-backlog-move-5-chinook-flow-windows-and` at 6ebc7fd0 against origin/main e9455d02;
crate `nuseds-schema` at 18668de. Probes were read-only. The crate suite ran in a detached worktree, since
removed: 0 failed, 0 errors, 0 skipped, 28 files.

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms`, all 14, with table rows and evidence blocks skipped.
  Under Rules that stand alone, Security and Spreadsheets, the index lines only (none applies to this diff).
- code-check-r.md, read by heading. Read: "A database driver's value is not a base R type"; "A `pkg::` call in a test
  passes `devtools::test()` and fails `R CMD check`"; "A fetcher's test helper must make the network fail"; "Under
  `R CMD check`, tests run from a temp dir"; "`system2(stdout = TRUE)` warns"; "Postgres row order is never fixed";
  "`on.exit()` at a script's top level never fires"; "`download.file(quiet = TRUE)`"; "CSV whitespace". About 150
  other headings were not read.
- code-check-shell.md, read by heading: none read (the diff runs git and aws through `system2()`, and the R headings
  cover those calls). About 120 headings not read.
- code-check-spatial.md, read by heading: none read (no spatial operations; FWA ids only). About 140 headings not
  read.

## Mechanism

Each property is fixed once, at its source: crate's declared types and encoding, Postgres's `bigint`, and the code,
commit and package versions a run reads. A later step then re-derives it from a stand-in that usually carries it:
CSV text and arrow's guess, the header row, a double's bits, `git HEAD`, a version string. Each guard or record
downstream checks the stand-in, which agreed with the property on every input seen so far. In each round's findings,
two lists happened to agree:

- the code and inputs a run depends on, against the list its clean check or run record names (R1 HEAD; R2 wet and
  segment_window_flow);
- the bytes a variant was registered from, against the bytes a later release under the same header carries (R1
  encoding);
- the types the source declared, against the types a second reader guessed (R1 integer64; R2 knw_publish);
- the property, against a count or a skip that stands in for it (R2 13 months; R2 crate floor and fixture skip).

## Places it reaches (held / open)

Types re-derived across a boundary
1. data-raw/chinook_window_flow.R: the bigint ids from the database are made numeric before `ifelse()` and `match()`
   (L111-116, L136, L228). HELD.
2. data-raw/segment_window_flow.R: the segment ids are made numeric, and wet's readers return integer ids
   (`wet_segment_read()` calls `as.integer()`). HELD.
3. data-raw/timing_nuseds.R: reads the records CSV with every column as character, and the year as integer. HELD.
4. knw_publish(types=) with scripts/0340's check of the manifest schema against crate. HELD. Measured on the local
   build: the Parquet has 37 string, 12 double and 2 int32 columns, as crate's schema declares.
5. knw_publish's leading-zero loop can replace a declared double or integer column with a string. HELD at its only
   caller: 0340's `wrong` check would stop.
6. chinook_window_flow reads visits_species.csv with readr's default guess, where 0320 sets guess_max = 1e5. HELD:
   the two reads are identical on the current file (measured), and the population, modelled and n_in checks
   reconcile against the tune table.
7. data/nuseds_release.csv is read with colClasses = "character" at both ends. HELD.

Encoding or shape chosen from the header
8. crate: UTF-8 bytes under a variant that declares latin1 are refused (`crt_ingest_check_not_utf8`, with a test).
   HELD.
9. crate: bytes that are not UTF-8, read as UTF-8, are refused. HELD. readr keeps the raw bytes and `validUTF8()` is
   FALSE (measured).
10. crate: the not-UTF-8 check on a `.zip` path. HELD. `readr::read_file_raw()` decompresses: 227,478,763 bytes from
    the 9,871,656-byte zip.
11. crate: Windows-1252 bytes under the latin1 variant. **OPEN** (finding 3).
12. crate: the canonical column names against the variant's names lower-cased. HELD (identical, measured).
13. crate: readr's default `trim_ws = TRUE` drops a trailing space from 12 POPULATION values. HELD, negligible: no
    join or key uses POPULATION. The docs' "as DFO wrote it" is loose by one space.

The record names the code that reproduces the run
14. chinook_window_flow: the clean check covers the rule file, the script and R/, untracked files included. The run
    record's head (2dee554e) has the same R/, script and rule as HEAD (empty diff). wet's version and daily build are
    recorded. HELD.
15. segment_window_flow: the clean check covers the script, R/ and the timing CSV, untracked files included. The run
    record names the knowledge commit, wet's build and wet's version. HELD.
16. scripts/0340's publish guard and `.knw_git_state()$dirty` both pass `--untracked-files=no`. **OPEN** (finding 1).
17. data/nuseds_release.csv `knowledge_commit` names a commit that does not hold 0340. **OPEN** (finding 1).
18. The NuSEDS receipt and release record do not name crate, whose registration decides every value's type and the
    file's decoding. **OPEN** (finding 2). The R2 fix records crate's version in the Phase 1 run record, a script
    that never calls crate.
19. timing_nuseds prints from the newest recorded release's CSV and does not check which build wrote it. HELD, as
    not a record: its output is printed and entered by hand.

Guards that check a stand-in
20. "13 months on one pick source". HELD. It now checks the count and the source.
21. chinook_window_flow L147 compares each river's MAD with `na.rm = TRUE`. HELD: check 20 guarantees month 0 for
    every lfid, rivers included, so nothing is NA.
22. segment_window_flow's `expect_rows` check cannot fire, because wet's reader always returns the full
    segment × source grid. Nothing depends on it. HELD, no defect.
23. knowledge's NuSEDS fixture fails rather than skips when crate lacks the registration. HELD.

## Findings

- **[fragile] scripts/0340-nuseds-build.R:40, :81-90, data/nuseds_release.csv** — the clean check and the release
  record miss untracked code. Line 40 runs `git status --porcelain --untracked-files=no`, and
  `.knw_git_state()` (R/receipt.R:47) does the same. An untracked file in R/ (`load_all()` sources it; DESCRIPTION has
  no Collate) or an untracked script therefore passes as a clean tree. A PUBLISH=TRUE run then uploads a receipt
  that names a commit without that code, marked `dirty: false`. A run without PUBLISH has no clean check at all, but
  still writes `knowledge_commit` into the tracked data/nuseds_release.csv. That record is never rewritten once its
  release is in it (L82-86), so the first build's commit stays. This branch shows it: the committed row names
  543bba64, which has no scripts/0340-nuseds-build.R (that arrived in 5f0d29a7, three minutes later) and has older
  R/nuseds_records.R and R/publish.R. This is R1's "run record names a HEAD that did not hold the script", in the
  NuSEDS build. Remedy: refuse untracked files under R/ and scripts/ as the window scripts do, run the check before
  any run that writes the tracked record, and rewrite the row's commit from a clean rerun.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "A guard that fails toward pass"

- **[fragile] scripts/0340-nuseds-build.R:99-104 (receipt recipe), data/nuseds_release.csv** — the NuSEDS output's
  record does not name crate. Its types and its decoding of the file come from crate's dfo/nuseds_all_areas
  registration: the schema YAML's types (ids as strings) and the variant's `encoding: latin1`. Yet the receipt's
  recipe names only the knowledge commit (`code`), the version and release (`config`), and the zip (`inputs`). Its
  context lists R, arrow, sf and GDAL, not crate (read from data/nuseds/20260601/publish/receipt.json), and the
  release record has no crate column either. Suppose a crate release changes a type, say an id back to integer, or
  the encoding. The rebuild then has the same recipe_id and a different result, and nothing in the record says why.
  This is R2's "the reproduce guard missed wet's version", reaching the one output crate actually shapes. The R2 fix
  added crate_version to ch_rear_run.csv, whose script never calls crate. Remedy: put crate's schema identity in the
  recipe's config, for example `crt_schema_fingerprint()` over the declared types plus the variant id and encoding,
  or crate's version and commit.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "A fix lands in one of two callers that share a harness"

- **[fragile] crate inst/extdata/schemas/dfo/nuseds_all_areas.yaml:194, R/crt_ingest.R:188-193** — `encoding:
  latin1` was inferred from bytes that cannot tell Latin-1 from Windows-1252. The release's only bytes ≥ 0x80 are
  0xC7 (Ç, 20 times) and 0xC8 (È, 240 times), measured over the whole decompressed CSV. Both encodings map those
  bytes to the same characters, so the evidence fits either. Under latin1, a cp1252 punctuation byte (0x92 ’, 0x96 –,
  0x93 or 0x94 curly quotes) decodes to an invisible C1 control. Demonstrated: `O\x92NEIL CREEK` reads as `ONEIL
  CREEK` with U+0092 under latin1, and as `O’NEIL CREEK` under windows-1252. Such a value passes
  `crt_ingest_check_utf8()`, which is skipped for latin1, and `crt_ingest_check_not_utf8()`, since a lone 0x92 is not
  valid UTF-8. A later release with such a byte and the same header is then read wrongly with no error. This is R1's
  "variant picked by header alone, encoding assumed", on its other side. Declaring `windows-1252` reads every byte of
  the current release identically and decodes the punctuation. Alternatively, refuse any byte in 0x80-0x9F under a
  latin1 variant, since those bytes are control codes in Latin-1 and never text.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A fixture that cannot reach the failure mode"
