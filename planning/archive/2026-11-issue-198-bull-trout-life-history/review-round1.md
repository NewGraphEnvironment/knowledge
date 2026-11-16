# Code review, round 1 (#198 branch, `git diff 86088f67...HEAD`, planning/ and scripts/logs/ excluded)

## Checklist read

- code-check-python.md: in full (no Python in the diff; nothing applies).
- code-check.md: the prose of every H3 under `## Mechanisms` (A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things), table rows skipped. The four later Mechanisms H3s (The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice) and every "Rules that stand alone" / Security / Spreadsheets H3 read by index line only.
- code-check-r.md, by heading: `nzchar(NA)` is TRUE; `strsplit()` drops a trailing empty field; `data.frame()` recycles a scalar against a zero-length column; `paste()` with a zero-length argument returns length ONE; `sub()` takes one replacement; CSV whitespace; Rscript reads a script as it runs. About 130 other headings read by index line only.
- code-check-shell.md and code-check-spatial.md: index lines only (no shell or spatial code in the diff).

## How the parser was probed

The research block (with `clean()`, `tokens()`, `fragments()` and `MIN_FRAG`) was extracted from a detached worktree of HEAD into a scratch harness and run, so nothing in the repo was touched; the worktree is removed.

- On `research/bull_trout_life_history.md` (UTF-8 locale): 170 quotes parsed, no guard rows, and every quote's reported line holds its first word. So `gregexpr(perl = TRUE)` positions and `capture.start` are in characters here, `substr<-` blanking keeps character counts with the en dashes, ± and ° present, and `line_at()` is right for wrapped quotes.
- Positive controls on fixtures. Each fires: a stray `"`, a straight `'` opening a word, a curly `‘`, an unquoted blockquote line, emphasis in a passage, a two-word passage, a three-word fragment after `…`, a file with no quote, and a missing file. A passage wrapped over a list item's two lines is parsed whole, with `pp. 8–9, OCR` read as `ocr`.
- `QUOTED=` and `QUOTED="  "` both give `character(0)` and zero rows, as documented. With QUOTED unset the default is used.
- Summary and exit: `res_pass` is `status %in% c("verified_text", "verified_ocr")`, and the exit line includes `any(!res_pass)`. Every parser guard row has a non-NA status outside that set, so a failed research quote cannot pass.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:598. The stray-mark guard misses quotation forms that render as a quote, so such a quote is neither parsed nor flagged, and the run exits 0. The guard's class is the literal set `[\"“”‘]` plus a straight `'` before a **letter**. Reproduced on a fixture, each of these lines produced no row at all (no parsed quote, no `stray_quote_mark`):
  - `Bull trout spawn in '20 cm of clean gravel in the autumn' (keyB, p. 4)`. A straight single quote opening a passage that starts with a digit or punctuation (`'20 …`, `'(…`, `'…`) is missed: the lookahead is `(?=[[:alpha:]])`, and the closing `'` follows a letter, so it is not caught either.
  - `&quot;fabricated sentence with five words&quot; (keyC, p. 5)` (an HTML entity renders as `"`).
  - `«a guillemet quoted fabricated passage» (keyD, p. 6)`. `„` is also outside the class, although `clean()` treats it as a quote mark.
  - `<q>a fabricated tag quote with words</q> (keyG, p. 1)`.

  None of these occurs in `research/bull_trout_life_history.md` today, so nothing escapes now. But the guard is how the gate claims coverage of "anything that would let a quote escape the check", and `scripts/README.md:540` says "a quote mark left outside that form … fails". The digit case is the one a drafter could plausibly type: a quoted measurement such as `'20% of redds …'`. Widening the lookahead to `(?=[^[:space:]])` and adding `„«»‹›`, `&quot;`/`&[lr]dquo;` and `<q>` to the class closes what was reproduced. Otherwise, narrow the README and comment claim to the marks actually checked.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a literal set used as a filter covers what the data holds today)

No other issues found. Line attribution, multibyte handling, the zero-quote and missing-file paths, `QUOTED=""`, and the summary and exit condition all behave as documented.

## Triage (main session)

Accepted and fixed. The guard class now also covers:
- low and reversed double quotes, and guillemets;
- a low single quote;
- a straight `'` that opens anything but a space;
- the HTML quote entities and `<q>`.

A fixture with the reviewer's forms gives 8 `stray_quote_mark` rows. A possessive (`streams' banks`, `trout's`) gives
none, the research file still passes all 170 quotes, and the passing fixture still passes.
