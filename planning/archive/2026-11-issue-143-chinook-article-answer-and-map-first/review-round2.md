# Review round 2: branch 143-chinook-article-answer-and-map-first-the (HEAD fb78ff5)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check-r.md: headings read: "Moving prose into a code chunk hides it from tools that scan the document",
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "ggplot2 legends and
  labels: a key for an unused factor level, and ggrepel labels that must avoid each other", "`$` on a list
  partial-matches, so a longer sibling key answers for a missing one", "`ifelse()` with an all-NA test returns a
  logical vector, whatever `yes` and `no` are" (5 read, 111 not read).
- code-check-shell.md: no heading names a tool or shape the diff uses (0 read, 70 not read).
- code-check-spatial.md: the diff calls the unchanged `knw_compare_map()`/`knw_compare_mapgl()` and draws no sf
  layer of its own (0 read, 94 not read).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, plus "An assertion that matches an interpolated
  value cannot see the claim around it" (15 read, 22 not read).

## What I ran

- Rendered both articles from a `git archive HEAD` copy in the scratchpad with `pkgload::load_all()` +
  `rmarkdown::render()`: both render, no stopifnot fires, 0 footnote-refs, no `\@ref`, no doubled
  "Table N: Table" captions. Every cited key is in its article's `.bib` and every `.bib` entry is cited; no
  `file =` paths in either `.bib`.
- Chunk labels: no duplicates in either article.
- Re-derived from `inst/vignette-data/chinook_rearing.rds`: the Table 1 rates (950/6368, 116/5164; 980/5339,
  86/6193), 11,532 sites, 125 groups, wetland km (2,479 / 8,422, median 0.343), surface rates, honest 4 of 5,
  boot 99.5 % / 47 %, 164 / 2,456 close calls. All match the page.
- Register phrases (snap_limit 200, snap_limit_code 500, se_strict 1.96) each sit on one line and match.
- The comparison's `default_rule` is `width>=1.5|g<=0.0549|cw channel_width>=15@D1000; mad discharge>=3@D1000 on
  wetland_flow` (built by `.knw_default_rule_label()`, R/compare_rules.R:791). link at 102762d and at today's
  origin/main (e2a8593) carry for CH `rear_river_discharge_min = 3`, `rear_river_channel_width_min = 15`,
  `rear_river_distance_max = 1000`, `rear_near_river = wetland_flow`; at a17e917 (the opening's link) none of these
  columns exist, and lines through wetlands got the free pass. All 188 groups are `cw` at both SHAs, so "1.5 m
  channel width" is the only size test link applied. The round-1 wetland fix reads consistently with Table 1's
  "none on stream lines" and with the comparison.
- bcfishpass 3bd2824c: the New Graph CH row (0.0549, 1.5), the stream-order exception, and the
  "more than half a million mapped road-stream crossings and dams" sentence in docs/01_background.md all hold.
  All linked commits/paths resolve on GitHub; all `habitat_thresholds.html#...` anchors exist.

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:149-150 — "The rest of the change comes from link's step that
  keeps rearing only where it links to spawning". Measured on `bulk_segments.rds` (`pre_default`/`pre_tuned` against
  `flag_default`/`flag_tuned`): of BULK's 871.7 km lost, 868.0 km fail the rule's own test (flow < 0.75 m³/s and no
  river within 1 km) and 3.7 km go at connectivity/overlay; of 256.9 km gained, 222.1 km come in by the near-a-river
  allowance, 14.5 km at connectivity/overlay, and 20.3 km by the rule's own test without the allowance (flow
  ≥ 0.75 m³/s where width < 1.5 m, or slope between 5.49 and 11 %). So the remainder is about 38.5 km, of which
  connectivity is 18.2 km and the rule's slope/flow dials 20.3 km: the sentence attributes all of it to the
  connectivity step. Small in km, but it is a causal claim with no guard, and it is wrong for over half of what it
  covers. (Carried from main's lines 304-306, now on the rewritten page.) Either name both causes or compute the
  shares in the chunk and guard them.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:230-231 and :234 (Figure 3 caption) — "link's current"
  names two different rules on one page. Figure 3's orange ring marks "link's current value" at `none` on both
  near-a-river dials, and line 231 says every close call "differ[s] from link's in every dial". Those come from the
  tuning's `default` row (link a17e917, which had no near-river columns). But the page now also says (line 331,
  the round-1 fix) that in the comparison link's rule carries a near-a-river pair. And link's current config
  (102762d = today's main) holds `rear_river_discharge_min = 3`, `rear_river_distance_max = 1000` for CH, the same
  river size and distance as the recommended allowance, applied to lines through wetlands only. Both tables qualify
  the cell as "none on stream lines". Figure 3's caption and the "every dial" sentence do not, so a reader who opens
  link's current thresholds row sees a 3 m³/s / 1,000 m value where the figure rings "none". The mechanism is that
  `dflt` (the tuning's a17e917 row) feeds every "link's current" statement built from the tune table, while the
  comparison (102762d) feeds the totals, rates, map and wetland bullet. Every place `dflt`'s near-river fields
  reach: `cell_near(dflt)` in Tables 1 and 2 (qualified, fine), `dflt_vals` in Figure 3 (unqualified), the
  `departures == 3` sentence at :231 (unqualified). Qualifying the two unqualified places as stream lines would
  close it.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:177 — "Habitat is summed over the 125 watershed groups link
  classifies for chinook". This is present tense about link. The comparison ran link's presence table at 102762d
  (125 CH groups), but link's `default` presence table on origin/main (d14f9fa8, 2026-11-01, "Apply the #402 review's
  provisional decisions") now marks 136 CH groups: 12 added (CHIR, HOLB, KUMR, LRDO, MORI, MUSK, NASC, NECL, PORI,
  TAHR, TUYR, UNUR), UDEN removed. Measured with `git show <sha>:inst/extdata/configs/default/overrides/wsg_species_presence.csv`, column `ch == "t"`.
  The same tense runs through "link's current rule" for the 99,186 km total. Tie the count to the comparison's build
  ("the 125 groups link classified for chinook in the comparison") rather than to link now. (The phrase was on main
  at line 288, but the opening now points readers at link, and link moved two days ago.)
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:299-300 — the strict table's note says "link's thresholds
  table gives the choice at 1.96 for every species tuned (rule_196)". `rule_196` is a column of this repo's
  `data/thresholds.csv` (knowledge's published table, R/thresholds_table.R). No file in link carries it
  (`git grep rule_196 origin/main` in link: no hits), so a reader sent to link's thresholds table
  (`parameters_habitat_thresholds.csv`) will not find it. (Pre-existing wording, moved into the new footnote.)
  - **Rule:** none

- **[severity: fragile]** vignettes/chinook_rearing.Rmd:123 — `!grepl("|Q", all_row$default_rule, fixed = TRUE)` can
  never be FALSE. `.knw_default_rule_label()` (R/compare_rules.R:791-806) builds the label as `width>=…|g<=…|none` or
  `…|cw <measure>>=…@D…; mad <measure>>=…@D…[ on <scope>]`, and no branch emits `|Q` (that token belongs to tuned-rule
  strings). The first `grepl("@D[0-9]+ on wetland_flow$", …)` alone backs the sentence: it fails for no pair, for no
  scope, and for scope `both`. The second assertion is decoration that reads as a second check. Delete it, or say
  what it is meant to catch and make it able to fire.
  - **Rule:** code-check.md "Restore the bug and prove the guard fires"
