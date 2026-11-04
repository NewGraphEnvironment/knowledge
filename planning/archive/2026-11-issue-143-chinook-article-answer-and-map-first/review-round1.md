# Code-check review, round 1: branch `143-chinook-article-answer-and-map-first-the` (merge-base 3140693)

## Checklist read

- code-check-python.md: in full.
- code-check-r.md, by heading (6 read): "Moving prose into a code chunk hides it from tools that scan the document";
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it"; "ggplot2 legends and labels:
  a key for an unused factor level, and ggrepel labels that must avoid each other"; "`tolerance` in testthat is
  RELATIVE, so it pins a published figure far more loosely than it looks"; "A `pkg::` call in a test passes
  `devtools::test()` and fails `R CMD check` if `pkg` is undeclared"; "`\<` and `\>` are word boundaries in R's default
  regex, not escaped `<` and `>`". The rest (about 110 headings) not read in full: none names a tool this diff uses.
- code-check-shell.md: no heading read in full (the diff adds no shell); index lines only.
- code-check-spatial.md: no heading read in full (the diff changes no spatial code; the map chunks are unchanged
  calls to `knw_compare_map()` / `knw_compare_mapgl()`); index lines only.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus "A link to a repo-hosted
  artifact must be *tracked*, not merely present" and "An assertion that matches an interpolated value cannot see the
  claim around it". Other stand-alone rules not read in full.

## What was run (in a copy, `$TMPDIR/.../scratchpad/rv1`, tracked files only)

- Both articles render with `pkgload::load_all()` + `rmarkdown::render()` (static-map path). No unresolved citation,
  no `NA` style or doubled "Table n:" from kableExtra; Table 1 and Table 2 numbered once each.
- `test-settings-register.R`: 272 pass, 0 fail. `test-vignette-data.R`: 42 pass, 7 skip, 0 fail. The three register
  phrases (`snap_limit`, `snap_limit_code`, `se_strict`) each match once in chinook_rearing.Rmd.
- Every `[@key]` in both Rmds is in its .bib and every .bib entry is cited; the five moved entries are byte-identical
  between the old chinook .bib and the new methods .bib.
- Duplicate chunk labels: none. Anchors `#se`, `#steps`, `#snap`, `#lost` exist in habitat_thresholds.Rmd.
- External links (catalogue record, bcfishpass blob/tree at 3bd2824c, link config tree at the run sha, link and fresh
  sites): all HTTP 200.
- Numbers checked against `inst/vignette-data/chinook_rearing.rds`: rates 950/6368, 116/5164 (default) and 980/5339,
  86/6193 (door); 11,532 sites; 125 groups + ALL in `compare`; 164 of 6,149 close calls, all `departures == 3`;
  link 2.45 SE behind; 2,456 at 1.96; seeds 4 of 4 / 0; honest 4 of 5, beats overall (1,327 vs 1,469); boot 99.5 % /
  47 %; surface 4 flows x 6 distances, near 10.2-11.4 %, 10 km 0.3-2.9 %; README's 0.11 matches data/thresholds.csv.
- bcfishpass at 3bd2824c: example_newgraph CH `rear_gradient_max` 0.0549, `rear_channel_width_min` 1.5 (the opening
  sentence holds); load_habitat_linear_ch.sql's exception is `cw.channel_width >= min OR (stream_order_parent >= 5 AND
  stream_order = 1)` under `cw.channel_width <= max` (so only where a width is mapped), in the cw branch only (the
  article's sentence holds); docs/01_background.md's "more than half a million mapped road-stream crossings and dams"
  supports the methods article's opening.
- Map caption colours and legend words match `R/compare_map.R` (`.compare_rule_cols`: lost #d95f02, gained #1b9e77,
  kept #1b6ca8; labels "lost (default only)", "gained (tuned only)").

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:327-331 (with :175-176) — the article now says two incompatible
  things about how link's current rule treats lines through wetlands. The new Table 1 footnote says "link's current rule
  applies a near-a-river pair only to lines through wetlands", which the comparison supports: `compare$default_rule` is
  `width>=1.5|g<=0.0549|cw channel_width>=15@D1000; mad discharge>=3@D1000 on wetland_flow`, and link's `default` at the
  comparison's `config_sha` 102762d has `near_river: false` on stream edges and river polygons and no such line on the
  1050/1150 rule. The "Before you use it" bullet, two sections later and pointed to by that footnote's "(below)", says
  "link puts them through the same test as a stream line, which leaves about 2,500 km ... under the recommended rule
  ... against 8,400 km under link's rule". Under link's rule they are not given a stream line's test: they get the size
  test or the pair, which stream lines do not get (R/compare_rules.R:33-39: that is `wetland_flow`; "the same test as
  a stream line" is the `door` structure, which only the recommended rule's figure was run under). The old text tied
  the sentence to the comparison ("and so does the comparison here"); the rewrite dropped that, and the new footnote
  now contradicts it on the same page. A third reading is waiting at the opening's `default` link: it points at
  `meta$link_sha` (a17e917, link 0.66.0), whose CH rear rule gives 1050/1150 lines `thresholds: false` (no test at all)
  and no near-river pair, so a reader who follows it finds neither statement. Fix the bullet to say what each rule does
  to these lines (stream test or pair under link's, the recommended rule's own test under the recommended one); the
  link target's version is a separate, pre-existing choice worth stating if kept.
  - **Rule:** code-check.md "One fact derived twice"

## Not findings (checked, holds or accepted)

- `all_row$gained_exception_km > 0` is a province-wide guard, while the map paragraph's "What it adds (green) is short
  reaches of small streams beside a river" is about BULK; it holds there (236 of 257 km gained is through the
  allowance), and the sentence was unguarded before this branch.
- "more rules are close calls" at 1.96 is backed only by `>=` (superset), not `>`; it holds (2,456 vs 164).
- `grad_ext` left in the bundle, the catalogue record linked rather than cited, and the hard-coded "four"/"six"/"Ten
  kilometres" (the surface grid is a contract fixed in data-raw/vignette_chinook.R:283) are accepted.
