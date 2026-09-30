# Task: Habitat-thresholds literature store and evidence table (CH, BT first) (#19)

## Problem

Habitat thresholds for CH and BT (spawn/rear gradient max, channel width min, MAD, lake/wetland sizes, rearing-to-spawning connection distance) are copied from bcfishpass. Nothing records why each value is what it is. link's research on the evidence for departures (NewGraphEnvironment/link#20) proposes a Zotero + ragnar workflow but has not built one; NewGraphEnvironment/link#2 is a separate store about passage, not habitat.


## What the NewGraphEnvironment group library (library 9) already holds, searched 2026-09-29

- **A habitat-modelling collection exists, but in the personal library.** It is `fisheries/habitat_modelling` in
  library 1, 35 keyed items: Kirsch, Sloat, Rosenfeld, Neuman & Newcombe, Sheer & Steel, Woll, Cooney & Holzer,
  Busch, Porter 2008/2010, Bjornn & Reiser and others. This is essentially where the bcfishpass thresholds come
  from. **All 35 have a group-library copy, but 24 of those copies have no PDF.** The PDFs sit in library 1 or in
  the old groups `habitat_modelling` (library 5) and `habitat_modelling2` (library 6).
- **Issue seed collections in library 9:** `species/chinook` 24, `species/bull_trout` 18, `Fisheries/species` 15,
  `Fisheries/temperature` 22, `skeena/wedzin_kwa_chinook` 131, plus `hydrology` and `salmon`, each of which exists
  twice in library 9. `Fisheries` is `TRXPJHQE`.
- **Relevant group items outside those collections** (keyword search on titles, 173 hits), for example:
  - richter_kolmes2005 (maximum temperature limits for CH);
  - macpherson_etal2024 (BT recovery);
  - retzer1989 (Williston spawning/rearing);
  - cope_morris2001 (Wigwam juvenile BT);
  - bilski_etal2022 (CH spawning habitat);
  - decker_hagen (juvenile CH);
  - finnegan_etal2005;
  - thorley_irvine2021.
- **211 standalone PDFs in library 9 have no parent item and so no citation key.** Several are relevant: Beamer
  rearing preferences, Gregersen non-natal CH, keeley_slaney 1996, kondolf_wolman 1993, keefer_peery 2008.
  Without a key they cannot be cited or put in a key-built store.
- **Not in any local library (1, 2, 5, 6, 9):** Rebellato et al. 2024 (the documented origin of the bcfishpass CH
  values), Montgomery et al. 1999, Isaak et al. 2015, McPhail & Baxter 1996, Rieman & McIntyre 1993,
  Dunham & Chandler 2001 and Trotter 2000. The Trotter 2019 in the library is a different work. Voss et al. 2023 is
  paywalled. Agrawal et al. is only in library 6.
- **Name clashes block `0150`.** It refuses a collection name that appears more than once anywhere in the
  database. `habitat_modelling` would clash with the personal collection, and `hydrology`/`salmon` already clash
  inside library 9.

Tools on m1: Ollama is up with `nomic-embed-text`, Zotero is running, and the API key file is present.
`cred::crd_zot_src_lookup()` finds a PDF in any library; `0150`'s `collection_keys()` needs it on the item in the
collection itself.

## Decisions (recommended defaults; approving the plan takes these)

1. **Create `Fisheries/habitat_modelling` in the group library, curated.** It holds:
   - the personal collection's 35 items (as their group copies);
   - link#284's cited keys;
   - the relevant group items found outside the seeds;
   - the gap additions.

   No `thresholds` subcollection. The evidence table is the threshold-specific layer; add a subcollection later
   only if a threshold-only store is ever wanted.
2. **The store `habitat_modelling` is built from `habitat_modelling` plus the seed collections**, so it covers
   hydrology, temperature and the Wedzin Kwa CH work without copying ~200 items into a collection named for
   modelling.
