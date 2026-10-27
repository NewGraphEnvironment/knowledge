# Task: Place FDIS sites with candidate snapping and the 1:50k code, not nearest-then-reject (#91)

`scripts/0230` places each FDIS visit by snapping its UTM point to the nearest Freshwater Atlas stream
(`fwa_indexpoint()`, 500 m search) and then rejects doubtful placements: 5,242 visits (10 % of 51,587) because the
nearest stream is 100–500 m away, and 1,088 because the FDIS 1:50k watershed code disagrees with the stream the point
landed on. The 100 m limit was inherited from the one-species builds with no recorded reason or sensitivity test.

Where the 1:50k code can check a placement (it names a tributary on 12,285 of the 50,024 placed visits), disagreement
rises with distance: 8 % within 25 m, 18 % at 25–50, 28 % at 50–100, 34 % at 100–200 and 57 % at 200–500 m. So distance
predicts a wrong stream, but two-thirds of the 100–200 m snaps agree with their code: the cut throws away many good
placements, and a near snap to the wrong stream is rejected rather than moved to the right one.

**Resumed 2026-10-27**: Al confirmed gate decisions 1 (evidence only) and 2 (the recommended rule) at the resume; the
run-to-PR mandate runs from here.

## Context (what the exploration and the plan review settled)

