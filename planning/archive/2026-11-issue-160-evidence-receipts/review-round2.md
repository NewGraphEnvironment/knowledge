# Branch review, round 2 (#160)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows skipped (evidence blocks skipped). Rules
  that stand alone, Security, Spreadsheets: headings only, none applies to this diff.
- code-check-r.md, by heading, full section read: "`$` on a list partial-matches, so a longer sibling key answers for a
  missing one"; "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent";
  "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never
  fires"; "`identical()` on two reader results tests the reader, not the file"; "`on.exit()` at a script's top level
  never fires"; "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests"; "Read-back shape must
  match write-back shape"; "R's `yaml` returns a mixed int/float sequence as a list, not a numeric vector". The rest
  (about 120 headings) not read: their tools or shapes are not in the diff.
- code-check-shell.md: no section read (the diff has no shell; its `system2()` calls are the R rule above).
- code-check-spatial.md: no section read (the diff touches no spatial code; the hydrologic zones step is unchanged
  but for one sha256).

Checked and clean: round 1's two fixes (`.knw_sha256_files(root =)` hashes the same relative paths wherever link is
installed, and link 0.78.x's default bundle has no `extends` and no file outside `extdata/configs/default`, measured
with `lnk_config("default")$chain` and its files' dirs; 0320's keep-check compares the kept receipt's
`recipe$inputs$evidence` with the value read at the start, identical in both the `recipe_id` and `version_id` forms,
and no `$` partial match reaches `evidence` in a pre-#160 receipt's inputs). The hydrologic zones zip's md5 is the same
in all 14 tracked ledgers, so hashing it does not move the recipe per download. The changed test files pass
(evidence_receipt 29, grade_receipt 50, receipt 93, publish 30, archive 90; 0 failed, 0 errors).

## Findings

- **[fragile]** R/archive.R:129-136 (with knw_archive_pull, R/archive.R:532-535) — the evidence receipt's bytes enter
  the MANIFEST, so the archive's `evidence_id` changes on every write of the receipt, not only when the build's tables
  change: crate's receipt carries `context.time` (and 0310's run ids), so two writes of one receipt differ in bytes
  (measured: two `knw_evidence_receipt_write()` calls on the same tables 1 s apart, `same bytes: FALSE`). Before #160 a
  0310 rerun whose visit tables came out byte-identical (#160's own rebuild gave three identical tables) kept the same
  `evidence_id`; now it gets a new one. 0320 keeps a grade across such a rerun (same `evidence_md5`, same recipe_id), and
  promotion by key is allowed onto it, so a key archived before the rerun sits under M1 and one archived after under M2
  though `evidence_md5` is one value. `knw_archive_pull()` for both keys (the documented `PULL=TRUE scripts/0336` of the
  published keys) then stops with "the keys' runs name 2 evidence builds", and each archive call stores the whole
  evidence build again. CLAUDE.md says "every build archived with one has its own `evidence_id`", which is true per
  0310 run, but the pull's one-build refusal was written when an id was the tables' identity.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile]** R/archive.R:536-563 (knw_archive_pull) — a restore of a build archived without a receipt (every build in
  the index today: all were archived before #160) leaves an `evidence_receipt.json` from another build in
  `data/fdis/derived` untouched, because the pull walks only the index's rows. The pull refuses each visit CSV present
  with another md5, so a user moves those aside as told; the stale receipt stays, and every reader of the restored
  build then refuses it: `.knw_evidence_recipe_id()` says the receipt "does not describe ... visits_link.csv ...
  rebuild the evidence (scripts/0310)", which stops 0320 at its start, `knw_grade_receipt_write()`, and
  `knw_archive_plan()`. The remedy named is wrong (the build is the archived one; the receipt is the stray), and a
  rebuild would replace the restored evidence. Reproduced in a copy of the repo: archive a run without a receipt, put a
  receipt of other tables in `dest/data/fdis/derived`, `knw_archive_pull()` succeeds, the receipt is still there, and
  `.knw_evidence_recipe_id()` on the restored directory returns the refusal above. The pull could refuse (or remove)
  an `evidence_receipt.json` in the target directory when the archived build holds none, as it refuses any other file
  that is not the archive's.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## Triage (main session)
1. The evidence id moved with the receipt's bytes: real, and inside phase 5's design rather than round 1's fixes. The
   receipt is stored in the build's folder outside the MANIFEST, so the id is the tables' again (a rewrite over the
   same tables keeps it; tested). A restore takes the receipt last archived for the id.
2. A stray receipt survived a restore of a build archived without one: real. `knw_archive_pull()` refuses before
   writing anything (tested, and the test goes red with the refusal removed).
CLAUDE.md and the research file had said every build with a receipt gets its own id: corrected.
