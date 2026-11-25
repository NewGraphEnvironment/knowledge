# Code-check round 4, #274 branch (f0a6cbd0...HEAD, tip 0e0ea2d5)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md` (read by heading): "Copy a live SQLite database with its `-wal`" (the rebuild's `-wal` gate and the
  guarded copies the planning files describe). The other headings were not read: the diff adds no R code.
- `code-check-shell.md` (read by heading): "An S3 multipart ETag depends on the uploader's part size, so try every size
  that gives its part count" (the push log's ETag line). The other headings were not read.
- `code-check-spatial.md` (read by heading): none read (no spatial code or data in the diff).
- `code-check.md` (read by heading): the prose of all fourteen H3s under `## Mechanisms` (table rows and evidence blocks
  skipped). No heading outside Mechanisms read.
- Also applied: the global rule that in a public repo "anything else learned about our machines" stays out of code,
  commits, issues, PRs and `planning/`, and the knowledge CLAUDE.md's "One discipline: everything here is public".

Checked against: the diff file (its md5 equals `git diff f0a6cbd0...HEAD` at 0e0ea2d5), `git log f0a6cbd0..HEAD`
(15 commits), `git show` of each unpushed commit, `gh issue view 274` and `gh issue view 278`, and `git ls-remote`
(origin's branch is at fa8ad1d2, so abcfa914, 5e498ba5 and 0e0ea2d5 are unpushed).

## Findings

- **[severity: security]** planning/active/progress.md:47-48 and review-round3.md:41 (history: commits abcfa914,
  5e498ba5) — round 3's fix did not reach the commits that carry the leak. Round 3 said both commits holding the
  removed fact are unpushed, "so an amend leaves no public revision", but the fix landed as a new commit
  (0e0ea2d5) on top of them. The unpushed history still holds the text the fix removed from the tip:
  - abcfa914 adds the findings.md Errors row that carried the removed fact;
  - 5e498ba5 adds progress.md's and review-round2.md's wording of the same facts, and its own subject names them
    (quotes removed here).

  A push of the branch as it stands publishes all of it, and GitHub keeps it in the PR's commit list after any later
  edit. No host name, user path, port or login is in any of it. The fix is cheap now and not after the push: fold the
  three unpushed commits into one (`git reset --soft fa8ad1d2`, then one commit with a subject that names no machine,
  for example "#274: code-check rounds 1-3; test-suite result and Phase 4 progress"). The store's manifest names
  1e89da92, which is on origin and untouched by this. progress.md:47-48 then says "cut (the unpushed commit amended)"
  of rounds 2 and 3 together; as written it is false for round 3, which amended nothing, so the sentence should become
  true by the fold, or be reworded.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: fragile]** planning/active/review-round2.md:20, review-round3.md:28, 41 — the review files' own
  descriptions of the leak still say what it was. Read together with findings.md:75 ("raised by the database server"),
  they give the reader the fact that the fix removed (round 2 line 20, round 3 lines 28 and 41, quotes
  removed here). This is milder than finding 1, since it gives no values and no machine, but it is route 2
  again: a description of the leak carries the leak's subject. A wording that keeps every point: name the facts as "such facts", "round 2's leak" and "the machine fact".
  This is the owner's call.
  - **Rule:** none

## (a) Did round 3's fixes damage anything?

| place at the tip | before round 3 | after | verdict |
|---|---|---|---|
| findings.md:75, Errors row | carried the removed fact | "raised by the database server, not by R code; re-run once, same error"; "Reported to Al, not fixed here" | still true (the error came from the server), and still says what happened and what was done. No damage |
| findings.md:103, Build heading | named the machine's role | "a worktree of this branch" | true. No damage |
| progress.md:32 | "Next: Phase 3 on the store-build machine" | "Next: Phase 3" | No damage |
| progress.md:36 | "On the store-build machine, a worktree..." | "In a worktree of this branch with a real `data/rag/`" | keeps the requirement (real `data/rag/`). No damage |
| progress.md:46 | named the machine's role and the error's cause on it | "Build worktree removed ... raised by the database server, not by R code" | true. No damage |
| progress.md:47-48 | round 2 only | "rounds 2 and 3 ... cut (the unpushed commit amended)" | **false for round 3** (finding 1) |
| review-plan.md:30, A2 | the plan machine's holdings | "The plan's note on where 0270 runs needed rewording. Accepted, reworded." | true as a record; says less, nothing wrong |
| review-round2.md:16-23 | the removed fact, by description | "facts learned about the database machine (removed here)" | the finding still reads as a finding. the line naming the kind of fact remains (finding 2) |
| review-round2.md:41 | named the machine's role | "the build's Zotero had synced" | true. No damage |
| task_plan.md:29-30, Requirements | which machine runs what and has what | "0270 runs beside the PDFs and a synced Zotero; the build and push need cred 0.8.0, ragnar 0.4.0 and a real `data/rag/`, and run from a worktree of this branch" | every requirement Phase 2 and 3 rely on is still stated: PDFs and synced Zotero for 0270 (its `db()` dedupe copy and the Web API), versions and a real `data/rag/` for 0150, the worktree for the manifest's branch and sha; the Zotero-quit and 0-byte `-wal` gate is in the next bullet and Phase 3. No damage |
| task_plan.md:43-44, decision 3 | named machines; "Upgrading cred on the browser machine is #217's" | "sourcing and 0270 beside the browser's downloads; build and push wherever the requirements above hold" | consistent with the Requirements bullet. The dropped #217 pointer was a scope note about one machine, not a requirement of this work. No damage |
| task_plan.md:98-99, Phase 3 heading and first step | "store-build machine" | "a worktree of this branch"; "make a worktree of it with a real `data/rag/`" | the X4 real-`data/rag/` check is kept. No damage |
| review-round3.md | new | the round's record | its line numbers cite the pre-fix tree, which is right for a record of that round. Line 41's "an amend leaves no public revision" is the recommendation that was not carried out (finding 1) |

