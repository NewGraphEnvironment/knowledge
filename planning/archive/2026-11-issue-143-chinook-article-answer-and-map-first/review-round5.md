# Review round 5: branch 143-chinook-article-answer-and-map-first-the (HEAD 1a78c43)

## Checklist read

- code-check-python.md: in full (6 rules; nothing in the diff is Python).
- code-check-r.md, code-check-shell.md, code-check-spatial.md: by heading, none beyond the index lines. Round 4's fix
  changes prose and inline values only; it adds no code, shell or spatial work.
- code-check.md: the prose of every H3 under `## Mechanisms` (opening paragraphs), with "A guard's scope, escape
  hatches, and remedies" and "One fact derived twice" read for this loop's mechanism.

## What I ran

All runs used a `git archive HEAD` copy in the scratchpad (`rv5`).

- Both articles render with `pkgload::load_all()` and `rmarkdown::render()`; no `stopifnot` fires. I read the rendered
  text of both pages in full.
- `test-settings-register.R`: 0 failed, no error. `test-vignette-data.R`: 0 failed, no error, 2 skips (no `data/` in
  the copy).
- Placement: `R/fdis_place.R`, `R/fdis_quality.R`, `inst/method/settings.csv` rows `snap_search`, `snap_limit`,
  `snap_limit_code`; `method.rds$funnel`; the three `#snap` examples' flags.
- Records: `R/tune_run.R:128-181`, `R/fdis_species.R:130-158`, `scripts/0310-evidence-build.R:190-217`,
  `method.rds$funnel_species`, `chinook_rearing.rds$summary` and `$tune`. Counted the filters on the evidence tables
  in the main checkout's `data/fdis/derived`, whose md5s (`1bd35829…`, `009698d7…`, `99f499bb…`) are the summary's
  `evidence_md5`.

## Round 4's two fixes

1. **Records cell: the group count holds.** "7,659 sites in 105 watershed groups: those on ... in groups where link
   expected chinook when the tuning ran". 105 is `summ$groups`, the groups holding the 7,659 (reproduced: 105 distinct
   groups among the sites passing every filter). link's expectation is now a condition on the groups, not a count. The
   4,858 / 234 / 45 clause matches `dflt$n_visits`, `dflt$n_detect` and `summ$groups_both` (the 105 groups hold 235
   detections; one sits in a group with no absence, so 234 in the 45). The condition list is incomplete, which
   predates the branch (finding 1).
2. **Methods step 2 and `#snap`: hold, exactly.**
   - `snap_search` = `snap_limit_code` = 500 m, so every hinted hit lies within 500 m and `flag_far_snap` can never
     fire on a confirmed pick. A code-checked visit (`ws50_checked`) with no hinted hit within the search is either
     `flag_ws50_mismatch` (some stream within 500 m) or `flag_not_placed` (none), and `knw_fdis_quality()` drops both.
     It never falls back to the nearest stream, even one within 200 m. "is dropped if none does" and "with none of its
     streams that close, the site is dropped" say exactly this, with no gap between the 500 m limit and the search
     radius.
   - "A site with no such record goes to / takes the nearest stream, ... within 200 m" matches `ws50_checked` FALSE,
     then `flag_far_snap` beyond `limit_near`; "in a form the Atlas can check" now opens both passages, matching
     `ws50_checked` (a row in `hinted`).
   - The three `#snap` examples agree with it: the kept and moved sites are code-confirmed; the dropped one
     (103962_6_1) has `ws50_checked` FALSE and `flag_far_snap` TRUE at 239.7 m, so "dropped for its distance" is its
     true reason, not a mismatch.
   - The chinook Placement cell and the page its "More" opens now say the same thing.
   - **Dropped-sites sentence still holds.** "About 4,000 visits are dropped here, most because the stream is too far
     away": 51,587 − 47,610 = 3,977. Of them, no usable point 1,037; no stream within 500 m 622; beyond the limit 1,941;
     code names no stream in reach 377. Distance accounts for 2,563 (64 %), or 2,940 (74 %) counting the 377 the new
     wording also frames as distance. "Where are records lost?" (66 % of 6,100) is 3,977 / 6,058 = 65.6 %, consistent.

## Enumeration

Round 4's 42 rows re-walked against the current text, plus 5 added.

