# Plan review (#160), Plan agent, 2026-11-06

Spawned 12:13 UTC at the baseline (b662b0c), and returned at phase 4 (it read phases 1 to 3 as committed). No
blockers. Each finding is listed with what was done about it.

## Probes answered
1. crate accepts `none` and `recipe_id` inputs. A tolerance column must be a double; `as.numeric` makes one. crate
   rounds to k decimals rather than using a band, so a comparison of receipts alone reads `different` when a value
   lands on the other side of a rounding edge (about 13 % of rebuilds of a 2,193-row `access_check` at 6e-11 / 1e-6).
   Comparing with `tables =` re-read reads `within`. → stated in the research file.
2. Nothing reads grade receipt inputs by the old names (0320, promotion and the archive read only `grades_md5`).
3. `0299` → `knw_publish()` is equivalent: the published v1 and v2 manifests carry `schema`, and the JSON output is
   the same.
4. Archive: a build without a receipt keeps its id; restore needs no change.
5. `0310`'s receipt is placed and fed correctly; the zones zip stays on disk.

## Gaps
1. `0299` held the evidence receipt to three tables while publishing five from that directory. → **Fixed**:
   `.knw_evidence_recipe_id(tables =)`; `0299` passes every evidence table it publishes.
2. A missing evidence receipt silently fell back to the md5 even where the build's ledger names one. → **Fixed**: the
   grade receipt reads the record's evidence ledger. A ledger that names a receipt now requires that receipt, with the
   same `recipe_id`.
3. Restore refuses an `evidence_receipt.json` that is present with other bytes: a receipt carries its write time, so
   two builds of byte-identical tables have different receipts. → **Kept as intended.** The two receipts describe two
   builds, so restore refuses rather than write one build's receipt over another's, as it already does for any file
   (move it aside to restore). Documented, along with the point that each `0310` build has its own `evidence_id`.
4. A failed receipt write left new tables and no ledger. → **Fixed**: `0310` writes its ledger under the `_refused`
   name with the error, then stops (the convention for any new refusal).
5. `0299` loaded the package before the PULL branch. → **Fixed**: it now loads after it.
6. The archive should check the receipt before storing it. → **Already in phase 5** (`.knw_evidence_recipe_id()`).
7. Input files were hashed at the end of the run rather than when read. → **Fixed**: the rds files, MANIFEST.md5 and
   tracked tables are hashed when `0310` reads them.
8. Docs: `scripts/README.md`. → **Done in phase 6.** NEWS is written by `/gh-pr-merge`.

## Ordering
- 6904c3e changed `grade.yaml` before its writer, which b3c8201 fixed. History is left as is; only a bisect would
  meet it.
- Phase 4 cannot be checked on real data (0299 reads `data/fdis/derived` only). → It is proved by `test-publish.R`
  and the scratch-clone smoke run, as stated in the archive README.

## Assumptions
- The "one ulp" line in `evidence.yaml` was wrong for the per-group table (its values are smaller). → **Fixed**: the
  comment and the gate decision now rest on the measured moves and #158's tolerance.
- `link_configs` fell back to link's version alone where link has no `RemoteSha`. → **Fixed**: it is the sha256 of the
  installed link's `configs/default` files, with the version in the context. `0310`'s header now says range and
  pooling come from the installed link.
- Grades name the evidence by its recipe, not its result. → Accepted at the gate (option a); reported to Al in the
  final summary.
- The fdis recipe records the publishing commit, not the commits behind the species tables. → Out of scope, as it is
  for 0299 today.

## Acceptance
- Phase 7's grade-receipt step uses a fixture record written against build `a`'s md5s, not a published grade record.
- Publishing v3 for real means rebuilding the default evidence, rerunning 0290/0294/0296, then retuning: written in
  the archive README.
