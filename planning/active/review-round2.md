# Code-check round 2: branch `120-chinook-rearing-every-setup` against main

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md: by heading. I read 2 sections in full: "A value compared as `::text` in SQL has PostgreSQL's
  spelling, not R's" (for `max(built_at)::text` in the parent note) and the round-1 set re-checked through the index
  ("A database driver's value is not a base R type — and it fails twice", "`match()` treats NA as a matchable VALUE,
  so two unknowns join to each other", "Postgres row order is never fixed unless the query fixes it, so a pick, a float
  sum and a presence check can each depend on it", "A `function(...)` mock hides arguments the real callee no longer
  accepts"). About 100 were not read.
- code-check-shell.md: no heading read (the diff has no shell).
- code-check-spatial.md: no heading read. The `sf::st_read`/`st_write`/tmap calls in `data-raw/setup_compare.R`
  match no indexed trap.
- code-check.md: I read the prose of all 14 H3s under `## Mechanisms`, skipping table rows and evidence blocks. Of the
  standalone rules I read only the index line of "Documentation Staleness".

## Findings

- **[severity: fragile]** R/tune_promote.R:100-107 (`run_grads` from `fld(x, "curve_grad")` over every summary). The
  same blind spot is in scripts/0320-tune-run.R:162-184, the resume guards. Round 1's fix identifies a setup run only
  by a summary that records `curve_grad`. 0320 writes `curve_grad = r$curve$cols[["grad"]]`, so a key with no curve
  records none: no_response, no_stream_rule, not_modelled, and also curve_failed. A setup run in which no summary
  records a gradient is therefore promotable:
  - every key in it has no fit, for example `SETUP=1 GRADIENT=parent_gradient SPECIES=KO` on a build where KO is
    paused; or
  - a by-key promotion of a no-fit key from a setup whose one fitted key's curve failed.
  - **Reproduced** with `knw_tune_promote(dry_run = TRUE)`, run from a temp copy of `R/`, on a candidate holding only
    `KO_rear_summary.csv` (`not_modelled`) and the log `...-ko-setup_parent.txt`. It passed and listed both files to
    write: the summary goes into `data/tune/`, and the setup's log is copied into `scripts/logs/habitat/`.
  - A promoted not_modelled or no-fit key retires the published key's files ("a tracked file of a promoted key that
    the run did not write is removed").
  - Because the resume guards share the blind spot, a main pass can also resume into such a run, and a setup pass
    into a main run of only no-fit keys.
  - CLAUDE.md ("`knw_tune_promote()` refuses any `curve_grad` but `segment_gradient`") and scripts/README.md 0335 ("a
    setup ... is refused") describe a whole-run refusal that holds only when some key fitted.
  - **Fix:** record the run's gradient on every summary, independent of the curve. For example, write
    `curve_grad = gradient` (the `cols_run` value) on no-fit rows too, or add a `setup` column. Alternatively,
    refuse a run whose logs match `-setup_`.
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: fragile]** scripts/0320-tune-run.R:96 (header) against :198 (log name). The header says a setup is
  written "with a -setup_<parent|fwa> log". The code writes `paste0("-setup_", sub("_gradient$", "", gradient))`,
  which gives `-setup_segment_fwa` for the Atlas setup. The real file is
  `data/tune/candidate/20261105_0437/20261105_tune_run-20261105_0437-p20261105050254-ch-setup_segment_fwa.txt`.
  Nothing parses the name today. A reader that matches on the documented `-setup_fwa` would miss the Atlas setup's
  logs, for example a promotion guard keyed on the log name as proposed above.
  - **Rule:** none

## Checked and found sound (round 1 fixes and the rest)

- **0320's setup-resume guard** now drops NA (`setdiff(run_grads, c(gradient, NA))`). The main-into-setup guard
  (`gradient == "segment_gradient"`) and the sensitivity-into-setup guard are correct for runs whose keys record a
  gradient.
- **`.knw_parent_held()`.** The note is built by `.knw_parent_note()` on both sides, so the strings match. 0310
  writes it through `add()` and `write_csv`, and 0320 and 0330 read it back through `read_csv`, all as character, with
  no edge whitespace. `built_at::text` is spelled the same on both sides, because RPostgres sets the session TimeZone
  to UTC (this database reports UTC). It is called in 0320 only for `parent_gradient` setups (a sensitivity quits
  before), and in 0330 on the candidate's own ledger (`knw_run_ledger(tune_dir)`).
- **Coverage query.** It now uses `NOT coalesce(abs(...) <= 0.01, FALSE)`, so a NULL length counts as off.
- **The parent table's key types.** `streams_parent.id_segment` and `id_segment_minimal` are integer, and the maximum
  id_segment is 80,538 (measured read-only on the published build). So `as.integer(as.numeric(keys$id_segment))`
  cannot overflow, and setup_compare.R's paste keys never reach the `1e+05` spelling.
- **The vocabulary.** link's vocabulary says of `grad-parent` that "No link build writes it". So the archive refusing
  `grad-parent` on a `segment_gradient` record cannot hit a native build.
- **The bin's scratch copy.** `UPDATE ... FROM <schema>.streams s LEFT JOIN ...` updates it before the indexes and
  before `frs_near_river`, so every rule, the other stage and the connectivity pass read the copy's gradient.
- **The main segment read.** `%7$s`/`%8$s` take the same `grad_sql`, and the aliases `kp`/`kf` do not collide with the
  query's other aliases.
- **0330's `run_grad`.** The single-gradient check, the default for runs with nothing fitted,
  `.knw_grade_grad_ok(h, run_grad)` and the `gradient =` passed to `knw_compare_rules()` are consistent.
- **0310's `segment_fwa_gradient` literal.** It uses `format(scientific = FALSE, trim = TRUE)` on integer-valued ids,
  matched as numeric.
- **setup_compare.R.** `knw_tune_pick_report()` takes the character-typed tune tables, and `evidence_md5`'s `[2:3]`
  is visits_species and walks.
- **The tests' mocks.** `knw_link_segments(..., gradient)` and `knw_parent_read(...)` match the real formals.
