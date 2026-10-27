# Code check, round 4 (enumeration): branch 91-place-fdis-sites-with-candidate-snapping (HEAD 327dafd)

## Checklist read

- INDEX.md read whole. Its headings are the same as the CLAUDE.md appendices.
- code-check-python.md (7,237 bytes) is the only FULL TEXT file under 40,000 bytes. Read it.
- code-check.md `## Mechanisms`: I read the prose of all fourteen H3s, skipping the `|` rows.
  - Applied here: "One fact derived twice", "Verification that reads its own output", "A guard's scope, escape hatches,
    and remedies" (the compression rule and the six-ways claim sweep), "A proxy is not the property" and "Written data
    outlives the fix".
- The larger files, the sections the diff touches:
  - code-check-r: `identical()` on reader results, `ifelse()` typing, Postgres row order, "Rscript reads a script as
    it runs", the data-masking rule.
  - code-check-spatial: "FWA main flow is not edge type 1000 alone", "A name is not a key".
- How I worked:
  - All probes ran read-only from `.../scratchpad/r4/`. The database queries were read-only, through DBI.
  - My only repo write is this file.
  - The changed tests ran on a `git archive HEAD` copy: test-fdis_place 25 passed, test-fdis_quality 13 passed,
    test-settings-register 261 passed. None failed, errored or skipped.
