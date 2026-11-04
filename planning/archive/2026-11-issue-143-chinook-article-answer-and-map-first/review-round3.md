# Review round 3: branch 143-chinook-article-answer-and-map-first-the (HEAD e48d0db)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check-r.md, by heading (4 read): "Moving prose into a code chunk hides it from tools that scan the document";
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it"; "ggplot2 legends and labels:
  a key for an unused factor level, and ggrepel labels that must avoid each other"; "`ifelse()` with an all-NA test
  returns a logical vector, whatever `yes` and `no` are". No other heading names a tool or shape this diff uses.
- code-check-shell.md: 0 headings read in full. The diff adds no shell.
- code-check-spatial.md: 0 headings read in full. The map chunks call the unchanged `knw_compare_map()` and
  `knw_compare_mapgl()`.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped), plus
  "An assertion that matches an interpolated value cannot see the claim around it" and "A pluralisation marker takes
  the quantity of whatever was substituted last".

## What I ran

- I rendered chinook_rearing.Rmd from a `git archive HEAD` copy (scratchpad `rv3`) with `pkgload::load_all()` and
  `rmarkdown::render()`. It renders, and no `stopifnot` fires. I read the rendered text from top to bottom.
- Chunk labels: no duplicates in either article. Citation keys: every key in each Rmd is in its `.bib`, and every
  `.bib` entry is cited. The only stray `@D` is inside a code-chunk regex.
- From the bundles: `summary` (visits_in 7,659, groups 105, groups_both 45), `method.rds$funnel_species` for CH
  (in_range 17,414, not_blocked 17,296, no_barrier 7,659, scored 4,858), `compare` (125 groups; default_rule
  `width>=1.5|g<=0.0549|cw channel_width>=15@D1000; mad discharge>=3@D1000 on wetland_flow`; config 102762d), and
  `fv` (11,532 sites = 6,368 + 5,164).
- The Bulkley decomposition reproduces the author's numbers: 1,128.6 km changed, of which 868.0 km are far drops,
  222.1 km near gains, 20.3 km other dials (edge 1000 18.7, 1250 1.0, 1100 0.5, 1450 0.1) and 18.2 km
  connectivity.
- link presence (`ch == "t"`) in `wsg_species_presence.csv`: 125 groups at a17e917, 125 at 102762d, 136 at
  origin/main (e2a8593). CH's `parameters_habitat_thresholds.csv` and `rules.yaml` are unchanged from 102762d to main.
  `rear_stream_order_bypass` is "no" for CH at a17e917 and at main.
- bcfishpass 3bd2824c: `parameters/` holds example_ccira, example_cwf, example_fptwg, example_newgraph,
  example_psf_fraser and example_testing. The CCIRA README says "access model only ... empty thresholds table", and
  the parameters README calls all of them "sample parameters". `docs/01_background.md` defines naturally accessible
  streams as "all stream downstream of natural barriers". `load_habitat_linear_ch.sql`'s order-5 exception sits only
  in the cw branch.
- `R/fdis_place.R` (roxygen) and `method.rds$funnel`: a visit whose code names no stream within the 500 m search is
  flagged `flag_ws50_mismatch` and dropped (377 visits: 47,987 to 47,610). Only a visit "with no code the
  cross-reference knows" takes the nearest stream under the 200 m limit.

## Mechanism

Rounds 1 and 2, and what this round finds, come from one move. The rewrite compressed qualified sentences into short
sentences and table cells. In doing so it dropped the clause that said which build, population or condition a
statement holds for:

- Round 1 dropped "and so does the comparison here".
- Round 2 found "on stream lines" and "when the comparison ran" missing, and a cause attributed to one step.
- This round finds two more: "Where FDIS recorded the site's 1:50k code and the crosswalk knows it" (main's placement
  sentence), and "Sites were kept when they were on ordinary stream lines, of a usual fished area, with no barrier to
  chinook downstream" (main's records sentence).

Each unqualified statement survived review for the same reason: its two possible producers agree on most members.

- The tuning's `dflt` row (link a17e917) and the comparison's regenerated `default` (config 102762d) agree on every
  stream-line dial: width 1.5 m, slope 0.0549, no pair. They differ only on lines through wetlands, and on the group
  set once link moved to 136 groups.
- The code-confirmed and nearest-stream placement paths agree for every site that has no code.
- The tuning's population funnel and the comparison's FDIS check both count "sites in link's chinook groups". They
  differ in which lines and barriers each keeps: 7,659 against 11,532.

So a statement reads true until a reader meets the members where the producers differ.

The author's enumeration (findings.md, "Review mechanism") covers only the near-river dial. It says the other mentions
"name a size, a slope, a score or a total, which do not depend on which build is meant". That is wrong for totals and
counts: round 2's own group-count finding was a count that depends on the build, and the Records row below is another.

