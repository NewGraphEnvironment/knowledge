# Code-check round 4 (#119): round 3's batch identity, and the enumeration re-run

## Checklist read

- `code-check.md.index`, `code-check-r.md.index`, `code-check-shell.md.index`, `code-check-spatial.md.index`,
  `code-check-python.md.index`: in full.
- `code-check-python.md`: in full (nothing in this diff is Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (evidence blocks and table rows skipped), with weight on
  "A proxy is not the property" (an identifier that can be copied identifies a configuration, not an instance),
  "A guard's scope, escape hatches, and remedies" ("already current" vs "never regenerated"; compare per source),
  "Written data outlives the fix" (diff the ledger against the artifacts it claims), "A guard that fails toward pass"
  (the write path; where two files must move together), "One fact derived twice".
- R sections for what the diff uses: `system2(stdout = TRUE)` warns instead of raising (`.knw_aws`, `.knw_zstd` read
  `attr(out, "status")`: fine); `tryCatch()` nests its handlers (the 404 handler re-raises with `stop(e)`: fine);
  `fs::file_move()` / `file.rename()` (return value checked in pull and `.knw_write_whole`); CSV whitespace / `read.csv`
  (`na.strings = ""` with `write.csv(na = "")`: round-trips); `identical()` on reader results (not used on readers).
  Shell: `aws s3 cp` cannot tell a missing key from a missing bucket (head-object 404 on a wrong bucket falls to a
  put that then fails, after the versioning check: fails toward error); S3 multipart ETag (not used: md5 is metadata).

Method: read the round 3 fix (`round3_fix.diff`) and the current `R/archive.R`, `scripts/0320`, `0335`, `0336`,
`R/tune_promote.R`, `R/grade_record.R`, `data-raw/archive_seed.R`; checked the migrated `data/archive_index.csv`
(47 rows, one batch; every archived record row's `source_md5` and every `promoted` event's record md5 equal the
tracked records' md5s; every grades row's `source_md5` equals its record's `grades_md5`); ran
`tests/testthat/test-archive.R` from a copy (56 passed, 0 failed, 0 errors); probes on the test's mock bucket in
`scratchpad/r4/` (`p1.R`, `p2.R`).

## Findings

- **[severity: bug]** R/archive.R:225-232 (`.knw_archive_batch_rows()`), used by `knw_archive_pull()` (:420) and
  `knw_archive_undo()` (:502) — the batch is identified by the md5 of the record alone, but the record pins only the
  grade table. The curve (`<key>_curve.rds`) and the segments (`<key>_segments.rds`) are not in the record, so two batches
  can hold the same record bytes with different curves or segments, and `tail(r$batch, 1)` then picks the newest of them,
  not the checkout's.
  - **Path 1 (an archive of a superseded run).** 0320 graded run R1, and two comparisons of R1 exist on two machines
    (s0, s1). R1 was promoted with s1 (B1), then superseded by R2. 0336 then archives the other copy, unpromoted:
    `RUN=R1` of a candidate copy, or the default on a checkout whose ignored `data/compare` is older, which CLAUDE.md
    says the database host's can be. The plan holds the grades to the record and the evidence to the grades, never the
    curve or the segments. The guard skips the key because R1 is no longer the published batch (`pub$setup` differs, or
    nothing is published), so B3 (r1, s0) is put over R1's folder.
    - From then on, a checkout whose record is r1 (an old commit, or the undo of R2's promotion) gets s0 from pull.
    - An undo of R2's promotion picks B3 too. It finds B3's s0 current and copies nothing, and it marks B3 published.
      The checkout holds s1 (moved back from `replaced_*`), and s1's version stays noncurrent, so it expires in 180
      days.
    - Probe `p2.R` prints: "stale unpromoted put of R1's record: accepted", "pulled segments: stale s0", "published
      batch's segments md5 == checkout's: FALSE", "s1 version current after undo? FALSE".
  - **Path 2 (two promotions of one record).** A byte-identical regrade at one commit after a by-key promotion (resume
    R, regrade K, 0330, promote K again), with a curve or segments of other bytes, then an undo.
    - `.knw_archive_events()` sees the restored batch equal to the published one, so it writes no `undone` event, only
      `promoted` B2 again.
    - The checkout holds B1's curve, B1's curve version stays noncurrent, and a pull returns B2's curve.
    - Probe `p1.R` prints the events "promoted, superseded, promoted, promoted" (the last two both B2), and "checkout
      curve md5 == pulled: FALSE".
  - Why it matters: the chinook bundle pins the curve and the segments (`meta$md5_local`). A restore that brings
    other bytes fails `test-vignette-data.R` on that machine. After an undo, the bytes the bundle pins remain only as a
    noncurrent version, which the lifecycle deletes in 180 days while the index points elsewhere: the loss the archive
    exists to prevent.
  - Remedy direction:
    - Identify the batch by every object the checkout can show, not by the record alone.
    - `knw_archive_undo()` has the restored curve and segments on disk (`tune_dir`, and `data/compare`). Select the
      batch whose record, curve and segments rows all match them, and refuse when none does.
    - For pull, prefer the batch of the last `promoted` event carrying this record md5 (what the bundles were built
      from) over the newest `archived` batch. Or refuse when batches sharing the record differ in another object.
    - Alternatively, have the unpromoted guard refuse a put whose record matches an archived batch in the same folder
      while another of its objects differs ("same record, other curve/segments" is never a new run).
  - **Rule:** code-check.md "A proxy is not the property" (the record's md5 stands in for the batch's four objects, and
    it pins one of them). Also "A guard's scope, escape hatches, and remedies": compare per source, since the identity
    compares one source and passes the other three.

## Enumeration: every path that writes or deletes one member of a pair (current code)

| # | Pair | Path (file:line) | What it writes / deletes | Consistent at every step, incl. failure partway? |
|---|------|------------------|--------------------------|--------------------------------------------------|
| 1 | grade table / record | scripts/0320-tune-run.R:249, 275 (pass-start clear) | deletes non-cache key files; `caches` keeps `_grades.csv` and `_grades_record.csv` together | Yes. Note: the curve is not a cache, so a resumed pass rewrites it under a kept record (feeds the finding's path 2) |
| 2 | grade table / record | scripts/0320-tune-run.R:282 (no-fit key) | `unlink()` of both in one call | Yes |
| 3 | grade table / record | scripts/0320-tune-run.R:455-462 (kept table) | writes a record only when none exists; a mismatched record forces a regrade | Yes |
| 4 | grade table / record | scripts/0320-tune-run.R:485 then 493 (regrade) | `.knw_write_whole` table, then `write_record` | Window: new table with the old record. Every reader checks md5 (0320, promote, plan), so it fails toward refusal |
| 5 | grade table / record | R/grade_record.R:94 | record written whole | Yes |
| 6 | grade table / record | R/tune_promote.R:337-351 | both match `^<key>_`, moved in one vector; replaced ones in one `file.rename` | Pre-existing #111 shape, named in the error; readers check md5. No new gap |
| 7 | grade table / record (and the batch's other objects) | R/archive.R:416-470 (`knw_archive_pull`) | restores the batch whose record row matches the checkout's record md5 | Grades and record: yes (round 3 fixed). Each file is moved in only after its md5 checks; a stop partway leaves files each correct for the batch, and the skipped mtime fix fails toward 0330's refusal. **Curve and segments: no**, when two batches share the record (finding) |
| 8 | grade table / record | data-raw/archive_seed.R:62-67 | record into STAGE, `file.copy` into data/tune | One-shot, already run; migrated index matches it |
| 9 | bucket current / index vid | R/archive.R:299-348 (`knw_archive_put`) | put per object; index appended once at the end | Interrupted: objects current but unindexed. The rerun's skip path records them under a new batch, which becomes the tail for that record. Consistent after a rerun (an unpromoted 0336 names no remedy, but a rerun is the natural one, and nothing is lost before 180 days) |
| 10 | bucket current / index vid | R/archive.R:497-528 (`knw_archive_undo`) | copy-object per object, appended per object, events at the end | Distinct records: yes, and a stop partway is completed by a rerun (tests). **Shared record: no** (finding) |
| 11 | bucket current / index vid | R/archive.R:318-319, 508-512 (skip paths) | records the current vid when its md5 matches | Yes: same bytes; copy-object keeps the metadata |
| 12 | published run / bucket objects | R/archive.R:262-277 (unpromoted guard) | refuses an object whose `source_md5` differs from the published batch's, in the published setup | Yes for the published batch (round 3 fixed; test). A superseded batch is unprotected by design, which is what lets the finding's path 1 add a second batch with the same record |
| 13 | promotion events / data/tune | scripts/0335-promote.R:118 then 143-149 | move, then archived rows and events | Window: the index names the old batch published, and an unpromoted put is compared with the old content. Fails toward refusal; the error names `0336 PROMOTED=TRUE` |
| 14 | promotion events / data/tune | scripts/0335-promote.R:139-142 (BUNDLES=FALSE, no evidence) | move, no events | Same as 13; the message names the command and the machine |
| 15 | promotion events / data/tune | scripts/0335-promote.R:109, 132-137 (undo) | bucket checked, move back, then `knw_archive_undo` | Distinct records: failure named with a rerun command. A record never archived refuses on every rerun (accepted residual) |
| 16 | promotion events / data/tune | R/tune_promote.R (unfitted key loses its tracked files) | no events | The index keeps the old batch published; the guard fails toward refusal |
| 17 | promotion events / data/tune | 0335 undo of a pre-#119 `replaced_*` | `archive_keys()` finds no record, so no events | Same as 16 |
| 18 | promotion events / data/tune | scripts/0336-archive.R:88 without PROMOTED | archived rows under a new batch, no events | Same content: harmless, and the new batch is the record's tail. Other curve or segments under a published record: refused by the guard. **Under a superseded record: accepted, and it becomes the record's tail (finding's path 1)** |
| 19 | segments / grades mtime | R/archive.R:423, 463-470 | grades first, segments last, then mtime raised | Yes |
| 20 | segments / grades mtime | R/tune_promote.R:341-345 | rename, or copy with `copy.date` | Yes |
| 21 | evidence / grades evidence_md5, ledger | R/archive.R:112-147 (plan) | visit tables against `evidence_md5`; sites.rds against the ledger's `md5_sites` | Yes (fdis_sites and reconcile are the accepted residual) |
| 22 | evidence objects / index | R/archive.R:157-164, 427-431 | `evidence/<MANIFEST md5>/`, content-addressed. Pull selects by `evidence_id` over every batch, `is.na(key)`, MANIFEST excluded | Yes: an evidence object's md5 equals its source's, so the skip path always takes it and it is never made noncurrent; any row's version holds the same bytes. Key-NA rows are outside `.knw_archive_batch_rows` and `.knw_archive_published` (`%in%` on NA is FALSE) |
| 23 | index / migrated seed (new) | data/archive_index.csv | `batch` column added; events carry batch and record md5 | Yes: 47 rows, one batch; the record rows' `source_md5` and the `promoted` events' md5 equal the eight tracked records; the grades rows equal the records' `grades_md5` |
| 24 | published batch / events (new) | R/archive.R:213-221, 354-367 | replay by batch; `superseded`/`undone` name `cur$batch` | Yes for distinct batches. When the restored batch is the published one (path 2), no `undone` is written: consistent only if the checkout's objects are that batch's (finding) |
| 25 | undo copy rows / batch (new) | R/archive.R:519-522 | a copy keeps the source row's batch, appended after it | Yes: `!duplicated(fromLast = TRUE)` takes the copy (current version) in pull, undo and the guard alike |
| 26 | put skip rows / batch (new) | R/archive.R:318-319, 334 | an unchanged object is recorded under the new batch with the current vid | Yes: same bytes. If zstd's output differs between machines, the grades are re-put as a new version under the new batch, which is also the record's tail, so pull and undo follow the current version |
| 27 | batch id (new) | R/archive.R:383-386 | time to the second + digest of the plan's objects and md5s | A collision needs the identical plan in the same second; its rows would then share objects and dedupe to the last. Harmless |

Everything except rows 7, 10, 18 and 24 (the shared-record case) is consistent, or fails toward refusal with a named
remedy. Those four are the single finding above: the record's md5 identifies the grade table, not the batch's curve and
segments.
