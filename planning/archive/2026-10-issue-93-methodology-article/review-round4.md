# Review round 4 — #93 methodology article (diff 3705426..8abf78f, planning/ and rds excluded)

## Checklist read

- `code-check-python.md` (7,237 bytes): in full.
- `code-check.md`: every index line; the prose of all 14 H3s under `## Mechanisms`, without their `|` table rows
  (from `mech.txt`); in full: "An assertion that matches an interpolated value cannot see the claim around it",
  "A link to a repo-hosted artifact must be *tracked*", "Documentation Staleness". 22 other standalone or Security
  or PDF headings read at index level only, because nothing in the diff touches their area.
- `code-check-r.md`: every index line; in full: "Moving prose into a code chunk hides it from tools that scan the
  document" and "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared".
  109 headings read at index level only.
- `code-check-shell.md`: every index line; no section read in full, because the diff has no shell. 67 headings.
- `code-check-spatial.md`: every index line; no section read in full, because the diff adds no spatial code. 93
  headings.
- soul `conventions/writing.md`: in full, "State each claim by the code's definition" and "When explaining a
  decision, list every check and the way it points" included.

## What I checked and found holding

- All 7 rows of the picks table: `rule_words()` against `knw_rule_in()` and `knw_tune_grid()`'s string format
  (`%s>=%g|g<=%g|Q%g@D%g`). Size, width and slope words match the code, apart from the exception wording in finding 4.
  The 1 SE picks equal each summary's `rule_recommended`, and the 1.96 SE picks equal `thresholds.csv`'s `rule_196`.
  `close_calls` equals `region_n` on every key.
- SE and close calls: `.tune_sel()` takes `se = sqrt(n_groups) * sd(per-group difference)` over the rows of `Sw`
  (one row per watershed group), so "how far that difference would move with a different set of watershed groups"
  is right. The pick is the region rule with the fewest departures, which is what "changes link's current rule
  least" says (it also moves off an exception distance under 200 m).
- Step 8 against 0320's summary columns. `seeds_same_rec` counts the exact rule (`seeds$recommended == pick$rule`),
  `seeds_rec_in_region` counts the main pick in each seed's region, and `boot_rec_share` is the recommended row's
  share of exact picks. `honest_dev_rec` and `honest_dev_default` are the fold sums of the choice made on the other
  folds and of `default`. The sentence describes each count as what it counts, and its guards match its words.
- The funnel: 7,893 dropped at placement, of which 5,242 were too far from their stream (more than half); 7,893 of
  the 11,035 lost is 72 %. Step 10's 999 of 7,699. 67 settings, 7 tested, 10 inherited and untested. 86 % of sites
  on routed flow. Between 6,149 and 8,385 rules, so "between 6,100 and 8,400" holds.
- "Flows are 30-year averages": PCIC routed is PNWNAmet 1981-2010, and wet's balance normals are 1981-2010.
- `vignette_bib.R`: I ran a copy that writes to a temp dir. It reproduces both committed `.bib` files byte for byte
  (`diff` empty). The chinook bib's change is the intended one: the organisations are braced, and the VIC-GL, Raven
  and fork entries are added. Every cited key resolves (12 in the methodology article; `setequal` passes for both
  articles). The fork commit 7c30f58 is on the fork's `newgraph` branch, and wet's check file at 94deeb5 names it.
- Step anchors: `id="step-1"` to `id="step-11"` each appear once in the render, and each has a matching
  `xlink:href`. `#se` resolves. The other anchors exist.
- Links that answer 200 and show the right page: the pkgdown sites of `knowledge`, `link`, `wet` and `fresh` (each
  redirects to newgraphenvironment.com); smnorris.github.io/fwapg; `03_functions.html#fwa-indexpoint` (the id
  exists); the fork and its `tree/newgraph`; bcfishobs; the FWA gov page; the FWA catalogue record; PCIC (redirects
  to uvic.ca/pcic); the hdl and DOI. The knowledge issue links answer 404 because the repo is private (an accepted
  tradeoff).

## Findings

- **[bug]** vignettes/habitat_thresholds.Rmd:163. `detail()` writes the step's "Open work" item as raw HTML but
  takes its link from `issue()`, which returns Markdown. Pandoc does not convert Markdown inside a one-line raw HTML
  block, so the published page prints the literal text `Open work: [#91](https://github.com/NewGraphEnvironment/knowledge/issues/91)`
  under step 2 and `[#92](...)` under step 7 (confirmed in the render). Build the link as
  `<a href="...">#91</a>` inside `detail()`.

- **[bug]** data-raw/vignette_method.R:330 with :370. `legend()` gives every legend box `URL=url_pkg[pkgs]`, and
  the lineage chart calls `legend(c("source", pkgs_flow))`. `url_pkg` has no `source` entry, so that box carries
  `URL="NA"`; the render holds `<a xlink:href="NA" ... target="_top">` around the legend's "source" box. Clicking
  it opens `articles/NA`, a 404. Give `source` no URL (drop the attribute when the value is NA) or a real one, then
  rebuild `method.rds`.

