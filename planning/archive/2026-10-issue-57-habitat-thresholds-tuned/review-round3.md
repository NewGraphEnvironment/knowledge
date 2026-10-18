# Code-check round 3 — knowledge#57 branch (`57-tune-habitat-thresholds-for-every-specie` against merge-base 3e88647)

Reviewed 2026-10-17 (22:30–23:00 UTC) read-only on the working tree, while the fifth `0330` attempt ran
(started 22:34 UTC; scratch schemas `knw_cmp_<sp>_<stage>` untouched). Read: the branch diff, round 1's and
round 2's reports and fix diffs (`cd16d85`, `40c3080`), every changed `R/` and `scripts/` file and the tests in
full, the merge-base `0294`–`0298`, link `configs/default` (`rules.yaml`, the thresholds and fresh CSVs), fresh
0.39.0's `frs_habitat_predicates()`, `.frs_rule_to_sql()`, `.frs_rule_ha_min()`, `.frs_run_connectivity()`,
`.frs_bucket_connected()`, `frs_cluster()` and `frs_habitat_overlay()` source, the committed `data/tune/*`
tables, the `0330` attempt logs and the live scratch tables. Probes ran against copies in the scratchpad, with
`pkgload::load_all()`, and with read-only SQL.

## Mechanism

Rounds 1 and 2 came from three shapes, and the two new findings below are the third one again.

**(a) Another system's semantics re-derived by hand and checked at one point.** fresh's rule list was re-read
into SQL (edge types, floors, `in_waterbody`), readr's `col_types` contract was re-stated per column, and
`parLapplyLB`'s error contract was assumed; each was checked on the case it was written for (CH's rule shape,
one species' groups, a run where nothing failed). The misreads surfaced wherever a species' rules departed from
CH's shape: CO's floorless `W`/`L` rules and always-in 1050/1150 rule, the spawn stream rule's
`in_waterbody: false`. The author's closing evidence for this mechanism is `review-round2-oracle_predicate.R`.
I ran it unchanged on three groups chosen for the features PARS and BULK lack — LFRA, OKAN and NARC hold 1,918
canal edges (2000/2300), 5,359 wetland-through edges (1050/1150) and 85 segments in man-made waterbodies — and it
reports **0 differ in 14 of 14 (149,024 segments)**, matching the author's 0 of 14 on 185,174. Then, per thing the
oracle structurally cannot see (it compares at `default`'s own values, width rule, no exception):

| what the full comparison exercises | checked how | verdict |
|---|---|---|
| other groups | the three groups above; `is_default_rule` runs live on GR (its pick is `default`) over all 82 of its groups, stopping on any difference | right |
| the MAD size test on the stream branch (`coalesce(s.knw_size >= m, FALSE)`) | `knw_size` is `grades.size` = `knw_link_segments()`'s `mad_pick` (own picked flow, else `knw_link_flow()`'s parent), the same flow the visits carry. On CH's 7,123-visit population, the visit's `mad_pick` equals its segment's `size` on 7,105; the 18 that differ are among the 39 visits `knw_link_place()` put on a segment whose `linear_feature_id` is not the visit's own FWA segment (the 5 m start window), where the two flows legitimately differ. Same test semantics as `knw_rule_in()` (`!is.na(m) & m >= min`) | right |
| the exception (`coalesce(s.knw_dist <= D, FALSE)`) | `knw_grade_species()` walks `cand = accessible & stream edge & 0 <= gradient <= grad_max & !size_ok`, a superset of every segment where `ex` can change `tuned_sql` (`sb` is inside the stream edges; `ex` is reached only when `grad_ok` and `size_ok` fails); the gate is the same `accessible`; the walk starts at the segment's downstream end, as 0298's did | right |
| the gradient substitution in `p_tuned_base` | `.frs_rule_to_sql()` inherits the CSV gradient only where `inherit_thresholds` holds, which fresh sets `FALSE` for every `L`/`W` rule; so the substituted gradient reaches the stream rule (overridden by `sb` anyway) and the `R` rule (`gradient BETWEEN 0 AND tuned AND channel_width BETWEEN 0 AND 9999`), exactly 0298's "changes the gradient on the stream and river branches, keeps default's river test"; the `W`/`L` branches are untouched. For `stage = "spawn"`, `pred_of()` passes `spawn_gradient_max` from `ps_t`, so the substitution reaches the spawn predicate too; a width pick leaves the `R` rule's explicit `[0, 9999]` alone | right |
| the lake and wetland bucket columns | compare's `lake_rearing`/`wetland_rearing` (`accessible AND waterbody_key IN (L, M)` / `IN (W)`) differ from fresh's `lake_rear`/`wetland_rear` (lakes only, no `M`) — but they are read only by `.frs_bucket_connected()`, which zeroes them where no spawning lies within 10 km, and come back in `flags` without entering `rearing`, `spawning` or any km; `frs_cluster()` reads `rearing` and `spawning` only. 0298 wrote them the same way | no output depends on them |
| spawning regenerated beside rearing | `pred_other` is `default`'s other-stage predicate under both rules, so the connectivity pass sees one spawning for both rear rules; for `BT_spawn`, connectivity's cluster pass rewrites `rearing` (read by nobody) and leaves `spawning` alone (BT's spawn rules carry no `requires_connected`) | right |
| `sb` against the scoring population's stream branch | scoring: stream edge, not in a river, a wetland ≥ 1 ha or a lake ≥ 100 ha (0297's); compare: not in the species' own `W`/`L` floors (CO: 0, so any wetland or lake). Measured on each species' scored population: visits in a wetland < 1 ha / a lake < 100 ha — CO 2 / 0, BT 4 / 8, CH 3 / 6, RB 4 / 8, ST 3 / 0, WCT 0 / 1, GR 0 / 1 — with the species caught on none but one RB small-lake visit. The accepted-tradeoff class, and now measured for the wetland floor too | accepted |

