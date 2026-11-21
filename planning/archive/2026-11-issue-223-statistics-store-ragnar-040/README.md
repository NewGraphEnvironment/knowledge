## Outcome

The `statistics` store was rebuilt under ragnar 0.4.0 and cred 0.8.0 with its whole build list, and Hedger et al. 2013
(`hedger_etal2013Improvingabundance`), which ragnar 0.3.1 could not chunk in #216, is now in it: 32 documents, 1 added,
none dropped, nothing skipped. A query about removal estimates biased low now returns Hedger in 6 of its top 8 results,
where before all 8 were Peterson et al. 2004. The store was pushed and read back from the bucket. Its manifest entry now
records `ragnar_version` and `store_schema` 0.4.0. Learned: cred records the manifest's `branch` and `head_sha` from
`git -C dirname(store)`, so the build and the push ran from a worktree of this branch on the store host, not from its
`main` checkout or through a symlinked `data/rag`. The issue comment asked for cred to be updated everywhere before the
push. That was deferred, not met: m4 still has cred 0.7.0, which #217's owed item covers.

## Measurement

- Before (bucket, pushed 2026-11-17 under cred 0.7.0): 31 documents, 11,113 chunks, 153,890,816 bytes.
- After (built 2026-11-21T19:23Z to 19:31Z, pushed 19:55Z): 32 documents, 11,182 chunks, 154,677,248 bytes, md5
  `4e2d930649fb1c1d7257781370522fca`. The 69 chunks gained match the 69 the issue measured for Hedger under 0.4.0
  in a scratch library, and the fresh 0.4.0 build did not grow the file.
- Membership was unchanged since #216 (47 distinct members, 32 with one live PDF, the same 15 left out), so the
  expected file, written before the build, predicted the result exactly.

## Evidence

`scripts/logs/rag/20261121_*statistics*` (before and after queries, expected list, rebuild and push logs);
`review-plan.md` in this directory.

Closed by: the PR from branch `223-statistics-store-rebuild-under-ragnar-0` (closes #223)
