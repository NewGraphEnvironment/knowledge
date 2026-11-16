# Code review, round 4 (#198 branch, `git diff 86088f67...HEAD`, planning/ and scripts/logs/ excluded)

## Checklist read

- code-check-python.md: in full. The diff has no Python, so none of it applies.
- code-check.md: the prose of every H3 under `## Mechanisms`, table rows skipped. I read these closely:
  - A guard that fails toward pass
  - A fixture that cannot reach the failure mode
  - A proxy is not the property
  - Verification that reads its own output
  - A guard's scope, escape hatches, and remedies
  - A fix lands in one of two callers that share a harness
  - Restore the bug and prove the guard fires
  - A wrapper's exit is not the work
  - Zero-length, empty, and unset are three different things
  - The probe is broken before the world is

  I read these four only in part: A shared working tree; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. "Rules that stand alone", Security and Spreadsheets I read by index line only.
- code-check-r.md, by heading:
  - A replacement function on an `xml_missing` node is a silent no-op
  - `nzchar(NA)` is TRUE
  - `paste()` with a zero-length argument
  - `strsplit()` drops a trailing empty field
  - `file(open = "wb", encoding = )` (opening only)

  The other headings I read by index line only.
- code-check-shell.md and code-check-spatial.md: index lines only. The diff has no shell or spatial code.

## How it was probed

I made a detached worktree of HEAD under the scratchpad and copied the OCR cache into it. It is now removed.

- **Harness.** I extracted script lines 226–238, 304, 311–316 and 561–661 into a scratch file and ran `research_parse()` on the fixtures in `scratchpad/fx4/` and `scratchpad/fx4b/`. I rendered each fixture with `commonmark::markdown_html(extensions = TRUE)`, both with and without `footnotes = TRUE`.
- **Full run.** I ran `scripts/0280-literature-verify.R` with `LOG=` set to the scratchpad, against the real Zotero copy. It took 41 s and exited 0.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:591. The renderer is called with `footnotes = FALSE`, the default in commonmark 2.0.0, but GitHub renders `.md` files with cmark-gfm's footnote extension on. So the checker reads footnote syntax as a different structure from the one the reader sees, and a footnote's text can escape every check.
  - **Fixture `fn4.md`.** It has a valid passage, `See the note.[^1]`, then `[^1]: A note on spawning.`, a blank line, and a 4-space-indented `"Bull trout never spawn in clean gravel beds anywhere." (mcphail_baxter1996reviewbull, p. 3)`.
    - `research_parse()` returns only the first quote, with no failure row.
    - With `footnotes = TRUE`, cmark-gfm renders the indented line as a `<p>` inside the footnote section: a cited quotation in plain view.
    - Without footnotes, it is an indented `<pre><code>` block. So the accepted tradeoff "code blocks outside block quotes are not checked" is the hatch it escapes through, which is input that tradeoff was not written for.
    - `fn3.md` has the same shape with a curly-quoted, uncited passage. It also gives no row; the stray guard never sees it.
  - **Fixture `fn2.md`.** It has `[^1]: https://example.org` followed by a line holding `"Bull trout never spawn in clean gravel beds"`. Without footnotes, that is a link reference definition with a title, which is invisible, so it gives no row. With footnotes, the reader sees the quoted words.
  - **Scope today.** None of the 28 `research/*.md` files uses `[^…]`, so nothing escapes today.
  - **Remedy.** Pass `footnotes = TRUE`.
    - I tested it in the scratch copy. `fn2`, `fn3` and `fn4` then give `stray_quote_mark` rows or a parsed quote.
    - The research file still parses 170 quotes with no guard rows.
  - **What the remedy adds.** A footnote reference then becomes an `fnref` node, which `inline()`'s switch does not handle. It has no children, so it contributes no character.
    - In `fnref.md` (`"…the bull trout[^n] occurs…" (key, p. ii)`), the passage goes to `check_row()` as written without the marker, while the reader sees "trout¹ occurs".
    - It needs a placeholder character of kind `l` (next finding).
  - **Rule:** code-check.md "A proxy is not the property" (commonmark's defaults stand in for GitHub's renderer). It is equally an instance of "A guard's scope, escape hatches, and remedies": the code-block exemption covers input it was not written for.

