# Findings — Chinook article: answer and map first, the river effect as a figure, detail in tables; methods article opens with what the map was for (#143)

## Issue context

**If we do it:** a reader opening the chinook article gets the answer, the map and the reason for the rule in the first screen, and the detail sits in figures and tables they can take in at a glance. A reader new to the work starts at the methods article, which opens by saying what the existing habitat map was for and what tuning adds. **If we never do:** the chinook article keeps opening on who made the tool and walks through the method before the result. Its two key ideas sit in a 4 × 6 table of percentages and a wide table of sentence-length cells.

## Problem

`vignettes/chinook_rearing.Rmd` runs to about 1,680 words of prose. It opens with the company name, puts the map near the end, and repeats the method that `vignettes/habitat_thresholds.Rmd` is the home for. "Why does a nearby river matter?" carries its point in a table of fitted rates, and the stricter-bar table is hard to read. The methods article starts straight into the steps, with no plain account of what the existing map was for.

The change is to prose only. Every figure and table below reads elements already in `inst/vignette-data/chinook_rearing.rds` (`surface`, `tune`, `checks`, `compare`, the Bulkley segments), so neither bundle is rebuilt and no promotion is needed. Neither bundle pins its own Rmd.

## Methods article: open simply (`vignettes/habitat_thresholds.Rmd`)

