# Plan review for #140 (Plan agent, 2026-11-26), with verdicts

Blockers raised: 2
Owner forks: 1

Each finding was probed before it was folded or declined.

| # | kind | finding | verdict |
|---|---|---|---|
| 1 | Blocker | The built workbook tables hold no GR (`0250` keeps only species with a `species_group`); the raw UPCE file has 804 GR rows, Pine 10 | Confirmed (`cut` of `workbook_species.csv`; grep of the raw files). Owner fork: Al moved it to #281 (2026-11-26) |
| 2 | Blocker | No GR size classes; lengths only in the ignored `data/fdis/build/fish.rds` | Folded: the spawning step reads `fish.rds`, held to the run ledger |
| 3 | Gap | Name the columns: width `cw_deploy`, MAD `mad_pick`, gradient `segment_gradient`; 15 % of range visits have no `cw_deploy` | Folded into Phase 5's spec: the tuning's columns; a blank width is its own class, counted |
| 4 | Gap | 1,140 of 1,231 GR-present visits sit on `access_gr = 2`, which their own records set | Folded: code 2 stays in the population, never a covariate or stratum; `access_gr = 0` visits counted and dropped |
| 5 | Gap | No edge or area filter | Folded: link's GR edge types (stream, canal); river-polygon edges counted apart; area 10-10,000 m² as `0291` |
| 6 | Gap | Gradient classes stop short of 5.49 %, every pick's limit | Folded: the ladder runs past 5.49 % |
| 7 | Gap | `data/gr_use.csv` needs its CLAUDE.md root-tier entry; NOTICE covers FDIS tables | Folded into Phase 6; workbook rows are #281's |
| 8 | Gap | No ignored directory named for Hagen's zip; reading its segments needs fwapg | Folded: `data/hagen_segments/` ignored; the read uses this machine's fwapg |
| 9 | Gap | Is `grayling_habitat.md` a quoted file? | Decided: no. It cites evidence rows by data row and the life-history file, and quotes nothing, so it stays out of `QUOTED` |
| 10 | Gap | Phase 4 has no meaning audit | Folded: the quoted file gets the same audit rounds as the rows |
| 11 | Gap | Issue and research pointers to #140 as the rebuilt baseline | #139's register sentence was already moved to #280 in Phase 1. Folded: `baseline_anchoring.md` lines 99, 111 and `research/README.md` rows 30 and 35 point to #280 and the new file |
| 12 | Ordering | Settle inputs before the spec | Done: #281 takes the workbooks, `fish.rds` is in |
| 13 | Assumption | Nothing checks the local evidence is the published build | Folded: the script refuses visit tables whose md5 is not the run ledger's |
| 14 | Assumption | No `lacustrine` in the vocabulary | Confirmed (`R/literature.R:82`). Brief corrected before the drafters started: lake form goes in `note` |
| 15 | Assumption | Timing listed among rows | Folded: timing and onset temperature are quoted in the life-history file, not rows |
| 16 | Assumption | "no gradient row" is wrong: row 1186 is GR's `access_gradient_max` with no value | Folded: "no habitat-gradient row" |
| 17 | Scope | Phase 5 may be a PR of its own | Mostly met by #281 taking the workbooks; the remaining script is one analysis |
| 18 | Acceptance | Make "found nothing" checkable: `none` rows for the six cells; consider GR in `0280`'s `COVERAGE` | Folded: a check that each of the six cells has a row. Declined: `COVERAGE` would demand all 12 parameters for GR, beyond this issue |
| 19 | Acceptance | Rerun-identical needs a fixed seed with resamples drawn before parallel fits, and the evidence md5 in the log | Folded |
| 20 | Acceptance | NOTICE's quotes line names only the two CSVs | Folded: it names `research/*_life_history.md` |

## Files the plan names

data/literature_evidence.csv
scripts/0280-literature-verify.R
research/grayling_life_history.md
research/grayling_habitat.md
research/README.md
research/baseline_anchoring.md
data-raw/grayling_use.R
data-raw/README.md
data/gr_use.csv
scripts/README.md
inst/NOTICE.md
CLAUDE.md
.gitignore
