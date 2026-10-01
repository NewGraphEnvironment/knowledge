# Review: Phase 1 staged diff, round 1

Reviewer: code-check subagent, 2026-10-01. Scope: the staged diff (`pkg/R/ip.R`, `pkg/R/literature.R`,
`pkg/R/read.R`, both test files, `scripts/0280-literature-verify.R`, `data/ip_model_registry.csv`,
`data/literature_evidence.csv` `model_id` column, NEWS, DESCRIPTION).

## Verdict

Nothing blocking. The reader logic, the registry quote shim and the two-way link check are correct as
written, and I found no path that fails toward pass in the new code. There are three fragile spots. Two of
them are new in this diff. The third is older, but it sits on the `SCALE` line this diff edited.

## Checked and fine

- `data/literature_evidence.csv`: all 191 lines have 19 fields, and the first 18 columns match HEAD byte for
  byte (compared with Python `csv`). 20 rows are tagged: 11 `rebellato2024` and 9 `cooney_holzer2006`. Each
  tagged model x species x stage has a registry row, and the reverse holds too.
- `data/ip_model_registry.csv`: all 7 lines have 23 fields.
- `quote_row()` shim through `check_row()`: `kind = "registry"` skips the `none` branch. `value_in_quote()`
  returns TRUE because there are no values. `with(reg_checks[i, ], ...)` resolves `quote` to the column,
  not to `base::quote`.
- `link_key()` on a zero-row tibble returns `character(0)`, because every argument to `paste()` is
  zero-length. That means no phantom link.
- `SCALE[[r$unit]]` uses exact matching (`[[`), so `km2` does not pick up `km`, and `mi2` is correctly kept
  away from the `^m` rule. `cfs`, `ft`, `km2` and `ratio` all resolve to scale 1.
- In `.ip_check()`, `nchar(NA_character_)` is NA, and the `%in% "text"` guard keeps it out of the
  short-quote test.
- `reg_log` derivation: `sub("(\\.csv)?$", ...)` gives `x_ip_registry.csv` for `x.csv`. A `LOG=` override
  keeps both logs away from the committed ones.
- No other consumer of `knw_literature_read()` or of the verify log in the repo breaks on the new required
  column or on the reordered log columns.

## Findings

- **[fragile] scripts/0280-literature-verify.R:402-409**: the gate errors on a registry with no data rows.
  `data.frame(data_row = seq_len(0), quote_of = "flow", ...)` raises *"arguments imply differing number of
  rows: 0, 1"* (reproduced). That is the scalar-recycled-against-zero-length trap. It fails closed (exit
  non-zero), but the message names nothing useful, and neither log is written.
  `knw_ip_read()` accepts a header-only registry, so this is reachable if the registry is ever emptied, or
  if `REGISTRY=` points at a fresh draft. The fix is to guard `nrow(reg) == 0`, or to build `quote_of` with
  `rep(..., nrow(reg))`.

- **[fragile] pkg/R/ip.R:131-133, 165**: a `flow_inputs` cell holding only separators (`";"` or `" ; "`)
  passes as present on a `modelled` row. `blank_to_na` keeps it because it is non-empty. The split drops
  every empty token, so the vocabulary check sees nothing, and the `modelled` check tests only `is.na`.
  Reproduced: setting `flow_inputs[1] <- ";"` on the real registry reads 6 rows with no error. The
  "modelled flow names its inputs" rule can be met with no inputs at all. The fix is to test for
  `lengths(lapply(inputs, function(v) v[nzchar(v)])) == 0` instead of `is.na(x$flow_inputs)`.

- **[fragile, pre-existing, on the line this diff edits] scripts/0280-literature-verify.R:298-299, 332**:
  `m3/s` has no `SCALE` entry, so it falls to the `^m` metre rule and gets `c(1, 1e3)`. A discharge value
  1000x the quoted number therefore passes `value_in_quote()`. `m bankfull` and `m wetted` get the same
  treatment for channel width. The diff added `mi2 = 1` to this list for exactly this reason and left
  `m3/s` behind. Three of the newly tagged `rebellato2024` rows are discharge rows (`spawn_mad_min`,
  `rear_mad_min`, `rear_mad_max`) that pass through this rule. The ×1000 is meant for bridge distance
  (km→m) only, so give `"m3/s" = 1` an explicit entry here. The width units are the same latent issue.
