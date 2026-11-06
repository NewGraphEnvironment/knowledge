# Branch review, round 3 (#160)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows and evidence blocks skipped. Rules that
  stand alone, Security, Spreadsheets: headings only; none applies.
- code-check-r.md, by heading, full section read (10 of 117): "Read-back shape must match write-back shape";
  "`on.exit()` at a script's top level never fires"; "`$` on a list partial-matches, so a longer sibling key answers
  for a missing one"; "A value compared as `::text` in SQL has PostgreSQL's spelling, not R's"; "`identical()` on two
  reader results tests the reader, not the file"; "CSV whitespace: `trim_ws` and `strip.white` do not do what the name
  suggests"; "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent"; "Postgres row
  order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it";
  "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never
  fires"; "`tryCatch()` nests its handlers, so a `stop()` in one is caught by a later one". 107 not read: their tools
  or shapes are not in the diff.
- code-check-shell.md: none of 70 read (no shell in the diff; `system2()` is the R rule above).
- code-check-spatial.md: none of 94 read (no spatial code changed).

Probes run (scratchpad only, no database, no S3): crate round-trips `recipe$inputs$evidence` in both forms so
`identical()` against the R list holds; crate hashes a config file by content under its key (two paths, one
recipe_id); `crt_table_fingerprint()` of `visits_link`'s 18 non-ASCII rows read by `read.csv` is the same under
`en_US.UTF-8`, `C` and `ISO8859-1`; link's `default` bundle has no `extends` and no file outside its directory;
RPostgres' `dbConnect()` sets `timezone = "UTC"`, so the parent table's `built_at::text` does not move with the
client; the two tracked builds (`derived_receipt_a`/`_b`) share one recipe_id, so the hydrologic zones zip does not
move per download.

## Findings

