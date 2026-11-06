# Code-check round 3 (#158): database_compare.R, database_walk_check.R, database_receipts.R, CLAUDE.md, research/database_builds.md

## Checklist read

- code-check-python.md (marked read in full): read in full. Not applicable, because the diff has no Python.
- code-check.md: read the prose of all fourteen H3s under `## Mechanisms`, with evidence blocks and `|` rows skipped.
- code-check-r.md: read in full the sections whose index lines name what this code uses: "`tolerance` in testthat is RELATIVE…" (it covers comparing at the published precision and the Inf trap in a hand-written tolerance), "Verify a float-formatting fix in its consumer, not through `as.numeric()`" and "`match()` treats NA as a matchable VALUE". Every other heading was read by index line.
- code-check-shell.md, code-check-spatial.md: read by heading only. No section applies, because the diff has no shell or spatial code.

## What I ran (on copies in the scratchpad; the only write to the repo is this file)

- `SELFTEST_ONLY=TRUE` on a copy: 22 verdicts as expected.
- I reran the compare (`data/compare` against candidate `20261106_0423`) and the evidence (`derived` against `derived_second`) with the current code into a temp OUT. Every verdict, row count, max_diff, column, tolerance and "rows differing" count matches the committed CSVs. The rerun had only three rows the committed CSVs lack, and those are files the run does not write or that were compared by hand: `floodplain.csv`, `fdis_sites.csv`, and the hand-compared ledger. The STOP sets match too: 4 in compare (exit 1) and 1 in evidence.
- The receipts CSV's `hand_verdict` equals the current hand CSVs on all 109 rows. The only two hand rows missing from it are the ledger and pick_report, and the script filters or skips both by design.
- I checked every number in the research table and the CLAUDE.md paragraph against the CSVs (results below).
- For each spec row, I read its writer's rounding (`scripts/0320-tune-run.R` lines 377, 424, 425, 434, 506, 529, 635; `scripts/0330-compare.R` lines 325-328, 523-527; `scripts/0310-evidence-build.R` lines 411-431). For each table, I simulated a one-unit flip at its stored precision on its real values and asked the script's own `over()` whether the flip passes.

## Mechanism

Rounds 1 and 2 have one thing in common. Each time, a fact about the data was asserted from a belief rather than read from what produced it. The beliefs were: which values count as the same (Inf, NaN, NA), which spec row a file takes, what a table stores (centimetres, 3 decimals), what tolerance a count was taken at, and what a column measures. Round 2's fix carries the same assumption one step further.
- **The tolerances are still a belief about the writers.** Round 2 corrected the rows its reviewer named (grades, compare.csv, change.csv). It then wrote two comments: "never finer than what the table stores" (header, lines 18-20) and "checks.csv and each key's tables carry full precision" (lines 67-68). The writers contradict both.
- **The float allowance ignores the value's size.** The "one unit passes" allowance is `tol * 1e-9`, an absolute 1e-15 at tol 1e-6, and its fixture sits at magnitude 0.1. The float error of `abs(x - y)` scales with |x|, not with tol, so the allowance stops covering a one-unit flip once values pass about 5 (tol 1e-6) or about 5,000 (tol 1e-3). The self-test cannot see this, because its flip fixture never leaves 0.1. Moved to 1000.10003/1000.10006 at tol 1e-5, the same fixture reads `different`.

Enumeration. Each spec row against its writer, with the one-unit-flip result measured on that table's real values:

