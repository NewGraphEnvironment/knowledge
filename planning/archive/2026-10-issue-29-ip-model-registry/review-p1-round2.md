# Code-check round 2 — phase 1 staged diff (#29)

Reviewer: subagent, 2026-10-01. Worked on a `git checkout-index` copy of the staged tree in
the session scratchpad; the repo working tree was not modified (apart from this file).

## Verified (no finding)

- `devtools::test()` on the staged tree: all pass (ip 56, literature 49 expectations).
- `R CMD check --no-manual` on the staged tree: 0 errors, 0 warnings, 1 NOTE (future file
  timestamps: cannot verify time, environmental). `devtools::document()` leaves `man/`
  unchanged, so the Rd files are current.
- Round-1 fix 1 (header-only registry): ran the real gate on a copy with
  `REGISTRY=<header-only copy>`. No crash; `registry: 0 rows, 0 quotes`, the six tagged
  evidence keys are reported `unregistered`, exit 1. Correct.
- Round-1 fix 3 (SCALE): every unit in `knw_literature_vocab()$unit` that starts with "m"
  (`m bankfull`, `m wetted`, `m`, `m3/s`, `mm`, `m/s`, `mi2`) now has an explicit SCALE
  entry, so the `^m` fallback reaches no vocabulary unit. `SCALE[[unit]]` is an exact
  lookup (`[[` on a list does not partial-match), so `m` cannot answer for `m3/s`. The
  new units `km2`, `cfs`, `ft` and `ratio` fall through to a scale of 1.
- Registry quotes routed through `check_row()`: `value_in_quote()` returns TRUE before it
  reads `variable` or `unit`, because both values are NA. Validation quotes fall back to
  `citation_key` when `validation_citation_key` is blank. The committed registry log has
  all 9 quotes `verified_text`.
- Zero-length `paste()` in `link_key()` on an empty registry returns `character(0)`
  (measured), so it does not produce a phantom link.

## Findings

- **[severity: fragile]** pkg/R/ip.R:101 (with ip.R:139). Round-1 fix 2 normalizes
  `flow_inputs` inside `.ip_check()` (`x$flow_inputs[lengths(inputs) == 0] <- NA`), but
  `knw_ip_read()` calls `.ip_check(x)` and discards what it returns. The normalization
  applies only to the check's local copy, and the returned table keeps the raw cell. So:
  - On a `flow_metric = none` row, a `flow_inputs` cell of `;` (or ` ; `) is NA for the
    "flow_metric none has no flow_inputs" check, so the row passes. The tibble then returns
    `flow_inputs = ";"`, which breaks the invariant the reader documents ("a `none` flow
    has no source, inputs or surrogate"). Any consumer testing `!is.na(flow_inputs)`
    sees an input. Measured on a copy: `flow_metric none`, `flow_source NA`,
    `flow_inputs ";"` came back from `knw_ip_read()` with no error.
  - On a gauged or field row, `;` is returned as a non-NA inputs claim. A valid cell with
    padding (`"precipitation ; drainage_area"`, which the new test accepts) is returned
    unnormalized, so a consumer's `strsplit(";")` gets `"precipitation "`.

  This is the round-1 defect one axis over: the check now sees the right value and the
  caller does not. Fix: `x <- .ip_check(x)` in `knw_ip_read()` (`.ip_check` already
  returns `invisible(x)`). Optionally also write back the trimmed tokens,
  `paste(v, collapse = ";")`. Add a test that reads a `none` row with `flow_inputs = ";"`
  and expects NA back.

## Note (pre-existing, outside this diff's intent, fails toward fail)

- scripts/0280-literature-verify.R:204. The per-run `work_` directory fixes concurrent
  deletes, but `ocrmypdf --sidecar` still writes straight to the shared cache path
  `side`. A second run can see `file.exists(side)` while the first is still writing.
  A killed run can also leave a truncated sidecar that is cached permanently. Both give
  `quote_not_found` rather than a false pass, so this is not blocking. Writing the sidecar
  into `work` and `file.rename()`-ing it into place would close it.
