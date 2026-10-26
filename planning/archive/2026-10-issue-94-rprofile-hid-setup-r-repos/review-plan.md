# Plan review — #94 (Plan agent, 2026-10-26 ~21:30Z)

Taken from the agent's reply; written here by the session (Plan agents cannot write).

- **Gap** — the citation workflow can be verified before merge: `workflow_dispatch` needs the file on the default
  branch (it is), and `gh workflow run update-citation-cff.yaml --ref <branch>` runs the branch's YAML. Its commit step
  pushes only if `CITATION.cff` changed, and the branch carries main's auto-updated copy (4aa30b3), so it should push
  nothing; if it did, it would push to the feature branch. The PR run proves only `pkgdown.yaml` parses. → Folded in:
  Phase 2 dispatch on the branch.
- **Ordering** — after merge, `/gh-pr-merge`'s release commit and `release: published` add pkgdown runs to the
  `pkgdown-true` group (no `cancel-in-progress`; one pending slot, a newer pending run cancels the older), so the merge
  SHA's run may be cancelled and `gh-pages` would name a later SHA. → Owed item now checks the newest non-bot main SHA.
  The stuck main run 40400891471 (old YAML, no timeout) holds that group, so post-merge runs queue behind it until it
  finishes or is cancelled. → Reported to Al as a merge-time decision.
  The release commit's `DESCRIPTION` bump triggers the citation workflow on main by itself. → Owed dispatch replaced by
  checking that run.
- **Assumption** — `setup-r-dependencies` caches the library keyed on OS version, so only the first run on 26.04
  installs from scratch; a rerun or a later run restores the cache and logs no duckdb install. → Read the first
  attempt's log.
- **Acceptance** — the PR run skips deploy, so deploy on 26.04 is shown only after merge. → Owed item.
- **Scope** — a job-level timeout covers every step and frees the concurrency group; a timeout during deploy or
  `git push` leaves no half-written state. The PR run is soul#541's probe on `ubuntu-latest`. → Report the result
  there.

Checked: `workflow_dispatch` is a trigger in `update-citation-cff.yaml` on main; run 40400891471 still in
`setup-r-dependencies` at 21:33Z (since 21:09Z).
