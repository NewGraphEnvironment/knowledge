# Code-check round 3 (#141): knw_tune_anchor, 0320's anchoring, tune_anchor_check.R, baseline_anchoring.md

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: every H3 under `## Mechanisms`, prose only (A guard that fails toward pass; A fixture that cannot
  reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape
  hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard
  fires; the rest from the index). Rules that stand alone, Security, Spreadsheets: index only (none applies).
- code-check-r.md: read `nzchar(NA)` is TRUE; `paste()` with a zero-length argument; Under `R CMD check`, tests run
  from a temp dir; CSV whitespace; `match()` treats NA as a matchable VALUE; `identical()` on two reader results;
  `A pkg:: call in a test`. About 85 headings not read (index only).
- code-check-shell.md, code-check-spatial.md: index only; no heading names a tool or shape this diff uses (the one
  `system2("git", ...)` call checks its output length, not a status).

## Findings

- **[severity: fragile]** scripts/0320-tune-run.R:41-42 — the ANCHORING header says "where the best carries an
  exception under d_floor, which no pick may, each pick is also read against the best rule a pick may be". The code
  (`knw_tune_anchor()`) reads every pick against the best allowed on every key, and that rule differs from the best
  also when the best did not converge (the predicate is `in_region` & the floor, as `.tune_pick()`'s). This is the
  round-2 mechanism one place over: the sentence names one property (the floor) where the predicate is two (floor and
  convergence, carried by the region). The roxygen, the data-raw header (lines 9-11), its log line (line 71) and the
  research file all carry the convergence clause; this header is the one description that does not. No number is
  wrong (all fifteen tables read have every rule converged), so it is a description to bring into line, e.g. "where
  the best is not a rule a pick may be (an exception under d_floor, or not converged)".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

Nothing else. The round-1 refusal (`recommended` not in `allowed`) cannot fire on a legitimate table:

- `.tune_pick()`'s recommended is either the pick `p` (taken when `exc_d[p]` is NA or >= d_floor, and `p` is in
  `rr = region & conv`) or `ok_d[1]` (in `rr`, clear of the floor); `res$in_region` is `s0$region[col] &
  sw$conv[col]`, the same `rr`, so the recommended rule is always in `allowed` at the scored d_floor. Measured on all
  fifteen saved tables (8 published, 7 minimal candidate): `rec %in% allowed` TRUE on each, and an independent
  `converged & ddev_best <= se_diff` equals the stored `in_region` on every row (0 mismatches).
- Read as text: `is_true()` takes "TRUE"; `exc_d` "" reads NA under readr's default `na`; the text round-trip test
  passes.
- A d_floor move: the moved-to rule is `ok_d[1]`, clear of the floor by construction. The refusal fires only when the
  caller passes a *higher* d_floor than the table was scored at and the recommended rule carries an exception between
  them, which is a correct, loud refusal (0320 passes the run's own `spec$d_floor`; the data-raw script uses 200, the
  value every tracked table was scored at).
- A table from before `in_region`: `in_region` (with convergence) has been in `knw_tune_score()` since the port
  (a0c433d, #57), so no saved table lacks it; one that did is refused by `check_names`, loudly.
- A key whose recommended is NA (every region rule under the floor): already refused by `knw_tune_pick_report()` at the
  same point (pre-existing), and its curve fails before the summary's anchor runs.

Also checked: the 0320 guard's names and `rule_best` cannot drift from the summary (same rows, same predicate; the
flow name is NA on both sides when there is no flow start, since the scorer's `recommended_flow` is NA exactly when
`departures_flow` is all NA); no column of the anchor collides with the summary row or the pick report (no `...1`
renames from `bind_cols`/`tibble`); no consumer of `pick_report.csv` exists; the tests (13) and the roxygen example
run green on a temp copy; logs were made at 7bb9111 and no file under R/, data-raw/, inst/ or DESCRIPTION changed
since; table md5s in the logs equal the files on disk.

## Enumeration

Source of truth for the pick: `.tune_pick()` (R/tune_score.R:456): `rr = region & conv`, ordered by departures then
score; recommended = pick, or the first `rr` rule clear of d_floor when the pick is under it. For the region:
`.tune_sel()` (`tot - tot[best] <= se`, best = `which.min(tot)` over every pattern, converged or not). For parts:
`knw_tune_grid()`'s departures (presence-only exception, extended to river size/distance between two exception
rules, accepted).