| Row | Verdict now |
|---|---|
| Title; :145 "than link's current rule allows"; opening `default` = 5.49 %, 1.5 m | hold (3) |
| Fig 1 caption; BULK 1,482 / 2,096 km; drops / gains / "the rest"; "around Smithers" paragraph | hold (4) |
| Table 1 rows 1-3, rows 4-6, caption, note "125 groups ... when the comparison ran", note "lines through wetlands" | hold (5) |
| Table 1 note "Sites are the 11,532 ..." | holds |
| bcfishpass order-5 exception ("if its width is mapped"); "`default` leaves that exception off" | hold (2) |
| Fig 2 caption and the 10.2-11.4 % / 0.3-2.9 % paragraph; close calls (164 of 6,149, 2.5 SE); Fig 3 caption; "back to link's" | hold (4) |
| Table 2 "link now" etc.; Table 2 note on `rule_196` | hold (2) |
| Other-checks table; wetland bullet (2,500 / 8,400 km); "at link's slope limit"; "beats link's default, not bcfishpass's" | hold (4) |
| Records cell "7,659 sites in 105 watershed groups: those on ..." | groups hold; **condition list does not** (finding 1) |
| Placement cell | holds |
| Slope; Candidates; "Rules run by"; "Left out" (as round 4 read it: bcfishobs) | hold (4) |
| habitat_thresholds opening (bcfishpass, crossings, parameter sets) | hold (2) |
| habitat_thresholds link / fresh / config rows | holds |
| habitat_thresholds unchanged lines (example rule, funnel, Limits, settings) | hold (1 row) |
| README 0.11 / 11 % / "Access and link's other steps" / Learn-more line (`CH_rear_v1` `rear_gradient_max` = 0.11) | holds |
| CLAUDE.md grad_ext line | holds |
| habitat_thresholds step 2 and `#snap` (round 4's added row) | holds (fix 2) |
| one-SE paragraph "changes link's current rule least"; "stay nearer link's rule" | holds |
| funnel sentence "where link expects the species, with no code that could hide it and no natural barrier" | holds |
| chinook References link "Version 0.66.0" | holds (accepted tradeoff) |
| "River polygons ... though no site in one was scored" | holds |

Rows added this round:

| Where | Source | Verdict |
|---|---|---|
| step 2 "About 4,000 visits are dropped here, most because the stream is too far away" | `method.rds$funnel` | holds (64-74 %) |
| "Where are records lost?" "66 % of the 6,100 dropped"; "far from any stream, or on the wrong tributary" | funnel | holds |
| `#snap` example fates (kept / moved / dropped for its distance) | `method.rds$examples` flags | holds |
| Limits "A site's tributary code can name several Atlas streams, and the site goes to the nearest of them" | `knw_fdis_place()` nearest hit | holds |
| chinook "Left out" cell "Sites off ordinary stream lines, of an unusual fished area, or with a barrier to chinook downstream" | `tune_run.R:161` | **does not hold** as a full list (finding 1) |

**Count: 47 items checked, 45 hold, 2 do not** (the Records cell's condition list and the Left out cell, one finding).
Rows added: 5. Neither failing row is inside round 4's fixes; both predate the branch.

## Findings

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:369 (Records cell) and the "Left out" cell (:376). The cell
  defines the 7,659 as "those on ordinary stream lines, of a usual fished area, with no barrier to chinook downstream,
  in groups where link expected chinook". The code applies one more filter: `d$status != "blocked"`
  (`R/tune_run.R:161`), which drops a site whose catch includes a code that could hide chinook
  (`R/fdis_species.R:155`, `blocks_absence_of`).
  - On the summary's evidence build, the four stated filters leave 7,748 sites; the hidden-code filter removes 89 of
    them, giving the 7,659 (groups stay 105). `funnel_species` shows the step as `in_range` 17,414 → `not_blocked`
    17,296.
  - The page the cell's "More" link opens lists it ("with no code that could hide it"), so the two pages define the
    set differently. The "Left out" cell repeats the three conditions as what was left out and omits this one too.
  - Predates the branch: main's "What records were used?" paragraph (main :136-138) had the same four-condition list.
    It belongs to this loop's mechanism (a qualifying clause dropped in compression; the stated and true sets agree on
    98.9 % of members).
  - Fix, for example: "... with no barrier to chinook downstream and no catch that could hide them, in groups where
    link expected chinook ..."; and in Left out, "... with a barrier to chinook downstream, or a catch that could hide
    chinook".
  - **Rule:** writing.md "State each claim by the code's definition"

Not filed (as round 4): "Software and citation" renders "(2026). :. New Graph Environment Ltd. Version." under a
`load_all()` render of an archive copy; the line is unchanged from main and reads the installed package's citation
under pkgdown.
