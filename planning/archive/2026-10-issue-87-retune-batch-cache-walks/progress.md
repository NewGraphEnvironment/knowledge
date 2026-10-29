# Progress — Make a retune fast enough to iterate: batch and cache the walks, parallel compare, any box with the build (#87)

## Session 2026-10-26

- Issues tidied before planning: #83 and #84 closed (their work landed in #73, PR #88; #84's run rule moved to #87's
  item 5); #91's body gained the 2026-10-26 snap probe (fresh's bulk snap, the candidate-population difference, segments
  not streams, the explicit tolerance).
- Plan-mode exploration: the walk path and the compare path read; a batched walk probed from a remote link (one query
  for 300 starts, identical to one-by-one); RPostgres's double encoding probed (exact). One Plan-agent review before the
  gate, its findings folded in (`review-plan.md`).
- Phases approved by Al as a parked baseline.
- Created branch `87-make-a-retune-fast-enough-to-iterate-bat` off main.
- Scaffolded PWF baseline from issue #87 with the approved phases.
- Next: parked 2026-10-26; resume with the command below, then "start Phase 0" (on the database's host, where the
  regraded grade tables are).

### Resume

From the repo root:

```bash
git fetch -q origin && git checkout 87-make-a-retune-fast-enough-to-iterate-bat && git pull --ff-only && git merge origin/main
```

`--ff-only` refuses when this machine's copy has commits origin lacks, so two machines holding the branch stop rather
than fork; the merge, not a rebase, brings in what landed on main while parked. The approval covered the baseline only:
the run-to-PR mandate starts at the resume instruction.

## Session 2026-10-26 (resumed)

- `/planning-init 87` re-run on the parked branch: the issue unchanged since the baseline and main not moved, so the
  parked plan was re-presented verbatim with one addition (decision 8: this machine is on a remote link, 110 ms per
  round trip, so the database-bound runs go to the host's own worktree over ssh). Approved by Al: run to the PR.
- Host worktree `~/Projects/repo/knowledge-87` created at `9475f62`; ignored inputs cloned with `cp -c` (APFS clones,
  no space) from the host's checkout, which holds #94's branch and is left alone.
- Phase 0: `data-raw/walk_batch_check.R` and `data-raw/compare_parallel_check.R` written; references are rds, because
  `write.csv` keeps 15 significant digits and the checks demand identity.

## Session 2026-10-27

- Phases 1-3 landed and reviewed (rounds 1-3, `review-round*.md`); Phase 4's first chain ran two cold `0320` at once
  (findings), so the cache was emptied and the chain rerun alone (`phase4c.sh`, then `phase4d.sh` after two lazy-promise
  fixes in the cache check, `9e56f18` and `147e961`).
- Phase 4 on the host, 02:49Z-06:47Z: cold `0320` 53.4 min (191 before); cache check passed; `0330` `GPKG=FALSE` 162.9
  min for eight keys on 6 workers; GeoPackages 14.0 min; warm `0320` (BT spawning alone) 4.1 min, 0 walks.
- The full compare's tables match the tracked ones within 2.6e-13 relative but for `config_sha` spelled short: `0330`
  now resolves CONFIG_SHA to the full commit (`38bd09f`). Regenerated tables not committed; the host worktree restored.
- Every key's grades identical per segment to 2026-10-25's (47,369,409 segments).
- Decision 5: #101 (the `default`-flags cache, measure first). Phase 5's research note, index row and CLAUDE.md paragraph.
- Next: merge origin/main (#94, a CLAUDE.md sync), Phase 6.
