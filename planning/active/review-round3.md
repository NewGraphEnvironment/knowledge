# Code review, round 3 (#198 branch, `git diff 86088f67...HEAD`, planning/ and scripts/logs/ excluded)

## Checklist read

- code-check-python.md: in full. The diff has no Python, so none of it applies.
- code-check.md: the prose of every H3 under `## Mechanisms`, table rows skipped. That covers the 14 sections from "A guard that fails toward pass" through "One fact derived twice". I read up to "Written data outlives the fix" closely; for "Serialization loses meaning silently" and "One fact derived twice" I read the opening only. "Rules that stand alone", Security and Spreadsheets I read by index line only.
- code-check-r.md, by heading:
  - `nzchar(NA)` is TRUE
  - `paste()` with a zero-length argument
  - `strsplit()` drops a trailing empty field
  - `file(open = "wb", encoding = )` does not re-encode on write (the C-locale part)
  - `deparse()` re-encodes non-ASCII
  - `data.frame()` recycles a scalar against a zero-length column
  - `\<` and `\>` are word boundaries

  The other headings I read by index line only.
- code-check-shell.md and code-check-spatial.md: index lines only. The diff has no shell or spatial code.

## The mechanism

All the findings in rounds 1 and 2 share one assumption: that the checker's own regex model of the Markdown source agrees with what the renderer shows the reader. It is two lists that happen to agree: the parser's model and CommonMark's.

The guard is fail-safe wherever the model adds text to check:
- it flags a mark;
- it parses a passage that renders as code.

It fails toward pass wherever the model removes text from view that the renderer still shows:
- fence blanking;
- code-span filling;
- the `[...]`-is-an-insert split in `fragments()`;
- and, for quote marks, a character property used in place of "renders as a quotation mark".

Round 2 replaced the hand-picked lists of quote characters with defined sets. It did not replace the hand-written model of Markdown structure that decides which text those sets ever see.

## How it was probed

I made a detached worktree of HEAD under the scratchpad, now removed, and checked that `git status` is clean. In it I ran two harnesses:
- `research_parse()` with `clean()`, `tokens()` and `fragments()` (script lines 226–238, 304–317, 560–635);
- and, for one case, `check_row()` against the real Zotero copy (lines 133–492 and 507–510).

I rendered each fixture with `commonmark::markdown_html(extensions = TRUE)`, which is cmark-gfm, the renderer GitHub uses. That shows what a reader sees.

## Coverage of each place the mechanism reaches

