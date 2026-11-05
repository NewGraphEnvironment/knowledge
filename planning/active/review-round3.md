# Code-check round 3 (#120 branch, at 9b7c914)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (14), tables skipped; no other heading.
- code-check-r.md: read by heading, 4 read ("A `data-raw/` script must load the source tree, not the installed
  package"; "`match()` treats NA as a matchable VALUE…"; "`[[` on a named ATOMIC vector with an absent key…";
  "Postgres row order is never fixed…"), the rest not read (about 120).
- code-check-shell.md: none read (no shell in the diff).
- code-check-spatial.md: none read (the diff's spatial code is a GeoPackage write and a tmap figure, unchanged in kind).

## Mechanism

Whether a run, table or record is a setup, and which gradient (and which parent table) it was made on, is a property
of the **run**, fixed before any key is scored. Rounds 1 and 2 kept finding readers that inferred it from an artifact
only some routes produce: the summary's `curve_grad` and the curve's `cols`, which only a fitted key carries (r1's
resume guard, r1's per-key promotion check, r2's all-no-fit run), and the parent table checked against what the
database holds now rather than against what the run recorded (r1's parent-held fix). The shared assumption is that
"every key that matters is fitted" and "the database is still the build the run read", so two signals (the summaries'
gradient and the run's real gradient; the database's build and the evidence's) happen to agree on every run anyone
had tried. The remedy the branch converged on is a run-level declaration written before any key (`setup.txt`) and a
recorded provenance line compared at read time (`.knw_parent_held()`). The places below are every reader or writer
that decides setup-ness or the gradient, or reads a gradient (or the parent table) from the segments.

## Enumeration (every place, its signal, present for every key/file? y/n)

| place | decides / reads | signal | present for every key and file it must cover? |
|---|---|---|---|
| `scripts/0320` run guards (L160-185) | setup vs main vs sensitivity in one run dir | `setup.txt` + every root summary's `curve_grad` (NA tolerated) | y: marker is run-level, written before any key; the two pre-marker setup runs (20261105_0436/0437) each hold a fitted CH_rear summary naming its gradient |
| `scripts/0320` `dir_out`, log suffix, `dir_pub` | where a setup writes | `setup` flag + `GRADIENT` | y |
| `scripts/0320` grade (L525-560, keep-check L589) | gradient the grade and keep-check use | the curve's `cols[["grad"]]` | y: every graded key has a curve |
| `scripts/0320` grade tokens (L546-552) | setup's `grad` token | `rec$tokens` (build) + `GRADIENT` | y, but evaluated after scoring (finding 3) |
| `scripts/0320` parent held (L537) | parent table = evidence's | ledger `parent_table` note vs `knw_parent_read()` provenance | y, but evaluated after scoring (finding 3) |
| `knw_grade_species()` | segments' gradient source | curve `cols[["grad"]]` → `.knw_grade_grads` | y (refuses any curve without one) |
| `knw_link_segments()` / `.knw_seg_grad_check()` | gradient read from segments; coverage | `gradient` argument (default `"segment"`) | y for its two callers that pass it; parent side held to the database now, the scripts hold it to the ledger |
| `knw_compare_rules()` + `.knw_compare_bin()` | gradient on the scratch copies and the segment read | `gradient` argument (default `"segment"`) | y from 0330; **n** from `data-raw/compare_structures_check.R` (finding 2); 0322 and compare_parallel_check read `data/tune` only (main curves), so y |
| `scripts/0330` `run_grad` | the run's gradient | fitted curves' `cols[["grad"]]`; no fitted key → segment (nothing compared) | y |
| `scripts/0330` stale check (L281) | grade table on the run's gradient | grade table `curve_grad` vs `run_grad` and curve | y |
| `scripts/0330` parent held (L250) | parent table = evidence's | ledger note | y |
| `knw_tune_promote()` | setup run never promoted | `setup.txt` + every summary's `curve_grad` (whole run, not keys) | y |
| `scripts/0335` | calls `knw_archive_plan()` then `knw_tune_promote()` | via the two above | y (a setup is refused, by the plan's evidence check or by promotion) |
| `knw_archive_setup()` / `knw_archive_plan()` / `0336` | archive folder's grad token | grade record `curve_grad` + `token_grad` | y: every archived key has a record carrying both; "no build writes `grad-parent`" checked in link's vocabulary.csv and NEWS 0.79.0 |
| `knw_grade_record_write()` | writes `token_grad` | `tokens_rec` from 0320 | y |
| `scripts/0310` | writes `parent_gradient`, `segment_fwa_gradient`, ledger `parent_table` | parent table / FWA by segment's `linear_feature_id` | y (`parent_table` only with PARENT=TRUE; PARENT_DIR evidence is refused at grade time, by design) |
| `scripts/0325`, `knw_thresholds_table()` | published gradient | `.knw_grade_grad_ok(h)` (segment) on tracked tables | y (tracked tables change only by promotion) |
| `data-raw/vignette_chinook.R`, `vignette_method.R` | published gradient | `.knw_grade_grad_ok()` on records / summaries | y |
| `data-raw/setup_compare.R` | what each setup is; the transfer through the parent table | records' `curve_grad`/`token_cut`/`token_grad`; parent table minimal run vs minimal record | **n**: the parent table's full side and the database's full build are held to nothing the records name (finding 1) |
| `data-raw/pick_network_compare.R`, `tune_anchor_check.R` | report a run's gradient | summaries' `curve_grad` (NA on no-fit keys) | n/a: report only, decide nothing |
| tests (`test-tune_promote`, `test-archive`, `test-grade_species`, `test-link_segments`, `test-parent_read`) | fixtures for the above | marker, records, curve cols | y (promotion's all-no-fit marker case is pinned) |

## Findings

- **[severity: bug]** `data-raw/setup_compare.R:85-92, 141-147` — the parent table and the database's full build are
  held only on the minimal side. The script checks `provenance$run_uid_minimal` against the minimal setup's record,
  and checks the setups share a flow load, tokens and visits/walks, but never that the published, parent and Atlas
  records name one full run (`run_uid`), nor that the parent table's `run_uid_full` (or the database's
  `knw_build_record()`) is that run, nor (for the parent setup) that the table is the one its evidence ledger
  recorded (`.knw_parent_held()`, which r1 added to 0320 and 0330). `knw_parent_read()` holds the table only to the
  database now. After a provincial re-run of the full network (link renames `fresh_default` and builds a new one, as
  CLAUDE.md records happening mid-chain) with the parent table rebuilt on it, the old runs' `<key>_segments.rds` keys
  `(wsg, id_segment)` are matched to the new build's parent rows (`match(k_of(full), …)`) and geometry (`geom_of()`):
  `anyNA(i)` fires only where an id is absent, so renumbered segments that reuse ids join silently, and the transfer
  km, the GeoPackage and the figure describe a mix of two builds. This is r1's parent-table finding in a third
  reader. Fix: stop unless `recs$published$run_uid`, `recs$parent$run_uid` and `recs$atlas$run_uid` are one value
  and equal `attr(par, "provenance")$run_uid_full`, and hold the table to the parent setup's ledger
  (`.knw_parent_held(conn, schema, read.csv(recs$parent$evidence_ledger))`).
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

- **[severity: fragile]** `data-raw/compare_structures_check.R:47, 159-164` — it calls `knw_compare_rules()` without
  `gradient`, so the default `"segment"` decides, and nothing reads the curve's or the grade table's `curve_grad`.
  Its `TUNE_DIR` accepts any directory, so pointed at a setup candidate it regenerates `default` and the tuned rule on
  the segment's own gradient beside grades made on the parent's or Atlas segment's, with no refusal (its only
  provenance checks, on flow load and evidence, report "NOT the grades'" and continue). 0330 got the fix (it passes
  `.knw_grade_grads[[run_grad]]` from the curves); this sibling caller did not. Fix: pass
  `gradient = .knw_grade_grads[[r$curve$cols[["grad"]]]]`, or refuse a curve whose `cols[["grad"]]` is not
  `.knw_grade_grad`.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "A guard that fails toward pass"

- **[severity: fragile]** `scripts/0320-tune-run.R:537, 546-552` (and `scripts/0330-compare.R:250`) — two run-level
  preconditions of a setup are evaluated only after the smoke run, the scoring and the summaries: the build's own
  `grad` token must be `grad-seg`, and the parent table must be the evidence's (`.knw_parent_held()`). Both are
  knowable at start (`rec$tokens` is read at connect, L254; `led` is read at L232). A setup refused by either loses its
  scoring pass's log, because both `stop()` without `writeLines(log_lines, …)` and without the `_refused` name
  CLAUDE.md requires of every new refusal ("A refused run writes its ledger or log under a `_refused` name … any new
  refusal does the same"); the run directory is left with the pass's summaries and curves and no grades. In 0330 the
  parent-held refusal likewise writes no log. Fix: move both checks into the `if (!dev)` block after
  `knw_build_record()` (for `setup` and for `gradient == "parent_gradient" && setup`), refusing through the
  `_tune_refused` path the latency check already uses.
  - **Rule:** code-check.md "A guard that fails toward pass"

/Users/airvine/Projects/repo/knowledge/planning/active/review-round3.md
