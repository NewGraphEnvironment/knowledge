# Plan review (#171), 2026-11-12

A `Plan` subagent reviewed `task_plan.md` against #171, #118, #107, #156, #159 and the code, while Phases 1 and 2 were
committed and Phase 3 was under way. Its findings, condensed, each with what was done.

## Blocker

- **B1. The method article prints "rule" from `method.rds`, not the Rmd.** Step headings from `pipeline.csv`
  ("Candidate rules", "Running the rule on link's streams"), five settings labels (`gradient_col`, `smoke_tol_null`,
  `flow_src`, `grade_size_mad`, `grade_size_width`), and the two pre-rendered SVGs (flow and lineage: "6 Candidate
  rules", "10 Running the rule on", "both rules run", "rules scored"). Editing `pipeline.csv` breaks its whole-file md5;
  editing a label breaks Phase 1's check; only the build's host can rebuild.
  **Done:** found independently before the review landed (findings, Phase 3). Split: the register and pipeline wording
  is filed as its own issue, to ride the next rebuild of the methodology bundle (a promotion reruns it), as #115 does.
  The Rmd's own prose carries no "rule".
- **B2. `R/compare_map.R`'s interactive popups** say "Habitat under the tuned rule" and "Downstream to the rule's river
  (km)"; the chinook article passes `title = "Habitat by rule"` itself. **Done:** popups and default title reworded;
  the article's title argument changed in Phase 3.

## Gap

- **G1.** The printed-columns test sat behind `has_src`, so CI never ran it, though it needs only the shipped register
  and bundle. **Done:** reads `system.file("method", "settings.csv")` and runs without the skip. `x$resolved$where`
  still names the old paths until the next rebuild; nothing prints it.
- **G2.** No test reads the legend labels. **Done:** `test-compare_map.R` asserts no class label or title default says
  "rule". `research/fig/` keeps the old labels until `0330` reruns.
- **G3.** `CLAUDE.md` gives the method article's old title; README link texts. **Done.**
- **G4.** The stream-splits article rests on the routed flows (the flow floor) but cites neither wet nor the fork.
  **Done:** cites both, by Al's rule.
- **G5.** #118 asks the case study to link the method's definitions. **Done:** links `tuning-method.html#thresholds`.
- **G6.** The redirects are meta-refresh pages: an old deep link lands at the top of the new page, through github.io's
  redirect to the custom domain. Noted in findings; acceptable.

## Ordering

- O1 (decide B1 first): done as above. O2 (bib regeneration after every citation edit; `all_tools` needs link, fresh,
  wet, fwapg, bcfishpass, bcfishobs in the chinook article): Phase 4 runs after Phase 3. O3: Phase 5 is tested by the
  PR's own CI.

## Assumption

- **A1. The stalls were apt mirror stalls** (`azure.archive.ubuntu.com`) inside setup-r's system requirements and pak's
  in setup-r-dependencies; a step timeout alone still leaves a red run to re-run. **Done:** Phase 5 adds a timed retry
  of each setup step in `pkgdown.yaml`, not only a timeout.
- **A2. Eight stalled runs on four occasions**, not three: PR #190's first pair (43033679109, 43033679680) and v0.4.29's
  (42115301523, 42115253520) besides the plan's. **Done:** findings and #159 say eight on four.
- **A3. fwapg reading.** The run's `fwapg_sha` (9a62b0c) is fork-only, so placement ran on a fork build too. Al's rule
  names the flows: the fork is cited where an article rests on the routed flows, upstream (no version) for loading and
  placing on the Atlas. Kept that reading; `vignette_bib.R`'s design note changes with it.
- **A4.** `../wet` needs to hold `wet_sha`, not have it checked out. Noted.
- **A5.** Redirects verified: pkgdown 2.2.0, pages land in `docs/articles/`, neither CI gate trips.

## Acceptance

- **AC1.** The rename grep must be `(habitat_thresholds|chinook_rearing|stream_splits)\.(Rmd|bib|html)`, excluding the
  redirects and NEWS: the research file names and bundle names legitimately match the bare words. **Done.**
- **AC2.** The rendered-text grep's exceptions: B1's bundle text and "rule of thumb". **Done.**
- **AC3.** Edit #156's body for the split fly row before "Fixes #156" merges. **Phase 7.**

## Scope

- **S1.** Reference pages (`R/compare_map.R` roxygen, `_pkgdown.yml` reference descriptions) say "rules". Out of scope:
  #156 is the README and the articles.
