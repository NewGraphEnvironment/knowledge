# Task: Bull trout life history: one research file quoted from the store (#198)

**What changes if we do it:** the bull trout habitat definitions (spawning and rearing) and species-at-risk work on both listed units stand on one written account of the species' life history, quoted from the documents rather than restated from memory. **If we never do:** each proposal and tuning pass restates life history from memory, one PDF at a time.

#194 merged (PR #218, 2026-11-15), so the "blocked by" no longer holds. No issue comments.

## Decided at the gate (Al, 2026-11-16)

1. **0280 checks the quotes.** `scripts/0280-literature-verify.R` gains a third input beside the evidence table and the
   IP registry: a list of quoted research files, starting with this one. Each quote goes through the same key
   resolution inside the group, the same token matcher and the same statuses (`check_row()` on a `quote_row()`,
   which is how the registry's quotes are checked now). So there is one gate and one matcher.
2. **Brief, then link.** The life-history story is quoted in full: forms, migration, redd-site selection, juvenile
   rearing, and the split of forms across BC. Thermal limits, timing, spawning gradient, substrate and groundwater
   already sit in BT evidence rows (181 of them) and in `thermal_requirements.md`, `bt_spawning.md` and
   `habitat_literature.md`. For those, the file gives one or two quoted sentences, then cites the data rows and links
   the file that holds them.
3. **Mechanism (agent's call).** File name `research/bull_trout_life_history.md`. Quote form
   `"<passage>" (<citekey>, p. N)`, page as printed. 0280 records the PDF pages each quote matched, as it does for
   evidence rows. Where the printed page and the PDF page differ, the meaning audit checks the page.

## Phase 1: 0280 checks quotes in research files
(Revised after the plan review, `review-plan.md`; each finding checked against 0280 before it was folded in.)
- [x] `QUOTED` (env, space-separated paths; default `research/bull_trout_life_history.md` once that file exists, empty
      until Phase 3 lands it). A listed file that is missing fails, and so does one with no parsed quote.
- [x] Parser, on the raw text (never `clean()` the whole file: it turns backticks into `'`). First blank fenced blocks
      and inline code. Then strip a leading `> ` from each line (blockquotes) and join the lines. Pull every
      `"<passage>" (<key>, p. N)`, `pp. N–M`, or `(<key>, p. N, OCR)`. Delimit with straight `"` only; curly marks may
      sit inside a passage. Keys match `[^\s,()]+` and `resolve()` judges them. Pages are arabic or roman numerals;
      one key per citation. Emphasis markers (`*`, `_`) are refused inside a passage.
- [x] Stray-mark guard: once the parsed quotes are blanked, these fail: any straight or curly double quote; a curly
      opening single quote; a straight `'` that opens a word; a `>` line holding no parsed quote.
- [x] Each quote is checked as a registry quote is (`check_row(quote_row(key, quote, src))`), after `quote_row()`'s
      definition. `src` is `text`, or `ocr` only where the citation says OCR, never as a fallback. Research
      fragments need at least 4 word tokens (the alignment check's `frag_min`), not 0280's 3 tokens counting
      punctuation. The log is named from `LOG` the way the registry's is (`<LOG>_research.csv`), one row per quote
      (file, line, key, source, status, PDF pages), and flags a quote matched on several pages. It goes into the
      summary and the exit condition.
- [x] Prove the guard fires on a scratch fixture, with `LOG=` in the scratchpad so the committed logs are not
      rewritten: a fabricated quote gives `quote_not_found`; a key not in the group gives `key_not_in_group`; a quote
      with no citation, a quote in single quotes, an unquoted blockquote and emphasis inside a passage each fail; an
      empty or missing listed file fails; a real quote passes. Then 0280 on the committed tables (`QUOTED` empty) has
      every status count unchanged from the run before the change.
- [x] One line each in 0280's header, `scripts/README.md`'s 0280 entry and CLAUDE.md's evidence notes: 0280 also gates
      the quotes in the research files `QUOTED` lists.
- Scope, settled by the review: a table passage cannot be a research quote, so timing tables are cited by data row.
  Quotes are short, as in the evidence table. #209's restricted reports are not in the store and are not quoted.

## Phase 2: Search the store
- [x] Before any query runs, write the expectations into `scripts/logs/rag/<yyyymmdd>_query_bull_trout_198.log`
      (#194's format): 2–3 queries per topic, each naming the keys expected (for example Fraley & Shepard 1989,
      McPhail & Baxter 1996, the BC 2023 management plan, COSEWIC 2012/2025, the Hagen Williston series, the USFWS
      2015 recovery plan, Mochnacz 2021, Baxter's work).
- [x] Run them with `ACTION=query STORE=bull_trout TOPK=…` through `0150`, and log the returned keys and every miss
      against those expectations. A miss is reported, not tuned away. (Ran as 0150's query does, `crd_search()` on the
      local store, unverified, but all 14 queries in one process instead of 14 `0150` calls.)
- [x] Read the candidate passages on their PDF pages (pdftotext from the group's attachment), not from the chunks.
      Draft per topic in `planning/active/draft-<topic>.md`, every quote with its key and printed page. Up to two
      general-purpose drafters, one per half of the topics, told not to spawn and to write to their draft file.
- [x] Run 0280 with `QUOTED=` on each draft as it lands, so a drafting error shows before Phase 3.

## Phase 3: Write `research/bull_trout_life_history.md`
- [ ] Header line: Verified, Issues (#198, store #194, relates #33, #51, #199), Produced by (the `bull_trout` store,
      the query log, 0280's research log), Status.
- [ ] "In brief": the life-history expectation in plain language, then what the store does not settle.
- [ ] One section per topic, each a question the reader brings: forms; migration and spawning timing; redd and
      spawning-site selection; thermal limits (brief, then rows and a link); juvenile rearing; the forms across BC and
      the two SARA units (South Coast and Western Arctic). Where a source's region matters, the claim names it (BC,
      Montana, Oregon, Alberta).
- [ ] "What the store does not hold": the scans no build reads (#217), the restricted reports (#209), and topics with
      no BC source.
- [ ] Add a row to `research/README.md`. Add a one-line pointer from `bt_spawning.md`'s and `habitat_literature.md`'s
      BT sections to the new file.

## Phase 4: Gate and meaning audit
- [ ] 0280 passes: every evidence row, registry quote and research quote, and the quote count logged.
- [ ] Meaning audit of every claim, not a sample (CLAUDE.md "the gate checks words, not meaning"). Two Explore
      readers, each given half the claims and the PDFs' text, check that the sentence around each quote says what the
      quote says, and that the region, form and life stage are right. The audit also lists every number written outside
      a quote and every data-row citation (row N is file line N + 1, a BT row on that topic); 0280 checks neither. It
      re-reads every ellipsis, and checks the printed page against the PDF page 0280 logs. Fix, then repeat until a round finds no error
      inside the previous round's fixes. Findings go to `planning/active/audit-round<N>.md`.

## Owed at the end (reported, done after merge)
- [ ] Edit #198's body to link the research file. If a gap the file names becomes its own issue, add it to the bodies
      of #33 and #199.

## Validation
- [ ] Tests pass (`devtools::test()`; nothing under `R/` changes, so this is a regression check only)
- [ ] `/code-check branch` clean, three rounds minimum
- [ ] The #56 archive's `public_sweep.py` is clean on the branch
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: Phase 1 is proved by the planted failures (each fails with the named status), and by 0280 then passing
on the committed evidence and registry with their row counts unchanged. The file is proved by 0280 passing on it, by
the stray-quote guard, and by a meaning-audit round that finds nothing.

