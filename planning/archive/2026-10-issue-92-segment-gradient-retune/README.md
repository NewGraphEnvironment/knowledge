## Outcome

The tuning now scores each visit on the gradient of the link segment it sits on (`segment_gradient`), the one link
applies a rule to and the grade reads, instead of the whole Freshwater Atlas line's. The gradient column is passed
through `knw_tune_run(cols = )`, kept in the score cache's spec, and recorded on every grade table and summary
(`curve_grad`), which `0320`, `0325`, `0330` and the article scripts hold each table to. Every key was retuned,
regraded and recompared on #91's evidence (`fresh_default_20261017`), and the Atlas gradient scored on every key as a
sensitivity (`data/tune/grad_fwa/`). The first measurement changed the framing: link cuts a stream at each bcfishobs
observation, so the segment at a visit, and its length, depend on the catch; the method says so and #70's fixed windows
test it. `research/habitat_thresholds_tuned.md` is the durable record of the result, the methodology article
(`vignettes/habitat_thresholds.Rmd`) carries the method.

## Measurement

- The segment at a visit (`data-raw/segment_gradient_check.R`): on the tuning's stream branch 86.2 % of visits with fish
  start a segment of their own against 10.2 % of empty ones; median segment 113 m against 305 m. The gap from the Atlas
  line's gradient does not follow the catch (median 0.0083 either way), but by species' own outcome it is smaller where
  present for CO, GR, ST and WCT. link's gradient breaks are its access classes only; segment gradients do not bunch at
  `default`'s cut-offs.
- Retune: `0320` 130.3 min (2026-10-27, 3:13 to 5:24 PM PDT), every key's smoke gates passed; the Atlas sensitivity
  12.0 min. `default` is outside the one-SE region for every key, grayling included (inside on #73's run). Steelhead
  and bull trout spawning pass the grade gate (by 32.8 and 8.0); coho and westslope cutthroat stay withheld; bull trout
  spawning's pick does no better than no rule on held-out folds (424.8 against 424.6). Of the seven fitted keys (WCT is
  underpowered), the pick is in the Atlas gradient's one-SE region for six (not coho), and the Atlas pick in the main
  region for four.
- Comparison: `0330` from a machine on a remote link, 466.1 min, of which 269.1 comparing and 196.9 writing the
  GeoPackages (14.0 min on the database's host, 2026-10-26). The answer to "why not run it elsewhere" was measured: no
  other database holds the build. This moved #81 to make the GeoPackages opt-in, and CLAUDE.md to say a run off the
  host passes `GPKG=FALSE`. On link's segments the picks draw less rearing habitat than `default` for five of seven
  rearing keys (−2.3 % CO to −27.0 % ST), more for GR (+3.4 %) and WCT (+18.0 %), and +49.5 % for BT spawning.
- Wrong turns kept in `progress.md`: the approved order had `0325` before `0330`, but `0325` reads each comparison's
  near-river scope, so `0330` runs first (and `knw_thresholds_table()` now refuses a comparison of another rule than
  the pick); five review rounds found 24 claim and guard defects and no code bugs, several inside earlier fixes, ending
  on an enumeration of the research file's run labels.

## Evidence

`scripts/logs/habitat/20261027_*` (the tune run, its `-grad_fwa` sensitivity, the comparison, the segment gradient
check; `20261027_evidence_build_ledger.csv` is #91's); `data/tune/`, `data/tune/grad_fwa/`, `data/compare/`; this directory's `review-*.md`.

## Owed

- Publish the evidence as `knowledge/fdis/v3` (`0299`) if the merge does not already cover it; check what #91 left.
- Publish #92's Parquet sets (`PUBLISH=TRUE 0325`, from the database's host); `knowledge/thresholds/v1` and
  `knowledge/habitat_grade/v1` are still #73's.
- Make the GeoPackages opt-in in `0330` (#81's task).

Closed by: PR (see `git log`), branch `92-score-rules-on-the-gradient-link-applies`
