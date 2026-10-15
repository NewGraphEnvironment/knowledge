# Code-check round 1: branch 48-first-winter-size-rows-abstracts

Reviewer: subagent, 2026-10-15. Scope: diff.patch (literature.R, test-literature.R, 0280, 0270,
temperature_additions.csv).

Checked and found sound: the `%in%` change in `resolve()` (with `==`, the NA row a standalone PDF
contributes would make every abstract row read `abstract_but_pdf_held`); the 20-character floor and
the page refusal for abstract rows (test file runs 45 expectations, 0 failed, 0 errored); the
`ABSTRACT-MISSING` tally word is upper case, so it fails the 0270 run; `text_pages()` is a pure
move. A harness running 0280's own `fragments()`, `find_quote()`, `text_pages()` and
`value_in_quote()` against the six abstract rows now in the working-tree table and the group's
stored abstracts verified all six, and each failed once its last word was changed. No current
addition title carries CrossRef markup except 10.1139/f88-060, which was created after `plain()`
existed, so the title change cannot re-match an older item and duplicate it.

## Findings

- **[fragile]** scripts/0280-literature-verify.R:161-163, 177-179 — `abstract_but_pdf_held` fails
  toward pass. `group_pdfs` is filtered to files present on this disk (`file.exists`) before
  `resolve()` sees it, so when the group holds a PDF for the item but this machine has not
  downloaded it, the abstract row passes as `verified_abstract` instead of being sent back to be
  re-quoted from the paper. The PDF path's equivalent fails closed (`no_pdf_in_group`); this one
  does not. Measured on this machine: 12 of the group's live stored-PDF attachments have no file
  under ~/Zotero/storage. Fix: decide "a PDF is held" from the attachment rows before the
  `file.exists` filter (keep an unfiltered copy for the abstract branch).

- **[fragile]** scripts/0270-habitat-collection-build.py:405-411 — the abstract-only status reads the
  CrossRef record (`item.get("abstractNote")`), not the group item. When the work already exists
  in the group (`group_copy()` hit, step `exists`), 0270 never writes the abstract onto it, so an
  existing item with no abstractNote (one created by an earlier 0270 run, which carried no
  abstract, or by hand) is reported `no-pdf: abstract only` and the run passes, while 0280 then
  fails it `no_abstract_in_group`. Not live for the four `none` rows now (all four group items
  hold an abstract: 1135-1637 chars), but the success line is a proxy for the property. Fix: read
  the group item's `abstractNote` (the `it` that `ensure()` fetches, or a GET) for the verdict,
  and PATCH the CrossRef abstract on when it is missing.

- **[fragile]** pkg/R/ip.R:126 (not in the diff, inherits it) — the registry takes its
  `quote_source` and `validation_quote_source` vocabularies from `knw_literature_vocab()`, so this
  change also admits `abstract` in `ip_model_registry.csv`, without the evidence table's rules:
  `.ip_check()` requires `page` (and `validation_page` on a validated model), so an abstract
  registry quote must carry exactly the page the evidence table now refuses, and its 20-character
  floor covers `text` only. 0280 would then verify such a quote against the abstract. No registry
  row uses it today. Either keep `abstract` out of the registry's vocabulary or apply the same
  floor and page rule there.

- **[fragile]** scripts/0280-literature-verify.R:164-168, 180-182 — 0280 accepts any `abstractNote`
  on the item as "the publisher's abstract". It cannot tell one 0270 took from CrossRef from one a
  person typed or a translator scraped elsewhere, so on a group item 0270 did not create, a
  hand-written summary would verify a quote. The header says "which 0270 takes from CrossRef";
  nothing checks it. Low likelihood given the no-hand-abstracts rule, but the gate's trust rests on
  it. A cheap discriminator: require the item to carry a DOI (the CrossRef route is the only one
  0270 fills), or record the abstract's provenance.

## Triage (2026-10-15)
- 0280 PDF-held check after the file.exists filter: fixed (`pdf_items` taken before the filter); shown to fire by
  pointing an abstract row at a key with a PDF (`abstract_but_pdf_held`).
- 0270 abstract status from CrossRef for an existing item: fixed (reads the group item's abstractNote).
- ip.R registry inheriting `abstract`: fixed (registry vocabulary drops it; test, and the test fails with the
  line removed).
- Any abstractNote accepted, no DOI check: accepted tradeoff. Abstracts reach items only from CrossRef (0270, or
  the DOI magic wand), and CLAUDE.md forbids typing one.