- **[fragile]** scripts/0310-evidence-build.R:276 (`parent_setting <- .knw_parent_note(pv)`), R/parent_read.R:127 —
  with `PARENT=TRUE` the recipe's `parent` setting is the parent table's provenance line, which begins with
  `pv$schema` (the `SCHEMA` the build was given) and carries `pv$minimal_schema`. A schema name is a location, and
  CLAUDE.md says a provincial schema is renamed after its run (`fresh_default` -> `fresh_default_<date>`), which is
  why the receipt names link's build by `run_uid` and not by schema. So a rebuild of the same build after the rename,
  or on a database whose schemas are named otherwise (#158's second database), is another recipe_id with every input
  and table unchanged: every grade on it reads "other evidence" and is regraded, and crate's comparison of the two
  receipts refuses on the recipe. The `PARENT_DIR` branch two lines down drops the directory and keeps basenames and
  md5s, so the two branches disagree about whether a location is identity. (0320's `.knw_parent_held()` already
  compares the same line, so a renamed schema's parent is refused there today; the receipt makes the name part of
  every grade's input as well.) The run ids, `built_at`, link sha and config hash identify the table without it.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile]** scripts/0299-fdis-publish.R:72-90 (PULL=TRUE), with R/evidence_receipt.R:95-98 — round 2's fix for a
  stray receipt left by a restore landed in `knw_archive_pull()` only. 0299's PULL is the other restore into
  `data/fdis/derived`: for v3 it writes `visits_link.csv`, `visits_species.csv`, `walks.csv`,
  `bcfishobs_fdis_match.csv` and `access_check.csv` from Parquet (arrow's bytes, never 0310's), refusing each CSV that
  exists, so the user moves 0310's tables aside as told, and `evidence_receipt.json`, which is not a table, stays.
  Every reader then refuses with `.knw_evidence_recipe_id()`'s remedy "rebuild the evidence (scripts/0310)"; and the
  newest ledger names that receipt, so `.knw_receipt_evidence()` refuses too even once it is moved. In
  `knw_archive_plan()` the same message is reached by any stray receipt beside a correct build, and running the
  remedy there replaces the very evidence the run's grades name, which is lost if it was not yet archived. Live once v3
  is published (v2's PULL writes no visit table). The pull could refuse an `evidence_receipt.json` in `dir_in` for v3
  as the archive pull does, and the message could name the stray-receipt case's own remedy (move it aside).
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"; code-check.md "A guard's scope,
    escape hatches, and remedies"

- **[fragile]** scripts/0299-fdis-publish.R:173-188 — v3's receipt names the whole set's evidence input as the
  recipe_id of 0310's receipt, held only against the five 0310 tables the set publishes. Its other fingerprinted
  tables, `bt_use_visits`, `ch_mad_visits`, `ch_rule_visits`, `ch_rule_walks` (0290/0294/0296, from whatever
  `visits_link.csv` was in the directory when they ran) and `fdis_sites` (0240), carry no record of the build they were
  made from, and nothing checks it. After a 0310 rebuild without reruns of 0290/0294/0296, a v3 publish writes a
  public receipt saying those tables were made from evidence X when they were made from W. The plan review put the
  *commit* half of this out of scope; the evidence half is round 2's mechanism (the receipt describes more files than
  the reader holds it to), so it is listed for triage rather than re-argued. A cheap hold: refuse when any of the four
  species tables is older than `visits_link.csv`, or have their scripts ledger `visits_link`'s md5.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## Mechanism

**The shared assumption:** whatever sits beside the described files when an identity is computed or checked belongs
to them, and a set of names checked in one place is the set described in another. Rounds 1-4 were each one form of
it: (1) an install path beside the configs' content entered the identity; (2) the keep-check held a kept grade to the
three-md5 list while its receipt named a recipe; (3) the receipt's write time entered the archive's id; (4) a receipt
left from another build sat beside restored tables. Underneath, four lists only happen to agree: the tables a receipt
describes (`evidence.yaml`, 7), the tables each reader holds it to (3 for grades and the archive, 5 for 0299), the
files the archive stores (6, of which 3 overlap), and the files each restore path writes.

Every place in the branch the mechanism reaches:

| place | identity from / compared against | verdict |
|---|---|---|
| `.knw_receipt_code()` (evidence, fdis) | the checkout's full commit, version, dirty over R/scripts/inst, read at the start | holds (a rebuild at another commit is another recipe: accepted) |
| `.knw_receipt_config_files()` | content of settings.csv and the walk, keyed by source-tree path | holds (probed: two paths, one id) |
| `link_configs` (`.knw_sha256_files(root =)`) | file content and paths relative to the bundle; radix order | holds (round 1 fix; bundle complete) |
| `fiss_workbooks` (`.knw_sha256_files()`, no root) | paths relative to the repo root, from `list.files("data")` | holds while 0310 runs from the root, which it requires |
| `fdis_export`, `fdis_sites/catch/fish`, species codes, size breaks, `fiss_evidence`, hydrologic zones | sha256 of the bytes read, taken as read | holds (zip stable across downloads, measured) |
| `link_build`, `flow` | run_uid; wet's table comment | holds (comment is #154's accepted input) |
| `parent` setting, PARENT=TRUE | provenance line with schema names | **does not hold** (finding 1) |
| `parent` setting, PARENT_DIR | basenames and md5s | holds |
| species, q_grid, sources, snap limits | resolved values, arrays kept with `I()` | holds |
| result tables (`.knw_receipt_csv_tables`) | CSV text; km as numbers | holds (encoding-independent, probed) |
| result parts | basenames and bytes | holds |
| context | run ids, rel paths, time | holds (never identity) |
| 0310 receipt vs its tables | removed before the first table, written last; refused ledger on failure | holds |
| `.knw_evidence_recipe_id()` | receipt's part sha256 vs the files, per table the caller names | holds for those tables; its remedy is wrong for a stray (finding 2) |
| `.knw_receipt_evidence()` ledger check | newest ledger's `evidence_receipt` row vs the receipt present | holds; skipped when the ledger path is absent (0320 requires one; data-raw passes a moved one) |
| 0320 `evidence_input` and keep-check | input read at start vs kept receipt's `recipe$inputs$evidence` | holds (round 2 fix; round-trip probed) |
| `knw_grade_receipt_write()` | md5s vs record, then the dir's receipt and the record's ledger | holds |
| promotion (`knw_tune_promote`) | kept keys by `evidence_md5` and `evidence_ledger`, not the receipts' evidence input | holds through `evidence_ledger`, except a same-day rebuild at another commit (one ledger path), where by-key promotion can leave receipts naming two recipes; accepted class (archive/md5s) |
| archive id (`knw_archive_plan`) | MANIFEST of table md5s, receipt outside it | holds (round 3 fix) |
| archive receipt row | receipt bytes, checked against the 3 visit tables | holds; the 4 other tables it describes are not archived, so a restored build's receipt covers absent files, which 0299 refuses (not silent) |
| archive pull, build without receipt | refuses a receipt in the target before writing | holds (round 4 fix) |
| archive pull, build with receipt | last archived receipt for the id | accepted |
| archive pull, receipt present with other bytes | refused mid-loop after tables are written | accepted; readers refuse the mix |
| 0299 PULL | writes visit tables, ignores the receipt | **does not hold** for v3 (finding 2) |
| 0299 v3 receipt evidence input | 0310's receipt held to 5 tables; 6 more tables unheld | **does not hold** (finding 3) |
| knw_publish receipt on republish | rewritten on every publish, tables unchanged | holds as the manifest does (pre-existing manifest behaviour) |
| 0325 sets | `version_id = evidence_md5` | accepted |
| three-name visit-table list | hard-coded in 0320, `.knw_receipt_evidence`, `.knw_evidence_recipe_id` default, archive `ev_md5` | agree today; four copies of one contract |

## Triage (main session)
1. The `parent` setting carried schema names (`.knw_parent_note()`): real. The setting now names the parent table by
   its build time, both runs, link's commit and config hash, without schema names.
2. 0299's PULL left a stray evidence receipt: real, and the other caller of round 2's fix (so the loop ends on an
   enumeration, not a quiet round). The pull refuses an `evidence_receipt.json` in the directory when it would write
   any of 0310's tables, before writing anything. `.knw_evidence_recipe_id()`'s remedy now names both causes: a
   receipt left beside restored or copied tables (move it aside) or a table replaced after it (rebuild).
3. 0299's v3 receipt does not tie the species tables or fdis_sites to the evidence build: accepted, as before #160;
   0299's header now says to rerun them after a 0310 rebuild before publishing.

## Enumeration (main session, by grep over R/, scripts/, data-raw/; ends the loop)
The mechanism: something beside the described files, or carrying a location, a time or another run's state, entering
an identity or standing in for the files. The candidate set, each checked:
- Writers of the seven tables the evidence receipt describes: `0310` only (scripts/0310-evidence-build.R:450-468),
  after it unlinks the receipt (:447). Holds.
- Paths restoring tables into an evidence directory: `knw_archive_pull()` (refuses a stray receipt, round 2) and
  `0299` PULL (refuses one, round 3). Copies by hand are covered by the refusal's remedy text. Holds.
- Readers of `evidence_receipt.json`: `knw_archive_plan()` (holds it to the visit tables), `.knw_receipt_evidence()`
  (grades, and `0320` at its start; holds it to the visit tables and the ledger), `0299` (holds it to every evidence
  table it publishes), `data-raw/evidence_receipt_compare.R` (a check). Holds.
- Inputs to the evidence recipe: code (commit, version, dirty); config files (keyed `inst/...`, hashed by content);
  settings (species, river sizes, sources, snap limits, parent: no schema names since this round); inputs (link's run
  uid, the flow load's comment, link's configs by relative path, the FDIS manifest, the 0230 rds files, the tracked
  tables, the workbooks by repo-relative path, the zones zip, bcfishobs `none`). None carries a location or a time.
  Holds.
- Inputs to the grade and fdis recipes: link run, flow load, evidence (recipe_id or md5s); version, evidence, export
  manifest. Holds.
- The three visit-table names, hard-coded in `.knw_receipt_evidence()`, `.knw_evidence_recipe_id()`'s default,
  `knw_archive_plan()`'s `ev_md5` and `0320`'s `evidence_md5s`: the same three in the same order. Holds.
