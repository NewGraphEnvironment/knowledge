# Code-check round 4 (#194 branch, base 89ee4d3a, to b0b08f62)

## Checklist read

- The five indexes, in full: code-check.index.txt, code-check-r.index.txt, code-check-shell.index.txt,
  code-check-spatial.index.txt, code-check-python.index.txt.
- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (via `mech.txt`, table rows and evidence blocks
  skipped; the longer ones read to their opening paragraphs and remedies), "A guard's scope, escape hatches, and
  remedies" including its "A remedy repeated across sibling messages is one claim written many times" passage, and
  "Documentation Staleness" in full.
- code-check-r.md: "Regenerated binaries churn git even when nothing changed" (index line; the diff's only R change is
  a `message()` inside an `if`). code-check-shell.md and code-check-spatial.md: index lines only; the diff uses no
  shell, sed, git plumbing, terra, sf or GDAL.

## 1. Round 3's fixes themselves

- `scripts/0150-store.R` parses (`parse()` ok). The new message sits inside `if (action %in% c("build", "update"))`,
  after the build/update dispatch and under `if (action == "update")`; it runs only after `crd_store_update()` returned,
  so it cannot fire for build, query or push, and a failed update stops before it.
- The rule's command is right against cred 0.7.0: `crd_store_build(overwrite = TRUE)` passes `overwrite` to the
  store's creation, which replaces the file, so the rebuild is a fresh file.
- 32 / 71 / 76 % and "`habitat_modelling` 3.6 GiB holding 0.9" agree with cred#48's table (699 / 4,026 / 11,312 free
  blocks; 896 MiB used of 3.6 GiB) and findings.md:66. The three rebuild logs' line 1 now give each store's share.
- "never `fraser`, `peace` or `pine`" (README:267-268) holds: the update guard refuses all three.
- One new sentence is false (finding 1).

## 2. The enumeration

Rerun of its set (`git grep -n -E "ACTION=update|crd_store_update"`, tracked, outside the archive and logs) gives the
same rows. A wider grep (`update` within a line of `push`, `store`, `0150` or `cred`, and research/, R/, data-raw/,
vignettes/, inst/) finds one passage the set's regex cannot see (finding 3). The rows' verdicts hold, but they
contradict README:267's new sentence: five rows are marked "states it" (finding 1).

## 3. The mechanism over the rest of the branch's added prose

Checked every quantified sentence the branch adds to CLAUDE.md, scripts/README.md, the two verdict notes and the
2026-11-15 log comments: "all three" (README:492), "neither unit" (README:488), "unlike sturgeon and cutthroat"
(both are outside `habitat_modelling`'s list: 0150 resolves a collection's direct members only, so `9U54XAND` does not
pull in `species/sturgeon` or `species/westslope_cutthroat`), the update logs' "neither HYSNCHBC nor N2IJDSIN ...
both had been before", and the bull_trout store's contents (the two registry PDFs and the 2025 COSEWIC report are
among the local store's 173 origins). These hold. Two do not (findings 2 and 4).

## Findings

- **[severity: fragile (false doc)]** scripts/README.md:267 — "This is the one place the rule is stated" is false.
  The full rule (cred#48, the 32 to 76 % figures, `ACTION=build OVERWRITE=TRUE` with the same build list, before the
  push) is also stated in CLAUDE.md:167-170, in `scripts/0150-store.R`'s usage comment (:16-18) and its printed message
  (:249-252), and in short form at README:24, :172-173, :492-493 and :503. `planning/active/enumeration_round3.md`
  marks four of these rows "states it". The sentence matters when cred#48 is fixed: a maintainer who trusts "the one
  place" removes the rule from the README bullet and leaves CLAUDE.md, the usage comment and the message every update
  prints telling people to rebuild. It is the round-3 mechanism (a remedy held in several places) in the sentence
  written to close it. Fix: drop the sentence, or list the places that carry the rule.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/README.md:263-268 and CLAUDE.md:167-170 (the rule), and
  scripts/logs/rag/20261115_rebuild_bull_trout_grayling.log:2 and 20261115_rebuild_habitat_modelling.log:2 — the rule
  treats the rebuild as compacting the updated store, but a rebuild re-reads every PDF and is not the same content. On
  this branch it dropped 1 document from `bull_trout_grayling` (197 updated, 196 rebuilt) and 10 from
  `habitat_modelling` (414, 404), the no-text scans older builds held as one-chunk documents, and moved chunk counts
  (task_plan.md:160-161). Those 196 and 404 are what went to the bucket (push logs, `"documents": 196` / `404`). The
  update lists every document it drops (README:263); the rebuild names the no-text PDFs it skips only in a warning
  that R truncates (rebuild_habitat_modelling.log:133 `[... truncated]`, findings.md:67: 6 of 10 named). So following
  the rule takes documents out of a published store with no complete list, and nothing in the rule says so. The
  two rebuild logs also keep line 2's pre-run expectation ("197 documents" / "414 documents, the same origins and
  per-document chunk counts as the updated store") with no note that the run missed it, unlike the update logs,
  which carry post-run notes. Fix: say in the rule that a rebuild can drop documents the update kept (unreadable
  PDFs, #217) and compare origins before the push, and note the miss in both logs.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" (the substitute path lacks the
    update's report of what it drops)

- **[severity: fragile]** scripts/README.md:269 — "**Push after every local write** (`0152` ingest, `0156` dedup, a
  rebuild or update)" still gives update-then-push, with no pointer to the rule. The enumeration's regex
  (`ACTION=update|crd_store_update`) cannot match a bare "update", so the passage is outside its set, and its closing
  claim "Nothing in the set gives update-then-push without the rule or a pointer to it" is true only of the set as
  grepped. Low risk, since it sits right after the rule's bullet. Fix: "a rebuild (after an update, while cred#48 is
  open, the rebuild is the write to push)", or drop "or update".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (end on an enumeration; a text scan used
    to enumerate under-counts)

- **[severity: fragile]** data/zotero_attachment_verdicts.csv:34-35 — "(the file is ignored, rebuilt by that
  command)". ocrmypdf's output is not byte-reproducible. Measured: ocrmypdf 17.4.2 `--deskew` run twice on the same
  one-page image PDF gave md5s `1a93e2a0...` and `3716ff11...`. `0275`'s `do_replace()`
  (scripts/0275-zotero-attachments-tidy.py:285-286) raises "is named ... but is not ... (md5 differs)" when the stored
  replacement and a local file both exist with different md5s. It checks this before the `done` test at :287. On a
  machine without the ignored file, each row reads `done`. On one that rebuilds the file as the note says, a re-run
  of `0275` fails both rows. Row 2 (#151, tredger) has the same note and the same trap; this branch copied it. Fix:
  say the file is not reproducible and that a re-run needs it absent, or the stored attachment downloaded.
  - **Rule:** code-check-r.md "Regenerated binaries churn git even when nothing changed" (a format with run-varying
    metadata gives a different file on every rebuild)

Outside the tracked tree, for the record: NewGraphEnvironment/cred#48, filed by this branch's work, is titled "...
an updated store is mostly empty space", and its body says "an updated store is mostly free blocks". That is the phrase
round 3 corrected in the bull_trout log, and it is false for its own first row (`bull_trout`, 32 %).
