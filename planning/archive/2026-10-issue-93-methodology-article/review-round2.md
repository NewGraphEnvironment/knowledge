# Code-check round 2 — #89 / #93 branch (base 80ea4c1, head b125673)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (from `mech.txt`, `|` rows skipped); `## Rules that stand alone`, Security and Spreadsheets: index only (0 sections in full).
- code-check-r.md: index read in full; sections read by their index line for what this diff uses (regex/`gregexpr`, `readLines`, `system2(stdout = TRUE)`, tests that silently do not run, `skip_if_not()` scope, testthat counting `error` vs `failed`, `Rscript -e` argument handling, regenerated binaries churn git, `yaml` list returns). About 10 of 111 headings; the rest index only.
- code-check-shell.md: index only (0 of 67 in full); the only shell is the pkgdown draft gate, unchanged since round 1, which round 1 ran against both answers.
- code-check-spatial.md: index only (0 of 93 in full); the diff's only spatial code is the `ST_DWithin` / `ST_Distance` example query, unchanged since round 1.

## Findings

- **[fragile — inside the round 1 fix, one axis over]** `inst/method/settings.csv:52` (`grad_clamp`) and `:7` (`ws50_code_length`). Round 1's `dist_offset` fix registered every copy of the `+ 10` offset. It did not do the same for the other `code:` rows, so copies of their values that the registered text does not match are still unwatched:
  - `R/tune_curve.R:159` (`nd$grad <- min(pick$grad_max, 0.2) / 2`) and `:176` (`seq(0, 0.2, length.out = 120)`) carry the gradient clamp in the plotted curves, the same plotting code whose `+ 10` copies (158, 177, 178) were registered.
  - `scripts/0230-fdis-load.R:449` (`substr(watershed_code_50k, 4, 45) != strrep("0", 42)`) carries the 45-character code length twice more.

  I changed all four in a temp copy (0.2 → 0.3, 45/42 → 46/43), and `test-settings-register.R` stayed green (0 failed, 0 errors). The header's "every line … that matches `<text>`" is true, but it covers the text, not the value. Register these copies as `code:` entries, as `dist_offset` now does.

- **[fragile — guard fails toward pass, inside the round 1 fix]** `data-raw/vignette_method.R:104-109` (`ext_value()`, YAML branch). The fix makes a missing *parent* an error, but a missing *leaf* under a present parent still reads `"unset"`, and `"unset"` is the register's value for `link_default_flow`. So two cases still hold:
  - a typo in the register's own key (`pipeline.discharge_sorce`);
  - link renaming the leaf (`pipeline.flow_source: wet`).

  I checked this against link's `default/config.yaml` at `102762da`: `pipeline.discharge_source` and `pipeline.discharge_sorce` both return `"unset"`. Where the register's value is the absent value, the presence of the leaf's name has to be checked somewhere else. One way is to require that the key appears in a sibling bundle that sets it: link's `default_tuned/config.yaml` sets `discharge_source: wet` at the same path.