- Measured 2026-10-27T19:5xZ against:
  - the current `data/fdis/build/sites.rds` (md5 39f751b1…, which equals the ledger's `md5_sites`);
  - `reconcile.csv`, `data/fdis/derived/{fdis_sites,visits_link}.csv`;
  - the committed logs `scripts/logs/fdis/20261027_*` and `scripts/logs/habitat/20261027_evidence_build_ledger.csv`;
  - `fresh_default_20261017`.

## Enumeration

| place | reads / quotes | source of truth | verdict now |
|---|---|---|---|
| 0230 `snap_edges_excluded <- 6010L`; both `snap()` calls pass it | fresh's `exclude_edge_types` | sites.rds | holds. The override replaces fresh's default: 14 visits are placed on 1425 (5 segments) and 0 on 6010 |
| 0230 `nearest_any` (`exclude_edge_types = NULL`) and `sites_snap_nearest_edge_6010_excluded` = 3 | attrs edge type | probe csv `any_edge_type == 6010` | holds: 3 = 3 |
| 0230 band partition and confirmed/unconfirmed partition | sites | reconcile | holds: the bands sum to 34,041 + 4,901 + 4,659 + 4,126 + 2,201 = 49,928 = `sites_placed`; 10,439 + 39,489 = 49,928 |
| 0230 `snap_limit_m` / `snap_limit_code_m` | variables passed to `knw_fdis_place()` | the same variables | holds (200 / 500; the snap500 log reads 500 / 500) |
| 0230 header: "link's segments include none of those three kinds" | DB | `fresh_default_20261017.streams` | holds. 1425 = 353 segments; 0 unmapped, 0 placeholder, 0 of 6010 |
| 0230 header and lines 68–69: 1425 "stays a candidate … excluding it lost three visits link placed and gained none" | none | probe csv × sites.rds × visits_link | **misattributed** (finding 1) |
| 0310 `snap_limit*_m` rows ← build/reconcile.csv | reconcile | the 0230 run that wrote sites.rds | holds: the ledger reads 200 / 500, the same as the reconcile |
| 0310 `md5_sites` | sites.rds | the current file | holds: 39f751b1… on both |
| 0310 `kept_snap_confirmed` / `kept_snap_moved` | `q$kept` before link | ledger order | holds: 10,247 and 754, before `no_link_segment` |
| 0310 `build_record` line "(schema, run, flow load, walk md5, fresh)" | `knw_build_record()$line` | R/build_record.R:40 and the ledger row | holds |
| 0310 `walk_cache_hit` / `walk_cache_miss` | `attr(w, "cache")` | R/link_walks.R:190 | holds (110,784 / 0) |
| 0310 RUN: "first run walks them cold, ~10 min on the database's host and 40-60 min over a remote link" | none | progress.md: the 500 m build's 0310 took 16 min, walks cold 6.4 min, from the remote link; #91 body: "cold 6.4 min from a remote link" | **false** (finding 3) |
| 0240: fdis_sites gains snap_method, snap_confirmed, snap_moved, nearest_distance_m; two placements in one bound column | 0240 select, 0250 | code | holds |
| 0299: the v3 columns | 0240 select | code | holds (the same four columns) |
| vignette_method.R: ledger `md5_sites` against sites.rds | ledger, sites.rds | same | holds |
| vignette_method.R (R3 fix): fdis_sites.csv columns against sites.rds | fdis_sites.csv, sites.rds | sites.rds | holds. All five columns are identical now (blue_line_key is double in the csv and integer in the rds, and the strings agree). Mutated: a table flagged at 100 m fires the guard |
| vignette_method.R: `ex_far` distance > `snap_limit` (R3 fix) | fdis_sites.csv, register | register | holds (a backstop: an unconfirmed far pick is above `snap_limit` by construction) |
| vignette_method.R: ledger `snap_limit*_m` against the register; reconcile against the ledger | ledger, reconcile, settings.csv | same | holds (200 / 500 on all three) |
| vignette_method.R `near()`: `NOT IN (val("snap_edges_excluded"))`, unmapped, placeholder | register "6010" | 0230's `6010L` (register test green) | holds; the candidate set is fresh's |
| snap_limit_sensitivity.R: ledger md5 against sites.rds; ledger copy | ledger | `_ledger-snap500.csv` | holds. The copy reads `snap_limit_m` 500, not_placed 1,659 and kept 47,253, which equals cell 500/500 `evidence_visits` 47,253 |
| sensitivity cell 200/500 `evidence_visits` | sensitivity csv | final ledger `visits_kept` | holds: 45,529 = 45,529 |
| research Placement: "in the probe's count … 10,889 … 4,045 / 3,039 / 2,222 / 1,195 / 388" (R3 fix) | probe txt | probe txt: one code per visit, so pairs = visits; fish.rds is taken after the repeat drop (0230:398 pools from dropped copies) | holds as attributed |
| research: "link's segments carry none of those three kinds" | DB | as above | holds |
| research: "the nearest line is a 6010 connector for 3 visits, which go to the next stream" | — | sites.rds and visits_link | holds: all 3 are placed on edge 1000 and kept |
| research: "excluding it, as the probe did, lost three visits link had placed and gained none" | — | probe csv × sites.rds × visits_link | **misattributed** (finding 1) |
| research: "all 13 visits whose nearest line is 1425 are placed on it, and 12 are kept (one is 221 m away with no code)" | — | sites.rds and visits_link | holds: 13 are on edge 1425 and 12 kept. `112386_1_1` is 221.3 m away, unconfirmed and `ws50_checked` FALSE |
| research: probe class table, the 1,491 reproduced, 1,645 of 2,038, median 135–151 m | probe txt | probe txt | holds (unchanged since R3) |
| research: 186 visits; 92 / 93 %, 71 / 73 %; measures at most 1 m apart | probe csv | R3 recompute (unchanged file) | holds |
| research: disagreement table, "0.1 point" | sensitivity txt (rerun) | the rerun's txt: identical to the first run's | holds |
| research: five pairs, no moves; regions 51–244 | sensitivity txt | the rerun: every pair FALSE; region_n from 51 to 244 | holds |
| research: "Across the 30 ordered pairs of the six cells, for each key, one pick falls outside" (R3 fix) | sensitivity csv | recomputed: CH 1 of 30 (200/200 outside 500/500), BT 0 of 30 | holds only as "one across both keys"; the comma reading gives one per key, which is false for BT (finding 4) |
| research: CH picks `g<=0.15` at 200/500 and `g<=0.3` with a smaller flow floor at 100/500; BT the same in all six | sensitivity txt | same | holds |
| research: of 785 moved, 177 within 25 m; 56 from under 25 m moved to 200–500 m | sensitivity txt | the moved table sums to 785; reconcile `sites_snap_moved` 785 | holds |
| research before/after table (1,563 → 1,659; 5,242 → 1,941; 1,088 → 377; 1,491 → 178; 40,552 → 45,529) | ledgers 20261022 and 20261027 | both ledgers | holds |
| research: 10,210 confirmed and 748 moved of 45,529; ledger rows 10,247 and 754 before the drop of 178 | visits_link.csv | recomputed: 45,529 / 10,210 / 748 | holds |
| research: "ties are 29 visits, all on one stream either way" | probe | probe csv: `old_blk == new_blk` on 0 of 29 | **false** (finding 2) |
| habitat_thresholds_tuned note: never on unmapped, placeholder or 6010; 45,529 vs 40,552 | sites.rds and DB | 30,414 placed segments: 0 unmapped, 0 placeholder, 0 of 6010 | holds |
| CLAUDE.md: unmapped and placeholder visits now reach a mapped stream | probe classes × sites.rds | 1,347 of 1,347 and 174 of 174 placed | holds |
| CLAUDE.md: `0310` takes SCHEMA and the walk cache; the vignette tests fail until #92 | code | code (accepted) | holds |
| scripts/README 0230 (fresh >= 0.40.0, SNAP_LIMIT / SNAP_LIMIT_CODE) and 0310 (SCHEMA, `knw_build_record()`, cache) | code | `fresh_min`, code | holds |
| scripts/README Placement bullet | code | code | holds |
| settings.csv `snap_limit` note (126 of 379; regions unmoved from 100 to 500) | sensitivity | rerun pairs 1–2 FALSE | holds |
| settings.csv `snap_limit_code` note (no move between 200 and 500) | sensitivity | rerun pairs 3–5 FALSE | holds |
| settings.csv `snap_edges_excluded` = 6010, "excluding it lost three visits link placed" | code, data | 0230 `6010L` (test green); the clause as in finding 1 | value holds; clause misattributed (finding 1) |
| pipeline.csv steps 2 and 5 | code | code | holds |
| `knw_fdis_place()` roxygen: 200 m is the widest band under one in three; ties go to the lowest `linear_feature_id` as in `frs_point_snap()` | sensitivity; fresh#266 body ("breaks an exact distance tie on the lowest `linear_feature_id`") | same | holds |
| `knw_fdis_quality()` roxygen: the info rows sit outside the partition | code and test | code | holds |
| #92 body: "`…20261027_evidence_build_ledger.csv` … 45,523 visits kept" | that ledger | the ledger now reads 45,529 | **stale** (finding 5; issue text, not in the diff) |
| #91 body: 45,529, not placed 1,659, the 1425 sentence | ledgers | as above | numbers hold; the 1425 sentence is as in finding 1 |

## Findings

- **[severity: bug (prose)] research/fdis_export.md:153, scripts/0230-fdis-load.R:44, inst/method/settings.csv:8
  (`snap_edges_excluded` note), and #91's body: "excluding it [1425] … lost three visits link had placed and gained
  none".** Inside an earlier fix: yes (R3).
  - **What the measurement shows.** The three link-placed visits that the exclusion lost were `112386_1_1`,
    `112387_1_1` and `121402_2_1`. One of them, `112386_1_1`, is lost under the inclusion as well: it is now placed
    on 1425 at 221.3 m with no code, and is dropped as a far snap.
  - **What the inclusion actually bought.** Compared with the exclusion, it gave six more kept visits: kept 45,523 →
    45,529, not placed 1,665 → 1,659. Those six are:
    - `112387_1_1` and `121402_2_1`, which link had placed under `fwa_indexpoint()`;
    - `121397_1_1`–`121400_1_1`, whose old picks were on 1400 and which link had not placed (`link_old` FALSE).
  - **The cause.** The sentence states a count from one comparison (the exclusion against the old placement) as the
    effect of another (the exclusion against the inclusion). That is R3's mechanism again.
  - **Fix.** Write: "excluding it kept six fewer visits, two of them ones link had placed under `fwa_indexpoint()`,
    and gained none".
- **[severity: bug (prose)] research/fdis_export.md:219–220: "fresh#266 (open) proposes a new tie rule between two
  segments of one stream; ties are 29 visits, all on one stream either way".** Inside an earlier fix: no (e2d81c7).
  - **Why it is false.** The probe tests `tie` only after `same_segment` and `same_stream`. Every one of its 29 ties
    therefore has two picks on different streams: `old_blk == new_blk` on 0 of 29. They are equal-distance picks on
    two streams, at confluences.
  - **Why fresh#266 does not apply.** fresh#266's ties (two segments of one stream) fall in the probe's
    `same_segment` and `same_stream` classes, not in `tie`.
  - **Where those visits are now.** The final build puts 27 of the 29 on the probe's new stream and 2 on the old one.
  - **Fix.** Say the 29 are ties between two streams, which fresh#266's rule does not touch.
- **[severity: fragile (prose)] scripts/0310-evidence-build.R:52–54 (RUN): "the first run walks them cold, ~10 min on
  the database's host and 40-60 min over a remote link".** Inside an earlier fix: no (52f43a2, written before the
  run).
  - **The measurement.** The branch's own record (progress.md; #91's body, "cold 6.4 min from a remote link") has the
    500 m build's 0310 taking 16 min in all from the remote link, with 113,658 walks cold in 6.4 min.
  - **What is wrong.** The remote figure is six to nine times too high, and the host figure has no measurement behind
    it.
  - **Fix.** Replace both with the measured numbers.
