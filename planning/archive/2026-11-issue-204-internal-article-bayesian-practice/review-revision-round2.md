# Review, revision round 2 (#204): `git diff c2a6eda4...HEAD`

## Checklist read

- code-check-python.md: index read in full (nothing in the diff is Python).
- code-check.md: the prose of every H3 under `## Mechanisms` from "A guard that fails toward pass" through "A guard's
  scope, escape hatches, and remedies" in full; the rest by index line. Plus "An assertion that matches an interpolated
  value cannot see the claim around it".
- code-check-r.md: "`vapply(..., USE.NAMES = FALSE)` strips ALL dimnames, row names included", "ggplot2 legends and
  labels: a key for an unused factor level, and ggrepel labels that must avoid each other", "A `data-raw/` script must
  load the source tree, not the installed package". Other headings by index line only (no tool or shape in the diff).
- code-check-shell.md, code-check-spatial.md: no heading read; the diff uses no shell, git plumbing, sf, terra or GDAL.

Method: read every changed file in full; read `method.rds$scope` and `cut_points.rds` (`premise`, `setups`); rendered
the article in a detached worktree at HEAD (`pkgload::load_all()` + `rmarkdown::render()`, every `stopifnot()` passed,
worktree removed); compared `knw_tune_run()`'s population block before and after the refactor (same filters, order and
no-response return; `st` and `bcol` now computed after the `no_stream_rule` and `not_modelled` exits, which do not use
them); checked `vignette_method.R`'s inputs against `scripts/0320-tune-run.R:300-325` (same files, same spawner call,
`edge_stream` and `area_range` from `knw_tune_run()`'s formals as 0320 uses them, `load_all()` unconditional, and the
commit guard covers package code); read issues #120, #186, #203, #70 and #214; checked the network claims against
`vignettes/tuning-stream-splits.Rmd:343-353, 474-476, 568-569`.

## Clean

No issues found.

Round 1's fixes hold:
- The `#cuts` section now names the three cut sources the minimal network leaves out and the earlier build, and says
  the runs cannot attribute the move to the cuts at fish records alone (matches tuning-stream-splits.Rmd:568-569 and
  #120). The parent setup, which runs on the published build, also gives 9 %, so "The network moves the result" holds.
- Network descriptions (prose 374-377, glossary 449-450) match tuning-stream-splits.Rmd:343-346.
- "less often than before, but still several times as often as an empty site" is what the guards at lines 78-79 check
  (44.2 % < 86.2 %; 44.2 % > 3 x 6.6 %), and "among other changes" no longer credits one cause.
- The #120 bullet matches the issue: the minimal candidate `20261103_0838` covers all seven published keys, chinook
  rearing also on the parent setup (`20261105_0436`), none promoted, decision open. RB rearing is not a published key
  (no value in `data/thresholds.csv`), so "every published species and stage" holds.
- "every stream the species can reach that has a size and a slope" matches `R/grade_species.R:106`.

Numbers checked against the bundles: 111 / 45 / 65 / 1 (sum identity guarded); none > all in all seven keys; the four
keys under half kept (BT spawn 22/50, CH 45/111, ST 11/78, WCT 6/14); withheld BT spawn (-0.56), CO (-58.1), WCT
(-106.3), the caption's sign side and `identical(grade_withheld, margin <= 0)`; 0.3 % and 20 %; about 12; 9 % / 13 % /
9 %. The groups figure's `n >= 4` label subset cannot misplace a stacked label while `all(groups_none > groups_all)`
holds (only the outermost "every site caught" segment can fall below 4 without the inner ones), so it is not fragile.
#186, #203 and #70 bullets match their issue bodies. No stale references to the old title or the `#gate` anchor remain.
