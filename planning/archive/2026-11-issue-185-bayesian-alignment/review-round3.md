## Checklist read

- code-check-python.md: in full (no Python in this diff).
- code-check.md: the index in full. Every H3 under `## Mechanisms` read as prose, with table rows and evidence blocks skipped (all fourteen). Outside Mechanisms the index only: none of those headings names a tool this diff uses.
- code-check-r.md: the index in full. Sections read: "`strsplit()` drops a trailing empty field, so a trailing separator vanishes", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires", "`\<` and `\>` are word boundaries in R's default regex, not escaped `<` and `>`", "`nzchar(NA)` is TRUE — non-empty checks silently pass NA" and "`paste()` with a zero-length argument returns length ONE, not zero". The rest judged from the index; none names another tool the diff uses.
- code-check-shell.md: the index in full. No sections read; the diff has no shell.
- code-check-spatial.md: the index in full. No sections read; the diff uses no spatial tool.

## Findings

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:131-142 (claim at :14-18 and research/bayesian_alignment.md:5-6). **The mechanism:** the enumeration lists page citations and gives each one to at most one quote. It never lists quotes and asks whether each is owned by a checked citation. It looks only *backwards* from a citation, and it masks the checked quote's own citation before it scans. So a quote that shares a checked quote's citation, or that follows its citation, has no unowned citation left to trip on. Both escapes keep the pinned count at 23. Fixtures were built in the session scratchpad from copies of the research file named `bayesian_alignment.md`, so the count gate ran. Each printed PASS, exit 0:
  - **Shared citation, edited in place.** Line 128 was changed to `> "A ridge penalty is a full Bayesian posterior in all but name." And: "Ridge regression does not compute a posterior distribution." (mcelreath2020StatisticalRethinking, p. 216)`. The output was `ok line 128 … p. 216` and 23 quotes. An invented quote that contradicts the book sits on a blockquote line citing p. 216, and it passes.
  - **Citation before the quote.** The added paragraph `On p. 216 Rethinking says "a wholly invented sentence that no book prints anywhere at all".` passes, and so does `Rethinking (mcelreath2020StatisticalRethinking, p. 216) puts it plainly: "…invented…".`. The file already writes in this order: line 275 has `p. 500; "the variable causes …"`, and line 468 has `pp. 500, 503). It also qualified "only"`.
  - **Fix shape:** scan in both directions, and do not exempt a checked quote's citation. For each checked span, fail on a quote mark in the window before the span's *start*. For each page citation, masked or not, fail on a quote mark in the window after it. Line 468's `"only"` will then need rewording. Today the masked text has no quote mark within 200 characters before any of the 52 outside citations, so the window can widen at no cost.
  - **Rule:** code-check.md "A proxy is not the property" (its coverage paragraph: the sweep asks a narrower question, "is each citation near a quote", than the property, "is each quote held to its page")

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:136, 138 (claim at :14-16, "Every page citation in the file … is enumerated"). The citation pattern and the quote-mark class are each a fixed list of spellings. A quote **added** in a spelling outside those lists escapes. The pinned count catches only a quote that leaves the checked form, never one that was added outside it. Each fixture below was an added paragraph, and each printed PASS, exit 0, with 23 quotes:
  - `pg.`: `"…invented…" (mcelreath2020StatisticalRethinking, pg. 216)`. The pattern `pp?` followed by `\.?\s*[0-9]` meets the `g` and fails.
  - **A no-break space after `p.`**, the usual typographic form: `(mcelreath2020StatisticalRethinking, p. 216)`. PCRE's `\s` does not match U+00A0 here, so neither the strict regex nor the enumeration sees it.
  - **Straight single quotes**: `'…invented…' (mcelreath2020StatisticalRethinking, p. 216)`. Round 2 listed this form. Its disposition reports "single curly quotes" probed, but the class on line 138 holds the opening curly `‘` and not `'`. The header does say "opening single", so this is declared. But it leaves research/bayesian_alignment.md:5-6, "every quote that cites a page checked on that page", untrue for that form.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a literal set used as a filter covers what the data holds today)

