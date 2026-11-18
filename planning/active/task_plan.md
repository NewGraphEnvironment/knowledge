# Task: Backlog move 5: Chinook flow windows and timing (#174)

**If we do it:** life-stage timing comes from cited sources and NuSEDS for more groups, and we learn whether flow in the months chinook use a stream sizes it better than MAD. **If we never do:** the timing table stays two groups with one open row, each repo keeps its own NuSEDS copy, and the CH rearing rule stays on MAD untested.

Members: #31, #96, #108 (batch 8, timing table and NuSEDS); #42, #105 (batch 9, flow in windows). One phase per batch, one PR; a member bigger than one PR carries its first piece and files the rest, split from move 5, left out of `planning/backlog.md`.

## Context

Umbrella #174 carries backlog batches 8 and 9: one phase per batch, one PR, and any member bigger
than one PR carries its first piece and files the rest as its own issue (named as split from move 5,
left out of `planning/backlog.md`). Members: #31, #96, #108 (batch 8); #42, #105 (batch 9). No
comments on #174 or its members.

What exploration found that shapes the plan:
- `data/life_history_timing.csv`: BULK 12 rows, MORR 26; BULK CO migration has `start` 08-15 and no
  `end` (#31). Read by `knw_timing_read()` (`R/timing.R`), which already accepts a half window.
- No NuSEDS code in knowledge. The catalogue record (open.canada.ca `c48669a3-…`) is **Open
  Government Licence – Canada**, published by DFO; current resource `All Areas NuSEDS_20260601.zip`.
  An older copy one of our reporting repos keeps has a different, lower-case header, so the schema may
  drift between releases. ckanr 0.7.0 is installed.
- The group library holds the NuSEDS item twice: `fisheriesandoceanscanadaNuSEDSNewSalmon` (cited by
  the reporting template) and the duplicate `canadaNuSEDSNewSalmon`. It also holds Fraser chinook
  sources: `bradford_taylor2023Diversityfreshwater`, `candy_etal2002discussionpaper`, and the 2013
  Cottonwood FSW summary, whose key `dolighanr_;britishcolumbiaconservationfoundation2013SummaryFisheries`
  has a `;` in it, which would break the timing table's `"; "` separator (it is cited nowhere yet).
- crate 0.16.0 has `crt_ingest()` / `crt_schema_conform()` / `crt_schema_variant()`. They read a
  registered upstream file whose shape changes between releases into one canonical shape. That fits
  NuSEDS (Al at the gate: "i bet those guys will change the schema").
- This machine (m1) holds the published build in its database (since #158), with wet's monthly load
  of 2026-10-24. The published CH rearing rule is now `mad>=0.75|g<=0.09|Q3@D1000` (minimal network,
  run `20261103_0838`, evidence `3d907629…`), not the `g<=0.11` that #105's body quotes. The walk
  cache keeps `large_lfid`, the river each ladder rung found, so #105 Phase 1 needs no change to the walk.
- wet 0.4.36 has `wet_segment_daily()` (daily flow per segment, from published parts; the database
  has no `segment_daily` table), `wet_flow_window()` (basis `daily` or `monthly`) and `wet_window_stats()`.
- This worktree has no `data/`; the published evidence is restored with `PULL=TRUE scripts/0336-archive.R`.

## Decided at the gate (Al, 2026-11-17)

- **NuSEDS home:** the full records table goes to ignored `data/nuseds/` as Parquet and is published to
  fresh-bc `knowledge/nuseds/v1/` through `knw_publish()` with a receipt. Tracked: a small release record
  and the NOTICE row. **Read the file through crate** (`crt_ingest`), so a reshaped release is a new
  registered variant, not a silent breakage.
- **#105 stop rule (set now, before Phase 1 runs):** stop if fewer than 5 % of visits **and** fewer than
  5 % of CH detections flip; continue if either is 5 % or more. The rule is committed to the research
  file before the run.
- **#42 per-segment table:** ignored `data/flow_window/segment_windows.parquet` (both sources, daily
  basis, window mean and 7-day minimum), summarised in the research file; publishing waits for a consumer.
- Defaults I take (say otherwise at the gate): keep `fisheriesandoceanscanadaNuSEDSNewSalmon` and trash
  its duplicate. Fix the Cottonwood item's creator field so Better BibTeX derives a key with no `;`.
  #105 Phase 1 reads the published run (minimal network) and wet's monthly load as the main result, with
  the daily basis as a check.

## Phase 1: Batch 8, timing table and NuSEDS (#31, #96, #108 piece 1)

- [ ] **crate:** file an issue and open a PR in crate registering NuSEDS (`source = "dfo"`,
  `file_name = "nuseds_all_areas"`): canonical columns knowledge keeps, and upstream variants fingerprinted
  from the 20260601 release and the older lower-case copy, with a handler that reads both into one shape.
  The knowledge PR needs that crate release (its merge is Al's word): raise the `crate` floor in
  `DESCRIPTION` once it ships, and report it as a blocker at PR time if it has not.
- [ ] `R/nuseds_fetch.R`, `knw_nuseds_fetch()`: ckanr against the catalogue record. It finds
  `All Areas NuSEDS_<YYYYMMDD>.zip`, downloads it once to `data/nuseds/<YYYYMMDD>/` and returns the
  path, release date and md5. It refuses to overwrite a release already held with different bytes.
  Tests mock ckanr and the download, which fail by default (`code-check-r.md`, fetcher test helper).
- [ ] `R/nuseds_records.R`, `knw_nuseds_records()`: `crt_ingest()`, then one row per population,
  species and year, keyed by `FWA_WATERSHED_CDE`, `POP_ID` and `WATERBODY_ID`. It keeps the issue's
  columns and the arrival and spawn dates unaltered, and adds `evidence_kind`: `count`,
  `presence_survey`, `presence_expert`, `none_observed` or `not_inspected`. Tests use a fixture holding
  #108's Maxan cases (1988 count by walk survey; 2008 expert opinion with no method; 1986 none
  observed; not inspected).
- [ ] `scripts/0340-nuseds-build.R`: fetch, build, write the Parquet, write tracked
  `data/nuseds_release.csv` (release, zip md5, rows, fetched date), publish through `knw_publish()` with
  `inst/receipt/nuseds.yaml`, and print the Maxan chinook check against #108's measured rows
  (2026-06-01 release: 1988 50 walk, 1993 20 helicopter, 2003 present, 2008 expert; none in 1986 and
  2007). Log under `scripts/logs/nuseds/`.
- [ ] `inst/NOTICE.md`: an OGL-Canada section for NuSEDS (DFO), naming the published prefix and the
  release record. A README at the published prefix carries the attribution.
- [ ] Zotero: trash `canadaNuSEDSNewSalmon` (merge its relations into the kept item through the Web
  API). Fix the Cottonwood 2013 summary's creators so its key has no `;`.
- [x] **#31:** read `officeofthewetsuweten2013WetsuwetenTitle` p. 24 from the PDF. Add the end date
  if the source gives one. If it does not, the row's note says the end is unsourced and consumers drop
  the row. `knw_timing_read()` still passes.
- [ ] **#96:** UFRA (Swift Creek, upper Fraser mainstem) and COTR (Cottonwood system) chinook rows,
  migration and spawning at minimum, then other stages where the evidence allows. Spawning comes from
  NuSEDS: the median start of spawning to the median end across the years with dates, the year count
  in the note, cited `fisheriesandoceanscanadaNuSEDSNewSalmon`. Migration comes from the group
  library's literature, each claim checked against the PDF text, never an abstract. Notes say where a
  window rests on one source or where sources disagree. `data-raw/timing_nuseds.R` prints the derived
  windows and per-year counts to a committed log; the rows are entered by hand, as the table's others are.
- [ ] Split from #108: file "provincial fish observations and literature per stream beside the NuSEDS
  records". Its body names move 5 (#174) as where it was split from; it stays out of `planning/backlog.md`.
  Edit #108's body to say what landed and what was split.

## Phase 2: Batch 9, flow in windows (#105 Phase 1, #42 piece 1)

- [ ] Restore the published run's evidence: `PULL=TRUE Rscript scripts/0336-archive.R`, and check the
  visit tables' md5s against the CH rearing grade record's `evidence_md5`.
- [ ] **Stop rule first:** create `research/chinook_window_flow.md` with the windows (rearing 08-01 to
  09-30 on the stream; spawning 08-15 to 09-15 on the downstream river) and the stop rule, and commit
  it before any flip is computed.
- [ ] `data-raw/chinook_window_flow.R` (#105 Phase 1), on this host (`knw_db_latency_check()`; the flow
  load recorded with `knw_discharge_load()`):
  - population: CH rearing's tune population (`.tune_population()` on the published summaries);
  - window mean on `pick` (`wet_segment_monthly()` then `wet_flow_window()`) at each visit's segment,
    and at the river (`large_lfid`) each ladder rung of its walk found;
  - window / MAD spread by watershed group, at visits and at rivers;
  - flips at matched thresholds: 0.75 m³/s scaled by the median ratio at visit segments, 3 m³/s by the
    median at rivers. Readings: stream only, river only, both. Visits and CH detections, by group. The
    river reading takes the ladder rivers within 1 km: an approximation (a river smaller than the lowest
    rung is not seen), stated in the file;
  - a daily-basis check (`wet_segment_daily()` from the published parts) on the spawning window, which
    takes part months;
  - small tables to `data/tune/flow_window/` (which `0325`, `0330` and `knw_thresholds_table()` never
    read), and a log.
- [ ] `data-raw/segment_window_flow.R` (#42 piece 1): every segment in each group of the timing table
  (BULK, MORR, UFRA, COTR), each stage window, both sources. Daily-basis mean and 7-day minimum, with the
  monthly basis beside them, written to ignored `data/flow_window/segment_windows.parquet`. If
  `wet_window_stats()` does not take a day-of-year climatology for `min7`, file that in wet and report
  it rather than work around it.
- [ ] Write up `research/chinook_window_flow.md`: the plain-language walk (what the rule reads now, what
  was asked, how judged, what came back), the spread and flips by group, the verdict against the rule set
  beforehand, the flow load, the caveats, and #42's summary by group and stage. Link it from
  `research/README.md` and from #42's and #105's bodies.
- [ ] Outcome: **on a stop**, close #105 with the result, and add a sentence to
  `research/chinook_stream_size.md` and to the methodology article's limits. **On a pass**, file "#105
  Phase 2: tune on the window" (body: the walk decision, a separate window walk or an edit to the
  published one; outputs under `flow_window/`; waits on Al's word), split from move 5.
- [ ] Split from #42: file "dry-year departures at gauges" (and carrying them to segments), split from
  move 5. Edit #42's body to say what landed.

## Phase 3: Wrap-up

- [ ] `DESCRIPTION` (ckanr, and arrow if not already present; crate floor), `NEWS.md`, `_pkgdown.yml`
  reference entries, `scripts/README.md` run order (`0340`), `CLAUDE.md` layout lines (`data/nuseds/`,
  `data/nuseds_release.csv`, `data/flow_window/`, `data/tune/flow_window/`).
- [ ] Tick batches 8 and 9 in `planning/backlog.md`.

## Owed at the end (reported, done after merge)

- [ ] crate release with NuSEDS registered, if it is still unmerged when the knowledge PR opens.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- NuSEDS: unit tests on fixtures (both header variants through crate; every `evidence_kind` class).
  `0340`'s Maxan check equals #108's measured rows. The receipt round-trips through `crt_receipt_compare()`.
- Timing: `knw_timing_read()` reads the whole table. Each new row's source resolves to one group-library
  key, and each literature claim is matched to its PDF page.
- #105: the stop-rule commit predates the flip computation in `git log`. The flow load is named. The
  flips are recomputed from the tables in `data/tune/flow_window/`.
- #42: row count = segments × windows × sources. A spot check of one gauge segment (Buck Creek 08EE013)
  against wet's own vignette window.
- `devtools::test()`, `lintr` per-file diff against `origin/main`, `pkgdown::check_pkgdown()`.

