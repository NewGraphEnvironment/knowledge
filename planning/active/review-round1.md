# Code-check round 1 — #89 / #93 branch (base 80ea4c1)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: every H3 under `## Mechanisms` read in prose (14 of 14, `|` rows skipped); `## Rules that stand alone`, Security and Spreadsheets: index only (0 of their sections read in full).
- code-check-r.md: read 9 of 111 headings in full ("Moving prose into a code chunk...", "Regenerated binaries churn git...", "Under `R CMD check`, tests run from a temp dir...", "`strsplit()` drops a trailing empty field", "R's `yaml` returns a mixed int/float sequence as a list", "Postgres row order is never fixed...", "`system2(stdout = TRUE)` warns...", "Tests that silently do not run", plus the `skip_if_not()` index line); 102 index-only.
- code-check-shell.md: 0 of 67 read in full (index only); the one shell change, the pkgdown draft gate, I ran under `bash -eo pipefail` against both answers instead (exit 0 with no draft page, exit 1 with one).
- code-check-spatial.md: 0 of 93 read in full (index only); the diff's only spatial code is one PostGIS `ST_DWithin`/`ST_Distance` query.

## Findings

- **[bug]** `data-raw/vignette_method.R:233` (`ex_kept <- pick_example(bulk[!bulk$flag_far_snap & ws50_ok, ])`) and `vignettes/_tuning_method.Rmd:200-203` — the "kept" worked example was never kept. The code picks it only on snap distance and the 1:50k check. The visit it picked, `102443_1_1`, has `flag_no_area = TRUE` and `flag_no_effort = TRUE`, so `knw_fdis_quality()` drops it at `effort_sentinel_or_none`, and it is not in `data/fdis/derived/visits_link.csv` (checked: `"102443_1_1" %in% visits_link$site_visit` is FALSE). The table prints `fate = kept` and the caption says "The first is kept", so a reader takes it for a visit that reached the tuning. Fix: draw the candidate from `vl$site_visit` (the visits that remain on a link segment), or rename its fate to say it passes placement only.

- **[bug]** `vignettes/_tuning_method.Rmd:139-145` and `research/habitat_thresholds_tuned.md` (Evidence, the new placement sentence): "the check reaches only the 12,285 placed visits that carry a full tributary code, and 1,311 of those disagree". Both numbers include visits that were never placed. `0230` builds `ws_check` by an `inner_join` with `placed`, and `placed` holds every visit with a UTM point, including those `fwa_indexpoint()` found no stream for (their `blue_line_key` is NA). So `ws50_checked` is TRUE for 25 unplaced visits, and `flag_ws50_mismatch` for 16 of them (NA blue line → no crosswalk hit). Measured on `data/fdis/derived/fdis_sites.csv`: 12,260 placed visits are checked, and 1,295 placed visits disagree. Either restate the figures as "visits with a point" or count over `!flag_not_placed`. The 1,088 ledger figure is unaffected.

- **[fragile — guard fails toward pass]** `tests/testthat/test-settings-register.R:69-78` ("the scorer's region is the register's number of SEs from the best"): the toy matrix cannot tell 1 SE from any other multiplier. In it, rule 1 sits 0.2 SE from the best and rule 3 sits 9.45 SE away, so every multiplier from 0.2 to 9.45 gives the same region, and all three assertions pass. I copied `.tune_sel` and changed `<= se` to `<= m * se`. The test passed at m = 1, 1.96, 0.5 and 5 (script: `/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/4acc7f78-ab59-497d-9375-606e07c47163/scratchpad/mut_sel.R`). So the only guard on the body literal behind `se_region` is decoration. Give it a rule between 1 and 1.96 SE from the best (and one just under 1 SE), so a changed multiplier moves the region.

- **[fragile — register row watches a value that never runs]** `inst/method/settings.csv` rows `se_region` (`fn:knw_tune_repick:se_mult`) and `se_strict` (`script:scripts/0320-tune-run.R:se_strict`). These are not the values that run:
  - The run's region and pick come from `.tune_sel()`'s hardcoded 1 SE.
  - `knw_tune_repick()`'s default of 1 is never relied on: 0320 passes `se_mult` explicitly, and `R/thresholds_table.R:110,113,117-120` hardcodes `se_mult = 1` and `se_mult = 1.96`.
  - That second file is what `0325` publishes (`holds_196`, the 1.96 flow pick).

  So a change to the stricter reading in the register and 0320 leaves the published thresholds at 1.96 with every test green, and the reverse holds too. Add `code:R/thresholds_table.R:se_mult = {value}` entries (or route those calls through one constant).

- **[bug — register row names the wrong thing, and passes]** `inst/method/settings.csv` row `grade_size_col` ("Flow the grade reads on link's segments", `mad_pick`, `fn:knw_grade:cols[size]`). The run never uses `knw_grade()`'s default. `knw_grade_species()` (`R/grade_species.R:78-79,112`) passes `cols = c(size = "size", ...)`, where `size` is `channel_width` when the pick's size test is a width and `mad_pick` otherwise. Three of the seven graded keys have width picks (BT spawn `width>=2`, GR rear `width>=1.5`, RB rear `width>=3`), so the article's register table states a flow column the grade did not read for them. `grade_grad_col` has the same mechanism: the value happens to be right, but `knw_grade_species()` passes `grad = "gradient"` itself, so the row's `where` cannot see a change there. Point both rows at `code:R/grade_species.R:...`.

