# Progress — Bull trout life history: one research file quoted from the store (#198)

## Session 2026-11-16

- Plan-mode exploration — phases approved by user
- Created branch `198-bull-trout-life-history-one-research-fil` off origin/main
- Scaffolded PWF baseline from issue #198 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) landed in `review-plan.md`. Spot-checked before folding in:
  - `value_in_quote()` returns early with no values (0280:422);
  - 21 BT rows from 7 keys are OCR;
  - a group key does contain `&`;
  - the registry log is named from `LOG`.
  All held. Phase 1 revised (parser, OCR by citation, frag_min, `LOG=` for planted runs, empty or missing file
  fails); Phase 2 gained a 0280 run on each draft, Phase 4 an audit of numbers outside quotes and of data-row citations.
- Phase 2: expectations written 14:54–14:55Z, then 14 queries, 14:55:20–14:56:05Z
  (`scripts/logs/rag/20261116_query_bull_trout_198.log`). Hits on R1 and J2 only; a miss on M3; partial on the rest.
  The reviews the file leans on mostly did not return, so they are read from their PDFs directly.
- Phase 1: 0280 checks the quotes in the research files `QUOTED` lists (empty until Phase 3 adds this file).
  - Before and after, run with `LOG=` in the scratchpad on the committed tables: identical evidence and registry logs,
    same status counts (1,151 rows; 117 registry quotes).
  - Planted fixtures, each with the expected status: `quote_not_found`, `key_not_in_group`, `emphasis_in_quote`,
    `quote_fragment_too_short`, `stray_quote_mark` (both a quote with no citation and a single-quoted one),
    `blockquote_without_quote`, `no_quotes_in_file` and `file_missing`. The fixture that should pass does: a quote
    on one line and one wrapped in a blockquote, with inline code and a fenced block holding quote marks.
  - OCR: a quote cited with `, OCR` gives `verified_ocr`; the same quote cited without it gives `quote_not_found`
    (there is no fallback). The 4-word floor refused an evidence row's quote whose first fragment, "chinook salmon
    spawned", has three words.
  - lintr: one semicolon fixed; three constant names in the script's existing uppercase style.
