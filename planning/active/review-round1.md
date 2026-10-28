# Code-check review, round 1 (#112, branch vs main at e064b61)

## Checklist read

- code-check-python.md: in full (7,237 bytes; no Python in the diff).
- code-check-r.md (179,420 bytes): read the sections "`system2(stdout = TRUE)` warns on a non-zero exit",
  "`tryCatch()` nests its handlers", "`tryCatch(warning = )` DISCARDS the value", "Postgres row order is never
  fixed unless the query fixes it", "`c(name = x)` keeps `x`'s own name", "A `data-raw/` script must load the
  source tree", "`[[` on a named ATOMIC vector with an absent key is an error", "testthat counts an uncaught error
  under `error`". 8 read; the remaining ~95 headings not read in full (index lines only).
- code-check-shell.md (125,440 bytes): index only; no shell in the diff beyond `system2("git", ...)`, covered by the
  R section above. 0 headings read in full.
- code-check-spatial.md (155,517 bytes): index only; nothing spatial in the diff. 0 headings read in full.
- code-check.md (330,698 bytes): the prose of all 14 H3s under `## Mechanisms` (table rows skipped). No other
  section read in full.

## What was checked

- `.knw_compare_structures()`: "reported" resolves to `tuned_as` before `chk_subset()`, then the new refusal holds it
  to the species x rule's own set. Probed in a scratch copy: `door_wetland` on a no-exception rule is refused with
  "not a structure", an unknown name still fails `chk_subset()`, `NULL` still returns the full set. No other caller
  passes `structures` (`0322` passes none; `compare_parallel_check.R` none).
- `.knw_compare_bin()` timing: `setup_s`, `rule_s[[k]]` and `walk_s` are assigned inside the `tryCatch()` expression,
  which evaluates in the function's frame (the same pattern `walk_s` and `flags` already used), so the totals reach
  the return. `rule_s` is named by `rule_names`, so `Reduce(`+`)` keeps the names and `worker_minutes` is
  `setup`, `walk`, then one entry per rule, as the check script indexes it.
- Equality gate in `data-raw/compare_structures_check.R`: the bootstrap's `set.seed()` precedes draws that do not
  depend on the number of rules, so `default` and `door` lifts and intervals are identical between the two runs; the
  sort keys are unique per table (compare: group x structure; change: structure x direction x reason x order;
  checks: check x rule x segment; segments: id x group); `compare$structure` is never NA, so the `==` filter adds no
  NA rows; the dropped segment columns match the regex (`rearing_free`, `rearing_pre_free`, ...) and the remaining
  column order equals a reported-only run's (`default`, `door`, `tuned`). Float sums from unordered fetches sit
  inside the 1e-9 relative tolerance.
- `0330`: `STRUCTURES` validated before use; `run_one` reads the global string (no local `structures`); per-key
  table columns do not depend on the structure set, so composition with saved keys is not refused; the CH
  through-wetland log line and `vignette_chinook.R` take whichever structure columns the segments carry.
- Readers of the tables: `knw_thresholds_table()`, `tune_promote.R`, `vignette_method.R`, `vignette_chinook.R`,
  `test-vignette-data.R` and the chinook article read only the tuned structure (or its rows) or count rows with
  `>= 1`; none requires `free` or `door_wetland`. The article's remaining inline code no longer names `wl_free`.
- `test-settings-register` patterns for `tuned_as` (script and function default) are unchanged by the diff.
- Nothing private in the new text.

## Clean

No issues found.
