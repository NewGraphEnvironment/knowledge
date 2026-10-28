# Task: Compare only default and the reported structure unless asked (#112)

## Problem

`0330` regenerates link's flags under every structure a key has, though the tables, maps and thresholds report only
`door` (`TUNED_AS`): four rules for CH, CO and ST (`default`, `free`, `door`, `door_wetland`), three for BT rearing, RB and
WCT, two for BT spawning and GR. Classify, overlay and connect was 164 of #92's 269 comparison minutes
(`scripts/logs/habitat/20261027_compare.txt`).

The other structures feed two sentences of the methodology article: `free` and `door` "differ by under 0.01 in the ratio
and by under 1 point in either FDIS share", and `door_wetland` puts outside detections for CH and CO beyond that spread.

## Context

`0330` regenerates link's flags under every through-wetland structure a key has (CH, CO, ST: `default`, `free`,
`door`, `door_wetland`; BT rearing, RB, WCT: three; BT spawning, GR: two), but the tables, maps, thresholds and
articles report only `door` (`TUNED_AS`). Classify, overlay and connect was 164 of #92's 269 comparison minutes. The fix
is mostly wiring: `knw_compare_rules()` already takes `structures =` (`R/compare_rules.R:99`, `.knw_compare_structures()`
at :694), so `0330` only has to pass `tuned_as` by default. The outside-check bootstrap draws `idx` independent of the
rule count (`R/compare_rules.R:474`), so `door`'s intervals do not move when `free` is dropped.

What reads the other structures today (explored):
- `vignettes/chinook_rearing.Rmd:97-99,336`: `wl_free` (the free pass's through-wetland km and grade) in a
  `stopifnot()` and a clause of prose. `data-raw/vignette_chinook.R:291` already greps for whichever structures the
  segments carry, so it needs no change.
- `research/habitat_thresholds_tuned.md:272-276, 319-322` and the species files' "free pass" rows: prose on #92's run,
  which did carry every structure. They stay true as a record of that run.
- `inst/method/settings.csv:68` (`tuned_as`): its note says "the comparison runs every through-wetland structure".
- No reader requires `door_wetland` or `free` otherwise (`0325`, `knw_thresholds_table()` and `0335` read the tuned
  structure only).

This machine reaches the database at 63 ms per round trip (measured 2026-10-28), so the measurement runs on the
database's host.

## Decided at the gate

- **The other structures' sentences are dropped** (Al, 2026-10-28, answering #112's operator's question). A default
  `0330` runs `default` + the reported structure for every key. `STRUCTURES=all` keeps today's behaviour for anyone who
  wants the others. The chinook article loses its free-pass clause now. Its bundle is not rebuilt, because only a
  promotion changes its sources (#111). The research prose stays as #92's record, with one sentence saying a default
  run since #112 no longer carries the other structures.

## Phase 1: Measure

- [x] `.knw_compare_bin()` returns seconds per rule (table, overlay, connectivity and flag read, summed by rule name)
      and the per-group shared setup (copy, indexes), alongside `walk_s`. `knw_compare_rules()` sums them over workers
      and logs one line, so every run's log shows each rule's share.
- [x] `data-raw/compare_structures_check.R` (pattern: `data-raw/compare_parallel_check.R`, reusing its sort-and-compare
      with a relative 1e-9 on numerics). On `SCHEMA=fresh_default_20261017` and `CONFIG_SHA=102762da` (#92's tracked
      tables) it:
      - runs WCT_rear on every group under every structure and under the reported one alone;
      - runs CH_rear and BT_rear on their 20 largest groups both ways;
      - refuses unless the reported-only tables equal the every-structure tables' `default`/`door` rows (compare,
        change, checks with the `free`/`door_wetland` rows removed, and segments without their columns);
      - refuses unless WCT's every-structure run equals the tracked `data/compare/WCT_rear_*` tables row for row;
      - logs per-stage and per-rule minutes both ways.
      It calls `knw_db_latency_check()` at connect, and its log goes to `scripts/logs/habitat/<date>_compare_structures_check.txt`.
- [ ] Run it on the database's host: over ssh if the host is reachable from here; otherwise hand Al the bare command.
      If the flow load named in the table comment differs from the tracked tables' `discharge_load`, the tracked
      identity is reported as not comparable, not as a failure. The reported-vs-all identity still decides.
- [ ] Record the minutes in `research/database_builds.md`: per rule, the saving per key, and the estimate for all keys.
      **Gate:** if the reported-only run saves under 10 % of CH's and BT rearing's comparison minutes, stop here and
      report: the default stays every structure.

## Phase 2: `0330` defaults to two rules

- [x] ~~`.knw_compare_structures_env()`~~ (plan review G1): `structures = "reported"` is resolved inside
      `knw_compare_rules()` by `.knw_compare_structures(br, tuned, structures, tuned_as)`, held to the species' own set
      (refused outside it). `0330` maps `STRUCTURES=all` to `NULL`, else `"reported"`. Tests in
      `tests/testthat/test-compare_rules.R`.
- [x] `scripts/0330-compare.R`: read `STRUCTURES` and pass `structures =` to `knw_compare_rules()`. Name it in the
      run's provenance line and the log. Update the header's THREE STRUCTURES note and its RUN line.
- [x] DEFERRED to #115 (plan review B1: `settings.csv` is md5-pinned in `method.rds`; only a promotion rebuilds it).
      ~~`inst/method/settings.csv`: a `structures` row (`reported`, `script:scripts/0330-compare.R:structures`). Fix the
      `tuned_as` row's note. `test-settings-register.R` passes.~~

## Phase 3: Readers and prose

- [ ] `vignettes/chinook_rearing.Rmd`: drop `wl_free` from the setup chunk's `stopifnot()` and the free-pass clause
      at :336. Keep the door's km and grade against `default`'s.
- [ ] `data-raw/vignette_chinook.R`: comment only. The wetland table holds the structures the segments carry. Not rerun.
- [ ] `research/habitat_thresholds_tuned.md`: one sentence where the structures are introduced: #92's run carried
      every structure, and a default `0330` since #112 compares `default` and the reported one (`STRUCTURES=all` for
      the rest).
- [ ] `CLAUDE.md`: the `0330` timing sentence names that its minutes are every structure's, and adds the measured
      two-rule figure.

## Validation

- [ ] Tests pass (`devtools::test()`), `lintr::lint_package()` clean
- [ ] The chinook article renders with the current bundle after installing the branch (`pak::local_install()`,
      then `rmarkdown::render()`), and `test-vignette-data.R` passes unchanged
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification of the acceptance: the minutes are in `research/database_builds.md`. A default comparison regenerates two
rules per key: `knw_compare_rules(structures = tuned_as)` gives `rule_names = c("default", tuned_as)`. The check
script's log shows the reported-only run's rule count and its identity with the every-structure run's rows. The
every-structure run equals today's tracked tables on WCT_rear row for row.

