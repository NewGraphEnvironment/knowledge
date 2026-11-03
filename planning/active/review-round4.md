# Review round 4: minimal-network province write-up (#120)

Branch `120-minimal-network-province`, base de9924c, HEAD 3729c6a. Read-only review: no R, no database. Scope: round 3's
four fixed rows (`round3_fix.diff`), the live issue body's edited sentence, every new claim the fixes introduced, and a
re-walk of round 3's table for verdicts the fixes could have moved.

## Checklist read

- Index in full (`codecheck.FK41vW/index.md`, 1,004 lines: every heading and first sentence of `code-check-python.md`,
  `-r.md`, `-shell.md`, `-spatial.md` and `code-check.md`).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (table rows skipped), all fourteen. The ones that bear
  here: "A guard's scope, escape hatches, and remedies" (compression runs both ways; a restatement names its
  population six ways; terminate by enumeration), "One fact derived twice" (derive a figure from every artifact it
  names) and "The probe is broken before the world is" (narrow rather than widen; write the numbers last).
- No code changed on this branch (prose, CSV rows, run logs), so no `-r`, `-shell`, `-spatial` or `-python` rule past
  its index line applies.
- Repo `CLAUDE.md` (public discipline; the accepted items in the brief).

## Sources

`data/tune/candidate/20261103_0838/*_summary.csv` (18 files, `status`), `*_grades_record.csv` (7), `R/tune_run.R`
(roxygen :16-18 and :76-78, status assignment :150-184 and :265-266), `R/thresholds_table.R:85`,
`R/tune_promote.R:107`, `minimal_network_120/20261103_compare_console.log`; link at `193cb8aa`
(`git show 193cb8aa:R/lnk_pipeline_prepare.R`: `.lnk_classes_bcfp` :156-161, `.lnk_resolve_classes()` :171-178,
`.lnk_pipeline_prep_minimal()` :648-818; `configs/default_minimal/config.yaml` (`extends: default`),
`configs/default/config.yaml` (`gradient_classes` commented out), `configs/default/parameters_fresh.csv`,
`configs/dictionary_parameters_fresh.csv`, `inst/extdata/vocabulary.csv` row `cut-min`); the evidence ledger's token
`cut-min.acc-v5.grad-seg.q-fwapg`; every committed log matching `20261103*` or under `minimal_network_120/` grepped for
`round trip`; `scripts/logs/habitat/20261103_site_gradient_check.txt` and `20261030_site_gradient_check.txt` (flip
table and stream-branch correlations); `data/thresholds.csv`; the live issue body.

## 1. Round 3's four fixed rows

| file:line | new wording | source checked | verdict |
|---|---|---|---|
| research:8 | "the seven keys fitted (six species; the other eleven keys have no response or no stream rule)" | 18 summaries: `fitted` BT_rear, BT_spawn, CH_rear, CO_rear, GR_rear, ST_rear (6); `underpowered` WCT_rear (1); `no_stream_rule` CM_rear, PK_rear, SK_rear (3); `no_response` CH, CM, CO, GR, PK, SK, ST, WCT spawn (8); none `too_few_groups` or `curve_failed`. `R/tune_run.R:18` "A species × stage with fewer than `power_wsg` groups is fitted and labelled `underpowered`"; :266 assigns `underpowered` only on the fitted path; `thresholds_table.R:85` and `tune_promote.R:107` treat `fitted` and `underpowered` together; the compare log reads "7 fitted species x stage"; 7 grade records | **holds**: fitted = 7 by the code's own definition (WCT included), 18 − 7 = 11, and those 11 are exactly 3 `no_stream_rule` + 8 `no_response` |
| research:59 | "round trip 0.8 to 1.1 ms" | every `round trip` line in committed 2026-11-03 logs: evidence ledger :13 and `20261103_evidence_build.log` :1/:23 0.9; `20261103_compare_console.log:7` 0.8; grading run log :7 and `20261103_tune_run_console.log:7` 1.1. The DEV run (`20261103_tune_run-…-dev.txt`, `20261103_dev_minimal_console.log`) connects to no database and logs none; the wet load, archive and check consoles log none | **holds**: min 0.8, max 1.1 over every logged measurement |
| research:112-113 | "for each species link models, at every class (0.15, 0.20, 0.25, 0.30) at or above the steepest gradient that species passes (`.lnk_pipeline_prep_minimal()`)" | `.lnk_pipeline_prep_minimal()` loops over species present in the group, `classes_for_sp <- classes[classes >= sp_amax]`; `classes` resolves caller → `cfg$pipeline$gradient_classes` → `.lnk_classes_bcfp` (0.15, 0.20, 0.25, 0.30); `default_minimal` extends `default`, whose `gradient_classes` is commented out; the `cut-min` token in the ledger is defined as `gradient_classes=1500:0.15,2000:0.2,2500:0.25,3000:0.3`, so no orphan class below every maximum enters. Maxima of the nine species: 0.15 (CH, CM, CO, GR, PK, SK), 0.20 (ST, WCT), 0.25 (BT). link's dictionary defines `access_gradient_max` as "Maximum stream gradient the species can ascend" and a class blocks when `class_value >= access_gradient_max` | **holds**: 0.30 is cut for every species; "steepest gradient that species passes" is link's own definition of the threshold, and "at or above" is the code's `>=` |
| research:70 | per-key flips, minimal against full: BT rear 0.6 (0.8), ST rear 14.2 (17.0), CO rear 25.5 (25.8), GR rear 11.4 (11.7), WCT rear 0.7 (0.7); the other way BT spawn 8.7 (8.5), RB rear 0.8 (0.7); CH 5.9 % of 2,453 (6.4; Atlas 11.6) | both logs' flip tables, `segment_gradient` and `fwa_gradient` rows | **holds**: all 16 figures match; the eight keys are every key with a gradient limit in `data/thresholds.csv` (the log's limits table); exactly two keys are worse on the minimal network; WCT is an exact tie (3 flips of 461 on both: 2 + 1) and is printed as one |
| issue :7 | "at which classes (0.15, 0.20, 0.25 and 0.30, each species cut at every class at or above the steepest gradient it passes)" | as research:112-113 | **holds** |

