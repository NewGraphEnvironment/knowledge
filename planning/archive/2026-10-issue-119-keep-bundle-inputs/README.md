# #119: keep the inputs a published article bundle was built from

## Outcome

Any machine with the repo, bucket credentials and the database can now rebuild the methodology bundle from about
200 MB of archived evidence, where before it needed 26 GB of ignored grade tables that existed on one machine only.
`0320` writes a tracked record beside each grade table (`<key>_grades_record.csv`: its run columns, md5, size and
rows, the run, ledger, commit and link build). The bundles pin the record rather than the table, and
`knw_tune_promote()` refuses a key whose record is missing or describes another table. `R/archive.R` and
`scripts/0336-archive.R` keep a run's grade tables (zstd -3), records, curves and segments, and its evidence build
once, in the bucket's private, now versioned `archive/knowledge/`. `data/archive_index.csv` holds every version id,
and `PULL=TRUE` restores a checkout's run by version, md5-checked. `0335` checks it can archive before moving
anything, and archives after. The published run (#92's, written 2026-10-28) was seeded from m4, the only machine
holding its tables, and the bundle was rebuilt from the archive alone. The methodology article's limits now carry
#121's site-gradient result (`R/site_gradient.R`). A run is identified by content, not name: a batch per archive
call, picked by the record and the files a checkout holds (`research/run_archive.md`). The link build of the
published run predates link's output vocabulary, so it is archived `untokened/` until NewGraphEnvironment/link#420.

## Measurement

- **Seed.** Eight grade tables, 28.1 GB, became 1.54 GB at zstd -3 on m4 in about 2 min, each round-tripped to its
  md5. Each matched the bundle's pin, and CH rearing's curve and segments matched the chinook bundle's. The archive
  holds 39 objects (3,213 MB, about 1.3 GB of it uncompressed segments); uploading from m1 took about 9 min.
- **Proof.** Two worktrees at `1e7dbb8`: one filled by hand (grade tables included), one by `PULL=TRUE 0336` alone (no
  grade tables). Their `method.rds` are identical in every element. Against the published bundle, only the four
  `meta` fields named in advance differ: `written`, `commit`, `md5` (gains seven records) and `md5_local` (loses
  seven tables). Every shared entry is equal. Tests in the restored worktree: 1752 pass, then 1802 at the branch tip.
- **Chinook bundle not rebuilt.** Rebuilt in the restored worktree, it differed only in `meta` and in
  `surface$rate`, by 1.2e-16 (a last-bit BLAS difference). It pins no grade table, so it is kept as published.
- **Site gradient (#121) in the article.** The refactored `site_gradient_check.R` log is identical over 344 lines.
  The sentence's first draft gave a 33–42 % range whose ends rested on bands of 3 and 15 sites; it was replaced by a
  pooled 37 % of 1,307.
- **Bucket.** 15 lifecycle rules, then versioning Enabled, both read back. There were 0 previous versions before
  (41 delete markers), so the rules expired nothing.
- **Review.** `/code-check branch`: five reviewer rounds (4, 6, 1, 1 and 2 findings). Rounds 2–5 each found a defect
  inside the previous fix, all on one axis: which archived batch is "the run". It ended on the enumeration of undo's
  selection in `findings.md`. Every fix has a test that fails under its mutation.

## Evidence

`planning/archive/2026-10-issue-119-keep-bundle-inputs/review-round*.md`; `data/archive_index.csv`.

## Owed

- when link has tokens for the published build, add them to its index rows (its folder is not renamed)
- delete the spare copies, on Al's word only: m4's and m1's `~/Projects/repo_aside/knowledge_seed_119/` (zst and staged tables, about 30 GB on m1), m1's `~/Projects/repo_aside/knowledge_published_inputs_20261028/`
- the next promotion archives through `0335` on whichever machine promotes (it needs bucket credentials; m4 has
  none yet)

Closed by: PR (this branch)
