# Task: Anchoring check: report the pick from each starting point beside the best-scoring rule (#141)

The pick is the region rule with the fewest departures from link's `default` (`R/tune_score.R`, `.tune_pick()`), so the starting point can decide which of several near-equal rules is published (#139, #120). #80 added a second starting point, link's flow version (`pick_flow`, `recommended_flow`), but nothing reports the two picks beside the rule the data score best, or says when they differ.

## Context

The pick is the one-SE region's rule with the fewest departures from link's `default` (`R/tune_score.R:456`, `.tune_pick()`), so the starting point can choose between near-equal rules (#139, #120). #80 added a second start (link's flow version: `pick_flow`, `recommended_flow`, `departures_flow`), but nothing sets the two picks beside the best-scoring rule, says whether they differ, or counts how far apart they are. This is first in #139's order: measure the current baselines before #140 rebuilds grayling's.

What exists: every `<key>_tune.csv` already holds all three (`recommended`, `recommended_flow`, `ddev_best == 0`) with each rule's `size_var`, `size_min`, `grad_max`, `exc_q`, `exc_d`, `ddev_best`, `se_diff`. The summary (`scripts/0320-tune-run.R:350`) names `rule_recommended`, `rule_best`, `rule_recommended_flow` but no distances and no departures between them. So no retune: the check is a function over the tune table.

Measured today from the tables (rule, + ddev / SE behind the best):
- Published (full network, #92): GR rear best `width>=1|g<=0.0549|Q50@D500`; from `default` `width>=2|g<=0.0549|none` (+5.7 / 10.4); from flow `mad>=0.021|g<=0.0549|none` (+11.6 / 13.9). CH rear: `default` start = best; flow start `mad>=0.28|…` (+24.8 / 26.9).
- Candidate `20261103_0838` (minimal network, #120): GR rear best `width>=2|g<=0.0549|Q50@D500`; from `default` `width>=1.5|…|none` (+9.3 / 10.9); from flow `width>=2|…|none` (+3.9 / 5.3). BT rear's pick is +65.3 / 73.7 behind its best.
- Ties at the best: 4 published keys and 2 candidate keys have 2–4 rules at `ddev_best == 0`; they are one fit (same in/out on every visit).

## Decided at the gate (approved by Al, 2026-11-03)

1. **"The pick" is the `recommended` rule** from each start (what is published; `d_floor` applied), not the raw `pick` column.
2. **Ties at the best are one fit.** `rule_best` stays the first tied rule in grid order (as the summary already writes it), `best_n` counts the tie, and a pick's distance to the best is its fewest departures from *any* tied rule, so a pick tied at the best reads 0.
3. **Departures between two rules** count the three parts as the grid does: size test (variable or value), gradient, exception (`exc_q` or `exc_d`, NA-aware): 0–3, with the parts named (`size+exception`).
4. **The "before" lives in a committed check log and a research file**, not a new table under `data/tune/` (those change only by promotion): `scripts/logs/habitat/<date>_tune_anchor_check-<label>.csv`, and `research/baseline_anchoring.md`.
5. **Steering order** for the baseline review: departures from the `default` pick to the best, then distance in SEs (`ddev_best / se_diff`), then whether the two starts disagree.

## Phase 1: `knw_tune_anchor()`
- [x] `R/tune_anchor.R`: one row per tuning table (scored, or a saved csv read as text, as `knw_tune_pick_report()` accepts): `rule_recommended`, `recommended_ddev`, `recommended_se`; `rule_recommended_flow`, `recommended_flow_ddev`, `recommended_flow_se` (NA with no flow start); `rule_best`, `best_n`; `rec_moved` + `rec_moved_parts` (default pick → best), `flow_moved` + `flow_moved_parts` (flow pick → best), `starts_apart` + `starts_apart_parts` (default pick ↔ flow pick); `rec_is_best`, `flow_is_best`, `starts_agree`. Refuses a table without exactly one `recommended` (and more than one `recommended_flow`). Roxygen with a runnable example.
- [x] `tests/testthat/test-tune_anchor.R`: a fixture where best and pick differ (parts named, counts right); one where they agree; a pick tied at the best reads 0; no flow start gives NA flow columns; a text-read table gives the same row; refusal on 0 recommended.
- [x] `_pkgdown.yml` reference entry beside `knw_tune_pick_report`; `devtools::document()`, `pkgdown::check_pkgdown()`.

## Phase 2: every run reports it (`scripts/0320-tune-run.R`)
- [x] Summary: bind the anchor's distance, departure and flag columns; stop if its `rule_recommended`, `rule_best`, `rule_recommended_flow` differ from the summary's own (one fact derived twice gets a guard).
- [x] `pick_report.csv`: the run's anchor columns beside the published comparison (without restating `rule_run`), and the log's pick-report block shows `rec_moved`, `flow_moved`, `starts_apart`.
- [x] Header: an `ANCHORING (#141)` bullet in the spec and the new columns under OUTPUT.

## Phase 3: run it on the published tables and the current candidate
- [x] `data-raw/tune_anchor_check.R` (`TUNE_DIR`, `LABEL`): every `<key>_tune.csv` in the directory (not recursed) through `knw_tune_anchor()`, written to `scripts/logs/habitat/<date>_tune_anchor_check-<label>.csv` with a short `.txt` naming the tables' run (`run_uid`, `tune_run`, `evidence_md5` from each summary).
- [x] Run on `data/tune` (published, #92) and `data/tune/candidate/20261103_0838` (minimal network, #120); commit both logs.

## Phase 4: record it
- [x] `research/baseline_anchoring.md`: plain-language walk (what anchoring is, why the pick is near `default` by construction), both readings side by side, keys ordered by how much the start steers, grayling rearing's "before" for #140 stated explicitly; row in `research/README.md`.
- [x] #140's body: the grayling "before" line and a link to the research file; #139's body: tick or note #141's result in its members table.
- [x] `research/grayling_rearing_tuned.md` and `minimal_network_tuning.md`: one pointer each where they discuss the pick's anchoring (grep first).

## Validation
- [x] Tests pass (`devtools::test()`), lintr clean
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- The function: fixtures above, plus a mutation check (break the tie handling and the parts count; the tests go red).
- The two readings: the check's rows for GR, CH and BT rear match the hand-tabulated numbers above.
- 0320: a `DEV=1` run against copied dev caches (`DEV_DIR=data/tune/dev_anchor`, minimal evidence) if the database is reachable, checking the summary and `pick_report.csv` carry anchor columns equal to the check's; if it is not reachable, say so in the PR rather than claim it ran.

## Owed at the end (reported, done after merge)
- None beyond what #140 and #139 already hold.

