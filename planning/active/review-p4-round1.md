# Review p4, round 1: staged diff (literature reader, 0280 gate, evidence table)

Reviewer: code-check subagent, 2026-09-29. No repo file edited. Probes ran from a frozen copy of the gate
(`$SCRATCH/gate_frozen.R`) with `EVIDENCE=$SCRATCH/mut.csv LOG=$SCRATCH/mut_log.csv`. `devtools::test()`:
FAIL 0 / PASS 112.

## Headline: the gate passes fabricated rows

I built 8 mutated rows from real rows and ran the gate on them. **All 8 passed** (log in
`$SCRATCH/mut_log.csv`):

| # | mutation | status |
|---|---|---|
| 1 | row 15 (Cooney & Holzer, table) quote -> `BF < 1 m High High High`, value 1 | verified_table (PDF page **1**, not C-16) |
| 2 | row 150 (Selong, text) quote truncated to `... occurred at 13`, value 13 (source says 13.2) | verified_text |
| 3 | row 138 (Bjornn & Reiser, ocr) `5.6-13.9` -> `9.6-13.9`, value 9.6 | verified_ocr_fuzzy |
| 4 | row 54 (ocr) `fourth- and fifth-order` -> `sixth- and fifth-order`, values 5-6 | verified_ocr_fuzzy |
| 5 | row 140 (text) quote -> `[an editorial insert and nothing else]` | verified_text (page NA) |
| 6 | row 147 (text) quote -> `They are uncommon wherever water temperatures rise above ... 25`, value 25 | verified_text |
| 7 | row 1 (Rebellato, table) quote -> `Bull Trout 0-2 (Busch et al. 2013)` | verified_table |
| 8 | row 161 (Woll 2017, table) quote -> `2 mm < Substrate < 16 mm` | verified_table (page 2, not 84) |

## Findings

- **[bug] scripts/0280-literature-verify.R:183: a quote with no fragments passes.** When the whole quote is
  an ellipsis or a `[bracketed insert]`, `frags` is empty, so `length(hit) == length(frags)` is `0 == 0`
  and the function returns `max(which(starts <= NA))`. That is `-Inf` with a warning, not `NA`. `check_row`
  tests `!is.na(pg)`, so the row is `verified_text`. The reader's 20-character rule does not stop it:
  mutation 5 is 38 characters. The same hole opens when a fragment normalizes to `""`, because
  `regexpr("", ..., fixed = TRUE)` matches at position 1. No committed row hits this, but the guard fails
  toward pass. Fix: `if (!length(frags)) return(NA_integer_)`, and drop fragments that are empty after `norm()`.

- **[bug] scripts/0280-literature-verify.R:206-211 and 225-226: `verified_ocr_fuzzy` is in the pass list, and
  a 10 % edit distance lets numbers change.** `agrepl(max.distance = 0.1)` allows about 1 edit per 10
  characters of quote. Changing a digit in a value (mutation 3) or an order word (mutation 4) still passes.
  The header says the fuzzy match "is reported as such", but it counts as a pass and the gate exits 0. The
  numbers are what the table exists to hold, so a fuzzy hit should pass only when every number in the
  quote also occurs exactly on that page, or it should be a non-pass status for a human to confirm. Row 54
  is the one committed row that depends on it. By hand it is genuine: the OCR has "spawned ina few".

- **[bug] scripts/0280-literature-verify.R:195-200: the `table` check verifies almost nothing, and it
  ignores the cited page.** It asks only whether every number in the quote occurs somewhere on some single
  page of the PDF. Words are never checked (mutation 1: "High High High"), and small numbers such as 0, 1,
  2 or 16 occur on nearly every page (mutations 1, 7, 8 passed on pages 1, 6 and 2). Several committed
  table rows reduce to one or two common numbers: row 15 is `{3.7}`, row 20 `{50, 0}`, row 161
  `{16, 100}`, row 40 `{5, 0.5}`. Nothing compares the page found with the row's `page`. `quote_source` is
  hand-set and the 20-character minimum applies only to `text`, so any quote relabelled `table` escapes
  the text check too. The committed table rows do land on plausible pages (by hand: Rebellato p6,
  Cooney C-16 on PDF page 16, Richter, Eaton, Isaak), so today's data looks right. The guard, though, is
  close to pass-everything. Minimum fix: require the found page to be the cited page, or within a stated
  offset, and require the non-numeric tokens of the quote on that page too.

