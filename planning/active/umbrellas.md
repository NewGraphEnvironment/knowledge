<!-- Each umbrella below is filed as written, labelled `umbrella`, after the go. Common footer in every body:
"Backlog: planning/backlog.md, move <m>. Plan it with `/planning-init <this issue>`: one phase per batch, one PR." -->

=====================================================================
## Move 1 — Evidence builds and tests: a tagged build archives like the default, a live test skips an empty schema
=====================================================================
**If we do it:** a build under a tagged `EVIDENCE_DIR` archives and checks with the default build's commands, and a full test run against an empty or partial `fresh_default` reads as untested rather than broken. **If we never do:** every run on another schema needs `fdis_sites.csv` copied in by hand (met on 2026-11-03 and again on 2026-11-05), and every test run on such a database reports an error unrelated to the code.

### Batch 1. Evidence-build and test fixes
- **Why here:** both bite every run off the published build, and #136 has recurred since it was filed. One test-suite run and one live check on the database's host verify both.
- **Touches:** `scripts/0310-evidence-build.R` or `R/archive.R`, `data-raw/minimal_network_check.R`, `tests/testthat/test-link_place.R`.
- **Decided at the gate:** whether `0310` copies `fdis_sites.csv` into a tagged directory or the archive reads it from where `0240` writes it.

| issue | title |
|---|---|
| #136 | A tagged EVIDENCE_DIR is a second-class evidence build |
| #142 | Live placement test errors when fresh_default holds no BULK BT rearing segment |

=====================================================================
## Move 2 — Public articles: a tuning series, one vocabulary, a build that cannot stall
=====================================================================
**If we do it:** the site's articles read as a method and its case studies, say "fish habitat definition" as the website and README do, cite upstream fwapg at a commit upstream holds, and a build that stalls fetching tiles fails fast. **If we never do:** the series stays titled by its first species and by `link`, the README and articles drift from the website's words, and a stalled build holds a runner to its timeout (twice so far).

