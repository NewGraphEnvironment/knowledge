# Code-check round 1: branch `120-chinook-rearing-every-setup` against main

## Checklist read

- code-check-python.md: in full (nothing in this diff is Python).
- code-check-r.md: by heading. Read 7: "A database driver's value is not a base R type — and it fails twice",
  "`match()` treats NA as a matchable VALUE, so two unknowns join to each other", "Inside a dplyr verb, a column named
  like a local variable wins", "A `function(...)` mock hides arguments the real callee no longer accepts", "`[[` on a
  named ATOMIC vector with an absent key is an error, not `NULL`", "`system2(stdout = TRUE)` warns on a non-zero exit
  instead of raising, so a `tryCatch(error =)` around it never fires", "Postgres row order is never fixed unless the
  query fixes it, so a pick, a float sum and a presence check can each depend on it". The rest were not read (about 95).
- code-check-shell.md: no heading read. The diff has no shell.
- code-check-spatial.md: no heading read. The `sf::st_read`, `st_write` and tmap calls in `data-raw/setup_compare.R`
  match no indexed trap.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with table rows and evidence blocks skipped. No
  standalone rule read.

## Findings

- **[severity: bug]** scripts/0320-tune-run.R:162-169 (`run_grads` and the `if (setup && length(setdiff(run_grads, gradient)))` stop): a setup run cannot be resumed. A key with no fit (`no_response`, `no_stream_rule`) writes its summary with `curve_grad` NA, so `run_grads` holds NA. `setdiff(c("parent_gradient", NA), "parent_gradient")` is `NA`, length 1, so `SETUP=1 GRADIENT=parent_gradient RUN=<the setup's own run>` stops with "holds summaries scored on NA: a setup on parent_gradient needs a run of its own".
  - **Reproduced** on the real candidate `data/tune/candidate/20261105_0436`. Its `CH_spawn_summary.csv` (`no_response`) has `curve_grad` NA, and the guard's code run over that directory gives `run_grads = c("parent_gradient", NA)` and `setdiff = NA`. `20261105_0437` is the same.
  - **Why it matters:** this blocks every second pass of a setup, which is the remedy 0330's stale-grade error and 0320's own keep-check rely on ("rerun 0320", "a later pass under the same name is numbered"). Examples are a regrade after a killed pass, or a `SPECIES=` pass.
  - **Fix:** the sensitivity guard two lines below already drops NA (`setdiff(run_grads, c("segment_gradient", NA))`). The setup guard needs the same: `setdiff(run_grads, c(gradient, NA))`.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: fragile]** scripts/0320-tune-run.R:160-169: the comment says "a setup and a main run never share a directory". The guards cover two of three cases: a setup over a main run, and a sensitivity over a setup run. A plain main pass (no `SETUP`, `GRADIENT=segment_gradient`) with `RUN=<a setup run>` passes both guards. It writes segment-gradient summaries, grades and `grad-seg` records into the setup's directory beside the setup's keys. 0330 then refuses the mixed run. But `knw_tune_promote(keys = <the main keys>)` checks per key, so the keys the main pass wrote can be promoted out of a directory named as a setup.
  - **Fix:** refuse a non-setup, non-DEV pass whose `run_grads` hold any setup gradient (`intersect(run_grads, names(.knw_grade_grad_tokens))`).
  - **Rule:** code-check.md "A guard that fails toward pass"

- **[severity: fragile]** R/tune_promote.R:104-107: the setup refusal is `!is.na(cg) && !identical(cg, .knw_grade_grad)`, so it passes any key whose summary has no `curve_grad`. Every no-fit key of a setup run is like that (for example `CH_spawn` in `20261105_0436`). That key then reaches `if (st %in% .knw_no_fit && is.na(rule)) next`.
  - **What it lets through:** `knw_tune_promote("20261105_0436", keys = "CH_spawn")` gets past the setup check. The one-build field check then reads only NA from that summary for the fields it compares (`evidence_md5`, `run_uid` and `curve_grad` sit in the fitted branch of 0320's row), so nothing there refuses it either. The promotion moves a setup run's summary, and copies its `-setup_parent` log, into the tracked tables.
  - **What the docs claim:** scripts/README.md ("a setup ... is refused, #120") and CLAUDE.md ("`knw_tune_promote()` refuses any `curve_grad` but `segment_gradient`") describe a whole-run refusal that does not hold for these keys.
  - **Fix:** identify the run as a setup from any summary in it, or from its records' `token_grad`, rather than from the promoted key's own summary.
  - **Rule:** code-check.md "A guard that fails toward pass"

- **[severity: fragile]** R/link_segments.R `.knw_seg_grad_check` → R/parent_read.R `knw_parent_read()`, as called at grade time (R/grade_species.R:96) and at compare time (R/compare_rules.R:215-216): nothing checks that the parent gradients read at grading are the ones the curve was fitted on.
  - **What is checked:** `knw_parent_read()` holds `streams_parent` to the builds now in the database (the minimal schema's current run, the full schema's log).
  - **What is not:** that the table is the one 0310 joined the visits from. 0310 writes the table's provenance (`parent_table` row: `built_at`, `run_uid_minimal`, `link_sha_minimal`) into the evidence ledger, and no later step compares it.
  - **The failure:** link re-models the minimal network and rebuilds `streams_parent` while the full schema is unchanged. 0320 SETUP=1 then grades, and 0330 compares, on new parent gradients while the curve was fitted on the old ones. `evidence_md5`, `run_uid`, `knw_build_record()` and the curve-grad checks all still pass, because none of them sees the parent table.
  - **Fix:** carry `run_uid_minimal` (and `built_at`) into the grade record or summary, and compare it with `attr(knw_parent_read(...), "provenance")` at grade and compare time. CLAUDE.md, "A run's record travels with its table, and its readers compare it", asks for exactly this.
  - **Rule:** code-check.md "A proxy is not the property" (the full schema's run stands in for the parent table's build)

- **[severity: fragile]** R/parent_read.R, the coverage query (`count(*) FILTER (WHERE p.n = 1 AND NOT abs(p.len - s.length_metre) <= 0.01)`): the check fails toward pass on NULL. A parent row with NULL `overlap_m` or `straddle_m`, or a segment with NULL `length_metre`, makes the predicate NULL, so the row is not counted as `off`. The function still reports "each row's overlap_m + straddle_m is its segment's length within 1 cm".
  - **Why it matters:** knw_parent_join() treats a missing length as a mismatch ("a missing length fails"), but it runs only on visit rows. The grade path (`.knw_seg_grad_check`) relies on knw_parent_read() alone, so a stale or partial table with NULL lengths passes there.
  - **Fix:** write it as `NOT coalesce(abs(...) <= 0.01, FALSE)`.
  - **Rule:** code-check.md "A guard that fails toward pass"

## Checked and found sound

- The UPDATE…FROM…LEFT JOIN on the scratch copy in `.knw_compare_bin`.
- The `%7$s`/`%8$s` positional arguments in knw_compare_rules' segment read.
- The default `grad_sql` on the bin.
- Whether `knw_link_segments(gradient =)` can reach `.knw_grade_grads`.
- The archive token checks in both directions.
- 0330's `run_grad` and its `.knw_grade_grad_ok(h, run_grad)`.
- The evidence-md5 order that setup_compare.R's `[2:3]` assumes (visits_link;visits_species;walks).
- `format(..., scientific = FALSE)` on the linear_feature_id literal.
- setup_compare.R's paste keys: both sides are numeric, with ids under 100,000 today, so no `1e+05` spelling arises.
- The tests' mocks against the real formals.
