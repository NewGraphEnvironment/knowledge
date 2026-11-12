# Plan review — #197 (Plan agent, 2026-11-12)

Spawned 16:58 UTC after the baseline; delivered after Phase 1 landed. Findings, each probed before acting:

- **Blocker:** none. Sorting both lists in R fixes the column order of `placed`: the SELECT order comes only from
  `sp_access` and `sp_hab`, the `_stored` columns follow `sp_hab` in the re-gating loop, and every later column in
  `0310` comes from fixed keys or `knw_species()`. Every reader of `visits_link.csv` reads by name.
- **Gap 1:** `inst/receipt/evidence.yaml:13-14` also cites #197. Confirmed; comment revised (nothing hashes the file,
  `knw_receipt_keys("evidence")` still parses it).
- **Gap 2:** the run_archive line is 137, not 136. Confirmed; edited there.
- **Gap 3:** the live test should check `species_habitat` sorted and the `_stored` order. Added both (the first
  attempt's regex also matched `lake_rearing`/`wetland_rearing`; anchored).
- **Gap 4:** the offline test covers the helper and `.knw_place_sql()`, not `knw_link_place()`'s use of them. The
  live test covers that path, and it ran here and went red under the mutation.
- **`set.seed(197)`** leaks the global seed into later tests: now `withr::local_seed(197)`.
- **Assumption (wrong in the plan):** `sp_access` did not merely "happen to agree": every evidence ledger lists the
  access species in column ordinal order, never sorted (`BT;CH;CM;CO;PK;SK;ST;WCT;KO;RB;GR` 2026-10-17 to 10-27,
  `…;WCT;GR;KO;RB` from 11-03), and the published build (`20261103`) lists both groups unsorted. Confirmed by reading
  all 15 ledgers. So the next build moves both column blocks once, on any database; the prose says so.
- **Acceptance:** the next `0310` ledger reads both species lists sorted; `recipe_id` and verdicts do not move;
  `evidence_md5` moves once. Recorded in the prose and in the PR's NEWS line.
