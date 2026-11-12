# Branch review: the enumeration that ended it (#197, 2026-11-12)

Round 3 found a defect inside round 1's fix (a fixture comment's count), so the loop ends on an enumeration, not a
clean round. Mechanism (round 3): a sentence describing an artifact from a neighbouring artifact or from intent, not
from the artifact it names. Candidate set: every claim in a line the branch adds outside `planning/` and `man/` (58
added lines, `git diff 8926ae37 -- . ':(exclude)planning' ':(exclude)man'`; `man/` is generated from the roxygen
lines checked in A). Each read against its artifact:

| # | claim (where) | artifact read | verdict |
|---|---|---|---|
| A | both species lists sorted; they order the species columns of `placed`, so the order is catalog-free (roxygen) | `R/link_place.R` SELECT built from `sp_access`, `sp_hab`; `_stored` loop over `sp_hab` | true |
| B | catalog rows come in plan order; list order is column order; unsorted, two databases write one build's values in another order (code comment) | the query has no ORDER BY; #165's two ledgers' habitat lists differ | true |
| C | two tables' bytes differed between databases until #197; crate's verdict never moved, `evidence_md5` did (`evidence.yaml`) | `receipt_165/20261112_evidence_receipt_compare.txt`, `research/run_archive.md` | true |
| D | header issue lines, "fixed" (both research files) | this branch | true once merged |
| E | the two tables carry one column order on any database | A, plus 0310's later columns from fixed keys and `knw_species()` | true |
| F | the published ledger lists both species groups in catalog order | `20261103_evidence_build_ledger.csv`: `BT;CH;CM;CO;PK;SK;ST;WCT;GR;KO;RB` both rows | true |
| G | the next build moves the species columns once | F differs from the sorted `BT;CH;CM;CO;GR;KO;PK;RB;SK;ST;WCT` | true |
| H | `segment_fwa_gradient` added by #120 (so the md5 changes in any case) | `58fe4bb8` 2026-11-04 (#120), after the 11-03 build; its ledger has no `segment_fwa_gradient_missing`; 0310:321 | true |
| I | `visits_link` differs on the parent flows #161's fix moves | 0310:311 writes `knw_link_flow()` output (`mad_m3s`, `flow_from`); 632 lines moved, 4 visits on them (round 3) | true |
| J | grade bytes differ only in `evidence_md5`, through `visits_link`'s column order (`run_archive.md` table) | `receipt_165/`: `visits_species`, `walks` byte-identical | true |
| K | fixture: four species with an access column, five with a habitat table, KO without access (test comment) | the fixture's `tbl`/`col` vectors | true (fixed this round) |
| L | `_stored` copies follow the habitat list's order (test comment) | re-gating loop `for (sp in sp_hab)` | true |

Nothing sits above its source. The loop ends here.