- **[severity: fragile]** scripts/0280-literature-verify.R:610–611 (`inline()`). A link or image with no child text contributes no character. So `at` holds no `l` and the passage is checked as if the node were absent.
  - **Fixture `img.md`.** `"Like many char, the bull trout ![](https://example.org/never.png) occurs as a number of life-history forms." (mcphail_baxter1996reviewbull, p. ii)` parses to the same quote string as the plain passage (`identical()` is TRUE). Round 3 found that string to be `verified_text` on PDF page 6.
  - The reader sees an image inside the quotation marks, and an image can show any words.
  - An image with non-empty alt text gives `link_in_quote`, as intended. Only empty alt escapes.
  - An empty link, `[](url)`, behaves the same way, but it renders nothing visible.
  - **Remedy.** Emit one `x` of kind `l` for a `link`, `image` or `fnref` node whose children produce no characters.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0280-literature-verify.R:566–573 (`RESEARCH_QM`, `research_marks`). The stray set is Unicode's `Quotation_Mark` united with the marks `clean()` maps. That still stands in for "renders as a quotation mark", and characters whose own Unicode names say QUOTATION MARK are outside it.
  - Each of these fixtures gives no row:
    - `❝…❞` (U+275D/E, "HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT");
    - `🙶…🙷` (U+1F676/7);
    - `״…״` (U+05F4 Hebrew gershayim);
    - `ʺ…ʺ` (U+02BA);
    - `〃…〃` (U+3003);
    - `‶…‶` (U+2036).
  - **The set is wider than these six.** Enumerated with Python's `unicodedata`, the code points outside `research_marks` whose names contain QUOTATION, PRIME, DITTO, GERSHAYIM, GERESH or APOSTROPHE include:
    - U+275B–2760 and U+276E/F;
    - U+1F676–8;
    - U+02B9–02BD, U+02DD, U+02EE;
    - U+05F3/4, U+055A;
    - U+2034–2037, U+2057;
    - U+3003.

    Round 3 named U+3003, U+02BA and U+02EE but did not run them. The round-3 fix adds only `clean()`'s marks.
  - **Scope today.** None occurs in any `research/*.md` today.
  - **A defined set that tracks rendering.** Use the union of three sets:
    - `Quotation_Mark`;
    - every code point whose Unicode name contains "QUOTATION MARK";
    - every code point that Unicode's `confusables.txt` maps to `"` or `'`.

    Keep the existing apostrophe exemption, extended to the single-mark confusables such as ʼ and ʻ, which are letters in some orthographies.
  - **Rule:** code-check.md "A proxy is not the property"

## Checked and holding

- **The research file.** The full run reports `research: 1 files, 170 quotes | verified_ocr 2 | verified_text 168`, with exit 0.
  - The research log has exactly 170 rows: 2 `ocr`, 168 `text`, and no other status.
  - An independent count agrees: the file holds 340 straight `"`, which is 170 pairs, and no curly marks.
  - The evidence and registry results are unchanged: 1151 rows and 117 registry quotes, all passing.
- **Character positions.** I tested ZWJ emoji sequences (👨‍👩‍👧), astral characters (🐟) and `e` plus U+0301 placed before and inside a passage, a code span and a stray mark.
  - Each gave the right row and line: `code_in_quote`, `emphasis_in_quote`, and the stray marks.
  - `strsplit(x, "")`, `nchar()`, `gregexpr(perl = TRUE)` and `substr()` all count code points.
- **Empty nodes.** cmark-gfm emitted no empty `text` node in 14 edge inputs, and `strsplit("", "")` is `character(0)`. So no zero-length element shifts the per-character vectors.
- **Probes the task listed:**

  | probe | result |
  |---|---|
  | tables (`table_cell`) | flagged |
  | ATX and setext headings | flagged |
  | angle-bracket and GFM extended autolinks | flagged |
  | reference-style image with marks in its alt text | flagged |
  | `<details>` with a markdown paragraph | flagged |
  | task-list items | flagged |
  | hard breaks (backslash and two spaces) | flagged |
  | a passage split across two paragraphs | two `stray_quote_mark` rows |
  | GitHub alert `> [!NOTE]` | `blockquote_text_outside_quote` (refusal) |
  | `[^n]` when footnotes are off and `[^n]: never` exists | `link_in_quote` |
  | a link reference title | not shown to a reader (tooltip only); not counted |