- **[claim — the article's provenance line]** `vignettes/_tuning_method.Rmd:240-241` prints "This article's data were written … at commit `r x$meta$commit`". `data-raw/vignette_method.R:330` records `git rev-parse --short HEAD` and does not check for a clean tree. The bundle is committed together with the script change that produced it, so the recorded commit is always the parent:
  - `method.rds` at b125673 records `64d58e5`, and was made by b125673's script.
  - `method.rds` at 64d58e5 records `6d8e6eb`.

  64d58e5's script gives different numbers: `ws50_checked` 12,285 vs 12,260, `ws50_mismatch_all` 1,311 vs 1,295, and kept example `102443_1_1` vs `103957_16_1`. A reader who checks out the printed commit and reruns gets a bundle that does not match the article. Refuse to write from a dirty tree (`git status --porcelain` on `data-raw/`, `R/`, `inst/method/`), or record the dirty state.

- **[claim — inside the round 1 fix]** `inst/method/settings.csv:30` (`fit`, `tested = no`) and `:28` (`seed`, `tested = no`), read against the article's definition at `_tuning_method.Rmd:224-225` ("**Tested** says whether the result has been compared with another value") and the count it prints at line 60. Round 1 flagged `prior_sd` and noted that `fit` might be the same case; the fix flipped `prior_sd` only.
  - `fit`: the #73 archive README (`planning/archive/2026-10-issue-73-…/README.md:30`) says "The fit with the groups absorbed reproduces the dense reference on six species rule by rule". So `fe` was compared with `dense`.
  - `seed`: step 8 repeats the choice on seeds 55–58 and reports whether the pick holds (`seeds_same_rec`). That compares the result under another value of the seed.

  So "3 have been tested against an alternative" still undercounts under the article's own definition.

- **[claim]** `inst/method/pipeline.csv:5` (step 4 `does`, printed in the article's step block): "PCIC's routed flow where it reaches … and wet's water balance elsewhere". In the run's `visits_link.csv`, 1,905 of the 5,561 visits that take the balance have a routed value (`mad_routed` present). They take the balance because routed carries under 0.2 of it on the segment's own line. Province-wide, the same holds for 222,906 of the 1,378,712 balance picks. "Elsewhere" says the balance is used only where routed does not reach. The research text has the condition right: "where routed does not reach, or carries under 0.2 of the balance on the segment's own line".

- **[claim, minor — published article]** `vignettes/chinook_rearing.Rmd` ("What records were used?"): "with wet's own water balance where that flow does not reach or carries under a fifth of the balance's". This drops the own-line condition. 668 of the 34,991 kept visits on routed flow carry under a fifth of the balance and keep routed, as do 51,083 routed picks province-wide (read-only query on `discharge.fwa_v1_segment_monthly`, build `94deeb5`). Add "on its own watershed's line" or similar.

- **[claim, minor]** `research/modelled_discharge.md`, "Which build": "wet has republished since (2026-10-24: monthly shares from donor gauges, wet#102, and a daily product, wet#99)". Per wet's NEWS and tags:
  - the donor-share republish (build `8ca2dee`) is v0.4.15, tagged 2026-10-19 20:52 PDT;
  - the daily product (build `77585a8`) is v0.4.16, tagged 2026-10-20;
  - 2026-10-24 is v0.4.20, the rebuild on the order-free province run (#76).

  Two of those republishes came before the 2026-10-22 evidence build, which bears on the sentence's point that the database and the bucket diverged. Date each republish, or say "republished several times since 2026-10-19".

- **[claim, minor]** `vignettes/_tuning_method.Rmd:73-75`: "Four outside sources reach the tuning, and the citations follow from them". The next sentence names a fifth: the Water Survey of Canada gauges the balance is fitted to, which reaches 13.7 % of the kept visits through the balance. The balance also rests on climate inputs (climr) that the article neither names nor cites. Since the article says the citations follow from this list, the list leaves out sources that inform the result.

## Checked and holding (no finding)

- **`.knw_where_values` regex.** `esc()` escapes every PCRE metacharacter correctly. I checked it from a script file, because `Rscript -e` mangles backslashes, on `\`, `^`, `$`, `[[`, `|`, `(`.
  - Lazy capture with a multi-piece value works (`c(-Inf, 1994, 2004, Inf)` → `1994, 2004`; the 7 edge types).
  - Two matches on one line are both returned (`f(1, 2) ; w <- f(9, 2)` → `1`, `9`).
  - Full-line `#`, `#'` and `--` comments are skipped. A trailing comment is counted, but that fails toward fail.
  - A miss returns `NULL`, and `length(NULL) > 0` is FALSE, so both the test and the data-raw script refuse it.
  - `{value}` at the end is refused. A `{value}` given twice silently uses the first two halves, but no row does that.
  - Every one of the 20 `code:` entries resolves to exactly the register's value.
- **`rule_flow <- flow_pick(`.** The pattern cannot match `rule_flow_196 <- flow_pick(`. The `se_region` and `se_strict` entries now cover every literal `se_mult` in `R/thresholds_table.R`.
- **Region test.** It now discriminates. Ratios of 0.9 and 1.1 SE give a region that changes for any multiplier outside [0.9, 1.1), and `<` in place of `<=` drops the best itself. Nothing else in the scorer fixes the region: `.tune_sel` feeds the main pick, the bootstrap, honest and seeds, and `knw_tune_repick()` takes `se_mult`. (`vignettes/chinook_rearing.Rmd:74-75` hardcodes 1.96 for its stricter reading. That predates this branch, and the register's `se_strict` does not see it.)
- **`fn:` rows.** Every one is a default the run does not override. `knw_tune_run()` passes `seed`, `folds`, `fit` and `prior_sd` on to `knw_tune_score()` and `knw_tune_smoke()` with the same values. It does not pass `seed_boot`, `dist_cap_m`, `q_default`, `k`, `cols`, `ref_quantile` or `classes`, so their defaults run. 0320 passes no `prior_sd`, which makes its new log line correct.
- **New `grade_species.R` rows.** They name the literals that run (`size_col`, `cols[grad]`).
- **Round 1 fixes that hold.**
  - Placed-only 1:50k counts: 12,260 / 1,295. The script now also checks `fdis_sites` against the ledger.
  - The kept example `103957_16_1` is in `visits_link`.
  - The header no longer claims a scored-visits guard.
  - The modelled_discharge provenance line is corrected.
- **The 29 % FDIS share of link's observations.** It is robust: 53,473 of 184,792 distinct keys (28.9 %) across link's per-group `working_*.observations` tables, which apply link's own per-group species-presence filter, and 29.4 % over all 16 codes those tables carry, province-wide.
- **`discharge.fwa_v1_segment_monthly`** (build `94deeb5`). Routed picked 3,154,131 and balance picked 1,378,712, as `modelled_discharge.md` states. Routed rows not picked: 222,906.
- **Tests.** `test-settings-register.R` (8) and `test-vignette-data.R` (10) pass in a temp copy, and `method.rds`'s md5s match the current registers.
