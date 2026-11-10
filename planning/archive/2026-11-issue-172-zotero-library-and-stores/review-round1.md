# Code-check round 1: branch 172 (b470bfd5...HEAD, planning/ excluded)

## Checklist read

- code-check-python.md: read in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows and evidence blocks skipped; also "Merge PDFs with `qpdf`, and check the merged file". About 40 other headings were judged from the index only.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: judged from the `.index` files only. The R lines in the diff are a few DBI/duckdb read-only calls inside a function: `on.exit` is in a function, and the file's existence is checked before connect. No index line names a pattern those lines use in a way that needed the full text. Shell and spatial: nothing in the diff.

## Method

- Read the full diff and the full text of 0150, 0153, 0270 (changed regions plus the helpers they call) and 0275.
- Read the installed cred 0.7.0 `crd_store_update()` and `.crd_origin_id()`.
- Checked the verdicts and additions CSVs for column counts and JSON validity: all parse.
- Queried a scratch copy of `zotero.sqlite` plus its `-wal`. `quick_check` was ok. Every verdict row's end state already holds in the library.
- Mocked 0275's `do_merge` and `do_replace` in a scratch script. Only the module's helpers were replaced; there was no network and no live Zotero.

## Findings

- **[bug]** scripts/0275-zotero-attachments-tidy.py:126-145 (`do_merge`) and :214-228 (`do_replace`). The end-state check treats "a live child attachment whose `filename` is the target" as "the merged or replacement file is on the server". It never checks the file itself.
  - **How it breaks.** 0153's `upload()` POSTs the attachment item first and only then authorises and uploads the bytes. An `auth-fail`, `s3-NNN` or `register-NNN` therefore leaves a live child carrying that filename and no file (no `md5`). 0270's `has_pdf()` already guards against exactly this row ("an attachment row left by an upload that failed after its first step has none").
  - **What it does here.** The first run raises and marks the row FAILED. The re-run, which the docstring offers as the recovery ("a re-run after a crash between upload and trash finishes the row"), sees `named` non-empty. It skips the upload and trashes every part (merge) or the original (replace). It reports `merged ... parts` / `replaced ...` and reads `done` on every later run.
  - **Result.** The item is left with one live attachment that has no file. Its real PDFs sit in the trash, recoverable only until the trash is emptied. A store update (`0150 ACTION=update`) would then drop the document.
  - **Reproduced** with a mock: a fileless named child plus two live parts. Dry run: "would trash 2 parts (merged file present)". Live: "merged 2 parts into F.pdf", trashing A1 and A2. Re-run: "done". `do_replace` likewise trashed X.
  - **Fix.** Count only a named child with an `md5`, and for a merge compare that `md5` with the merged bytes when they are at hand. Treat a named child without a file as something to re-upload or trash, never as done.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A guard that fails toward pass"

- **[bug]** scripts/0270-habitat-collection-build.py:410-414 (`addition_item`) and scripts/0275-zotero-attachments-tidy.py:114-121 (`creators`). Both treat "no comma" as an organization and split at the first comma otherwise. An organization whose name contains a comma becomes a personal name.
  - **This branch's own row hit it.** data/flow_additions.csv's "Environmental flow needs policy" lists the creator "Ministry of Forests, Lands, Natural Resource Operations and Rural Development".
  - **The item is already filed that way.** In the scratch copy of `zotero.sqlite`, group item KE758PAG (key `ministryofforests2022Environmentalflow`) holds lastName "Ministry of Forests", firstName "Lands, Natural Resource Operations and Rural Development", fieldMode 0. Data rows 1146-1149 of literature_evidence.csv cite that key.
  - **Consequences.** A bibliography renders the policy as a person ("Ministry of Forests, L. N. R. O. and R. D."). The input format cannot express this creator at all. Fixing the creator in Zotero alone would make 0270's `group_copy()` miss the item on the next run, because `_first_last` would compare "ministry of forests" with the full name, and 0270 would create a duplicate.
  - **Fix.** The creators cell needs a way to mark a one-field name (for example a leading `=` or braces). After that, PATCH the existing item, and change both the CSV and the item together. Better BibTeX keeps the key once set (resetKeyOnChange is off), so the cited key should stay; check that after the PATCH.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "Written data outlives the fix"

- **[fragile]** scripts/0150-store.R:219-220. The update guard refuses only origins whose basename matches `^[A-Z]{4}__[0-9]+\.pdf$`. Yet `crd_store_update()` drops every document whose origin is not among the sources it resolves (`removed <- !docs$id %in% ids`). That covers every origin outside `storage/<8-char key>/`.
  - **The name pattern misses real harvest names.** 0152 accepts `^[A-Z]+__` extents of any length. data/corpus_tags.csv lists 20 lowercase `fraser__NNNNN.pdf` harvest files that the regex does not match.
  - **It also misses non-harvest origins.** Any PDF ingested from a local directory (for example data/rag/pdf/... or an old 0150 PDF-directory build) would be dropped without the guard firing.
  - **Exposure today.** fraser is still refused, because it also holds four-letter names. A store with only lowercase-extent or non-harvest local documents would be silently stripped locally, and pushed if the README's "push after update" is followed.
  - **Fix.** Guard on the property itself: refuse when any origin is not under `/storage/[A-Z0-9]{8}/`. That is the same test cred's `.crd_origin_id()` uses to decide what can resolve.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[fragile]** scripts/0275-zotero-attachments-tidy.py:140-146. The merged PDF is uploaded, and the parts trashed, without `qpdf --check` on the result and without asserting its page count equals the sum of the parts. The merged file becomes the item's only live copy, so a bad merge silently replaces good parts.
  - `check=True` does catch qpdf's exit 3 (warnings) during the merge. It does not check the file that leaves.
  - **Rule:** code-check.md "Merge PDFs with `qpdf`, and check the merged file"

planning/active/review-round1.md
