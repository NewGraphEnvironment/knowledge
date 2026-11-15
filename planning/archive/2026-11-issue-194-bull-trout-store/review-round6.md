## Checklist read

Read all five indexes (code-check, -r, -shell, -spatial, -python) and code-check-python.md in full. In code-check.md I read the
prose of every H3 under `## Mechanisms`, skipping the table rows. In code-check-r.md I read the full sections the diff's
tools reach: "`on.exit()` at a script's top level never fires" (it does not apply: `doc_origins()`'s `on.exit()` sits inside a
function), "`dbConnect(SQLite(), path)` CREATES the file…", "`tryCatch(warning = )` DISCARDS the value…", "Do not abort
inside a handler for a warning raised from C++…", "duckdb in R: the query that autoloads `icu`…" and "duckdb refuses a
parent delete…". The diff has no shell, spatial or Python code.

Scope: `git show 213e0fcc`. I read scripts/0150-store.R:190-262, cred 0.7.0's `crd_store_build()`, `.crd_store_report()`,
`.crd_store_skipped()` and `crd_store_connect()`, and ragnar 0.3.0.9000's `ragnar_store_create_v2()` and
`check_store_overwrite()`.

Checked and true (no finding):
- The update guard still reads the same vector: `before <- doc_origins()` on an existing file, the same function and query
  as before the move. A missing file gives `character(0)`, and then the update's own `!file.exists()` stop fires, as it
  did before.
- A fresh build (no file) gives `before = character(0)`, so `if (length(before))` prints no counts. That is right: there
  is no prior store to compare. Nothing outside that block uses `after`.
- A build without OVERWRITE over a valid store: the pre-read succeeds, then `crd_store_build()` refuses with "Store already
  exists" after `collection_keys()`, as before.
- Connection and lock: `doc_origins()` disconnects with `shutdown = TRUE`, so the read-only instance is gone before ragnar
  opens the file read-write. Round 5's scratch build on `statistics` exercised this sequence, and the after-read follows
  cred's own `shutdown = TRUE` in its `on.exit`. When another process holds a write lock, the pre-read now refuses where an
  OVERWRITE rebuild used to unlink the file under that writer. That is a safer change, not a regression.
- A store left by a killed build: a timeout-killed build of scratch `zzr6` left a main file and a `.wal`. A copy of them
  read through the same function and query returns 3 origins, so the pre-read does not block a rebuild over such a store.
- When cred aborts a build, the script stops at `crd_store_build()` before any `doc_origins()` runs. A build where every
  PDF is skipped aborts in cred ("No PDF could be ingested"), and the same applies. Either way cred's `on.exit` unlinks the
  file, so no after-read meets a missing file.
- "cred names those only in a warning R cuts at warning.length (1,000 characters)" holds: `.crd_store_report()` names
  skipped PDFs only through `warning()`, and `getOption("warning.length")` is 1000.
- Log line 134, "cut partway through its seventh": the warning (log lines 125-132) ends inside the seventh entry,
  `stuart_chislett1979AspectsLife ( [... truncated]`.
- In enumeration_round3.md, "4 documents before, 4 after" matches: `statistics.duckdb` holds 4 distinct origins.
- README:268-270 and the message after an update describe what the code now prints. README:264's sentence about an update
  printing its before and after counts is still true.

Scratch files: `data/rag/zzr6.duckdb` and its `.wal` were deleted afterwards. `git status` is clean.

## Findings

- **[severity: fragile]** scripts/0150-store.R:212: the pre-read now makes `ACTION=build OVERWRITE=TRUE` fail over any file
  at the store path that is not a readable ragnar store. Before 213e0fcc, such a rebuild replaced the file, because
  ragnar's `check_store_overwrite()` unlinks it. Now `doc_origins()` runs first, on every build where the file exists,
  and stops the script with a raw duckdb error that offers no remedy. This covers three cases: a 0-byte file, a file that
  is not a duckdb database ("exists, but it is not a valid DuckDB database file!"), and a valid duckdb with no `documents`
  table.
  - Reproduced on a scratch name. With `data/rag/zzr6.duckdb` holding 5,000 random bytes,
    `ACTION=build STORE=zzr6 COLLECTIONS=LP4R4VYR OVERWRITE=TRUE Rscript scripts/0150-store.R` exits 1 in
    `duckdb:::rethrow_error_from_rapi` before `collection_keys()` runs.
  - Under the same command, the pre-fix script (`git show 213e0fcc^:scripts/0150-store.R`) replaced the file and reached
    "Ingesting 4 PDF(s) into data/rag/zzr6.duckdb".
  - Impact: the command meant to replace a store refuses exactly the broken store it would replace, until the operator
    deletes the file by hand. cred's pulls are atomic (`.part-<pid>` then rename), so such a file is uncommon.
  - For a build, an unreadable prior store should mean "nothing to compare": say so and go on, for example by computing
    `before` under `tryCatch()` on the build path only. The update path rightly keeps refusing.
  - **Rule:** code-check.md "A guard that fails toward pass" ("What the guard reads": treat unreadable as a third state
    beside pass and fail)
