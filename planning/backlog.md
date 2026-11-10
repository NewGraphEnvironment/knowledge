# knowledge backlog: move order

**Verified:** 2026-11-09 against 59 open issues · **Produced by:** a read of every open issue body
(`gh issue list --state open`) and its comments; each older premise checked against `origin/main`; the state of every
peer issue a batch waits on (link, fresh, wet, cred, fwapg, flooded, floodplains, fly) · the pass's own issue, #169,
whose `planning/archive/` holds the read

How to use this file: `/backlog-sweep` writes it. Take the first move in **Moves** that is not
ticked and not **waiting**; `/planning-init <umbrella>` plans it, one phase per batch, one PR.
When the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece, files
each other piece as its own issue and lists it under `## Singles` as split from its move, where the next
`/backlog-sweep` places it: split rather than take it all in one PR.
`/gh-pr-merge` step 9c ticks the move on merge; `/compact-prep` names the next. A `NONE` from
`backlog_moves.sh next` that names batch sections means those batches have no move yet: run
`/backlog-sweep` again, the backlog is not finished.

## Moves

| move | umbrella | batches | state |
|---|---|---|---|
| - [ ] 1 | #170 | 1: evidence-build and test fixes (2 issues) | open: start here |
| - [ ] 2 | #171 | 2, 3: articles as a tuning series, a build that stalls fails fast (4 issues) | open |
| - [ ] 3 | #172 | 4, 5: Zotero library writes, new sources into the stores (5 issues) | open |
| - [ ] 4 | #173 | 6, 7: maps out of the comparison, one research page per key (4 issues) | open: after move 2, which renames the article #77 edits |
| - [ ] 5 | #174 | 8, 9: timing table and NuSEDS, flow in windows (5 issues) | open |
| - [ ] 6 | #175 | 10: location error against flow resolution (2 issues) | open |
| - [ ] 7 | #176 | 11, 12: FISS parser, gradient and PINE; layers for report repos (6 issues) | open |
| - [ ] 8 | #177 | 13: promotion cargo (4 issues) | **waiting** on Al's word for the next full retune |
| - [ ] 9 | #178 | 14, 15: access, gradient on the ground (4 issues) | **waiting** on link#434 and link#400 (override lifts, known records) and fresh#257 (fixed-window gradients) |
| - [ ] 10 | #179 | 16: library, keys and our own prose (3 issues) | open |
| - [ ] 11 | #180 | 17: report-priority pipeline for any group (3 issues) | **waiting** on Al's word to resume the report-priority work, parked 2026-09-04 |

