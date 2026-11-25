# #274: seven cited works of the detection methods, added to the statistics store

## Outcome

Six of the seven works the detection methods' documentation cites are now filed under `statistics/detection` with
their PDFs and are in the `statistics` store, rebuilt and pushed: Morris et al. 2019, Kellner et al. 2023, Taylor
2008 (the accepted manuscript, the only free copy), O'Brien et al. 2003, Best & Fisher 1979 and Albert & Anderson
1984, all but Taylor's the published version. Seber 1982 is the gap: a book in print with no lawful free copy. The
three works Unpaywall called closed all had a free copy of the published version on ResearchGate, which Al fetched
for the two that met its human check; the plan's search-first rule held again. No abstract-only row was needed, so the
open question about filing one went away.

Learned:
- **0270 files a CrossRef journal name undecoded** (`&amp;`): `crossref_item()` runs only the title through
  `plain()`. One group item already carries it. Filed as #278; Taylor's row works around it with `override`.
- **Zotero's file server can already hold a new upload's bytes.** For five of the six new items 0270 reported `pdf
  exists`: the server recognised the md5 and registered the attachment without a second upload. Each attachment's md5
  was read back from the Web API and matched the local file.
- **Facts about our machines reach a public repo by three routes**, and the code-check needed five rounds to close
  them: tool or server output copied into notes, the agent's own notes on where each step ran, and review files that
  quote or describe what they flag. Round 4 found round 3's fix sitting on top of unpushed commits that still held the
  text; round 5 found round 4's own file naming both host names. The loop ended on a mechanical enumeration
  (`review-enumeration.md`): the #56 sweep over every branch file and commit message, and a fact-kind grep over the
  965 added lines, each hit given a verdict. The plan's notes now state requirements instead of machines.

## Measurement

| | before | after |
|---|---|---|
| `statistics/detection` items, all with a PDF on disk | 24 | 30 |
| `statistics` documents / chunks | 32 / 11,182 | 38 / 11,554 |
| `statistics` file | 154.7 MB | 159.1 MB |
| new PDFs | | 6, 4.92 MB |

- The build held to the expected file written before it ran: 53 members, the same 15 left out with no live PDF, 38
  keys, "32 documents before, 38 after: 6 added, 0 dropped", no "Skipped" warning. 11.6 min.
- Every one of the 38 document origins is a live PDF attachment in the group library.
- Query checks, top 5, each expected work absent before and returned after: simulation-study performance measures
  (Morris, all five), a von Mises kernel with a plug-in bandwidth (Taylor 3rd to 5th, behind Ridout & Linkie 2009),
  the unmarked package (Kellner, all five).
- 0270: dry run 6 `would create`; live run 6 created; second dry run 0 `would` lines.
- The push's multipart ETag matched the file at 8 MiB parts (19 parts).
- Tests: 466, 0 failed, 1 error in `test-link_flow.R:67`, raised by the database server, not by R code (no R code
  changed); reported to Al.
- Code-check: 5 rounds (1 clean, then 1, 2, 2, 2 findings, rounds 3 to 5 each inside the previous fix), ended by
  enumeration (`review-verdict.md`).

## Evidence

`scripts/logs/rag/20261125_*` (the 0270 dry runs, live run and measures, the expected outcome, the before and after
queries, the rebuild, the push); `enumeration_round0.tsv`; `review-plan.md`, `review-round*.md`,
`review-enumeration.md`.

Closed by: the PR for #274
