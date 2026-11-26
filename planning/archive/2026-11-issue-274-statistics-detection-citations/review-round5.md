# Code-check round 5, #274 branch (f0a6cbd0...HEAD, tip 81a749ac)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md` (read by heading): "Copy a live SQLite database with its `-wal`" (the rebuild's `-wal` gate and the
  guarded copies the planning files describe). The other headings were not read: the diff adds no R code.
- `code-check-shell.md` (read by heading): "An S3 multipart ETag depends on the uploader's part size, so try every size
  that gives its part count" (the push log's ETag line). The other headings were not read.
- `code-check-spatial.md` (read by heading): none read (no spatial code or data in the diff).
- `code-check.md` (read by heading): the prose of all fourteen H3s under `## Mechanisms` (table rows and evidence
  blocks skipped). No heading outside Mechanisms read.
- Also applied: the global rule that in a public repo "anything else learned about our machines" stays out of code,
  commits, issues, PRs and `planning/`, and the knowledge CLAUDE.md's "One discipline: everything here is public",
  whose named check is the #56 archive's `public_sweep.py`.

Checked against: the diff file (`git diff f0a6cbd0...HEAD`, 978 added lines, 2 removed), `git log -p fa8ad1d2..HEAD`
(the one unpushed commit, 81a749ac), `git log f0a6cbd0..HEAD` (13 commits), `gh issue view 274` and `gh issue view
278`, `git ls-remote` (origin's branch is at fa8ad1d2, so 81a749ac alone is unpushed), and the `host` pattern of
`planning/archive/2026-10-issue-56-public-flip/public_sweep.py` (line 25) run over every file the branch touches.

## Findings

- **[severity: security]** planning/active/review-round4.md:97 — round 4's own "History" paragraph lists the terms
  it grepped the pushed commits for, and the list names both of our machines' host names and the kind of private
  network they are joined by (quotes withheld here). This is route 3 again: a review file's description of its
  check carries what the check looks for. It is the only line on the branch that the repo's own sweep flags: the
  `host` pattern of `public_sweep.py` (its line 25) matches it, and no other added line. That also makes
  planning/active/progress.md:49 ("Public sweep: no hits in this branch's files or commit messages") false at the
  tip, because round 4's file was written after the sweep ran. The line is only in 81a749ac, which is unpushed, so
  amend 81a749ac (not a new commit on top, round 4's lesson) with the grep terms named by kind: "host names, user
  paths, ports and connection terms". Then rerun the sweep over the branch's files, so progress.md:49 describes the
  final tree.
  - **Rule:** none for the leak (the global public-repo rule, as in rounds 2 to 4); for progress.md:49, code-check.md
    "The probe is broken before the world is" ("Write the numbers last, against the final tree")

- **[severity: fragile]** planning/active/review-round3.md:37, 57, 59, 60; planning/active/review-round4.md:24, 26,
  58; planning/active/review-round2.md:23 — round 4's finding 2 named three lines whose descriptions of the leak say
  what it was, and the fix reworded those three. The same kind-of-fact descriptors remain at these eight. Each one
  names the kind of fact that was removed (kinds not repeated here); read with findings.md:75 they tell a reader
  more about the machine than the fix left. They give no values, no host and no path. It is the class one axis over
  from round 4's three lines, so it is fixed by enumerating the class, not those lines: in the same amend as finding 1, name each as "the removed fact" / "round 2's leak", or delete
  the kind from round 3's table cells at 57, 59 and 60 and from round 4's table cell at 58. This is the owner's call,
  as round 4's finding 2 was.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (terminate by enumeration: the class
    recurs one axis over)

## Did round 4's fixes damage anything?

| place at the tip | round 4's fix | verdict |
|---|---|---|
| history f0a6cbd0..HEAD | three unpushed commits folded into 81a749ac on top of origin's fa8ad1d2 | done: `git log` shows 13 commits; origin is at fa8ad1d2; none of the folded commits' text is in the branch's history |
| 81a749ac's message | subject names no machine | clean: "code-check rounds 1-4, test-suite result, Phase 4 progress" plus the co-author line |
| progress.md:47-48 | "rounds 2, 3 and 4 ... the unpushed commits that carried them folded into one before the push" | true once 81a749ac is pushed as it stands (or amended, which is still one commit) |
| progress.md:49 | "Public sweep: no hits in this branch's files or commit messages" | **false at the tip** (finding 1) |
| review-round2.md:16-17, 20 | "facts learned about the database machine (removed here)", "Such facts" | still reads as a finding, and still says what it found (a public-repo leak in findings.md:75, cuttable before the push). Line 21's 1e43a18e and round 3's abcfa914/5e498ba5 and round 4's 0e0ea2d5 no longer exist anywhere; they are a record of the round, and nothing resolves or links them. No damage |
| review-round3.md:28, 41 | "carries whatever state the machine is in"; "The machine fact belongs in memory" | generic now; the finding still says what it found. No damage |
| findings.md:75 | "raised by the database server, not by R code; re-run once, same error" | true; says what happened and what was done. No damage |
| review-round4.md:20-45 | the record of round 4's findings | still accurate as a record of the pre-fold state; its recommendation was carried out |

The pushed commits (2deffbbd to fa8ad1d2): no host name, user path, port or login. The `host` pattern of
`public_sweep.py`, and a grep for user paths, the user name and connection terms,
`pg_service`, `.Renviron` and `.config/` over `git log -p f0a6cbd0..fa8ad1d2` find nothing. They do carry the
earlier plan wording on which machine runs what, and the earlier wording on where each step ran. This is
already public. 81a749ac's patch shows it again as removed lines in task_plan.md and review-plan.md, which adds no
exposure.

## Enumeration of what a push would publish

Routes: 1 = tool or server output captured verbatim; 2 = the agent's notes on where a step ran or what a machine
has; 3 = review files quoting what they flag.

| source | lines | route | carries something learned about a machine? |
|---|---|---|---|
| data/detection_additions.csv | +6 | none | no: DOIs, repo-relative `data/rag/pdf/detection/` paths, sourcing notes |
| planning/active/enumeration_round0.tsv | +7 | none | no: bibliographic fields, repo-relative paths |
| planning/active/findings.md | +116 | 2 | no new fact. Line 75: the server raised the error (accepted). Lines 98-101: Chrome's last-used folder and `~/Downloads` (generic). Line 103: "a worktree of this branch". "any local library" means the Zotero libraries |
| planning/active/progress.md | +50 | 2 | no machine fact. Line 49 is false (finding 1) |
| planning/active/review-plan.md | +48 | 2 | no: A2 reworded; G3 generic; P1 is a rule |
| planning/active/review-round1.md | +20 | 2, 3 | no: a sentence saying no home path exists; arithmetic on logs |
| planning/active/review-round2.md | +61 | 3 | line 23 names the kind of the leak (finding 2); line 55 is hypothetical and generic. The rest no |
| planning/active/review-round3.md | +76 | 3 | lines 37, 57, 59, 60 (finding 2); line 32's role label and line 57's PostgreSQL path are accepted. The rest no |
| planning/active/review-round4.md | +104 | 3 | **line 97: two host names and a network term (finding 1)**; lines 24, 26, 58 (finding 2). The rest no |
| planning/active/task_plan.md | +140 | 2 | no: Requirements (29-30) and decision 3 (43-44) state requirements; versions accepted; `~/Downloads` generic |
| scripts/README.md | +3 / -2 | none | no: store contents and issue numbers |
| scripts/logs/rag/20261125_0270_detection_dryrun.log | +33 | 1 | no: Zotero keys, DOIs, counts |
| scripts/logs/rag/20261125_0270_detection_dryrun2.log | +33 | 1 | no |
| scripts/logs/rag/20261125_0270_detection_live.log | +33 | 1 | no |
| scripts/logs/rag/20261125_0270_detection_measure_after.log | +4 | 1 | no: MB of library content |
| scripts/logs/rag/20261125_0270_detection_measure_before.log | +4 | 1 | no |
| scripts/logs/rag/20261125_push_statistics.log | +26 | 1 | no: bucket (accepted), the store's bytes, md5, ETag, branch and head_sha; no host field |
| scripts/logs/rag/20261125_query_statistics.log | +58 | 1 | no: `/tmp/Rtmp<random>` and the duckdb notice (accepted); `origin` truncated to `/User…`, no user name |
| scripts/logs/rag/20261125_query_statistics_before.log | +62 | 1 | no, as above |
| scripts/logs/rag/20261125_rebuild_statistics.log | +61 | 1 | no: as above; "Installed 48 packages" (accepted); the `-wal` gate line is procedure |
| scripts/logs/rag/20261125_rebuild_statistics_expected.txt | +33 | 2 | no |
| unpushed patch 81a749ac (`git log -p fa8ad1d2..HEAD`) | +282 / -12 | 2, 3 | the added lines are a subset of the rows above (findings 1 and 2); the removed lines are already public (see above) |
| commit messages f0a6cbd0..HEAD (13 commits) | 56 | 2 | no: subjects, one body (42ffece5) on sources and #278, co-author lines |
| #274 body | 49 | 2 | no: "through a browser", sourcing routes, store counts |
| #278 title and body | 16 | 2 | no: "a guarded copy of the local database" is the Zotero database, no path |
| **total** | **978 added lines (21 files), 56 commit-message lines, 65 issue lines** | | **one line carries host names (finding 1); eight carry the kind of a removed fact (finding 2)** |

## Verdict

Two findings. Finding 1 should be fixed before the push, by amending 81a749ac and rerunning the sweep. Finding 2 is
the owner's call and fits in the same amend.
