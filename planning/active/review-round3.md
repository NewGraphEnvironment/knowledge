# Code-check round 3 (#127): branch diff 9e10a19...HEAD

## Checklist read

- `code-check-python.md`: read in full (7,237 B).
- `code-check.md`: read the prose of every H3 under `## Mechanisms` (table rows skipped).
- `code-check-r.md`: read the sections this diff's tools use: "`tryCatch()` nests its handlers", "`system2(stdout = TRUE)` warns on a non-zero exit", "`dbConnect(SQLite(), path)` CREATES the file", "`on.exit()` at a script's top level never fires", "`Rscript -e` supplies `--args` itself", "`identical()` on two reader results tests the reader", "`tempfile()` lives in the session tempdir", "Base `file.info()` has no inode column", "`tryCatch(warning = )` DISCARDS the value", "`$` on a list partial-matches".
- `code-check-shell.md` and `code-check-spatial.md`: no heading names a tool or pattern this diff uses (no sed, git, gh, ssh or spatial code), so neither was opened.

Ran `data-raw/zotero_copy_check.R` from a `git archive HEAD` copy in the scratchpad (`LIVE=FALSE STRESS_SECS=15`): PASS, every table ok. Two probes are described under the findings. One slip: a probe whose `cd` failed wrote `probe.R` into the repo root as an untracked file. I moved it out at once, and `git status --short` is clean again. Nothing tracked was touched.

## Mechanism and enumeration

**The mechanism.** The check gives a score to the *value* a case returns, and never establishes the *cause* of that value. That value has more than one producer. In round 1, "every accepted copy was committed" was the result both of a working stability guard and of the fact that torn copies are rare. In round 2, `NA` was the result both of the guard refusing and of any error on the hooked path. The assumption both rounds shared: the outcome a case scores as right can come only from the behaviour the case exists to test. This is code-check.md "A proxy is not the property" (two causes, one observation), arriving as "A guard that fails toward pass" (the error path and the expected path look the same). Round 2's fix moved the decision onto a sentinel string, "no consistent copy", matched as a substring. A substring match leaves the assumption alive wherever some other message can carry that string, or some other failure can raise the guard's own refusal.

**Where it reaches, with a verdict for each:**

| site | can a failure read as a pass? |
|---|---|
| `read_way()` `tryCatch` (fixtures) | No. An error leaves `opened = FALSE` and `n = NA`. The precondition needs `opened & quick_check == "ok" & n == want`, and `all()` over an NA fails `stopifnot`. The `stopifnot(file.copy(...))` calls sit outside the `tryCatch`, so a failed copy stops the check. |
| `read_way()` (live table) | Prints only and claims nothing. The PASS line does not mention it. |
| `r_guard()` | No. A non-refusal error is re-raised first. "Never fired" is tested before a refusal is re-raised, and that message carries no sentinel. |
| `py_guard()` "gave no result" | No. The REFUSED branch runs first, so this message cannot hold the child's REFUSED line. |
| `py_guard()` "hook never fired" | **Yes.** The message pastes the child's output, which holds the refusal text when the child refused. Confirmed by probe: Finding 1. |
| `guard_rows()`, fixture table | No. NA fails `gt$ok`. |
| `guard_rows()`, interference | Reachable only through Finding 1, and only when a hook does not fire. Today every NA-expected case hooks copy 1, which every try makes, so the current cases cannot reach it. |
| `guard_rows()`, stress | NA is scored ok by design (the stress measures). But an R guard's `file.copy()` returning FALSE (disk full) is also read as the guard's own refusal, so a resource failure joins the NA producers. `idle` catches only the case where every call gave up. See Finding 2. |
| `guard_rows()`, live guards | Prints only. |
| `gt$ok`, `it$ok`, `st$ok`, and the final `stop()`s | No. `gt` and `it` treat NA as a failure, except where the expected value is NA. The stops run before PASS. `!is.null(st)` is correct. |
| R `snapshot()` (0280 and 0150, identical) | Cannot return an unstable or half pair. A `dbConnect` error gives NULL and a retry. A `quick_check` error gives FALSE and a retry. A zero-row or NA `quick_check` makes `if (NA)` abort. The `-wal` appearing or vanishing is in `state()`. A failed `file.copy` makes `copied` FALSE and a retry. `return(con)` sits only after a stable state and "ok". The remaining gap is a same-size rewrite inside the mtime's resolution, which is accepted and measured by the stress. In production a disk-full copy ends in "is Zotero mid-sync?": that fails toward abort, with the wrong remedy, and harms nothing. |
| Python `db()` (0270) | Same verdict. `DatabaseError` means close and retry. An `OSError` from `copyfile` propagates, so it aborts. A missing `-wal` is caught and also shows in `stat(wal)` across the state. `return con` only after a stable state and "ok". |

