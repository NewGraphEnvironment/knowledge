# Findings — Run a retune on the second database (#158)

## Issue context

**If we do it:** a second database is proved able to run a retune end to end, so species work can run there while the host's database serves other work, starting with chinook rearing and then every other key. **If we never do:** the second database holds the same build but nothing has run on it, so the first real run there is also its test, and a failure partway through is found at the cost of that run.

## Problem

A second database now holds the build the published retune (#145, run `20261104_0543`) read: link's `fresh_default` (run `20261103_163715-269b585a`) and `fresh_default_minimal` (run `20261102_203300-60ab009d`), wet's 2026-10-24 segment flows, and the walk cache, loaded as `research/database_builds.md`, "A second database", describes. The FWA, bcfishobs, CABD and PSCIS loads already matched the host's.

What has been checked there (2026-11-06):

- link's `data-raw/logs/provincial_246/verify_extra.sql` passes for both builds (241 groups each)
- `knw_build_record()` (0.4.29) reads both builds with the 2026-10-24 flow load and refuses neither
- the flow table holds the manifest's 102,790,688 rows, and exact row counts of every table read agree with the host's
- `0310`'s settle gate would pass: the newest `scripts/logs/habitat/<date>_link_settle.csv` ends `released` on run `20261103_163715-269b585a`, the run the second database's `fresh_default` holds

What has not: anything that queries the build. `knw_build_record()` passing means the build is recognised, not that `0310`, `0320`'s grading or `0330` complete there, or that they produce what the host produced.

Two facts that shape the test:

- `0310` has no `SPECIES`: one evidence build covers every species, so the evidence half of the test is the whole build, even for one key.
- The evidence build (`data/fdis/derived`) is untracked, so the second machine's copy is not the host's. The published run's outputs in `data/tune/` are tracked and are the reference for `0320`.

## The comparison is a receipt comparison (#154)

Running one build's recipe on a second database and comparing what it makes is the comparison #154 sets up for knowledge's tables: the same recipe, and per output a verdict of identical, equivalent within a declared tolerance, or different (NewGraphEnvironment/crate#43, `crt_receipt_compare()`). Neither has landed, so this issue does not wait on them. It records its results in their shape, so the results become #154's first real case.

The bar is that the same code on the same inputs gives an equivalent result, not the same bytes. What does not matter is context, never a stop: the machine, file paths, run timestamps, ledger lines that name the host or the time, row order, and float differences under a rounding (the 9.5e-11 km below came from the database summing in another order). The run stops only on a `different` in something a decision reads: the visits placed, a pick, a grade, km drawn. A `different` anywhere else is noted, given a tolerance and carried on past.



- [ ] Per output compared: the file, the verdict (and whether the bytes matched), and for `equivalent` the largest difference and the tolerance it was held to. #154 cites a precedent: one rebuild gave three byte-identical tables and a fourth differing at 9.5e-11 km
- [ ] Each tolerance used here is proposed in #154 as the declaration beside that table's writer, and each table found identical is proposed as exact
- [ ] Once `crt_receipt_compare()` ships, rerun this issue's comparisons through it and check its verdicts match the ones recorded here, which tests crate's comparison on a case whose answer is known

## Proposed

### Chinook rearing first

- [ ] `0310` on the second database, `SCHEMA=fresh_default`, into a scratch `EVIDENCE_DIR` (a tagged directory, so #136 applies: `0336` needs `fdis_sites.csv` beside it). Log the wall time
- [ ] The evidence build against the host's `data/fdis/derived`, compared on content, not bytes: rows sorted on their key, columns by name, floats to a rounding. The same visits, placements, walks and flows is the pass. Byte identity is reported where it happens but is not required
- [ ] `DEV=1 SPECIES=CH 0320` on that evidence: chinook rearing's scores, pick (`mad>=0.75|g<=0.13|Q3@D1000`) and grades equal `data/tune/CH_rear_*` from run `20261104_0543`. Grading is where the database is read per segment, so this is the step most likely to show a difference the build check cannot
- [ ] `0330` for chinook rearing: the km drawn and graded equal `data/compare/`'s for the published run
- [ ] Minutes per step logged beside the host's, so `research/database_builds.md` can say what a run costs on each

### Then every key

- [ ] `DEV=1 0320` for the run's species list on the same evidence; every key's pick and grades equal run `20261104_0543`'s
- [ ] `0330` for every key, or the keys #101's 2.9 h allows, against `data/compare/`
- [ ] `research/database_builds.md`, "A second database": replace "the load time was not measured" with the measured load (about 71 GB moved as 8 GB of dumps plus one 14-minute flow load, 66 min of moving, 2026-11-05) and record which steps were reproduced there. From then on, a run on the second database is an ordinary run

Nothing is promoted from this issue: it reproduces a published run, so a promotion would write what is already there.

Relates to #145 (the run reproduced), #154 (receipts for published tables and grades), NewGraphEnvironment/crate#43 (the receipt and its comparison), #120 (chinook rearing on every setup), #136 (tagged evidence directories), #101 (comparison run time).


## Exploration (2026-11-06, plan mode)

- Second database = this machine's default PG* database: fresh_default run 20261103_163715-269b585a (241), fresh_default_minimal 20261102_203300-60ab009d (241), flows wet 2026-10-24 b4bbc50, knw.walk_cache 6,532,230 rows, RTT 1.7 ms.
- Published run 20261104_0543: knowledge_commit 2aacd1f, link build 0.78.2 (4dfbfa49), installed link at the evidence build 0.78.1, fresh 0.52.0; archive batch 20261104T073508Z-de09068f.
- Host timings: 0310 walks 0.1 min (all cache hits); 0320 scored 22 keys in 17.8 min on 14 workers, whole run 51.7 min; CH grading 5.3 min; 0330 7 keys 50.9 min on 6 workers (CH 14.0 min) with GeoPackages 3.9 min.
- Main checkout data/fdis/build: catch.rds and fish.rds md5s match the published ledger; sites.rds does not (98d4d6dd vs 39f751b1).
- DEV=1 0320 grades nothing; knw_link_walks(cache = FALSE) walks uncached.

## Errors Encountered

| Error | Resolution |
|-------|------------|
