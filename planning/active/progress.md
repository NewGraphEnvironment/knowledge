# Progress — Write receipts for the evidence build and the published visit tables (#160)

## Session 2026-11-06

- Plan-mode exploration — phases approved by user (gate: one `evidence` grade input, `visits_link` exact now, the
  evidence receipt archived)
- Created branch `160-write-receipts-for-the-evidence-build-an` off origin/main (dcb7870)
- Scaffolded PWF baseline from issue #160 with approved phases
- Next: start Phase 1
- Phase 1: `evidence.yaml` and `fdis.yaml` declared; `grade.yaml`'s inputs are `[link_build, flow, evidence]`;
  `.knw_receipt_csv_tables()` reads a receipt's tables as text with only a rounded column numeric, and
  `knw_publish()` uses it. crate refuses `config_files: []`, so `fdis.yaml` omits the key (it reads as none).
  test-receipt and test-publish pass.
- Phase 2: `knw_evidence_receipt_write()` (R/evidence_receipt.R) writes `evidence_receipt.json`; `0310` checks crate and
  reads the commit state and `data/fdis/MANIFEST.md5` at the start, removes an earlier receipt before its first table,
  and writes the receipt after `access_check`, ledgering its recipe_id. The receipt block was smoke-run from the script's
  own lines on fixtures (scratchpad `smoke0310.R`); a real build is phase 7. test-evidence_receipt passes, and its
  array check goes red with the `I()` wrap removed.
- Phase 3: `.knw_receipt_evidence()` returns one `evidence` input: `.knw_evidence_recipe_id()` reads the build's
  receipt and refuses one whose visit-table sha256 are not the files' (proved by removing the check: the refusal
  test goes red); no receipt falls back to `version_id = evidence_md5`. No reader in R/, scripts/, data-raw/ or the
  vignettes read grade receipt inputs by the old names.
- Phase 4: `0299` publishes through `knw_publish()`; v3 carries a receipt (summary `visits`, renamed from `rows` in
  `fdis.yaml`), v2 none. Published manifests v1 and v2 carry `schema` on every file (read 2026-11-06), so
  `knw_publish()`'s prior check matches 0299's. Smoke-run in a scratch clone on fixture tables: v3 writes
  `receipt.json` naming the evidence recipe_id; no evidence receipt, or one whose `walks.csv` moved, is refused;
  `VERSION=v2` writes none and removes the earlier one. The full-tree clean rule for `PUBLISH` is kept.
  The fdis test's last-place move is `equivalent`, not `identical`: the Parquet's bytes move with the value.
- Phase 5: `knw_archive_plan()` appends `evidence_receipt.json` to the evidence files and MANIFEST where it exists,
  after holding it to the build's tables; a restore brings it back through the index. A build without one keeps its
  MANIFEST and id (tested).
- Plan review returned (spawned 12:13 UTC, at phase 4): no blockers; findings and what was done in
  `planning/active/review-plan.md`. Fixed: 0299 holds the evidence receipt to every evidence table it publishes; a
  ledger that names a receipt requires it (guard proved by removal); 0310 hashes inputs as read, names link's configs
  by their files' sha256, and writes a refused ledger when the receipt fails; 0299 loads the package after PULL; the
  "one ulp" claim is corrected. Kept: restore refuses a receipt present with other bytes (two builds).