- **[bug]** data-raw/vignette_method.R:320. The flow chart's "FDIS electrofishing" box links to
  `https://catalogue.data.gov.bc.ca/dataset/fisheries-data-information-system-fdis`, which is not a catalogue
  record. The catalogue's own API answers `package_show?id=fisheries-data-information-system-fdis` with "Not Found",
  and a catalogue search for FDIS returns only "Provincial Obstacles to Fish Passage" and "Lake Inventory Surveys".
  The URL answers HTTP 200 only because the catalogue is a single-page app that serves its shell for any path, and a
  reader sees its not-found view. So the box does not go where the article says it does ("each box links to its
  package or source").

- **[bug: a sentence the code does not support]** vignettes/habitat_thresholds.Rmd:197-199 (step 4). "Where it
  reaches, that is PCIC's modelled streamflow ... Elsewhere it is wet's own water balance." wet's pick also takes the
  balance where routed flow reaches but, on a stream's own line, carries under a fifth of the balance's. That is the
  0.2 setting printed in the step's own details, and the chinook article states it. In the run's
  `visits_link.csv`, 1,905 of the 5,561 kept sites on the balance (34 %) have a routed value. So the sentence
  misdescribes a third of the balance sites. pipeline.csv's `does` text, which stated the rule, is no longer
  printed anywhere in the article.

- **[bug: a sentence the code does not support]** vignettes/habitat_thresholds.Rmd:207 (step 5). "Each kept site
  takes its segment's flow, width, slope and access". The slope the rules are scored on is `fwa_gradient`, the
  Freshwater Atlas line's own `gradient` (`R/link_flow.R:36`, `s.gradient AS fwa_gradient` from
  `fwa_stream_networks_sp`), not link's segment's. The article's own Limits bullet says so ("Rules are scored on the
  Atlas line's slope, while link applies a rule on its own segments"), as does settings row `gradient_col`. The two
  passages contradict each other.

- **[bug: a sentence the code does not support]** vignettes/habitat_thresholds.Rmd:222-223 (step 7). "which data
  set and decade the record comes from". The nuisance term is three eras, cut at 1994 and 2004
  (`R/tune_run.R:124-125`: `to1994`, `1995-2004`, `2005on`). The first spans 1950 to 1994 and the last 2005 to 2022.
  "Era", or the three spans, says what the model does.

- **[bug: a sentence the code does not support]** vignettes/habitat_thresholds.Rmd:64 (`rule_words()`, printed in
  the opening paragraph and the picks table). The exception reads "a smaller stream also counts within 1 km of a
  river carrying 3 m³/s". `knw_rule_in()` passes a visit whose walk downstream reaches a river of at least `exc_q`
  within `exc_d`, along the network. "Carrying 3" omits "at least". "Within 1 km of a river" with no "downstream"
  reads as a straight-line distance, which is a different set: a small stream beside a river that joins it far
  downstream passes the straight-line reading but not the rule. The chinook article says it as the code does: "a
  river of at least 3 m³/s within 1 km downstream". (The exception also still needs the slope test, since
  `grad_ok & (size_ok | ex)`, and the semicolon leaves that open.)

- **[fragile: a sentence narrower in the code]** vignettes/habitat_thresholds.Rmd:179-180 (step 2). "A site is kept
  only if ... where the record names the site's tributary, is that tributary." 0230 drops a mismatch only where the
  code is a full 45-character 1:50k code and the Atlas's 1:20k-1:50k crosswalk knows it
  (`scripts/0230-fdis-load.R:448-472`: `flag_ws50_mismatch = ws50_checked & ws50_known & !ws50_match`). A site
  whose recorded tributary code the crosswalk does not know is kept wherever it snapped. The chinook article and the
  article this replaces both state the crosswalk condition. (I did not count those sites; the flag table does not
  keep `ws50_known`.)

- **[fragile]** data-raw/vignette_bib.R:64 and :92. The fork's cited version, `"7c30f58"`, is a literal fact about
  another artifact. Its comment says wet's check file at the loaded build names it, but the script never reads that
  file, so a wet reload built from another fork commit leaves the citation on 7c30f58 with no error. Likewise, the
  methodology article's tool versions come from `chinook_rearing.rds` on the comment's word that "both articles
  describe this run", and nothing compares that bundle with `method.rds`'s `meta`. The two already disagree on one
  field: chinook's `versions$wet` reads "built 2026-10-20T18:40:10Z", while `method.rds`'s `flow_load` (the grade
  tables' `discharge_load`) reads "built 2026-10-19T06:08:31Z, wet 94deeb5". Only "discharge/fwa/v1" reaches the
  .bib, so nothing printed is wrong today.

- **[fragile]** vignettes/habitat_thresholds.Rmd:73, :159 and :162 call `htmltools::` in a vignette that now ships
  (it lost its `_` prefix, so `.Rbuildignore` no longer drops it), and DESCRIPTION declares `htmltools` in neither
  Imports nor Suggests. It builds today only because rmarkdown pulls htmltools in. `R CMD check`'s unstated-
  dependencies check on vignettes reports the `::` use. No workflow runs `R CMD check` here, so nothing goes red
  yet.

## Guards (stopifnot)

None of them can pass while the sentence it guards is false.
- Step 8's guards match its claims: an exact-rule count under half, in the region on every seed, honest below
  default.
- Step 2's "most because the nearest stream is too far away" guard counts the far-snap drops only, which is the
  stricter of the two readings.
- The "Where are records lost?" share guard uses the same two quantities the sentence prints.

No sentence quoted in a finding above has a guard: those findings are about wording, not numbers.
