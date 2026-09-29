# Review 0250 — round 1

## Findings

- **[bug]** scripts/0250-fiss-evidence.R:209, 216, 229 — `n_caught` and `n_measured` mean something different from the same columns in `fdis_evidence.csv`, and the mix double-counts unmeasured fish.
  - In 0230/0240, `n_measured` counts every detail row, with or without a length (0230:205). `n_caught` is `pmax(n_counted, n_measured)`, so it is never below `n_measured` and never NA when fish were measured (0230:215). Unmeasured is then `(n_caught - n_measured) + n_nolength`, which is consistent because the no-length rows are already in `n_measured`.
  - In 0250, `n_measured = sum(!is.na(size_class))` counts classed fish only, and `n_caught` is the raw Step 2 sum. So `pmax(n_caught - n_measured, 0) + n_nolength` counts each no-length Step 3 fish twice: once in `n_caught - n_measured` and again in `n_nolength`.
  - Measured on the staged output: site `52771:502`, BT, boat electrofishing has `n_caught` 4, 3 classed fish and 1 fish with no length. It is written as 3 classed + 2 unmeasured, which is 5 fish from a catch of 4.
  - Also in `fiss_evidence.csv`: 108 site x species x method keys have `n_caught` NA while `n_measured > 0`, and 19 have `n_caught < n_measured`. FDIS has 0 of either (8,999 keys).
  - A consumer binding the two files reads NA `n_caught` as "abundance unknown" on rows where fish were measured and counted.
  - Fix: mirror 0230. Set `n_measured` to all Step 3 rows for the key and `n_caught = pmax(coalesce(sum, 0), n_measured)` (NA only when there is no count and no Step 3 fish). Unmeasured then follows 0240's formula unchanged.

- **[fragile]** scripts/0250-fiss-evidence.R:345-348 — the reconcile gate compares quantities with themselves, so it cannot fail on the thing it claims to check.
  - `step3_fish_owned` compares `nrow(step3)` with the sum of buckets over `fish`, which is those same rows. `case_when` always assigns a bucket, and the `sites` join is unique by `stopifnot`, so the two numbers are equal by construction.
  - `classed_vs_evidence_rows` and `focal_no_length_in_unmeasured` count the same predicate on the same filtered rows (`!in_fdis`, focal, site present, `size_class` NA or not) as the bucket they are compared with.
  - The only arm that can fire is `reports_parsed_differently_across_groups`.
  - Nothing reconciles the written `n` values against Step 2 totals, which is exactly where the double count above lives. A check that classed + unmeasured == `max(n_caught, n_measured)` per key over `evidence` would have flagged `52771:502`.

- **[fragile]** scripts/0250-fiss-evidence.R:77-85 — Step 3 fish in reports that have no rows in any `fiss_sites_*_all.csv` are dropped by `own()`'s inner join before the gate.
  - The owner table is built from sites only. Four reports have Step 3 fish but no site rows: 16389 (unth, 71 fish), 16393 (lnth, 94), 16597 (upce, 418) and 16845 (unth, 225). That is 808 fish.
  - `step3_fish_owned` is taken after the join, so these fish are in no bucket, and the header's claim that "every Step 3 fish is accounted for" is off by 808.
  - Evidence is probably unaffected, since they would have landed in `no_step1_site`. But the gate cannot see the loss, and it may point to a 0220 parse gap for those reports.
  - Fix: compare against `n_distinct` fish per report across `step3_all`, or build the owner table from the union of all three tables.

- **[bug, overlap output only]** scripts/0250-fiss-evidence.R:175-179, 186 — the multiset match is scoped per FISS site, so one FDIS fish can be counted as a match at several FISS sites.
  - 224 FDIS visits pair with more than one matched FISS site, 90 of them from different reports (the same survey submitted twice).
  - Summed per FDIS length cell, FISS matches exceed the FDIS fish present in 4,403 cells, by 5,392 fish in total.
  - This inflates `fish_matched` and `share_matched` in `data/fiss_fdis_overlap.csv`, and the logged "94,228 matched by length". Evidence rows are unaffected, because the drop is by site.

- **[fragile]** scripts/0250-fiss-evidence.R:180, 192 — one length match drops every electrofished fish at the site.
  - 95 matched sites have fewer than half their measured electrofished fish matched in FDIS. Those sites drop 5,428 fish: 3,595 are measured and unmatched, and 35 are focal.
  - This is a design choice and the findings file argues for it. Still, those 35 focal fish are removed with no FDIS row accounting for them.
  - Related: 61 fish with NA method at FDIS-matched sites are kept, because `is_ef(NA)` is FALSE. If they were electrofished, they duplicate FDIS.

## Checked and fine

- `knw_size_class()`: half-open classes, the error on gaps and overlaps, and NA for unmeasured are all correct. The classes in `stage_ok` match `fdis_size_breaks.csv`.
- Owner selection: in every report that has sites, the owner group has as many Step 3 and Step 2 rows as any other group.
- Date parsing: serials run 37182-44106 (2001-2020). The text dates (`10-Aug-06`, `22/9/2021`, `18/8/11`) parse as dmy. Only `Jul 26/2010` fails, and it is counted among the undated sites.
- Stage-vs-class joins: no key with a single stage also has unstaged Step 2 rows, so no fish takes a label from another row. Keys with several stages are excluded and counted.
- Kept evidence has no cross-report duplicate sites (same date, within 50 m). The 26 same-report pairs share no measured-fish signature.
- The output columns are identical to FDIS, `flag_ws50_mismatch` is logical in both, and there are no duplicate (site, species, method, class) rows.