### Batch 2. Articles as a tuning series
- **Why here:** #118 is the hub (named by four open issues); #107 is already folded into it, and #156 rewrites the same three articles' prose, so one rename, one prose pass, one bibliography regeneration and one site build cover all three.
- **Touches:** `vignettes/*.Rmd` and `.bib` (renamed), `_pkgdown.yml`, `README.md`, `data-raw/vignette_{chinook,method,bib}.R`, `inst/method/settings.csv` (`where` paths only), `tests/testthat/test-vignette-data.R`, `CLAUDE.md`, `research/` references.
- **Decided at the gate:** the titles (#118's table); whether `stream_splits` joins the series as `tuning-…`; the fwapg pin (an upstream tag, or no version); the fly row of the ecosystem table waits on fly's own README change.

| issue | title |
|---|---|
| #118 | Retitle the articles as a tuning series: the method, then a case study per species and stage |
| #107 | Upstream fwapg citation pins a commit that exists only in New Graph's fork |
| #156 | README and articles: say fish habitat definitions, and lead with life history |

### Batch 3. A build that stalls fails fast
- **Why here:** the move's own site build is the test; the candidate cause is the `stream_splits` article's tile fetch.
- **Touches:** the article's basemap call; possibly gq's `gq_basemap_tiles()` (its own issue there if the timeout belongs in gq).
- **Decided at the gate:** if the logs are gone and the cause stays open, record that and close.

| issue | title |
|---|---|
| #159 | Post-merge CI stalled to its timeout once: find whether the article's Esri tile fetch can hang a build |

=====================================================================
## Move 3 — Zotero: fix what the group library holds, and bring new sources into the stores
=====================================================================
**If we do it:** the Zotero scripts run with the key in a file, the library's duplicates, mistitled items and multi-PDF items are settled in one sitting, and the DFO threat-layer document and a statistics store reach the stores. **If we never do:** `0270 --collection sturgeon` stays unsafe to re-run, the citation audit keeps reading map sheets, and the method has no statistics store to be read against.

### Batch 4. Library writes
- **Why here:** one sitting with Zotero running and the Web API key; #168 makes the key easy to supply first; #151 and #126 share CLAUDE.md's duplicate-merge recipe and end in one store update.
- **Touches:** `scripts/0153-reports-to-zotero.py`, `scripts/0270-habitat-collection-build.py` (one shared key helper), `scripts/README.md`, `CLAUDE.md`, `data/sturgeon_additions.csv`.
- **Decided at the gate:** a verdict per item for #126's 25 group-library items (merge, keep one, or split out); the personal-library items wait on #13. The Web API writes need a person present: auto mode refused #124's merge.

| issue | title |
|---|---|
| #168 | Zotero scripts: read the API key from a file when ZOTERO_API_KEY is unset |
| #151 | Sturgeon store follow-ups: OCR Tredger 1984, merge the duplicate watershed strategy, correct two items |
| #126 | Zotero items with several PDFs: merge appendices and report parts into one file, drop the copies |

### Batch 5. New sources into the stores
- **Why here:** both run `0270` → `0150` build → push (and `0280` for #20's rows) in the same Zotero sitting as batch 4.
- **Touches:** `data/statistics_{members,additions}.csv`, `data/literature_evidence.csv` (appended rows, audited for meaning), `research/bayesian_alignment.md`, the `habitat_modelling` and new `statistics` stores.
- **Decided at the gate:** whether #95's partially pooled curve experiment is in this move or filed on its own; whether #20's data-availability question is still open.

| issue | title |
|---|---|
| #20 | DFO CSAS 2025/013 (Iacarella et al.): Fraser flow and temperature threat layers on the FWA |
| #95 | Read the method against Statistical Rethinking: a statistics store, an alignment review, and a partially pooled curve |

=====================================================================
## Move 4 — Comparison maps out of the run, and one generated research page per key
=====================================================================
**If we do it:** a comparison run writes tables (and GeoPackages only when asked), the few example maps carry a scale bar and keymap, and each species × stage has one generated page in one template. **If we never do:** comparisons keep spending hours on GeoPackages nobody opens, the maps cannot be placed by a stranger, and the research files stay eight shapes with hand-copied numbers and stale figures.

### Batch 6. Maps out of the comparison
- **Why here:** both edit `R/compare_map.R` and the example-map script #81 creates; #77's scale bar and keymap apply to exactly those maps.
- **Touches:** `scripts/0330-compare.R` (`GPKG` opt-in), `R/compare_map.R`, a new example-map script, `data-raw/readme_figure.R`, a gq style for the GeoPackage.
- **Decided at the gate:** `GPKG` off by default; which `research/fig/` PNGs no file shows.

| issue | title |
|---|---|
| #81 | Separate map making from the comparison: GeoPackages for QGIS, a few scripted examples |
| #77 | knw_compare_map: no scale bar or keymap on the static maps |

### Batch 7. One research page per key
- **Why here:** #90's fixed skeleton and #64's per-species order are one template; one generator writes every page from the tables.
- **Touches:** `research/tuning/`, `research/README.md`, `data-raw/tuning_reports.R`, `research/fig/` (removals).
- **Decided at the gate:** the one template (reconcile #90's headings with #64's order); which keys get pages now.

| issue | title |
|---|---|
| #90 | Tuning reports in research/tuning/, generated from the tables, with their figures |
| #64 | One template per species: life-history prior, evidence, recommendation, what it draws, left open |

Runs after move 2, which renames the article #77 turns the scale bar on in.

=====================================================================
## Move 5 — Chinook flow windows and timing
=====================================================================
**If we do it:** life-stage timing comes from cited sources and NuSEDS for more groups, and we learn whether flow in the months chinook use a stream sizes it better than MAD. **If we never do:** the timing table stays two groups with one open row, each repo keeps its own NuSEDS copy, and the CH rearing rule stays on MAD untested.

### Batch 8. Timing table and NuSEDS
- **Why here:** one table (`data/life_history_timing.csv`) and one new source; NuSEDS spawn dates are #96's main input.
- **Touches:** `data/life_history_timing.csv`, a new NuSEDS fetcher in `R/`, a records table under `data/`, `inst/NOTICE.md` (a new tracked source needs its row).
- **Decided at the gate:** where the NuSEDS table lives and what it publishes; NuSEDS's licence read from its catalogue record.

| issue | title |
|---|---|
| #31 | BULK coho migration has no end date |
| #96 | Chinook timing for UFRA (Swift Creek) and COTR |
| #108 | Salmon records per stream: NuSEDS, provincial fish observations and literature, in one table |

### Batch 9. Flow in windows
- **Why here:** #105's Phase 1 needs #42's window mean per segment; both read wet's monthly segment flows on the database's host.
- **Touches:** `research/chinook_window_flow.md`, `research/chinook_stream_size.md`, a `data-raw/` script; nothing under `data/tune/` outside `flow_window/`.
- **Decided at the gate:** #105's stop rule, set before Phase 1 runs; Phase 2 and anything that publishes wait on Al's word. Daily flow (#42's 7-day minimum) is no longer blocked upstream.

| issue | title |
|---|---|
| #42 | Flow in Chinook life-stage windows on FWA segments |
| #105 | Chinook rearing: does flow in a seasonal window size streams better than MAD? |

=====================================================================
## Move 6 — Where records sit: the site-visit table, and whether one flow per segment is fine enough
=====================================================================
**If we do it:** each FDIS visit joins its bcfishobs records with a span on the network, and we know whether discharge resolution adds error beyond where records already sit. **If we never do:** location error and flow-resolution error stay unmeasured beside each other.

### Batch 10. Location error against flow resolution
- **Why here:** #23's downstream-end check is the oracle #137's second question needs.
- **Touches:** `scripts/0230`/`0240`, `research/fdis_export.md`, a new `research/` section on discharge resolution.
- **Decided at the gate:** #23's original consumer (a link issue) has closed, so scope #23 to what #137 needs.

| issue | title |
|---|---|
| #23 | Site-visit table joining FDIS catch, effort, fished span and measured habitat to bcfishobs records |
| #137 | Is one discharge value per FWA segment accurate enough to tune on? |

=====================================================================
## Move 7 — FISS workbooks: a tested parser, percent gradients, and the no-fish layer delivered to report repos
=====================================================================
**If we do it:** the workbook parser is tested `knw_fiss_*` code, site gradients read in percent, PINE joins the keyed schema, and the no-fish-captured layer and its coverage reach report repos by manifest. **If we never do:** the parser stays a 500-line script, `gradient_pct` reads 2.5 % as 0.025 %, and the layer stays a per-group file copied by hand.

### Batch 11. Parser, gradient and PINE
- **Why here:** one regeneration of the FISS outputs: graduate the parser, fix the gradient in `0250`, re-fetch PINE through it, diff once.
- **Touches:** `R/fiss.R` (new), `tests/testthat/test-fiss.R` and fixtures, `scripts/0220`, `scripts/0250`, `data/pine/`, `data/fiss_evidence.csv`.
- **Decided at the gate:** fixture workbooks built from the provincial template.

| issue | title |
|---|---|
| #7 | Graduate the FISS .xls parser into the package as tested knw_fiss_* functions |
| #34 | FISS workbook site gradient is read as a fraction, not a percent |
| #10 | Re-fetch PINE so its fetch log carries idx and xls_url |

### Batch 12. Layers for report repos
- **Why here:** #17 rolls up batch 11's outputs; #2 and #1 are the other two things report repos would consume.
- **Touches:** `data/nfc.gpkg`, `data/nfc_coverage.gpkg`, an S3 sync, `R/` (a snapshot helper if kept), a planning-method vignette.
- **Decided at the gate:** whether #17's SHA stamped in the GeoPackage makes #2 unnecessary; whether #1 is still wanted.

| issue | title |
|---|---|
| #17 | Cross-group NFC roll-up plus a coverage layer, synced so rtj can load it by manifest |
| #2 | Snapshot consumer: pull a layer at a recorded knowledge SHA into a report repo |
| #1 | Planning-method vignette for reports to port as an appendix |

=====================================================================
## Move 8 — Rides the next retune and promotion (waiting)
=====================================================================
**If we do it:** the next promotion carries the register row #112 owed, a measured verdict on the near-a-river exception for every species, and a tested path for rainbow trout's return. **If we never do:** the register misstates the comparison's default, the coho and rainbow tie-break stays unstated, and the first `not_modelled` key to return is also its path's first run.

**Waiting** on Al's word for the next full retune. The walk changes in the speed and provenance tracks (#85, #162) regrade every key too, so the gate decides whether they ride the same retune.

### Batch 13. Promotion cargo
- **Why here:** each changes the tracked tables or the method bundle, which only a promotion may.
- **Touches:** `inst/method/settings.csv`, `scripts/0325-publish.R` / `knw_thresholds_table()` (an `exception_evidence` column), `research/*_tuned.md`, `tests/testthat/test-tune_promote.R`.
- **Decided at the gate:** #63's tie-break (keep the exception as a departure, or recommend it where the curve test supports it); #148's second half waits on link un-pausing rainbow trout.

| issue | title |
|---|---|
| #115 | Settings register: STRUCTURES row and the tuned_as note, at the next method bundle rebuild |
| #63 | Distance to a river: measure its evidence per species and decide the tie-break on it |
| #148 | Bring rainbow trout rearing back when link models it |

=====================================================================
## Move 9 — Access gradients and gradient on the ground (waiting)
=====================================================================
**If we do it:** link's access gradients are traced to their sources and checked against records, the tuning population follows link's access with leave-one-out, and gradient is read over fixed windows and against the floodplain edge. **If we never do:** every tuning rests on inherited access classes, excludes resident populations above barriers, and reads a gradient whose length depends on the catch.

**Waiting** on link's override table (link#434), its known-record rule (link#400) and fresh's fixed-window gradients (fresh#257). #132's literature step can start before them.

### Batch 14. Access
| issue | title |
|---|---|
| #132 | Where link's access gradients come from, and whether they hold |
| #131 | Tune on link's access with its overrides, leaving each visit out of its own |

### Batch 15. Gradient on the ground
| issue | title |
|---|---|
| #70 | Gradient on the ground: field-measured against the Freshwater Atlas, fixed-window gradients, then lidar |
| #71 | Distance and gradient from the floodplain edge (ff02, ff04) for small streams near large rivers |

=====================================================================
## Move 10 — Report corpus: one library, stable keys, and our own prose indexed
=====================================================================
**If we do it:** one central Zotero library, store documents keyed on parent item and library, and our own research and archive READMEs searchable beside other people's reports. **If we never do:** 331 citation keys keep warning wherever no library is named, store documents join three incompatible ways, and our own findings stay greppable one repo at a time.

### Batch 16. Library, keys, own prose
- **Why here:** #14 depends on #13's single-library decision, and #16's one-store-or-two question is the same keying decision; one store rebuild serves all three.
- **Touches:** `data/zotero_key_map.csv`, `scripts/0150`–`0156`, `CLAUDE.md`'s store sentences, new store manifests.
- **Decided at the gate:** the single-library policy; one store or a separate one for our own prose; whether triage of the 290 personal-library items is in scope.

| issue | title |
|---|---|
| #13 | Triage what the dormant Zotero libraries hold that the central one does not, then retire them |
| #14 | Key the ragnar corpus on stable Zotero identity: parent item key, library, version |
| #16 | Index our own prose: report bodies, method notes, research/, PWF archive READMEs |

=====================================================================
## Move 11 — Report-priority pipeline for any group (waiting)
=====================================================================
**If we do it:** the harvest → farm → reconcile pipeline works for a group with no PSCIS assessments, and farmed rows carry a reach on the network. **If we never do:** the pipeline silently returns nothing for unassessed groups, and the corpus stays keyed to a watershed group.

**Waiting** on Al's word to resume the report-priority work, parked on 2026-09-04.

### Batch 17. Generalize and key by reach
- **Why here:** both rewrite `0161` and `0162` (#4's B3, B4 and B6; #15's snap and reach columns).
| issue | title |
|---|---|
| #4 | Validate the fieldwork-prep pipeline end-to-end on an unharvested group (UPCE) |
| #15 | Spatial keys on the farmed corpus: blue_line_key + measure, and a reach dossier |
