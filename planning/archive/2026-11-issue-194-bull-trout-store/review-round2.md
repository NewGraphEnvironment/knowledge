# Code-check round 2 (#194 branch, base 89ee4d3a)

## Checklist read

- code-check.index.txt, code-check-r.index.txt, code-check-shell.index.txt, code-check-spatial.index.txt,
  code-check-python.index.txt: in full (the five indexes).
- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped, via `mech.txt`). Standing-alone
  sections read by heading: none beyond the index lines (none names a tool or shape this diff uses beyond
  "Documentation Staleness", whose index bullet is its rule). Not read in full: the remaining 26 standing-alone,
  Security and Spreadsheet headings.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: no full section read (index lines only). This round's
  diff is docs, CSV rows and planning prose plus a three-field tuple widening in a Python script that round 1
  covered; no R, shell or spatial code changed. All headings in those three files not read in full.

## Findings

- **[severity: fragile]** CLAUDE.md:168-169 — "Read `pragma database_size` before a push, and rebuild
  (`ACTION=build OVERWRITE=TRUE`) where it is high." is unscoped: "before a push" covers every store, and the same
  file says to push after `0152` ingest and `0156` dedup, which write `fraser`. Measured read-only today (md5
  unchanged before/after): local `fraser.duckdb` is 700 MiB with 1,564 of 2,800 blocks free (56 %), so the rule as
  written fires on `fraser`. But `fraser`, `peace` and `pine` hold documents from outside Zotero storage, and the
  harvest guard in `scripts/0150-store.R:209-224` runs only for `ACTION=update`; `ACTION=build` has none.
  `cred::crd_store_build(overwrite = TRUE)` (cred 0.7.0) calls `ragnar_store_create(overwrite = TRUE)` before ingesting
  and `unlink(store_path)` on any failure, so a rebuild replaces the harvest store with a Zotero-only one (or deletes
  it if the build fails), and the "push after every local write" rule then carries that to the bucket. `0150`'s own
  header even documents a build line for `peace` (`ACTION=build STORE=peace COLLECTIONS="pine - PINE,peace arm -
  PCEA"`). The README's version (scripts/README.md:264-265) is safe only because it sits inside the `ACTION=update`
  bullet, which already refuses those stores. Fix: scope the CLAUDE.md sentence to cred-built stores ("a store `0150`
  can update"), and say that `fraser`, `peace` and `pine` are not rebuilt this way.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a remedy is code the caller will run:
    run it for every input the clause can receive)

- **[severity: bug (false doc)]** scripts/README.md:490 — "A build, not `ACTION=update`, while
  NewGraphEnvironment/cred#48 is open, because an update leaves the file mostly free blocks." The branch's own
  measurement (cred#48's table, findings.md:66, task_plan.md:157) has `bull_trout`'s update at 32 % free blocks, so
  "mostly" holds for two of the three updates, not as a property of an update. It also leaves the README giving two
  procedures for the same stores: line 167 ("after a library change, ACTION=update ... brings a store up to date") and
  the `0275` bullet (~line 497, "a cred-built store that holds one is brought up to date with `0150 ACTION=update`")
  still send a `VHWEK6RE` change to `ACTION=update`, and line 264-265 says update then rebuild only "where most blocks
  are free", which the `bull_trout` case (32 %) would not trigger. A reader following the 0275 bullet after a
  `species/bull_trout` replace gets the update path the new paragraph forbids. Fix: state the measured range (32 to
  76 %) and make the rule one rule (either "check `database_size` after any update and rebuild where high" or "these
  three: build, not update"), pointing the line-167 and 0275 sentences at it.
  - **Rule:** code-check.md "Documentation Staleness"

- **[severity: fragile (evidence)]** scripts/logs/rag/20261115_update_habitat_modelling.log and
  20261115_update_bull_trout_grayling.log — each prints "150 added, 2 dropped" / "164 added, 2 dropped" followed by a
  bare `dropped:` with no entries. `0150-store.R:243` prints the dropped origins on the lines after it
  (`message("dropped:\n  ", paste(setdiff(before, after), collapse = "\n  "))`), so the committed logs had those
  path lines deleted, not rewritten. The duckdb `ℹ /var/folders/...` line is missing the same way in
  20261115_update_bull_trout.log. task_plan.md:162 says the logs were committed with "home paths as `~/` (G6)";
  they were filtered instead, and the one record of which two documents each update dropped (the expectation was
  HYSNCHBC and N2IJDSIN, the trashed scans) is gone from the tracked evidence, while the bare `dropped:` reads as an
  empty list beside "2 dropped". The stores have since been rebuilt, so this cannot be re-derived from them. Fix:
  either restore the two lines per log as `~/Zotero/storage/<key>/<file>` from wherever the raw output is kept, or
  correct task_plan.md:162 and note in each log that path lines were removed.
  - **Rule:** none

- **[severity: minor (false record)]** planning/active/progress.md:41 — "`bull_trout` built 17:18–17:47Z"; the build
  log it rests on (scripts/logs/rag/20261113_build_bull_trout.log) says `start 2026-11-13T17:26:39Z` and
  `exit 0 at 2026-11-13T17:46:56Z`. Either an earlier attempt started at 17:18 and is unrecorded, or the start time
  is wrong.
  - **Rule:** none

## Checked and holding

- CLAUDE.md "76 % free blocks (3.6 GiB holding 0.9)": cred#48's row, 3,584 used + 11,312 free 256 KiB blocks =
  3.64 GiB, 896 MiB used, 75.9 %.
- Verdict notes: 14,541 and 51,642 words and the md5s match 20261113_ocr_bull_trout.log; the 0275 live record
  (8PADNGFE, PWRE9XAM live with the OCR md5s; HYSNCHBC, N2IJDSIN trashed) matches the rows' attachment keys and paths.
- task_plan/progress counts against logs: bull_trout build 171 docs / 27,589 chunks; update 2 added, 0 dropped, 173,
  28,215 chunks; bull_trout_grayling 35 to 197 (164 added, 2 dropped); habitat_modelling 266 to 414 (150 added, 2
  dropped); rebuilds 173 / 196 / 404 docs, 07:00:42 to 07:44:14Z; pushes 07:47-07:49Z, ETags matched at 8 MiB (46, 53,
  116 parts); manifest documents 173 / 196 / 404. Local rebuilt bull_trout is 366.2 MiB with 0 free blocks (measured
  read-only, md5 unchanged).
- Query verdicts (Q1 partial, Q2 3/4, Q3 2/3, Q4 hit) match the logged top rows; `speciesatriskpublicregistry2026BullTrout`
  is the South Coast page (additions row 129) and the Western Arctic page is member `speciesregistrycanada2020BullTrout`.
- README store contents: the bull_trout store holds post_etal2012 (COSEWIC 2012), the 2025 COSEWIC report, both
  registry pages, BC's 2023 plan, rodtka2009 (Alberta), the US recovery plan, by origin.
- `VHWEK6RE` is in habitat_modelling's 10-key build line and the rebuild log; WEUFTSDC and TIDR3PNN are not.
- The rebuild's loss of 10 (habitat_modelling) and 1 (bull_trout_grayling) no-text scans is recorded in #217 and
  progress.md; per #217 they were one-chunk documents with no searchable text, so nothing searchable was lost.
