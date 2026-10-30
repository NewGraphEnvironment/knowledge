# Code-check round 3 (#119): branch diff, mechanism enumeration

## Checklist read

- `code-check.md.index`, `code-check-r.md.index`, `code-check-shell.md.index`, `code-check-spatial.md.index`,
  `code-check-python.md.index`: in full.
- `code-check-python.md`: in full (nothing in this diff is Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (table rows skipped), in particular "A guard that fails
  toward pass" (the write path; where the guard sits), "A proxy is not the property", "A guard's scope, escape
  hatches, and remedies" ("already current" vs "never regenerated"), "Written data outlives the fix" (diff the ledger
  against the artifacts it claims), "One fact derived twice", "Verification that reads its own output".
- R sections whose index lines name what the diff uses: `system2(stdout = TRUE)` warns instead of raising;
  `tryCatch()` nests its handlers; `fs::file_move()` / `file.rename()`; `on.exit()` at top level; Postgres row
  order; CSV whitespace / `read.csv` na handling; `identical()` on reader results. Shell: `aws s3 cp` cannot tell a
  missing key from a missing bucket; S3 multipart ETag. None of these produced a finding beyond the one below.

## Mechanism

Rounds 1 and 2 each found a place where two stores were assumed to agree because one write usually follows the other
(grade table and record; bucket current version and index version id; promotion events and the files in `data/tune`;
segments and grades). Round 3's instance is the same mechanism one level up: **the archive identifies a run's content
by its `tune_run` name**, and a name is a proxy for the content. `knw_archive_put()`'s guard, `knw_archive_pull()`
and `knw_archive_undo()` all select or protect "the run" as `tune_run` (and "its objects" as the *last* archived row
of each object under that name), while the tracked record that names the run also pins its content (`grades_md5`, and
the record's own bytes). 0320 explicitly allows one run name to carry different tables over time (`RUN=<existing>`
resumes and regrades), and 0335 promotes by key, so a promoted key's run can be resumed, regraded and archived (or
promoted) again under the same name.

## Findings

