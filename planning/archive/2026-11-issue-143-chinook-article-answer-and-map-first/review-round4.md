# Review round 4: branch 143-chinook-article-answer-and-map-first-the (HEAD d6ff482)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check-r.md, by heading: none beyond the index lines. The round-3 fix changes only prose and inline values inside
  existing table cells; it adds no code.
- code-check-shell.md and code-check-spatial.md: 0 headings. The diff adds no shell and no spatial code.
- code-check.md: the prose of the H3s under `## Mechanisms` ("A guard that fails toward pass" and "A fixture that cannot
  reach the failure mode" read in full; the rest by their opening prose), with "One fact derived twice" and "A guard's
  scope, escape hatches, and remedies" read for this loop's mechanism.

## What I ran

All runs used a `git archive HEAD` copy in the scratchpad (`rv4`).

- `test-settings-register.R` passes (10 expectations). To check that its guard fires, I changed "within 200 m." to
  "within 300 m." in the copy's Placement cell, and the test failed (1 failure). `test-vignette-data.R` passes, with 2
  skips because the copy has no `data/`.
- Both articles render with `pkgload::load_all()` and `rmarkdown::render()`, and no `stopifnot` fires. I read the
  rendered text of both pages.
- Placement: I read `R/fdis_place.R`, `R/fdis_quality.R:45-49` and the methods article's step 2 and `#snap`.
- Records: I read `R/tune_run.R:128-182`, `scripts/0310-evidence-build.R:195-217` and `method.rds$funnel_species`.
  - At the evidence build, which matches the summary's `evidence_md5`, CH sites in link's range sit in 117 groups.
  - link's `default` presence marks 125 CH groups at a17e917 and at 102762d. The presence file has not changed between
    2026-08-27 and 2026-11-01.
- Table 1 note: I read `R/compare_rules.R:297,427-445`.
- bcfishpass 3bd2824c: I read `docs/01_background.md`, `parameters/README.md` and the folder list, and the
  `load_habitat_linear_ch.sql` cw branch.

## Round 3's four fixes

1. **Placement cell: holds.** "A site whose 1:50k tributary code the Atlas's crosswalk knows went to the nearest
   stream that code names, kept when it lay within 500 m of the point, and was dropped otherwise; a site with no such
   code went to the nearest stream, kept when it lay within 200 m."
   - This matches `knw_fdis_place()`. A visit with hinted rows (`ws50_checked`) takes the nearest hinted hit
     (`code`). A hinted visit with no hit is flagged `flag_ws50_mismatch` and dropped by `knw_fdis_quality()`, or
     `flag_not_placed` and dropped.
   - A visit with no hinted row takes the nearest stream, and `flag_far_snap` drops it beyond 200 m.
   - "kept when it lay within 500 m of the point" and "nearest stream, kept when it lay within 200 m." are each whole
     on the one line, and the register test sees both (mutation above).
   - The cell no longer agrees with the page its "More" link opens (finding 2).
2. **Records cell: does not hold** (finding 1). The filters are now in the cell, but "the 105 watershed groups where
   link expected chinook" counts the wrong groups.
3. **Table 1 note: holds.** "electrofishing sites of a usual fished area on reachable stream, river and wetland lines
   in those groups, a wider set than the one the rule was chosen on" matches `compare_rules.R:427-445`:
   - `vv` is cut to area 10-10,000 m² and to edges 1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250 and 1350 (stream,
     wetland and river lines, no lake connectors);
   - it is matched to the 125-group segments;
   - it counts rearing plus accessible-not-rearing, and rearing is gated by `accessible` (`:642`).

   "Wider" combined with "They overlap" does not claim a superset. The note no longer reads as the same population as
   the Records cell.
4. **habitat_thresholds.Rmd opening: holds.**
   - "which streams fish can reach below natural barriers such as falls and steep slopes" matches background items 1-2
     ("waterfalls, subsurface flow, steep gradients"; "all stream downstream of natural barriers").
   - "more than half a million mapped crossings and dams" is the background's own figure.
   - "as parameter sets: New Graph's and other organizations'" is supported. The README calls the folders "sample
     parameters", and the sentence no longer claims a set per group that runs bcfishpass.

## Enumeration (round 3's table re-walked against the current text, plus rows it lacked)

Round 3's 37 rows, re-walked:

| Row (round 3) | Verdict now |
|---|---|
| Title; :145 "than link's current rule allows"; opening `default` = 5.49 %, 1.5 m | hold (3) |
| Fig 1 caption; BULK 1,482 / 2,096 km; drops / gains / "the rest"; :170 | hold (4) |
| Table 1 rows 1-3, rows 4-6, caption, note "125 groups ... when the comparison ran", note "lines through wetlands" | hold (5) |
| Table 1 note "Sites are the 11,532 ..." (rewritten) | holds (fix 3) |
| bcfishpass order-5 exception ("if its width is mapped": `cw.channel_width <= max` is false on NULL); "`default` leaves that exception off" | hold (2) |
| Fig 2 caption and :235-238; :246-248 close calls; Fig 3 caption; :299 "back to link's" | hold (4) |
| Table 2 "link now" etc.; Table 2 note on `data/thresholds.csv` `rule_196` | hold (2) |
| Other-checks table; wetland bullet; "at link's slope limit"; "beats link's `default`, not bcfishpass's" | hold (4) |
| Records "7,659 sites ... in the 105 watershed groups where link expected chinook" | **does not hold** (finding 1) |
| Placement | holds (fix 1) |
| Slope; Candidates; "Rules run by"; "Left out" | hold (4) |
| habitat_thresholds opening :114-116 and :119 | hold (2, fix 4) |
| habitat_thresholds :125-132 (link / fresh / config rows) | holds |
| habitat_thresholds unchanged lines (:142-143 example rule, :206, :238, :273-276, :322, :334, :345, :371, :401) | hold (1 row) |
| README "0.11" / "11 %" / "Access and link's other steps ..." / Learn-more line (`data/thresholds.csv` CH_rear_v1 `rear_gradient_max` = 0.11) | holds |
| CLAUDE.md grad_ext line | holds |

Rows round 3 lacked:

| Where | Source | Verdict |
|---|---|---|
| habitat_thresholds step 2 (Rmd :193-200) and `#snap` (:293-298): "... within 500 m. Otherwise it goes to the nearest stream, if that lies within 200 m"; `#snap` "Where the site's record names its tributary ..." | `knw_fdis_place()`, `knw_fdis_quality()` | **does not hold against the chinook cell it backs** (finding 2; pre-existing lines) |
| habitat_thresholds one-SE paragraph, re-wrapped on the branch: "the one that changes link's current rule least"; "the choice can stay nearer link's rule" | tuning picks | holds |
| habitat_thresholds funnel sentence "where link expects the species, with no code that could hide it and no natural barrier to it downstream" | `tune_run.R` filters | holds (describes the method) |
| chinook References: link "Version 0.66.0" | the tuning's build; the comparison's config is 102762d | holds (accepted tradeoff: the article names the tuning's link) |
| chinook "Before you use it": "River polygons ... though no site in one was scored" | `tune_run.R:129` excludes `wb_river` | holds |

**Count: 42 items checked. 40 hold, 2 do not:** round 3's 37 re-walked, of which 36 hold, plus 5 added, of which 4
hold.

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:369 (Records cell). It now reads "7,659 sites on ordinary stream
  lines, of a usual fished area, with no barrier to chinook downstream, in the 105 watershed groups where link
  expected chinook when the tuning ran".
  - "the 105 watershed groups where link expected chinook" says link expected chinook in 105 groups. It did not.
    - `summ$groups` is `nlevels(droplevels(d$wsg))` after every filter (`R/tune_run.R:179-181`). That is the groups
      holding at least one of the 7,659 sites.
    - link's `default` presence marks CH in 125 groups at a17e917 and at 102762d. The presence file has been unchanged
      from 2026-08-27 to 2026-11-01.
    - At the evidence build (md5 `1bd35829…` and `009698d7…`, the summary's), CH sites in link's range fall in 117
      groups.
  - The round-3 fix introduced this. Before it, "7,659 sites in 105 watershed groups where link expects chinook" put
    the 105 on the sites. The new definite article and relative clause put it on link's expectation.
  - The page now contradicts itself. Table 1's note says "the 125 watershed groups link classified for chinook when the
    comparison ran", and the two time clauses invite the reader to read 105 against 125 as a change in link between
    the runs. Presence did not change.
  - Fix, for example: "7,659 sites in 105 watershed groups: those on ordinary stream lines, of a usual fished area,
    with no barrier to chinook downstream, in groups where link expected chinook when the tuning ran".
  - **Rule:** writing.md "State each claim by the code's definition"

- **[severity: fragile]** vignettes/habitat_thresholds.Rmd:195-198 (step 2) and :296-298 (`#snap`). The chinook
  Placement cell links here ("More" goes to `#snap`), and it now says a code-known site with no code-named stream
  within 500 m "was dropped". The methods page says neither that nor anything else about such a site.
  - Step 2: "Where the record names the site's tributary in a form the Atlas can check, the site goes to the nearest
    stream of that tributary ... if it lies within 500 m. Otherwise it goes to the nearest stream, if that lies within
    200 m."
  - `#snap`: "... kept if it lies within 500 m ... Otherwise the nearest stream is taken, kept if it lies within
    200 m."
  - Round 3 read exactly this construction as a bug in the chinook cell: after a "kept if within 500 m" clause,
    "Otherwise" reads as "when no stream of that tributary lies within 500 m". The code drops such visits
    (`flag_ws50_mismatch`, 377 visits).
  - Round 3's finding 1 said "the methods article ... says 'a visit whose code names no stream within reach is
    dropped'". That sentence is in `inst/method/pipeline.csv` and is not rendered: the rendered HTML has 0 matches for
    "names no stream" or "within reach". So the corrected cell has no counterpart on the page it links to, and the
    page reads the other way.
  - `#snap`'s condition, "Where the site's record names its tributary", is also wider than the code. A code the 20k-50k
    crosswalk does not know goes the nearest-stream path (`ws50_checked` FALSE). Step 2's "in a form the Atlas can
    check" is right.
  - The lines are unchanged since #92 (c2cc0ec), so this predates the branch. The branch made it visible by making the
    chinook cell explicit.
  - Fix, for example: in both places, "...within 500 m, and is dropped if no stream of that tributary lies within
    500 m. A site whose record names no tributary the Atlas can check goes to the nearest stream...". The register
    rows for `snap_limit` and `snap_limit_code` point at the chinook Rmd only, so this edit touches no register
    phrase.
  - **Rule:** writing.md "State each claim by the code's definition"

Not filed: chinook "Software and citation" renders "(2026). :. New Graph Environment Ltd. Version." from a
`load_all()` render of an archive copy. The line is unchanged from main and reads the installed package's citation
under pkgdown.