- **Not valid UTF-8.** I tested a Windows-1252 file with 0x93…0x94 and 0xAB…0xBB.
  - `research_parse()` errors inside the xml2 and cli message path ("input string 1 is invalid UTF-8"), so the run stops before any log is written. It fails toward refusal; the message is unhelpful.
- **Missing commonmark or xml2.** `xml2::` or `commonmark::` raises at line 591 before any log is written: a refusal. With `QUOTED=` empty, neither is touched.
- **`no_quotes_in_file`.** It fires when `out` is empty or holds only guard rows. A file whose only passage carries a guard status has a non-NA key, so it does not fire there, which is correct because that row fails anyway.
- **The block-quote XPath.** The whitespace and newline inside the predicate are valid XPath. Lists and headings inside a block quote are allowed, and their paragraphs and headings are still checked through the ancestor test.

/Users/airvine/Projects/repo/knowledge-stats/planning/active/review-round4.md

## Triage (main session)

All three findings were accepted. The footnote one sits inside round 3's fix: the renderer was called without
GitHub's footnote option.

- **Footnotes.** `markdown_xml(footnotes = TRUE)`, as GitHub renders. A footnote's paragraphs are now read, and a
  footnote mark inside a passage is `link_in_quote`.
- **Links, images and footnote marks with no text** become one placeholder character of the link kind. An image
  inside a passage is `link_in_quote`.
- **Marks named as quotation marks.** The set now takes every punctuation mark, symbol or modifier letter in planes
  0 and 1:
  - that Unicode classes as an initial or final quote (`Pi`, `Pf`);
  - or whose Unicode name (`stringi`) contains QUOTATION MARK, QUOTE, PRIME, DITTO, GERESH, GERSHAYIM, APOSTROPHE,
    DOUBLE ACUTE, TURNED COMMA or REVERSED COMMA.

  Letters and combining marks are left out by category, so Erdős is text. U+02BB and U+02BC join the apostrophe
  class, so Wetʼsuwetʼen and Hawaiʻi are prose.

The fix also adds:
- `file_not_utf8`, which replaces an opaque error;
- an inline node the walk does not know is read as HTML, so it fails inside a passage;
- any text node outside a leaf block fails as `text_outside_a_block`.

My first pass at the HTML fallback also caught the paragraph passed in at the top, which turned all 170 quotes into
`html_in_quote`. The rerun caught it before commit, and the leaf blocks are now named in the switch. It failed toward
a refusal.

## Closing enumeration (ends the loop)

Rounds 2, 3 and 4 each found a defect inside the previous fix, so the loop ends on an enumeration against the two
sources of truth the rounds named, not on a quiet round.

**Characters** (`planning/active/fixtures/enum_sets.R`). Every member of each source set is in `research_marks`
(79 characters):

| source set | members | outside the guard's set |
|---|---|---|
| Unicode `Quotation_Mark` | 30 | 0 |
| Unicode `Pi` and `Pf`, planes 0–1 | 22 | 0 |
| named as quote-like, not a letter or combining mark, planes 0–1 | 56 | 0 |
| what `clean()` reads as a quote mark | 11 | 0 |

**Renderer nodes** (`planning/active/fixtures/enum_nodes.R`). A document using every construct gives 26 node names
under GitHub's extensions with footnotes on. Every one has a named handling, and 0 fall to the fallback. The
fallback and `text_outside_a_block` stay in place for a node a later cmark-gfm adds.

**Fixtures** (`planning/active/fixtures/make_enum.R`, now covering rounds 1–4):
- every case fails with its expected status;
- the negative controls give 0 rows: possessives after code, `et al.`, `*k*`, `)`; straight and curly apostrophes;
  café's, Erdős, Wetʼsuwetʼen, Hawaiʻi; `&`, `<` and `>` in prose;
- the 24 other research files give exactly the rows they gave before round 4.

**Outputs:**
- `research/bull_trout_life_history.md`: 170 quotes, 168 `verified_text` and 2 `verified_ocr`.
- `QUOTED=`: evidence and registry logs byte-identical to the run before the branch.
