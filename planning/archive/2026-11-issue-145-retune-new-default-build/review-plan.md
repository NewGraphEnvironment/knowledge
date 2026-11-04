# Plan review (#145), Plan agent, 2026-11-04 UTC

Delivered as reply text (the Plan type cannot write); written here by the session. Disposition follows each point.

- **Gap, fallback provenance:** a fallback over a `log` holding several runs passes and mixes SHAs. -> Fallback only
  when `log` holds exactly one run; otherwise refuse, naming the runs. Probed every link schema on both databases:
  the proofs (`zz415_*`, `zz440_default`, `zz326_*`, `zz396_*`) hold one `log` run each.
- **Gap, fail toward pass:** a set-aside run newer than the kept one (link wrote after the recompute) passes with a
  note. -> Refuse a set-aside run whose latest `date_start` is at or after the kept rows' earliest. Refuses link's
  test schema `zz432_pre` (`432_clear` after the build) and `fresh_smoke369b` (a 2099 fixture row), both rightly.
- **Gap:** rows with a NULL `run_uid` show as "NA". -> Named "(no run id)". The published `fresh_default_20261017`
  holds 5 such rows (2026-08-06 to 2026-10-12) beside its run's 241; its line now names them as set aside.
- **Gap:** the helper reads `log` unconditionally. -> Refused with a clear message when the table is absent.
- **Gap:** 0310 calls the helper a second time. -> The record carries the helper's result (`rec$log`); 0310 reads it.
- **Tests missing** (two-run log with no match; newer set-aside run); the older mocks fell through. -> Added; mocks
  made explicit.
- **Assumption, the 0320 hazard is overstated:** 0320 reads link's thresholds at every SHA and stops unless they
  agree (0320:252-261), so a mixed `link_sha` refuses or reads identical text. The real effects: a foreign SHA and a
  `0.68.0;0.78.2` version in the grade record and `knw_thresholds_table()`, and `data-raw/segment_gradient_check.R`
  reading thresholds at `shas[1]` unchecked. -> Plan context corrected; the scoping removes the mixed value at source.
- **Gap, settle log name:** `SCHEMA=fresh_default` writes the default-named settle log, after which a plain `0310`
  would rebuild `data/fdis/derived` on the unpromoted build, and the published recipe on the 20261017 log breaks.
  -> `0300` takes `SETTLE_TAG=`, naming the log `<date>_link_settle-<tag>.csv`; this run tags `default_20261103`.
- **Ordering:** commit Phase 1 before running (0320 stamps `+dirty`). -> Done (052224b) before any run.
- **Scope:** the issue says the link question is drafted, not posted. -> The plan Al approved files an observation in
  link (our repo); noted in the PR.
- **Scope:** the ledger's fresh is 0.52.0 against the minimal build's 0.53.0; 0310 calls no fresh function. -> Said
  in the write-up.
- **Acceptance:** compare `visits_kept` and `species_pooling_md5` with the minimal ledger; name the minimal artefact
  (candidate `20261103_0838`); anchoring by `tune_anchor_check.R` on both sides; RB not modelled; PR must not close
  #145. -> Folded into Phases 2-4.
