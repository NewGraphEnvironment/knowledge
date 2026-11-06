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
- Phase 6 (part): CLAUDE.md's receipt paragraph and `scripts/README.md` (0299, 0310) revised; #161's body carries the
  owed comparison. The research file waits for phase 7's verdict. Phase 7 is held: at 12:28 UTC another session was
  running #161's tie checks on this database (four active queries), and two evidence builds would load it under them.
- Full suite at 12:33 UTC: 0 failed, 0 errors, 4 skipped, 2,231 passed. Lint clean on the new files; check_pkgdown
  clean once the export was indexed.
- Phase 7 (12:48 to 13:12 UTC, after the other session's #161 check left this database): staged the published FDIS
  build in this worktree's ignored `data/fdis` (sites.rds and reconcile.csv from the 2026-10-28 staging, catch/fish and
  MANIFEST.md5 from the main checkout, md5s equal to the published ledger), ran `0310` into `derived_receipt_a` and `_b`
  (11.9 and 11.6 min). One recipe_id; six tables byte-identical; access_check at most 1.0e-10 km apart; verdict
  `equivalent` alone and re-read; a grade receipt against build a names its recipe_id. The tagged ledgers were moved
  into `scripts/logs/habitat/evidence_receipt_160/` (their receipts' context names the original path). The two
  directories (202 MB each, ignored) stay until the merge.
- `/code-check branch`: three rounds (13:14, 13:20, 13:29 UTC), plus the plan review, four spawns in all. Round 1: 2
  findings, both fixed (link configs hashed by absolute path; the keep-check kept a grade naming stale evidence).
  Round 2: 2, both fixed (the archive id moved with the receipt's bytes; a stray receipt survived a restore). Round 3:
  3, 2 fixed (schema names in the parent setting; 0299's pull, the other caller of round 2's fix), 1 accepted (the
  species tables are not tied to the evidence build, as before). Round 3's inside-a-fix finding meant the loop ended on
  an enumeration (review-round3.md): writers, restores, readers and recipe inputs around the receipt, all holding.
- Final suite 13:41 UTC: 0 failed, 0 errors, 3 skipped, 2,244 passed.
