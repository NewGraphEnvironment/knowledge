# Plan review of the #154 baseline (Plan agent, delivered 2026-11-06 ~04:00 UTC)

Written here by the session from the agent's reply (the Plan type cannot write). Triage in the last column.

| id | class | finding | triage |
|----|-------|---------|--------|
| B1 | Blocker | tracked grade receipts would carry the database host's name unless `publish = TRUE` | taken: `knw_grade_receipt_write()` always passes `publish = TRUE`; test asserts no `context.host` |
| B2 | Blocker | knowledge's commit is short in 0320 and 0325; crate needs 40 hex + dirty; link has no dirty flag; `run_link_sha` can hold several commits | taken: `.knw_git_state()` reads the full commit with 0320's dirty scope; link enters only as the `link_build` input (its run uid), its version and commit(s) in `context` |
| G1 | Gap | 0320 deletes a receipt at each pass start (`caches`), keeps the table; unfit keys unlink grades and record only | taken: receipt added to `caches` and to the unfit unlink; the receipt's context carries the record's `grades_md5`, so the keep path keeps a receipt that names the checked record, and writes one from the table's two columns when missing |
| G2 | Gap | summaries must describe the written (rounded) table; the writer needs the key's spec, seed; Inf prior | taken: 0320 builds the written frame once and passes it; spec from `r$score$spec`; Inf written as a string |
| G3 | Gap | published-set declarations must list the inputs and settings the writer passes; prov does not map onto crate's kinds | taken: published sets declare `link_build`, `flow`, `evidence` (the grades' `evidence_md5` as `version_id`, since 0325 holds no evidence files) and `tune_run` |
| G4 | Gap | the "setting has a register row or is a run argument" test cannot be expressed; names differ | taken: test dropped; `settings.csv` is not edited (O1) |
| G5 | Gap | a required receipt would break archiving every pre-receipt run; `source_md5` by position | taken: receipt archived when present, appended last |
| G6 | Gap | promotion carries the receipt unchecked | taken: promotion checks a present receipt names the record's `grades_md5`; absence allowed (runs before #154) |
| G7 | Gap | upload order untestable through a local `system2` closure | taken: uploads go through `.knw_aws()`; `recipe`/`keys` default `NULL` |
| G8 | Gap | `crt_receipt_validate()` needs jsonvalidate | taken: Suggests + `skip_if_not_installed()` |
| G9 | Gap | config files named; vector settings shape; `.gitattributes` yaml line unneeded | taken: named (done); yaml line removed |
| O1 | Ordering | editing `settings.csv` moves the method bundle's pinned md5 | taken: `settings.csv` not edited |
| O2 | Ordering | revising tolerances after #158 makes earlier receipts compare `different` (a tolerance difference refuses) | taken into the docs and the owed item: compare across a revision with a `keys` register override, said where the tolerances are declared |
| O3 | Ordering | stale facts: crate 0.12.0 released and installed; 7 grade tables, not 22 | taken: plan corrected |
| A1 | Assumption | hashing `settings.csv` hashes documentation | kept: the issue names it; any edit to it is also a new commit, which `recipe.code` already refuses, so it adds no new way to differ |
| A2 | Assumption | parts as `record` make byte-different grades `identical` | taken: `warn` instead (the difference is listed); docs say identical means pick and summaries equal for a grade |
| A3 | Assumption | crate mechanics verified | — |
| A4 | Assumption | no reader trips on the new `.json` | — |
| A5 | Assumption | the host needs crate with `file =` installed | taken: owed item |
| S1 | Scope | per-field register test repeats crate's own | taken: scoped to knowledge's overrides and tolerances, plus every override naming a register field |
| S2 | Scope | 0299's visit tables and 0310's evidence build (the 9.5e-11 km `access_check` case) get no receipt | taken: deferred to a follow-up issue, filed and named in the PR; the issue's two named writers are this branch's scope |
