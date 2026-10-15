# Code-check round 3: branch 48-first-winter-size-rows-abstracts

Reviewer: subagent, 2026-10-15. Scope: diff3.patch (pkg/R/literature.R, pkg/R/ip.R, their tests, 0280, 0270,
temperature_additions.csv), with the round 1 and 2 fixes (459b86f, c1d9e0a). Probes ran on a copy of
zotero.sqlite (quick_check ok) and on CrossRef records for the four `pdf = none` DOIs, fetched with a plain
User-Agent. No repository file was changed except this one.

## The mechanism

Every defect so far is one fact derived twice. A property of the group item is decided in one place by one
reader and one rule, then decided again elsewhere by a different reader with its own rule. The properties are
"holds a PDF", "carries an abstract", "is this work" and "what the abstract says". The readers are 0270 through
the Web API, 0280 through a sqlite snapshot, CrossRef's record, the local disk, and a normaliser on one side
only. Nothing ties the two derivations to one definition, so the code only works while they happen to agree.
Round 1's two findings were a CrossRef record standing in for the group item, and files on disk standing in for
the group's attachments. Round 2's finding was a normaliser applied to the CrossRef title only.

Where that mechanism reaches in this diff:

| fact | derivation A | derivation B | verdict |
|---|---|---|---|
| holds a PDF | 0270 `has_pdf()`: Web API child, pdf, imported, **md5 set** | 0280 `pdf_items`: attachment row, pdf, linkMode 0/1, `storage:` path, **any hash** | **disagree**: finding 1 |
| holds a PDF (standalone copy) | 0270: children only | 0280: `parentItemID` only | agree (both blind to a standalone PDF of the work). 211 live standalone PDFs, none titled like the four works. Sound for now. |
| carries an abstract | 0270: Web API group item, `strip()` | 0280: sqlite group item, `trimws()` | same object, differs only by sync lag. Sound. |
| what the abstract says | 0270 `plain()`: tags to a space | 0280 `value_in_quote()`: unit exponent expected fused (`m2`) | **disagree**: finding 2 |
| is this work (title) | `same_work()` side a | `same_work()` side b | `plain()` reaches both sides. Checked offline: markup, `<sub>`, `&amp;` and the f88-060 title all match. Sound. |
| is this work (search) | `group_copy` `q=` words | Zotero substring match on stored markup | words only. Round 2 checked four DOIs live. Sound. |
| `<…>` in a title read as markup | `same_work` side a | `same_work` side b | symmetric. No group title has an angle bracket that is not markup. Sound. |
| allowed quote_source | `knw_literature_vocab()` | `knw_ip_read()` `setdiff` | refused on both registry columns, with a test. Sound. |
| passing status | `check_row()` literal `verified_abstract` | `PASS` | same literal. Sound. |
| abstract row ↔ `pdf = none` addition | evidence `citation_key` | additions `DOI` | nothing links them (round 1 accepted). Not re-reported. |

## Findings

- **[low]** scripts/0280-literature-verify.R:155-165, with 0270:227-236. This finding sits inside round 1's fix.
  `pdf_items` counts every PDF attachment row as a held PDF, including rows that have no file anywhere. 0270's
  `has_pdf()` excludes exactly those rows: they have no md5, being "an attachment row left by an upload that
  failed after its first step".
  - Measured on the snapshot: 1,528 live parented group PDF rows. All 1,516 whose file is on disk carry a
    `storageHash`. All 12 whose file is missing have `storageHash IS NULL`. So round 1's premise, "12 PDFs in the
    group but not downloaded here", was in fact 12 file-less stubs, and nothing in the group is held but not
    downloaded.
  - The consequence: give an abstract-only work's item such a stub. 0270 reports `no-pdf: abstract only` and
    passes. 0280 refuses the row as `abstract_but_pdf_held`, and its stated remedy, re-quoting from the paper,
    cannot be done because no paper exists. The check fails closed, but with the wrong diagnosis.
  - Not live: none of the four abstract items has any attachment.
  - Fix: add `ia.storageHash` to the `group_pdfs` query and take `pdf_items` from rows where it is not NULL. That
    is the same rule as `has_pdf()`'s md5, and it keeps round 1's case of a hash set with the file absent.

