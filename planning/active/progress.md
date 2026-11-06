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
