# Code review, round 4 (enumeration): branch 56-clean-up-and-make-the-repo-public-packag (HEAD f274339)

Read: review-round3.md in full, `public_sweep.py`, the f274339 diff, 0230's fetch block, 0299's PULL block,
task_plan.md, findings.md. Probes were read-only:
- `gh api` GET and GraphQL;
- `aws s3 ls`;
- `aws s3 sync --dryrun` into the scratchpad;
- a full `PULL=TRUE` run of 0299 in a scratch copy, reading from the bucket.

Nothing was written to S3, a database or GitHub. This file is the only repo write. It names the client slugs and the
home path generically on purpose, because this file will become public too (finding 2).

Runs (2026-10-16 22:37Z, `origin/main` = 7504091):
- `public_sweep.py all`: exit 1. One hit, issue #4's rename entry (an owner decision). The generated-convention line
  reads `host 6, internal_ref 1, local_path 15, private_repo 16, template_name 1`.
- `public_sweep.py history`: exit 1. 105 revision hits on 23 distinct URLs, as a set **identical** to findings.md's
  23-item list (`diff` of the sorted URL sets is empty).

So (c): the output matches findings.md.

## Enumeration

### (i) What becomes public at the flip, against what the sweep reads

| Surface | Verdict | Evidence |
|---|---|---|
| Tracked tree at HEAD (incl. binaries), outside exemptions | Holds | `all` gives no tree hits. Every multi-part year-suffixed token outside the exemptions, matched case-insensitively with `-` or `_`: the only candidates are public FISS workbook filenames in `data/<wsg>/fiss_xls_*.csv` and `data/necr/crossings.csv` (mixed case, not NGE slugs). The group-brief slug is gone from `data/context_bowron_mcgregor.md`. |
| CLAUDE.md below the marker | Reported, not failed (accepted). **The report undercounts**, finding 1 | CLAUDE.md:2118 and 2138 hold a hyphenated `<client>-<region>-<year>` branch-name slug. `project_repo` matches only `_`, so neither the generated-line count nor soul#439's 39-hit inventory includes it. |
| `planning/`, `scripts/logs/` | Exempt (accepted). **The new CLAUDE.md claim does not hold**, finding 2 | This branch's own `planning/active/` files, written 2026-10-16, carry 82 line-by-pattern hits. They include both client slugs and a client slug inside a home path (review-round3.md:33, 35, 40, 68, 110, 122). |
| Issue/PR titles, bodies, comments, review comments, review bodies (current) | Holds | REST `--paginate` (complete). The only hit is #4's rename. 0 reviews and 0 review comments exist (GraphQL `totalCount`). |
| Rename events | Holds (owner decision on #4) | The sweep reports #4. |
| Edit histories | Holds as a snapshot. **Not wired into the flip**, finding 3 | `history` = findings.md list (23/23). The GitHub-wide maxima, measured: 10 edits per body, 3 comments per item, 5 edits per comment. So the unpaged `first:50` and `first:100` truncated nothing today (finding 4). Masking: re-searching each revision after removing the PR `sred` reference and #20's `m1` adds 0 items. |
| PR head branch names (shown on every PR page, including closed and merged ones) | Holds; **row missed by round 3** and unswept | 19 head refs. All sweep patterns give 0 hits. The broad slug form matches only a citation key (`…-et-al-2005`, PR #46). |
| This branch's commit messages | Holds | `commits()` is clean over `origin/main..HEAD`. f274339's message carries no slug. |
| Branch `11-…` / PR #12 | Owner decision (recorded) | Unchanged: `refs/heads/11-…` = `refs/pull/12/head` = 20f0a5a. |
| Actions runs/artifacts, wiki, discussions, releases, tags, milestones, commit comments, deployments, environments, labels, description, topics, homepage, Pages | Holds | 0 runs and 0 artifacts. The wiki git remote is "Repository not found" (no pages). Discussions are off. Releases, tags, milestones, commit comments, deployments and environments are all 0. Labels are the defaults. The description is generic, there are 0 topics, the homepage is null, and Pages returns 404. |
| `s3://fresh-bc/fdis/`, `knowledge/` | Holds (caveat unchanged) | 28 + 6 objects. The manifest's `published_from_commit` is still `f2e17aa`. The branch is still not on the remote (`ls-remote` lists only `main` and `11-…`), so it needs a merge-commit merge, as round 3 said. |

### (ii) A file's or object's presence taken as proof a step completed

| Place | Verdict | Evidence |
|---|---|---|
| 0230 `NO_SIGN` | Holds | Unchanged: `.part` manifest, then keys, then the rename. |
| 0230 credentialed sync (round-3 fix) | Holds | `aws s3 sync … --exclude MANIFEST.md5 --dryrun` lists 27 downloads and none of them is the manifest. The bucket has 28 objects and 1 manifest. The manifest `cp` runs only after the sync exits 0. A failure before it leaves no marker, so a re-run syncs again. Residual (not a finding): a cache left half-synced by the *old* code still has its manifest. It fails loudly at the md5 check and loses nothing. |
| 0230 outputs; 0240 reads | Holds | Unchanged since round 3 (`git diff 2b3a042 HEAD` touches only the 0230 fetch block). |
| 0299 `PULL` (round-3 fix) | Holds | A full run in a scratch copy wrote all 5 tables, and each row count equals the manifest's (53018 / 17606 / 21862 / 21862 / 372687), exit 0. A truncated `.part` either fails to parse or counts short, and either way it stops before the rename. Residual (not a finding): an interruption after table k leaves tables 1..k complete. A re-run then stops at table 1 with "move it aside". That is loud, and nothing is truncated. |
| 0299 publish, guard probe, clean-tree check | Holds | Unchanged since round 3. |
| 0200, 0210, 0220, 0260, pkgdown page check, `test-data-dir.R` | Holds | Unchanged since round 3 (not in f274339). |
| `history` output as the deletion list | Holds now, against the 23/23 run | |
| **"After merge" step 1 → step 2 (revisions deleted → make public)**, a row round 3 missed | **Does not hold**, finding 3 | The flip follows a person working through a list frozen in the PR. Nothing re-measures. |
| `wf_*.js` `harvest_dir` | Pre-existing (accepted) | |

## Findings

- **[security, low] CLAUDE.md:2118, 2138; planning/active/public_sweep.py:28. INSIDE ROUND-3 FIX.**
  - The widened `project_repo` alternative `\b[a-z]+_[a-z]+_20\d{2}\b` takes the slug class to be underscore-only.
    The generated conventions name a client project as a hyphenated branch slug (`322-<client>-<region>-<year>`, and
    the bare `<client>-<region>-<year>`). It is the same client and region as the one in PR #12's branch path.
  - The sweep's generated-text report therefore omits it. soul#439, which inventories exactly the 39 hits those
    patterns found, does not list it either. The fix at the source will leave a client identifier in every public
    repo's CLAUDE.md.
  - Measured with separators `[-_]` (`\b[a-z]+[-_][a-z]+[-_]20\d{2}\b`): over the tree outside the exemptions and over
    all GitHub text (current and every revision), it matches only those two CLAUDE.md lines and #17's two known
    revisions. It also matches a citation key in PR #46's head branch name, which the sweep does not read. Widening
    the pattern adds no false positives to anything swept.
  - Fix: use `[-_]` in that alternative, and add the hyphenated slug to soul#439.

- **[fragile / security, low] CLAUDE.md:60-62 vs planning/active/. INSIDE ROUND-3 FIX.**
  - The reworded claim says "That holds for new `planning/` files". It says the archives and logs "written before
    2026-10-16" are the ones that carry such text.
  - This branch's planning files are new, dated 2026-10-16, and become `planning/archive/2026-10-issue-56-…`. Measured
    with the sweep's own patterns: 82 line-by-pattern hits across all 8 files. Many are the patterns quoting themselves, which
    is benign. Not benign:
    - review-round3.md quotes the client field-project slug that f274339 removed from the group brief, at lines 33,
      35, 68 and 110.
    - review-round3.md:40 and :122 quote a home path containing a second client slug.
  - The tree fix is therefore re-published one directory over. Nothing checks it, because `EXEMPT_PREFIX` covers
    `planning/active/` wholesale. A later session will trust the claim.
  - Fix: either
    - scrub the #56 PWF of client slugs and home paths before `/planning-archive`, by rewording the quotes, and
      sweep planning files newer than the cutover (a `git log --diff-filter=A --since` list); or
    - restate the claim as "the #56 archive also quotes them".

- **[fragile] planning/active/task_plan.md:94-96 (After merge).**
  - Step 2 ("Make the repo public") follows step 1 ("Delete earlier revisions … list provided in the PR"). That is the
    round-3 mechanism again: "done" is decided from a list written at PR time, not from the population at flip time.
  - Two things move between the PR and the flip:
    - New edits after the PR add revisions. #56 and its comments carry 17 of today's 20 revision hits, from two sessions.
    - Whether every revision is deletable in the UI is unverified. GitHub's docs say only that you "select it from
      the list of edits" and delete it. They do not say whether an item's original revision can be deleted. At least two
      listed items hit in their oldest recorded revision: #3 at 2026-07-30T17:20:09Z and #56 at 2026-10-16T20:23:56Z.
  - Fix: make step 2 conditional on `public_sweep.py history` printing no hits and `… all` printing only accepted
    items. Do this on the day of the flip.

- **[fragile, low] planning/active/public_sweep.py:151-153. INSIDE ROUND-3 FIX.**
  - `history()` does not page past the first 50 comments per item. It requests no `pageInfo` and gives no warning,
    so a long thread would be read as clean (failing toward pass).
  - It does not read PR reviews or review comments, which are also `UserContentEditable`.
  - Measured today: at most 3 comments per item, and 0 reviews and 0 review comments, so nothing is missed now.
  - `userContentEdits(first:100)` is complete by construction: GitHub keeps the original plus the most recent 99
    edits (docs), and the maximum measured is 10.
  - Fix: assert `comments.totalCount <= 50`, or page it, and add `reviews{…}` (with their comments) to the PR query.
    Or exit non-zero when any `totalCount` exceeds what was fetched.

planning/active/review-round4.md
