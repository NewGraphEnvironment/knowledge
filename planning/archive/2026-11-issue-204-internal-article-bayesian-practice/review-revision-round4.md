# Review of the revision, round 4 (#204)

Reviewer: closing round on `dc99543f` (fixes for round 3). Checks run in a detached worktree of `dc99543f`, removed
afterwards: both `bayesian_alignment_check.R` runs, a full `rmarkdown::render()` of the article after
`pkgload::load_all()`, and the article's `load` chunk evaluated against mutated copies of `method.rds` and
`cut_points.rds`.

## Checklist read

`code-check.md`, `## Mechanisms`: above all "Restore the bug and prove the guard fires" (each new guard was run against a
mutated bundle, and the output grepped for the guard that stopped, not just for a stop), "A guard's scope, escape
hatches, and remedies" (NA and NULL lookups as escape hatches; whether the guard covers the set its sentence names),
"A proxy is not the property" (the md5 pin against the pick proxy it replaces), "Written data outlives the fix" (every
artifact quoting the moved line numbers and the guards' scope), "A fix lands in one of two callers that share a harness".

## Round 3's findings

| # | finding | fixed? | is the fix right? |
|---|---|---|---|
| 1 | stale `R/tune_run.R` line cites; research check FAIL | yes | All seven cites now land on their code: `:273` is `rec$grade_withheld <- ... cv$heldout >= rec$null_heldout_curve`, `:299` the `in_range`/`blocked` filter, `:300` the `barrier_dnstr_` filter, `:302` `d$U <- as.integer(d$present)`. No other tracked file outside `planning/archive/` cites `tune_run.R:<n>`. `Rscript data-raw/bayesian_alignment_check.R` PASS (exit 0; its output is byte-identical to the committed `20261113_bayesian_alignment_check.txt`); the `MD=` run PASS on quote lines 207/223/233/275/289, matching the updated committed log. |
| 2 | "the build the published tuning reads" pinned only by chinook's pick | yes | The two md5 pairs are the discriminating fact. Mutations: cuts bundle's `published_145/visits_link.csv` md5 changed, stops on that `identical()`; method bundle's `visits_species.csv` md5 changed, stops on its `identical()`; method bundle's `visits_link` key removed, stops. Escape hatch: both keys absent (or both `md5_local` NULL) compares `NA` with `NA` (or `NULL` with `NULL`) and passes, but `vignette_method.R:60-61,574` names the method bundle's keys by literal, so its side is always present and the hatch is unreachable with today's writers. |
| 3 | `d_floor` missing from the choice | partly | Line 148-149 now matches `.tune_pick()` (`R/tune_score.R:456-461`) exactly: region rules ordered by departures then score; if the first has `exc_d < d_floor`, take the first with `exc_d` NA or `>= d_floor`, which equals "the fewest-departures close call, passing over any with an exception under 200 m". `identical(val("d_floor"), "200")` fires when the value is changed or the row removed. But the table's row 4 (line 182), which round 3 named, is unchanged; see below. |
| 4 | "keeping the near-ties together rather than naming one winner" | yes | "reporting the near-ties beside the one it chooses rather than a single winner alone" matches `thresholds.csv` (`value` with `range_lo/range_hi`) and the table's row 8. |
| 5 | "slightly earlier `link`" as a second cause | yes | Clause and its version pin removed; "leaves out three kinds of cut at once" stands on its own, as `research/minimal_network_tuning.md` and the stream-splits article say. No other version claim remains in the article. |
| 6 | "every published species and stage has been tuned on it" unpinned | yes | `setequal(sc$key, cp$other_keys$key)` stops when `WCT_rear` is dropped from `other_keys` (mutation run). |

Rendered page: the four changed sentences read as intended (checked in the rendered HTML's text).

## Enumeration, changed lines only

| line | claim | source | verdict |
|---|---|---|---|
| 119-121 | the tuning reports the near-ties beside the one it chooses | `thresholds.csv` `value`, `range_lo/hi`; table row 8 | T |
| 147-149 | choose the close call changing link's definition least, passing over any whose exception is under `d_floor` m | `.tune_pick()`; `val("d_floor")` pinned `"200"` | P (value) / T (rule) |
| 182 | row 4: "the close call nearest link's current habitat definition" | `.tune_pick()` | **TU** (below) |
| 229 | "choosing the close call nearest link's current habitat definition is a decision" | as above | T (it names the decision, not the rule) |
| 380-381, 387 caption | the build the published tuning reads | md5 pairs pinned | P |
| 404-406 | minimal network leaves out three kinds of cut, so the runs cannot isolate fish-record cuts | link `break_order`; minimal_network_tuning.md | T |
| 418-420 | every published key tuned on the minimal network | `setequal()` pinned | P |
| 82-88 (guard) | new pins | mutation runs above | P, each fires |
| `research/bayesian_alignment.md` 207, 245, 269, 279, 398, 399, 415 | line cites | `R/tune_run.R` read at HEAD | T (table rows checked by the script; prose cites by hand) |
| `CLAUDE.md` 79-80 | the article's cuts guard "stops the build when the two bundles' chinook rearing picks part" | the article's guard | **W** (below) |

## Findings

**[low]** `vignettes/tuning-bayesian-practice.Rmd:182` — table row 4 still answers "which close call is chosen?" with
"the close call nearest link's current habitat definition", without the `d_floor` exception that line 148-149 now
states. Round 3 named this row; `dc99543f` fixed only the prose. Today the two agree (pick equals recommended in every
key), but if a promotion's fewest-departures close call has an exception under 200 m, the published rule is not the
nearest close call and the row is wrong with no guard firing. Remedy: "the close call nearest link's current habitat
definition with no near-river exception under 200 m" (or the `r val("d_floor")` form).
**Rule:** "State each claim by the code's definition" (writing.md); "A guard's scope, escape hatches, and remedies"
(a fix lands in one of the places carrying the claim).

**[low]** `CLAUDE.md:79-80` — says the article reads `cut_points.rds` and "its guard stops the build when the two
bundles' chinook rearing picks part". From `dc99543f` the guard also stops when the cuts bundle's `published_145`
visit tables differ from the method bundle's evidence (any promotion onto a new evidence build, even one leaving chinook
rearing's pick unchanged) and when the published key set differs from the minimal run's. The next promotion onto a new
build will stop this article's build for a reason CLAUDE.md does not name. Remedy: "stops the build when the two
bundles' chinook rearing picks part, when the cuts bundle's published evidence is not the tuning's, or when the
published keys are not the minimal run's".
**Rule:** "Written data outlives the fix" (enumerate every artifact describing what moved); Documentation Staleness.

No other issue: both alignment checks pass, the article renders, and every guard `dc99543f` added stops when its pinned
fact is broken.
