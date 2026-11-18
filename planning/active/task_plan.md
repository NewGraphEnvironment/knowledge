# Task: Backlog move 5: Chinook flow windows and timing (#174)

**If we do it:** life-stage timing comes from cited sources and NuSEDS for more groups, and we learn whether flow in the months chinook use a stream sizes it better than MAD. **If we never do:** the timing table stays two groups with one open row, each repo keeps its own NuSEDS copy, and the CH rearing rule stays on MAD untested.

Members: #31, #96, #108 (batch 8, timing table and NuSEDS); #42, #105 (batch 9, flow in windows). One phase per batch, one PR; a member bigger than one PR carries its first piece and files the rest, split from move 5, left out of `planning/backlog.md`.

## Context

No comments on #174 or its members. What exploration found that shapes the plan:
- `data/life_history_timing.csv`: BULK 12 rows, MORR 26; BULK CO migration has `start` 08-15 and no
  `end` (#31). Read by `knw_timing_read()` (`R/timing.R`), which already accepts a half window.
- No NuSEDS code in knowledge. The catalogue record (open.canada.ca `c48669a3-…`) is **Open
  Government Licence – Canada**, published by DFO; current resource `All Areas NuSEDS_20260601.zip`
  (one Latin-1 CSV, 421,001 rows, 51 columns). The copies our reporting repos keep show an earlier
  49-column release without `FWA_WATERSHED_CDE` and `FULL_CU_IN`, but those copies were renamed by our
  own scripts, so they are not a release as received. ckanr 0.7.0 is installed.
- The group library holds the NuSEDS item twice: `fisheriesandoceanscanadaNuSEDSNewSalmon` (cited by
  the reporting template) and the duplicate `canadaNuSEDSNewSalmon`. It also holds Fraser chinook
  sources: `bradford_taylor2023Diversityfreshwater`, `candy_etal2002discussionpaper`, and the 2013
  Cottonwood FSW summary, whose key `dolighanr_;britishcolumbiaconservationfoundation2013SummaryFisheries`
  has a `;` in it, which would break the timing table's `"; "` separator (it is cited nowhere yet).
- crate's `crt_ingest()` reads a registered upstream file whose shape changes between releases into one
  canonical shape (Al at the gate: "i bet those guys will change the schema"). Its registry is crate's
  own, so a crate release is a real dependency (main is 0.19.0; installed 0.16.0).
- This machine (m1) holds the published build in its database (since #158), with wet's monthly load
  of 2026-10-24. The published CH rearing rule is `mad>=0.75|g<=0.09|Q3@D1000` (minimal network,
  run `20261103_0838`, evidence `3d907629…`), scored on 7,823 visits, 235 with CH, 111 groups, 45 with
  both outcomes (`data/tune/CH_rear_summary.csv`), not the older run #105's body quotes. The evidence's
  `walks.csv` keeps `large_lfid`, the river each ladder rung found, so #105 Phase 1 needs no change to
  the walk.
- wet 0.4.36 has `wet_segment_daily()` (mean flow per day of a common year, from published parts; the
  database has no `segment_daily` table) and `wet_flow_window()` (basis `daily` or `monthly`). Neither
  reader returns `pick`. `wet_window_stats()` needs dated series (one value per window per year), so a
  7-day minimum per segment needs per-year daily flow, which wet does not publish per segment.
- This worktree lacks the ignored `data/fdis/`; the published evidence is restored with
  `PULL=TRUE KEYS=CH_rear scripts/0336-archive.R`.
- Plan review: `planning/active/review-plan.md` (every finding and how it was folded).

## Decided at the gate (Al, 2026-11-17)

- **NuSEDS home:** the full records table goes to ignored `data/nuseds/` and is published to fresh-bc
  `knowledge/nuseds/v1/` through `knw_publish()` with a receipt. Tracked: a small release record, the
  README source and the NOTICE row. **Read the file through crate** (`crt_ingest`), so a reshaped release
  is a new registered variant, not a silent breakage.
- **#105 stop rule (set now, before Phase 1 runs):** stop if fewer than 5 % of visits **and** fewer than
  5 % of CH detections flip; continue if either is 5 % or more. Made exact from the review (AC1) before
  its commit: counted over the 4,858 visits and 234 detections the tuning scores (45 groups with both
  outcomes; the review's 7,823 is the population before that filter); a flip is a visit the
  window reading classifies differently from the MAD reading, either way; judged on the totals, not per
  group; each of three readings (stream, river, both) is judged, and Phase 2 is filed if any reading
  reaches either share.
- **#42 per-segment table:** ignored `data/flow_window/segment_windows.parquet`, summarised in the
  research file; publishing waits for a consumer. From the review: the daily-basis window mean only; the
  7-day minimum goes with dry years into the split-off issue.
- Defaults I take: keep `fisheriesandoceanscanadaNuSEDSNewSalmon` and trash its duplicate. Fix the
  Cottonwood item's creator field so Better BibTeX derives a key with no `;`, after checking no store
  names it. #105 Phase 1 reads the published run and wet's monthly load through the database as its
  result, with the daily basis as a check.
- **Order:** the knowledge PR needs crate's release, so Phase 2 runs while the crate PR waits for Al's
  merge. If crate has not released when everything else is done, the PR opens and names it as the blocker.

## Phase 1: Batch 8, timing table and NuSEDS (#31, #96, #108 piece 1)

- [ ] **crate#74** (issue filed; PR from the `crate-nuseds` worktree, branch `nuseds-schema`): register
  `dfo / nuseds_all_areas` with the `2026-06-01` variant as received (Latin-1, declared as the variant's
  `encoding`), lower snake canonical names, counts `double`, year, inspections and ids `integer`, dates as
  written strings. It carries crate#41's first fix (read every column as character) with a test that
  fails on the old read; `crt_ingest()` reads the header, picks the variant, reads in its encoding, and
  refuses bytes that are not UTF-8 where none is declared. Fixture: every Maxan Creek chinook year and one
  François Lake row of the release. Its merge and release are Al's word.
- [x] `DESCRIPTION`: ckanr and curl in Suggests (an occasional fetch, guarded by `requireNamespace()`); `.gitignore`: `data/nuseds/` and `data/flow_window/`.
- [x] `R/nuseds_fetch.R`, `knw_nuseds_fetch()`: ckanr against the catalogue record. It finds
  `All Areas NuSEDS_<YYYYMMDD>.zip`, downloads it once to `data/nuseds/<YYYYMMDD>/` and returns the
  path, release date and md5. It refuses to overwrite a release already held with different bytes, and a
  zip that holds anything but one CSV. Tests mock ckanr and the download, which fail by default.
- [x] `R/nuseds_records.R`, `knw_nuseds_records()`: `crt_ingest("dfo", "nuseds_all_areas")`, then assert
  one row per `pop_id`, species and year, keeping the columns unaltered, and add `evidence_kind` by a
  precedence written in the function: `count` (a spawner or return number), `presence_survey` (present,
  with a method or inspections recorded), `presence_expert` (present by expert opinion, no survey
  recorded), `none_observed`, `not_inspected`, `unknown` (anything else). Tests on crate's fixture hold
  #108's Maxan cases, an unknown header refused, and every class.
- [ ] `scripts/0340-nuseds-build.R`: fetch, build, write `data/nuseds/<rel>/nuseds_records.csv` and tracked
  `data/nuseds_release.csv` (release, zip md5, rows, fetched date). With `PUBLISH=TRUE` only, publish
  through `knw_publish()` (`id = "knowledge/nuseds/v1"`) with `inst/receipt/nuseds.yaml` (added to
  `test-receipt.R` and the `receipt` docs) and upload `data/nuseds_README.md` beside it. Prints the Maxan
  chinook check against #108's measured rows. Log under `scripts/logs/nuseds/`. If auto mode refuses the
  upload, hand Al the bare command.
- [ ] `inst/NOTICE.md`: an OGL-Canada section for NuSEDS (DFO), naming the published prefix and the
  release record; `data/nuseds_README.md` carries the attribution.
- [ ] Zotero: trash `canadaNuSEDSNewSalmon` (its relations merged into the kept item through the Web
  API). Check no store names the Cottonwood item, then fix its creators so its key has no `;`.
- [x] **#31:** read `officeofthewetsuweten2013WetsuwetenTitle` p. 24 from the PDF. Add the end date
  if the source gives one. If it does not, the row's note says the end is unsourced and consumers drop
  the row. `knw_timing_read()` still passes.
- [ ] **#96:** UFRA (Swift Creek, upper Fraser mainstem) and COTR (Cottonwood system) chinook rows,
  migration and spawning at minimum, then other stages where the evidence allows. Populations are picked
  by FWA watershed code inside the group, never by name. Spawning comes from NuSEDS: start
  `START_SPAWN_DT_FROM`, end `END_SPAWN_DT_TO` else `END_SPAWN_DT_FROM`, month and day only, the median of
  each across the years with dates, the year count in the note, cited
  `fisheriesandoceanscanadaNuSEDSNewSalmon`. Migration comes from the group library's literature, each
  claim a `timing` row in `data/literature_evidence.csv` (appended) checked by `0280` against its PDF,
  never an abstract. Notes say where a window rests on one source or where sources disagree.
  `data-raw/timing_nuseds.R` prints the derived windows and per-year counts to a committed log; the rows
  are entered by hand, as the table's others are. If the literature grows past this PR, the migration rows
  split out.
- [ ] Split from #108: file "provincial fish observations and literature per stream beside the NuSEDS
  records". Its body names move 5 (#174) as where it was split from; it stays out of `planning/backlog.md`.
  Edit #108's body to say what landed and what was split.

## Phase 2: Batch 9, flow in windows (#105 Phase 1, #42 piece 1)

- [x] Restore the published run's evidence: `PULL=TRUE KEYS=CH_rear Rscript scripts/0336-archive.R`, and
  check the visit tables' md5s against the CH rearing grade record's `evidence_md5`.
- [x] **Stop rule first:** create `research/chinook_window_flow.md` with the windows (rearing 08-01 to
  09-30 on the stream; spawning 08-15 to 09-15 on the downstream river), the matched thresholds' method and
  the stop rule as set at the gate, and commit it before any flip is computed.
- [x] `data-raw/chinook_window_flow.R` (#105 Phase 1), on this host (`knw_db_latency_check()`). It
  refuses unless the research file is committed, and logs HEAD and the stop rule's commit:
  - flow load from `knw_discharge_load()`, refused unless it equals the grade record's `discharge_load`;
  - population: `.tune_population()` on the restored evidence with `knw_tune_run()`'s own defaults
    (7,823 / 235 / 111), then `.tune_modelled()`, stopped unless 4,858 / 234 / 45;
  - window means from `discharge.fwa_v1_segment_monthly` through the connection, on each segment's `pick`
    source: at each visit's segment (`visits_link$pick_source`; the 26 visits whose flow came from a parent
    read the parent's, or are dropped and counted) and at each rung's river (`large_lfid`, `pick` from the
    table);
  - window / MAD spread by watershed group, at visits and at rivers;
  - the MAD reading through `knw_rule_in()` first, stopped unless it reproduces the published rule's
    `n_in` 1,400 and `n_detect_in` 197 (`data/tune/CH_rear_tune.csv`), and unless the recomputed MAD equals
    `mad_pick` at every visit; then the window readings at matched thresholds (0.75 m³/s scaled by the median ratio at
    visit segments, 3 m³/s by the median at rivers): stream, river, both. Flips, both directions, of visits
    and CH detections, in total and by group. The river reading uses the ladder's rivers within 1 km: an
    approximation (a river smaller than the lowest rung is not seen), stated in the file;
  - a daily-basis check (`wet_segment_daily()`, each river's group looked up) on the spawning window,
    timed on one group first, with wet's daily build recorded;
  - small tables to `data/tune/flow_window/` (tracked; `0325`, `0330` and `knw_thresholds_table()` never
    read it), and a log.
- [ ] `data-raw/segment_window_flow.R` (#42 piece 1): every segment in each group of the timing table
  (BULK, MORR, UFRA, COTR), each complete stage window, both sources: the daily-basis window mean, with
  the monthly basis beside it, to ignored `data/flow_window/segment_windows.parquet`.
- [ ] Write up `research/chinook_window_flow.md`: the plain-language walk (what the rule reads now, what
  was asked, how judged, what came back), the spread and flips by group, the verdict against the rule set
  beforehand, the flow load, the caveats, and #42's summary by group and stage. Link it from
  `research/README.md` and from #42's and #105's bodies.
- [ ] Outcome: **on a stop**, close #105 with the result, and add a sentence to
  `research/chinook_stream_size.md` and to the methodology article's limits. **On a pass**, file "#105
  Phase 2: tune on the window" (body: the walk decision, a separate window walk or an edit to the
  published one; outputs under `flow_window/`; waits on Al's word), split from move 5.
- [ ] Split from #42: file "7-day minimum and dry-year departures per window" (per-year daily flow at
  gauges, then carried to segments), split from move 5. Edit #42's body to say what landed.

## Phase 3: Wrap-up

- [ ] `DESCRIPTION` crate floor (the release carrying #74), `NEWS.md`, `_pkgdown.yml` reference entries,
  `scripts/README.md` run order (`0340`), `CLAUDE.md` layout lines (`data/nuseds/`,
  `data/nuseds_release.csv`, `data/nuseds_README.md`, `data/flow_window/`, `data/tune/flow_window/`).
- [ ] Tick batches 8 and 9 in `planning/backlog.md`.

## Owed at the end (reported, done after merge)

- [ ] crate release with NuSEDS registered, if it is still unmerged when the knowledge PR opens.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- NuSEDS: unit tests on crate's fixture (the 2026-06-01 variant, an unknown header refused, every
  `evidence_kind` class). `0340`'s Maxan check equals #108's measured rows. The receipt round-trips through
  `crt_receipt_compare()`.
- Timing: `knw_timing_read()` reads the whole table; `0280` reports 0 unresolved timing sources and every
  new `timing` quote verbatim.
- #105: the script refuses an uncommitted stop rule and logs its commit. The flow load is named. The MAD
  reading reproduces the published rule. The flips are recomputed from the tables in `data/tune/flow_window/`.
- #42: row count = the sum over groups of segments × complete windows × 2 sources. A spot check of one
  gauge segment (Buck Creek 08EE013) against wet's own vignette window.
- `devtools::test()`, `lintr` per-file diff against `origin/main`, `pkgdown::check_pkgdown()`.
