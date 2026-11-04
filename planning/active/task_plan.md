# Task: Promote the retune on link's new provincial default build (#145, its last item)

Al, 2026-11-04: "full candidate 0320 (grades) and 0330, run on the database's own host, then RUN=<run> 0335 to
promote." The build is run `20261103_163715-269b585a` (link 0.78.2) in the database on this machine (m4,
`PGSERVICE=fresh_local`). The first part of #145 is archived in
`planning/archive/2026-11-issue-145-retune-new-default-build/`.

## Decided

- Rainbow trout (Al, 2026-11-04, "Retire it on this build"): the build models neither rainbow trout nor kokanee
  (`access_rb` and `access_ko` empty on every segment). A species link does not model on the build is written
  `not_modelled` (no fit, no grades); the promotion replaces the published RB and KO keys with that status, and
  `thresholds.csv` keeps their rows with that status and no values.
- The promotion needs `data/fdis/derived` to hold this build's evidence: re-settle under the default name and rebuild
  it with a plain `0310`. The published evidence's three tables are in the bucket archive (batch
  `20261030T205416Z-8892d5cd`); the whole directory is copied to `data/fdis/derived_published_20261017` (ignored).
- Work continues on the #145 branch (PR #146); the PR then closes #145.

## Phase 1: not_modelled
- [x] Failing test: `knw_tune_run(modelled = )` writes `not_modelled` for both stages of a species outside it.
- [x] `knw_tune_run()` takes `modelled`; `.knw_no_fit` gains `not_modelled`; 0320 passes the species with any
      access value in the evidence; docs (roxygen, 0320 header).
- [x] Tests, document, lint; commit.

## Phase 2: the build's evidence as the default
- [x] `0300` untagged on `fresh_default` (released), then a plain `0310` into `data/fdis/derived`; md5s equal the
      tagged build's (same build, same code).

## Phase 3: the candidate
- [ ] Full `0320` (all species; smoke gates, grades) on this host.
- [ ] `0330 TUNE_DIR=data/tune/candidate/<run>` on this host.

## Phase 4: promote
- [ ] `RUN=<run> DRY=1 0335`, then `RUN=<run> 0335` (Zotero running for the bibliography).
- [ ] The pins and prose a promotion moves, by hand: `test-tune_repick.R`, `test-vignette-data.R`, the articles'
      inline checks, `research/` prose that quotes the published run; full test suite.

## Phase 5: review and close
- [ ] `/code-check branch` over the new commits; archive; PR #146 body updated to close #145.
