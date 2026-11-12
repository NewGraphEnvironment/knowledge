# Plan review for #165 (Plan agent, 2026-11-12)

Read-only review of the baseline plan against the issue and the code. Each finding with its disposition; the plan was
revised from it (task_plan.md, "Decided at the gate" and every phase).

| # | kind | finding | disposition |
|---|---|---|---|
| 1 | Blocker | A commit, a staged file under `R/`/`scripts/`/`inst/`, or an `inst/receipt/*.yaml` edit on the second's worktree between the two halves makes the recipes differ, or writes new tolerances into a receipt claiming a clean commit (`R/receipt.R:23,47`) | Taken: a freeze on the second's worktree until both receipts are written (gate) |
| 2 | Ordering | Moving the ledgers into `receipt_165/` breaks `0320` (`.knw_evidence_ledger()` does not recurse, `R/run_ledger.R:91-95`) | Taken: ledgers stay in `scripts/logs/habitat/` |
| 3 | Ordering | `evidence_receipt_compare.R` reads the first build's ledger; copy the host's ledger to the second first | Taken (Phase 2) |
| 4 | Ordering | One `RUN` stamp on both hosts would overwrite the second's candidate when the host's is copied; pass `OUT=` to `database_compare.R` | Taken (Phase 3) |
| 5 | Gap | Check `../link` holds `4dfbfa49` on the host; compare `reconcile.csv` and `MANIFEST.md5` byte for byte (the ledger has md5s for the three .rds only); link's config sha; the flow comment exactly; sessionInfo | Checked: `../link` holds it on both; the two files' md5s agree (`aab0088a…`, `914693b6…`); the flow comments are the same string; link configs and sessionInfo in Phase 1/2 |
| 6 | Gap | The hydrologic-zones zip is downloaded per run: compare the ledgers' `zone_zip` md5 | Taken (Phase 2) |
| 7 | Assumption | crate compares summaries as a band (`crt_receipt_compare.R:160`), rounding only table cells | Confirmed in crate origin/main 0.16.0; the gate's rule rewritten |
| 8 | Assumption | "At or above" a writer unit fails in floating point; use the next power of ten, strictly above | Taken (gate) |
| 9 | Assumption | One identical chinook measurement is weak: compute the order bound for the largest key and the published set; say #162 is not exercised | Taken (Phase 3, gate) |
| 10 | Assumption | `pick.null_heldout_curve` at 1e-4 acts as exact on receipts alone | Taken: said in the header (Phase 4) |
| 11-15 | Gap | More places restate the tolerances: `test-grade_receipt.R:73-82`, `test-evidence_receipt.R:72-73`, `test-publish.R:149-150`, `test-receipt.R:119,128`, `run_archive.md:74,79-82,89,100-103`, yaml headers (grade sizes 0.29-2.5 GB), CLAUDE.md 459 and 478-480, a new NEWS line | Taken (Phase 4 list) |
| 16 | Acceptance | The pin is `test-receipt.R:119-134`, not the moved-value test | Taken (Verification) |
| 17 | Acceptance | Try the new tolerances on real receipts | Taken (Phase 4) |
| 18 | Acceptance | Phase 3 needs a rule for `different`; define when "provisional" goes | Taken (Phase 3, gate) |
| 19 | Acceptance | The IDate probe should compare fingerprints, not receipts | Already so: the probe compared the result fingerprints' sha256 (identical) as well as the verdict |
| 20-21 | Scope | Say in the yamls that chinook alone set the grade tolerances, and that thresholds rest on #158's tune tables | Taken (gate, Phase 4) |
