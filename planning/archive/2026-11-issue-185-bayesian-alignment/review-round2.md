## Checklist read

- code-check-python.md: in full (no Python in this diff).
- code-check.md: the index in full, and every H3 under `## Mechanisms` read as prose, table rows and evidence blocks skipped (all fourteen). Outside Mechanisms the index only, since none of those headings names a tool this diff uses (the PDF headings concern links, glyph-stripped numbers and merging; the script compares tokens and strips no digits).
- code-check-r.md: the index in full (its 120 headings match the copy in CLAUDE.md). Sections read: none beyond round 1's three (`system2(stdout = TRUE)`, `data-raw/` loading, `nzchar(NA)`). All 120 skipped for this round, because round 1's fixes add no R tool those three do not already cover.
- code-check-shell.md: the index in full (70 headings). No sections read; the diff has no shell.
- code-check-spatial.md: the index in full (94 headings). No sections read; the diff uses no spatial tool.

## Findings

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:122-126. The loose detector is compared with the strict one by count per line (`sum(loose > 0) > length(ms)`), not by position, so a strict match that the loose regex cannot see pays for a bad quote elsewhere on the same line. The research file already has such a line. Line 124 (`"By “skeptical,” I mean …" (mcelreath2020StatisticalRethinking, p. 214)`) gives strict 1 and loose 0, because loose's `[^"”]{3,}` stops at the nested `”`. A count over every line finds it is the only line where the two differ.
  - Probe: a copy of the research file with line 124 extended by ` Also "a wholly invented passage that is nowhere in the book" (p. 214).` printed PASS, exit 0, with 23 quotes checked.
  - That quote is in the no-citekey form, which header lines 14-15 say "fails, so none escapes the check". This repeats round 1's defect one axis over: the fix assumed the strict matches are a subset of the loose ones.
  - Fix: compare positions, not counts. Require every loose match to start where a strict match starts, and let the loose passage class admit `”` (or match from each opening quote to the next same-kind closing quote).
  - **Rule:** code-check.md "A proxy is not the property" (its coverage paragraph: the sweep must ask a wider question than the check, and the strict form here holds a member the sweep cannot see)

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:118, 121-123 (claim at :14-15). The loose detector reads one markdown line at a time, and it needs a `,` or `(` right after the closing quote. Several plausible forms therefore escape both checks. Each probe below edited the line-74 quote (`"imagine leaving out one of the clusters" (mcelreath2020StatisticalRethinking, p. 428)`) in a copy of the research file, and each printed PASS, exit 0.
  - **A quote wrapped across two lines.** The prose is hard-wrapped at about 120 characters, and line 74's quote sits at a wrap point. Probe: `"imagine leaving` at the end of line 73, then `out every one of the invented clusters" (mcelreath2020StatisticalRethinking, p. 428)` on line 74. Result: 22 quotes checked instead of 23. The quote count is pinned nowhere, so a reflow that drops a quote from the check is silent.
  - **Single quotes.** Probe: `'imagine fully inventing all of the clusters' (mcelreath2020StatisticalRethinking, p. 428)`.
  - **Words between the quote and the page.** Probe: `"imagine fully inventing all of the clusters", as Rethinking puts it (p. 428)`.
  - **A pandoc bracket citation.** Probe: `"another wholly invented passage here" [@mcelreath2020StatisticalRethinking, p. 428]`.
  - **Pages without the abbreviation's dot.** By the regex, `pp 227` and `page 227` escape too.

  The header's "none escapes the check" is false for each of these, and so is the research file's "every quote that cites a page checked on that page" (research/bayesian_alignment.md:5-6) for any future edit in these forms. Fix: run the loose scan over the whole text, not line by line (`paste(md, collapse = " ")`, mapping offsets back to lines), with any opening quote mark and a short window up to `p`/`pp`/`page` plus a number. Also hardcode the expected number of checked quotes (23) as a contract, so a quote that drops out fails. Or narrow both sentences to the forms the check actually reads.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (terminate by enumeration; the class recurs one axis over)

- **[severity: security]** planning/active/review-round1.md:31. The line "Probe fixtures and outputs:" gives an absolute temp path whose directory name is the session's mangled home path. That slug carries the local username and the repo's location under the home directory. `planning/active/` is tracked, the repo is public, and CLAUDE.md says that `planning/` "from 2026-10-16 carries … no home paths"; the public sweep searches `planning/active/` for local paths. Fix: replace the path with "the session scratchpad", or with the fixture text itself.
  - **Rule:** none (CLAUDE.md, "One discipline: everything here is public")

## Probed and found sound (not findings)

- **Folio test.** With each book's offset shifted by -2, -1, +1 or +2 (in a copy of the script), every one of the 23 quotes fails on "the page's head or foot does not carry its number". A wrong offset fails, as the header says.
- **Anchor check.** All 19 cited `file:line` cells resolve to their anchors, and each anchor occurs once.
  - A cell without backticks parses.
  - A range (`R/x.R:97-105`) compares its first line, so it fails unless the anchor sits on that line.
  - A cell naming two files does not parse, so it fails.
  - The anchor is matched as text, so a commented-out copy of the line at the same line number would still pass. That is noted only; no edit in this diff produces it.
- **Every `file:line` in the research prose.** All resolve to the code they describe at HEAD.
- **Table parsing.**
  - A pipe in a middle cell shifts only middle cells. The id (first) and the verdict (last) cells are what the check reads.
  - A row wrapped onto the next line leaves a non-verdict last cell, so it fails.
  - A second table under the same heading adds its header row as a stray id, so it fails.
- **The committed log.** scripts/logs/habitat/20261112_bayesian_alignment_check.txt matches a fresh run at HEAD line for line.
- **Public-repo leaks.** None in the script, research/bayesian_alignment.md, research/README.md or the log.

Probe fixtures were built in the session scratchpad, outside the repo; each is described above by the edit it makes.

## Dispositions (session, 2026-11-12)

All three fixed. The mechanism behind round 1's and round 2's quote findings: straight double quotes do not say which
one opens, so any detector that pairs quote marks drifts out of phase (a minimum length skips a short quote such as
"in", and every pairing after it flips), and comparing two such detectors by count lets one stand in for the other.
The scan now pairs nothing. It enumerates every page citation in the joined text ("p. N", "pp", "page", `[@`): each
must lie inside a checked quote, or have no quote mark within 80 characters before it once checked quotes are masked.
The number of checked quotes is pinned (`n_quotes`, 23). Enumeration on the file: 75 page citations, 23 inside checked
quotes, 52 outside, none of those with a quote mark within 80 characters. Probes: the round's credit case, a wrapped
quote (still checked, PASS), single curly quotes, words between quote and page, a pandoc citation, "pp" with no dot,
"page", a quote whose citekey is dropped (fails, count 22), and a valid quote added without changing `n_quotes`
(fails). One false positive the scan found (the `response_presence` cell quoted the method's wording) was reworded.
The temp path at line 31 of `review-round1.md` was scrubbed and the unpushed commit amended, so it is in no commit.