- **[severity: bug]** R/archive.R:258-259 (`knw_archive_put()` guard), R/archive.R:391-394 (`knw_archive_pull()`),
  R/archive.R:473-474 (`knw_archive_undo()`) — a later archive of the same run name with other content overwrites the
  published objects, and pull and undo then pick it instead of the version the tracked record describes.
  - The guard refuses an unpromoted put only when `!identical(pub$tune_run, plan tune_run)`. The same name with
    regraded content (`0320 RUN=<run>` resumed after a by-key promotion, then `0336 RUN=<run>`) passes it, and
    `put-object` makes the published version noncurrent, so it expires in 180 days. The index still lists it, but
    under an earlier row.
  - `knw_archive_pull()` takes `a[!duplicated(a$object, fromLast = TRUE)]` among rows of `rec$tune_run`, which is the
    *newest* archive of that name, not the one whose `source_md5` is the tracked record's `grades_md5`. It restores
    grades first and moves the wrong table into `data/tune/`. It then stops on the record row ("is here with another
    md5") before the post-loop `knw_grade_record_check()` can run, so the checkout is left holding a grade table its
    tracked record does not describe.
  - `knw_archive_undo()` selects the same way. After "promote K from run R → resume R → promote K again → undo the
    second promotion" (all through 0335), it finds the newest version of R already current and skips. The index's
    last rows point at the second content, and the version the restored record describes stays noncurrent and
    expires. The record object alone has the same problem even when the regraded table is byte-identical, because the
    record's `knowledge_commit` (and possibly `evidence_ledger`) differ at a later commit.
  - Reproduced on the test file's mock bucket (scratchpad `r3/probe1.R`, `r3/probe2.R`):
    - Unpromoted put of the same run name with `grade = 0.2` over a promoted `grade = 0.1`: "11 rows appended", 2
      versions of the grades object.
    - Pull with the first record tracked: refused on the record, and `data/tune/CH_rear_grades.csv` was left in place.
    - Undo: the current grades version is `v012`; the published one, `v001`, is noncurrent. The index's last grades
      row `source_md5` does not equal the restored record's `grades_md5`.
  - Remedy direction: identify an archive by content, not by name.
    - Pull and undo select the archived rows of the run whose `_grades_record.csv` row's `source_md5` equals the
      tracked record's md5, falling back to `grades_md5` for the grades row, and refuse when none matches.
    - The put guard compares the published run's record md5 (or `grades_md5`) with the plan's, not `tune_run`.
  - **Rule:** code-check.md "A proxy is not the property" (and "A guard's scope, escape hatches, and remedies": an
    identifier that can be reused identifies a configuration, not an instance).

## Enumeration: every path that writes or deletes one member of a pair

| # | Pair | Path (file:line) | What it writes / deletes | Consistent at every step, incl. failure partway? |
|---|------|------------------|--------------------------|--------------------------------------------------|
| 1 | grade table / record | scripts/0320-tune-run.R:249-251,275 (pass-start clear) | deletes non-cache key files; `caches` now keeps `_grades.csv` and `_grades_record.csv` together | Yes: neither member is deleted |
| 2 | grade table / record | scripts/0320-tune-run.R:282 (no-fit key) | `unlink()` of both in one call | Yes (an orphan record could survive only a kill inside one `unlink()`, and the next pass deletes it) |
| 3 | grade table / record | scripts/0320-tune-run.R:455-462 (kept table) | writes a record only when none exists; a mismatched record forces a regrade | Yes |
| 4 | grade table / record | scripts/0320-tune-run.R:485 then 493 (regrade) | `.knw_write_whole` table, then `write_record` | Window: new table with the old record. Every reader checks md5 (0320 next pass regrades; promote and plan refuse), so it fails toward refusal |
| 5 | grade table / record | R/grade_record.R:94 (`knw_grade_record_write`) | record written whole | Yes |
| 6 | grade table / record | R/tune_promote.R:337-350 (move in, replaced to archive) | both match `^<key>_`, so they move in one `copies` vector, replaced ones in one `file.rename` | A failure inside the vector is #111's pre-existing shape, named in the error; readers check md5. No new gap |
| 7 | grade table / record | R/archive.R:407-433, 437-444 (`knw_archive_pull`) | restores the grades by the index row; the record is tracked | **No: finding above.** Rows are chosen by `tune_run`, newest first, so a wrong table can be moved in before the record row refuses |
| 8 | grade table / record | data-raw/archive_seed.R:62-67 | record into STAGE, `file.copy` into data/tune | One-shot, already run; holds the table to the manifest and pins first |
| 9 | bucket current / index vid | R/archive.R:285-329 (`knw_archive_put`) | put per object; index appended once at the end | Interrupted: objects current but unindexed. A promoted put's superseded run expires by design, the unpromoted guard keeps a published run out, and the rerun's skip path records the current vids. Consistent after the named remedy, except row 12's case |
| 10 | bucket current / index vid | R/archive.R:475-495 (`knw_archive_undo`) | copy-object per object, appended per object (round 2 fix) | Yes for a distinct run name; **No** for a reused name (finding) |
| 11 | bucket current / index vid | R/archive.R:300-305 (skip path) | records the current version's vid when its md5 matches | Yes: same bytes, and copy-object keeps the metadata |
| 12 | published run / bucket objects | R/archive.R:255-264 (guard) | refuses only a different `tune_run` in the published setup | **No: finding above** |
| 13 | promotion events / data/tune | scripts/0335-promote.R:118 then 142-151 (promote, then put promoted) | move, then archived rows and events | Window between them: the index names the old run published. That fails toward the guard refusing; the error names `0336 PROMOTED=TRUE` |
| 14 | promotion events / data/tune | scripts/0335-promote.R:137-141 (BUNDLES=FALSE, no evidence) | move, no events | Same as 13; the message names the command and the machine |
| 15 | promotion events / data/tune | scripts/0335-promote.R:132-136 (undo) | move back, then `knw_archive_undo` | Failure is named with a rerun command; the bucket was checked before the move |
| 16 | promotion events / data/tune | R/tune_promote.R:226-227 (unfitted key loses its tracked files, record included) | no events | The index keeps the old run as published, so the guard fails toward refusal. Harmless |
| 17 | promotion events / data/tune | 0335 undo of a pre-#119 `replaced_*` (no records) | `archive_keys()` finds none, so no events | Same as 16: fails toward refusal; that run is untokened, so no shared folder is at risk |
| 18 | promotion events / data/tune | scripts/0336-archive.R:89 without PROMOTED on the published tables | archived rows, no events | Harmless: a later promotion's events supersede by replay |
| 19 | segments / grades mtime | R/archive.R:397, 442 (pull ordering and mtime fix) | grades first, segments last, then mtime raised | Yes (round 1 fix) |
| 20 | segments / grades mtime | R/tune_promote.R:342-344 | rename, or copy with `copy.date` | Yes |
| 21 | evidence / grades evidence_md5, ledger | R/archive.R:111-145 (plan) | visit tables against `evidence_md5`; sites.rds against the ledger's `md5_sites` (present in all three real ledgers) | Yes (fdis_sites and reconcile are the accepted residual) |
| 22 | evidence objects / index | R/archive.R:157-162, 403-405 | content-addressed folder `evidence/<MANIFEST md5>/`, never overwritten with other bytes | Yes |

Everything except rows 7, 10 (reused name) and 12 is consistent, or fails toward refusal with a named remedy. Those
three are the single finding above: one mechanism, `tune_run` standing in for content.
