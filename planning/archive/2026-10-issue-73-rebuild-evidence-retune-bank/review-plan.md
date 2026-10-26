# Plan review (#73), Plan agent, 2026-10-22

Spawned after the baseline commit (2c24b94), read-only, against the working tree that already carried Phase 1 and 2
edits. Its direct answers and findings, with what was done about each. Confirmed by probe: the discharge comment is
still build 94deeb5; `fresh_default.log_recompute` is `20261017_004619-3f4c713b`; `fresh_default.streams` has no
`mad_m3s` and no near-river table; the Context's quantified claims hold (link#364's 275.6 km at 5 %, 43.1 km; #80's
1.26 SE; BT 0.043; 4 minutes of walks; connector median 14–88 m).

## Direct answers

- **Phase 1's subtraction reproduced half of fresh's rule.** fresh counts every jump between path rows
  (`path_m = SUM(below_m + jump_m)`) and subtracts connector rows plus the part of each jump inside the target's
  polygon. Our walk never added a jump to the distance, so subtracting the jump's inside part double-discounted
  side-line connectors. **Done:** the walk now adds each hop's gap (`d := d + par.g`), fresh's convention and the
  approved Decision 1 ("every other gap counts").
- **A connector passed through stays in the distance.** The working tree already did this (subtraction keyed by
  `waterbody_key`, only the target's key summed). Kept.
- **T1/T2/T3 are expressible** but not with the two-arm `tuned_sql`; the 1050/1150 rule must be forced free for T1,
  given a third arm for T2/T3, and `per_group`, `change`, `checks$outside`, `segments` generalised over the rule
  names. **Done in Phase 4.**
- **0.67.0 `default` for CH needs `near_river_table`**, at the pair the rule resolves to under the group's model:
  `channel_width ≥ 15 m within 1,000 m` under `cw` (all 188 groups), not 3 m³/s. **Done in Phase 4:** the pairs come
  from fresh's own resolver (`.frs_near_river_specs()`), walked as given.

## Blockers

- **B1** `c record` shadowed the mouth query's alias `c`: every hopping walk errored. **Fixed** (`conn_row`); the
  test gained a hopping start.
- **B2** the double discount above. **Fixed** (gaps counted).
- **B3** the check could not see B2: a side-connector origin landed in `path`. **Fixed:** the check reports the bank
  residual by class and by a side-line-connector flag; after B2, 85 such origins agree with fresh to 0.00 m.
- **B4** Phase 4's recipe walked discharge where link walks width. **Fixed in Phase 4** (pairs from the resolver).
- **B5** Decision 4 ("no new column") contradicted Phase 4's new columns. **Resolved:** the table gains
  `river_measure`, `rule_flow` and `rule_flow_196`; `near_river_scope` is dropped (O1); `thresholds/v1` stays v1
  because it has never been uploaded, which is the rule the issue states for the grade and the fdis tables too.

## Gaps

- **G1/G2** `compare.csv` gaining `structure` and `_segments.rds` gaining per-structure flags collide with
  `data-raw/vignette_chinook.R`, `test-vignette-data.R` and `0330 STAGE=maps`. **Phase 8:** the article and test
  read the `tuned` alias (the structure `0330` names `tuned_as`), one row per group per structure.
- **G3** `default_rule` label omits the door and the pair. **Phase 4:** labelled from the configs.
- **G4** `checks$outside` and `per_group` hard-code two names. **Phase 4:** generalised.
- **G5** `vignette_chinook.R` pins `20261019_tune_run.txt` and the 0322 population. **Phase 8.**
- **G6** `.gitignore` lacks `data/compare/gpkg/`. **Phase 4.**
- **G7** `knw_tune_curve()` had no `edge_stream`. **Done (Phase 3).**
- **G8** `test-grade_species.R`'s mock walk has six columns. **Done:** `target_in_group` is read only when the walk
  names `large_lfid`.
- **G9** GR has no 1050/1150 rule in 0.67.0 `default`. **Phase 4:** a species with no through-wetland rule runs one
  tuned structure; one with no exception runs two.

## Ordering

- **O1** `near_river_scope` needs a human judgement after Phases 6–7. **Dropped from the table;** the scope goes in
  the research files and link#346's body.
- **O2** `0320` reads `default_tuned` at the run's sha, not `config_sha`. **Kept as the code does** (the grid is
  anchored on the run's `default`; BT 0.043 predates the run); the task plan's wording corrected.
- **O3** `0325` refuses when the live flow build differs: a wet reload during grading forces a full regrade. Noted.
- **O4** the one-time `default` check must run on today's code first. **Done:** ADMS and BULK, CH rearing, default
  and tuned km reproduce #65's to 1e-12 (`scratchpad/default_check_o4.out`, 2.3 min, fresh 0.42.0, configs at
  a17e9177).

## Assumptions

- **A1** the comparison loop is per rule, so `default` + three structures is 3–4× #65's 132 min, plus a near-river
  walk per group: 4–5 h, not ~130 min. Accepted; `0330` runs species in parallel.
- **A2** "scoring 104 min" was #57's number; on the 30 % ladder every species scores 6,149 rules or more. Labelled an
  estimate.
- **A3** the new walk adds a query per line and a polygon intersection per hop. **Measured:** 2,460 starts in 4.7 s
  against 4.4 s before the gap counting; #57's 34,192 starts × 21 took 3.7 min.
- **A4** fresh's check against our walk ran on fresh 0.40.0 (b616b44), not 0.42.0; the reversed check here runs on
  0.42.0.
- **A5** a synthetic unit test cannot shadow the schema-qualified tables; the live test is right, and it now hops.

## Scope and acceptance

- **S1** `knowledge/fdis/v3` kept while values move: the override recorded in `findings.md`.
- **S2** the tuned predicate's walk crosses group outlets, link's does not: `target_in_group` is recorded per
  segment and the km that pass only through a river in another group are counted (Phase 4).
- **AC1** tests the plan did not list: `test-tune_repick.R` (8 tune files, #79's 1.96 table), `test-vignette-data.R`
  (8 keys, the `versions` names), `test-tune_run.R` (2795 → 6149, done), `test-thresholds_table.R` (Phase 4).
- **AC2** the walk gate reports the side-connector population (done).
- **AC3** the link#364 comparison needs a comparable quantity: CH through-wetland km under `default` before
  connectivity on ADMS, BULK, CHWK, CLWR and SQAM is logged by `0330` and set beside link#364's figure in the
  write-up, not made a gate.
- **AC4** `0330`'s refusal reads the header separately (done).
