# Code-check round 2 (#112, branch diff against main at e064b61, planning/ excluded)

## Checklist read

- code-check-python.md: in full.
- code-check-r.md (179 KB): read the full sections "`tryCatch()` nests its handlers", "`on.exit()` at a script's top
  level never fires", "A `data-raw/` script must load the source tree" (and its PSOCK-worker bullet), "`system2(stdout =
  TRUE)` warns on a non-zero exit", "`c(name = x)` keeps `x`'s own name", "`[[` on a named ATOMIC vector with an absent
  key", "Forked `parallel::mclapply()` workers segfault", "Postgres row order is never fixed", "Rscript reads a script as
  it runs", "Inside a dplyr verb, a column named like a local variable wins". 10 read, about 110 not.
- code-check-shell.md (125 KB): no heading's index line names a tool or shape this diff uses (the only shell is
  `git rev-parse` / `git show` through `system2()`, covered under R). 0 read.
- code-check-spatial.md (156 KB): nothing spatial changed. 0 read.
- code-check.md (331 KB): the prose of every H3 under `## Mechanisms` (table rows skipped); the index of "Rules that stand
  alone", acting on "Documentation Staleness".

## What I checked

- The code paths: `.knw_compare_structures()` ("reported", subset refusal), the new timing in `.knw_compare_bin()`
  (setup ends before the walk, the walk is outside the rule loop, so setup, walk and rule minutes do not overlap;
  assignments inside `tryCatch()` reach the bin's frame; `stats::` qualified for the socket worker), `worker_minutes`
  names (unnamed `setup`/`walk` scalars, rule names from `Reduce` of named vectors), `assert_default` under "reported",
  0330's `STRUCTURES` parsing ("" and "reported" both mean reported), every reader of non-reported structures
  (0330's CH through-wetland log line, `vignette_chinook.R`, `knw_thresholds_table()`, `tune_promote.R`'s field check,
  0330's composition guard, `vignette_method.R`, the README figure): none needs `free` or `door_wetland`.
- `tests/testthat/test-compare_rules.R` in a `git archive` copy: 41 passed, 0 failed, 0 errors.
- Every number in the CLAUDE.md sentence and the new `research/database_builds.md` section against the four
  `20261028_compare_structures_check*.txt` logs and `20261027_compare.txt`: the table (4.5/3.2/33 %, 16.6/12.6/31 %,
  9.9/7.0/29 %), "24 to 29 %" (28.9, 24.1, 29.3 % wall), "5 to 19" worker minutes per rule (5.3 to 19.2), "0.7 to 1.4"
  (0.7 to 1.4), CH walks "about 20" (19.5, 20.0), 9.9e-14, 1.7e-14, 164 (164.3), and the free/door_wetland km in
  `habitat_thresholds_tuned.md` (lines 16 to 67 of `20261027_compare.txt`). These hold. The findings are below.

## Findings

- **[fragile]** scripts/README.md:87-90 — the run order's `0330` row still says it compares "under each rule structure
  for the through-wetland lines and the pair (#73: free | door | door_wetland; …)", which is no longer what a default
  run does: it now compares `default` and TUNED_AS alone, and the row never names `STRUCTURES=all`. CLAUDE.md names
  `scripts/README.md` as the run order, so whoever runs `0330` from it to refresh the research files' `free` and
  `door_wetland` figures will not get them. The script's header, roxygen and CLAUDE.md were updated; this sibling was not.

- **[fragile]** data-raw/README.md:12 — "Three scripts are checks, not data: each proves that a faster or different path
  returns what the reference path returns", followed by the list of three. `compare_structures_check.R` is a fourth of
  exactly that kind (the reported-only path held to the every-structure run), and the README neither counts nor lists it.

- **[prose]** research/database_builds.md:113 — "the contended pass read the same shares (35, 31 %)". The idle reruns
  the table reports read 33 % for WCT (`-4`: 6.1 of 18.4) and 31 % for CH (`-3`). CH's matches. WCT's (35 % in the `.txt`
  log, 7.8 of 22.2) does not. The two WCT passes also read different inputs: #92's staged tables in the `.txt` log
  (visits md5 1bd35829 009698d7), the host's own in `-4` (d3a434e2 bc71243b). So the pair cannot separate contention
  from inputs in any case. Say "within two points" or similar, and name the input difference.

- **[prose]** research/database_builds.md:113-115 — "they come to about 40 of its 164, a quarter". I can get 39.4 only
  by applying CH's 31 % to CO and ST ("CO and ST drop two rules like CH"). But 19.5 of CH's 56.6 worker minutes in that
  share's denominator are near-river walks (`-3`), and CO and ST have none (`20261027_compare.txt`: "near-river walks
  0.0 min" for both). With the walks left out, CH's dropped rules are 47 % of the rest (17.6 of 37.1). On that share CO
  saves 10.6 and ST 8.7 of their 22.4 and 18.4 min, not 6.9 and 5.7, and the total is about 46 of 164 (28 %). The
  sentence's estimate depends on an assumption it does not state, and it probably understates the saving. Either say
  which share each key was given, or apply a walk-free share to the keys with no walk.

No bugs or security issues in the R code, the check script or 0330's change.