The residual gap (not a finding): nothing in `tests/` pins `.knw_fresh_branches()` over `rules.yaml` (round 2
asked for it); the oracle lives in `planning/active/` and is run by hand. GR's live `is_default_rule` check covers
the width/gradient form only.

**(b) One fact written at every consumer.** The access gate. Every read of `access_`, `accessible`,
`streams_access` and `streams_habitat` across `R/` and `scripts/0290`, `0294`, `0296`, `0300`–`0330`:

| place | gate as written | verdict |
|---|---|---|
| `R/link_place.R:239` (visits) | `<sp>_<flag>_stored & !is.na(access > 0) & access > 0` | the one gate |
| `R/link_segments.R:136-139` (segments) | `<flag>_stored %in% TRUE & (!is.na(access) & access > 0)` | the one gate |
| `R/grade_species.R:50, 69-70` | `seg$accessible` from `knw_link_segments()`: the walk candidates and the `NA` grade | inherits it |
| `R/grade.R:356` | reference quantile over `segments$accessible %in% TRUE` | inherits it |
| `R/compare_rules.R:152, 209` | `h.accessible AND coalesce(a.access_<sp> > 0, FALSE)` | the one gate (`h.accessible` is never NULL: 0 NULLs in all seven habitat tables, measured) |
| `R/compare_rules.R:244-253, 314, 368-370` and `R/compare_map.R:152`, `R/floodplain_ha.R` (`accessible` flag) | compare's `seg$accessible` | inherit it |
| `R/link_access_check.R:266` | the two columns cross-tabulated, by design | not a gate |
| `scripts/0310:188-193, 290` | writes the cross-tabulation and ledgers the disagreeing cell | not a gate |
| `scripts/0320:165`, `0330:103` | `groups_sp()` reads `streams_habitat_<sp>` for the group list only | not a gate |
| `scripts/0325:75, 84` | publishes the raw `access` code beside the grade; the description's "NA where inaccessible" is the grade's gate above | consistent |
| `scripts/0290:50-51, 58` (frozen-shape BT table) | `access_bt %in% c(1, 2)` — on codes {0, 1, 2} the same predicate as `access > 0` — and `accessible = bt_accessible`, the re-gated flag | consistent; 0290's own, accepted |
| `scripts/0296:205` (frozen-shape CH table) | `link_accessible = ch_accessible_stored` | the stored flag, as the merge-base 0296 wrote it (`h.accessible AS link_accessible`, line 273): a faithful frozen reproduction, not a gate |
| `R/tune_run.R:326-352` (the scoring population) | no access gate at all: stream branch, area, `in_range`, `status != "blocked"`, `barrier_dnstr_<sp> %in% FALSE` | 0297's population (0297:149-150 gated on `natural_barrier_dnstr %in% FALSE`, never on access, by B3's argument that a rule scored behind the access gate learns barriers); carried unchanged |

