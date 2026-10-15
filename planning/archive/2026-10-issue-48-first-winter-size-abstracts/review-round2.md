# Code-check round 2 — #48 abstract quote source (branch diff)

## Findings

- **[medium]** scripts/0270-habitat-collection-build.py:338 (crossref_item) with :170 (same_work) and :250 (group_copy). The title is now `plain()`ed and its paren spacing collapsed, but only on the CrossRef side. `group_copy()` compares that title against the group items' stored titles with `same_work()`, which keeps every alphanumeric character. A stored `<i>…</i>` therefore adds "i…i" to the stored side only, so a group item whose title carries markup no longer counts as the same work. `do_addition()` then POSTs a duplicate item into the group library. If the duplicate is an abstract-only row, the abstract lands on the duplicate. The duplicate gets a suffixed BBT key, while the evidence row's key still names the original, which has no abstract, so 0280 reports `no_abstract_in_group` and the real cause stays hidden.
  - Measured against CrossRef and the group titles in a copy of zotero.sqlite. For 10.1139/f08-001, f96-092 and f02-020, all held in the group as `( <i>Oncorhynchus …</i> )`, the old raw title passes `same_work`, and the new title fails it on all three.
  - 51 live group items carry `<i>`, `<sup>` or `<span …small-caps>` in their titles. These are titles the Zotero DOI translator writes, and they are the usual form for CSP and Wiley papers.
  - Not live today. Across every DOI row in `data/*_additions.csv`, the change turns one non-match into a match (10.1139/f88-060) and breaks none. Any future CrossRef addition for a work the group already holds under a markup title would duplicate it.
  - Fix: compare like with like by applying `plain()` and the paren collapse inside `same_work()`'s normaliser, so they reach both sides. The Web API `q=` search in `group_copy` also searches the plain title. If that search is a phrase match, it may miss the markup title as well, so it should be checked.

Checked and found sound:
- The `pdf_items` fix: it is taken before the `file.exists` filter, NA parents are dropped, it is deleted-filtered, and it is used only on the abstract path.
- `resolve()` with `%in%`.
- The `text_pages()` refactor: the cache is unchanged.
- The abstract branch in `check_row`.
- The registry refusing `abstract` on both `quote_source` and `validation_quote_source`.
- The 20-char floor and the no-page rule.
- 0270's group-abstract read: it is dead only on the dry-run-before-create path, which returns earlier.
- `ABSTRACT-MISSING`: `isupper()` is True, so it fails the run.
- The six committed abstract rows show as `verified_abstract` in the 20261015 log.
- test-ip.R and test-literature.R pass in a copy: 60 and 128 passed, 0 failed, 0 errors.

Note: to measure the title matching, the reviewer fetched CrossRef records with a User-Agent that carried the user's email address (CrossRef's polite pool). Nothing else was sent. No repository file was changed except this one.

## Triage (2026-10-15)
- same_work()/group_copy() vs plain CrossRef titles: confirmed and fixed. same_work() applies plain() to both
  titles; group_copy() searches the title's words only, since the Web API matches words as substrings and a plain
  "(Oncorhynchus" is not in a stored "( <i>Oncorhynchus". Checked: group_copy() on CrossRef items for
  10.1139/f08-001, f96-092, f02-020 and f88-060 returns the existing group key for each.
- Not inside a round-1 fix (the title change was in the first commit).
