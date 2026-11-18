# Code-check round 1: branch 178-backlog-move-9-access-gradients-and-grad (base 434ab55f)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus "Documentation Staleness". Not read: the remaining 23 standalone/Security/Spreadsheet headings (none names a tool or shape this diff uses).
- code-check-r.md: read "`$` on a list partial-matches, so a longer sibling key answers for a missing one", "`vapply(..., USE.NAMES = FALSE)` strips ALL dimnames, row names included", "testthat counts an uncaught error under `error`, not `failed`", "Tests that silently do not run", "`nzchar(NA)` is TRUE — non-empty checks silently pass NA", "`match()` treats NA as a matchable VALUE, so two unknowns join to each other", "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`", "`expect_gt()` and friends take no `info` argument", "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests" (9 read; 113 not read).
- code-check-shell.md: none read (the diff has no shell; 72 not read).
- code-check-spatial.md: none read (no spatial code; 94 not read).

## What was checked, and held

- `knw_literature_read()` is the only reader of `data/literature_evidence.csv` (grep over R/, scripts/, data-raw/, vignettes/, tests/, inst/), so the new capability guard in `.literature_check()` covers every path into 0280's COVERAGE and ACCESS counts.
- Mutation: with the guard replaced by `rep(FALSE, nrow(x))` in a detached worktree, "a leap or swimming-speed row is a fish's capability, never a model parameter" goes red; on HEAD test-literature.R is 48 blocks, 0 failed, 0 error, 0 skipped (`NOT_CRAN=true`).
- Every variable in `knw_literature_vocab()$variable` has an entry in `fits`, so `fits[[v]]` never returns NULL for a valid variable; `mfits[[v]]` is reached only for variables that are in it.
- The table reads: 1189 data rows, 20 fields each, the 36 new rows appended at the end (no insertions); all `data row N` cross-references in the new notes resolve to the row they describe; the 20261118 0280 log verifies rows 1154-1189 (33 verified, 3 `none_row`).
- ACCESS's 13 species equal link's installed and checked-out `configs/default/parameters_fresh.csv` today; the exit condition includes `any(access$rows == 0)`.
- `passage_limits_members.csv` (19 rows x 3) and `passage_limits_additions.csv` (6 rows x 18) parse with `csv.DictReader` as 0270 reads them; no row has a DOI, so `override` is inert; `{...}` creators go to `row_creators()`'s organisation branch; every `pdf` path exists under the ignored `data/rag/pdf/passage_limits/`.
- The two `merge-items` verdict rows parse to 7 fields with a known action; 0275's `do_merge_items()` refuses unless the kept item holds a stored PDF, and both kept items now do (VDT8YQJT through 0270's member `pdf` URL), so a re-run cannot trash the only copy.
- `planning/backlog.md` through soul's `backlog_moves.sh`: `list`, `next`, `free` and `lanes` all read it (rc 0); `tick '#178'` on a copy flips move 9 and ticks only batch 14's checkbox.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:85 — `ACCESS$species` is a hand-typed copy of link's `configs/default/parameters_fresh.csv` species list, and the grid only ever checks that list. The comment above it states the property as "Each species link's default models has an access gradient", which is a fact about link's artifact, not a contract this repo chose; link added GR and KO to that file in 2026 (the research file says so), and the next species it adds will be absent from ACCESS, so 0280 keeps exiting 0 with that species unsearched. The guard fails toward pass on exactly the drift it exists to catch. Read the species from the installed link's `parameters_fresh.csv` (0310 already loads link's default config), or keep the literal and stop when it differs from link's.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** R/literature.R:137-139 (and so man/knw_literature_read.Rd) — the reader's documentation still says "A `temperature`, `air_temperature`, `degree_days`, `instream_flow` or `fish_length` value needs a `metric` ...; every other row leaves `metric` blank." On this branch a `swim_speed` value needs a metric too (`.knw_metric_fits()`), so the exported reference page states the opposite of what the reader enforces, and a drafter following it writes swim-speed rows the reader refuses. Same staleness in 0280's header: its OUTPUT block lists the failures that exit non-zero ("coverage cell, thermal cell or flow cell") without the new access cell. Doc-only; nothing runs wrong.
  - **Rule:** code-check.md "Documentation Staleness"

No bugs or security issues found in the code paths; the two items above are a guard that can go silently stale and a stale reference sentence.