Tracks are separate efforts, not moves: baselines (#139, `track:baselines`: #140 next), speed (`track:speed`: #85,
#101; its umbrella is in the skills repository), provenance (`track:provenance`: #162, #165; umbrella likewise) and
minimal-run (#120, `track:minimal-run`; its last task waits on link#460).

link's own pass: link#468, a backlog pass for link that carries the link issues moves 8 and 9 and the baselines and minimal-run tracks wait on, so link's backlog can place them knowing what they hold up.

## Order

| # | tracking | batch | issues | gate | why here |
|---|---|---|---:|---|---|
| 1 | #170 | evidence-build and test fixes: #136, #142 | 2 | where `fdis_sites.csv` comes from for a tagged build | #136 recurred (2026-11-05); #142 errors every full test run on an empty schema |
| 2 | #171 | articles as a tuning series: #118, #107, #156 | 3 | titles; the fwapg pin | one rename, one prose pass, one bibliography and site build over the same three articles |
| 3 | #171 | a build that stalls fails fast: #159 | 1 | close if the logs are gone and the cause stays open | the move's site build is the test |
| 4 | #172 | Zotero library writes: #168, #151, #126 | 3 | a verdict per #126 item | one sitting with Zotero and the Web API key; one store update |
| 5 | #172 | new sources into the stores: #20, #95 | 2 | whether #20's data question is still open | `0270` → `0150` → push in the same sitting |
| 6 | #173 | maps out of the comparison: #81, #77 | 2 | `GPKG` off by default; which PNGs go | both edit `R/compare_map.R` and the example-map script |
| 7 | #173 | one research page per key: #90, #64 | 2 | one template from #90's skeleton and #64's order | one generator writes every page |
| 8 | #174 | timing table and NuSEDS: #31, #96, #108 | 3 | where the NuSEDS table lives; its NOTICE row | one table and one new source |
| 9 | #174 | flow in windows: #42, #105 | 2 | #105's stop rule, set before Phase 1 | #105's Phase 1 needs #42's window means |
| 10 | #175 | location error against flow resolution: #23, #137 | 2 | cut #23 to what #137 needs (its link consumer closed) | #23's downstream-end check is #137's oracle |
| 11 | #176 | FISS parser, gradient and PINE: #7, #34, #10 | 3 | fixtures from the provincial template | one regeneration of the FISS outputs |
| 12 | #176 | layers for report repos: #17, #2, #1 | 3 | whether #2 and #1 are still wanted | #17 rolls up batch 11's outputs |
| 13 | #177 | promotion cargo: #115, #63, #148, #72 | 4 | #63's tie-break; #85 and #162 ride the same retune or not | each changes what only a promotion may |
| 14 | #178 | access: #132, #131 | 2 | decisions 1 and 2 in #131 | access classes and the access gate read the same override records |
| 15 | #178 | gradient on the ground: #70, #71 | 2 | whether `ff02` exists network-wide | both rescore chinook rearing on a gradient other than the segment's |
| 16 | #179 | library, keys and our own prose: #13, #14, #16 | 3 | the single-library policy; one store or two | #14 depends on #13; #16's store question is the same keying decision |
| 17 | #180 | report-priority pipeline for any group: #4, #15, #3 | 3 | resume or not | #4 and #15 rewrite `0161` and `0162`; #3 records the farm decision they act on |

### 1. Evidence-build and test fixes

- [ ] Carried by move 1, #170

#136 (a tagged `EVIDENCE_DIR` needs `fdis_sites.csv` copied by hand, and `minimal_network_check.R` logs only at the
end) and #142 (the live placement test errors on a `fresh_default` with no BULK BT rearing segment, or an empty one).
Touches `scripts/0310-evidence-build.R` or `R/archive.R`, `data-raw/minimal_network_check.R`,
`tests/testthat/test-link_place.R`. Gate: whether `0310` copies `fdis_sites.csv` or the archive reads it from `0240`'s
directory.

### 2. Articles as a tuning series

- [ ] Carried by move 2, #171

#118 (rename the articles as a method and case studies, narrow the register check), #107 (fold: pin upstream fwapg to
a commit upstream holds) and #156 (say "fish habitat definition", lead with life history). Touches `vignettes/`,
`_pkgdown.yml`, `README.md`, `data-raw/vignette_{chinook,method,bib}.R`, `inst/method/settings.csv` (`where` paths),
`tests/testthat/test-vignette-data.R`, `CLAUDE.md`, `research/` references. Gate: titles, whether `stream_splits` joins
the series, the fwapg pin; the fly row waits on fly's README.

### 3. A build that stalls fails fast

- [ ] Carried by move 2, #171

#159: two post-merge stalls to the timeout. The candidate is the `stream_splits` article's tile fetch, weakened by a
stall in a workflow that fetches no tiles. Touches the article's basemap call, or gq's `gq_basemap_tiles()` through its
own issue.

### 4. Zotero library writes

- [ ] Carried by move 3, #172

#168 (read the key from `ZOTERO_API_KEY_FILE`), #151 (OCR Tredger 1984, merge the duplicate strategy, correct two
items) and #126 (items with several PDFs). Touches `scripts/0153`, `scripts/0270`, a shared key helper,
`scripts/README.md`, `CLAUDE.md`, `data/sturgeon_additions.csv`. Gate: a verdict per group-library item for #126; the
personal-library items wait on #13. The writes need a person present (auto mode refused #124's merge).

### 5. New sources into the stores

- [ ] Carried by move 3, #172

#20 (the DFO threat-layer document, its cited sources and evidence rows) and #95 (the `statistics` store only: its
alignment review and partially pooled curve are each a PR of their own, filed as issues by this move's plan and listed
under `## Singles`; decided 2026-11-09). Touches `data/statistics_{members,additions}.csv`,
`data/literature_evidence.csv` (appended, audited for meaning). Gate: whether #20's data question is still open.

### 6. Maps out of the comparison

- [ ] Carried by move 4, #173

#81 (GeoPackages opt-in, a script for the few example maps, PNGs out) and #77 (scale bar and keymap on those maps).
Touches `scripts/0330-compare.R`, `R/compare_map.R`, a new example-map script, `data-raw/readme_figure.R`, a gq style.

### 7. One research page per key

- [ ] Carried by move 4, #173

#90 (generated pages under `research/tuning/`) and #64 (one template per species: the template in `research/README.md`,
then coho). #64's chinook rewrite is not here: it is #118's, in batch 2 (PR #147 moved only the method sections
behind links).
Touches `research/tuning/`, `research/README.md`, `data-raw/tuning_reports.R`, `research/fig/`.

### 8. Timing table and NuSEDS

- [ ] Carried by move 5, #174

