# Plan review for #284 (Plan agent, 2026-11-26), with verdicts

Read against the issue, `0270`, `0150`, `0280`, `scripts/README.md`, `CLAUDE.md`, `inst/NOTICE.md` and #190's plan.

| # | kind | finding | verdict |
|---|---|---|---|
| 1 | Blocker | link's coho range comes from a presence table sourced from bcfishpass, and bcfishpass-derived files fall under #76; a tracked log of them would be one | Folded (decision 4): the log carries only the Province's observation fields plus the group; link's range is stated in the research file's prose |
| 2 | Gap | `0270` sends an addition whose `pdf` is empty through `ensure(required=True)`: `PDF-MISSING`, non-zero exit | Confirmed at `0270:555`. Folded (decision 5, Phase 2 rows box): an addition is in the CSV only with a PDF in hand or as `none` with a CrossRef abstract |
| 3 | Gap | `row_creators` types every creator as author, so a `bookSection` cannot record its editors | Confirmed at `0270:437`. Folded (decision 5): the book title carries Groot & Margolis, as the temperature additions do |
| 4 | Gap | once cred#48 is fixed, `0150`'s rebuild-after-update text and the README and `CLAUDE.md` copies are stale, and `0150` has no cred floor for update | Folded into Phase 4's `habitat_modelling` box, and owed together with it if cred#48 has not merged |
| 5 | Gap | an update needs the store local (pull with `ACTION=query VERIFY=TRUE`) and the embedder running | Folded into Phase 4 |
| 6 | Gap | `0280`'s `QUOTED_DEFAULT` and NOTICE's quotes row name only the life-history files | Confirmed at `0280:75` and `NOTICE.md:65`. Folded into Phase 5 |
| 7 | Gap | NuSEDS mainstem populations that cross groups join no group unless `data/nuseds_reach_groups.csv` places their reach | Folded: Phase 1 lists them apart, and Phase 5 adds a row per reach the check places |
| 8 | Gap | #190's box confirming that the CSVs need no NOTICE row is missing | Folded into Phase 2 |
| 9 | Scope | "EcoCat stays out" collides with the sources of the 2004 FISS entries | Folded (decision 5): EcoCat searches stay out; a single EcoCat report behind a judged record is gathered |
| 10 | Ordering | the records script names the reports Phase 2 must gather, so it should run first | Folded: the records are now Phase 1, and the judgement stays after the build (Phase 5) |
| 11 | Assumption | joining bcfishobs to the Province's layer by observation id assumes the id is stable | Folded: join on `observation_key`, with the join rate logged |
| 12 | Assumption | the FDIS count's 33 groups are not listed in the issue | Folded: recover the list or log why the count differs |
| 13 | Assumption | `49HFCT96` is a standalone attachment and the build lists it as left out | Agreed; noted in Phase 3 |
| 14 | Acceptance | the free-space threshold, the verdict definitions, one verdict per record, asserted counts, `0280` passing and the sweep need to be stated | Folded into Phases 4 and 5 and the proofs |

No finding was declined. None is a stored-data or scope fork for the owner. Finding 1 is a licence matter, and keeping
the log to the Province's fields settles it inside the rule that already exists.
