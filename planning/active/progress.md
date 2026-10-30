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
