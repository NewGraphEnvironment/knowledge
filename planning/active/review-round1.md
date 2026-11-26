# Code-check round 1: #140 branch (grayling_use.R, grayling_segments.R, docs)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md, by heading: "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising…", "Forked
  `parallel::mclapply()` workers segfault in `glm.fit`…", "`clusterApply()` returns `NULL` for no tasks…", "Postgres row
  order is never fixed unless the query fixes it…", "A `data-raw/` script must load the source tree, not the installed
  package", "A URL handed to a reader goes through R's 60 s connection timeout", plus the index lines for `$`
  partial-match, `match()` NA, `ifelse()` all-NA, `sprintf("%g")` into SQL, `tryCatch(warning =)`, `paste()`
  zero-length, `unlist()` of `split()` names, readr `trim_ws` (checked against the code without the full section). The
  rest of the file's headings (about 105) not read: no tool or shape they name is used.
- code-check-shell.md, by heading: "Git plumbing calls whose default answers a different question". The rest (about 90)
  not read.
- code-check-spatial.md, by heading: "A GDAL failure partway through `sf::st_read()`…", "Ask the file about its field
  names, not R"; index lines for `st_union` after `st_transform` with mixed XY/XYZ and FWA edge types checked against
  the code. The rest (about 110) not read.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows skipped).

Index, diff and changed files read from file.

Probes run (read-only, outside the repo's outputs): a scratch R script at
`<scratchpad>/probe_use.R` reading `data/fdis/derived` (population NA checks, sensitivity population), and inline R
reading `data/hagen_segments/AG_Segments_merged.shp` to measure segment overlap. Nothing in the repo was written.

## Findings

- **[severity: bug]** data-raw/grayling_segments.R:84-91, 113 — the `all` row (and the lake message) sum over
  segment x FWA-line join rows, so a reach covered by several segments is counted once per segment.
  - The 85 segments overlap heavily: 2,248 of their 3,316 km lie within 25 m of another segment (most of it inside the
    2021 layer, where one reach carries separate Adult, Fry and Juvenile segments). Dissolved, each reach once, they
    cover about 1,980 km. The per-stage groups barely overlap (fry 0 km, juvenile 1, adult 2), but spawning has 105 of
    540 km and `all` 2,248 of 3,316.
  - So the log's `all ... 85 segments 3176 km` is about 1.6 times the length of stream the segments follow, and its
    length-weighted quantiles and shares weight multiply-covered reaches two or three times. "Lines in a lake or
    reservoir polygon left out: 328 lines, 248 km" counts rows, not lines, and double-counts the same way.
  - It has already been published: `research/grayling_habitat.md:123` says "(3,176 km outside lakes and the
    reservoir)". Fix by deduplicating `linear_feature_id` within each group before summing (`distinct(d,
    linear_feature_id, .keep_all = TRUE)`), and `n_distinct` in the lake message; then rerun and revise the research
    sentence.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/grayling_use.R:353-362, 398-399 — the bootstrap keeps resamples where a class is
  separated (no detection or every visit a detection), and their fitted ratios go to about 0 or without bound. The main
  fit's `sep` guard (line 396) does not reach the resamples. Published intervals carry the artifact:
  `data/gr_use.csv` has `ratio_lo` 0 on six rows (for example gradient 5.49-8 % gr_caught, 0-0.312) and `ratio_hi`
  723773232.976 (gradient 8-12 % gr_caught_given_fish). `n_boot_ok` counts those resamples as good. Every affected row
  is `underpowered` today, which limits the harm, but the bounds read as numbers. Count separated resamples per class,
  and give the interval as NA, or report the count, where they exceed the 2.5 % tail.
  - **Rule:** none

- **[severity: fragile]** data-raw/grayling_segments.R:8-9, 11-14 — the header says the gradient, MAD and width are
  read "as link's rules would read them" and lake lines are "a lake or reservoir polygon". Neither holds as written:
  - `fwa_gradient` from `knw_link_flow()` is `s.gradient`, the whole Freshwater Atlas line's gradient. link's rules
    read the gradient of link's own segment (`segment_gradient`, CLAUDE.md, "The tuning scores link's segment
    gradient"), and the companion `grayling_use.R` classes visits on `segment_gradient`. The research file sets the
    two side by side against link's 2.49/3.49/5.49 % limits. On these large rivers the gap is probably small, but the
    sentence should say whole-line gradient.
  - `wb_lake` from `knw_link_width()` is a lake or man-made waterbody of at least 100 ha (`lake_ha_min`). Lines in
    smaller lakes stay in, with near-zero gradient.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/grayling_segments.R:16-17 and .gitignore:9 — the header says the layer's terms are
  unsettled "(inst/NOTICE.md, #76)". Neither records it. NOTICE's "Terms not yet settled" list names EcoCat fish data
  submissions and report text, not an EcoCat GIS layer, and the body of #76 (open) does not mention the Hagen segments.
  CLAUDE.md says a source whose terms are unconfirmed "goes to an issue instead", and a tracked log
  (`20261126_grayling_segments.txt`) and research prose are now derived from it. Add the layer to #76's body (and to
  NOTICE's list if that is where it belongs), or reword the pointer.
  - **Rule:** none

- **[severity: fragile]** data/grayling_additions.csv:7, 8, 10, 15, 17, 18, 19 (file lines) — several `why` notes are
  cut mid-word or mid-phrase in the committed file: "associated fish speci", "October 2007, whi", "title page "
  (then the field closes), "image-only UMI scan (n", "title page reads 'of the long-term". The CSV still parses (read
  with 18 rows and no problems), but the kept record of why each original was filed is lost at the cut. Separately,
  the Northcote 1995 row (line 16) says "paywalled, abstract only", and the commit that filed it (595eef3d) says it
  was "filed with no PDF or abstract, so it is not quoted". One of the two is wrong.
  - **Rule:** none

## Checked and clean

- `.tune_base()` / `.tune_population()` / `knw_tune_run()` defaults: `edge_stream` 1000/1100/2000/2300 and
  `area_range` 10-10,000 are read from `formals(knw_tune_run)`. The population's filters (river, wetland and lake
  flags, area, in range, not blocked, `barrier_dnstr_gr` FALSE) match the header. The funnel's end is checked against
  `pop$d`. On this machine: 1,580 visits, 229 with GR caught, which matches the gradient rows of `gr_use.csv`. No NA
  in `catch_status`, `month`, `blue_line_key`, `segment_gradient` or `mad_pick` in either the main or the
  river-kept population.
- `knw_run_ledger("data/tune")` resolves to the `-derived_minimal` ledger, and its `md5_fish` row exists.
  `data/thresholds.csv`'s blank `evidence_md5` cells read as NA under readr and drop out, leaving one value, which
  equals the local md5s in the order visits_link, visits_species, walks.
- `.knw_free_path()` behaves as used. `system2` status is read from `attr(out, "status")`. `pkgload::load_all()` is
  used, not the installed package. The socket cluster (not forks) suits the glm bootstrap. Resamples are drawn in the
  master before `parLapply`, so the output does not depend on worker count. The SQL ends its `ORDER BY` on
  `(seg_id, linear_feature_id)`. `curl_fetch_disk` follows redirects and its status is checked.
- The class labels match the `cut()` intervals for all three variables. `rr[class]`, the bootstrap columns and the
  table rows are all in `labs` order.
- `st_as_text()` writes 7 significant digits (BC Albers x rounded to about 1 m). Against a 25 m buffer and a
  half-length rule this is immaterial, so it is not raised.