## Findings

- **[severity: fragile]** data-raw/zotero_copy_check.R:267 (`py_guard`) together with :282 (`guard_rows`). The "hook never fired" error pastes the child's whole output: `stop("the ", event, " hook never fired: ", paste(out, collapse = " | "))`. When the child refused, that output contains `REFUSED no consistent copy of zotero.sqlite …`. `guard_rows()` then finds "no consistent copy" anywhere in the message with `grepl(fixed = TRUE)` and scores the dead hook as the guard refusing. This is round 2's defect on the one path round 2's fix did not order. `r_guard` checks `fired` before it re-raises a refusal, and its message carries no sentinel, so the two harness callers now differ.
  - **Probe:** a `wal_pending` copy with a hot-journal header (so the guard refuses every try without interference), `event = "touch_main", on = 3L, tries = 1` (so the hook never fires). Results: both R guards: `STOPPED: … the touch_main hook never fired`. 0270: `NA NA`, a refusal.
  - **Reach:** none of today's cases, because each NA-expected case hooks copy 1. Any future case whose `on` exceeds the copies a refusing try makes would pass unexercised.
  - **Fix:** match the sentinel at the start of the message (`startsWith(conditionMessage(e), "no consistent copy")` in `guard_rows()`, and the same in `r_guard`). Or check REFUSED before FIRED in `py_guard`, as `r_guard` orders it. Or leave the REFUSED line out of the "never fired" message.
  - **Rule:** code-check.md "A guard that fails toward pass" (a decision moved onto a channel with a reserved value). Also code-check.md "A fix lands in one of two callers that share a harness".

- **[severity: fragile]** data-raw/zotero_copy_check.R:224-225 (`r_guard`), :354-359 (stress loop), and scripts/0280-literature-verify.R / scripts/0150-store.R `snapshot()`. Each R `snapshot()` call writes a new `tempfile()` copy of the database, and the check never deletes it. `r_guard` disconnects but does not unlink. In the stress, each R guard runs hundreds of times on a growing database.
  - **Measured:** the session tempdir reached 249 MB in a 15 s stress (192 calls per guard, the database at up to 1,440 rows). The growth is about quadratic in `STRESS_SECS`, so the 90 s run the header cites would leave several GB until R exits.
  - **Why it matters beyond disk:** once the disk fills, an R guard's `file.copy()` returns FALSE. `snapshot()` treats that as an unstable copy, retries, and stops with "no consistent copy". `guard_rows()` scores that as NA, and `st$ok` counts NA as ok. So the stress goes on reporting `not_committed = 0` over calls that tested nothing. `idle` fires only if every call of a guard gave up. The Python guard is unaffected: `copyfile` raises, and its `atexit` removes its directory.
  - **Fix:** in `r_guard`, read the copy's path (`DBI::dbGetInfo(con)$dbname`) and `unlink(paste0(path, c("", "-wal", "-shm")))` after the disconnect.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things" (a failed value folded into the nearest definite one). Also code-check.md "Verification that reads its own output" (`file.copy()` signals failure by returning FALSE).
