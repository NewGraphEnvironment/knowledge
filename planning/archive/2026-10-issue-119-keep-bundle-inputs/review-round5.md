# Code-check round 5 (#119): round 4's batch selection, by enumeration

## Checklist read

- `code-check.md.index`, `code-check-r.md.index`, `code-check-shell.md.index`, `code-check-spatial.md.index`,
  `code-check-python.md.index`: in full.
- `code-check-python.md`: in full (nothing in this diff is Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (evidence blocks and `|` rows skipped), weighted to
  "A proxy is not the property", "A guard's scope, escape hatches, and remedies" (run the remedy for every input the
  clause can receive; a guard written against the whole artifact redefines a mode that holds a subset), "Written data
  outlives the fix", "A fix lands in one of two callers that share a harness" (pull and undo share
  `.knw_archive_batch_rows()`; diff their contracts).
- `code-check-r.md`: "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`" (0336's `BATCH=`),
  "`system2(stdout = TRUE)` warns…" (`.knw_aws` reads the status: fine), "`tryCatch()` nests its handlers" (fine),
  "`fs::file_move()` onto an existing directory…" / `file.rename()` return checked (fine).
- `code-check-shell.md`, `code-check-spatial.md`: indexes only; no shell or spatial code changed in round 4's fix.

Method: read `round4_fix.diff`, the current `R/archive.R`, `R/tune_promote.R`, `scripts/0335-promote.R`,
`scripts/0336-archive.R`, `review-round4.md`. Probes in `scratchpad/r5/`: `enum.R` calls `.knw_archive_batch_rows()`
on a synthetic index for every case in table 1; `undo_probe.R` and `undo_stale.R` drive `knw_archive_put()` and
`knw_archive_undo()` end to end on the test file's mock bucket. `tests/testthat/test-archive.R` from a copy: 61 passed,
0 failed, 0 errors. Read-only check on this checkout: the selection with the checkout's own `data/tune` and
`data/compare` refuses all 8 keys of the real `data/archive_index.csv` (below).

## Findings

- **[severity: bug]** R/archive.R:548 (`knw_archive_undo()`), with R/archive.R:241-261 (`.knw_archive_batch_rows()`)
  and scripts/0335-promote.R:132-137. Round 4's fix makes undo select the batch by the restored curve and segments,
  and break a tie by the *currently published* batch. Undo has no way out when either check cannot decide. 0335 has
  already moved the tables back when it calls undo, and its printed remedy reruns the same call, which fails the same
  way. The index keeps naming the undone run as published. In a tokened folder the restored run's objects stay
  noncurrent, so the 180-day lifecycle deletes them. That is the loss round 1's copy-back exists to prevent. There are
  two ways in, and both are reachable:
  - **The restored files are stale.** `replaced_<stamp>/` holds whatever ignored curve and segments the promoting
    machine had, and CLAUDE.md says a host's `data/` can be an older build than the published run.
    - On this checkout today, all 8 keys' local curve and segments match no archived batch (read-only probe: "no
      archive holds this record with the …_curve.rds, …_segments.rds here" for BT_rear … WCT_rear).
    - A promotion made here and then undone refuses on every key.
    - Before round 4, the undo selected by the record alone and would have succeeded.
    - `undo_stale.R` (tokened folder: R1 promoted, R2 promoted, undo with a stale curve) prints the refusal on the
      first try and on the rerun. Afterwards it prints "published after: 20261102_0000", and the current curve
      version is still R2's.
  - **The record is ambiguous and the restored files cannot decide.** Take two batches with R1's record and different
    segments: 0336 `RUN=R1` archives the candidate, 0330 is re-run, then R1 is promoted. R2 is then promoted on a
    machine without R1's ignored files, and undone.
    - The tie-break reads `.knw_archive_published()`, which during an undo is the batch being undone, so it never
      applies.
    - `undo_probe.R` prints "archives …-4c34bd85, …-31ba0561 hold this record with other files; name one (BATCH=)".
      `knw_archive_undo()` takes no batch (formals: keys tune_dir index bucket compare_dir).
    - The index already names the right answer: the batch R2's promotion superseded.
    - Where the undone promotion carried the restored record itself (round 4's path 2) and the restored files lack the
      differing object, the tie-break returns the undone batch (`enum.R` case 8a). `.knw_archive_events()` then writes
      `promoted` for the undone batch again, with no `undone` event.
  - The property undo needs: the batch the undone promotion superseded (its record equal to the restored one). The
    restored ignored files may confirm it, but they cannot veto it, because they are only what the promoting machine
    happened to hold.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (run the remedy for every input: 0335's
    rerun cannot succeed; a guard against the whole artifact redefines the subset mode). Also "A proxy is not the
    property" (the published batch stands in for "the batch this operation restores", and in an undo it is the
    opposite).

- **[severity: bug]** R/archive.R:464 (`knw_archive_pull()`: `batch[[k]]`), with scripts/0336-archive.R:53-54 and
  78-80. `batch` is documented as "batch ids by key" for an ambiguous record, and the refusal asks for exactly that
  (`name one (BATCH=)`). But `batch[[k]]` on a named character vector errors for any key it does not name.
  - 0336's default `PULL=TRUE` takes every key with a record (8 on this checkout). `BATCH=CH_rear=<b>`, the remedy the
    refusal gives, therefore stops on the first other key (`BT_rear`, alphabetically first) with "subscript out of
    bounds", before anything is restored.
  - Only `KEYS=CH_rear` together with `BATCH=` works, and the message does not say so.
  - A `BATCH=` value without `key=` gives a named `NA` and fails the same way.
  - The probe (0336's two parsing lines, then `batch[["BT_rear"]]`) prints "ERR subscript out of bounds".
  - **Rule:** code-check-r.md "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`". Also
    code-check.md "A guard's scope, escape hatches, and remedies" (run the remedy yourself).

Note, not a finding: on a checkout whose ignored files are an older build (this one), pull now refuses at the
selection with "no archive holds this record with the X here", where before it refused per file with "move it aside
to restore". It still fails toward refusal, but the remedy it named is gone. The same message also lists every local
file, the matching ones included.

## Table 1: `.knw_archive_batch_rows()`, every case

Property:
- **Pull** returns a batch whose record is the checkout's, and whose every other object equals the checkout's copy
  wherever the checkout holds one.
  - Where several such batches differ in an object the checkout lacks, it takes the published one if it is among them,
    and otherwise refuses with a remedy that works.
  - Where the checkout's file is in no batch, it refuses and says to move the file aside.
- **Undo** returns the batch the undone promotion superseded.

Batches: A (c1, s1); A2 (c1, s1), identical to A; B (c1, s2); C (c2, s1); X (another record). "local" is what the
checkout holds besides the record. All cases are from `enum.R` unless marked e2e.

| # | Candidates sharing the record | Local held | Published | Returns | Right? |
|---|---|---|---|---|---|
| 1a | A | none | none | A | yes |
| 1b | A | curve c1 | none | A | yes |
| 1c | A | segments s1 | none | A | yes |
| 1d | A | c1, s1 | none | A | yes |
| 1e | A | curve c2 (stale) | none | refuse "no archive holds … here" | pull: yes, but the "move aside" remedy is lost (note). Undo: **no** (finding 1) |
| 1f | A | c1, s2 (mixed) | none | refuse | pull yes; undo **no** (finding 1) |
| 2a | A, A2 identical | none | none | A2 (tail) | yes: same bytes |
| 2b | A, A2 | c1, s1 | none | A2 | yes |
| 2c | A, A2 | c2 (stale) | none | refuse | as 1e |
| 3a | A, B (segments differ) | none | none | refuse BATCH= | pull yes, but BATCH= breaks under default keys (finding 2); undo **no** (no batch argument) |
| 3b | A, B | c1 (does not discriminate) | none | refuse BATCH= | as 3a |
| 3c | A, B | s1 | none | A | yes |
| 3d | A, B | s2 | none | B | yes |
| 3e | A, B | c1, s2 | none | B | yes |
| 3f | A, B | s3 (stale) | none | refuse | as 1e |
| 3g | A, B | none | A | A | pull yes |
| 3h | A, B | c1 | B | B | pull yes |
| 3i | A, B | s2 | A (filtered out) | B | yes: the checkout's file wins over publication |
| 3j | A, B | none | X (not a candidate) | refuse BATCH= | pull yes (finding 2 for the remedy); undo of X: **no**, A or B by which X superseded (finding 1, e2e `undo_probe.R`) |
| 3k | A, B | none | none (A superseded) | refuse BATCH= | pull yes |
| 3l | A, B; A superseded by X | none | X | refuse BATCH= | undo of X: **no**, A is determinable (finding 1) |
| 4a | A, C (curves differ) | s1 | none | refuse BATCH= | as 3a |
| 4b | A, C | c2 | none | C | yes |
| 4c | A, C | s1 | C | C | pull yes |
| 5a | A, B | none | none | `batch = "A"` gives A | yes |
| 5b | A, B | none | none | `batch = "X"` refuses "does not hold this record" | yes |
| 5c | A, B | s2 | none | `batch = "A"` gives A, local ignored | yes: the per-file md5 check then refuses s2 ("here with another md5") |
| 5d | A, B | none | none | `batch = NA` refuses | yes (and see finding 2 for how 0336 produces NA) |
| 6a | A, B, A2 | s1 | none | A2 | yes |
| 6b | A, B, A2 | none | none | refuse BATCH= | as 3a |
| 6c | A, B, A2 | none | A | A | yes |
| 7a | A, B, then A's undo copy rows | s1 | none | A (with the copy's versions) | yes |
| 8a | A, B; B promoted over A | c1 | B | B | pull yes; undo of B: **no**, A is right and the events re-promote B (finding 1) |
| e2e-U1 | two batches of R1's record (segments differ), then R2 promoted | none (replaced_ without ignored files) | R2 | refuse BATCH=; undo has no batch | **no** (finding 1) |
| e2e-U2 | R1 only, tokened; R2 promoted | stale curve | R2 | refuse, and refuse again on the rerun; R1's curve stays noncurrent | **no** (finding 1) |
| real | this checkout, 8 keys, 1 batch | each key's curve and segments (an older build) | the seed batch | refuse, all 8 | pull: refuses (note); an undo here: **no** (finding 1) |

The axes are covered: candidate count (1, 2 identical, 2 differing in segments, 2 differing in the curve, 3 mixed);
local (none, curve, segments, both, stale, mixed); published (none, among, filtered out, not a candidate, being
undone); named batch (in, out, NA). Byte-identical candidates are 2a, 2b and 6a. Every wrong cell is an undo (finding
1), and every refusal whose remedy fails is a BATCH= under the default keys (finding 2).

## Table 2: round 4's enumeration re-run on the current code, plus round 4's new paths

| # | Pair | Path (file:line, current) | What it writes / deletes | Consistent at every step, incl. failure partway? |
|---|------|------------------|--------------------------|--------------------------------------------------|
| 1 | grade table / record | scripts/0320-tune-run.R:249, 275 | pass-start clear keeps both (`caches`) | Yes (unchanged) |
| 2 | grade table / record | scripts/0320-tune-run.R:282 | `unlink()` of both | Yes |
| 3 | grade table / record | scripts/0320-tune-run.R:455-462 | record written only when none; a mismatched one regrades | Yes |
| 4 | grade table / record | scripts/0320-tune-run.R:485, 493 | table whole, then record | Window fails toward refusal (md5 checked by every reader) |
| 5 | grade table / record | R/grade_record.R (`knw_grade_record_write`) | written whole | Yes |
| 6 | grade table / record | R/tune_promote.R:337-351 | both moved in one vector | Pre-existing #111 shape; readers check md5 |
| 7 | batch objects / checkout | R/archive.R:450-516 (`knw_archive_pull`) | selects by record plus local curve and segments, then each file is md5-checked before it is moved in | Round 4's case: **fixed** when the checkout holds the discriminating file, or the published batch is a candidate. Otherwise it refuses with BATCH=, which breaks under the default keys (**finding 2**). A stale local file refuses earlier than before, without the move-aside remedy (note). A stop partway leaves files correct for the batch, and the rerun's `local` holds them, so it narrows to the same batch |
| 8 | grade table / record | data-raw/archive_seed.R | one-shot seed | Yes; the real index has 1 batch, 47 rows, 8 `promoted` |
| 9 | bucket current / index vid | R/archive.R:337-387 (`knw_archive_put`) | put per object, then the index once | Interrupted: objects current but unindexed; the rerun's batch has the same content, so the sets are identical and the tail is taken. Yes |
| 10 | bucket current / index vid | R/archive.R:538-576 (`knw_archive_undo`) | copy-object per object, appended as made | With the restored curve and segments both archived: yes (round 4's test). Stale or partial restored files: **no** (finding 1) |
| 11 | bucket current / index vid | R/archive.R:353-358, 554-558 (skip paths) | records the current vid when its md5 matches | Yes |
| 12 | published run / bucket objects | R/archive.R:300-316 (unpromoted guard) | refuses another content over the published batch's objects | Yes (unchanged); a superseded batch is unprotected by design |
| 13 | promotion events / data/tune | scripts/0335-promote.R:118, 143-149 | move, then archive | Fails toward refusal with a 0336 command that works |
| 14 | promotion events / data/tune | scripts/0335-promote.R:139-142 | move, no events | As 13 |
| 15 | promotion events / data/tune | scripts/0335-promote.R:109, 132-137 (undo) | bucket checked, move back, then `knw_archive_undo(ak)` with the default dirs | The default `compare_dir` is right: `knw_tune_promote()` moves the replaced segments into `data/compare`. **No** where the restored ignored files are stale or cannot decide: the printed rerun fails identically (finding 1) |
| 16 | promotion events / data/tune | R/tune_promote.R (unfitted key) | no events | Fails toward refusal (unchanged) |
| 17 | promotion events / data/tune | 0335 undo of a pre-#119 `replaced_*` | no record, no events | As 16 |
| 18 | promotion events / data/tune | scripts/0336-archive.R:93 without PROMOTED | archived rows, a new batch | Same content: harmless (identical sets). Other curve or segments under a superseded record: accepted, so the record becomes ambiguous. Pull with the discriminating local file, or with the published batch among the candidates: right. Otherwise refuse/BATCH= (finding 2). Undo: finding 1 |
| 19 | segments / grades mtime | R/archive.R:466-467, 505-514 | grades first, segments last, mtime raised | Yes |
| 20 | segments / grades mtime | R/tune_promote.R:341-345 | rename, or copy with dates | Yes |
| 21 | evidence / grades, ledger | R/archive.R:112-147 | visit tables to `evidence_md5`, sites.rds to the ledger | Yes (fdis_sites and reconcile are the accepted residual; the batch sets exclude evidence rows, so two batches differing only there are taken as identical, inside the same residual) |
| 22 | evidence objects / index | R/archive.R:471-475 | by `evidence_id`, key NA, MANIFEST excluded | Yes; key-NA rows are outside `rows_of()` (`%in%` on NA is FALSE) |
| 23 | index / migrated seed | data/archive_index.csv | 1 batch; record and `promoted` md5s equal the tracked records | Yes. On this checkout the local curve and segments of all 8 keys are in no batch (note; finding 1) |
| 24 | published batch / events | R/archive.R:213-221, 393-406 | replay by batch | With full restored files: yes (an `undone` is written for B2 and B1 is promoted). Partial: the tie-break picks the undone batch and re-promotes it (8a, finding 1) |
| 25 | undo copy rows / batch | R/archive.R:565-568 | copy keeps the batch, appended after | Yes: `rows_of()` dedupes fromLast, and `unique(r$batch)` keeps the first position (7a) |
| 26 | put skip rows / batch | R/archive.R:353-358, 373-377 | unchanged object recorded under the new batch | Yes: the sets compare `source_md5`, not `object_md5`, so a zstd byte difference does not make two batches "differ" |
| 27 | batch id | R/archive.R:422-425 | time plus digest | Yes. No `=` or `,` in an id, so 0336's `BATCH=` split is safe for the value |
| N1 (new) | `BATCH=` parsing / keys | scripts/0336-archive.R:78-80, R/archive.R:464 | named vector, `batch[[k]]` per key | **No** (finding 2) |
| N2 (new) | undo `compare_dir` | R/archive.R:538-548 | `local` from `tune_dir` and `compare_dir` | 0335 passes the defaults, which are right from the repo root. The tests that pass only `tune_dir` read the test directory's (absent) `data/compare`, so they test the curve alone: not a production path |
| N3 (new) | 0335's undo call / its remedy | scripts/0335-promote.R:133-136 | `knw_archive_undo(ak)`; on error, prints the same call | Distinct records with archived files: yes. Otherwise the remedy cannot succeed (finding 1) |
| N4 (new) | pull `local` / partial earlier pull | R/archive.R:462-464 | a curve restored by an interrupted pull narrows the rerun | Yes: it narrows to the batch that put it there |
| N5 (new) | pull `batch` / local | R/archive.R:237-240 | a named batch ignores local | Yes: the per-file md5 check refuses a conflicting local file (5c) |

Everything outside findings 1 and 2 is consistent, or fails toward refusal with a remedy that works. Finding 1 is
round 4's own axis one step on: undo inherited pull's rule, where "the checkout's files decide, then the published
batch" is right for pull. For an undo the restored ignored files are incidental, and the published batch is the one
being undone.
