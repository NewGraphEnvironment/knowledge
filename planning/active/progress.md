# Progress — Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

## Session 2026-11-02

- Plan-mode exploration — phases approved by user (parked)
- Created branch `120-tune-chinook-rearing-on-minimal-segments` off origin/main (`6b7c31d`, v0.4.22)
- Scaffolded PWF baseline from issue #120 with approved phases; the Plan review ran in plan mode and its findings
  are folded in (`review-plan.md`)
- Probes (read-only, 2026-11-02 ~15:10–15:50 UTC): m1's database (51 ms from here) holds `fresh_default`
  (run 20261023, link 0.68.0), `fresh_default_20261017` and `knw`, no `zz415_*`; m4's local fwapg
  (`PGSERVICE=fresh_local`, 2.6 ms) holds `zz415_default` and `zz415_minimal` (4 groups each, `date_end` set,
  tokens on `log`: `cut-full-top`/`cut-min`, `acc-v5`, `grad-seg`, `q-fwapg`, none NULL), `fresh_default_minimal`
  (empty), `fresh_pretest_default_minimal`, wet's flows (2026-10-15 build, `scenario historical` comment), cabd,
  bcfishobs, no `knw.walk_cache`; the local `data/fdis/derived` md5s equal the published grade record's
  `evidence_md5`
- Next: parked 2026-11-02; paste the block under ### Resume into a fresh session

### Resume

```
Continue knowledge#120 from its parked PWF baseline. Repo ~/Projects/repo/knowledge, branch `120-tune-chinook-rearing-on-minimal-segments`,
parked 2026-11-02 by `/planning-init knowledge#120 park`, branched from origin/main at 6b7c31d.
Run these in order, and stop at the first that fails; each failure means what it says:

cd ~/Projects/repo/knowledge && git fetch -q origin
git worktree list | grep -F '[120-tune-chinook-rearing-on-minimal-segments]' || echo none   # a path printed: that tree holds the branch; cd to it and skip the checkout
git branch --show-current; git status --porcelain --untracked-files=no   # another branch with changes, or one another session may be on: do not check out here; git worktree add ../knowledge-120 120-tune-chinook-rearing-on-minimal-segments and cd there
git checkout 120-tune-chinook-rearing-on-minimal-segments   # fails: the branch is not on origin
git pull --ff-only   # fails: this machine has commits origin lacks; resume where they were made
git merge origin/main   # a conflict: main moved meanwhile; resolve it, commit, and go on

Then read planning/active/task_plan.md, findings.md, progress.md and review-plan.md if present.
The gate decisions, the measurements and the Plan-agent review are already folded in:
do not re-plan and do not re-ask them.
Start Phase 1 and run every phase to the PR (/code-check branch, /planning-archive,
/gh-pr-push). This message is the resume instruction that starts the run-to-PR
mandate; the merge stays with me.
```

## Session 2026-11-02 (resumed)

- Resumed from the parked baseline; branch current with origin/main
- Phase 1: `knw_build_record()` reads link's tokens from `<schema>.log` (every row; a NULL beside a value refused).
  Mutation: the `log_recompute` read put back fails 4 expectations of `test-build_record.R`. Live on m4:
  `zz415_default` reads `cut-full-top.acc-v5.grad-seg.q-fwapg`, `zz415_minimal` `cut-min.acc-v5.grad-seg.q-fwapg`,
  m4's `fresh_default` (0.68.6) none
- Phase 1: `EVIDENCE_DIR` on `0310` (tagged ledger `<date>_evidence_build_ledger-<base>.csv`, `evidence_dir` first row,
  refused twin tagged alike), `0320` (+ `DEV_DIR`, summary `evidence_dir`; the pick report's published directory is
  now named, not derived by a regex that `DEV_DIR=data/tune/dev_<x>` would have mangled), `0330` (the summaries'
  directory, refused unless its md5s are the curves'), `segment_gradient_check.R` (tagged, never overwritten log);
  internal `.knw_ledger_path()`/`.knw_evidence_ledger()` in `R/run_ledger.R` with tests
- Phase 2: `0300` `SCHEMA`/`POLL_MIN` (schema and poll interval on every row, tagged log name); `0310` `SETTLE=`,
  `settle_schema`/`settle_override` ledger rows, link floor 0.78.1, `schema_species` from `<schema>.log.species`,
  `access_check.csv` per group, `PARENT_DIR` through `knw_parent_join()` (new, exported, tested); `0320`
  `GRADIENT=parent_gradient` (`grad_parent/`), `MIN_WSG`/`FOLDS` in the summary; `knw_tune_promote()` refuses other
  floors (mutation: guard removed fails 3 expectations). link 0.78.1 installed here from `../link` fast-forwarded to
  origin/main `552f43d6`
- Phase 3 (m4, `PGSERVICE=fresh_local`, link 0.78.1 installed, fresh 0.52.0; 16:46–17:25 UTC):
  - `POLL_MIN=1 0300` released both schemas (runs `415_recompute_default`, `415_recompute_minimal`; link 0.78.0
    `6bf9ca06`); `0310` on each (`EVIDENCE_DIR=data/fdis/derived_zz415_{default,minimal}`, `PARENT_DIR` on the full):
    2,082 visits placed on both, 43,625 dropped as outside the four groups; walks 0.4 min cold, then 5,724 of 5,724
    pairs from the cache
  - `minimal_network_check.R`: same visits, line and measure; walks and species tables byte-identical; access km equal
    per group; access codes differ only 1 → 2 (never across zero); every visit's parent is its minimal segment, none
    on a straddling full segment; 1,175 visits read a different gradient on the full network
  - premise (`segment_gradient_check.R`, stream branch): full 52.0 % of fish visits start a segment against 5.8 % of
    empty ones, minimal 2.8 % against 1.5 %; median lengths 298/458 m against 742/742 m
  - `DEV=1 0320`, `MIN_WSG=4 FOLDS=4`, nine species, 0.2 min each: BT_rear the one fitted key (underpowered, 4
    groups); every other key `too_few_groups`, `no_response` or `no_stream_rule`; minimal and full-parent BT_rear
    tables and curves byte-identical; full picks the same rule from a narrower region; Atlas line picks g<=0.20
  - CH grading refused by the smoke gate at `MIN_WSG=3 FOLDS=3` (coef 20.0, limit 5); BT_rear graded and compared
    on both schemas (4.3 and 4.1 min; 0330 0.6 and 0.7 min): stored vs regenerated default 0 km in every group
  - `site_gradient_check.R` on both four-group builds: Spearman 0.696 on both; CH flips at 0.11 on 8.5 % (minimal)
    against 8.7 % (full)
  - Ignored artefacts (md5): derived_zz415_default visits_link c8b7248d, visits_species 9e19cc57, walks 0c21cba6,
    access_check 7345cf6e; derived_zz415_minimal visits_link b265204d, visits_species 9e19cc57, walks 0c21cba6,
    access_check 6c5fbd35; BT_rear_tune.csv dev_zz415_minimal ba760b83, dev_zz415_default f4306afe, grad_parent
    ba760b83, grad_fwa 9fa8cfc2; candidates 20261102_172001/2 (CH, refused smoke), 20261102_173001/2 (BT): grades
    8c2b6fd8 / a1a7f466, compare 59c6ee45 / da8c2c3e, GeoPackages ce62dfa1 / c9decbd8. Logs copied to
    `scripts/logs/habitat/minimal_network_120/`
  - `.gitignore` gains `data/tune/dev_*/`; `0320`'s `DEV_DIR` takes `data/tune/dev` or `data/tune/dev_<name>` only
