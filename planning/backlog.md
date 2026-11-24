# knowledge backlog: move order

**Verified:** 2026-11-09 against 59 open issues · **Produced by:** a read of every open issue body
(`gh issue list --state open`) and its comments; each older premise checked against `origin/main`; the state of every
peer issue a batch waits on (link, fresh, wet, cred, fwapg, flooded, floodplains, fly) · the pass's own issue, #169,
whose `planning/archive/` holds the read

**Verified:** 2026-11-18 against 59 open issues · **Produced by:** a read of the 16 open issues the file did not name
(`gh issue list --state open`) and their comments, and of #211, split from move 4; each premise checked against
`origin/main`; the peer issues the new batches touch (cred, gq, wet, link, fresh) · link#434 and link#400, which move 9
waited on, closed 2026-11-17; link#460, the minimal-run track's last wait, closed 2026-11-13 · the table gains `lane`,
`waits on` and `model`; #115 moves from batch 13 to batch 19, which rebuilds the method bundle

**Verified:** 2026-11-19 against 69 open issues · **Produced by:** a read of the 6 open issues the file did not name
(#230, #239, #240, #241, #242, #243) and their comments; each premise checked against `origin/main` (`0340`'s documented
`tee` into a tracked log against its clean-tree check; `knw_discharge_load()` still reads the table comment;
`data-raw/timing_nuseds.R` reads the local csv for two fixed groups); wet's open work that reads the timing rows · move
16 (#244) carries #240 and #230; #243 becomes the `track:timing` umbrella; no closures

**Verified:** 2026-11-20 against 67 open issues · **Produced by:** a read of the 2 open issues the file did not name, both
filed during move 6 (#175, merged in PR #247) · the age-class and workbook-source issue split from move 6's #23 joins move 7 as batch 27 (left unplaced at move 7's gate); #246 joins the
provenance track; no closures, no new move

**Verified:** 2026-11-24 against 59 open issues · **Produced by:** a read of the 11 open issues the file did not name
(#1, #2, #14, #16, #17, #245, #248, #251, #255, #260, #261) and their comments; each premise checked against
`origin/main` f8d4b6e9 (`knw_link_flow()` writes its temporary table with no `ANALYZE`; the score cache's `spec` holds
neither the stream-size column nor the walk source; `data-raw/chinook_window_tune.R` anchors on `^## Phase 2:`; `pkg/`
no longer exists); cred's open work on store identity (#14 waits on it) and cred's `crd_store_build()`, which builds
only from Zotero keys (#16); soul's research-file check, which flagged eleven files for length: seven new issues,
#263 to #269, three files covered by #211 and its generated pages, one by #261 · batches 12 and 27, named at move 7's
gate, get sections; moves 17 to 21; #248 becomes move 17's umbrella; #17's title and body, and #2's body, rewritten
to name no private repo or project; no closures

How to use this file: `/backlog-sweep` writes it. Take the first move in **Moves** that is not
ticked and not **waiting**; `/planning-init <umbrella>` plans it, one phase per batch, one PR.
When the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and
files each other piece as its own issue, naming the move it was split from, and leaves it out of this file: the next
`/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was
split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone).
Split rather than take it all in one PR.
`/gh-pr-merge` step 9c ticks the move on merge; `/compact-prep` names the next. A `NONE` from
`backlog_moves.sh next` that names batch sections means those batches have no move yet: run
`/backlog-sweep` again, the backlog is not finished.
`next` reads only this file, so a plain `NONE` is not the end either while an open issue is named nowhere here (a
split piece, or one filed since the last pass): run `/backlog-sweep` to place it.

## Moves

| move | umbrella | batches | state | lane | waits on | model |
|---|---|---|---|---|---|---|
| - [x] 1 | #170 | 1: evidence-build and test fixes (2 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/187 | — | — | — |
| - [x] 2 | #171 | 2, 3: articles as a tuning series, a build that stalls fails fast (4 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/208 | — | — | — |
| - [x] 3 | #172 | 4, 5: Zotero library writes, new sources into the stores (5 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/189 | — | — | — |
| - [x] 4 | #173 | 6, 7: maps out of the comparison, one research page per key (4 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/212 (batch 6; batch 7 split to #211) | — | — | — |
| - [x] 5 | #174 | 8, 9: timing table and NuSEDS, flow in windows (5 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/229 | — | — | — |
| - [x] 6 | #175 | 10, 18: location error against flow resolution, the FDIS load's outputs (4 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/247 | A | — | opus |
| - [x] 7 | #176 | 11: FISS parser, gradient and PINE (3 issues; batches 12 and 27 left unplaced at the gate, recorded in #176's body) | done: https://github.com/NewGraphEnvironment/knowledge/pull/249 | B | — | opus |
| - [ ] 8 | #177 | 13, 23: promotion cargo, tuning-code fixes (4 issues) | **waiting** on Al's word for the next full retune | E | 12, 19 | opus |
| - [x] 9 | #178 | 14: fish-passage literature, the access track's first piece (1 issue) | done: https://github.com/NewGraphEnvironment/knowledge/pull/237 | C | — | fable then opus |
| - [x] 10 | #179 | 16, 22: library, keys and our own prose; OCR of the scanned PDFs (2 issues; two of batch 16's members and the rest of #13 left unplaced at the gate, recorded in #179's body) | done: https://github.com/NewGraphEnvironment/knowledge/pull/252 | C | 9 | opus |
| - [ ] 11 | #180 | 17: report-priority pipeline for any group (3 issues) | **waiting** on Al's word to resume the report-priority work, parked 2026-09-04 | C | 10 | opus |
| - [ ] 12 | #231 | 19: article wording and one method-bundle rebuild (3 issues) | open | E | — | opus |
| - [ ] 13 | #232 | 20: one research page per key (3 issues) | open | E | 10, 12, 20 | fable then opus |
| - [x] 14 | #233 | 21: window flow follow-ups (2 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/257 | G | — | fable then opus |
| - [ ] 15 | #236 | 24: PSCIS stream slope against link's gradient, the gradient track's first piece (1 issue) | open | F | — | opus |
| - [x] 16 | #244 | 25, 26: NuSEDS windows for every group, the timing track's first piece; a publish that runs as documented (2 issues) | done: https://github.com/NewGraphEnvironment/knowledge/pull/250 | H | — | opus |
| - [ ] 17 | #248 | 12: layers for report repos (3 issues) | open | I | — | opus |
| - [ ] 18 | #270 | 27: FDIS counts by age class, the workbook second source (1 issue) | open | I | 17, 20 | opus |
| - [ ] 19 | #271 | 28: link-helper temp tables, the score cache's reading (2 issues) | open | E | — | sonnet |
| - [ ] 20 | #272 | 29: research files folded into topic statements (8 issues) | open | K | — | sonnet |
| - [ ] 21 | #273 | 30: dormant Zotero libraries merged, personal library triaged (1 issue) | open: needs Al present for the Web API writes | L | — | opus |
Tracks are separate efforts, not moves: baselines (#139, `track:baselines`: #140 next), speed (`track:speed`: #85,
#101; its umbrella is in the skills repository), provenance (`track:provenance`: #162, then #246, the placement ties a rerun of `0230` meets on another database; #165 done in PR #206, #197 in PR #207; umbrella likewise) and
minimal-run (#120, `track:minimal-run`: closed 2026-11-18, its waiting setups owed in #132 and #70) and publish (#220,
`track:publish`: #219 next; its upload of `knowledge/fdis/v3` is the moment batch 18's per-pass tables can join v3
without a new version), access (#132, `track:access`: #234 first, in move 9, then #238, the records above modelled gradient barriers; #131 a member) and gradient (#70,
`track:gradient`: #235 first, in move 15; #71 a member; its windows and lidar wait on fresh#257). Move 9 split into the
two on 2026-11-18, at its gate. Timing (#243, `track:timing`, 2026-11-19): #240 first, in move 16; then #241 (Skeena
groups, the BULK and MORR chinook rows among them) and #242 (Fraser and Thompson groups), each after #240.

**Verified:** 2026-11-18, a hand edit at move 9's gate, not a sweep · **Produced by:** the gate's decision to split move
9 into the access and gradient tracks; #234 placed in batch 14 (move 9) and #235 in batch 24 (move 15, #236) by that
decision, against the header's rule that split pieces wait for the next sweep

**Verified:** 2026-11-20, a hand edit at move 7's gate (#176), not a sweep · **Produced by:** the plan's measure of batch 11
(#7, #34, #10) as one PR's work · batches 12 and 27 were left out of this file so the next sweep places them; #176's
body names the issues

link's own pass: link#468, a backlog pass for link that carries the link issues moves 8 and 9 and the baselines and minimal-run tracks wait on, so link's backlog can place them knowing what they hold up.

## Order

| # | tracking | batch | issues | gate | why here |
|---|---|---|---:|---|---|
| 1 | #170 | evidence-build and test fixes: #136, #142 | 2 | none: the archive reads `fdis_sites.csv` from `0240`'s directory (decided 2026-11-09) | #136 recurred (2026-11-05); #142 errors every full test run on an empty schema |
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
| 12 | #248 | layers for report repos: #17, #2, #1 | 3 | does #17's commit stamp make #2's helper unnecessary; is #1 still wanted; convert `average_gradient_percent` or rename it | one cross-group layer and its coverage, read through one manifest |
| 13 | #177 | promotion cargo: #63, #148, #72 | 3 | #63's tie-break; #85 and #162 ride the same retune or not | each changes what only a promotion may |
| 14 | #178 | fish-passage literature: #234 (from #132) | 1 | its own store; gradient rows with their leap and speed basis (both decided 2026-11-18) | the access track's first piece; the records review needs its literature |
| 15 | #178 | gradient on the ground: #70, #71 | 2 | split 2026-11-18: the gradient track, first piece batch 24 | — |
| 16 | #179 | library, keys and our own prose: #13 (first piece; two members left unplaced at the gate) | 1 | the single-library policy; one store or two (both decided 2026-11-21) | the policy the store keying waits on |
| 17 | #180 | report-priority pipeline for any group: #4, #15, #3 | 3 | resume or not | #4 and #15 rewrite `0161` and `0162`; #3 records the farm decision they act on |
| 18 | #175 | the FDIS load's outputs: #225, #214 | 2 | whether the per-pass tables join `fdis/v3` before its first upload (#219) | one `0230` rerun and one archive with #23 |
| 19 | #231 | article wording and one method-bundle rebuild: #201, #202, #115 | 3 | rebuild the bundle on its own now, on the database's host, or with move 8's promotion | one rebuild of `method.rds` and one blind readability pass |
| 20 | #232 | one research page per key: #211, carrying #90 and #64 | 3 | page names; where the check register lives | one generator writes every page (batch 7, split from move 4) |
| 21 | #233 | window flow follow-ups: #226, #227 | 2 | a separate window walk or the published one; which evidence directory; how much of #227 is wet's | both read the window flows and write `research/chinook_window_flow.md` |
| 22 | #179 | OCR of the scanned PDFs: #217 | 1 | none | rebuilds the five stores that hold the scans |
| 23 | #177 | tuning-code fixes: #203 | 1 | nest `honest` or rename it | the curve change regrades every key, which only a promotion publishes |
| 24 | #236 | PSCIS stream slope against link's gradient: #235 (from #70) | 1 | what `STREAM_SLOPE` measures | the gradient track's first piece, beside #121's FDIS check |
| 25 | #244 | NuSEDS windows for every group: #240 (from #243) | 1 | the mainstem rule; whether a NuSEDS window alone may become a row | the timing track's first piece; #241 and #242 start from its windows |
| 26 | #244 | a publish that runs as documented: #230 | 1 | log outside the repo then copied in, or the log directory exempt | #240 reads the published parquet; one sitting on the NuSEDS source |
| 27 | #270 | FDIS counts by age class, the workbook second source: #245 | 1 | one PR or two; age tables through `PLACE=FALSE 0230` only | follows move 7's tested FISS parser (PR #249) |
| 28 | #271 | link-helper temp tables, the score cache's reading: #255, #260 | 2 | what a cache without the new fields does | both found in #226; one live-database test run checks both |
| 29 | #272 | research files folded into topic statements: #261, #263, #264, #265, #266, #267, #268, #269 | 8 | #261's anchor; how many files per PR | one review of each file's citations and quote checks |
| 30 | #273 | dormant Zotero libraries merged, personal library triaged: #251 | 1 | the personal library's disposition; Al reviews the discards and deletes the groups | one sitting with Zotero and the Web API key |

### 1. Evidence-build and test fixes

- [x] Carried by move 1, #170 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/187)

#136 (a tagged `EVIDENCE_DIR` needs `fdis_sites.csv` copied by hand, and `minimal_network_check.R` logs only at the
end) and #142 (the live placement test errors on a `fresh_default` with no BULK BT rearing segment, or an empty one).
Touches `R/archive.R`, `scripts/0336-archive.R`, `data-raw/minimal_network_check.R`, `tests/testthat/test-link_place.R`.
Decided 2026-11-09, no gate left: the archive reads `fdis_sites.csv` from where `0240` writes it, beside `0230`'s
`sites.rds`, and holds it to the ledger's `sites.rds` before archiving; `0310` does not copy it (#170 gives the why).

### 2. Articles as a tuning series

- [x] Carried by move 2, #171 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/208)

#118 (rename the articles as a method and case studies, narrow the register check), #107 (fold: pin upstream fwapg to
a commit upstream holds) and #156 (say "fish habitat definition", lead with life history). Touches `vignettes/`,
`_pkgdown.yml`, `README.md`, `data-raw/vignette_{chinook,method,bib}.R`, `inst/method/settings.csv` (`where` paths),
`tests/testthat/test-vignette-data.R`, `CLAUDE.md`, `research/` references. Gate: titles, whether `stream_splits` joins
the series, the fwapg pin; the fly row waits on fly's README.

### 3. A build that stalls fails fast

- [x] Carried by move 2, #171 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/208)

#159: two post-merge stalls to the timeout. The candidate is the `stream_splits` article's tile fetch, weakened by a
stall in a workflow that fetches no tiles. Touches the article's basemap call, or gq's `gq_basemap_tiles()` through its
own issue.

### 4. Zotero library writes

- [x] Carried by move 3, #172 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/189)

#168 (read the key from `ZOTERO_API_KEY_FILE`), #151 (OCR Tredger 1984, merge the duplicate strategy, correct two
items) and #126 (items with several PDFs). Touches `scripts/0153`, `scripts/0270`, a shared key helper,
`scripts/README.md`, `CLAUDE.md`, `data/sturgeon_additions.csv`. Gate: a verdict per group-library item for #126; the
personal-library items wait on the personal library's triage. The writes need a person present (auto mode refused #124's merge).

### 5. New sources into the stores

- [x] Carried by move 3, #172 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/189)

#20 (the DFO threat-layer document, its cited sources and evidence rows) and #95 (the `statistics` store only: its
alignment review and partially pooled curve are each a PR of their own, filed as issues by this move's plan and left
for the next sweep to place in another move; decided 2026-11-09). Touches `data/statistics_{members,additions}.csv`,
`data/literature_evidence.csv` (appended, audited for meaning). Gate: whether #20's data question is still open.

### 6. Maps out of the comparison

- [x] Carried by move 4, #173 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/212)

#81 (GeoPackages opt-in, a script for the few example maps, PNGs out) and #77 (scale bar and keymap on those maps).
Touches `scripts/0330-compare.R`, `R/compare_map.R`, a new example-map script, `data-raw/readme_figure.R`, a gq style.

### 7. One research page per key

- [ ] Carried by move 4, #173; not done there: split to #211 (2026-11-13), which the next `/backlog-sweep` places

#90 (generated pages under `research/tuning/`) and #64 (one template per species: the template in `research/README.md`,
then coho). #64's chinook rewrite is not here: it is #118's, in batch 2 (PR #147 moved only the method sections
behind links).
Touches `research/tuning/`, `research/README.md`, `data-raw/tuning_reports.R`, `research/fig/`.

### 8. Timing table and NuSEDS

- [x] Carried by move 5, #174 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/229)

#31 (BULK coho migration end), #96 (chinook timing for UFRA and COTR; wet's pilots that first wanted it have closed)
and #108 (NuSEDS, provincial observations and literature per stream). Touches `data/life_history_timing.csv`, a
NuSEDS fetcher in `R/`, a records table under `data/`, `inst/NOTICE.md`.

### 9. Flow in windows

- [x] Carried by move 5, #174 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/229)

#42 (window means per segment; daily flow is no longer blocked upstream) and #105 (does a seasonal window size chinook
rearing streams better than MAD). Phase 2 of #105 and anything that publishes wait on Al's word.

### 10. Location error against flow resolution

- [x] Carried by move 6, #175 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/247)

#23 (the site-visit table: join key, span, the downstream-end check) and #137 (whether one discharge per FWA segment is
fine enough).

**Touches:** `scripts/0230-fdis-load.R`, `scripts/0240-fdis-evidence.R`, `research/fdis_export.md`, and a new research
file on discharge resolution

### 11. FISS parser, gradient and PINE

- [x] Carried by move 7, #176 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/249)

#7 (graduate the `.xls` parser into `R/` as tested `knw_fiss_*`), #34 (site gradient read as a fraction in `0250`) and
#10 (re-fetch PINE onto the keyed schema).

**Touches:** `R/fiss_visits.R`, `scripts/0220-fiss-xls-parse-nfc.R`, `scripts/0250-fiss-evidence.R`, `data/pine/`,
`data/fiss_evidence.csv`, and new knw_fiss files with their tests and fixtures

### 12. Layers for report repos

- [ ] Carried by move 17, #248

#17 (a cross-group roll-up of the no-fish-captured sites and a coverage layer of the groups processed, stamped with
the knowledge commit and synced to the bucket), #2 (a helper that pulls a layer at a recorded commit into a report
repo) and #1 (a planning-method vignette for reports to port as an appendix). Named at move 7's gate (#176) and
deferred there; its parent PR has merged. Owed from #176: the per-group tables carry Step 4's
`average_gradient_percent` as a fraction. #2 and #1 were written when the package lived in `pkg/` and this repo was
private. Gate: does #17's commit stamp make #2's helper unnecessary; is #1 still wanted.

**Touches:** `scripts/0220-fiss-xls-parse-nfc.R`, `data/nfc.gpkg`, `data/nfc_coverage.gpkg`, `_pkgdown.yml`, and
the per-group no-fish tables in each group's data folder, a snapshot helper in the package if #2 is kept, a
planning-method vignette if #1 is kept

### 13. Promotion cargo

- [ ] Carried by move 8, #177

#63 (distance to a river: its evidence per species and the tie-break) and #148 (a test of a key's return from `not_modelled`; its second half waits on link un-pausing
rainbow trout). #72 (reopened 2026-11-09: four readers still gate on the `ref_population` literal rather than the curve's
recorded edge types: `0330`, `0325`, `0322`'s `done_rule()` and `data-raw/vignette_chinook.R`) joins because it edits
`0325` beside #63. Each changes the tracked tables or the method bundle, which only a promotion may. The speed track's
#85 and the provenance track's #162 also regrade every key: the gate decides whether they ride the same retune. #115
(the `structures` register row) moved to batch 19 on 2026-11-18, which rebuilds the method bundle without a promotion.

**Touches:** `scripts/0325-publish.R`, `scripts/0330-compare.R`, `scripts/0322-tune-grad-extend.R`,
`data-raw/vignette_chinook.R`, `scripts/0320-tune-run.R`, `tests/testthat/test-tune_repick.R`

### 14. Fish-passage literature

- [x] Carried by move 9, #178 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/237)

#234, the access track's first piece (split from #132 at move 9's gate, 2026-11-18): the classes' lineage, a
`Fisheries/Fish Passage/passage_limits` collection and its own `fish_passage` store, `access_gradient_max` rows per species with the
leap height and burst speed behind each, audited for meaning, and `research/access_gradients.md`. #132 is now the
`track:access` umbrella; #131 is its member, no longer in this batch (link#434 and link#400, which it waited on,
closed 2026-11-17).

**Touches:** `data/passage_limits_members.csv`, `data/passage_limits_additions.csv`, `data/literature_evidence.csv`,
`R/literature.R`, `man/knw_literature_vocab.Rd`, `tests/testthat/test-literature.R`, `scripts/0280-literature-verify.R`,
`research/access_gradients.md`, `research/README.md`, `scripts/README.md`, `CLAUDE.md`

### 15. Gradient on the ground

- [x] Split 2026-11-18 at move 9's gate: #70 became the `track:gradient` umbrella with #71 a member; batch 24 (move 15,
  #236) carries its first piece

#70 (field against modelled gradient, fixed windows, lidar) and #71 (distance and gradient from the floodplain edge)
were each several PRs; the gradient track holds their order.

### 16. Library, keys and our own prose

- [x] Carried by move 10, #179 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/252)

#13 (triage the dormant Zotero libraries), its first piece: the single-library policy and a verdict on each satellite
group-library item. The other two members were left unplaced at move 10's gate (2026-11-21, recorded in #179's body),
as was the rest of #13's triage, split to its own issue.

**Touches:** `data-raw/zotero_library_triage.py`, `data/zotero_library_triage.csv`, `CLAUDE.md`, `research/zotero_libraries.md`

### 17. Report-priority pipeline for any group

- [ ] Carried by move 11, #180

#4 (the UPCE validation, parked after Phase 3; B2–B6 unfixed) and #15 (spatial keys on the farmed corpus), which both
rewrite `0161` and `0162`, and #3 (reopened 2026-11-09: `0154`'s `farmed` column is whether a report yielded rows, not the farm/skip
decision and its reason, which #3 asked to record; from that decision, the farm target list as a query over the tags,
and the flag on table-dense reports that were skipped, which `0154` takes from the same proxy).

**Touches:** `scripts/0161-priority-farm-reconcile.R`, `scripts/0162-priority-spatialize.R`, `scripts/0154-corpus-tag.R`

### 18. The FDIS load's outputs

- [x] Carried by move 6, #175 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/247)

#225 (publish the per-pass electrofishing tables the load already builds: one row per pass, one per pass and species)
and #214 (archive `fish.rds` with the build and restore it on `PULL=TRUE`, and check whether `0230` rewrites it
byte-identically). Both act on `0230`'s outputs, which #23 in batch 10 rewrites: one rerun, one archive. Gate: whether
the per-pass tables join `knowledge/fdis/v3`, which no upload has published yet (#219 owes it), or wait for a v4. A
private repo of ours has open work that would read the per-pass tables; the plan reads it before fixing their columns.

**Touches:** `scripts/0230-fdis-load.R`, `R/archive.R`, `scripts/0336-archive.R`, `scripts/0299-fdis-publish.R`,
`data/fdis_README.md`

### 19. Article wording and one method-bundle rebuild

- [ ] Carried by move 12, #231

#201 (step names, settings labels and diagrams printed from `method.rds` say "habitat definition"), #202 (define each
term before use, one name per thing, one precision per number, across the three articles) and #115 (the register's
`structures` row and the `tuned_as` note, "at the next method bundle rebuild"). All three change what
`data-raw/vignette_method.R` writes, so one rebuild carries them. Gate: rebuild on its own now, on the database's host
against the published build's evidence, or with move 8's promotion. A blind readability pass on the rendered articles
before and after checks #202.

**Touches:** `vignettes/tuning-method.Rmd`, `vignettes/tuning-chinook-rearing.Rmd`, `vignettes/tuning-stream-splits.Rmd`,
`inst/method/pipeline.csv`, `inst/method/settings.csv`, `data-raw/vignette_method.R`, `inst/vignette-data/method.rds`,
`tests/testthat/test-vignette-data.R`, `tests/testthat/test-settings-register.R`

### 20. One research page per key

- [ ] Carried by move 13, #232

#211, split from move 4's batch 7 (2026-11-13), carrying #90 and #64: the check register, the template, the generator
(`KEYS=`), chinook rearing's page, `research/tuning/README.md`'s table across the 22 keys, and #90's move of
`chinook_rearing_tuned.md`. Decided at #173's gate (2026-11-12): one template, #64's order with a plain-language walk
first. Gate: page names, and where the check register lives. Floodplain hectares wait on a promotion and are withheld
until then.

**Touches:** `research/tuning/`, `research/README.md`, `research/chinook_rearing_tuned.md`, `data-raw/tuning_reports.R`,
`inst/method/settings.csv`, `scripts/0335-promote.R`, `CLAUDE.md`, and a new check register under the method
directory

### 21. Window flow follow-ups

- [x] Carried by move 14, #233 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/257)

#226 (#105's Phase 2: score chinook rearing on window flow beside MAD, four readings, outputs only under
`data/tune/flow_window/`). The batch also held the rest of #42 (7-day minimums and dry-year departures at gauges, then
whether to carry them to segments), which move 14's plan gate split out on 2026-11-21: it is its own issue, left for
the next `/backlog-sweep` to place. Gate (answered in #233's body): a separate window walk or the published one (whose md5 moves every grade); the window
column in the published evidence build or a tagged evidence directory; and how much of #227 is wet's, which has open
work on monthly error by region and season and on donor departures at ungauged sites. Grading, comparing or publishing
a window rule waits on Al's word.

**Touches:** `R/link_walks.R`, `inst/sql/ch_dist_profile.sql`, `scripts/0310-evidence-build.R`,
`data-raw/segment_window_flow.R`, `data/flow_window/`, `data/tune/flow_window/`, `research/chinook_window_flow.md`,
`research/chinook_stream_size.md`

### 22. OCR of the scanned PDFs

- [x] Carried by move 10, #179 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/252)

#217: OCR ten group-library scans with no text layer (Bjornn & Reiser 1991 and Ford et al. 1995 among them), a
`replace` verdict for each through `0275`, then the five cred-built stores that hold them (`habitat_modelling`,
`temperature`, `flow`, `fish_passage`, `bull_trout_grayling`); cred's free-space issue on updated stores is still open,
so they are rebuilt rather than updated. `peace`, a key-named store of local copies, keeps its old scan.

**Touches:** `data/zotero_attachment_verdicts.csv`, `scripts/0275-zotero-attachments-tidy.py`, `scripts/0150-store.R`

### 23. Tuning-code fixes

- [ ] Carried by move 8, #177

#203 (from #185's review): the curve gives a held-out visit's unseen data set or era the reference level, as the scorer
does; `honest` is nested or renamed; a run stops when the scorer's no-prior fallback fires. None moves a published pick,
but the curve change regrades every key, which only a promotion publishes. Gate: nest `honest` (about five times the
scoring cost, measured on one key first) or rename and redescribe it.

**Touches:** `R/tune_curve.R`, `R/tune_score.R`, `vignettes/tuning-method.Rmd`, `inst/method/pipeline.csv`

### 24. PSCIS stream slope against link's gradient

- [ ] Carried by move 15, #236

#235, the gradient track's first piece (split from #70 at move 9's gate, 2026-11-18): `STREAM_SLOPE` from the PSCIS
assessment layer, measured at each assessed crossing, against link's segment gradient, as #121 compared the FDIS site
gradients. The habitat-confirmation layer carries no gradient field (checked 2026-11-18). Gate: what `STREAM_SLOPE`
measures.

**Touches:** `data-raw/site_gradient_check.R`, `R/pscis.R`, and a new research file for the gradient track

### 25. NuSEDS windows for every group

- [x] Carried by move 16, #244 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/250)

#240, the timing track's first piece (#243): `data-raw/timing_nuseds.R` takes groups and species as arguments (default
every group and species with dated records), reads the published `knowledge/nuseds/v1` parquet rather than the local
csv, writes the windows to a tracked log, and compares every row of `data/life_history_timing.csv` with its group's
NuSEDS window, reporting each disagreement (BULK and MORR chinook among them). Gate: a mainstem rule that holds for every
group (the script now drops the Bulkley and Morice mainstems), and whether a NuSEDS window alone may become a row where
no literature exists yet. Two open wet issues read the timing rows and rerun when they move.

**Touches:** `data-raw/timing_nuseds.R`, `data/life_history_timing.csv`, and a new tracked timing log under `scripts/logs/`

### 26. A publish that runs as documented

- [x] Carried by move 16, #244 (merged in https://github.com/NewGraphEnvironment/knowledge/pull/250)

#230: `scripts/0340-nuseds-build.R`'s documented RUN line tees into a tracked log, which `tee` truncates at launch, so
`PUBLISH=TRUE`'s clean-tree check refuses (#174's publish of `knowledge/nuseds/v1` moved the log by hand). Gate: the log
goes outside the repo and is copied in after the run (keeps the check whole), or `scripts/logs/nuseds/` is exempt.

**Touches:** `scripts/0340-nuseds-build.R`, `scripts/README.md`

### 27. FDIS counts by age class, the workbook second source

- [ ] Carried by move 18, #270

#245 (split from #23 at move 6's gate, and from move 7 at its gate): keep the export's age split in the visit and pass
counts, and class each Fish Data Submission workbook site against bcfishobs (in the export, in bcfishobs only, or
new). Gate: one PR or two; the age tables are rebuilt through `PLACE=FALSE 0230`, never a full rerun, whose placement
does not reproduce (#246); whether they join `knowledge/fdis/v3` before its first upload (#219).

**Touches:** `scripts/0230-fdis-load.R`, `R/fdis_passes.R`, `scripts/0220-fiss-xls-parse-nfc.R`,
`scripts/0250-fiss-evidence.R`, `research/fdis_export.md`

### 28. Link-helper temp tables, the score cache's reading

- [ ] Carried by move 19, #271

#255 (`ANALYZE` the temporary table `knw_link_flow()` joins to, and time the sibling helpers on two ids; results must
not move) and #260 (the score cache's `spec` gains the stream-size column and the walk source, so two readings cannot
share scores). Both found while building #226. Gate: what a cache written without the new fields does.

**Touches:** `R/link_flow.R`, `R/link_width.R`, `R/link_regulated.R`, `R/link_barrier_dnstr.R`, `R/tune_run.R`,
`R/tune_score.R`, `tests/testthat/test-link_flow.R`, `tests/testthat/test-tune_run.R`

### 29. Research files folded into topic statements

- [ ] Carried by move 20, #272

#261 (`chinook_window_flow.md`, whose verdict-rule guard in `data-raw/chinook_window_tune.R` moves with it) and the
seven files the research-file check flagged on 2026-11-24: #263 (`bayesian_alignment.md`), #264
(`bull_trout_life_history.md`), #265 (`database_builds.md`), #266 (`fdis_export.md`), #267
(`habitat_thresholds_tuned.md`), #268 (`minimal_network_tuning.md`), #269 (`rainbow_rearing_tuned.md`). Every citation
of each file is kept or updated; quotes stay verbatim and their checks are rerun. Gate: #261's anchor, and how many
files one PR takes.

**Touches:** `research/chinook_window_flow.md`, `data-raw/chinook_window_tune.R`, `research/bayesian_alignment.md`,
`research/bull_trout_life_history.md`, `research/database_builds.md`, `research/fdis_export.md`,
`research/habitat_thresholds_tuned.md`, `research/minimal_network_tuning.md`, `research/rainbow_rearing_tuned.md`,
`research/README.md`, `CLAUDE.md`

### 30. Dormant Zotero libraries merged, personal library triaged

- [ ] Carried by move 21, #273

#251, the rest of #13: carry out the 51 `merge` verdicts and attach the files the central library lacks, Al reviews
the four `discard` verdicts, triage the personal library (its several-PDF items from #126 among them), then Al deletes
the five satellite groups. Gate: whether a personal item that is only reading is discarded or kept where it is. The
Web API writes need Al present.

**Touches:** `data/zotero_library_triage.csv`, `data-raw/zotero_library_triage.py`, `research/zotero_libraries.md`,
`scripts/0270-habitat-collection-build.py`

## Singles

- #51: age-0 length against degree-days, its own analysis of FDIS lengths and station temperatures
- #76: licences of tracked data, a reading of terms of use ending in `inst/NOTICE.md`
- #130: switches `0150` to cred's WAL-aware read; blocked on cred#45
- #33: BT spawning; only Track 3 is left, and it needs the Williston redd layer on the network
- #11: a one-off read of the North Thompson fish-passage reports
- #228: salmon records per stream beside NuSEDS (the rest of #108, split from move 5); wet's open Maxan Creek article
  would read it
- #186: a partially pooled curve for WCT and CH rearing, an experiment of its own (split from move 3); relates to the
  baselines track's priors
- #199: which bull trout datasets exist and who holds them, a search that feeds #33
- #209: access requests for three restricted bull trout reports and two papers; waits on the report owners
- #210: `knw_compare_mapgl()` on gq's mapgl helpers (gq 0.24.0 has them); one function
- #223: the `statistics` store rebuilt under ragnar 0.4.0; blocked on cred#43 (which ragnar cred supports)
- #239: `knw_discharge_load()` reads wet's `discharge.wet_load`; waits until a database holding a build is reloaded by
  wet 0.4.36 or later, so the table exists there (the published build's database had none on 2026-11-16)
- #14: re-key the stores on parent item, library and version; waits on cred's open issue on document identity, then
  every store rebuilt on it (`peace` among them)
- #16: a separate store of our own prose (decided at move 10's gate, 2026-11-21); cred builds stores only from Zotero
  keys, so its gate opens a cred issue for plain files or builds the store with ragnar directly

## Closed and transferred

- #68: closed: done in 9f4b21bd (#73's PR): the gradient ladder runs 3 to 30 % for every species, republished since
- #48: closed: done in PR #50; the gate's refusal of an abstract row once a PDF arrives needs no work
- #80: closed: superseded by #141 (the pick from the flow start) and #73 (the wetland door); the open decision with
  link on flow numbers, and the articles' section comparing the two starting points, moved to #139
- #8: transferred to the skills repository, where the skill lives