- **[low]** scripts/0270-habitat-collection-build.py:326-334 (`plain()`), as read by 0280:363-367
  (`quote_numbers()`). `plain()` turns every tag into a space, so an inline superscript or subscript splits away
  from its base. CrossRef's `/m<jats:sup>2</jats:sup>` becomes `/m 2`.
  - This is live on the snapshot: bradford_etal2001Ecologyjuvenile's stored abstract reads "density of >0.5/m 2".
  - `quote_numbers()` drops a unit exponent only when it is fused (`m2`). Against an abstract the exponent is
    therefore a free number, and a row with value 2 would verify against a quote holding "/m 2". The same split
    turns `10<sup>-3</sup>` into "10 -3", which reads as a range.
  - This widens what the gate accepts, in the direction its own header (lines 192-197) warns against. It is not
    live: no committed abstract row quotes such a span. Row 1142 quotes another sentence of that abstract.
  - Fix: map inline tags (`sup`, `sub`, `i`, `b`, `italic`, `bold`, `sc`, with or without `jats:`) to "" and block
    tags to " ". Then re-write the stored abstract of any item 0270 already created, because the stored text
    outlives the fix (bradford_etal2001 is one).

## Checked and found sound

- 0270's `pdf = none` branch:
  - `ABSTRACT-MISSING` is upper case and fails the run.
  - `steps[-1]` is replaced only after `no-pdf`, so `ADD-FAIL` survives.
  - `pdf present` leaves the refusal to 0280.
  - The dry-run `item.get` fallback is unreachable, since a dry run with no `gkey` returns at line 400.
- 0280's abstract path:
  - `resolve(abstract = TRUE)` sees one id, because ambiguous and missing ids return first.
  - `group_abstracts` is unfiltered for deletion but is reached only through live ids.
  - `quote_source` cannot be NA on a cited row (knw_literature_read:225), so `abstract = NA` cannot reach `if`.
  - Registry quotes go through `check_row()` with `abstract = FALSE` in practice, because the vocabulary refuses
    the value.
- `plain()` strips tags before `html.unescape()`, so CrossRef's `&lt;90` and `&gt;90` survive as `<` and `>`.
  Checked on z97-007: rows 1139 and 1140 depend on it.
- The `<jats:title>` strip with attributes (`content-type=`) does not match and leaves "Abstract" in place. That
  is harmless: a quote that spans it fails closed.

## Triage (2026-10-15)
- Finding 1 (inside round 1's fix): confirmed; `pdf_items` now requires `storageHash`, matching `has_pdf()`'s md5 rule.
- Finding 2: confirmed; `plain()` drops inline tags (sup, sub, i, b, italic, bold, sc, ...) without a gap and turns
  other tags into a space. Stored abstracts are brought to the current form by 0270's abstract-only branch, which
  PATCHes a group item whose abstract differs from CrossRef's; it changed only bradford_etal2001 (">0.5/m 2" ->
  ">0.5/m2"), and a dry re-run is a no-op.

## How the loop ended: enumeration
Round 3 found a defect inside a round-1 fix, so a quiet round would not end it. The reviewer named the mechanism
(one fact derived twice by different readers) and enumerated every place it reaches in this diff (table above:
9 facts). Two disagreed; both are fixed, and the other seven were sound as found. With the fixes, every row of
that table agrees.
- Rendering choice: `10<sup>-3</sup>` now reads "10-3", which the gate takes as a range, exactly as it reads a PDF
  text layer (pdftotext prints superscripts inline: "m2", "10−3"). An abstract therefore reads the same as the
  paper's own text would; the gate's handling of inline exponents in PDFs is unchanged by this branch.
