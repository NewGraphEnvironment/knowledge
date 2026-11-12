## Checklist read

- code-check-python.md: in full.
- code-check.md: every H3 under `## Mechanisms` read as prose (tables skipped): "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two callers that share a harness", "Restore the bug and prove the guard fires", "A shared working tree, and what generators leave in it", "A wrapper's exit is not the work", "Zero-length, empty, and unset are three different things"; the remaining four Mechanisms H3s read from the index only. Outside Mechanisms: "Extracted PDF text carries corrupted glyphs, and a tolerant parser turns them into wrong numbers". Not read: the other 25 headings (stand-alone, security, spreadsheet/PDF), none of whose tools this diff uses.
- code-check-r.md: "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires", "A `data-raw/` script must load the source tree, not the installed package", "`nzchar(NA)` is TRUE — non-empty checks silently pass NA"; the rest (about 120) judged from the index lines, none matching a tool this diff uses beyond those.
- code-check-shell.md: "Paths"; the rest (about 105) not read, the diff has no shell.
- code-check-spatial.md: none read; the diff uses no spatial tool.

## Findings

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:117 — a quote on a blockquote line that does not *open* with the quote escapes both checks. Line 117 exempts every `^>` line from the "outside a blockquote" failure, but line 119 only checks `^>\s*"` lines, so `> As the book puts it, "<invented text>" (mcelreath2020StatisticalRethinking, p. 210)` is neither failed nor checked. Probed: that line added to a copy of the research file, `MD=<copy> Rscript data-raw/bayesian_alignment_check.R` printed PASS, exit 0. The header (line 14) says "A quote with a citekey anywhere but a blockquote line fails, so none escapes the check". Fix: fail `setdiff(anyq, ql)` instead of `setdiff(anyq, grep("^>", md))`.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:141-153 — a quote that cleans to no tokens passes. `frags` becomes empty, so the `for (f in frags)` loop never runs and returns TRUE (`found`), and `short <- any(lengths(frags) < frag_min)` is `any(logical(0))`, FALSE. Probed: `> "..." (mcelreath2020StatisticalRethinking, p. 210)` and `> "∑ ≈ √" (mcelreath2020StatisticalRethinking, p. 210)` both printed `ok`, PASS, exit 0. Fix: fail when `!length(frags)`.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:116 — the "quote outside a blockquote" net sees a citekey only if it is one of the two book keys or matches `[A-Za-z]+[0-9]{4}[A-Za-z_]*`. The group library's own `<name>_etal<year>…` form (as in `gelman_etal2013Bayesiandata`) does not match for any book outside `books`, and nor does a passage in curly quotes (“…”). Probed: `Text "a wholly invented passage here" (mackenzie_etal2002Estimating, p. 5) more.` added to a copy gave PASS, exit 0. This also falls under the header's line-14 claim. Fix: widen the key pattern to `[A-Za-z_]+[0-9]{4}[A-Za-z0-9_]*` and accept `“` and `”` as the quote marks.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** research/bayesian_alignment.md:5-6 — the header says "every quoted page checked by `data-raw/bayesian_alignment_check.R`", but four quoted passages cite a page with no citekey and so the script never reads them: line 74 ("imagine leaving out one of the clusters", p. 428), line 115 ("another level of cross-validation" (p. 182)), line 211 ("Bayesian penalized (P) splines" (p. 490)) and line 275 ("the variable causes its own missing values", p. 503). By hand, all four are on their pages today, so nothing is misquoted. But the sentence promises a guard that does not cover them, and the Limits section (line 445: "A page cited without a quote is not machine-checked") implies that a page cited *with* a quote is checked. Either narrow the sentence to the blockquoted passages, or have the script check inline quotes too.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/bayesian_alignment_check.R:191-194 (claim at research/bayesian_alignment.md:386-387 and :447-448) — the anchor check is `grepl(fixed = TRUE)` over the whole file. Neither the cited line number in the table's `where` cell nor that cell's file is ever read. So "each row names the line that makes it, and the check fails if that line moves away" and "fails when the line behind an unkeyed choice moves" are false whenever the line moves: code inserted above `R/tune_run.R:176` leaves every `where` citation stale and the check passing. Worse, `curve_group_effect`'s anchor `"+ s(wsg, bs = 're')"` matches both `R/tune_curve.R:104` (the fit the grade uses, the line cited) and `:133` (the per-fold fit). Removing the random effect from the graded fit at :104 still passes. The other 18 anchors each match once today, and all 19 cited line numbers currently match. Fix: parse `file:line` out of the `where` cell, require it to name `choices[[k]][1]`, require that exact line to hold the anchor, and require the anchor to occur once.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** research/bayesian_alignment.md:6 — the evidence log it cites, `scripts/logs/habitat/*_bayesian_alignment_check.txt`, exists neither in the tree nor on disk (`ls scripts/logs/habitat | grep -i bayes` returns nothing), and no open task in task_plan.md writes it. Logs in that directory are tracked (e.g. `20260929_habitat_store_build.txt`), so the citation points at nothing. Run the check once without `MD=` and commit its log before the PR.
  - **Rule:** none

No public-repo leaks found: none of the added lines (script, research files, planning/active/*) carries a home path, host name, credential path or private link. Paths are relative or under `~`, and the script prints only `md_path` and relative names.

Probe fixtures and outputs: in the session scratchpad (not tracked).

## Dispositions (session, 2026-11-12)

All six fixed. The quote scan now reads every line: any quote followed by a page in another form (no citekey, an
unknown book, curly quotes, a lead-in on a blockquote line) fails, and inline quotes in the citekey form are checked
like blockquotes; a passage with no word fails. The four inline quotes (pp. 428, 182, 490, 503) carry their citekeys
and are checked (23 quotes). Each unkeyed choice's `file:line` must be the anchor's own line and the anchor must occur
once (`curve_group_effect`'s anchor lengthened to the graded fit's line). The header and the choices-table sentence
say what the check does. The log is written and committed. Negative tests: the round's fixtures a, b, c; mutations of
the real file for a wrong cited line, a lead-in quote, an empty quote, an `_etal` inline key, curly quotes, a verdict
in prose; a twice-occurring anchor. Each fails.
