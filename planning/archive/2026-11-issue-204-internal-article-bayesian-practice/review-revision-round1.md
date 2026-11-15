# Review, revision round 1 (#204): `git diff c2a6eda4...HEAD`

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: the prose of every H3 under `## Mechanisms` ("A guard that fails toward pass", "A fixture that cannot
  reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope,
  escape hatches, and remedies", "A fix lands in one of two callers that share a harness", "Restore the bug and prove
  the guard fires", and the opening of "A shared working tree"; the remaining Mechanisms H3s by their index line only),
  plus "An assertion that matches an interpolated value cannot see the claim around it". Other standalone headings not
  read (about 20).
- code-check-r.md: "ggplot2 legends and labels: a key for an unused factor level, and ggrepel labels that must avoid
  each other", "A `data-raw/` script must load the source tree, not the installed package", "`vapply(...,
  USE.NAMES = FALSE)` strips ALL dimnames, row names included", "`$` on a list partial-matches, so a longer sibling key
  answers for a missing one". About 115 headings not read (no tool or shape in the diff).
- code-check-shell.md, code-check-spatial.md: no heading read; the diff uses no shell, sed, git plumbing, terra, sf or
  GDAL.

Method: read every changed file in full; read `method.rds$scope` and `cut_points.rds` (`premise`, `setups`); rendered
the article in a detached worktree (`pkgload::load_all()` + `rmarkdown::render()`, every `stopifnot()` passed) and
looked at the four figures; compared `knw_tune_run()` before and after the refactor line by line (equivalent: same
filters, same order, the no-response return carries the same pre-response `d`); checked `vignette_method.R`'s spawner
call against `scripts/0320-tune-run.R:322-325` (identical); checked the stream-splits article, issue #120's body,
`R/grade_species.R` and `scripts/0336-archive.R` for the new prose's claims.

## Findings

- **[bug]** vignettes/tuning-bayesian-practice.Rmd:394-399 (with 371-373, 443, 413-414) — the `#cuts` section credits
  the move in chinook rearing's slope limit (13 % published, 9 % minimal and parent) to the cuts at fish records ("A
  predictor should not be shaped by the outcome ... It moves the result."). The minimal network also leaves out the
  cuts at crossings and at hand-mapped habitat ends, and the two tunings are on different link builds (0.78.2 and
  0.78.1). The stream-splits article says outright that "these runs cannot say which of the three moved the limit"
  (`vignettes/tuning-stream-splits.Rmd:568-569`), and #120's body says the same ("cannot be pinned on one break
  source"). The network descriptions around it are also wrong by the code's definition: line 371-373 ("cuts only where
  a species' access changes"), the glossary at 443 ("cut only where a species' access changes, not at fish records")
  and the next-steps bullet at 413-414 ("segments cut only where access changes"). Both of link's networks also cut
  where one Atlas line meets the next (`tuning-stream-splits.Rmd:343`), and the minimal network's other differences
  (no crossing or hand-mapped-habitat cuts) go unmentioned, so the reader reads the 13 % to 9 % move as the effect of
  catch-dependent cuts alone. No `stopifnot()` can cover this; the wording has to name the three cut sources the
  minimal network leaves out, and say the move is not attributed to one of them. Separately, the next-steps bullet
  presents "every species and stage scored on segments cut only where access changes" as future work. #120 has already
  scored every key on the minimal network (candidate `20261103_0838`, not promoted). What is still to come is the
  parent setup beyond chinook rearing, and a decision.
  - **Rule:** code-check.md, "A proxy is not the property" (a sentence describing a figure makes a claim about the
    criterion the figure only stands in for)

- **[fragile]** vignettes/tuning-bayesian-practice.Rmd:370-371 and the guard at 79 — the prose says the published
  build "narrows the gap without closing it", where the gap is the difference between visits with fish and empty ones
  (86.2 % against 10.2 % on the earlier build, 44.2 % against 6.6 % on the published one). The guard checks only that
  the share for visits with fish fell (`at_site("published_92", "fish") > at_site("published_145", "fish")`), and its
  comment states that narrower claim ("less often than on the earlier build"). If the fish share falls while the empty
  share falls further, the gap widens and the build still passes. The guard should compare the two differences.
  The same sentence also credits the narrowing to the build "that cuts only at the highest" record. Between link 0.66.0
  and 0.78.2 link also stopped cutting gradient breaks except where a present species' access changes (link#326,
  0.69.0, per CLAUDE.md). That change moves the share for empty visits too (10.2 % to 6.6 %), so the narrowing is not
  the highest-record change's alone.
  - **Rule:** code-check.md, "An assertion that matches an interpolated value cannot see the claim around it" (the
    guard pins a neighbouring value, not the sentence's claim)

- **[fragile]** data-raw/vignette_method.R:513-516, 553 — the methodology bundle now reads `data/fdis/build/fish.rds`
  and pins its md5 in `meta$md5_local`. `scripts/0336-archive.R` archives and restores only
  `data/fdis/build/{reconcile.csv,sites.rds}` from the build (its header at lines 28-29). CLAUDE.md tells a checkout
  without the ignored evidence to restore it with `PULL=TRUE scripts/0336-archive.R`. After that restore,
  `vignette_method.R` now stops at `readRDS(f_fish)`, so a promotion's last step (`0335` reruns it) cannot run on a
  restored checkout. And `test-vignette-data.R`'s md5_local check fails wherever a `fish.rds` from another `0230` run
  sits, with no archived copy to restore the one the bundle names. Before this change the bundle needed nothing from
  `data/fdis/build` beyond what the archive holds. Either archive `fish.rds` with the build or say in CLAUDE.md that it
  is not restorable.
  - **Rule:** code-check.md, "A guard's scope, escape hatches, and remedies" (a remedy that no longer covers every
    input it is offered for)

- **[fragile]** vignettes/tuning-bayesian-practice.Rmd:314-315 — "Grades are still drawn for every stream the species
  can reach, in the dropped groups too." The grade is drawn only for accessible segments that have a gradient and a
  size (`R/grade_species.R:106`; the article's own line 141 says "every stream the species can reach that has a size
  and a slope"). The groups half holds, since 0320 grades every group in `streams_habitat_<sp>`. Read alone, the
  sentence overstates the coverage.
  - **Rule:** none

Checked and holding: every rendered number (111/45/65/1, 0.3 % and 20 %, about 12, 0.6 by deviance, 9 % and 13 %, the
four keys over half dropped, the three keys withheld) against the bundles; each quantifier ("every species and stage
... outnumber", "more than half", "about as often", "again", "withholds") against its guard; the figure captions against
the rendered figures (stack order, the dodge direction of bars and labels, the sign side of the publishing test, the
dotted lines at three scales); the `#gate` to `#publishing-test` anchor rename (nothing links `#gate`); and
`vignette_method.R`'s reproduction of the summaries' `groups` and `groups_both`, which stops on a mismatch.