- [ ] Three short paragraphs before the steps:
  1. **What the map was for.** bcfishpass [@norris2024smnorrisbcfishpass] models which streams fish can reach and where they could spawn and rear, to rank where fieldwork should go among more than half a million road and rail crossings and dams (its `docs/01_background.md`). The Province publishes its access model as [Freshwater Fish Habitat Accessibility Model – Pacific Salmon and Steelhead](https://catalogue.data.gov.bc.ca/dataset/freshwater-fish-habitat-accessibility-model-pacific-salmon-and-steelhead). The habitat thresholds are in bcfishpass's repository, New Graph's [parameters](https://github.com/smnorris/bcfishpass/blob/3bd2824c300c5f9c0c041380d412a52987df1ebb/parameters/example_newgraph/parameters_habitat_thresholds.csv) and the Canadian Wildlife Federation's [parameters](https://github.com/smnorris/bcfishpass/blob/3bd2824c300c5f9c0c041380d412a52987df1ebb/parameters/example_cwf/parameters_habitat_thresholds.csv). They were set to screen sites, and a fair guess is enough for that.
  2. **What tuning adds.** `link` [@irvine2026linkDevelop] and `fresh` [@irvine2026freshFreshwater] hold every rule as a row in a config, so a rule can be changed and run beside another. Tuning scores those rules against where crews caught fish and keeps the one the records support, with room for the biology (a young chinook's use of small streams near big rivers), so the map points to where fish are most likely to rear and spawn.
  3. **What the article covers:** the steps, in order.
- [ ] The Data Catalogue record goes into the Zotero group library, and `data-raw/vignette_bib.R` writes both `.bib` files again (Zotero running).
- [ ] The statistics citations for the scoring move here from the chinook article, into "How are two rules told apart?" (the one-SE rule: Breiman et al. 1984, Hastie et al. 2009, Chen & Yang 2021; cross-validation error: Bengio & Grandvalet 2004, Bates et al. 2024), as #64 planned.

## Chinook article, in this order (`vignettes/chinook_rearing.Rmd`)

- [ ] **1. Opening: the answer, no company name.** Draft, numbers inline from the bundle as now:

  > Young chinook salmon rear in more of BC's small streams near rivers, and in fewer far from one, than the usual rule draws. [`link`](…) [@irvine2026linkDevelop] starts from bcfishpass's chinook thresholds [@norris2024smnorrisbcfishpass]: a channel at least 1.5 m wide and a slope of at most 5.5 %. Electrofishing records support a different rule: a slope of up to 11 %, and either an average flow of 0.75 m³/s or a river of 3 m³/s within 1 km downstream. It draws 16 % less habitat across the province, and chinook are caught far more often inside it. [How the tuning works](habitat_thresholds.html) explains where these rules come from and how they are tested.

- [ ] **2. The map, straight after.** The Bulkley (around Smithers) under each rule, kept, lost and gained. Its caption tells the reader how to read it: orange is the upper reaches of tributaries far from a river, green is small streams beside one. The map paragraph in "What changes on the ground?" folds into the caption.
- [ ] **3. "What changes?": one before/after table.** Rows: smallest stream, steepest slope, near-a-river allowance, km of rearing habitat across the province, and how often chinook were caught on and off the habitat (the `checks` rates). Columns: link now, recommended. A table note keeps the caveat that these sites overlap the ones scored. This replaces "What does link do now?" and the "A check" paragraph.
- [ ] **4. "Why does a nearby river matter?": a figure in place of the 4 × 6 table.** x: distance downstream to a river of at least 3 m³/s, on a log scale from 100 m to 50 km; y: the fitted chance of catching chinook on one visit; one line per stream flow (0.1, 0.3, 0.75, 2 m³/s). The lines sit together at 10 to 11 % within 100 m and fan apart past 1 km (0.3 % to 2.9 % at 10 km). A dashed vertical line at 1 km marks the allowance, and the 0.1 and 0.3 m³/s lines go grey beyond it, where the rule stops counting them. One sentence beside it says the pattern. Open the section with one sentence on bcfishpass's own form of the idea: in groups sized by width, a first-order stream whose parent is order 5 or more counts as rearing at any width, along its whole length (`model/02_habitat_linear/sql/load_habitat_linear_ch.sql`, pinned). link's `default` has that exception off for chinook (`rear_stream_order_bypass = no`); its `bcfishpass` config has it on. The section moves ahead of the uncertainty section, because it is the reason for the rule.
- [ ] **5. "How sure are we?"** One or two plain sentences on the principle (scores carry error; rules within one standard error of the best are close calls, a convention fixed before the run), linking the methods article for the rest. Then:
  - the dial profile figure, as now;
  - the stricter-bar table rebuilt: rows are the three dials, columns are link now, chosen at 1 SE and chosen at 1.96 SE; short cells ("0.75 m³/s flow", "11 %", "3 m³/s river within 1 km"); cells that differ from link's in bold; a smaller font (`kableExtra::font_size`); the close-call counts (164, 2,456) in a table note;
  - "Two other checks" as a three-row table: the check, its result, and which way it points (other random splits; chosen on four sets and scored on the fifth; redrawn groups).
- [ ] **6. "Before you use it": the same bullets, shorter.** Cut the history of the earlier run on the longer slope ladder (it serves the authors). The `grad_ext` read can stay in the bundle unused; if it comes out, the CLAUDE.md sentence naming it changes too. Add the gap below.
- [ ] **7. "How was this done?": a table at the end.** One row each for the records (sites, sites with chinook, groups), placement (500 m by tributary code, 200 m to the nearest stream), flow (wet), slope (the link segment's), the candidate dials (6,149 rules), scoring (five sets of watershed groups, held out; lower is better), the tie-break (the close call nearest link's), and what was left out (bcfishobs, because it records where fish were found, not where they were sought and missed). Each row is a short cell and a link into the methods article. It is a pipe-format kable: pandoc citations do not resolve inside a `format = "html"` one. This replaces "What records were used?" and "How were rules compared?".
- [ ] **8. References,** plus the "Software and citation" section #118 asks for.
- [ ] Keep every inline number guarded by a `stopifnot()` as now, and add guards for the new figure's sentence (lines together near the river, apart at 10 km).
- [ ] Measure: prose word count before and after (now ~1,680), aiming for about half.

## The gap this leaves

The tuning never scored bcfishpass's order-5 exception as a candidate. So the records show that a flow-and-distance allowance beats link's `default`, not that it beats bcfishpass's own rule. "Before you use it" says so in one sentence. Adding the exception to the candidate set is a retune and is decided separately.

## Relation to #118 and #64

This takes the chinook article's structure and tone from #118 (renaming the articles as a tuning series) and the chinook part #118 folded in from #64. #118 keeps the file renames, the `_pkgdown.yml` menu and the bundle rebuild its rename forces, and can follow this.


## Constraints found at the plan gate


- **Register phrases stay verbatim.** `inst/method/settings.csv` rows `snap_limit`, `snap_limit_code` and `se_strict`
  name text in `vignettes/chinook_rearing.Rmd` ("nearest stream, kept when it lay within {value} m.", "kept when it lay
  within {value} m of the point", `se_strict <- {value}  #`), which `tests/testthat/test-settings-register.R` resolves.
  Editing the register would move `method.rds`'s pinned md5 and force a bundle rebuild (#118's problem), so the rewrite
  keeps those three strings exactly.
- **Citations must stay in prose.** `data-raw/vignette_bib.R` reads keys with `rbbt::bbt_detect_citations()`, which skips
  code chunks, and requires the chinook article to cite fwapg, bcfishpass, bcfishobs, link, fresh and wet
  (`all_tools = TRUE`). So the end methods table is a literal markdown pipe table with inline `r` numbers, not a kable.
- **kableExtra** is not in `Suggests`; the stricter-bar table's note and font need it (`pkgdown-publishing.md`: HTML kable +
  `kable_styling()` + `footnote()`).
- **Zotero** did not answer Better BibTeX's probe at planning time; the bib phase needs it running, and the Data Catalogue
  record needs an item in the group library (Web API, `ZOTERO_API_KEY`).


## Errors Encountered

| Error | Resolution |
|-------|------------|
| Better BibTeX gave no reply on localhost:23119 (curl exit 52, connector ping too) though the Zotero process had run 4 days; `ZOTERO_API_KEY` unset in the shell and R | Bib regeneration waits on a Zotero restart. Recommend citing the Data Catalogue record by link only (background, not data the article uses), so no Web API item is needed |

## Measurements

- Chinook prose (outside chunks, after the setup): 1,683 -> 1,236 words. The methods table at the end (moved, not cut) sets the floor.
- Rendered text minus the reference list (review 11's count; `scratchpad/count.R` over renders of 3140693 and the branch, 2026-11-04): chinook 2,053 -> 1,800 words (-12 %); methods 4,452 -> 4,746 (+294: the new opening and the moved citations). The forecast was about half: most of the detail moved into tables and a figure rather than out of the page, as Al asked ("in a table at the end", "easier to digest"), and the source count fell further because table cells and notes are written in R strings.
- Pinned links (bcfishpass x3 at 3bd2824, Data Catalogue record): all HTTP 200, 2026-11-04.
- Methods article render: only the five moved statistics keys unresolved until `vignette_bib.R` runs.

## Standing constraint: the register's phrases in the chinook article

`R/settings_register.R` matches each `code:` entry per line with a lazy `(.+?)`, skips lines starting with `#`, and needs every match to equal the value. In the methods table's placement row the 500 m phrase must come first and the 200 m phrase must end "200 m." with its full stop; a second use of either phrase anywhere, even with an inline value, fails `test-settings-register.R` (plan review 7).

## Unrelated test error

`test-link_place.R:39` errors (data.frame of 1 and 0 rows): its query found no BULK bull trout rearing segment in the live `fresh_default` during the provincial run on 2026-11-04. This branch touches nothing under `R/` or `tests/`; the other 1,901 expectations pass.
| After the restart, Zotero 10.0.7 listened on 127.0.0.1:23119 and answered a raw `nc` request 200, yet `curl` probes got an empty reply (exit 52) on most attempts, whatever the user agent or `Connection` header | Not chased: `rbbt` from R reached Better BibTeX on the first try and `vignette_bib.R` ran clean. The probe, not Zotero, was the unreliable part after the restart |

## Review mechanism: "link's rule" names two builds (rounds 1-2)

The page draws link's rule from two places: the tuning's scored rule (`dflt`, link a17e917; stream lines; no near-river pair on any line) and the comparison's regenerated rule (config 102762d; a near-river pair on wetland-flow lines only, `... on wetland_flow`). Round 1 found the wetland bullet and the table note disagreeing; round 2 found two unqualified near-river statements for link (Figure 3's ring, "differ in every dial") and a group count in the present tense. Enumeration of every mention in chinook_rearing.Rmd (40 lines matching link's / link now / `default` / dflt, 2026-11-04): the near-river dial for link appears in `cell_near(dflt)` (both tables; "none on stream lines"), Figure 3's ring and the "every dial" sentence (now "on stream lines"), and the order-5 sentence (off at both builds, verified). The rest name a size, a slope, a score or a total, which do not depend on which build is meant.

Bulkley map sentence (round 2): of 1,128.6 km changed, 868.0 km are drops below the floor more than 1 km from a river, 222.1 km gains beside one, 20.3 km other dial changes and 18.2 km the spawning-connection step alone. Main's sentence credited all the rest to that step; the new one names both, guarded.

## Review mechanism, revised (round 3)

Round 3 widened it: the rewrite compressed qualified prose into short sentences and cells and dropped the clause saying which build, population or condition a statement holds for, and each survived because its two possible sources agree on most members (two link builds; two placement paths; the tuning's 7,659-site population against the comparison's 11,532 sites). My enumeration covered only the near-river dial and wrongly called totals and counts build-independent. Round 3's own table (`review-round3.md`, 39 rows: every sentence, caption, cell and footnote naming link, `default`, bcfishpass or the comparison on both pages, plus the README lines changed) holds except four, all fixed: the placement cell restores main's condition (a code-named stream beyond 500 m drops the site); the records cell restores its filters and puts link's chinook groups at the tuning's build; the table note says what its 11,532 sites are; the methods opening says fish reach streams below natural barriers and that bcfishpass's parameter folders are sets, not one per group.

## Code-check close (branch mode, 2026-11-04)

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|-------|----------|-------|----------|----------------------|
| 1 | 1 | 1 | 0 | — |
| 2 | 5 | 5 | 0 | y (round 1's guard had a half that could not fire) |
| 3 | 4 | 4 | 0 | n (named the mechanism; 39-item enumeration) |
| 4 | 2 | 2 | 0 | y (the records cell put 105 on link's range) |
| 5 | 1 | 1 | 0 | n (47-item enumeration: 45 held, 2 cells from one finding) |

Ended by enumeration: round 5's 47 items (every statement on both pages naming link, `default`, bcfishpass, the comparison, a site or group count, a habitat total or a placement rule, plus the README lines changed) all hold after its one fix, the hidden-catch condition in the Records and Left out cells (`R/tune_run.R:161`, worded as the methods article words it). Five reviewer rounds, the per-task bound; three of the thirteen findings (the Bulkley sentence, the methods article's placement fallback, the hidden-catch condition) were on main before this branch.