- **[bug] scripts/0280-literature-verify.R:168-186: a quote ending in a number matches a longer number (no
  boundary), and fragments after an ellipsis match anywhere later in the document.** A `fixed` substring
  match means `occurred at 13` verifies against "occurred at 13.2" (mutation 2), and `range of 0-2` would
  verify against "0-24". Quotes that deliberately stop at a number are common in the table: rows 140, 141,
  148, 149 and 150, whose notes say the text layer mangles the degree sign. For those rows the gate cannot
  tell a truncated value from the real one. After an ellipsis, each later fragment only has to occur
  somewhere after the previous one, with no distance bound, so a short tail such as `25` (mutation 6) or
  `October` (row 181) matches pages or chapters away. Rows 179 and 181 are genuine by hand: the source
  reads "lateaugust" and "midoctober" in the text layer. Fix: require a non-digit, or the end of the text,
  after a trailing digit of each fragment, and bound the gap between fragments, for example to the same or
  the next page.

- **[fragile] scripts/0280-literature-verify.R:144: the `joined` variant deletes a line-end hyphen between
  digits.** `"2-\n4 %"` becomes `24%`, so a quote reading `24%` can verify against a source range of 2-4 %.
  The `table` check uses only `joined`, so a range broken across lines also loses its numbers. It is rare,
  but when it happens it silently changes a value. Restrict the joining to letters: `([a-z])-\s*\n\s*([a-z])`.

- **[fragile] scripts/0280-literature-verify.R:3 against 190-216: the header says "every cited value is
  checked against the PDF", but `value_min` and `value_max` are never compared with the quote.** A row with
  a verbatim quote and a mistyped value passes. I checked mechanically. Every committed numeric row's
  values occur among its quote's numbers, except rows 29, 54, 106, 107 and 158-160. All of those are
  explained: a proportion to percent, order words, and cm to mm. I read all 172 cited rows against their
  quotes and found no value that contradicts its own quote. The data is fine today, and nothing keeps it
  that way.

- **[fragile] scripts/0280-literature-verify.R:183, 200, 204: the logged `pdf_page` is the first occurrence,
  not the cited location.** Row 84 (`Spawning habitat type small streams`, BT, cited p. 117) is logged at
  PDF page 68. That page is a different species' summary table ("preferred spawning temperature
  7.2-13.3 °C ..."). The BT table is on PDF page 141 (printed 117, the same +24 offset as row 72's
  124 -> 148). The row is genuine, but the log's evidence pointer is wrong, and a generic quote from a
  repeated table template would pass for the wrong species. The fix is the same page check as the table
  finding.

- **[fragile, out of diff] data/habitat_modelling_members.csv:54 is now stale because of the timing edit.**
  The collection holds `officeofthewetsuweten_etal2013Moricefish`, labelled "candidate for the unresolved
  officeofthewetsuweten2013Wetsuwet". The correction chose the other candidate,
  `officeofthewetsuweten2013WetsuwetenTitle`, which is not a member. So the timing table's only CO source is
  missing from the `Fisheries/habitat_modelling` collection, and the member list documents the wrong item
  as that source.

## Checked and clean

- **Timing CSV edit.** The line ending is LF like the rest of the file and the quoting matches the other rows
  (empty `end` left unquoted, as before). `knw_timing_read()` reads it, all 3 timing keys resolve in the
  group, and the corrected key names exactly one item.
- **Multi-PDF keys.** No evidence key currently has more than one PDF in the group, so the case where the
  first matching attachment is a different document is latent only. `sort(files)` makes the choice
  deterministic.
- **Pass list.** No failure status is in the pass list. Apart from `verified_ocr_fuzzy`, only `none_row`
  and the exact `verified_*` statuses pass. The exit status covers rows, timing keys and coverage.
- **Snapshot.** It is a whole-file copy with an mtime/size/journal guard and `quick_check`. The live database
  is never opened.
- **Reader.** The new cross-column checks behave as documented. A header-only CSV reads as an empty tibble.
  Tests pass (112).
- **Normalization.** Dropping the spaces around punctuation is applied to the quote and the PDF alike. I found
  no realistic false pass from it on its own. The hyphen-join and missing-boundary findings above are the
  real vectors.
