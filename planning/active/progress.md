# Progress — Keep the inputs a published article bundle was built from, so any machine can rebuild it (#119)

## Session 2026-10-30

- Plan-mode exploration — phases approved by Al, parked (baseline only)
- Gate decisions (Al): versioning on with expiry by prefix; untokened builds under `tune/<key>/untokened/<run_uid>/`;
  version ids in the run index, not the record; seed grade tables compressed on m4 and uploaded from here
- Created branch `119-keep-the-inputs-a-published-article-bund` off origin/main
- Scaffolded PWF baseline from issue #119 with approved phases; plan review in `review-plan.md`
- Next: parked 2026-10-30; resume with the command below, then "start Phase 1"

### Resume

```bash
cd /Users/airvine/Projects/repo/knowledge && git fetch -q origin && git checkout 119-keep-the-inputs-a-published-article-bund && git pull --ff-only && git merge origin/main
```

## Session 2026-10-30 (resumed)

- A second `/planning-init 119` gate missed this branch and was answered differently; Al chose to resume this parked
  plan, adding the link token issue (Phase 2) and #121's article item (Phase 5). Merged origin/main (ef6d75f).
- Next: Phase 1
- Phase 1 landed: `R/grade_record.R` (write, read, check), `knw_build_record()` tokens (none in any schema on
  2026-10-30: no `token_*` columns yet), 0320 writes records, promote reads and checks them, both bundle scripts read
  records; 173 tests pass; mutation (promote's md5 check removed) turns `test-tune_promote.R` red. The
  `md5_local` failures in `test-vignette-data.R` are the existing ones (this checkout holds the 2026-10-25 build, A3).
- Phase 2 landed: filed NewGraphEnvironment/link#420 (tokens for pre-0.70 builds, the Atlas-line gradient, the
  tuning's flow read) and wrote it into #119's body; `R/archive.R` (setup, plan, put, pull, undo, index),
  `scripts/0336-archive.R`, 0335's preflight and archive step, `research/run_archive.md`; 214 tests pass with `aws`
  and `zstd` mocked; mutations (promoted-run guard, restore md5 check) each turn a test red.
  Deviation from the plan text: the evidence id is the MANIFEST's full md5, and the index's `source` is the file's
  path in a checkout (`data/...`), so a candidate's files restore to where the tracked tables expect them.
- Phase 3 done 2026-10-30: lifecycle (Standard-IA kept; abort multipart 7 d; noncurrent 180 d on archive/knowledge/,
  30 d on each other top-level prefix and archive child: 15 rules) then versioning Enabled, both read back. Before
  it: 0 noncurrent versions, 41 delete markers, so nothing existing was expired. Real round trip under
  archive/knowledge/_test/ (11 objects; second put sent nothing; restore md5-identical), its 11 versions deleted.
