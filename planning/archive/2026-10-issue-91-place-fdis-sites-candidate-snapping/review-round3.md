# Code check, round 3: branch 91-place-fdis-sites-with-candidate-snapping (HEAD 6299d86)

## Checklist read

- INDEX.md read whole. It lists the same rule headings as the CLAUDE.md appendices for python, r, shell, spatial and code-check.
- code-check-python.md (7,237 bytes), the only FULL TEXT file under 40,000 bytes: read.
- code-check.md `## Mechanisms`: the prose of all fourteen H3s, with table rows and evidence blocks skipped. Most relevant
  here: "One fact derived twice", "Verification that reads its own output", "A guard's scope, escape hatches, and
  remedies" (the compression and six-ways claim sweep) and "A proxy is not the property".
- The larger files, read for the sections whose index lines name what this diff uses: code-check-r ("`identical()` on
  two reader results", "`ifelse()` with an all-NA test", "Postgres row order", "Rscript reads a script as it runs",
  "Inside a dplyr verb, a column named like a local variable wins", "`Sys.getenv`"/register handling via
  R/settings_register.R) and code-check-spatial ("FWA main flow is not edge type 1000 alone", "A name is not a key").
- Probes ran read-only, in my own scratch directory (`.../scratchpad/r3/`). I made no repo writes other than this
  file. The changed tests ran green on a `git archive HEAD` copy: test-fdis_place 25 passed, test-fdis_quality 13
  passed, test-settings-register 261 passed with 0 skipped.

## Mechanism

I agree with the candidate and would narrow it. In every case a claim or a check is taken at the artifact nearest the
writer, not at the artifact the consumer reads. Either a count measured at one stage is quoted as an outcome at a
later stage, or a guard ties together two artifacts that are not the ones the consumer reads. The R1 and R2 instances
fit this:

- The kept confirmed and moved counts were counted before link's drop.
- The vignette guard read 0230's current reconcile instead of the ledger.
- `subsurface_excluded` counted two edge types under one label.

Two new instances turned up in this round:

1. **A count taken at snap time, with its result asserted at placement.** `sites_snap_nearest_edge_1425_excluded = 13`
   counts visits whose nearest line of any kind is 1425. The prose then says those visits "now go to the next
   stream". Nothing read where they actually landed.
2. **A guard on a sibling of the artifact consumed.** R2's fix ties the ledger to `data/fdis/build/sites.rds` by md5.
   But `vignette_method.R` never reads sites.rds. It reads `flag_far_snap`, `snap_confirmed` and `snap_moved` from
   `data/fdis/derived/fdis_sites.csv`, which 0240 writes. That file is tied to the ledger only by `nrow == n_in` and
   the placed count, and neither of those depends on the limits.

## Enumeration

Measured on 2026-10-27 against the working tree, the committed logs and the database (`fresh_default_20261017`).

