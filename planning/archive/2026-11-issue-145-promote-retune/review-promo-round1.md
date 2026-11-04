# Review: promotion of run 20261104_0543 (#145), round 1

## Checklist read

- code-check-python.md: read in full (no Python in this diff).
- code-check.md, `## Mechanisms`: the prose of all fourteen H3s, tables skipped. Also "An assertion that matches an
  interpolated value cannot see the claim around it".
- code-check-r.md, by heading: "`$` on a list partial-matches", "A `skip_if_not()` skips only its own `test_that()`
  block", "Tests that silently do not run", "Moving prose into a code chunk hides it from tools that scan the document".
- code-check-shell.md and code-check-spatial.md: no heading names a tool, shape or pattern this diff uses.

## How it was checked

- Every number in the new section of `research/habitat_thresholds_tuned.md` ("The run promoted on 2026-11-04 (#145)",
  "At 1.96 SE", "Grades", "On link's segments") and its revised summary, recomputed from `data/tune/<key>_summary.csv`,
  `<key>_tune.csv`, `data/compare/compare.csv` (ALL, door), `data/compare/checks.csv` and `data/thresholds.csv`. #92's
  side was read from `git show 3140693:...`. Everything matches except what is listed below: visits, detections,
  groups, region sizes and ranges, `default`'s distance and SE, seed counts, the honest sums, the curve against no rule,
  all km and percentages, FDIS rates, bcfishobs ratios, the 1.96 picks and counts, and grad_fwa's picks (identical to
  #92's for all seven keys).
- CLAUDE.md's 44.2 % / 6.6 % and 305 m / 466 m match
  `scripts/logs/habitat/20261103_segment_gradient_check-derived_default_20261103.txt`; 241 groups and link 0.78.2 match
  `20261103_link_settle.csv`.
- Both articles rendered from a `git archive HEAD` copy in the scratchpad (`pkgload::load_all()` then
  `rmarkdown::render()`, PGHOST=invalid.invalid): every `stopifnot()` passes. `method.rds`'s ledger md5 is
  `200bae29...` (the 2026-11-03 ledger), and `segment_at_site` is 0.442 against 0.066, 305 m against 466 m.
- `test-tune_repick.R` (30 pass), `test-vignette-data.R` (179 pass, 2 skip: no ignored data in the copy),
  `test-tune_run.R` (71), `test-tune_promote.R` (133) and `test-settings-register.R` (272), with NOT_CRAN=true: no
  failures and no errors.

## Findings

- **[bug]** vignettes/chinook_rearing.Rmd:110-111 (the sentence ends on 111). The new sentence "the slope limit is the least steady part (below)"
  is not what the bootstrap shows. In `data/tune/CH_rear_tune.csv`, the recommended flow floor (MAD 0.75) is the pick
  in 33.0 % of draws (`sum(boot_rec_share[size_var == "mad" & size_min == 0.75])`). The recommended slope limit (13 %)
  is the pick in 39.5 %, and the recommended allowance (Q3 within 1 km) in 45.5 %. So the floor's value is less steady
  than the slope limit's. The "below" it points to compares a flow floor of any value (100 % of draws) with the exact
  slope limit (40 %), and the guard `boot_mad > 0.9, boot_grad < 0.5` pins only that comparison, not a superlative
  across the dials. A fix is to say what is measured ("a flow floor is always chosen, the exact slope limit in only
  40 % of draws") or compute and guard every dial's share.
  - **Rule:** code-check.md "A proxy is not the property" (a sentence describing a figure claims the criterion it
    stands in for: compute the share it claims and state it inline), and code-check.md "A guard's scope, escape
    hatches, and remedies" (a sentence that gained a superlative is unsupported until checked)

- **[bug]** research/README.md:28 (the `minimal_network_tuning.md` row, not edited by the diff). It still ends "each
  of the seven published picks both scored stays in both regions". The research file now says this of #92's picks.
  The published picks are now #145's, and `minimal_network_tuning.md` itself says that two of them, bull trout
  spawning (`g<=0.11`, 7.1 behind, SE 5.1) and chinook rearing (13 %, 10.4 behind, SE 7.3), lie outside the minimal
  network's region. Read today, the index row is false. It should say "#92's picks".
  - **Rule:** code-check.md "Written data outlives the fix" (when a derived value changes, enumerate every artifact
    quoting it)

- **[bug]** research/README.md:21 (the `habitat_thresholds_tuned.md` row, which the diff edited). The diff appends
  "Its first results section is #145's run", but the row's description of that table still reads "`default` outside
  the one-SE region for every fitted key but grayling" and "the grade summary per key (none for CO, ST and WCT)". On
  #145's run, `default` is outside every region, grayling's included (1.16 SEs). The grades withheld are CO, WCT and
  BT spawning (`grade_withheld` TRUE in their summaries); ST is graded (398.7 against 432.7). The row was already
  stale for #92's run, but the edit now points it at a section it contradicts.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression runs both ways: re-read the
    source beside the compression)

