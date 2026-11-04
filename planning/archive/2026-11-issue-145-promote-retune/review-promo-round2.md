# Review: promotion of run 20261104_0543 (#145), round 2

## Checklist read

- code-check-python.md: read in full (no Python in this diff).
- code-check.md, `## Mechanisms`: the prose of all fourteen H3s, tables skipped (extracted to a scratch file and read
  whole).
- code-check-r.md, by heading: "A `skip_if_not()` skips only its own `test_that()` block", "Tests that silently do not
  run" (the diff's test pins sit behind `skip_if_not(length(tune_files) > 0)`).
- code-check-shell.md and code-check-spatial.md: no heading names a tool, shape or pattern this diff uses.

## How it was checked

- Round 1's nine fixes (commit 8c14181) read against the tables. #145's side is `data/tune/<key>_{summary,tune}.csv`,
  `data/tune/grad_fwa/`, `data/tune/dev_minimal/`, `data/compare/{compare,checks}.csv` (ALL, `door`). #92's side is
  `git show 3140693:data/{tune,compare}/...`, which is byte-identical to 019259d's.
- `data/tune/dev_default_20261103/` (the DEV run `minimal_network_tuning.md` calls "this run") is identical to the
  promoted tables in every rule's `ddev_best`, region and pick (all seven keys), so that file's numbers hold for the
  promoted run.
- 22 summary statuses: fitted 6 (BT_rear, BT_spawn, CH, CO, GR, ST), underpowered 1 (WCT), not_modelled 3 (KO_spawn,
  RB_rear, RB_spawn), no_response 8 (CH, CM, CO, GR, PK, SK, ST, WCT spawning), no_stream_rule 4 (CM, KO, PK, SK
  rearing). The fixed table rows match.
- `0320`'s missing-column stop is correct. It sits before any scoring, and it writes no `_tune_run` log, so a later
  step cannot read a refused run (the same as the `GRADIENT` stop above it). `not_modelled` is in `.knw_no_fit`, and
  `knw_thresholds_table()` and `0325` treat every status outside fitted/underpowered alike.

## Findings

- **[bug]** research/habitat_thresholds_tuned.md:220-221. "grayling's lower width floor adds 11.1 % (+3.4 %)". The
  tuned rule (`width>=1.5|g<=0.0549|none`) has the same width floor as `default` (`width>=1.5|g<=0.0349|none`). So
  against `default`, every km gained (8,937, none by the exception) comes from the slope limit, 5.49 % against 3.49 %,
  and none from the width floor. The lower floor (2 m on #92's run, 1.5 m now) explains why the gain grew from +3.4 to
  +11.1 %. It does not "add 11.1 %". The sentence credits the slope limit's gain to the width floor.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression: "an attribution widened",
    a causal link checked against the source)

- **[fragile]** research/habitat_thresholds_tuned.md:169-170, added by round 1's fix: "On the Atlas line's gradient
  ... all seven keys pick #92's sensitivity picks again, so these moves come with link's segments, not the scored
  visits." The causal link is an inference the check cannot carry for two of the four moves:
  - Grayling's new pick (`width>=1.5|g<=0.0549`) and bull trout rearing's (`mad>=0.1|g<=0.25`) are exactly #92's
    Atlas-gradient picks. An Atlas reading that already sat at the new value cannot show whether flows or range would
    move it, so its being unchanged is no evidence about them.
  - An unchanged Atlas pick does not rule out flows that move a pick only together with the segment gradient.
  - It contradicts the sibling file. `minimal_network_tuning.md:131-132` says grayling's move "comes from the flows, the
    range or link's build, not the network", because the minimal and the full network both pick it. Read side by side,
    the two files attribute grayling's move to opposite causes.

  Separately, the scored visits are identical between the runs (the same `n_visits`, detections and groups for all
  seven keys), so the range cannot have moved any pick, though the minimal-network sentence still names it.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (any sentence that gained a causal link is
    unsupported until the source is checked; a fix reproduces the defect one axis over)