- **[severity: fragile (prose)] research/fdis_export.md:197: "Across the 30 ordered pairs of the six cells, for each
  key, one pick falls outside another's region".** Inside an earlier fix: yes (R3's "36" fix).
  - **The count.** CH has 1 of 30 (200/200 outside 500/500) and BT has 0 of 30.
  - **The problem.** The sentence is true only as "one across the two keys' 60 pairs". The commas let it read as one
    per key, which is false for BT. The colon after it names CH only.
  - **Fix.** Write: "Across each key's 30 ordered pairs of the six cells, one pick falls outside another's region,
    and it is CH rearing's".
- **[severity: fragile (issue text, not in the diff)] #92's body, "Owed by #91": "`scripts/logs/habitat/20261027_evidence_build_ledger.csv`
  … 45,523 visits kept".** Inside an earlier fix: no.
  - **The mismatch.** After 327dafd's rerun, the ledger at that path reads 45,529, and so does #91's body.
  - **Fix.** Edit the body.

No code defect found in the rest of the diff:

- `knw_fdis_place()` (types and empty `hinted`).
- 0230's attribute join and its `format()` id list, which is guarded by `all(lfid %in% attrs$linear_feature_id)`.
- 0310's info rows and its schema gate.
- The sensitivity's `keep_of()`, which is the same inequality as `knw_fdis_place()`.
- vignette_method.R's new guards, which fire when run and pass on the current files.

Every enumeration row not listed as a finding holds against the current build.
