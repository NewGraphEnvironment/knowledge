# Plan review: #194 (Plan agent, 2026-11-12, read-only)

Spawned 07:18Z, delivered about 07:25Z. Verified here, then folded into `task_plan.md` as noted after each finding:
- G1 confirmed: the local `habitat_modelling.duckdb` md5 is `b28ad0ed…`, against the bucket's `4fcc6700…` (266
  documents).
- A2 confirmed: the bucket's `bull_trout_grayling` holds 35 documents (md5 `4846e7a3…`, the same as the local copy).
- G2 confirmed: `addition_item` (`0270:406-408`) takes no `publicationTitle`, `volume` or `issue`.

## Findings (the reviewer's, condensed)

- **G1 (high), folded into Phase 3.** The worktree's `habitat_modelling` is stale. Pull both stores to be updated
  with `ACTION=query VERIFY=TRUE` before any update, and record each md5 against the manifest.
- **G2 (high), folded into Phase 1.** `0270` cannot file Fraley & Shepard 1989 (no DOI) as a complete journal article.
  Add `publicationTitle`, `volume` and `issue` to `addition_item`'s fields. A DOI row is for a journal article only;
  a report with a DOI goes in without it.
- **O1, folded into Phase 3.** The order runs:
  1. the gate;
  2. a verified pull;
  3. the build;
  4. the queries;
  5. the updates;
  6. commit;
  7. **push the branch** (no rewrite after);
  8. the store pushes one at a time, `habitat_modelling` last, each result read and its ETag checked;
  9. commit the trimmed push logs.

  Zotero stays quit from step 2 to step 5.
- **O2 (high), folded into Phase 1 and the rules.** Run the per-field title-page enumeration before the first dry
  run, so fixes are CSV edits. A fix after filing is a CSV row, a PATCH and a no-op dry run, then the PATCHed items'
  keys are re-read. If a key moved: the CSVs and evidence rows, `0280`, and update and push all three stores. Never
  edit the metadata of members whose keys are unpinned.
- **G3, folded into Phases 1 and 3.** Count no-text pages in every PDF to be filed and OCR them with `ocrmypdf
  --skip-text`. Acceptance: documents = keys − no-text PDFs, named.
- **G4, folded into Phase 1.** Decide from the text whether the federal plan adopts the 2023 BC plan; if it does, file
  Part 1 only. The Saskatchewan–Nelson (Alberta) documents are outside the two units.
- **G5, folded into Phase 1.** `0270` cannot see or restore the trash. Restore only when no live group copy exists,
  with a Web API PATCH `deleted: 0`, Al present, before the first dry run.
- **G6, folded into Phase 3.** Committed logs carry home paths as `~/`, and each push log is trimmed to its own
  manifest entry.
- **A1, folded into Phase 3.** Each update writes its expected added keys first; the `N added, M dropped` line must
  match, and every surprise is explained before the push.
- **A2, folded into Context.** `bull_trout_grayling` holds 35 documents.
- **A3, folded into Phase 1.** Set the total MB to upload against the group's storage quota and tell Al.
- **S1, folded into Phase 1.** List the 14 group items to become members as their own source line in the scope check.
- **P1, folded.** Phase 4's two doc items are annotated as drafted in `7a9f4c7a`.

Answers: `0270` handles the existing collection (`find_collection` matches `bull_trout` under `9U54XAND`, and
existing members print `member`). `ACTION=update` is allowed for both stores (built from Zotero; the #172 guard
refuses only fraser, peace and pine). The issue's 20 was 16 keyed live items, 1 live standalone (`P3TMRWQX`, Gill's
PDF) and 3 trashed copies.