## 2. New claims the fixes introduced

| # | claim | verdict |
|---|---|---|
| 1 | seven keys "fitted" (status line) | holds (code: underpowered is fitted; compare log "7 fitted") |
| 2 | six species among them | holds (BT, CH, CO, GR, ST, WCT) |
| 3 | "the other eleven keys" | holds (18 summaries − 7) |
| 4 | the eleven "have no response or no stream rule" | holds (8 `no_response`, 3 `no_stream_rule`, nothing else) |
| 5 | round trip lower bound 0.8 ms | holds (compare console) |
| 6 | round trip upper bound 1.1 ms | holds (grading run log and console) |
| 7 | "for each species link models" | holds (per group, the species `lnk_presence()` finds present, which is what link models there) |
| 8 | the class set 0.15, 0.20, 0.25, 0.30 | holds (`.lnk_classes_bcfp`, no config override, `cut-min` token) |
| 9 | "at or above the steepest gradient that species passes" | holds (`>=`, link's dictionary definition) |
| 10 | attribution to `.lnk_pipeline_prep_minimal()` | holds (the selection is at :665) |
| 11 | "Each published limit" covers eight keys | holds (`data/thresholds.csv`: BT_rear, BT_spawn, CH_rear, CO_rear, GR_rear, RB_rear, ST_rear, WCT_rear carry a gradient) |
| 12 | steelhead rearing 14.2 % (17.0) | holds |
| 13 | westslope cutthroat rearing 0.7 % (0.7) | holds |
| 14 | "two the other way": bull trout spawning 8.7 (8.5), rainbow trout rearing 0.8 (0.7) | holds (the only two keys with a higher share on the minimal network) |
| 15 | each key labelled by stage ("bull trout rearing", …) | holds (each figure is the named key's row) |
| 16 | issue :7's class set and rule | holds (as 8 and 9) |

## 3. Re-walk of round 3's table

Every row round 3 marked "holds" was re-read against the post-fix text. No verdict changed:

- research:8 "six species", :9 "rainbow trout and kokanee are paused": unchanged and consistent with the new wording.
- research:27-28 "Of the seven keys fitted on the minimal network": now agrees with the status line (before the fix
  the two named different sets); issue :35 "Of the seven keys fitted on this build" agrees too.
- research:59 the other claims of that sentence (date, `PGSERVICE`, link and fresh versions, wet load): unchanged.
  "All … on the database the minimal build lives in" is loose for the DEV run, which reads evidence from disk and
  connects to nothing; it carries no round trip, so it does not touch the fixed range. Not a finding.
- research:70 correlations 0.678 (0.690; Atlas 0.653 on both) and chinook's 5.9 % (6.4; 11.6): re-verified in both logs.
- research:106-109 "barely moves agreement (0.678 against 0.690)": unchanged.
- research:113 "Cutting at another set is 'minimal, other access classes' (#132)" and the setups table (:147) still
  read correctly beside the new class set; issue :58 likewise.
- Issue :48 "within 0.011 % per key" and research:73 "within 0.02 % per key" both hold (max 0.0108 %); untouched.
- The four rows round 3 failed are now the holds in section 1.

Round 3's four findings were the only rows it failed; with them fixed, the enumeration of every quantified or
set-scoped claim in the CLAUDE.md paragraph, the research file's header, "The answer", "The province run" and "What each
break source does", and the issue body's province and every-setup items, has no false or unsupported row.

## Aside (not on this branch)

`research/minimal_network_tuning.md:154`, the four-group section, says "round trip 1.0 ms" for 2026-11-02, but
`minimal_network_120/20261102_compare-20261102_173001-bt.txt:6` logged 0.9 ms (the other five 2026-11-02 logs: 1.0).
The line dates from 79a9089 and the log from afb1bcb, both before the base de9924c, so this branch did not write it;
"0.9 to 1.0 ms" would hold. The issue body's "a 1 ms round trip" (:21) holds at whole-millisecond precision.

## Findings

Clean.
