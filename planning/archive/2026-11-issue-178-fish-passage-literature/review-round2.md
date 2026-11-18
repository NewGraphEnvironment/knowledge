# Code-check round 2: branch 178-backlog-move-9-access-gradients-and-grad (HEAD 464a8f01, base 434ab55f)

## Checklist read

- `code-check-python.md`: read in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (evidence tables skipped), all fourteen.
- `code-check-r.md` by heading: "`$` on a list partial-matches, so a longer sibling key answers for a missing one",
  "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests", "`nzchar(NA)` is TRUE — non-empty
  checks silently pass NA", "testthat counts an uncaught error under `error`, not `failed`", "Inside a dplyr verb, a
  column named like a local variable wins".
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool or shape this diff uses (the diff carries no
  shell or spatial code); index lines only.

## What was checked

**Round 1's fixes first.**
- 0280's `ACCESS` read (scripts/0280-literature-verify.R:87-90). Installed link 0.78.1 has the file; it gives 13
  species (BT CH CM CO CT DV PK RB SK ST WCT GR KO). Probed in R: with link absent, `system.file(mustWork = TRUE)`
  stops with "no file found". With the column renamed to `species`, the read gives NULL, length 0, and the script stops
  ("lists no species"). A blank field reads as `""` and gives 0 rows, which fails the gate. A literal `NA` gives
  `rows = NA`, so the script errors at `if (any(access$rows == 0))`: still a non-zero exit. No input that is not a species
  code gets past as a pass. Duplicates only print twice. The one weak spot is the `$` read, below.
- The roxygen and Rd for `knw_literature_read()` and 0280's OUTPUT line now name `swim_speed` and the access cell, and
  `man/` matches the roxygen.
- The access grid on the real table: every one of the 13 link species has at least one `access_gradient_max` row
  (GR, KO and WCT through a `none` row). FISH and SALMONIDS rows fill no species' cell, because the match is exact.

**Rest of the diff.**
- The capability guard in `.literature_check()`: tested by mutation in a detached worktree. Deleting the `ability`
  block turns "a leap or swimming-speed row is a fish's capability…" red, with 3 failed expectations. The unmodified
  file passes 48 of 48, with 0 errors and 0 skips. No earlier check catches these rows first.
- Swim speeds and leaps cannot fill a THERMAL, FLOW or COVERAGE cell: THERMAL and FLOW match on `variable`, and the guard
  refuses a `parameter`. The new GR `velocity` row (life stage `migration`) falls in no FLOW velocity cell (only spawning
  and rearing have one).
- The new vocabulary in R/ip.R `.ip_check()` (it uses only `life_stage`, `life_history_form` and `quote_source`)
  is unaffected.
- `data-raw/zotero_copy_check.R` takes `snapshot()` out of 0280 by parsing the file, so the new top-level read never
  runs there.
- The CSVs, read with Python's `csv` module: additions 18 columns × 6 rows, members 3 × 19, verdicts 7 × 36. Every row
  is the header's width.
  - 0270: `addition_item()` reads every column the additions use (publicationTitle, volume, issue, pages, reportNumber,
    reportType, place, url). `override` is blank and there is no DOI, so `override_fields()` is never applied. The local
    `data/rag/pdf/passage_limits/*.pdf` paths follow the file's documented ignored-path pattern, and on another machine
    `has_pdf()` answers before `addition_pdf()`. The WDFW 2009 member's URL matters only if the item loses its PDF.
  - 0275: both `merge-items` rows are in `ACTIONS`, with empty `fields` and `file`.
  - The verify log shows data rows 1154-1189 verified, or `none_row`.
- `planning/backlog.md` through soul's `backlog_moves.sh`: `list`, `next`, `free` and `lanes` all parse it (rc 0). A
  simulated `tick 178 <pr>` on a copy flips move 9 and ticks batch 14 only. Batch 15's first box is already ticked, so
  `next` reports no unmoved section.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:87-88: the read takes the column of link's
  `parameters_fresh.csv` with `$species_code`. That file is another package's, and its columns can change.
  `$.data.frame` partial-matches: where `species_code` is absent and one column starts with it (`species_code_fresh`,
  say), that column answers, silently and with no warning by default, so the access grid could ask about values that
  are not the species list. Where no such column exists, the read gives NULL and the stop fires, but its message
  ("lists no species") names the wrong cause. Taking the column with `[["species_code"]]`, after checking it is in
  `names()`, makes both cases stop with the true reason. Neither case can happen with link 0.78.1's columns today. This
  is the one way the round-1 read can fail other than correctly.
  - **Rule:** code-check-r.md "`$` on a list partial-matches, so a longer sibling key answers for a missing one"

/Users/airvine/Projects/repo/knowledge/planning/active/review-round2.md

## Fix and enumeration (session, 2026-11-18)

Fixed: 0280 checks `"species_code" %in% names(link_params)` and reads `link_params[["species_code"]]`, refusing an
empty, NA or blank species. Proven on made-up tables: a frame with only `species_code_fresh` is refused (the old `$`
read returned its values), as are a blank and an NA species; the real table passes (access 13 of 13).

Enumeration, the mechanism being a column read by name with `$`: every `$` in the branch's added R lines.
- `x$variable`, `x$parameter`, `x$model_id` (R/literature.R guard) and `ev$species_code`, `ev$parameter` (0280): the
  evidence frame after `chk::check_names(x, cols)` and `x[cols]` in `knw_literature_read()`, so every name exists exactly.
- `ACCESS$species`, `ACCESS$parameter`, `access$species_code`, `access$rows` (0280): a list and a frame built in place
  with exactly those keys.
- `x$…[1] <-`, `y$…[1] <-`, `out$variable`, `out$metric`, `knw_literature_vocab()$variable` (tests): assignments to
  `literature_fixture()`'s existing columns, the reader's output, and a list holding the key `variable` exactly.
- link's `parameters_fresh.csv`: the one read of a schema this branch does not own; fixed above.
Nothing sits above its source of truth.
