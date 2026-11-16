# #198: bull trout life history, quoted from the store

## Outcome

`research/bull_trout_life_history.md` is the record of bull trout life history, quoted from the `bull_trout` store
#194 built. It has 170 verbatim quotes, each with its citation key and page, and covers:
- the forms and how they mix;
- migration and spawning timing, and the spawning cue;
- skip spawning;
- redd-site selection by groundwater;
- incubation;
- juvenile habitat and age at leaving;
- the thermal rows, by pointer;
- the sea-run form, the five designatable units (four of them in BC) and the two on Schedule 1.

`scripts/0280-literature-verify.R` now gates research files as well as the evidence table and the registry. The
files are listed in `QUOTED`, and each `"passage" (citekey, p. N)` is checked as a registry quote is. Each file is
read through cmark-gfm, as GitHub renders it, and a quote that escapes the check fails the run. A quote can escape
through a stray quotation mark, HTML, a link, code or emphasis inside a passage, or text in a block quote outside a
passage.

What was learned:
- The gate checks words, not meaning. Every quote passed 0280 before the audit, yet three rounds of meaning audit
  found 44 errors: 36, then 7, then 1. Most of the later ones sat inside earlier fixes: dropped hedges, a life stage
  mixed up, a place a fix had invented.
- The code review followed the same pattern. Each guard written from a list of cases missed the next case. The loop
  ended only when the guard was rebuilt on defined sets: Unicode's quotation-mark properties and names, and the
  renderer's own node tree. An enumeration against those sets then ended it.

## Measurement

| what | number |
|---|---|
| store queries (expectations written first) | 14: 2 hits, 1 miss, 11 partial; the reviews the file leans on were mostly not returned and were read directly |
| quotes in the file | 170, 168 `verified_text` and 2 `verified_ocr`; 7 match on more than one PDF page, the cited page among them |
| meaning-audit findings, rounds 1, 2 and 3 | 36, 7, 1 (all accepted) |
| code-check findings, rounds 1–4 | 1, 3, 5, 3; rounds 2–4 each found a defect inside the previous round's fix |
| closing enumeration: characters | Quotation_Mark 30, Pi/Pf 22, named 56, clean() 11; 0 outside the guard's 79 |
| closing enumeration: renderer | 26 cmark-gfm node names, all handled |
| evidence and registry logs with `QUOTED=` | byte-identical to the run before the branch |
| agents | 11: plan review, 2 drafters, 4 meaning auditors, 4 code reviewers |

Wrong turns, kept as evidence:
- A drafter quoted `lateAugust` and `postspawning`. The text layer drops a line-end hyphen, which the OCR of the
  page images shows, so both are now quoted with `, OCR`.
- A source's own `[DU1 ...]` brackets read as an editorial insert, so those quotes start after the bracket.
- `\x{}` escapes in a PCRE pattern fail on an ASCII-only file.
- `chartr()` refuses Unicode noncharacters.
- My first HTML fallback marked all 170 quotes `html_in_quote`.

Each of these was caught on its rerun, before it was committed. Every code fault failed toward a refusal.

## Evidence

- `scripts/logs/rag/20261116_query_bull_trout_198.log`: the store searches, with expectations and verdicts.
- `scripts/logs/habitat/20261116_literature_verify*`: the gate run, including `_research.csv`.
- `audit-round*.md`: the meaning audits. `review-plan.md` and `review-round*.md`: the plan review and the code review.
- `fixtures/`: `make_enum.R` (the escape cases and negative controls), `enum_sets.R` (the character sets) and
  `enum_nodes.R` (the renderer nodes).

## Owed

- Edit #198's body to link the research file. If a gap the file names becomes its own issue, add it to the bodies

  (The gaps are listed in the research file's last sections. None was filed as an issue in this PR.)

Closed by: the PR for #198