- **[fragile — fails toward pass]** `data-raw/vignette_method.R:99-103` (`ext_value()` YAML branch). A key path that resolves to nothing returns `"unset"`, and that is the register's value for `link_default_flow`. So a misspelled or moved key, for example link renaming `pipeline:` or nesting `discharge_source` elsewhere, still "holds" the register's `unset`, even if link's `default` then sets `discharge_source: wet`. Distinguish "the parent path exists and the leaf is absent" from "the path does not exist": require `y[["pipeline"]]` to be a list before reading `unset`.

- **[fragile]** `R/settings_register.R:68-77` (`code:` kind, `>= 1` occurrence). The check passes while any one copy of a literal survives. `dist_offset` names `R/tune_curve.R`'s `dist_cap_m), dist_cap_m) + 10)` (line 78), but the same `+ 10` offset is also at lines 158, 177 and 178 of that file (`log(dist_cap_m + 10)`, `log(thr_dist + 10)`, `exp(x) - 10`). Changing any of those leaves the register green. A fixed-string match also counts an occurrence inside a comment.

- **[claim]** `data-raw/vignette_method.R:16-17`, header comment: it says "each rearing key's last count must equal its summary's `visits_in` and its default rule's scored visits, or the script stops". Only `visits_in` is checked (line 189). `scored` is the tune table's `n_visits`, the visits in groups with both outcomes (`.tune_modelled()`), and is lower by design (CH 7,123 vs 4,490). The comment states a guard that does not exist, and one that would always fire.

- **[claim]** `inst/method/settings.csv` row `prior_sd` (`tested = no`) against the article's definition at `vignettes/_tuning_method.Rmd:224-225` ("**Tested** says whether the result has been compared with another value"). The row's own note says it was "compared with no prior (#84)", and `research/habitat_thresholds_tuned.md` §grades reports what the prior moved (steelhead's curve 860.8 → 553.8 held-out). No prior (SD = Inf) is another value. So "2 have been tested against an alternative; the rest are the list of what to test next" (line 60) undercounts, or the definition needs "another finite SD". `fit = fe` (#83) may be the same case; I did not trace it.

- **[claim]** `research/habitat_thresholds_tuned.md` (Evidence): "link breaks its streams at bcfishobs observations (`lnk_pipeline_break()`), about half of them FDIS's own". link's `observations_breaks` are species-filtered (`lnk_pipeline_break.R`, line 23 of its roxygen). For the 11 species this repo tunes, 60,098 of 212,059 `bcfishobs.observations` rows carry an FDIS `fshclctn_id` (28 %). Across all species it is 163,743 of 375,962 (44 %), which is where `knw_bcfishobs_match()`'s roxygen "about half" comes from (read-only query, 2026-10-26). "About a quarter of them, for the species link models" is what the data support.

- **[claim, minor]** `research/modelled_discharge.md` header: "build ... from wet `94deeb5`, v0.4.14 ... wet's ... `NEWS.md`" at that commit. `94deeb5` is a #103 branch commit whose `DESCRIPTION` reads 0.4.13. The 11.5 % / 15.8 % figures quoted in the body are not in `NEWS.md` at `94deeb5`; they first appear in the v0.4.14 release entry (`42c3da7`, a descendant). Say "the build at `94deeb5`, released as v0.4.14" and cite the NEWS at the tag.

## Checked and holding (no finding)

- The funnel recomputation reproduces `knw_tune_run()`'s population: same stream/area base, `in_range %in% TRUE & status != "blocked"`, then `barrier_dnstr_<sp> %in% FALSE`. Its count equals `visits_in` for every rearing key.
- The ledger arithmetic holds: 51,587 − 1,563 − 5,242 − 1,088 − 23 − 1,353 − 275 − 1,491 = 40,552.
- No usable UTM 1,037 and no stream within 500 m 526: correct.
- The flow split is correct: 34,991 routed and 5,561 balance (86.3 / 13.7 %), with no NA.
- The DB query confirms 222,906 balance picks that have a routed value, every one of them under 0.2 of the balance, and the `pcic_routed` period of 1981–2010.
- The wet MAE figures (24.2 / 27.6 / 13.1 / 18.0 / 23.0) match `data/checks/pcic_routed_compare_20260717.txt` at `94deeb5`, and `routed_far_low <- 0.2` matches too.
- At link `102762da`, `default` sets no `discharge_source` and `default_tuned` sets `wet`. The bridge values (10000, 0.05) match.
- `fwa_gradient` comes from the snapped line (`knw_link_flow(v$linear_feature_id)`), and `frs_col_generate()` recomputes gradient from the piece's ends.
- Every function named in `pipeline.csv` exists (knowledge internals, and the fresh, link and wet exports).
- pkgdown 2.2.0 drops `^_` vignettes (`package_vignettes()`). The CI draft gate fires on a present page and passes on an absent one.
- The register tests skip under `R CMD check`, because `scripts/` is build-ignored, and the `fn:` and region tests still run there.
- The fwapg fork PR numbers resolve to the crosswalk PRs.