3. **Upload the missing PDFs to their group-library copies** (~24 plus link's others), from the local library 1/5/6
   copies. The group library is then self-contained, and the store rebuilds on any synced machine.
4. **Re-parent relevant standalone PDFs:** create a parent item (CrossRef metadata where there is a DOI) only where
   no keyed copy already exists. The rest of the 211 are out of scope and counted in `findings.md`.
5. **Timing:** add evidence rows (variable `timing`). Fill `source` in `data/life_history_timing.csv` only for
   unsourced rows where a quote supports that window. Dates are not changed here.
6. **One table, `data/literature_evidence.csv`**, beside `fdis_evidence.csv` / `fiss_evidence.csv`. Columns:
   - `species_code`, `life_stage` (`knw_timing_stages()` plus `access`), `life_history_form` (CH
     `stream_type`/`ocean_type`; BT `resident`/`fluvial`/`adfluvial`; else NA);
   - `variable` (gradient, channel_width, discharge, lake_area, wetland_area, bridge_distance, temperature,
     substrate, timing), `parameter` (the link parameter it bears on, e.g. `spawn_gradient_max`,
     `cluster_bridge_distance`, else NA), `bound`;
   - `value_min`, `value_max` (character; `MM-DD` for timing), `unit` (width says bankfull/wetted/unspecified),
     `kind` (link's vocabulary plus `none` = "searched, nothing found");
   - `region`, `citation_key`, `page`, `quote`, `note`.

## Phase 1: Issue body, reader (tests first), store-script scoping
- [x] Edit #19's body:
  - link#284's `literature.md` is the primary seed;
  - the collection is `Fisheries/habitat_modelling`;
  - the group-library inventory above;
  - the decisions.
- [x] `pkg/tests/testthat/test-literature.R`:
  - filters by species and variable;
  - refuses: an off-vocabulary variable, stage, form or kind; a non-numeric value on a non-timing row; a bad
    `MM-DD` on a timing row; `value_min > value_max`; missing columns; a blank quote or key (except `kind = none`);
  - a zero-row filter returns a typed empty frame.
- [x] `pkg/R/literature.R`: `knw_literature_read(path, species_code = NULL, variable = NULL)` plus the vocabulary
  functions. Same style as `knw_timing_read()`. Roxygen with a runnable `@examples`, `document()`, and the
  DESCRIPTION line.
- [x] `scripts/0150-store.R`: scope `collection_keys()` to the group library (`groups.groupID = 4733734`), and
  accept an 8-character collection key as well as a name. This resolves the `habitat_modelling` clash with library
  1 and the duplicate `hydrology`/`salmon`. Duplicates within the group library are still refused by name.

## Phase 2: Zotero collection (group library)
- [x] `scripts/0270-habitat-collection-build.py`: the Web API pattern from `0153` (key file, group 4733734). It is
  idempotent and has a `--dry-run` that writes nothing. It:
  - creates `Fisheries/habitat_modelling` if absent;
  - adds the curated items by group item key: the personal collection's 35 group copies, link's keys that have
    group copies, and the listed topical items;
  - uploads the local PDF to each member whose group copy has none (skip where present; Zotero dedups by md5).
- [x] Re-parent the relevant standalone group PDFs (Decision 4) and add those items to the collection. *(Revised: the
  named ones were keyed items already and were added as members. The 3 relevant true standalones got a new parent
  plus a PDF copy, and the standalone was left in place; see findings.md and review-plan.md G2.)*
- [x] Add the 7 gap references: CrossRef metadata where there is a DOI, the OA PDF (checked with `file`), and no
  hand-set citation keys. Relaunch Zotero so BBT assigns keys, and wait for sync. Anything unobtainable is listed in
  `findings.md`, not worked around.
- [x] Log to `scripts/logs/habitat/`: members by source, PDFs uploaded, re-parented items, gap items and their keys.

## Phase 3: Store
- [ ] *(From plan review, Ord1)* After sync, check a copy of the local DB: collection member count = 87, and every
  member with a server PDF has its file on disk.
- [ ] `ACTION=build STORE=habitat_modelling COLLECTIONS="habitat_modelling,chinook,bull_trout,species,temperature,wedzin_kwa_chinook,X29BX4U8,W4425VK5,545K8HP4"`.
  Record the key count and the members with no PDF.
- [ ] Spot-query it (a gradient, a width, a temperature and a timing question) and confirm the hits come from the
  expected keys.
- [ ] `ACTION=push CONFIRM=TRUE`, then a verified connect confirms the md5 matches the manifest.

## Phase 4: Evidence table
- [ ] *(From plan review, Ord4)* Write `scripts/0280-literature-verify.R` first, then port rows against it.
- [ ] Port link's `literature.md` §0–§2 into `data/literature_evidence.csv`, keeping quotes verbatim. Its "none
  found" findings become `kind = none` rows.
- [ ] Add the template CSV's CH rows where the key resolves and they are not already covered.
- [ ] Gap-fill, searching the group library first (store query plus full text), with one row per parameter at
  minimum (a value or a `none` row saying what was searched):
  - discharge (MAD);
  - lake/wetland size;
  - bridge distance;
  - temperature by stage;
  - substrate;
  - BT resident/fluvial/adfluvial and CH stream-/ocean-type.

  Read-only agents, 2–3 at once split by variable group, may locate candidates. Every row passes the gate below.
- [ ] *(From plan review, Ord2)* Final rebuild and push of the store after gap-fill, so every evidence key is in it.
- [ ] Timing rows for CH and BT per stage; fill unsourced `life_history_timing.csv` rows per Decision 5.
- [ ] `scripts/0280-literature-verify.R`, a gate:
  - every row reads through `knw_literature_read()`;
  - every key resolves in Zotero;
  - every quote is found (whitespace- and hyphenation-normalized) in the PDF text via `crd_zot_src_lookup()` +
    `pdftotext`, and its PDF page is reported.

  A PDF with no text layer is `unverifiable`, not a failure; any other miss exits non-zero. The log goes to
  `scripts/logs/habitat/`. Test the gate by mutating one quote and watching it go red.

## Phase 5: Wiring
- [ ] `scripts/README.md`: run order plus a `0270`/`0280` section and the `0150` scoping note. `CLAUDE.md` data
  tier: add `literature_evidence.csv` and the `habitat_modelling` store.
- [ ] Comment on link#284 pointing to the table as an input, with what it adds beyond `literature.md`.

## Validation
- [ ] Tests pass; restore one validator and see its test go red
- [ ] `0280` gate green; a mutated quote goes red
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` with `Measurement` (rows by variable and kind, verified/unverifiable counts, store docs
  and chunks, PDFs uploaded) and `Evidence` (`scripts/logs/habitat/`)

