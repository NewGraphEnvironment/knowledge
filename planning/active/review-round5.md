## Checklist read

Read all five indexes (code-check, -r, -shell, -spatial, -python); code-check-python.md in full; code-check.md's
`## Mechanisms` prose (every H3, table rows skipped) and "Documentation Staleness". The diff (`git show 0afe1db9`)
is prose in `scripts/README.md`, `CLAUDE.md`, two rebuild logs and three verdict-CSV notes; it touches no R, shell,
spatial or Python code, so no tool-specific section of -r, -shell or -spatial applies beyond their indexes.

Checked and true (no finding):
- "five other passages here": `git grep -n cred#48 -- scripts/README.md` gives lines 24, 173, 273, 497, 508 outside
  the bullet (265-272): five. CLAUDE.md:168, 0150-store.R:17 and :250 carry cred#48, so the grep finds every copy.
- "1 and 10" image-only scans, "XDKIU3UA, stuart_chislett1979", "kept as one-chunk documents": the scratchpad dumps
  give bull_trout_grayling 197 -> 196 (only XDKIU3UA, n_chunks 1) and habitat_modelling 414 -> 404 (ten origins, each
  n_chunks 1, the same ten attachments #217's table lists). bull_trout 173 -> 173, 0 moved.
- "chunk counts also moved on documents the older builds had chunked": 24 and 167 documents moved; none of
  bull_trout_grayling's 24 is in the update log's list of attachments new to the store.
- Verdict notes: `do_replace()` (0275:277-301) raises on md5 mismatch only when the replacement attachment is in
  Zotero (`named and local`), and returns "done" when it is and the original is trashed, whether or not the file is
  present. All three replace rows are completed (BHHDYTJI, RVFQ4NDZ "done" in 20261115_0275_bull_trout_ocr_dryrun2;
  AHE9BFQQ replaced in #172), so the notes hold for them. CSV: 35 rows, every row 7 fields via `csv.reader`, no
  overflow key via `csv.DictReader`.
- cred 0.7.0: `crd_store_build()` names skipped PDFs only through `.crd_store_report()`'s `warning()`; 0150's build
  path prints no origin list, so "names them only in a warning" holds.

## Findings

- **[severity: bug]** scripts/README.md:269 — "names them only in a warning R cuts after six" states the case in hand
  as a rule. R truncates a warning message by length, `getOption("warning.length")` = 1000 characters, not by entry
  count: the habitat_modelling warning's text up to "[... truncated]" is 1001 bytes
  (`awk '/^Skipped 10 PDF/,/truncated/' scripts/logs/rag/20261115_rebuild_habitat_modelling.log`), and it cut
  partway through the seventh entry, after printing that entry's key. How many names survive depends on the
  filenames' lengths (a store whose skipped files have short names shows more; long ones fewer). A reader who sees six
  or fewer names will take the list as complete when it may not be. Say it is cut at about 1000 characters.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a compression that gained a quantifier
    is unsupported until checked against the source)

- **[severity: bug]** scripts/logs/rag/20261115_rebuild_habitat_modelling.log:134 — "the warning above names 6": the
  warning above (lines 125-132) names seven citation keys; the seventh, `stuart_chislett1979AspectsLife`, is printed
  before "( [... truncated]". Six entries are complete; seven are named. The count was taken from the complete lines,
  and it is what README:269's "cuts after six" was written from.
  - **Rule:** code-check.md "One fact derived twice" (a count stated beside the artifact it counts, not taken from it)

- **[severity: fragile]** scripts/0150-store.R:250-251 (and :16-18, scripts/README.md:24) — the round-4 fix added a
  step to the rebuild rule in one copy only: README:268-270 now says a rebuild drops image-only scans an update kept
  and to "compare the rebuilt store's origins with the updated store's before the push", while README:270-271 calls
  CLAUDE.md, 0150's usage and 0150's message after an update repetitions of "the rule". CLAUDE.md points to the
  bullet, but 0150's printed remedy, the text an operator sees the moment the update finishes, says only "rebuild it
  with ACTION=build OVERWRITE=TRUE and the same COLLECTIONS before the push", with no comparison and no pointer to the
  README; the usage block and README:24 the same. And the build path prints no before/after origin diff (0150-store.R
  diffs origins only for `action == "update"`), and its skipped list is the truncated warning above. Following the
  printed instructions rebuilds and pushes a store with documents silently dropped (#194's would have lost 11 without
  the hand comparison). A remedy repeated across sibling messages is one claim written many times; adding a step to
  one copy leaves the others giving the old remedy.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a remedy in the error message is code the
    caller will run; a remedy repeated across sibling messages is one claim written many times)