| item | source of truth | code matches | descriptions match |
|---|---|---|---|
| best (`rule_best`, `best_n`) | `ddev_best == 0` (`.tune_sel` best and every rule of its fit); first in grid order as 0320's summary | y (`ddev %in% 0`; 0320 guard uses `ddev_best == 0`) | y: roxygen l.12-15, 0320 header l.40-41, research "Rules with the same in or out..." (2 to 4 rules on six of fifteen tables: measured y) |
| best allowed (`rule_best_allowed`, `best_allowed_ddev`) | lowest-scoring rule `.tune_pick` could recommend: `in_region` (region & conv) & (exc_d NA or >= d_floor) | y (l.88-90) | y: roxygen l.23-28, data-raw l.9-11, research ("in the region, and with no exception or one at 200 m or more"); 0320 header l.41-42: **n** (floor only; finding above) |
| `best_is_allowed` | some tied best is in the allowed set (equivalently best allowed ddev == 0) | y (`ddev[allowed[1]] == 0`; the best is always in the region when converged, since its own se is 0) | y: roxygen l.26-28, data-raw l.71 log text, research parenthetical; Rd regenerated (no `best_floor_ok` left anywhere outside planning/) |
| pick from default (`rule_recommended`, `recommended_ddev`, `recommended_se`) | `recommended` column (the d_floor-moved pick, not `pick`) | y (test l.144 pins it) | y: roxygen l.10-11, 0320 l.38, research "the published pick" |
| pick from the flow start (`rule_recommended_flow`, ...) | `recommended_flow`, present when `departures_flow` has values (`knw_tune_score`'s `flow_start`) | y (same test as the scorer and `knw_tune_repick`) | y: roxygen l.10-12/33-35, research "its flow version, the same rule with its width floor written as the MAD it stands for" (grid: MAD floor m_def, same gradient, no exception: y) |
| `rec_moved`, `flow_moved` (+ parts) | fewest parts to any tied best, first such in grid order names them | y (`to_set`) | y: roxygen l.14-16/44-47, 0320 header, research |
| `rec_moved_allowed`, `flow_moved_allowed` (+ parts) | same, against the tied best-allowed set | y | y (roxygen, research, data-raw block title) |
| `starts_apart` (+ parts) | `.knw_rule_parts(rec, flow)` | y | y |
| `rec_is_best`, `flow_is_best` | pick's `ddev_best == 0` | y | y ("the pick is tied at the best") |
| `starts_agree` | the two picks are the same row | y | y (research "pick the same rule": published 6 of 8, minimal 4 of 7, measured y) |
| parts | knw_tune_grid departures + distance extension | y (test l.160 reproduces departures and departures_flow on a grid) | y (roxygen l.16-19, comment l.133-134) |
| d_floor | knw_tune_score / knw_tune_run default 200; 0320 passes the run's `spec$d_floor`, falling back to knw_tune_run's formal for a pre-spec cache | y | y (roxygen l.36-38, 0320 comment l.327-329, data-raw l.11-12, research "200 m") |
| steering order | data-raw l.54: desc(rec_moved_allowed), desc(ddev/se), disagreeing starts first | y | y (data-raw l.9-11, research "Where the baseline review starts"; both lists' order and figures recomputed from the logs: GR 2/0.55, ST 1/0.40, CO 1/0.26; BT 2/0.89, GR 2/0.85, ST 1/0.62, CO 1/0.38) |
| 0320 log block "anchoring (#141)" | pick-report rows | y (columns exist; `rule_best` from the anchor) | y |
| research numbers | the two logs and the tables | — | y: every table row and sentence checked against the logs; independently on the tables: 0 unconverged rules on all 15; ST published best-allowed `mad>=1|g<=0.07|Q1@D250` 3.45 behind with exactly two rules (one fit) clear of the floor scoring better and outside the region; GR default 19.26/6.72 published, 14.35/11.79 minimal, outside the region; CH flow default `mad>=0.28|g<=0.0549|none`; GR tied bests share width 1 m (published) and 2 m (minimal); BT minimal 65.3 the largest deviance behind |
| "behind the best ... always under one [SE], by construction" | `ddev_best <= se_diff` | — | y within the stated precision (the bound is inclusive; no pick sits at it) |
| grayling_rearing_tuned.md, minimal_network_tuning.md, research/README.md, data-raw/README.md pointers | the logs / function | — | y |