Enumeration. These are every sentence, caption, table cell and footnote on both pages, and the README lines the branch
changed, that name link, `default`, bcfishpass or "the comparison", or that quote a number from another build or run.
Each has a verdict:

| Where | Source of the claim | Verdict |
|---|---|---|
| Title / VignetteIndexEntry "choosing link's thresholds" | generic | holds |
| :145 "than link's current rule allows" | direction is the same at a17e917, 102762d and main (no pair on stream lines in any) | holds |
| :145-148 opening: `default` (a17e917) "start from the thresholds New Graph runs bcfishpass with", `words(dflt)` = 5.49 %, 1.5 m | bcfishpass NG row 0.0549 / 1.5; link a17e917 and main the same | holds |
| Fig 1 caption "Orange: link's current rule only" | comparison 102762d; CH thresholds and rules unchanged to main; BULK presence unchanged | holds (as a rule; the segments are the 10-17 build, which the page does not claim are current) |
| :160-161 BULK 1,482 / 2,096 km "under link's" | comparison | holds |
| :161-165 drops / gains / "the rest" | guarded; decomposition reproduced | holds |
| :170 "less habitat than link's ... caught more often" | comparison; guarded | holds |
| Table 1 rows 1-3, "link now" (1.5 m, 5.49 %, "none on stream lines") | tuning row a17e917 | holds |
| Table 1 rows 4-6, "link now" (99,186 km, 15 %, 2.2 %) | comparison 102762d | holds. The footnote ties it to "when the comparison ran". Rows 1-3 and 4-6 come from two builds that agree on the stream-line dials, and no guard checks that they do (see the note under Findings) |
| Table 1 caption "link's current rule" | both builds above | holds while they agree |
| Table 1 note "125 watershed groups link classified for chinook when the comparison ran" | `per_group` = groups in the 10-17 schema's `streams_habitat_ch`; presence 125 at a17e917 and 102762d | holds (past tense) |
| Table 1 note "Both totals include lines through wetlands, which the two rules test differently" | comparison | holds |
| Table 1 note "11,532 electrofishing sites on reachable streams in those groups" | comparison FDIS check (edge types include river and wetland lines; accessible) | holds alone. It conflicts in reading with the Records row (finding 2) |
| :203-205 bcfishpass's order-5 exception | SQL at 3bd2824c, cw branch only | holds |
| :206 "link's `default` leaves that exception off" | bypass "no" at a17e917 and main | holds |
| Fig 2 caption and :235-238 | curve from the tuning run; guarded | holds |
| :246-248 "nearest link's; all differ from link's stream-line rule in every dial ... 2.5 SE behind" | tuning row; `departures == 3` guarded | holds |
| Fig 3 caption "value of link's rule on stream lines" | tuning row | holds |
| :299 "back to link's" | guarded | holds |
| Table 2 "link now", caption "link's current rule", "Bold: differs from link's rule", "close call at neither" | tuning row | holds |
| Table 2 note "This package's thresholds table (data/thresholds.csv, column rule_196) ... every species tuned" | data/thresholds.csv: rule_196 filled for every `fitted` key | holds |
| Other-checks table "link's on 0", "beats link's on 4 of 5", "Points to" | tuning run | holds |
| :347-351 wetland bullet "In the comparison, link's rule counts them by their size or by a near-a-river pair" | comparison; `on wetland_flow$` guard | holds |
| :354 "at link's slope limit" | guarded | holds |
| :359-360 "beats link's `default`, not ... bcfishpass's" | tuning | holds |
| :369 Records "7,659 sites in 105 watershed groups where link expects chinook" | tuning funnel at the evidence build | **does not hold** (finding 2) |
| :370 Placement "...; otherwise to the nearest stream, kept when it lay within 200 m." | `knw_fdis_place()` | **does not hold** (finding 1) |
| :372 Slope "link can cut a stream at a site that caught a species it models" | true at 0.66.0 and, after link#396, still "can" | holds |
| :373 Candidates "link's among them" | tuning | holds |
| :375 "through all of link's steps for the map and the habitat totals" | comparison | holds |
| :376 Left out (bcfishobs; barrier) | tuning | holds |
| habitat_thresholds.Rmd :114-116 "which streams fish can reach past natural barriers" | bcfishpass background | **reads as the opposite of the source** (finding 3) |
| habitat_thresholds.Rmd :119 "one set for each group that runs it" | bcfishpass `parameters/` | **does not hold** (finding 4) |
| habitat_thresholds.Rmd :125-132 link builds on bcfishpass; fresh runs its rules; config rows | generic | holds |
| habitat_thresholds.Rmd :142, :206, :238, :273-276, :322, :334, :345, :371 (unchanged lines) | tuning or comparison build; :401 states "the segments of link's build of 2026-10-17" and what link has changed since | holds (the page names its build) |
| README "0.11" / "11 %" / "Access and link's other steps then apply as they do to `default`" / Learn-more line | data/thresholds.csv, run 20261017 | holds |
| CLAUDE.md grad_ext line | the Rmd no longer reads `x$grad_ext` | holds |

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:370 — the Placement cell reads: "to the nearest stream its 1:50k
  tributary code names, kept when it lay within 500 m of the point; otherwise to the nearest stream, kept when it lay
  within 200 m." With main's opening condition gone ("Where FDIS recorded the site's 1:50k tributary code and the
  Atlas's 1:20k-1:50k crosswalk knows it"), "otherwise" now reads as "when no code-named stream lies within 500 m".
  The code does not do that.
  - `knw_fdis_place()` flags such a visit `flag_ws50_mismatch`, and the funnel drops it ("its tributary code names no
    stream in reach", 377 visits).
  - Only a visit with no code the crosswalk knows goes to the nearest stream under the 200 m limit.
  - The methods article this cell links to ("More", `#snap`; pipeline step 2) says "a visit whose code names no
    stream within reach is dropped", so the two pages now disagree.
  - Restoring the condition keeps the register phrases intact. For example: "...within 500 m of the point; a site with
    no code the crosswalk knows, to the nearest stream, kept when it lay within 200 m." This keeps "kept when it lay
    within 500 m of the point" first and "nearest stream, kept when it lay within 200 m." whole, on the one line.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression runs both ways: a remedy
    promoted out of its evidence drops the condition that made it true)

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:369 — the Records cell reads: "7,659 sites in 105 watershed
  groups where link expects chinook". Main's sentence tied that count to its filters: "Sites were kept when they were
  on ordinary stream lines, of a usual fished area, with no barrier to chinook downstream, in a group where link
  expects chinook". In the rewrite the filters moved to the last row ("Left out"), so the count now reads as every
  site in link's chinook groups.
  - The 7,659 is the funnel's `no_barrier` step, after the stream-branch, fished-area, range and barrier cuts
    (17,414 in range, 17,296 not blocked).
  - Table 1's note, three sections up, says "Sites are the 11,532 electrofishing sites on reachable streams in those
    groups" (the 125 groups link classified for chinook). A reader then sees more sites on reachable streams in link's
    chinook groups than the page's whole population of sites in link's chinook groups. One label carries two
    populations: the comparison's check also counts river and wetland lines and does not use the barrier cut.
  - The cell is also the round-2 tense defect, unfixed here. "where link expects chinook" is present tense for a count
    taken from the evidence build's presence table (125 groups). link's `default` now marks 136 CH groups (origin/main;
    12 groups added, UDEN removed), so today's link would give another in-range population.
  - Fix: put the filters back in the cell, or say "after the cuts below", and use the past tense ("where link
    expected chinook in the run's build").
  - **Rule:** code-check.md "One fact derived twice" (one column name carrying different populations across files)

- **[severity: fragile]** vignettes/habitat_thresholds.Rmd:114-116 — the sentence reads: "bcfishpass models which
  streams fish can reach past natural barriers, the road and rail crossings and dams below them". Read as written, it
  says bcfishpass models the streams fish reach beyond natural barriers.
  - bcfishpass defines naturally accessible streams the other way: "identify all stream downstream of natural
    barriers" (`docs/01_background.md`, item 2 at 3bd2824c). Streams past a natural barrier are by definition not
    accessible.
  - The road and rail crossings and dams are the barriers fish may or may not pass. So the list joins two kinds of
    barrier that the model treats in opposite ways.
  - This is a new sentence on this branch, and the article's first statement of what the map is.
  - **Rule:** none

- **[severity: fragile]** vignettes/habitat_thresholds.Rmd:119 — the sentence reads: "The spawning and rearing
  thresholds sit in bcfishpass's repository, one set for each group that runs it". That does not hold at the linked
  commit.
  - `parameters/` holds six "example" folders, which the parameters README calls "sample parameters". example_ccira is
    "access model only ... empty thresholds table", so a group that runs bcfishpass has no spawning or rearing set.
    example_testing is a test subset, not a group.
  - "Each group that runs it" is also a population nothing on the page measures.
  - "Sample sets, among them New Graph's and other organizations'" would be supported as written.
  - **Rule:** none

Note on the first producer pair, not filed as a finding because it holds today. Table 1's and Table 2's "link now"
columns, and the opening's `words(dflt)` beside the comparison's km, rates and map, join two builds:

- the dials come from the tuning's `dflt` (a17e917);
- the outcomes come from the comparison's `default` (102762d).

They agree on the stream-line dials (`width>=1.5|g<=0.0549` at the head of `all_row$default_rule`), but no
`stopifnot` in the article checks that they do. `data-raw/vignette_chinook.R:157` checks the tuned rule's agreement
only. If a future comparison runs a link whose `default` moved a stream-line dial, these columns would pair one build's
thresholds with another build's habitat, and nothing would fire.