The enumeration is complete and every member that gates reads the same predicate.

**(c) A fix lands at one end of a contract and the other end is not re-read.** Round 2's two `0330` fixes each
changed one side of a positional or typed contract inside `run_one()`'s collection: the error-tolerant collection
filters `res` by name while the map loop still indexes `jobs` by position through `names(res)`; the trimmed
`col_select` read restated the column types and typed `watershed_group_code` as a double, which the SQL join and
the `%in% groups` filter downstream read as text. Both are below.

## Findings

- **[bug, inside round-2 fix 3]** `scripts/0330-compare.R:172,174` — `stage <- jobs[[match(k, names(res))]]$stage`
  and `sp <- jobs[[match(k, names(res))]]$species_code` index the unfiltered `jobs` list by a position taken from
  `names(res)` **after** line 147 removed the failed jobs (`res <- res[setdiff(names(res), failed)]`). `jobs` and
  `res` are aligned only until that line. Input that shows it: jobs are dispatched largest first (`RB_rear` 210,
  `BT_rear` 158, `BT_spawn` 158, `CH_rear` 125, `CO_rear` 100, `GR_rear` 82, `ST_rear` 79, `WCT_rear` 16); if
  `RB_rear` fails, as it did in round 2's run, then for `k = "BT_rear"` `match()` gives 1 and `jobs[[1]]` is
  `RB_rear`, so `sp = "RB"`; for `k = "BT_spawn"` `jobs[[2]]` is `BT_rear`, so `stage = "rear"`, `flag =
  "rearing"`, and line 187 reads `rearing_default`/`rearing_tuned` out of `BT_spawn`'s segments (both stages'
  flags are present, so nothing errors). Every job after the failed one gets the previous job's labels: wrong
  `species_code`/`stage` on every `floodplain.csv` row, the wrong stage's flags in the floodplain hectares and in
  the maps, and `compare_<k>_<wsg>.png` titled for another species. `compare.csv`, `change.csv` and `checks.csv`
  are unaffected (they are bound from `res` by name). This is exactly the case the round-2 fix was written for
  (one job failing must not spoil the rest), so the guard's own success path is the one that mislabels. Fix: name
  the list once (`names(jobs) <- vapply(jobs, `[[`, character(1), "key")`) and index `jobs[[k]]`.

- **[bug, inside round-2 fix 3; corrected on disk since, uncommitted]** `scripts/0330-compare.R:119-121` as
  committed in `40c3080` — `col_types = readr::cols(grade_class = "c", .default = readr::col_double())` applies
  `col_double()` to `watershed_group_code`, which is in `col_select`. Measured on `GR_rear_grades.csv`: 2,000 of
  2,000 rows come back `NA` with readr's parsing problem "expected a double, actual ATLL" (a warning, which the
  `tryCatch(error = )` does not catch). `grades$watershed_group_code %in% groups` is then all `FALSE`, so an
  empty `grades` table reaches the scratch schema — and because the empty table still carries a `float8`
  `watershed_group_code`, PostgreSQL refuses the join: `operator does not exist: double precision = character
  varying`, which is what every job of attempt 4 died of 0.1–0.2 min in
  (`scripts/logs/habitat/20261017_compare-attempt4.out`). Loud by the luck of the type system; had the key column
  been text-typed and empty, every MAD species would have compared with `knw_size` and `knw_dist` NULL throughout,
  silently. The working tree's `cols(id_segment = "d", watershed_group_code = "c", …)` is right and the live run
  (attempt 5) reads 210/82/100/125/158/158 groups into the scratch `grades` tables; it needs committing, because
  `40c3080` as it stands cannot produce a comparison.

## Round-2 fixes re-checked

1. `.knw_fresh_branches()`: floors 0 where a rule names none, the stream rule is the first no-`waterbody_type`
   rule whose `thresholds` is not `FALSE`, `no_waterbody` read from `in_waterbody`. Over every species in
   `rules.yaml`: BT W 1 / L 10, CH W 1 / L 100, CO W 0 / L 0, GR L 40 (no W), RB and WCT W 1 / L 10, ST W 1 / L 60;
   every `edge_stream` 1000/1100/2000/2300; every spawn stage `no_waterbody = TRUE`, every rear stage `FALSE`;
   `river = TRUE` throughout. The oracle agrees with fresh on all 14 on the five groups now run. Holds.
2. `sb` with `waterbody_key IS NULL` on the spawn stage: matches fresh's compiled spawn predicate; the oracle's
   `BT spawn` and the six other spawn rows read 0 differ. Holds.
3. `0330` collection: a failed job now returns its error and the rest write their tables as they finish; the
   worker log (`outfile`) is written. Holds for what it set out to do; the two findings above sit inside it.
4. Access gate written once: compare's two SQL reads now carry `h.accessible AND coalesce(a.access > 0, FALSE)`,
   the same cell as the visits and the grades; `access_gate_differ_km` reports what the gate removes. Holds (table
   above).
5. Grade cache keyed on `rule` and `run_uid` from the CSV's first row against the current pick and ledger, both
   character. Holds.
6. Map-criteria header and comment now say what the code picks. Holds.

## Checked and found consistent

- The eight fitted summaries' `rule_recommended`, visits, detections, groups, region size, `default`'s `ddev`
  and SE agree with the `_tune.csv` recommended and default rows, and `research/habitat_thresholds_tuned.md`'s
  results table quotes those rows (BT rear 8,717/1,198/75, region 196, +138.7 ± 87.8; CH rear 4,490/215/43, 23,
  +196.3 ± 81.6; GR `default` in, +10.7 ± 12.1; and the rest).
- `knw_rule_in()` and compare's `tuned_sql` test the same thing: `grad_ok & (size_ok | ex)`, `NA` failing each
  part, width in `[min, 9999]`, MAD `>= min`, distance `<= D`.
- `knw_tune_run()`'s population is 0297's (`sb_all` then `natural_barrier_dnstr %in% FALSE`), with `in_range`
  and `status != "blocked"` where 0290/0294 dropped the same rows before 0297 saw them.
- `knw_thresholds_table()`'s `seeds_n`/`seeds_rec_in_region` columns exist in every fitted summary; the not-fitted
  summaries bind on the union of columns.
- `0325`'s `tune_logs` regex matches the three `_tune_run*.txt` logs and not the `.out` files.
- `0299`'s `VERSION` switch: `tables_v3` carries v2's `fdis_sites` and `fdis_repeat_surveys` unchanged, the five
  `0310` tables, and the four species tables with the v3 note; `supersedes` maps v2→v1, v3→v2.
- `knw_fiss_visits()` takes the first pass's length × width and sums seconds over passes; the test pins the
  `ef_length_m` override and the non-EF method.
- Not live, noted: `.knw_fresh_branches()` reads a rule's `edge_types` as one comma-separated string
  (`strsplit(x, ",")[[1]]`) while fresh reads it as a vector of categories; every rule in `default`'s generated
  `rules.yaml` uses `edge_types_explicit` ("Edge types: explicit" in its header), so the branch is not reached.