- **[severity: fragile]** research/bayesian_alignment.md:10-11 and :189-190. Line 10-11 says quotes are used "only where a passage decides a row; each carries its citekey, the form the check reads". Line 189-190 presents "an average cluster" and "marginal of cluster" in quote marks as the book's terms ("A multilevel model predicts for "an average cluster" … or "marginal of cluster" …, and the book says"). They carry no citekey and no page, so the check never reads them, and they are not the book's words. pdftotext of Rethinking pp. 428-430 gives "average actor" (p. 428) and "marginal of actor" (p. 429); neither "average cluster" nor "marginal of cluster" occurs on pp. 426-431. Either drop the quote marks and say the book's terms are "average actor" and "marginal of actor", or quote those terms with their citekey and page.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a claim about what a check covers, executed over the population it names)

## Probed and found sound (not findings)

- **`line_at`.** It reports the right line for all 23 checked quotes, including line 275, which comes after many multibyte characters (√, em dashes). A quote wrapped across lines reports its start line.
- **Masking.** A strict match cannot swallow text beyond its own quote. `[^"]+` cannot cross a straight quote, and the match needs `\s*\(` right after the closing mark. So the passage always runs from the opening mark of the quote whose closing mark is followed by the citation, whatever the parity of earlier quote marks. The masked span is exactly that quote and its citation. The one thing masking hides is the citation that other quotes share (finding 1).
- **Quote more than 80 characters before its page.** Every one of the 52 citations outside checked quotes has no quote mark within 200 characters before it. A quote 80+ characters before its page, with prose between, is a declared heuristic, and no such case appears in this file's style (the closest is about 78 characters, and it fails).
- **Forms that fail as they should:** a citation on the next blockquote line, `pp` without its dot, an unknown citekey in the strict form, and curly double quotes.
- **The pinned count.** It is gated on the basename `bayesian_alignment.md` and counts strict matches. A dropped or reflowed quote fails it. An added valid quote fails it until `n_quotes` is changed.
- **Public-repo leaks.** None in the added lines or the branch's commit messages and patches: no home or temp path, host, credential path or private link.

## Dispositions (session, 2026-11-12)

All three fixed; the first was a defect inside round 2's fix. The mechanism: round 2 enumerated page citations but
looked only backwards from each and masked a checked quote's own citation, so it never asked whether every quote mark
was held to a checked citation. Now each checked passage is blanked (its marks and words, not its citation), every
quote mark left is found once over the whole text, and every page citation fails if any mark stands within 200
characters on either side. The citation spellings gained "pg" and a no-break space (in the strict form too); a
straight single quote counts in opening position, an apostrophe never (`BDA3's`, `folds'`, `*k*'s`). Inline code is
blanked, being code. The scan found three prose quotes near citations (the article's wording, "prediction for a new
group", "only"), reworded without quote marks, and "average cluster"/"marginal of cluster" now use the book's own terms
without quote marks (average actor, p. 428; marginal of actor, p. 429), as does the `grade_average_group` row.

Enumeration that ends the loop (the check computes it on every run): 23 checked quotes; 76 page citations, 23 of them
a checked quote's own and 53 others; 20 quote marks left after masking, the nearest 268 characters from any citation.
Probes, each failing as it should: a quote sharing a checked citation, a quote after its citation (plain and with a
citekey), "pg.", a no-break space, straight and curly single quotes, words between, a pandoc citation, "pp" with no
dot, "page", round 2's same-line credit, a dropped citekey (count 22), an added quote without `n_quotes` (count 24), a
wrong cited line, a lead-in, an empty passage, an unknown book, a verdict in prose, a deleted, duplicate or stale
setting, a wrong page and a fabricated word; a valid quote wrapped across lines passes.
