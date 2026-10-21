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
- Phase 7: README credits fwapg, bcfishobs and bcfishpass to Simon Norris (Hillcrest Geographics), in link README's words for bcfishpass
- Phase 6: article rewritten. Words (prose outside YAML and chunks, inline `r` as one word,
  `scratchpad wc_article.sh`, the awk/sed pipeline in this file's history): 2,434 before, 1,295 after, against a
  1,400 target; 11 sections before, 7 plus References after. The floor was the 1.96 table's two framing sentences and
  the surface table's reading, which the outline keeps. Built with `pkgdown::build_article()` after installing the
  branch: 12 reference entries (stub bib), no `???`, the widget draws in Chrome (9,839 rendered features, no console
  errors), page 5.5 MB (742 KB gzipped) plus 11 MB of shared widget libraries; `rmarkdown::render()` takes the static
  path. Citation keys for the new Zotero items are `TODOKEY_*` placeholders until Phase 1 runs; the group library has
  no FDIS item, so Phase 1 adds one
- Phase 7: link#346's body gains the 1.96 item (link is public and knowledge private, so it names no knowledge issue)
- Phase 1: filed through the Web API (12 items, one subcollection, three merges); keys after the desktop synced. `vignette_bib.R` writes 12 entries, deterministic across two runs; site and package renders show 12 references, versions as "Version 0.66.0"

## Session 2026-10-21 (UTC)

- Code-check over the branch: three rounds, ten findings fixed, closed on an enumeration (findings.md, "Code-check").
  The unpushed branch's history was rewritten once (round 2) so no commit carries a home path or credential-store
  wording; `public_sweep.py commits` empty.
- Final: 189 tests, 0 failed, 0 skipped; `check_pkgdown()` clean; the article 1,303 words, 6 lints (19 on main);
  site build shows the 1.96 table, 12 references and the widget. Issue body unchanged since planning; main has not
  moved.
