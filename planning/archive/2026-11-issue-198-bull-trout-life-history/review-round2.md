# Code review, round 2 (#198 branch, `git diff 86088f67...HEAD`, planning/ and scripts/logs/ excluded)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms`, table rows skipped (A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice). "Rules that stand alone", Security and Spreadsheets were read by index line only.
- code-check-r.md, by heading: `\<` and `\>` are word boundaries in R's default regex; `paste()` with a zero-length argument; `data.frame()` recycles a scalar against a zero-length column; `nzchar(NA)` is TRUE; `sub()` takes one replacement; Rscript reads a script as it runs. The other headings (about 130) were read by index line only.
- code-check-shell.md and code-check-spatial.md: index lines only. The diff has no shell or spatial code.

## How it was probed

I ran lines 226–238, 304, 311–316 and 554–610 of `scripts/0280-literature-verify.R` from a detached worktree of HEAD in a scratch harness, on fixtures and on every `research/*.md`. The worktree is now removed. Nothing in the repo was edited apart from this file.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:599–600. Round 1's widened `'` arm, `(?<![[:alnum:]])'(?=[^[:space:]])`, fails on correct possessives. Code spans are blanked to spaces at line 573, before this regex runs. So in `` `default`'s ``, the `'` follows a space and gets flagged. The same holds after `.`, `*` and `)`. A fixture line, ``Ford et al.'s review and `default`'s floor, fold *k*'s pick, (Smith 2003)'s view.``, gives four `stray_quote_mark` rows, so the run exits 1.
  - This is the house style. `grep -E "(^|[^[:alnum:]])'[^[:space:]]"` matches lines in 20 of the 27 other `research/*.md` files, about 140 hits, almost all `` `x`'s ``.
  - Among them are the files most likely to join `QUOTED` next: `bull_trout_tuned.md` (15, including `Ford et al.'s` at line 86), `flow_requirements.md:39` (`al.'s`) and `thermal_requirements.md`.
  - The accepted tradeoff covers `'90s`, not possessives. The fix makes the gate refuse correct prose in the form this repo writes, and the remedy for each failure is to rewrite good prose.
  - Possible remedy: blank code spans with a non-space filler, such as `x`, rather than spaces. This also closes the next finding. Then exempt `'s` followed by a non-letter (`'(?!s(?![[:alpha:]]))`). Pin it with a negative-control fixture holding these four forms.
  - **Rule:** code-check.md "A guard that fails toward pass" ("keep a negative control set, because widening a guard is how it starts refusing correct content")

- **[severity: fragile]** scripts/0280-literature-verify.R:573 and 579. Code spans are blanked to spaces before passages are parsed. A word in backticks inside a passage therefore renders as part of the quote but is never checked.
  - Reproduced: ``> "Bull trout `never` spawn in clean gravel beds" (keyA, p. 3)`` parses to the quote `Bull trout spawn in clean gravel beds`. That is what goes to `check_row()`, so a real PDF sentence plus one inserted backticked word verifies.
  - This is the escape the emphasis guard (line 591) closes for `*`/`_`, through the code-span route. The current file has no backtick inside a passage (checked), so nothing escapes today.
  - Blanking with a non-space filler (above) turns this into a `quote_not_found` failure.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0280-literature-verify.R:599 and 604. Some forms render as quoted or blockquoted text yet pass with no row. Each was reproduced on a fixture:
  - **Numeric HTML entities.** `&#8220;a numeric entity passage of words&#8221;` gives no row. Neither do `&#34;…&#34;` and `&bdquo;`. The comment at line 545 claims "an HTML quote entity", but the class lists only the named ones.
  - **Unquoted text in a blockquote.** The blockquote guard works per line on `>` lines that hold no parsed quote. So a CommonMark lazy-continuation line directly after a `> "…" (key, p. N)` line passes. So does trailing prose on the same `>` line, after the citation (`> "Real passage here with five words" (keyC, p. 5) Bull trout never spawn in gravel.`). Both render inside the blockquote and are unchecked.
  - **HTML `<blockquote>`.** `<blockquote>…</blockquote>` gives no row.
  - None of these occurs in `research/bull_trout_life_history.md` today: no lazy line follows any of its 170 `>` lines. But the comment and `scripts/README.md` say "a blockquote holding no quote … fails", and a lazy continuation is an easy slip when a sentence is typed straight after a quote.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a literal set used as a filter covers what the data holds today)

Everything else holds as round 1 reported:
- passage pairing when stray `"` are present (an earlier unmatched `"` is flagged, and the real passage is still parsed);
- line attribution;
- `QUOTED=` empty and unset;
- the missing-file and zero-quote rows;
- the summary;
- the exit condition (`any(!res_pass)`).

The unclosed-fence case hides later quotes, but CommonMark also renders them as code, so nothing that renders as a quote escapes. I did not report it.

## Triage (main session)

All three accepted. The first is a defect inside round 1's fix: the widened apostrophe rule failed correct
possessives, because code spans were blanked to spaces. So from here on only an enumeration ends the loop.

The mechanism: the guard was a hand-picked list of quote characters, set against prose apostrophes and a blanking
step that changed what precedes them. The fix moves each part onto a defined set:

- **Quote characters.** Every character with Unicode's `Quotation_Mark` property (30, `RESEARCH_QM`) is flagged,
  with one exemption, written once: an apostrophe (' or U+2019) after a letter or digit, or as `'s` before a
  non-letter. `(*UCP)` makes `[[:alnum:]]` Unicode-aware, so `café's` is prose.
- **HTML quotes.** Any named or numeric character entity is flagged, and so are `<q>` and `<blockquote>`.
- **Blockquotes.** Any text left outside a parsed quote on a `>` line or on a lazy continuation line is flagged
  (`blockquote_text_outside_quote`, replacing `blockquote_without_quote`).
- **Code spans.** They are now filled with a letter of their own length, not spaces, so a possessive after one stays
  a possessive. A code span inside a passage is `code_in_quote`. The `>` strip keeps the line length, so code
  positions stay aligned.
- **A fault in the fix itself.** `\x{}` escapes made the pattern invalid on an ASCII-only file, because R runs PCRE
  in UTF mode only for UTF-8 strings. The patterns now build their characters with `intToUtf8()`. The fault failed
  toward a refusal: the run errored.

## Enumeration

The fixture is `planning/active/fixtures/make_enum.R`, run through 0280 with `QUOTED=` and with `LOG=` in the
scratchpad.

| set | members | flagged | expected |
|---|---|---|---|
| `Quotation_Mark` characters opening a passage | 30 | 30 lines | all |
| HTML quote forms (`&quot;`, `&#8220;`, `&#x201C;`, `&bdquo;`, `<q>`, `<blockquote>`, `&rsquo;`) | 7 lines | 7 lines (8 rows) | all |
| Possessives and apostrophes: after code, `et al.`, `*k*`, `)`, straight and curly, `café's`; `&` and `<`/`>` in prose | 3 lines | 0 | none |
| Blockquote: prose after a quote, a lazy line, an unquoted `>` line | 3 | 3 | all |
| Code span inside a quote | 1 | `code_in_quote` | all |
| Valid quotes, plain and in a blockquote | 4 | `verified_text` | pass |

The earlier fixtures give the same results as before:
- `bad.md` gives every planted status;
- `escape.md` gives 8 stray rows;
- `good.md` passes;
- an empty file gives `no_quotes_in_file` and a missing one `file_missing`.

`QUOTED=` gives evidence and registry logs byte-identical to the run before the branch. The research file passes all
170 quotes.
