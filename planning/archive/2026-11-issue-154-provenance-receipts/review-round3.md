## Checklist read

- code-check-python.md: in full. Nothing in the diff is Python.
- code-check-r.md (by heading): read 4 of about 121. These were "`$` on a list partial-matches, so a longer sibling key answers for a missing one" (checked against the `crt_receipt_read(...)$context$run$grades_md5` reads: no key there has a prefix sibling), "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, ...", "`identical()` on two reader results tests the reader, not the file" and "Two repos pinning the same remote at different tags is an unsolvable install".
- code-check-shell.md (by heading): read none of about 100. The diff's only shell use is `git` through `system2`, which the R heading above covers.
- code-check-spatial.md (by heading): read none of about 120. Nothing in the diff is spatial.
- code-check.md (by heading): read the prose of all 14 Mechanisms H3s, without their table rows. I did not read the Rules-that-stand-alone, Security, or Spreadsheets and PDFs headings (about 25).

## The mechanism

Your statement is: a receipt can draw a value from a different moment or artifact than the table it describes. It holds for the seven earlier findings, but it is half the class. The class is **pairing a receipt with its table**, and it has two directions:

1. **A receipt describes something other than its table.** A value comes from another moment or artifact. This covers findings 2, 4 and 7, and 6 on the published side.
2. **A table is accepted as described when its receipt is missing or belongs to another set.** The reader decides what absence means by a proxy instead of asking the run.

The second direction is new in this round. 0320's keep path treats a missing receipt as a failed pass and regrades. Promotion and the archive treat a missing receipt as "a run from before receipts" and accept the table (F1 below).

## Checking your enumeration (planning/active/findings.md, "Branch review round 2")

I checked each row against the code. The grade writer's rows hold:

- **Settings from `r$score$spec`.** When the score comes from the cache, this is the cached spec. That cache is reused only when its spec equals this pass's after `.tune_spec_norm()` (R/tune_run.R:260), so the values written are this pass's.
- **`min_wsg`.** It is not in the cache spec, but the score does not depend on it. It only decides whether a key is modelled (R/tune_run.R:195).
- **Walk SQL.** It is held to the record's `walk_md5`. The record's value is the table column, which 0320 checks against the run's `walk_md5` at grading.
- **Inputs, pick, context and summary.** These come from the record written seconds before, or from the frame written to disk.
- **link's thresholds.** 0320 reads them with `git show <build sha>` (0320:328). The build's run uid therefore covers them.

Fields the table leaves out, all harmless:
- the receipt's `output.scope` (from the record);
- `context.time` and `toolchain` (crate fills them at write time, and they are not part of the receipt's identity);
- `recipe.code.version` (`packageVersion()` reads DESCRIPTION at write time, not at the start; this falls under the accepted rule against editing files a run reads).

Readers the table leaves out:
- **promotion's and the archive's handling of a missing receipt** (F1);
- **the archive's batch narrowing.** `.knw_archive_local()` narrows batches by the curve and the segments only, never by the tracked receipt. It matters only through F1.

On the published side, the `tune_run` row is held to the right tables but taken over the wrong population for the grade set (F2).

## Findings

- **[severity: fragile]** R/tune_promote.R:143-152 and R/archive.R:138-157. Promotion and the archive read a missing grade receipt as a run from before receipts.
  - 0320's keep path (0320:623-628) reads the same absence as a pass that stopped, and regrades. That leaves one class with two policies.
  - **How a run ends up with a table and record but no receipt.** A pass of a receipt-era run can stop after `write_record()` and before `write_receipt()`. The window is real: the receipt hashes the 0.7 to 5.6 GB table, and `.knw_receipt_evidence()` refuses evidence that moved. The pass has already unlinked the previous receipt (0320:660). The run then holds a table and a record that match each other, and no receipt.
  - **What promotion does with it.** If an earlier pass of the same run logged `<k> grades:`, the log check passes; promotion reads every `_tune_run*.txt` in the run. Once 0330 has been rerun, promotion accepts the key ("a run from before receipts has none"). It also moves the tracked receipt from the last promotion into `removed`. The key is published with no receipt and nothing says so.
  - **What the archive does with it.** The archive stores that batch without a receipt. A later resume regrades the key with the same RUN, at the same commit, and very likely to a byte-identical table. That gives a byte-identical record, so a second batch holds the same record plus a receipt.
  - **Why a restore then fails.** `.knw_archive_batch_rows()` narrows only by curve and segments (`.knw_archive_local()`), so the two batches stay ambiguous. A pull then stops asking for `BATCH=` unless one of them is the published batch.
  - **Fix.** Decide what absence means from the run, not from the file. One way: refuse a key with no receipt when any other fitted key in the same run directory carries one. Another: refuse it when the record's `knowledge_commit` resolves to a commit that holds `R/grade_receipt.R` (`git cat-file -e <commit>:R/grade_receipt.R`). Also add the tracked receipt to `.knw_archive_local()`, so a checkout's own receipt picks its batch.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A fix lands in one of two callers that share a harness"

- **[severity: fragile]** scripts/0325-publish.R:125-137 against 160-164. The grade set's recipe and its result are taken over different keys.
  - `tune_runs` is built from the records of every grade table, withheld keys included, and the one `recipe_pub` serves both sets.
  - The habitat_grade set then drops the withheld keys (`gfiles <- gfiles[!basename(gfiles) %in% withheld]`). Its summary and parts cover only the published keys.
  - Three of today's seven tracked keys are withheld (BT_spawn, CO_rear, WCT_rear). All are on one run now, so nothing moves yet.
  - **When it bites.** Once a withheld key is promoted by key from another run, which promotion allows on the same build, the habitat_grade receipt names that run in its `tune_run` setting. None of that run's grades are in the set, and the set's `recipe_id` changes because of a key the set leaves out.
  - The thresholds set is not affected: its rows include the withheld keys.
  - **Fix.** Compute the grade set's `tune_run` after the withheld filter, and give that set its own recipe.
  - **Rule:** code-check.md "One fact derived twice"

## Checked and found sound (no finding)

- **Round 2 fixes, gating.**
  - The crate check is gated on `!main_only` (0320:234). DEV=1 and GRADIENT=fwa_gradient quit before grading, so a pre-spec score cache (`sc$spec` NULL, read only for fwa_gradient) never reaches `knw_grade_receipt_write()`.
- **Round 2 fixes, keep path.**
  - The keep path now requires an existing record (`file.exists(grec) &&`). A kept table's receipt must name the record's `grades_md5`, and the record is held to the table by md5.
  - Nothing writes a receipt outside the pass that graded the table.
- **0325's record check.**
  - It covers every grade table, withheld ones included.
  - It runs before the thresholds write and before both publishes, so a refusal publishes nothing.
- **The archive's receipt check.**
  - It reads the record from `f$source[2]`. The receipt row is appended last, so `source_md5` stays aligned.
- **Promotion.**
  - A fitted key's `^<key>_` files carry its receipt.
  - An unfitted key keeps only its summary and curve record. Its tracked record and receipt go through `removed`, and 0320 unlinks both in the run (0320:405-407).
- **`.gitignore`.** Tracked `data/tune/*_grades_receipt.json` is not ignored. The candidate and publish receipts are.
- **`knw_publish()`.**
  - On a republish, `receipt.json` goes up before the manifest.
  - Only 0325 calls it, always with a receipt, so no published set is left with a stale receipt on S3 from a later publish that has none.
