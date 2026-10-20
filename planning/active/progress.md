# Progress — One-SE region: state it as a heuristic, publish 1.96 beside it, and give the article references (#79)

## Session 2026-10-20

- Plan-mode exploration — phases approved by user; Al: "go all phases to pr"
- Created branch `79-one-se-region-state-it-as-a-heuristic-pu` off main
- Scaffolded PWF baseline from issue #79 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) delivered; written to `planning/active/review-plan.md` and folded in
- `ZOTERO_API_KEY` is unset in the shell and in R: Phase 1 (Zotero writes) waits on it; the other phases go first
- Phase 2: `knw_tune_repick()`; at 1 SE it returns every table's `recommended`, at 1.96 the issue's column; three
  planted bugs each fail its tests. `knw_thresholds_table()` gains `rule_196`/`holds_196` (and `d_floor`, and a
  guard that the one-SE replay is the recommended rule; three more planted bugs each caught). 0325 rerun locally
  (no upload): `thresholds.csv` equals main's with the two columns removed. Expected red until Phase 5 rebuilds the
  bundle: `test-vignette-data.R`'s CH-rows md5 (the header gained two columns)
- Phase 3: the one-SE wording in four research files; `habitat_thresholds_tuned.md` gains "At 1.96 SE" (table from `knw_tune_repick()`), `chinook_rearing_tuned.md` its #57 paragraph's 1.96 pick
- Phase 5 (data): bundle rebuilt (frozen copy of the script, from the repo root). Against main's bundle: new
  `tune_all` (8 tables, 26,875 rows) and `wetland`; `thresholds` gains `rule_196`/`holds_196`, every other column's
  values identical; `meta` changes only `written`, `md5` (7 tune files added), `md5_rows`, and adds `versions`;
  `bulk_segments` gains `water`/`water_ha`, every other column identical; `bulk_water` identical. Wetland lines
  (edge 1050/1150): default 10,286.8 km, recommended 10,197.0 km, both 10,075.1 km, median grade 0.0307 under the
  recommended rule. BULK segments: 10,846 stream, 2,127 river, 2,540 wetland, 1,173 lake
- Phase 4: `knw_compare_mapgl()`. Checked in Chrome on the Bulkley: the source id `water` collided with Carto
  Voyager's own `water` layer ("Layer water already exists"), which left the basemap blank, so the ids are
  `knw_water`/`knw_seg`; mapgl 0.4.6's popup evaluator (`maplibregl.js:397`) reads only get, concat, to-string,
  to-number and number-format, so the popup fields are short display strings ("none" for missing); `format()` over
  the vector gave `3.7e-02`, so per-value `formatC(fg)`. Classes as integer codes. Bulkley segment GeoJSON 5.2 MB
  (8.3 MB with a prebuilt HTML popup per segment). Grade layer and its legend swap in through the switch.
  Planted bugs (a grey80 colour, unrounded coordinates, vector format, switch position, legend position) each fail
