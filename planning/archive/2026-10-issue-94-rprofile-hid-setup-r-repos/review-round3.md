# Code check, round 3 (#94: unpin runners, add job timeouts)

## Checklist read

- `soul/conventions/ci-monitoring.md` (14,500 B): in full.
- `code-check-python.md` (7,237 B): in full.
- `code-check.md` (330,698 B): the prose of all fourteen H3s under `## Mechanisms`, with table rows and evidence
  blocks skipped. None of the index headings outside Mechanisms names CI, workflows, timeouts or runner images.
- `code-check-shell.md`, `code-check-r.md`, `code-check-spatial.md` (all over 40,000 B): index read. The headings that
  bear on two YAML files ("pak Behavior", "`timeout` is GNU coreutils", the `gh` CLI notes) were covered by rounds 1
  and 2. Nothing else in them names Actions, runners or timeouts, so no other section was read.
- Rounds 1 and 2 and `task_plan.md`, so that this round does not repeat them.

## The mechanism

**A guard that fails toward pass, because its fired state uses a channel whose value means something benign.**
`timeout-minutes` is a guard: it turns a hang into a kill. That only helps if the kill reaches someone. This
repo's readers (the session-start scan in ci-monitoring.md, `/gh-pr-merge` step 10, and the plan's own
`gh run view --log-failed`) give the value a timeout produces a reserved, benign meaning.

**Measured 2026-10-26, so round 1's open question is now answered.** Three NGE runs were killed at GitHub's job
time limit (the default 6 h, which is the same limit `timeout-minutes` lowers):

| run | run conclusion | job conclusion | check-run conclusion | annotation |
|---|---|---|---|---|
| drift 38592249287 (pkgdown) | cancelled | cancelled | cancelled | "The job has exceeded the maximum execution time of 6h0m0s" |
| fly 37670553822 (pkgdown) | cancelled | cancelled | cancelled | same |
| rfp 32275661101 (pkgdown) | cancelled | cancelled | cancelled | same |

In each case the step that was running reads `cancelled`, and every later step reads `skipped`. On drift
38592249287, `gh run view --log-failed` prints **0 lines**. A third-party write-up of a `timeout-minutes: 1` kill
quotes the same annotation ("has exceeded the maximum execution time of 1 minute"). It also says that filtering
the UI by "timed out" finds nothing, so `timed_out` is not what gets set. The annotation is the only sign that the
run timed out, not that a person cancelled it or a newer push superseded it.

## Where it reaches in these two files

1. `.github/workflows/pkgdown.yaml:19` (`timeout-minutes: 30`). If a `push` to main or a `release` run times out,
   nothing deploys and the conclusion is `cancelled`. The session-start scan selects `conclusion == "failure"`, so it
   never shows the run. `/gh-pr-merge` step 10 reads it as "⊘ superseded". The site goes stale and every monitor
   reports nothing. The `pkgdown-true` group with no `cancel-in-progress` makes this worse: after a kill, the group
   moves to the pending run, so the queue looks healthy.
2. `.github/workflows/update-citation-cff.yaml:17` (`timeout-minutes: 15`). This job only runs on a release push
   (`DESCRIPTION`). If it times out, CITATION.cff keeps the previous version, which is exactly the
   "update-citation-cff: CITATION.cff stale" failure that ci-monitoring.md's scan exists to catch. The scan cannot
   see it, because the run reads `cancelled`.

Before this diff, a hang also ended as `cancelled`, but only after 6 h, about once a month across the org. A
30 min or 15 min limit fires on every stall. The plan's gate decision assumes that "a stall fails within half an
hour and is rerun". That is false: a stall is cancelled, and nothing reruns it unless a person reads the
annotation.

Neither of the other two mechanism candidates shows up in this diff:

- **Wrapper's exit.** `Rscript -e` and the `git diff --quiet` gate in the citation job fail loudly. An error in
  `git diff` sends the job toward the commit step, which then fails visibly.
- **Proxy for the property.** Rounds 1 and 2 cover the image proxy (a green `ubuntu-latest` run does not show the
  run was on 26.04), and the plan already has a step for it.

## Findings

- **[severity: fragile]** `.github/workflows/pkgdown.yaml:19` and `.github/workflows/update-citation-cff.yaml:17`.
  A run killed by `timeout-minutes` ends with conclusion `cancelled` at the run, job and check-run level (measured
  above). Every reader this repo uses either filters it out or reads it as benign:
  - ci-monitoring.md's scan, `select(.conclusion == "failure")`;
  - `/gh-pr-merge` step 10, which reads `cancelled` as superseded;
  - the plan's Phase 2 fallback, `gh run view --log-failed`, which prints nothing.

  So the new guard turns a hang that someone would notice (a run still `in_progress` hours later) into a run that
  looks finished and harmless. A stale site or a stale CITATION.cff after a release is then reported by nothing.

  The YAML itself is not wrong. The defect is the assumption that the kill "fails". Before calling it done, pick
  one of these:
  - the readers check for the annotation "exceeded the maximum execution time" on any `cancelled` run of these two
    workflows;
  - the scan and `/gh-pr-merge` also treat `cancelled` as a failure when no newer non-bot run on the same workflow
    passed;
  - check that a step-level `timeout-minutes` on `setup-r-dependencies` marks the step and job `failure`. Not
    verified here, so measure it before relying on it.

  At least, fix the plan's "If the run fails or stalls" step: read `--json jobs` and the annotations, not
  `--log-failed`.

Nothing else found.

Sources: [zenn.dev/snowcait: telling a timeout from a manual cancel](https://zenn.dev/snowcait/articles/ecf458c1cb3811);
the run conclusions and annotations above came from `gh api repos/NewGraphEnvironment/<repo>/actions/runs/<id>/jobs`
and `.../check-runs/<job_id>/annotations`.