| place | reads / quotes | source of truth | verdict |
|---|---|---|---|
| 0230 `add("snap_limit_m"/"snap_limit_code_m")` | the `snap_limit` and `snap_limit_code` variables | the same variables passed to `knw_fdis_place()` | holds (one variable, two uses) |
| 0230 `sites_snap_nearest_edge_<e>_excluded` | `nearest_any` (no edge types excluded), edge type from `attrs` | probe csv `any_edge_type` | holds: 13 and 3, matching the probe |
| 0230 band partition and confirmed/unconfirmed partition `stop()`s | `sites` | `sites` | holds (one population) |
| 0310 `snap_limit*_m` ledger rows | `data/fdis/build/reconcile.csv` | 0230's run that wrote sites.rds | holds: both are written by the same 0230 run; no md5 links reconcile to sites, but every reader checks the ledger's md5 of sites.rds and the reconcile value against the ledger |
| 0310 `md5_sites/catch/fish` | the build files at 0310's start | the files 0310 consumes | holds: ledger 8410465f… equals the current sites.rds, which was rewritten at 11:48 by a deterministic rerun |
| 0310 `kept_snap_confirmed`/`kept_snap_moved` (10,247 and 754) | `knw_fdis_quality()$kept`, before link | ledger order (before `no_link_segment`) | holds; the label is "kept" at that stage |
| 0310 `build_record`, `no_link_segment` note, `walk_cache_*` | `SCHEMA`, `attr(w, "cache")` | `knw_build_record()`, `knw_link_walks()` | holds |
| 0240 header: `flag_far_snap` has two meanings across fdis and fiss evidence | 0230 limits against 0250's 100 m | code | holds |
| vignette_method.R: md5 of sites.rds against ledger `md5_sites` | sites.rds | the artifact the vignette consumes is **fdis_sites.csv**, not sites.rds | **wrong target** (finding 2) |
| vignette_method.R: ledger `snap_limit*_m` against the register, and reconcile against the ledger | ledger, reconcile, settings.csv | the ledger of the build | holds |
| vignette_method.R: `fdis_sites` "is the ledger's build" (`nrow == n_in`, placed == `n_placed`) | fdis_sites.csv | sites.rds or the ledger | **proxy**: both counts are the same under any snap limit (finding 2) |
| vignette_method.R: `ex_far`/`ex_kept`/`ex_moved` predicates and the nearest-stream check | fdis_sites.csv flags plus `near()` | the snap's candidate set (excluded edges, 999, unmapped) | holds for ranking; the flags inherit finding 2 |
| vignette_method.R `near()` edge filter | `val("snap_edges_excluded")` | 0230's `snap_edges_excluded` (register-tested) | holds |
| snap_limit_sensitivity.R: "500 m build" = `!any(flag_far_snap)` | sites.rds | reconcile `snap_limit*_m` | proxy, holds today (the 500 build had no far flags) |
| snap_limit_sensitivity.R: ledger md5 against sites.rds | ledger, sites.rds | same | holds |
| snap_limit_sensitivity.R: derived vl/vs/walks belong to that ledger | not checked | ledger | unguarded but holds as measured: the cell 200/500 `evidence_visits` 45,523 equals the real 200/500 build's kept 45,523 |
| snap_limit_sensitivity.txt "evidence ledger scripts/logs/habitat/20261027_…" | a path a later 0310 run has since overwritten | the `_ledger-snap500.csv` copy | holds through the copy |
| snap_candidate_check.R literals 50,024, 12,285 and 1,491 | the 2026-10-17 build and the 20261022 ledger | the refusal on `snap_method` enforces that build | holds; 1,491 reproduced |
| research Placement: 10,889 crosswalk-known codes, 4,045/3,039/2,222/1,195/388 | probe (old build's population) | 0230's `sites_ws50_checked` = **10,895** | **off by 6**: the probe's population, not 0230's (finding 3) |
| research: 1425/6010 exclusion; "link's segments carry no unmapped, placeholder or 6010 line" | DB | `fresh_default_20261017.streams`: 0 placeholder, 0 unmapped, 0 of 6010; 1425 = 353, 1400 = 17,136, 1410 = 81,700, 1450 = 259,794 | holds |
| research: "the nearest line is one for 13 visits, which now go to the next stream" | reconcile row 13 | sites.rds and visits_link for those 13 | **wrong**: 6 not placed, 1 placed at 416 m and dropped far, 6 placed and kept (finding 1) |
| 0230 header comment (lines 40–42): "so a visit whose nearest line is one of those reaches the next stream link can place it on" | none | DB and sites.rds | **wrong**: link carries 1425 (353 segments), and 6 visits reach no stream (finding 1) |
| research: probe class table (48,241 … 29), link before/after | probe txt | probe txt | holds |
| research: 1,645 of 2,038 link misses unmapped or placeholder | probe "by old pick's kind" (224 + 1,421; 393 + 224 + 1,421) | probe | holds |
| research: median 135–151 m | probe `med_new_dist` 135.1 and 150.9 | probe | holds |
| research: 186 visits; 92 % vs 93 % within 25 m, 71 % vs 73 % at 50–100 m | probe csv.gz | recomputed: 186; 0.917/0.925; 0.707/0.732 | holds |
| research: measures differ by at most 1 m | probe max 1.000 | probe | holds |
| research: disagreement table (8,637/645 … 172/96), "0.1 point" | sensitivity txt | sensitivity txt (126/379 = 33.25 %) | holds |
| research: the five pairs, no moves; regions 51–244 | sensitivity txt and csv | recomputed | holds |
| research: of 36 ordered pairs, one pick is outside (CH 200/200 `g<=0.13`, 500/500's 51-rule region) | sensitivity csv | recomputed over all 36 (self-pairs included): exactly 1, as stated | holds |
| research: CH picks `g<=0.15` at 200/500, `g<=0.3` at 100/500; BT the same in all six | sensitivity txt | same | holds |
| research: of 785 moved, 177 within 25 m; 56 moved 200–500 m from under 25 m | sensitivity (500 build); reconcile `sites_snap_moved` 785 | the moved table sums to 785 | holds (the probe has 179 on the old build; the prose cites the sensitivity) |
| research before/after table | ledgers 20261022 and 20261027 | both ledgers | holds |
| research "same link schema and flow load" | 20261027 `build_record` | the 20261022 ledger has no flow-load row (only `wet_manifest` 2026-10-20) | holds on run_uid; the flow load is unverifiable from the older ledger |
| research: 10,210 confirmed, 748 moved of 45,523 kept; ledger rows 10,247 and 754 before the drop of 178 | visits_link.csv | recomputed: 10,210 and 748 | holds |
| research: ties 29 | probe | probe | holds |
| habitat_thresholds_tuned note: never on 1425 or 6010 lines; 45,523 vs 40,552 | sites.rds (0 placed on 1425 or 6010), ledgers | same | holds |
| CLAUDE.md: unmapped and placeholder visits now reach a mapped stream | probe classes and sites.rds | 1,347 of 1,347 and 174 of 174 placed now | holds |
| CLAUDE.md: `0310` takes SCHEMA and the walk cache | 0310 | code | holds |
| settings.csv snap_limit note: "100–200 m: 126 of 379", regions unmoved from 100 to 500 m | sensitivity | the rule's pairs at confirmed 500 | holds |
| settings.csv snap_limit_code note: no move between 200 and 500 m | sensitivity | the rule's pairs at each unconfirmed limit | holds |
| settings.csv snap_edges_excluded note: 6010 lacking in link; 1400, 1410 and 1450 stay candidates | DB, code | same | holds |
| settings.csv `script:` with `Sys.getenv(…, 200)` | register resolver takes the default | `.knw_where_value` line 55 | holds; test green |
| pipeline.csv step 2 wording | knw_fdis_place | code | holds |
| scripts/README 0230 and 0310 lines | code | code | holds |

## Findings

- **[severity: bug (prose)] research/fdis_export.md, Placement section ("They do carry 1425 lines; the nearest line is
  one for 13 visits, which now go to the next stream"), and scripts/0230-fdis-load.R:40–42 ("snap_edges_excluded drops
  subsurface flow (1425) and the group-boundary connectors (6010), so a visit whose nearest line is one of those
  reaches the next stream link can place it on").** Inside an earlier fix: yes, both sentences were edited in R2.
  - **Measured.** I joined the probe's 13 `any_edge_type == 1425` visits to the current sites.rds and visits_link.csv:
    - 6 are not placed at all, because there is no other stream within 500 m;
    - 1 is placed at 416 m and dropped as a far snap;
    - only 6 go to a next stream and are kept.
  - **Why the 0230 comment is also wrong.** Its premise for 1425 is false: `fresh_default_20261017.streams` holds 353
    edge-1425 segments, so link can place a visit on a 1425 line.
  - **What the exclusion costs.** Two of the 13 (`141680_17_1`, `121402_2_1`) were on link's segments under
    `fwa_indexpoint()` (probe `link_old = TRUE`) and are now lost. The probe's "by old pick's kind" table shows all 5
    old 1425 picks placed by link.
  - **Fix.** Correct both sentences to "6 of the 13 go to the next stream; 6 reach none and 1 is dropped far". The
    exclusion of 1425 is a convention that loses visits link can place, so state that, or reconsider the convention.
    That is the user's call; the register calls it `convention`.
- **[severity: fragile] data-raw/vignette_method.R, lines 186–188 (md5 guard) and 246 (`fdis_sites is not the ledger's
  build`).** Inside an earlier fix: yes, R2.
  - **What the guard covers.** The md5 guard ties the ledger to `data/fdis/build/sites.rds`, which the script never
    otherwise reads.
  - **What the examples read.** `ex_far`, `ex_kept` and `ex_moved` are chosen by `flag_far_snap`, `snap_confirmed`
    and `snap_moved` from `data/fdis/derived/fdis_sites.csv`, which 0240 writes.
  - **Why the remaining check cannot catch it.** fdis_sites.csv is checked only by `nrow == n_in` and the placed
    count, and both are the same under any `SNAP_LIMIT`/`SNAP_LIMIT_CODE`. The only other tie is the md5 that
    `meta` records, and nothing compares it.
  - **The failure.** Rerunning "0230 and 0310 together", as the R2 stop message instructs, after any limit change
    leaves fdis_sites.csv on the old limits, and every guard passes. The "dropped for its snap distance" example can
    then be a visit under 200 m that the evidence kept, captioned "more than 200 m from its stream". Today fdis_sites.csv
    agrees with sites.rds on every placement column (0 differences), so no output is wrong now.
  - **Fix.** Compare fdis_sites.csv's placement columns with `readRDS(sites.rds)` by `site_visit` (or record its md5
    from 0240 and compare), name 0240 in the remedy, and assert `ex_far$site$distance_to_stream > val("snap_limit")`.
- **[severity: fragile, prose] research/fdis_export.md, Placement, "Confirmed" bullet ("of the 10,889 the crosswalk
  knows, 4,045 name one key …").** Inside an earlier fix: no.
  - **The mismatch.** The counts are the probe's population (`snap_candidate_check.txt`, on the 2026-10-17 build). The
    paragraph describes 0230's pick, and 0230's own `sites_ws50_checked` in the committed reconcile is **10,895**. The
    6-visit gap is the difference between the two populations.
  - **Fix.** Either attribute the breakdown to the probe and its build, or recount it on 0230's `ws50_checked`
    visits.

No other row of the enumeration fails. Every count in the changed prose that I did not list as a finding was recomputed
from the committed log, the current build or the database and matched.
