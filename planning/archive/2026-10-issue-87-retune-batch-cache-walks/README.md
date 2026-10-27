# Issue #87: make a retune fast enough to iterate

## Outcome

Grading walks 500 segments per query (`knw_link_walks(batch =)`) and keeps every walk in `knw.walk_cache`,
keyed on the flow load's and the walk code's md5s (`cache =`, `knw_discharge_load()`, `knw_walk_md5()`, a `walk_md5`
column every grade reader compares). `knw_compare_rules(workers =)` splits a key's watershed groups across connections,
each with its own scratch schema; `0330` runs keys in turn and writes the GeoPackages after (`GPKG=FALSE`,
`STAGE=gpkg`). `knw_build_record()` makes `0320` and `0330` refuse a schema built by another run before any work.
On the database's host a cold regrade of every key took 53.4 min (190.9 before), one key regraded with its walks
cached 4.1 min, and one key's recompare 4.5 to 37.1 min (BT rearing 33.4, against 143.3). The full recompare did not
get faster (162.9 min plus 14.0 of GeoPackages, against 160.1): the database's cores were the bound both ways, so
the `default`-flags cache is #101. `research/database_builds.md` holds the durable verdict.

## Measurement

The durable verdict is `research/database_builds.md`.

- Grading walk, ms per walk per worker: host one query per start 6.71 to 8.2, host batched 2.65 to 4.67, remote link
  batched 11.7 to 17.5, remote one query per start 116. Batching made grading possible from a remote link; the cold
  walk's own server cost is now most of the host's time (#85 keeps that).
- Walk cache: BT spawning read 2,681,583 of 2,681,583 walks from BT rearing's; one key regraded in 4.1 min against
  48.2. 4,459,402 walks, 1,595 MB after a full cold regrade.
- Comparison with groups on 6 workers: WCT 16.9 -> 4.4 min, CH's 20 largest groups 45.3 -> 17.0 min on the check;
  every key 4.5 to 37.1 min in the full run. The full recompare's wall time unchanged, which turned "parallel compare"
  from a whole-run speed-up into a per-key one and sent item 4 to #101.
- Identity: every batched walk identical to the one-query reference on 14 columns; 1,000 cached walks identical
  re-walked; every key's grades identical per segment to the 2026-10-25 run's (47,369,409 segments); the full
  comparison's tables within 2.6e-13 relative of the tracked ones (unordered float sums).
- Wrong turns kept: Phase 4's first launch left the first chain's R process alive (it runs as `exec/R`, and the
  leftover check looked for `Rscript`), so two cold regrades ran side by side and their timings and grade tables were
  discarded; the cache's primary key held. The cache check then failed twice on one mechanism, an RPostgres query
  passed as a lazy promise and evaluated after the outer statement was prepared on the same connection (`9e56f18`,
  `147e961`). The full comparison exposed `0330` recording a short CONFIG_SHA as spelled (`38bd09f`).

## Evidence

`scripts/logs/habitat/20261026_*` (this issue's runs, dated by the host's local date; the timed chain ran
2026-10-27 02:49Z-06:47Z), against #73's `scripts/logs/habitat/20261024_*` and `20261025_*`. Review rounds:
`review-plan.md`, `review-round1.md` to `review-round5.md` here (round 4 corrected five claims and added `0330`'s
flow-load check; round 5 clean).

## Owed

- [ ] The host's main checkout: its grade tables (2026-10-25) carry no `walk_md5`, so after the merge `0325`, `0330`
      and `data-raw/vignette_chinook.R` refuse them; copy Phase 4's regraded tables from the host worktree, or rerun
      `0320` there (warm, minutes). Then rerun `data-raw/vignette_method.R` there: #93's `method.rds` pins those
      ignored tables' md5s, so `test-vignette-data.R` fails wherever they differ from the copies it was built on.

- [ ] #86's body: "done in #87's PR"; close it.
- [ ] #85's body: the new per-walk numbers, and that it is the cold-walk fix only.
- [ ] #91's body: a task for `0310` (`SCHEMA`, `cache = "knw.walk_cache"`) when it reruns there; #92: nothing.

PR #100 (#93) merged first, so the branch merged main before its own merge (2026-10-27) and did #93's two tasks
there: `0310` reads the flow build with `knw_discharge_load()`, and the settings register needed no row, because no
argument #87 added shapes a result (a batch size and a worker count do not, and the walk cache returns identical
walks while the Atlas tables it reads and the historical flow load are unchanged); `test-settings-register.R`
passes on the merged tree. Review round 3 found the flow comment names only the scenario loaded last, so
`knw_discharge_load()` now refuses one that does not name `scenario historical` (wet#88 has the load-table need).

Closed by: the PR from branch `87-make-a-retune-fast-enough-to-iterate-bat`.