#31 (BULK coho migration end), #96 (chinook timing for UFRA and COTR; wet's pilots that first wanted it have closed)
and #108 (NuSEDS, provincial observations and literature per stream). Touches `data/life_history_timing.csv`, a
NuSEDS fetcher in `R/`, a records table under `data/`, `inst/NOTICE.md`.

### 9. Flow in windows

- [ ] Carried by move 5, #174

#42 (window means per segment; daily flow is no longer blocked upstream) and #105 (does a seasonal window size chinook
rearing streams better than MAD). Phase 2 of #105 and anything that publishes wait on Al's word.

### 10. Location error against flow resolution

- [ ] Carried by move 6, #175

#23 (the site-visit table: join key, span, the downstream-end check) and #137 (whether one discharge per FWA segment is
fine enough). Touches `scripts/0230`/`0240`, `research/fdis_export.md`, a `research/` section on discharge resolution.

### 11. FISS parser, gradient and PINE

- [ ] Carried by move 7, #176

#7 (graduate the `.xls` parser into `R/` as tested `knw_fiss_*`), #34 (site gradient read as a fraction in `0250`) and
#10 (re-fetch PINE onto the keyed schema). Touches `R/fiss.R`, tests and fixtures, `scripts/0220`, `scripts/0250`,
`data/pine/`, `data/fiss_evidence.csv`.

### 12. Layers for report repos

- [ ] Carried by move 7, #176

#17 (cross-group no-fish-captured roll-up and a coverage layer, synced for the manifest), #2 (a snapshot pull at a
recorded commit) and #1 (a planning-method vignette). Gate: whether #17's commit stamp makes #2 unnecessary, and
whether #1 is still wanted.

### 13. Promotion cargo

- [ ] Carried by move 8, #177

#115 (the `structures` register row and the `tuned_as` note), #63 (distance to a river: its evidence per species and
the tie-break) and #148 (a test of a key's return from `not_modelled`; its second half waits on link un-pausing
rainbow trout). #72 (reopened 2026-11-09: four readers still gate on the `ref_population` literal rather than the curve's
recorded edge types: `0330`, `0325`, `0322`'s `done_rule()` and `data-raw/vignette_chinook.R`) joins because it edits
`0325` beside #63. Each changes the tracked tables or the method bundle, which only a promotion may. The speed track's
#85 and the provenance track's #162 also regrade every key: the gate decides whether they ride the same retune.

### 14. Access

- [ ] Carried by move 9, #178

#132 (where link's access gradients come from; its literature step can start before the wait clears) and #131 (tune
on link's access with its overrides, leaving each visit out of its own; waits on link#434 and link#400).

### 15. Gradient on the ground

- [ ] Carried by move 9, #178

#70 (field against modelled gradient, fixed windows, lidar; #121 compared FDIS site gradients, so step 1 still owes the
PSCIS habitat confirmations and the FISS workbook gradients, the latter after #34 in move 7; the parent reading is
#120's; windows and lidar wait on fresh#257) and #71 (distance and gradient from the floodplain edge).

### 16. Library, keys and our own prose

- [ ] Carried by move 10, #179

#13 (triage the dormant Zotero libraries), #14 (key the stores on parent item, library and version) and #16 (index our
own prose). Touches `data/zotero_key_map.csv`, `scripts/0150`–`0156`, `CLAUDE.md`'s store sentences.

### 17. Report-priority pipeline for any group

- [ ] Carried by move 11, #180

#4 (the UPCE validation, parked after Phase 3; B2–B6 unfixed) and #15 (spatial keys on the farmed corpus), which both
rewrite `0161` and `0162`, and #3 (reopened 2026-11-09: `0154`'s `farmed` column is whether a report yielded rows, not the farm/skip
decision and its reason, which #3 asked to record; from that decision, the farm target list as a query over the tags,
and the flag on table-dense reports that were skipped, which `0154` takes from the same proxy).

## Singles

- #51: age-0 length against degree-days, its own analysis of FDIS lengths and station temperatures
- #76: licences of tracked data, a reading of terms of use ending in `inst/NOTICE.md`
- #130: switches `0150` to cred's WAL-aware read; blocked on cred#45
- #33: BT spawning; only Track 3 is left, and it needs the Williston redd layer on the network
- #11: a one-off read of the North Thompson fish-passage reports

## Closed and transferred

- #68: closed: done in 9f4b21bd (#73's PR): the gradient ladder runs 3 to 30 % for every species, republished since
- #48: closed: done in PR #50; the gate's refusal of an abstract row once a PDF arrives needs no work
- #80: closed: superseded by #141 (the pick from the flow start) and #73 (the wetland door); the open decision with
  link on flow numbers, and the articles' section comparing the two starting points, moved to #139
- #8: transferred to the skills repository, where the skill lives