- **link's segments already exclude what fresh excludes, except subsurface lines.** `lnk_pipeline_prepare.R:836-838`
  drops unmapped (`localcode_ltree IS NULL`) and placeholder (`999.*`) lines: `fresh_default_20261017.streams` holds 0
  of each and no 6010 connector, but 353 subsurface (1425) segments. So the 1,474 + 174 visits `fwa_indexpoint()`
  puts on unmapped or placeholder lines are today's `no_link_segment` drops (1,491 in the ledger); under fresh they
  snap to the next mapped stream and can be kept. fresh admits 6010, which link's streams lack, and excludes 1425 by
  default, which link's streams carry: the probe counts both classes and the exclusion set is read off the counts
  (default `c(1425L, 6010L)`, fresh's convention plus the connector).
- **The hint route is feasible.** `fwa_streams_20k_50k`: 293,445 codes; 70 % map to one 20k `blue_line_key`, 90 % to
  at most two, 1,248 to more than five, max 422 (big mainstems, which the check excludes as all-zero below the basin).
  `frs_point_snap(col_blk =)` snaps a row with a hint only to that key (`(p.hint IS NULL OR s.blue_line_key =
  p.hint)`), rows of one point with different hints are independent, ids must be unique, an `sf` in EPSG:3005 is
  accepted, and `distance_to_stream` and `linear_feature_id` come back. A visit with a checkable code becomes one row
  per key, and "confirmed" means what today's check means: on any 20k stream the 1:50k code names (`any(hit)`). The
  per-stream reduction the issue weighed is not needed on this route, and raising `num_features` would still not
  guarantee the coded stream is among the candidates. A fresh issue is filed only if the probe shows the hint route
  cannot cover the codes.
- **Only one settle log exists** (`scripts/logs/habitat/20261017_link_settle.csv`, run `20261017_004619-3f4c713b`),
  so `0310` passes its gate only on `SCHEMA=fresh_default_20261017`: the build every tracked tune table rests on
  (the renamed `fresh_default` is run `20261023_074321-24d85e8c`, with no settle log). The evidence is rebuilt there,
  and `knw_build_record()` keeps the same refusal.
- **`0310` never cached its walks**, so its first run with `cache = "knw.walk_cache"` walks every visit cold (about
  840k walks; ~10 min on the host's 4 workers, 40–60 min over a remote link). The cache holds the grade's
  segment-end starts, not visits'. fresh's whole-metre measure (floor, never below the segment's start rounded up) is
  a separate fact: it may gain hits where a visit sits on a link break, and `knw_link_place()`'s window `[m-1, m+5]`
  still finds the break; `segment_starts_in_window` before and after is the check.
- **The articles cannot be rerendered before the retune**: `data-raw/vignette_method.R` requires the grade tables'
  `evidence_md5` to equal the derived tables' md5s. #93's decision stands (counts wait for the retune), so the
  methodology and chinook articles' prose change at the retune, and this branch writes those tasks into #92.
- **Two tests go red until that rerun, on every clone.** `method.rds` pins the md5s of its tracked sources, and
  `inst/method/settings.csv` and `pipeline.csv` are among them (`vignette_method.R:380-387`), so the register edit
  alone fails `test-vignette-data.R`'s "every tracked source … unchanged" test wherever `data/` exists, which is every
  clone (`data/` is tracked); the "every ignored source" test fails too where the new derived tables are. No workflow runs the tests yet (#98, the R CMD check
  workflow, is an open PR: once it merges, the two tests read red on every push), so until then nothing on GitHub
  reads red; `devtools::test()` does, with the
  message "rerun Rscript data-raw/vignette_method.R".
- The settings register's `snap_limit` row carries a `code:` pointer into `vignettes/chinook_rearing.Rmd` ("stream
  lay within 100 m"). The chinook article truthfully describes the #73 run until its rerender, so that pointer moves
  to the row's note until the retune restores it (the register test and `vignette_method.R` iterate `where` only).
- The register parser unwraps only a bare `Sys.getenv(var, default)` (`settings_register.R:55`) and reads the
  default, so an overridable constant is written `snap_limit <- Sys.getenv("SNAP_LIMIT", 100)` (numeric literal, as
  `0330`'s `tuned_as`) and coerced with `as.numeric()` at use; the script default, `knw_fdis_place()`'s default and the
  register value must agree, and the test holds the three.

## Decided at the gate (1 and 2 confirmed by Al at the resume, 2026-10-27)

1. **Scope of the run on this branch: the evidence, not the retune.** `0230` and `0310` are rerun and the limits are
   measured by scoring two keys on the main fold seed into an untracked directory; `0320`/`0325`/`0330` and the two
   articles' rebuilds are one retune with #92, written into #92's body as tasks. Consequence until #92's retune
   merges: `devtools::test()` fails two tests of `test-vignette-data.R` on every clone (above), each naming the
   rerun; the tracked tune and compare tables keep describing the #73 run, consistent with each other; the published
   articles keep the #73 run's counts and method. *Alternative:* run the full retune here (`0320` scoring ~1 h,
   grading mostly warm, `0330` ~3 h on the host, the two bundles and the bib) and let #92 retune again.
2. **The limits, by rule.** Two limits: `snap_limit` for an unconfirmed pick (no checkable code) and
   `snap_limit_code` for a code-confirmed pick. Recommended rule: a confirmed pick is kept to the search radius
   (500 m: the code names the stream; the sensitivity reports, for every confirmed pick beyond 100 and 200 m, its
   distance and the nearest stream's, because the issue's disagreement-by-distance table describes nearest snaps and
   says nothing about moved ones); an unconfirmed pick is kept to the widest distance band whose code-checked
   disagreement stays under one in three (the issue's table gives 100 m: 100–200 m disagrees 34 %), recomputed under
   the new snap, with CH rearing's and BT rearing's one-SE region at each limit reported beside it. If a key's region
   moves inside the chosen limit, the smaller limit wins. *Alternatives:* (b) the widest limit at which neither key's
   region moves; (c) a number Al names.
3. **A checkable code with no segment within the search radius is a drop** (today's `ws50_mismatch`, now meaning "the
   recorded tributary is not in reach"): the code contradicts every stream in reach, so nothing can be moved. Stated,
   not asked.
4. **Schema `fresh_default_20261017`** for the evidence build (the only one with a settle log; the build the tracked
   tables rest on). Stated, not asked.

## Phase 1: Probe first, from a committed script

- [x] `data-raw/snap_candidate_check.R` (fresh ≥ 0.40.0 required): from `data/fdis/build/sites.rds`'s points
      (50,550 with coordinates), rerun the 2026-10-26 comparison: `fwa_indexpoint()` nearest against
      `fresh::frs_point_snap()` nearest at 500 m (same segment, same stream, measure difference), and class every
      difference (unmapped, placeholder, subsurface 1425, connector 6010, tie, no fresh candidate); then run
      `knw_link_place()` on `fresh_default_20261017` for each class under both snaps, so the ledger says what link
      already drops today (expect the old snap to reproduce `no_link_segment` = 1,491) and what fresh's snap recovers
- [x] the hint route measured on the visits' own codes: checkable codes per visit, keys per code, hinted-snap
      coverage (a code with a segment of its stream within 500 m), moves (hinted pick on another stream than the
      nearest) with the move's distance and the nearest's, confirmed picks by keys-per-code, and the distance of
      confirmed and unconfirmed picks by band
- [x] `scripts/logs/fdis/<date>_snap_candidate_check.txt` (the summary) and `.csv` (one row per visit and class);
      the counts into `findings.md`; the exclusion set (`exclude_edge_types`) read off the 1425 and 6010 counts;
      file the fresh issue only if the hint route cannot cover the codes

## Phase 2: Place with fresh's snap and the 1:50k code

- [x] `R/fdis_place.R`: `knw_fdis_place(nearest, hinted, limit_near = <snap_limit>, limit_code = <snap_limit_code>)`,
      a pure pick with no database: one row per visit with `snap_method` (`code`, `nearest`), `snap_confirmed`,
      `snap_moved` (the pick's stream is not the nearest's), the pick's `blue_line_key`, `downstream_route_measure`,
      `linear_feature_id`, `distance_to_stream`, plus `nearest_distance_m`, `flag_not_placed`, `flag_far_snap` (an
      unconfirmed pick beyond `limit_near`, or a confirmed one beyond `limit_code`) and `flag_ws50_mismatch` (a
      checkable code with no hinted hit); ids pass through untouched and are only compared, so `integer64` from
      `0230`'s connection works; `tests/testthat/test-fdis_place.R` on a fixture that reaches every branch (no
      code, confirmed nearest, moved, no hit, far unconfirmed, far confirmed, not placed, several keys per code, the
      nearest key wins among hits) and shows each limit flipping a row
- [x] `scripts/0230`: a `packageVersion("fresh") >= "0.40.0"` stop as `0310`'s link gate; two `frs_point_snap()`
      calls on the `sf` points (nearest at `snap_search`; hinted, one row per visit × `blue_line_key_20k` of its
      checkable codes, ids `site_visit|key`), `tolerance = snap_search`, `exclude_edge_types` from Phase 1; the stream
      attributes (`fwa_stream_networks_sp`, channel width, discharge) joined by `linear_feature_id` as today;
      `knw_fdis_place()` picks; the temporary table and the `fwa_indexpoint()` lateral go; `snap_limit` and
      `snap_limit_code` as `Sys.getenv("SNAP_LIMIT", 100)`-form constants coerced at use; the reconcile gains
      `sites_snap_confirmed`, `sites_snap_moved`, `sites_snap_unconfirmed`, `sites_snap_nearest_edge_<type>_excluded` (one per excluded type), and
      placed counts by distance band; the header's PLACEMENT note rewritten
- [x] `R/fdis_quality.R`: the same drop steps (`not_placed`, `far_snap`, `ws50_mismatch`) with their notes reworded,
      plus `info` rows for confirmed and moved placements among the kept; `test-fdis_quality.R` updated
- [x] `scripts/0240`: `snap_method`, `snap_confirmed`, `snap_moved`, `nearest_distance_m` into `fdis_sites.csv`
      (v3 is unpublished, so no version bump; `0299`'s header notes the columns); its header says `flag_far_snap` in
      `data/fdis_evidence.csv` is this limit while `data/fiss_evidence.csv` (`0250`, bound by row) keeps 100 m on
      `fwa_indexpoint()`
- [x] `inst/method/settings.csv`: `snap_search` → fresh's `tolerance` (`script:` row kept); `snap_limit` → the
      unconfirmed limit (`script:` and `fn:knw_fdis_place:limit_near`), its chinook-article `code:` pointer moved to
      the note until the retune; new `snap_limit_code` (`script:` and `fn:knw_fdis_place:limit_code`),
      `snap_edges_excluded` (`script:`); `pipeline.csv` step 2 names
      `fresh::frs_point_snap;knowledge::knw_fdis_place;knowledge::knw_fdis_quality` and its `does` text;
      `test-settings-register.R` passes (`test-vignette-data.R`'s tracked-source test now fails, as decided)
- [x] run `SNAP_LIMIT=500 SNAP_LIMIT_CODE=500 Rscript scripts/0230-fdis-load.R 2>&1 | tee scripts/logs/fdis/<date>_fdis_load-snap500.log`
      (every placed visit kept, so the sensitivity can apply any smaller limit); `0240` is not run here, and the
      tracked `data/fdis_repeat_surveys.csv` this run rewrites is restored (`git checkout -- data/fdis_repeat_surveys.csv`)
      so only Phase 4's final run is committed

## Phase 3: `0310` on a named schema with cached walks

- [x] `scripts/0310`: `schema <- Sys.getenv("SCHEMA", "fresh_default")` as `0320`/`0330`; `knw_build_record(conn,
      schema, run_uid = st$run_uid)` replaces the hand-rolled `log_recompute` check and its line is ledgered
      (`build_record`); `q$ledger`'s `info` rows bound beside its drops (today only `kind == "drop"` is, `0310:111`);
      `knw_link_walks(..., cache = "knw.walk_cache")` with the cache's hit and miss counts ledgered; header,
      `scripts/README.md` and `inst/method/pipeline.csv` step 5 updated
- [x] run `SCHEMA=fresh_default_20261017 Rscript scripts/0310-evidence-build.R` on the 500 m build →
      `scripts/logs/habitat/<date>_evidence_build_ledger.csv` (cold visit walks: `0310` never cached them); the
      sensitivity script copies this ledger to `scripts/logs/fdis/<date>_snap_limit_sensitivity_ledger-snap500.csv`
      before Phase 4's run overwrites the day's ledger (the `_evidence_build_ledger\.csv$` readers never match the copy)

## Phase 4: The limits by measurement

- [x] `data-raw/snap_limit_sensitivity.R`: from the 500 m evidence (`visits_link`, `visits_species`, `walks`, link's
      `default` and `default_tuned` thresholds at the ledger's `run_link_sha` read as `0320:134-150` reads them, the
      spawner table unused for rearing), for unconfirmed ∈ {100, 200, 500} × confirmed ∈ {200, 500}: visits kept,
      moved picks by move distance and the nearest's distance, and CH rearing's and BT rearing's pick and one-SE
      region on the main fold seed (`knw_tune_run(..., species = c("CH", "BT"), stages = "rear", thresholds_extra =
      thr_tuned, smoke = FALSE, extra = FALSE, cache_dir = NULL)`: nothing written under `data/tune`); the
      code-checked disagreement by distance band under the new snap; `scripts/logs/fdis/<date>_snap_limit_sensitivity.{txt,csv}`
- [x] set `snap_limit` and `snap_limit_code` by the gate's rule; register rows; rerun `0230` (log
      `<date>_fdis_load.log`), `0240` and `0310` at the defaults (walks now cached, provided wet's flow load has not
      moved between the two runs: the cache keys on `load_md5`) → the final evidence ledger; these outputs
      (`data/fdis_repeat_surveys.csv`, `data/fdis_evidence.csv`, the logs) are the ones committed
- [x] the ledger before and after, in `findings.md`: placed, confirmed, moved, unconfirmed, dropped and why,
      `no_link_segment`, `segment_starts_in_window`, the walk cache's hits and misses

## Phase 5: Write-up and pointers

- [x] `research/fdis_export.md`: a placement section (the method, the probe's classes, the sensitivity table, the
      limits and their rule, what "confirmed" means with a multi-key code); `research/habitat_thresholds_tuned.md`
      Evidence paragraph (how a visit reaches the network now); `research/README.md` row
- [x] `data-raw/vignette_method.R`, for the retune's rerun (not run here): the drop reasons' wording; the worked
      example's `near()` query takes fresh's guards (unmapped, placeholder, the excluded edge types) so its ranking
      is the snap's, and the example set becomes a kept nearest, a moved visit and a dropped one, each with its own
      assertion (today's `:284-286` stops unless the nearest is the placed stream, which a moved example breaks by
      design)
- [x] `CLAUDE.md` working note (the hint route; `0310`'s walks are cached from here; the two red tests until the
      retune; the articles wait for it); `NEWS.md` entry
- [x] #92's body: the retune's tasks (`0320`/`0325`/`0330`, `vignette_method.R` and `vignette_chinook.R` reruns, the
      chinook article's placement sentence and the `snap_limit` row's `code:` pointer restored,
      `vignettes/habitat_thresholds.Rmd` step 2, `#snap` and Limits prose, the two tests green again); #91's body:
      the measured section replaced by the probe's and sensitivity's numbers, linking the research file

Not inside: `scripts/0250` (FISS workbook sites) keeps `fwa_indexpoint()` and its own constants (no 1:50k code there;
a separate source, noted in `0240`'s header); the frozen `0290`–`0298`; `vignettes/*.Rmd` prose (the retune's).

## Owed at the end (reported, done after merge)

- [x] none owed past the merge: the retune is #92's, written into its body in Phase 5

## Validation

- [x] Tests pass (`devtools::test()`: `test-fdis_place.R`, `test-fdis_quality.R`, `test-settings-register.R` and
      the rest), except the two `test-vignette-data.R` tests decided at the gate ("every tracked source …" and
      "every ignored source …" of the methodology bundle), named in the PR with the rerun that clears them
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion

How each change is proved: the probe's classes partition the 50,550 points and its link-placement counts reproduce
today's `no_link_segment` (1,491) on the old snap; `knw_fdis_place()`'s fixture reaches every branch and a mutation of
each limit flips a row; `0230`'s reconcile and `knw_fdis_quality()`'s ledger partition the input (both already
assert it); `0310`'s ledger partitions 51,587, carries the build record, and its walk row names the cache's hits and
misses; the sensitivity's six cells each state kept visits, moved picks by distance and both keys' region, and the
chosen limits are read off the rule stated at the gate; the register test passes on the committed tree;
`lintr::lint_package()` clean.