- **[fragile]** research/README.md:28 (round 1's fix to this row). "each of the seven picks #92 published stays in
  both regions": #92 published eight picks (RB rearing included: the old 1.96 pins in `test-tune_repick.R` list
  eight keys). The research file says "seven picks #92 published *that both tunings scored*". The fix dropped that
  qualifier, so the row's count is wrong.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression drops the condition that made
    it true)

- **[fragile]** research/habitat_thresholds_tuned.md:172-177. The nested-selection bullet lists who beats `default`
  (BT rearing, CH, CO) and who loses to it (GR, ST), "as on #92's", then two flips. Bull trout spawning's choosing
  beats `default` on both runs (420.8 against 425.1; #92's 424.8 against 425.2), and the bullet never says so. Its
  flip sentence mentions only no rule. The list reads as complete. It is the same class as round 1's WCT omission,
  one key over.
  - **Rule:** writing.md "When explaining a decision, list every check and the way it points"

- **[fragile]** R/tune_promote.R:258. "(R/tune_run.R's three statuses)" sits beside `.knw_no_fit`, which now holds
  four. Round 1 flagged the stale count at :104. The fix updated :104 and left this second copy of the same count in
  the same function. It is only a comment, but it misstates which keys `unfit_files()` covers, and `not_modelled` is
  the status this branch exists to retire.
  - **Rule:** code-check.md "Written data outlives the fix" (enumerate every artifact quoting a changed value)

- **[fragile]** research/baseline_anchoring.md:6, 20, 95-96, 101 and 106, and research/README.md:29 (not in the
  diff). Each calls #92's tables "the published tables". The promotion makes #145's the published tables, and the
  numbers differ:
  - the file says grayling's `default` is 19.3 behind (SE 6.7) "published"; on #145's tables it is 15.7 (SE 13.5);
  - the file says "four of eight picks" are the best; #145 has seven keys.

  Line 44 alone anchors "(link's full network, #92)". The Status line and the grayling "before" table that #140 reads
  do not. This is the class of round 1's README:28 finding, one file over.
  - **Rule:** code-check.md "Written data outlives the fix"

## Mechanism behind round 1's prose findings

Seven of round 1's nine findings were prose. They share one mechanism: **a reference that the promotion moved, with no
check that the sentences pointing at it still hold.** "Published", "the same as #92's", "every", "their keys" and "the
least steady" were each true of a population that the promotion or the new run changed:
- "published" names a different run after a promotion;
- RB's retirement moved the key count and the status sets;
- the new picks moved which comparisons are reshuffles.

The fixes were made sentence by sentence, so the defect recurs one axis over. A count that the fix dropped
(README:28's "both tunings scored"), a second copy of a count (tune_promote.R:258), a causal clause added to explain a
corrected list (habitat_thresholds_tuned.md:169-170), and a "published" in a file the sweep did not open
(baseline_anchoring.md) are all the same mechanism. What terminates it is the enumeration below, together with
`grep -rn "published" research/` read for referent rather than for text.

## Enumeration: every quantified or comparative claim in the diff's prose

Verdicts: OK = matches the source named; FINDING = above; UNVERIFIED = needs the database or a source outside the
repo.

### research/habitat_thresholds_tuned.md, summary (lines 45-58)

| claim | source | verdict |
|---|---|---|
| link's current test is not among the regions for any species | `default_in_region` FALSE ×7 | OK |
| less habitat for four of the six rearing keys (BT, CH, CO, ST) | compare ALL door: −23.5, −14.1, −3.2, −24.6 | OK |
| from 3 % less (coho) to 25 % less (steelhead) | −3.2, −24.6 | OK |
| more for grayling (11 %) and WCT (19 %) | +11.1, +19.1 | OK |
| a quarter more for BT spawning (24 %) | +23.8 | OK |
| no grade for CO, WCT and BT spawning | `grade_withheld` TRUE for exactly those three | OK |

### research/habitat_thresholds_tuned.md, the #145 section

| claim | source | verdict |
|---|---|---|
| link 0.78.2, all 241 groups, run `20261103_163715-269b585a` | `20261103_link_settle.csv` (round 1); `run_uid` in summaries | OK |
| each key scores as many visits as on #92's run | `n_visits` identical ×7 (detections and groups too) | OK |
| what the visits read moved with the segments, range and flow load | scored set identical, so range moved no scored visit | imprecise (see finding 2) |
| RB's and KO's access columns are empty on every segment | evidence: 0320 log and the task plan; segments need the DB | UNVERIFIED here (visits: OK) |
| RB keys and KO spawning `not_modelled`; KO rearing `no_stream_rule` | summaries | OK |
| RB's last rule `width>=3\|g<=0.3\|none`, in git history and the archive | 019259d's RB_rear_summary; `data/archive_index.csv` rows | OK |
| table: visits (detections), groups ×7 | tune `n_visits`, `n_detect`, `n_wsg` | OK |
| table: recommended rule ×7 | `rule_recommended` | OK |
| table: region sizes and ranges ×7 | `in_region` rows' size and gradient sets; CH all with the exception | OK |
| table: `default` out, ddev and SE ×7 | `default_ddev`, `default_se` | OK |
| table: pick holds in N of 5 seeds ×7 | `seeds_same_rec` + 1 | OK |
| table: #92's pick ×7 | 3140693 summaries | OK |
| table: no-fit rows (3 + 8 + 4 keys) | statuses | OK |
| four picks moved; coho, steelhead and WCT keep #92's rule | rule comparison | OK |
| BT rearing's new pick in #92's region, 2.8 (SE 10.6) | #92 tune row | OK |
| BT spawning, CH and GR outside #92's region: 4.8/2.9, 8.3/4.3, 10.0/5.5 | #92 tune rows, `in_region` FALSE | OK |
| move descriptions (30→25 %, 13→11 % with no exception, 11→13 %, width 2→1.5) | rules | OK |
| Atlas line: all seven keys pick #92's sensitivity picks | grad_fwa summaries, new against 3140693 | OK |
| "so these moves come with link's segments, not the scored visits" | inference | FINDING |
| `default` outside every region; GR narrowest, 1.16 SEs against 2.87 | ddev/se ×7 both runs | OK |
| nested: beats `default` for BT rear, CH, CO | honest sums | OK, but incomplete (FINDING: BT spawning) |
| nested: loses for GR (915.3 / 902.2) and ST (427.9 / 399.0), as on #92's | honest; #92's 916.9/904.3 and 416.3/403.0 | OK |
| two keys flip: BT spawning (420.8 / 424.6); WCT (1,446.5 / 1,442.6, 1,431.3; #92's 1,428.1 / 1,444.9, 1,431.3) | honest, both runs; no other relation flips | OK |
| 1.96 table: SEs behind, picks at 1 and 1.96, flow start, region counts ×7 | summaries; `knw_tune_repick` pins; counts recomputed | OK |
| four of seven keep `default` at 1.96 (BT spawning, GR, ST, WCT) | `is_default` rules | OK |
| each 1.96 region holds most of the grid | 7,021/7,095, 6,680/7,740, 6,678/7,224, 7,211/7,224 | OK |
| CH does not move at 1.96; BT rearing back to 10.49 % with its flow floor; CO to `default`'s width and limit with a nearer exception | summaries | OK |
| four keys pass the gate, with each curve/null pair | `dev_curve`, `null_heldout_curve` | OK |
| CO, WCT withheld as on #92's; BT spawning 404.4 / 403.9, #92's passed by 8.0 | both runs | OK |
| the grade log named | file tracked | OK |
| on link's segments: accessible, `default`, tuned, change, lost, gained (exception), graded km ×7 | compare ALL door | OK |
| BT spawning +23.8 against #92's +49.5; limit 13→11 and the exception lost | compare both runs | OK |
| CH −14.1 (−15.9 on #92's) | compare | OK |
| "grayling's lower width floor adds 11.1 % (+3.4 %)" | rules: same floor as `default` | FINDING |
| FDIS detection rates, `default` then tuned ×6 | checks `fdis_visits` | OK |
| bcfishobs ratios ×7, with rise, level and fall | checks `bcfishobs_outside` lift | OK |
| maps and floodplain not redrawn; RB maps and rows removed | 91ae2f5 stat: 24 RB pngs, 69 floodplain rows; no other fig touched | OK |
| section headers "(#92's run)" | label only | OK |

### research/README.md, the two edited rows

| claim | verdict |
|---|---|
| habitat row: `default` outside the one-SE region for every fitted key | OK (WCT, underpowered, is out too) |
| habitat row: no grade for CO, WCT and BT spawning | OK |
| habitat row: first results section is #145's, the rest #92's | OK |
| minimal row: the network alone moves four of seven picks | OK (BT rear, BT spawn, CH, ST) |
| minimal row: three outside the other network's region (BT rear, BT spawn, CH) | OK (BT rear's minimal pick 80.8/73.2 out of the full region; BT spawn 7.1/5.1 and CH 10.4/7.3 out of the minimal region; ST in both) |
| minimal row: "each of the seven picks #92 published stays in both regions" | FINDING (eight published; seven scored by both) |
| rainbow row: retired on the 2026-11-03 build | OK |

### research/rainbow_rearing_tuned.md

| claim | verdict |
|---|---|
| access column empty on every segment | UNVERIFIED here (DB); the visits agree (0320 `not_modelled`) |
| `data/thresholds.csv` carries `RB_rear_v1` as `not_modelled` with no values | OK (line 31) |
| tables and comparison in git history and the bucket archive | OK (`archive_index.csv` RB_rear rows) |
| #145 removed the floodplain rows and maps | OK |

### research/minimal_network_tuning.md, the edits

| claim | verdict |
|---|---|
| the full-network run was graded, compared and promoted as `20261104_0543` | OK in substance: a fresh full run, whose tables equal the DEV run's cell for cell |
| table header "#92's pick (published until 2026-11-04)" | OK |
| CH 9 % minimal, 11 % #92's, 13 % new full | OK |
| each of the seven #92 picks both tunings scored lies in both new regions | OK (all 7 in both; recomputed) |
| grayling's move "comes from the flows, the range or link's build, not the network" | the range part is wrong (scored set identical); it conflicts with habitat_thresholds_tuned.md:170 (FINDING 2) |
| RB modelled by neither build; the promotion retired it | OK |

### CLAUDE.md, the two passages

| claim | verdict |
|---|---|
| #145's build carries link#326 and link#396 | OK (link 0.78.2 > 0.69.0; round 1's settle check) |
| 44.2 % against 6.6 %, medians 305 m and 466 m, on the stream branch | OK (`20261103_segment_gradient_check-derived_default_20261103.txt`, "by catch (stream branch)") |
| minimal and published builds in a database other than #92's; that database holds an empty `fresh_default_minimal`; flow loads 2026-10-24 and 2026-10-19 | UNVERIFIED here (DB); consistent with the summaries' `run_uid` and the ledger |

### vignettes (the edited sentences)

| claim | guard | verdict |
|---|---|---|
| chinook: "many nearby rules fit almost as well (below)" | region 169 rules | OK |
| chinook: at 1.96 the choice stays the same (three places) | `ch196$rule == rec$rule`, `n_region > nrow(region)` | OK |
| chinook: "the shape is steady, the slope limit is not" (unchanged text, boot shares 1.0 and 0.395) | `boot_mad > 0.9, boot_grad < 0.5` | OK |
| methodology: a site with fish far more likely to start a segment (44.2 against 6.6) | `at_site_fish > 3 * at_site_zero` | OK |
| methodology: results on the 2026-11-03 build, which carries link#326 and link#396 | ledger md5 pin `200bae29…` | OK |

### Test pins

| pin | verdict |
|---|---|
| `test-tune_repick.R`: 7 tables; the 1.96 picks ×7 | OK (matches `rule_recommended_196` ×7) |
| `test-vignette-data.R`: 7 keys | OK |
| `test-tune_run.R`: `not_modelled` both stages, KO_rear `no_stream_rule`, `NULL` = all | OK (reads the code order) |
