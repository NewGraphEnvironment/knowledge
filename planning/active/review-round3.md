# Review round 3: minimal-network province write-up (#120)

Branch `120-minimal-network-province`, base de9924c, HEAD 7b84bbd. Read-only review: no R, no database.

## Checklist read

- Index in full (`codecheck.FK41vW/index.md`).
- `code-check-python.md` in full (7 KB, the only FULL TEXT file under 40,000 bytes).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (table rows skipped). The ones that apply here are
  "A guard's scope, escape hatches, and remedies" (compression runs both ways; a restatement names its population six
  ways; terminate by enumeration), "One fact derived twice" and "The probe is broken before the world is" (when
  flagged, narrow rather than widen).
- `code-check-r.md`, `-shell.md`, `-spatial.md` (each over 40 KB): no heading's index line names a tool, shape or
  pattern this diff uses (the diff is prose, CSV rows and run logs; no code changed), so no section was read past the
  index.
- Repo `CLAUDE.md` ("One discipline: everything here is public"; the R2 accepted items), and the index lines of
  `writing.md` "State each claim by the code's definition" and "Check that each guard covers the set its sentence names".

## The mechanism

All six earlier findings are one shape: **a quantified or set-scoped claim written from memory of a nearby set rather
than from the set's own definition.** "Five keys move one or two steps" was the set of keys that moved, not the set the
number described; "every published rule" was the published set, not the tested set; "tuned, graded and compared" was
the graded set standing in for the tuned set; "the same lake segments" was the TESR set standing in for its lake
subset. Round 3 found the same shape three more times: "keys with a stream rule" written from the set of fitted keys,
"the classes" written from the set of species access maxima, and a round-trip range written from the logs that were
in view rather than all the runs the sentence covers. The fix that ends it is the one used here: derive each set from
its producer (the status the code assigns, link's own class selection, every log the sentence covers).

## Enumeration

Sources: `data/tune/candidate/20261103_0838/` (`*_summary.csv`, `*_tune.csv`, `pick_report.csv`,
`*_grades_record.csv`), `data/tune/*` (published), `data/tune/grad_fwa/CH_rear_tune.csv`,
`data/compare/candidate/20261103_0838/compare.csv` (summed over groups, `ALL` excluded), `data/compare/compare.csv`,
`data/thresholds.csv`, the committed logs, `planning/active/findings.md` (marked "findings"), `R/tune_run.R`,
`R/tune_grid.R`, `scripts/0310-evidence-build.R`, and link's `R/lnk_pipeline_prepare.R` and
`inst/extdata/configs/default/parameters_fresh.csv` (local checkout `552f43d6`).

### CLAUDE.md (new paragraph, lines 426-434)

| file:line | claim | source checked | verdict |
|---|---|---|---|
| CLAUDE.md:426 | minimal build is run `20261102_203300-60ab009d` | settle log, evidence ledger | holds |
| CLAUDE.md:427 | the published database holds a `fresh_default_minimal` with no segments | findings ("Where the inputs are": 0 segments) | holds (findings) |
| CLAUDE.md:428 | each database keeps its own flow load and walk cache | findings; grade records' `discharge_load` (2026-10-19 published, 2026-10-24 candidate) | holds |
| CLAUDE.md:428-429 | minimal build reads wet's 2026-10-24 build; published grades the 2026-10-19 load | `data/tune/CH_rear_grades_record.csv`, candidate record | holds |
| CLAUDE.md:430 | wet's public prefix keeps no older manifest, so the older load exists only where it was loaded | findings (`list-object-versions`: one version) | holds (findings) |
| CLAUDE.md:430 | evidence is `data/fdis/derived_minimal`, ledger tagged `-derived_minimal` | ledger name and its `evidence_dir` row | holds |
| CLAUDE.md:431 | `0310` reads range from the installed link's `default` presence table, not the schema | `scripts/0310-evidence-build.R:195-215` (`lnk_config("default")`, `lnk_load_overrides()`) | holds |
| CLAUDE.md:432-433 | link#402's review moved 12,083 visit × species rows between link 0.66.0 and 0.78.1 | minimal_network_check console ("rows in one alone: 12083"); ledgers' `link_version` 0.66.0 / 0.78.1; gains+losses per species in the two ledgers sum to 12,083; every commit touching link's default presence/pooling files between v0.66.0 and v0.78.1 is #402's | holds |

### research/minimal_network_tuning.md, header and "The answer" (lines 3-55)

| file:line | claim | source checked | verdict |
|---|---|---|---|
| :7-8 | "the nine species link models on the minimal build tuned on it" | ledger `schema_species` (9 modelled, KO and RB paused); 18 summaries | holds |
| :8 | "the seven keys with a stream rule (six species; chum, pink and sockeye have none) graded and compared" | candidate summaries' `status`; `R/tune_run.R:150-170`, `R/tune_grid.R:67` | **false**: 15 keys have a stream rule; only CM, PK and SK rearing are `no_stream_rule`. The eight other spawning keys (CH, CM, CO, GR, PK, SK, ST, WCT) are `no_response`, a status `knw_tune_run()` reaches only after the grid is non-empty. Chum, pink and sockeye have spawning stream rules |
| :8 | six species | BT, CH, CO, GR, ST, WCT among the 7 graded keys | holds |
| :9 | rainbow trout and kokanee are paused there | ledger `schema_species` | holds |
| :19 | "On all 241 watershed groups it takes the catch out of the segment" | settle log 241 of 241, token `cut-min` on every record; premise measured pooled | holds (by construction; measured pooled) |
| :23 | full network 86 % / 10 %, 113 m / 305 m | CLAUDE.md (#92's numbers) | holds |
| :24 | minimal 3.4 % / 3.0 %, 717 m / 699 m | `20261103_segment_gradient_check-derived_minimal.txt` | holds |
| :27 | region = within one standard error of the best | `scripts/0320` spec ("the one-SE region") | holds |
| :27-28 | of the seven keys fitted, every published rule is inside its key's region | `pick_report.csv` `published_in_region` TRUE ×7; WCT is fitted and labelled `underpowered` (0320 spec: fitted ≥ 5 groups, labelled under 10) | holds |
| :29 | two keys pick the published rule again | `same_pick` TRUE for CO, WCT | holds |
| :29-30 | CH, GR, ST move one or two steps on one part of the rule | each key's own ladder in `*_tune.csv`: CH g 0.11→0.09 (1), GR width 2→1.5 (1), ST MAD 1→0.5 (2) | holds |
| :30-31 | BT rearing 30 % → 10.5 %, seven steps; MAD four steps up (0.1→0.35) | BT_rear ladder: 0.25, 0.2, 0.15, 0.1349, 0.13, 0.11, 0.1049 (7); MAD 0.15, 0.2, 0.28, 0.35 (4) | holds |
| :31-32 | BT spawning 13 % → 25 %, three steps | BT_spawn ladder 0.15, 0.2, 0.25 | holds |
| :32-33 | rainbow trout rearing has a published rule but is paused, not tested; (link models nine species) | `data/thresholds.csv` (RB rear fitted; KO rear `no_stream_rule`); ledger | holds |
| :37-43 | pick table: picks and ddev / se for 7 keys | `pick_report.csv` | holds (all 14 figures) |
| :45-48 | three changes at once; 12,083 rows, `in_range` only; link#402 after 0.66.0 | findings; console; link git log | holds |
| :50 | "leaves each published rule it tested standing" | `published_in_region` ×7 | holds |
| :52-53 | CH rearing each on 4,858 visits: 11 % (164 in region), 9 % (102), 15 % (117) | `n_visits` 4858 and `in_region` counts in the three `CH_rear_tune.csv` | holds |
| :54-55 | flow floor MAD ≥ 0.75 and Q3@D1000 hold on all three | the three recommended rules | holds |

### research/minimal_network_tuning.md, "The province run" (lines 57-100)

| file:line | claim | source checked | verdict |
|---|---|---|---|
| :59 | "All on 2026-11-03 UTC" | settle polls 06:53-06:55Z, wet load, 0310, 0320, 0330 times | holds |
| :59 | round trip 0.8 to 0.9 ms | every 2026-11-03 log carrying one: evidence 0.9, compare 0.8, **grading (`0320` run `20261103_0838`, `20261103_tune_run_console.log:7` and the run log :7) 1.1** | **false**: 0.8 to 1.1 ms |
| :60 | link 0.78.1 `193cb8aa`, fresh 0.53.0 installed, build on 0.52.0 | settle log `fresh_version` 0.52.0; segment check log fresh 0.53.0 | holds |
| :60-61 | wet 2026-10-24 (`b4bbc50`), loaded because the database held an older one | findings (2026-10-15 before) | holds (findings) |
| :61-62 | published database keeps the 2026-10-19 load its grades name; two loads one per database | findings; published grade record | holds |
| :66 | settle released after three equal polls, 241 of 241 | settle log (3 rows, same churn, `released`) | holds |
| :67 | 23 min; 45,529 visits, the published build's count; every walk cold, 110,784 pairs, 4.7 min | findings 08:09-08:32; ledgers 45,529 (20261027 and 20261103); evidence log `walk_cache_hit 0`, `walk_starts` note 4.7 | holds |
| :68 | every visit at the same blue line, measure and Atlas line; 172 on a segment keeping another line's id; flow, width and walks read the visit's own line, so nothing the tuning reads moves | console (45,357 of 45,529 on one Atlas line *by the segment's id*); findings; `0310` joins `knw_link_flow` and `knw_link_width` on the visit's `linear_feature_id` | holds (findings + code) |
| :69 | by each species' own outcome 0 to 5.6 % either way | segment check log, species table (0.0 to 5.6) | holds |
| :70 | 16,279 visits; 0.678 (0.690; Atlas 0.653 on both) | both site gradient logs | holds |
| :70 | CH 5.9 % of 2,453 (6.4; Atlas 11.6); bull trout 0.6 (0.8); coho 25.5 (25.8); grayling 11.4 (11.7) | both logs' flip tables | holds for the keys listed, but **"bull trout" is bull trout rearing only**: bull trout spawning flips 8.7 % against 8.5 %, the one key that moves the other way (ST 14.2 against 17.0, WCT 0.7 against 0.7 are also unlisted) - unsupported as a species claim |
| :71 | DEV tuning 5.4 min on 14 workers; every smoke gate passed | findings 08:32:53-08:38:19 (the log prints "Done in 5.3 min"); 56 `: pass`, 0 fail | holds |
| :72 | 70.9 min; the same picks; grades withheld for CO and WCT, as on the published run | run log "Done in 70.9 min"; `pick_report.csv` = DEV report; `grade_withheld` in both runs' summaries | holds |
| :72 | 52 to 67 % fewer segments per key; CH 2.65 M against 5.76 M | grade records' `grades_rows` (51.9 % to 66.8 %) | holds |
| :73 | 43.5 min on 6 connections | compare console "Compared 7 species x stage in 43.5 min, each on 6 workers" | holds |
| :73 | regenerated `default` within 0.02 % of stored per key | `compare.csv` `stored_vs_default_differ_km` / `default_km`: max GR 0.0108 % | holds |
| :76 | run's own `compare.csv`, all groups | `ALL` rows | holds |
| :81-87 | default km, tuned km, change, published change for 7 keys | both `compare.csv` (door) | holds (all 28 figures) |
| :89 | 0 km for bull trout spawning | `compare.csv` | holds |
| :89-90 | 0.05 to 9.3 km for the other keys; in one to nine groups each | `compare.csv`: WCT 0.048 (1 group) … CH 9.30, BT 5.98 (9 groups) | holds |
| :90 | chinook 9.3 km of 104,751, 8.5 in TESR | `compare.csv` | holds |
| :90-91 | almost every differing segment is stored rearing the regeneration drops | findings (150 of 154) | holds (findings) |
| :91 | the regenerated predicate passes every one | findings (`rearing_pre_default` TRUE on all) | holds (findings) |
| :92-93 | TESR: CH and GR differ on the same segments, 41 of chinook's 42 | findings (CH 42, GR 41, 41 shared) | holds (findings) |
| :93-94 | 37 of 42 construction lines in lakes (1200, 1450), 5 single-line | findings | holds (findings) |
| :94-96 | ruled out: other-group spawning, access gate (0 km), user habitat, fresh's version | findings; `access_gate_differ_km` 0 for every key | holds |
| :96 | link runs that stage one group at a time, as the comparison does | findings (`lnk_pipeline_connect()` per AOI) | holds (findings) |
| :99-100 | steps 3 to 5 need the published evidence rebuilt per group, which the published build predates | minimal_network_check console ("access_check.csv has no group column: rebuild with 0310 from #120") | holds |

### research/minimal_network_tuning.md, "What each break source does" (lines 102-116)

| file:line | claim | source checked | verdict |
|---|---|---|---|
| :104-106 | full 86 / 10; minimal 3.4 / 3.0; length and gradient no longer depend on the outcome | logs; `cut-min` cuts no fish record (by construction) | holds |
| :106-109 | removing every break but barriers and access gradients barely moves agreement (0.678 against 0.690) | site gradient logs | holds |
| :110-111 | crossings and habitat end points dropped with the fish records | issue #120, link#441 | holds |
| :112-113 | the minimal network cuts access gradients "at the classes of the species link models (0.15, 0.20, 0.25)" | link `R/lnk_pipeline_prepare.R` `.lnk_pipeline_prep_minimal()`: each present species is cut at every class `>= access_gradient_max` from classes 0.15/0.20/0.25/0.30; `parameters_fresh.csv` maxima for the nine species are 0.15, 0.20, 0.25; knowledge's own `data-raw/segment_gradient_check.R:32` lists 0.30 as an access class and the province log tabulates it | **false**: 0.15/0.20/0.25 are the species' access maxima; the classes cut are 0.15, 0.20, 0.25 and 0.30 |
| :114-116 | a full segment given its parent's gradient reads the minimal gradient at every visit (four groups) | four-group section, `20261102_minimal_network_check.txt` | holds |

### Issue body (live), province items and "Chinook rearing on every setup"

| line | claim | source checked | verdict |
|---|---|---|---|
| 34 | wet's 2026-10-24 build loaded in 43.5 min; rows per source unchanged | wet load log ("minutes 43.5", counts); findings before/after | holds |
| 35 | the same 45,529 visits placed, at the same stream and measure | console; ledgers | holds |
| 35 | premise holds province-wide: 3.4 % against 3.0 % (full 86 / 10) | logs | holds |
| 35 | every smoke gate passed | DEV and grading consoles: 56 pass, 0 fail | holds |
| 35 | of the seven keys fitted, every published rule in region, each less than one SE behind | `pick_report.csv` (ddev < se on all 7; WCT 0 / 0) | holds |
| 35 | bull trout's picks move furthest (30 → 10.5 %, 13 → 25 %) | ladders (7 and 3 steps; next is ST at 2) | holds |
| 35 | rainbow trout rearing has a published rule but is paused | `data/thresholds.csv`; ledger | holds |
| 37-45 | pick table | `pick_report.csv` | holds |
| 47 | three ways at once (network, flow load, range); link#402 after 0.66.0 | findings; link git log | holds |
| 48 | every key ran (43.5 min) | compare console: the 7 keys with grades (all `0330` takes) | holds |
| 48 | within 0.011 % per key; BT spawning exactly; CH 9.3 of 104,751, 8.5 in TESR, mostly inside lakes | `compare.csv` (max 0.0108 %); findings (37 of 42 segments) | holds |
| 48 | residue all in the connectivity stage, mostly segments link keeps and the regeneration drops | findings (predicate TRUE and user habitat FALSE on all 154; 150 of 154) | holds (findings) |
| 48 | spawning in another group, access gate, user habitat, fresh's version ruled out | findings | holds |
| 48 | chinook −16.4 % (published −15.9 %) | `compare.csv` both | holds |
| 56 | published setup: link 0.66.0, 2026-10-19 load | published grade record | holds |
| 57 | minimal: done, every key (candidate `20261103_0838`, not promoted) | 18 summaries in the candidate; none promoted | holds |
| 60 | Atlas line scored on the published evidence, CH g ≤ 15 % | `grad_fwa/CH_rear_tune.csv` | holds |
| 63 | "minimal" and "full, parent gradient" read the same gradient at every visit | four-group check (all 2,082 visits) | holds |
| 64 | four groups: 0.696 on both; 8.5 % against 8.7 % | research four-group table (out of this round's logs) | holds (as quoted from round 1-2) |
| 64 | province: 16,279 visits; 0.678 (0.690; Atlas 0.653); CH 5.9 % (6.4; 11.6) | both site gradient logs | holds |
| 64 | the minimal network drops crossings and habitat end points with the catches, on a newer link | settle log 0.78.1 against 0.66.0 | holds |
| 7 (Problem, outside the province items) | "at which classes (0.15, 0.20, 0.25)" | as research :112 | same wording as the false row above |

### Public-repo rule

Tracked files outside `planning/` on this branch (`CLAUDE.md`, the research file, `data/archive_index.csv`, 18 logs)
grepped for home paths, user names, host labels (`m1`, `m4` and the like), `fresh_local`, `.Renviron`, `pgpass`, ssh,
tailnet and port patterns: no hit. The only URLs are the public `fresh-bc` bucket's wet manifest. `~/.pg_service.conf`
in CLAUDE.md is the generic libpq file CLAUDE.md already names. The live issue body: no host, path or credential.
Clean.

## Findings

- **[severity: bug]** research/minimal_network_tuning.md:8 — "the seven keys with a stream rule (six species; chum,
  pink and sockeye have none) graded and compared" is false by the code's own definition. `knw_tune_run()` assigns
  `no_stream_rule` only when the grid is empty (`R/tune_run.R:154-158`, `R/tune_grid.R:67`); in the candidate that
  is CM, PK and SK rearing alone. The other eight spawning keys (CH, CM, CO, GR, PK, SK, ST, WCT) reach `no_response`,
  which comes after the grid check, so they have stream rules and lack a spawner response (only bull trout carries
  one). So 15 keys have a stream rule; the seven graded are the keys with a response and at least five groups holding
  both outcomes, and chum, pink and sockeye have spawning stream rules. The set named is the set of fitted keys,
  the third instance of R1/R2's shape at this one sentence. A wording that holds: "the seven keys fitted (six
  species; the rest have no rearing stream rule (chum, pink, sockeye) or, for spawning, no electrofishing response)".
  (Aside, not on this branch: `research/habitat_thresholds_tuned.md:136` says "CM, PK … no stream rule in
  `default`", which the same summaries contradict for their spawning keys.)
  - **Rule:** writing.md, "State each claim by the code's definition"; code-check.md, "A guard's scope, escape
    hatches, and remedies" (compression adds a claim; terminate by enumeration).
- **[severity: bug]** research/minimal_network_tuning.md:112-113 — "The minimal network still cuts at them, at the
  classes of the species link models (0.15, 0.20, 0.25)". Those three numbers are the nine species' `access_gradient_max`
  values (link `inst/extdata/configs/default/parameters_fresh.csv`). The classes cut are each present species' classes
  at or above its maximum, from 0.15, 0.20, 0.25 and 0.30 (`.lnk_pipeline_prep_minimal()`, `classes_for_sp <- classes
  >= sp_amax`), so 0.30 is cut for every species; knowledge's own `data-raw/segment_gradient_check.R:32` lists 0.30 as
  an access class and the branch's `20261103_segment_gradient_check-derived_minimal.txt` tabulates it. The issue body's
  Problem paragraph (line 7) carries the same "(0.15, 0.20, 0.25)". The set of thresholds stands in for the set of
  classes. Read from a local link checkout at `552f43d6`, which holds 0.78.1's code path.
  - **Rule:** writing.md, "State each claim by the code's definition".
- **[severity: bug]** research/minimal_network_tuning.md:59 — "round trip 0.8 to 0.9 ms" for every run of
  2026-11-03. The grading run, `0320` run `20261103_0838`, logged 1.1 ms (`minimal_network_120/20261103_tune_run_console.log:7`
  and the run log's line 7), so the range is 0.8 to 1.1 ms. A range written from the evidence and comparison logs in
  view, not from every run the sentence covers. Minor, but it is a quantified range in a public file.
  - **Rule:** code-check.md, "One fact derived twice" (derive the figure from every artifact it names); agent
    operations' "between X and Y" as a word to check.
- **[severity: fragile]** research/minimal_network_tuning.md:70 — "bull trout 0.6 % (0.8)" names a species with two
  keys and reports one: it is bull trout rearing. Bull trout spawning's 13 % limit flips 8.7 % of 5,660 visits on the
  minimal network against 8.5 % on the full one, the one key where the minimal gradient does worse; steelhead (14.2
  against 17.0) and westslope cutthroat (0.7 against 0.7) are unlisted too. Every listed figure is correct, but the
  list reads as the species' result and all four point one way. Name it "bull trout rearing", or list every key.
  - **Rule:** writing.md, "When explaining a decision, list every check and the way it points".

Nothing else in the enumeration is false or unsupported; the public-repo sweep is clean.