| place (what the model decides) | in round 2's enumeration | result |
|---|---|---|
| Fenced code: ```` ^\s*``` ```` toggles parity | no | **escape** (finding 1) |
| Code spans: `` `[^`]*` `` per line, filled with `x` | code inside a quote; possessive after code | **escape** via an escaped backtick (finding 2). Code on a `>` line, a wrapped passage, and astral or combining characters before a span all align (below). |
| Blockquote: `^\s*>` plus lazy lines | `>` lines, lazy lines, prose after a citation | **escape**: a blockquote inside a list item (finding 3) |
| HTML: `<q>`, `<blockquote>`, `&…;` | lower-case tags, `;`-terminated entities | **escape**: upper-case tags; semicolon-less legacy entities in raw HTML (finding 3) |
| `[…]` read as an editorial insert | no | **escape**: a Markdown link inside a passage renders its text without brackets, unchecked, and the passage verifies (finding 4) |
| Quotation_Mark (30) as "renders as a quote mark" | all 30 | **escape**: `″…″`. `clean()` in the same script treats `′` and `″` as quote marks, but `RESEARCH_QM` does not (finding 5). |
| Code-position map vs `txt` | not enumerated | aligned (below) |
| `(*UCP)` plus `intToUtf8()` on ASCII vs UTF-8 | not enumerated | identical (below) |

None of the escapes occurs in `research/bull_trout_life_history.md` today. The file has none of the following:
- `~~~` or four-backtick fences;
- an indented ```` ``` ````;
- `` \` ``;
- a blockquote in a list item;
- an upper-case tag;
- a link or a bracket;
- a prime.

All 170 quotes parse.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:584–586 (`fence`/`in_fence`). The fence model counts every line that opens with ```` ``` ```` and toggles on its parity. CommonMark closes a fence only with the same character, at least as long, and does not treat a 4-space-indented ```` ``` ```` as a fence at all. So a mismatched line flips the parity, and the parser blanks every later line up to the next ```` ``` ````. A passage hidden that way is neither parsed nor flagged, and the run passes, even though the reader sees it as a quote. Each case below was reproduced, and cmark-gfm renders the fabricated passage as a normal paragraph:
  - A `~~~` fence that holds a ```` ``` ```` line, followed by `"Bull trout never spawn in clean gravel beds anywhere." (mcphail_baxter1996reviewbull, p. 3)`: only the earlier quote is parsed, with no failure row.
  - A ```` ```` ```` (four-backtick) fence that holds a ```` ``` ```` line: the same result.
  - A paragraph line indented four spaces holding ```` ``` ```` (an indented code block in CommonMark): both quotes below it, the valid one and the fabricated one, vanish.

  The `no_quotes_in_file` backstop does not fire, because the quotes above the fence still parse.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a literal set used as a filter covers what the data holds today)

- **[severity: fragile]** scripts/0280-literature-verify.R:587–588 (`code`). The code-span regex pairs backticks within a line, so an escaped backtick (`` \` ``), which renders as a literal backtick, still opens a "span". Everything up to the next backtick on the line is then filled with `x`. Reproduced: ``A literal \` then “Bull trout never spawn in clean gravel” and "Bull trout never spawn in clean gravel beds anywhere." (mcphail_baxter1996reviewbull, p. 3) and \` end.``
  - It gives no row: the curly-quoted passage and the straight-quoted, cited one both disappear.
  - cmark-gfm renders both, with literal backticks.

  A code span that runs across lines (CommonMark pairs backticks within a paragraph) diverges the same way. In the cases I tried it fails safe: it flags or parses more than it should.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0280-literature-verify.R:596 (`bq`) and 571 (`research_stray`, the tag and entity arm). The blockquote and HTML sets are defined by spellings, not by what renders:
  - **A blockquote inside a list item.** `- > Bull trout never spawn in clean gravel beds anywhere.` renders as a `<blockquote>` inside an `<li>`, but `^[[:space:]]*>` does not match it. It gives no row.
  - **Upper-case tags.** `<Q>…</Q>` and `<BLOCKQUOTE>…</BLOCKQUOTE>` give no row. HTML tag names are case-insensitive, and cmark-gfm passes both through.
  - **Legacy entities without a semicolon.** `&laquo fabricated passage of words&raquo` inside a raw HTML block (`<div>…</div>`) gives no row. cmark-gfm passes the block through untouched, and a browser decodes `&laquo`/`&raquo` without the `;` (they are on HTML's legacy list), so the reader sees «…».
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0280-literature-verify.R:312 (`fragments()`, reached from line 640). Inside a research passage, a bracket is read as an editorial insert and dropped from the check. In Markdown, though, a bracket followed by `[ref]`, `[]` or a definition is a link: it renders the bracketed words with no brackets, so the reader sees them as part of the verbatim quote.
  - Reproduced with `"Like many char, the bull trout [never][n] occurs as a number of life-history forms." (mcphail_baxter1996reviewbull, p. ii)` plus `[n]: https://example.org`.
  - `check_row()` returns **`verified_text`** (PDF page 6). The page shows "…the bull trout <a>never</a> occurs…" inside the quotation marks.
  - The accepted tradeoff covers a source's own brackets, not a Markdown link. An inline `[never](url)` fails safe, because `(url)` stays in the next fragment's tokens.
  - **Rule:** code-check.md "A proxy is not the property" ("A verbatim-quote gate certifies the words, not the meaning of the row built around them"). It is equally an instance of "A guard's scope, escape hatches, and remedies", since an exemption, the insert, covers input it was not written for.

- **[severity: fragile]** scripts/0280-literature-verify.R:565–566 (`RESEARCH_QM`). Unicode's Quotation_Mark property stands in for "renders as a quotation mark", and the two differ.
  - Reproduced: `″Bull trout never spawn in clean gravel″ (keyX, p. 3)` (U+2033 double prime) gives no row.
  - The same script's `clean()` (line 227) maps `′` and `″` to quote marks, so the file already holds two lists of quote characters that disagree.
  - Ditto `〃` (U+3003), `ʺ` (U+02BA) and `ˮ` (U+02EE) are look-alikes of the same kind. I have not run them.
  - **Rule:** code-check.md "A proxy is not the property"

### Remedy covering all five

Take the structure from the renderer rather than modelling it. `commonmark` 2.0.0 is installed and wraps cmark-gfm, the engine GitHub renders with. `commonmark::markdown_xml(text, extensions = TRUE, sourcepos = TRUE)` returns:
- `code_block` and `code` nodes;
- `block_quote` nodes, including those inside list items;
- `html_block` and `html_inline` nodes;
- `link` nodes;
- `text` nodes, with entities already decoded.

All of these carry source positions. Run the passage regex and the stray guard on the rendered text nodes, never on raw source. Flag the following:
- a `link` inside a passage's span;
- any `block_quote` whose text is not wholly parsed passages;
- any HTML node matching `(?i)<(q|blockquote)\b` or a decoded quote mark.

Add `′` and `″` (the marks `clean()` already treats as quotes) to the stray set. That leaves GitHub's renderer and cmark-gfm as the only two models that could still disagree, and they are the same engine.

## Checked and holding

- **Code-position map vs `txt`** (UTF-8 locale). Positions are in characters throughout:
  - `gregexpr(perl = TRUE)` on UTF-8 strings;
  - `nchar()`;
  - `substr<-`;
  - the `x` filler, of the span's own `nchar`;
  - the `>`→space strip, which keeps the length;
  - `"\n"` matched to `"0"` in the join.

  These fixtures all gave the right rows:
  - a code span inside a passage on a `>` line, after 🐟 (an astral character) and `é` written as `e` plus a combining accent: `code_in_quote`;
  - a code span before a passage on the same `>` line, ASCII and with astral characters inside the span: the passage parses with no `code_in_quote`, and the span is `blockquote_text_outside_quote`, which is correct because it is unquoted blockquote text;
  - a passage wrapped over two `>` lines with code on the second: `code_in_quote`, reported at the passage's first line.
- **`(*UCP)` with `intToUtf8()`.** An ASCII-only file and the same file with one `é` added give identical rows:
  - `` `default`'s ``, `trout's` and `(Smith 2003)'s` are not flagged;
  - an opening `'Bull` is flagged once;
  - `café's` is not flagged, so UCP is in effect.

  The patterns carry UTF-8 characters, so PCRE runs in UTF mode for both files.
- **Under `LC_ALL=C`** the run stops at the existing `clean()` (`chartr`: "'old' is longer than 'new'"). That is code this branch did not change, and the run stops loudly before the research block.
- **False failures on the next candidates** (`research_parse()` on each):
  - `research/thermal_requirements.md`: 22 `stray_quote_mark` rows;
  - `research/flow_requirements.md`: 8;
  - `research/bull_trout_tuned.md`: 6.

  Each file also gets `no_quotes_in_file`. Every flagged character is a straight `"`, which is expected because these files have no quote form yet. No possessive or apostrophe is flagged. That includes `al.'s` (flow_requirements.md:39), `Coleman & Fausch's` (thermal_requirements.md:86) and every `` `x`'s ``. Over all 28 `research/*.md` files the only character flagged is `"`, and there is one `blockquote_text_outside_quote` (outside these three files). So the guard raises no false failures there.
- **The research file:** 170 quotes parsed, no guard rows.

/Users/airvine/Projects/repo/knowledge-stats/planning/active/review-round3.md

## Triage (main session)

All five findings accepted. The mechanism is the reviewer's. The guard read the raw Markdown through its own regex
model of it, and that model only happened to agree with the renderer. Rounds 1 and 2 widened the character lists
without replacing the model. So the fix replaces the model.

- **The file is read through cmark-gfm** (`commonmark::markdown_xml(extensions = TRUE, sourcepos = TRUE)`, the
  renderer GitHub uses). The guard therefore sees exactly the text a reader sees, block by block, with source
  lines and decoded entities. Fences, indented code, code spans, escaped backticks, block quotes in list items, and
  links are the renderer's own decisions.
- **Inside a passage, one node kind per status:** code, a link, inline HTML and emphasis give `code_in_quote`,
  `link_in_quote`, `html_in_quote` and `emphasis_in_quote`.
- **HTML blocks and inline HTML** are flagged when they hold `<q>`/`<blockquote>` (any case), `&` or a quotation
  mark.
- **A block quote** fails if it holds any block but a paragraph, or any text outside a parsed passage.
- **The stray set** is now `Quotation_Mark` (30) united with every BMP character that `clean()` reads as a quote
  mark, taken by running `clean()`. This adds ′ ″ and the backtick, and the two lists cannot part.
- Running `clean()` exposed a fault in the fix: `chartr()` refuses Unicode noncharacters (U+FFFE…), so the probe
  range now leaves out surrogates and noncharacters. It failed toward a refusal: the run errored.

## Enumeration after round 3

Fixture: `planning/active/fixtures/make_enum.R`, now with the round-3 cases. Every round-1 and round-2 set gives the
same result as before:
- 30 of 30 `Quotation_Mark` characters are flagged;
- the HTML forms are flagged (line 40 falls inside line 39's HTML block, which cmark ends only at a blank line);
- the negative-control lines give 0 rows;
- the blockquote shapes are flagged, and code inside a quote gives `code_in_quote`.

Each round-3 case now fails:

| case | before | now |
|---|---|---|
| `~~~` fence holding a ```` ``` ```` line | quote hidden | parsed: `quote_not_found` (fabricated) |
| four-backtick fence holding a ```` ``` ```` line | hidden | `quote_not_found` |
| ```` ``` ```` indented four spaces | hidden | `quote_not_found` |
| escaped backtick before a curly-quoted passage | hidden | 4 `stray_quote_mark` |
| `- > …` blockquote in a list item | no row | `blockquote_text_outside_quote` |
| `<Q>…</Q>` | no row | 2 `html_quote` |
| `&laquo…&raquo` in an HTML block | no row | `html_quote` |
| `[never][n]` link inside a passage | `verified_text` | `link_in_quote` |
| `″…″` | no row | 2 `stray_quote_mark` |

Other checks:
- The research file passes all 170 quotes.
- `QUOTED=` gives evidence and registry logs byte-identical to the run before the branch.
- No false failures in the other 24 research files: every flagged line holds a real double, curly-opening, prime or
  backtick mark. These files have no quote form yet, so their strays are expected, and `bayesian_alignment.md`'s 23
  quotes in the same form verify.
- lintr adds only uppercase constant names, which follow the script's style.

Accepted, all failing toward a refusal:
- any `&` inside HTML;
- HTML attributes with straight quotes;
- a straight `'` opening a word.
