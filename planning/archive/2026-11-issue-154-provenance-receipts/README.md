## Outcome

knowledge now writes crate's shared provenance receipt (NewGraphEnvironment/crate#43) for each grade table
(`<key>_grades_receipt.json`, tracked, written by `0320` through `knw_grade_receipt_write()`) and for each set
`knw_publish()` publishes (`receipt.json` beside the manifest, from `0325`), with what each output is judged on and
its roundings declared in `inst/receipt/<output>.yaml` and pinned by `test-receipt.R`. The grade table's receipt
needed crate to name a receipt file, so crate#47 added `crt_receipt_write(file =)`, released as crate 0.13.0, which is
knowledge's floor. Promotion and the archive check and carry a grade receipt; the published-set receipts upload after
the tables and before the manifest. The roundings are provisional until #158 measures a rebuild; the evidence build
and the published visit tables are #160. What was learned: a receipt and its table pair in two directions, and every
reader has to hold both. The branch review found, over three rounds, a receipt naming another moment than its table
(a kept table's receipt written by a later pass, which mixed one pass's commit with another's settings) and a table
accepted with its receipt missing (read as a run from before receipts in one reader and as a stopped pass in
another). The settled rules are that a receipt is written only by the pass that graded its table, and that absence is
decided from the run (the grading commit, else another key's receipt), recorded in `findings.md` as two enumerations
and kept in `research/run_archive.md`, "The receipt says whether a rebuild came out the same". crate's own review of
`file =` ended the same way: three rounds each found a spelling a string comparison missed, until the check resolved
paths through the filesystem.

## Owed

- Revise the declared tolerances from #158's per-output verdicts (identical becomes exact; equivalent gets the
  rounding it was held to), and put that task in #158's body as well
- The first grade receipts reach `data/tune/` with the next retune's promotion (no backfill)
- The first published-set receipts reach the bucket with the next `PUBLISH=TRUE 0325`
- The database host needs crate at the floor (with `file =`) installed before the next 0320

Closed by: the PR from branch `154-write-the-shared-provenance-receipt-for`
