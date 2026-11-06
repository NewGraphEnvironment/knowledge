# Plan review — #158 (Plan agent, 2026-11-06)

The reviewer's findings, condensed from its reply, each with its disposition after a probe.

## Blocker

- **B1** `SCHEMA=fresh_default 0336` without `PULL` runs archive mode (`scripts/0336-archive.R:76-99`, `R/archive.R:344-415`).
  **Confirmed, already hit**: it stopped before sending (findings, Errors). Use `DRY=1` with `SCHEMA` from now on.
- **B2** At main, 0310 writes `segment_fwa_gradient` into visits_link (`scripts/0310-evidence-build.R:286-294`, #120). The
  published table has 229 columns and lacks it, so visits_link is `different` by construction, and `evidence_md5` moves in every
  grade table, record and summary. **Confirmed.** `database_compare.R` gains an `added` field (declared columns the current code
  writes are noted and never fail; self-tested both ways) and treats `evidence_md5`, `tune_run`, `evidence_ledger` and
  `evidence_dir` as context in the summaries, records and grade tables. bytes_match is FALSE by construction for those outputs.
- **B3** The grade sample took `no_walk` rows (`R/grade_species.R:101`), and `$message` should be `$line`. **Confirmed, already fixed**
  (638f773).

## Gap

- **G1** Pin `CONFIG_SHA=e2a85938cdb5e8ec55df3d2b293ed0da5597428f` for 0330. **Adopted.**
- **G2** The smoke `previous` row reads the tracked `*_tune.csv`, which now holds run 0543's own pick, where the host read the
  2026-10-27 pick. **Expected difference**; smoke is not decision-read.
- **G3** The 0310 ledger has new rows at main (`segment_fwa_gradient_missing`, `segment_line_not_own`), context rows (`evidence_dir`,
  round trip, minutes) and live-fetched rows (`wet_manifest`, `zone_zip`). **Adopted**: check the `zone_zip` md5 before reading
  visits_link's verdict.
- **G4** The machine is a third cause beside code and database, and workers load the installed knowledge (`R/link_walks.R:149-150`).
  **Adopted as a control**: run CH through 0320 on the restored host evidence (`data/fdis/derived`, ledger
  `20261103_evidence_build_ledger.csv`). Matching tables show the machine is equivalent; its grade table then differs from the
  published one only through this database, with `evidence_md5` equal. Record `sessionInfo()`.
- **G5** Not reproduced: `grad_fwa/`, `grad_ext/`, `floodplain.csv`, GeoPackages and figures. **Listed as out of scope.**
- **G6** Set `WORKERS` explicitly (8 here, 14 on the host); the host's ledger has no total 0310 wall time. **Adopted.**
- **G7** Read the grade log's cache hit and miss counts. **Adopted.**
- **G8** Candidate tune logs named `_tune_run*.txt` in `scripts/logs/habitat/` would enter 0325's provenance. **Confirmed**
  (`scripts/0325-publish.R:54` lists non-recursively): logs go under `scripts/logs/habitat/database_second/`.
- **G9** crate 0.12.0 with `crt_receipt_compare()` is already installed, and crate PR #44 merged at 02:30 UTC. **Confirmed**: Phase 4's
  precondition is met.

## Ordering

- **O1** The build check after the pull. Done in that order.
- **O2** Never rewrite `data/fdis/derived_second` between the passes; a `2aacd1f` fallback gets its own worktree, evidence directory and
  run. **Adopted.**
- **O3** Pass 2 rewrites CH's smoke, tune, curves, summary and curve.rds. **Adopted**: compare pass 1 first and copy its CH outputs
  aside, which gives a free repeat check.
- **O4** Phase 3's 0330 runs `SPECIES=BT,CO,GR,ST,WCT` with the same `CONFIG_SHA`. **Adopted.**
- **O5** Run the cold walk check alone. **Adopted.**

## Assumption (checked by the reviewer)

A1 pass 2 reuses CH's cache and grade table; A2 a non-default EVIDENCE_DIR is accepted; A3 only 0310 uses the installed link;
A4 `walk_md5` is a code property; A5 the pull restored the right files (do not copy the main checkout's `reconcile.csv`, which differs;
it was not copied); A6 the other inputs are present; A7 the cold walk is feasible; A8 the results should not depend on the worker count
(an inference).

## Acceptance

- **C1** Each output's pass condition plus the expected differences (B2, G2, G3). **Adopted.**
- **C2** The candidate's `pick_report.csv` against `data/tune` (the published run): `same_pick` TRUE for every key. **Adopted.**
- **C3** Record cache counts, worker counts and sessionInfo. **Adopted.**
- **C4** The #136 note does not apply (0336 never runs on the candidate). **Adopted** for the issue edit.
