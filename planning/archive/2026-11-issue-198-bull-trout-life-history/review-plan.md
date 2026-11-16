# Plan review, #198 (Plan agent, 2026-11-16)

Returned as reply text (the Plan type cannot write) and copied here. Before anything was folded into
`task_plan.md`, these were checked against the code:
- `value_in_quote()` returns early (0280:422);
- 21 BT rows from 7 keys are OCR;
- a group key contains `&`;
- the registry log is named from `LOG` (0280:570-575).

## Findings

1. **check_row(quote_row()) works.** `value_in_quote()` returns TRUE when there are no values, so the NA fields do no
   harm. The research block must come after `quote_row()`'s definition.
   - Gap: a number written outside a quote is never checked, so the meaning audit has to list every number and
     every data-row citation.
2. **Parser.**
   - Blocker: a `>` on a wrapped blockquote line lands inside the passage, and a blockquote with no quote marks
     escapes the parser. Strip the `> ` before joining lines, and fail a `>` line that holds no parsed quote.
   - Blocker: emphasis (`*`) inside a quote adds tokens the PDF lacks. Forbid it inside a passage.
   - Gap: keys can contain `&`, so match `[^\s,()]+` and let `resolve()` judge.
   - Gap: roman-numeral pages; a citation takes one key.
   - Gap: inline code and fenced blocks must be blanked before the guard and the parser run.
   - Gap: the guard must also catch a curly opening single quote and a straight `'` that opens a word.
   - Gap: a quote can hold quoted terms of its own. Delimit with straight `"` only and allow curly marks inside.
   - Gap: never `clean()` the whole file, because it turns backticks into `'`.
   - Assumption: `MIN_FRAG = 3` counts punctuation, so require at least 4 word tokens per fragment. The audit
     re-reads every ellipsis.
3. **OCR.** 21 BT evidence rows from image-only PDFs are OCR. Allow OCR only where the citation says so, never as a
   fallback.
4. **Ordering and acceptance.**
   - `QUOTED` must not point at a file that does not exist yet. A missing listed file fails, and so does one with zero
     quotes.
   - Planted-failure runs must set `LOG=` to the scratchpad, or they overwrite today's committed logs.
   - Run 0280 on each draft as it lands.
   - Printed pages and PDF pages differ, so flag a quote that matches several pages.
   - A table passage cannot be a research quote; timing is cited by data row.
   - Quotes stay short; restricted reports are not quoted.

## Disposition

All folded into Phase 1, Phase 2 and Phase 4 of `task_plan.md`. None declined.
