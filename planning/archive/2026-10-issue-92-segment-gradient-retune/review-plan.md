# Plan review (Plan agent, spawned 2026-10-27T21:57:27Z, delivered in reply; written here by the parent)

Verdict: direction sound. `knw_grade` (R/grade_species.R:154) and `knw_compare_rules` (R/compare_rules.R:172, :304)
already read link's segment `gradient`. In visits_link, `segment_gradient` and `fwa_gradient` have no NAs (55 negative
segment gradients, against 27 on the Atlas line; out under every rule, matching link's `BETWEEN 0 AND max`).
`data/tune/grad_fwa/` is not listed by 0325 (:68), 0330 (:96), `knw_thresholds_table` (R/thresholds_table.R:61),
vignette_method.R (:78) or vignette_chinook.R (:112), because none recurse. `.gitignore`'s `data/tune/**` patterns
cover its ignored outputs.

## Blockers
- **B1.** With `extra = FALSE`, 0320's non-dev code reads `seeds`, `honest` and `boot_rec_share`, which are absent:
  `seeds_n`, `boot_rec_share` (:247-248), the `_seeds`/`_honest` writes (:211-217), the log blocks (:264-267) and
  `honest_dev_*` (`sum(NULL) = 0`). Grading quits only on `dev`. Fix: one `main_only` flag used everywhere `dev` gates.
- **B2.** `path_log` gives a same-day sensitivity pass the main log's name, so it overwrites it. vignette_chinook.R
  (:60-64) then reads the wrong log. Fix: a `-grad_fwa` suffix.

## Gaps
- **G1.** A cache with `spec = NULL` is read back as segment-scored. Fix: rescore it unless the run reads
  `fwa_gradient`.
- **G2.** A cache with no `spec$grad` is always rescored, which throws away fwa-scored caches (optional: normalise a
  missing `grad` to `fwa_gradient`). `spec$grad` is set after scoring, as `evidence` is.
- **G3.** Both of 0320's `knw_tune_run` calls (smoke :168 and main :190) need `cols`.
- **G4.** Readers missing from the plan:
  - vignette_method.R (grades and summaries :78-91; add `grad_fwa/` to `sources` :412).
  - `knw_thresholds_table`: carry `curve_grad` and refuse it NA on fitted rows.
  - 0330: compare `curve_grad` with `curve.rds$cols`.
  - vignette_chinook.R:221 records `formals(knw_rule_in)$cols` rather than the run's record.
  - Non-fitted summary rows carry NA.
- **G5.** `knw_grade_species` reads segment `gradient` whatever the curve was fitted on. Refuse a curve whose
  `cols[["grad"]]` is not `segment_gradient`.
- **G6.** Register:
  - 0320 passing `cols` explicitly means the default is not what runs. Point to a `script:` variable, or pass `cols`
    only under GRADIENT (the `prior_sd` pattern).
  - `gradient_col` becomes `tested = yes`.
  - pipeline.csv steps 7 and 9 carry issue 92, and step 5's text omits the gradient.
- **G7.** CLAUDE.md "A run's record travels with its table": add `curve_grad`, `spec$grad` and vignette_method.R.
- **G8.** chinook_rearing.Rmd carries `stopifnot` guards encoding #73's findings (:71-72, :77-80, :86-87, :91, :98-99).
  `grad_ext` (0322) was scored on the Atlas gradient on pre-#73 evidence, so the article (:344-345) must say so. Budget
  a full reread.
- **G9.** habitat_thresholds.Rmd: the gradient sentence is in step 5 (:185), not step 2. Limits :334 ("a near-equal
  stream close by is not weighed") is now false. Guards :80-86 (`fun$n[1] == 51587`).
- **G10.** 0325: "a change of columns or meaning is a new version". Resolved: `aws s3 ls s3://fresh-bc/knowledge/`
  holds only `fdis/` (v1, v2), so thresholds/v1 and habitat_grade/v1 were never published, and v1 stays.

## Ordering
- **O1.** vignette_method.R refuses a dirty tree and md5s settings.csv. Order Phase 4: prose the register names,
  then register edits, commit, the bundle scripts, then the tests.
- **O2.** Make DEV=1 on CH Phase 3's first step. Run the sensitivity apart from the 0320 → 0325 → 0330 chain.
- **O3.** test-vignette-data's two source tests stay red until Phase 4. Say so in Phase 2's acceptance.

## Assumptions
- **A1.** `grad_<name>` gives `grad_fwa_gradient`. Spell out the mapping (`fwa_gradient` → `grad_fwa`), allow only
  the two values, and send DEV=1 to `data/tune/dev/grad_fwa/`.
- **A2.** 0322 and snap_limit_sensitivity.R cannot rerun on current evidence anyway. Pin `cols` and fix 0322's header
  "SAME SPEC AS 0320".
- **A3.** `previous` and the smoke checks are fine under GRADIENT.

## Acceptance
- **AC1.** "Population unchanged" has no baseline in the committed summaries (#73 evidence). Compare against a
  sensitivity run or segment_gradient_check's counts.
- **AC2.** A mutation check through the scripts is impractical. Put the grade-record comparison in one helper and
  unit-test it.
- **AC3.** Tests: `knw_thresholds_table` `curve_grad`; `knw_grade_species` refusing an off-gradient curve; the
  no-spec cache rescored.

## Scope
Optional: the 0330 compare tables carry no `evidence_md5` or `curve_grad`. File separately if not fixed.
