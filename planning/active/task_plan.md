# Task: FISS .xls: parse Step 2 life stage and Step 3 individual fish into the size-class evidence (#21)

`scripts/0220` parses Fish Data Submission workbooks for Steps 1, 2 and 4. It does not read:
- Step 2's life-stage column (it is in the sheet; not in `wanted_cols`);
- Step 3, Individual Fish Data (length, weight, maturity, age).

#18 built the evidence from the FDIS export instead (`scripts/0230`–`0240`), and left this as the supplement.

## Phase 1: Normalize Step 2 across editions and read life stage (0220)
- [x] `variant_map`: `species_code`→`species`, `method`→`sampling_method`,
      `haul_or_pass`/`haul_number_pass_number`→`haul_pass`, `ef_length_m`/`length_m` left as is
- [x] Add `stage`, `haul_pass`, `min_length_mm`, `max_length_mm` to `wanted_cols$step2_fish_coll`;
      `stage` kept verbatim (issue: submitter's label as-is), plus a lower-cased `stage_norm`
- [x] NFC: also match the code `NFC` (exact, case-insensitive), not only "no fish"
- [x] Re-run 0220 for all 5 groups; record per-group NFC / species_list before→after in findings;
      reconcile gate must still pass. Commit regenerated per-group outputs.

## Phase 2: Parse Step 3 per fish (0220)
- [x] `step3_indiv_fish` in `match_sheet()` (`step.?3|indiv`) and `wanted_cols`
      (species, length_mm, weight_g, sex, maturity, age, sampling_method, method_number,
      haul_pass, comments); gather with `gather_step()`; parse log goes to 4 rows per workbook
      (update the `parse_log_rows_vs_3_per_workbook` check)
- [x] Write `data/<wsg>/fiss_step3_fish_<wsg>.csv` (long, raw, keyed by `site_key`)
- [x] Reconcile row: Step 3 rows whose `site_key` has no Step 1 site (unplaceable, counted by name)

## Phase 3: Graduate the size classifier to pkg
- [x] `knw_size_class(species_group, length_mm, breaks)` in `pkg/R/size_class.R`, same semantics
      as 0240 `classify()` (half-open intervals, stop on overlap/gap); runnable `@examples`
- [x] Tests: boundary values (80 → juvenile), 0/NA/negative length → NA, overlapping breaks
      error, gap error; restore-the-bug check on the boundary
- [x] 0240 calls `knw_size_class()`; re-run 0240 and byte-compare `fdis_evidence.csv`,
      `fdis_maturity_check.csv`, `fdis_summary_ch_bt.csv` against HEAD (must be identical)

## Phase 4: FISS evidence (new `scripts/0250-fiss-evidence.R`)
- [x] Read every `data/*/fiss_step3_fish_*.csv` + `fiss_sites_*_all.csv` + Step 2 csv (cross-group;
      a report spans groups, so dedupe `site_key` across groups first)
- [x] Species label → code via `fdis_species_codes.csv` (code, then name, case-insensitive);
      unmatched labels reported by count, never silently dropped
- [x] Maturity text → FDIS codes (immature→IM, mature→M, maturing→MT, spawning→SP, spent→ST,
      undetermined/unknown→NA); same spawner rule as 0240 (SP/ST any date, M Aug–Oct)
- [x] Class with `knw_size_class()` + `data/fdis_size_breaks.csv`
- [x] Unmeasured rows: Step 2 `total_number` minus Step 3 fish for the same event × species
      (floored at 0), as in 0240
- [x] Place sites with 0230's `fwa_indexpoint` query (local fwapg :5432, 500 m); measured
      gradient / channel width from Step 4 (`average_gradient_percent`, `avg_channel_width_m`)
- [x] Dedupe vs FDIS: multiset match on survey date + UTM (within 50 m, same zone) + species +
      length; matched fish flagged `in_fdis = TRUE` and excluded from the FISS rows; match rate
      per report written to findings
- [x] Emit rows in the `fdis_evidence.csv` shape + `source` + `method` (see decision below)
- [x] Reconcile gate: Step 3 fish in = classed + unmeasured + no-length + dropped-with-reason

## Phase 5: Submitter label vs length class
- [x] Map `stage_norm` to comparable classes per group (fry↔fry; parr/juvenile↔parr/juvenile/
      older_juvenile for CH, fry/juvenile for char; adult↔adult/subadult for char) — written as a
      small table in the script, not inferred
- [x] Fish level: Step 3 fish joined to its Step 2 event × species row where that row is the only
      staged row (ambiguous joins counted, not guessed)
- [x] Row level: Step 2 staged rows whose min/max length both class to one size class
- [x] Write `data/fiss_stage_vs_class.csv` (species group × stage × class, n, share) and the
      disagreement rate into findings

## Phase 6: Docs
- [x] `scripts/README.md` (0220 now reads Step 3 + stage; 0250 run order and outputs);
      0220 header; `research/fdis_export.md` pointer to the FISS supplement
- [x] Log: `scripts/logs/fiss/` campaign run logs + README

## Decision (taken at the plan gate)

Option 1: new `data/fiss_evidence.csv` in the fdis shape plus `source` and `method`; `source = "fdis"` added to `data/fdis_evidence.csv` so the two bind directly.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