## (b) Enumeration: every added line, every commit message, both issue bodies

Routes: 1 = tool or server output captured verbatim; 2 = the agent's notes on where a step ran or what a machine has.

| source | lines checked | route | carries something learned about a machine? |
|---|---|---|---|
| data/detection_additions.csv | 6 | none | no: DOIs, repo-relative `data/rag/pdf/detection/` paths, sourcing notes (Zenodo, White Rose, ResearchGate, JSTOR) |
| planning/active/enumeration_round0.tsv | 7 | none | no: bibliographic fields and repo-relative paths |
| planning/active/findings.md | 116 | 2 | no at the tip. Lines 66-68 (Chrome's last-used folder, `~/Downloads`) are browser defaults and a generic path; line 75 says only that the server raised the error; "any local library" (dedupe) is the Zotero libraries, not a machine; line 98 (auto-mode refusal) is the harness, not a machine; 11.6 min and UTC stamps are accepted |
| planning/active/progress.md | 49 | 2 | no machine fact. Lines 47-48 make a claim about the commits that is false for round 3 (finding 1) |
| planning/active/review-plan.md | 48 | 2 | no: line 30 rewritten; G3 (Chrome's last-used folder) generic; P1 "home paths as `~/`" is a rule |
| planning/active/review-round1.md | 20 | 2 | no: "No home-directory path" is a statement that none exists; arithmetic on logs |
| planning/active/review-round2.md | 61 | 2 | line 20 tells which kind of fact was recorded about the database machine (finding 2); line 51 "a machine without the ignored `data/rag/pdf/detection/`" is hypothetical and generic. The rest no |
| planning/active/review-round3.md | 76 | 2 | lines 28, 41 as finding 2; line 32's role label and one table cell are accepted; the table's remaining rows are verdicts with no values. The rest no |
| planning/active/task_plan.md | 140 | 2 | no: Requirements and decision 3 state requirements; `~/Downloads` generic; versions accepted |
| scripts/README.md | 3 | none | no: store contents and issue numbers |
| scripts/logs/rag/20261125_0270_detection_dryrun.log | 33 | 1 | no: Zotero keys, DOIs, counts |
| scripts/logs/rag/20261125_0270_detection_dryrun2.log | 33 | 1 | no |
| scripts/logs/rag/20261125_0270_detection_live.log | 33 | 1 | no ("pdf exists" is Zotero's file server, not ours) |
| scripts/logs/rag/20261125_0270_detection_measure_after.log | 4 | 1 | no: collection sizes of library content |
| scripts/logs/rag/20261125_0270_detection_measure_before.log | 4 | 1 | no |
| scripts/logs/rag/20261125_push_statistics.log | 26 | 1 | no: bucket (accepted), manifest list, the store's bytes, md5, ETag, branch, head_sha; cred writes no host field |
| scripts/logs/rag/20261125_query_statistics.log | 58 | 1 | `/tmp/Rtmp<random>` (accepted); duckdb's notice says `~/.duckdb` is absent, a trivial config state with precedent in seven logs on main (`git grep 'create ~/.duckdb' origin/main -- scripts/logs`); `origin` truncated to `/User…` (accepted, no user name). No |
| scripts/logs/rag/20261125_query_statistics_before.log | 62 | 1 | the same as above; versions accepted. No |
| scripts/logs/rag/20261125_rebuild_statistics.log | 61 | 1 | `/tmp/Rtmp<random>` and duckdb notice as above; eight "Installed 48 packages" (accepted, precedent on main); "Zotero quit, zotero.sqlite-wal 0 bytes" is the procedure's gate. No |
| scripts/logs/rag/20261125_rebuild_statistics_expected.txt | 33 | 2 | no: "a copy of zotero.sqlite with its -wal" names no path |
| commit messages, f0a6cbd0..HEAD (15 commits) | 33 | 2 | 5e498ba5's subject says what kind of fact the host had recorded, no values and no host (unpushed; goes with finding 1's fold). The other 14 no |
| #274 body | 34 | 2 | no: "through a browser", sourcing routes, store counts |
| #278 body (title and body) | 9 | 2 | no: "a guarded copy of the local database" is the Zotero database, no path |
| **total** | **873 added lines, 33 commit-message lines, 43 issue lines** | | |

History: the pushed commits (2deffbbd to fa8ad1d2) carry the earlier plan wording about which machine runs what and
what each holds; grep of them for host names, user paths, ports and connection terms finds none
(the one home-path pattern hit is in unpushed abcfa914, round 1's sentence "No home-directory path"). The unpushed commits are
finding 1.

## Verdict

Two findings. Finding 1 should be fixed before the branch is pushed: fold the three unpushed commits, which also makes
progress.md:47-48 true. Finding 2 is the owner's call.