- **[bug]** research/habitat_thresholds_tuned.md:159-161 (the new table's no-fit rows). The 22 keys are 7 fitted, 3
  `not_modelled`, 8 `no_response` and 4 `no_stream_rule`, but the rows list 7 spawning keys under "no electrofishing
  response" and 3 rearing keys under "no stream rule". So 2 keys are missing:
  - CM spawning (`CM_spawn_summary.csv`: `no_response`) is missing from "CH, CO, GR, ST, WCT, SK, PK spawning";
  - PK rearing (`PK_rear_summary.csv`: `no_stream_rule`) is missing from "KO, SK, CM rearing".

  (#92's rows were off too: they listed CM spawning under "no stream rule", where its status was `no_response`.)
  - **Rule:** code-check.md "One fact derived twice" (enumerate every member against its source)

- **[bug]** research/habitat_thresholds_tuned.md:141-143. "Rainbow trout rearing is retired ... link models neither
  rainbow trout nor kokanee here ... Their keys are `not_modelled` (no fit, no grade)". KO rearing is
  `no_stream_rule`, not `not_modelled` (`KO_rear_summary.csv`, `data/thresholds.csv` `KO_rear_v1`), as the code
  orders it and the table's own row says ("RB rearing and spawning, KO spawning"). The quantifier covers one key too
  many: "three of their keys", or name them.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (quantifiers checked per member)

- **[fragile]** research/habitat_thresholds_tuned.md:163-166 together with :146-148. "How to read a pick" says that a
  move to a rule both runs count in their regions is a reshuffle, not a finding. The bullet that follows ("Four picks
  moved ...") never applies that test. Read against #92's tune tables, three of the four new picks lie outside #92's
  region:
  - BT spawning `width>=2|g<=0.11|none`: 4.8 behind, SE 2.9;
  - CH `g<=0.13`: 8.3 behind, SE 4.3;
  - GR `width>=1.5|g<=0.0549`: 10.0 behind, SE 5.5.

  Only BT rearing's move is a reshuffle (2.8, SE 10.6). Every #92 pick does lie inside #145's region. A reader primed
  by the paragraph will take all four moves for reshuffles.

  The same bullet also says "all within the gradient limit or the size floor", then says that bull trout spawning
  "drops the near-river exception", which is a third dial.
  - **Rule:** writing.md "When explaining a decision, list every check and the way it points"; code-check.md "A guard's
    scope, escape hatches, and remedies" (quantifier)

- **[fragile]** research/habitat_thresholds_tuned.md:168-170. "Nested selection ... beats `default` for BT rearing,
  CH and CO, and loses to it for GR ... and ST ..., as on #92's. Bull trout spawning's choosing now beats no rule ...
  where #92's did not." The bullet leaves out WCT, whose nested selection flipped the other way. On #92's run it beat
  both `default` and no rule (1,428.1 against 1,444.9 and 1,431.3). On #145's it loses to both (1,446.5 against
  1,442.6 and 1,431.3; `WCT_rear_summary.csv`). "as on #92's" plus the one flip named reads as nothing else changed.
  - **Rule:** writing.md "When explaining a decision, list every check and the way it points"

- **[fragile]** scripts/0320-tune-run.R:239-248 with R/tune_promote.R:106 and :427. `modelled` treats a missing
  `access_<sp>` column (`col %in% names(vl)` FALSE) the same as a species link does not model, with only a `say()`
  line. An evidence directory without the columns, or a future rename of them, therefore marks every key
  `not_modelled`. `knw_tune_promote()` passes a `.knw_no_fit` status straight through
  (`if (st %in% .knw_no_fit && is.na(rule)) next`) and replaces each published fitted key with it, which is the
  mechanism that retired RB. Today every evidence directory carries all 11 columns (checked), so this has not
  happened. A missing column is a schema mismatch, not a finding: stop on it, and keep `not_modelled` for a column
  present and all NA. Separately, the comment at R/tune_promote.R:104 still reads "three with no fit by design"
  beside a constant that now holds four.
  - **Rule:** code-check.md "A guard that fails toward pass" (the error path and the "nothing to do" path look the
    same; enumerate the complement)

- **[fragile]** research/minimal_network_tuning.md:133. "Rainbow trout rearing is modelled by neither build and stays
  paused." The same promotion retires it on the full build (`habitat_thresholds_tuned.md`,
  `rainbow_rearing_tuned.md`: "retired", `data/thresholds.csv` `not_modelled`). "Paused" now contradicts the files
  this one points to.
  - **Rule:** code-check.md "Written data outlives the fix"