| spec row | writer's precision | tol | one-unit flips read `different` | decision-read | verdict |
|---|---|---|---|---|---|
| visits_link | full (0310:427) | 0 | n/a (exact by design) | yes | OK |
| visits_species | full | 0 | n/a | yes | OK |
| walks | full | 0.005 (chosen) | n/a | yes | OK |
| bcfishobs_fdis_match | full | 0 | n/a | no | OK |
| access_check | full | 1e-6 | n/a | no | OK |
| workbook_sites / _species | full | 1e-6 | n/a | no | OK |
| _grades_record | strings, ints, null_heldout_curve at 4 dp | 0 | CPU value, same inputs | yes | OK (latent) |
| _grades | rate and grade at 5 sig digits, all < 1; null_heldout_curve at 4 dp | 1e-5 | 0 on rate and grade (round 2's fix holds below 1); null_heldout_curve would fail | yes | OK; null_heldout_curve latent |
| **_tune** | round 6 (0320:424) | 1e-6 | **6,695 of 50,629 cells (CH); dev_heldout 3,169 of 6,149** | **yes** | FAIL |
| **_summary** | round 4 (0320:506) | 1e-6 | **16 of 16** | **yes** | FAIL |
| **_curves** | signif 5 (0320:425) | 1e-6 | **1,294 of 1,800** | no | FAIL |
| _seeds | rules and ints | 0 | n/a | yes | OK |
| **_honest** | round 6 (0320:434) | 1e-6 | **1 of 15** (values near 280) | no | FAIL |
| **_smoke** | rules rows round 6 (0320:377) | 1e-6 | **6 of 20** (deviances near 1,400) | no | FAIL |
| _groups | ints | 0 | n/a | no | OK |
| **pick_report** | round 4 (0320:529) | 1e-6 | **57 of 57** | **yes** | FAIL |
| **compare.csv** | round 3 (0330:527) | 1e-3 | **32 of 12,502** (the largest km, e.g. 583183.397) | **yes** | FAIL |
| change.csv | km round 3 (0330:525) | 1e-3 | 0 of 177 | yes | OK |
| **checks.csv** | **round 4** (0330:523), not full precision as line 68 says | 1e-6 | **77 of 77** | no | FAIL |
| _compare / _change / _checks | full (0330:325-328) | 1e-6 | n/a | yes / yes / no | OK |

Every code path in `compare_tables()`:
- **context note** (lines 101-106): compares unsorted rows, so it is order-sensitive. Every context column in use sits in a one-row table or is constant, so no current note is wrong. Latent; OK.
- **column mismatch, row count, key missing, repeated key, keys on one side** (lines 113-151): OK.
- **NA-placement path** (lines 161-168): the count now uses `diff_of` and `over`, consistent with the numeric path (round 2's defect is fixed). `worst` skips this column, so `max_diff` can understate how far a column with a moved NA went. No committed regenerated row is affected. Latent; OK.
- **numeric path** (lines 169-176): `over()` is the FAIL member above.
- **non-numeric path** (lines 177-179): OK.
- **final verdict** (lines 183-190): consistent with the counts. OK.
- **compare_files** (bytes short-circuit, non-csv, missing): OK.

Every number in the prose:
- research table: 7 of 7 picks; byte-identical scores, seeds, nested selection, curves and groups; "at most 3.3e-9" (BT_spawn_compare 3.318e-9); 3 of 45,529 visits at 0.0029; 40 to 441 sizes; 0 to 276 grades; 0 to 9 classes; 0.41 km (BT_rear 0.4108, compare.csv 0.411); 12.6 % (98,007 of 775,488); 0.05 % (412 of 775,488); 0.12 % (23 of 20,000); 2.3 min. All supported.
- Three kinds expected, plus ST's tie: supported by the tune CSV.
- CLAUDE.md: 441 and 276 supported. "About one cold walk's distance in a thousand" is loose (finding 3).
- One committed CSV is stale against the code: finding 2.

## Findings

- **[severity: bug (latent: no committed verdict is wrong)]** data-raw/database_compare.R:18-20, :57-66, :67-71, :152. Seven spec rows are held to a tolerance at which a one-unit rounding flip at the table's stored precision reads `different`. Five of them are decision-read, so such a flip stops the chain with exit 1.
  - **Tolerance finer than storage.** `_summary.csv` and `pick_report.csv` are written at 4 decimals (0320:506, :529) and held to 1e-6. Measured: `dev_default` 1481.0158 → 1481.0159 gives `different` on a decision-read table. `checks.csv` is written at 4 decimals (0330:523), not "full precision" as line 68 says: lift 2.4543 → 2.4544 gives `different`. `_curves.csv` is written at 5 significant digits and held to 1e-6.
  - **Tolerance equal to storage, but the allowance is absolute.** `over <- function(d) d > tol * (1 + 1e-9)` adds 1e-15 at tol 1e-6, while the float error of `abs(x - y)` is about eps·|x|. On `_tune.csv` (round 6, tol 1e-6), `dev_heldout` 1433.494917 → 1433.494918 gives max_diff 1.0000001e-6, verdict `different`, decision-read; 3,169 of the 6,149 dev_heldout values fail this way. The same happens on `_honest` and `_smoke` (round 6), and on `compare.csv` at its largest values: accessible_km 583183.397 → 583183.398 gives max_diff 1.00000005e-3, `different`, decision-read, STOP.
  - The header's "never finer than what the table stores … one unit passes" holds for none of these rows. The self-test's one-unit flip passes only because its fixture sits at 0.1.
  - Fix: compare at the stored precision. Either round both sides to the row's declared digits and compare exactly, or make the allowance relative to the values, e.g. `d > tol + 8 * .Machine$double.eps * pmax(abs(x), abs(y))`. Add `dp` or `sig` to each spec row, taken from the writer. Move the self-test's flip fixture to a magnitude near 1000.
  - **Rule:** code-check-r.md "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks" (compare at the published precision); code-check.md "A fixture that cannot reach the failure mode" (the flip fixture never leaves magnitude 0.1); code-check.md "A guard that fails toward pass" ("A comment stating a property is an unexecuted claim": lines 18-20 and 67-68).

- **[severity: fragile]** scripts/logs/habitat/database_second/20261106_database_compare-walks.csv (both rows). This CSV is the only committed verdict file that was not regenerated after rounds 1 and 2 changed what `column` and `max_diff` mean. It was written at 7551eaa, where `column` listed only the columns in `bad` and `max_diff` was NA on that path. The visit row's `column` therefore omits `dist_m`, `n_hops` and `max_entry_gap_m`, which its own note counts (412, 18, 18) and which current code would list (`names(n_bad)`), and its `max_diff` is NA although `dist_m` moved past 0.005. The counts the prose quotes are unaffected: dist_m is never NA in the reference, so its 412 came from the numeric path at tol 0.005. A reader of the CSV still sees fields the current code does not write. Rerunning needs the database, so either annotate the row (as the ledger row is) or say in the research file that the walks CSV predates the round-2 field definitions.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: fragile]** CLAUDE.md:533. "moved about one cold walk's distance in a thousand by more than 5 mm": the cited walks CSV gives 412 of 775,488 visit walks (0.53 per thousand, about one in 1,900) and 23 of 20,000 grade starts (1.15 per thousand). For the larger population that is half the rate the sentence states. research/database_builds.md states both shares correctly (0.05 % and 0.12 %).
  - **Rule:** none
