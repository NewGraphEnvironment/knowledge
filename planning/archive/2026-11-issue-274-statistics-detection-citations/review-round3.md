# Code-check round 3, #274 branch (f0a6cbd0...HEAD)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md` (read by heading): "Copy a live SQLite database with its `-wal`", "`tempfile()` lives in the
  session tempdir, so a path printed in an error names a file R is about to delete" (the logs' `/tmp/Rtmp…` paths).
  The other headings were not read: the diff adds no R code.
- `code-check-shell.md` (read by heading): "An S3 multipart ETag depends on the uploader's part size, so try every
  size that gives its part count". The other headings were not read.
- `code-check-spatial.md` (read by heading): none read (no spatial code or data in the diff).
- `code-check.md` (read by heading): the prose of all fourteen H3s under `## Mechanisms` (table rows and evidence
  blocks skipped). No heading outside Mechanisms read.
- Also applied: the global CLAUDE.md rule on public repos ("anything else learned about our machines"), and
  feature-workflow's "Public-repo text describes the package, and points nowhere private" ("Our host topology does
  not: which machine runs what").

## The mechanism

Round 2's leak was not authored about the work: it was text the run's **environment** produced, carried into tracked
text. That reaches a branch two ways:

1. **Verbatim environment output.** A tool's stdout or stderr captured into a log (R temp dirs, duckdb notices, uvx
   install lines), or a server's error message quoted into findings. The machine writes it; nobody chooses its
   content, so it carries whatever state the machine is in.
2. **The agent's notes on where each step ran.** To explain why a step ran in one place and not another, the plan and
   findings describe the machines: what each has installed, what it holds, which runs what, what state it was in.
   This is the route round 2's leak took (an operational note about a failed test, enriched with what was
   learned while diagnosing it), and it is the one that survives round 2's fix.

`public_sweep.py` and a grep for host names catch neither, because neither carries an identifier: route 1 carries
random paths and timings, route 2 carries roles ("the store-build machine") and states.

## Findings

- **[severity: security]** planning/active/findings.md:75, planning/active/progress.md:46,
  planning/active/review-round2.md:16-17 — the removed fact (quotes removed here) were still there after round 2, in findings, progress and round 2's own text. Round 2's own suggested replacement carried
  the state forward, so this is a finding inside the previous fix. The point the row needs, that the one error is not
  the branch's, holds without the machine: "1 error, in `test-link_flow.R:67`, raised by the database server, not by
  R code; no R code changed on this branch". Both commits carrying it (abcfa914, 5e498ba5) are unpushed (origin's
  branch tip is fa8ad1d2), so an amend leaves no public revision. The machine fact belongs in memory, not here.
  - **Rule:** none

- **[severity: security]** planning/active/task_plan.md:29-32 and 45-46, planning/active/review-plan.md:30,
  planning/active/findings.md:103, planning/active/progress.md:32, 36, 46 — the plan records the host topology: which machine runs what and what each one has installed (quotes removed here), restated from a private memory file into public `planning/`; feature-workflow names "which machine runs what" as topology that stays out of public text. Unlike finding 1
  this is on origin since the baseline (2deffbbd), so editing the tip removes it from the file, not from the
  branch's public commits. Lower severity than finding 1, and there is precedent in the #216 and #223 archives ("the
  second machine", "on the machine that rebuilt five stores for #217"), so this is the owner's call; if it is cut,
  state requirements instead of machines: "0270 runs beside the PDFs and a synced Zotero; the build and push need
  cred 0.8.0, ragnar 0.4.0 and a real `data/rag/`, run from a worktree of this branch".
  - **Rule:** none

## Every place the mechanism reaches, and the verdict

| place | route | carries something learned about a machine? |
|---|---|---|
| findings.md:75 (Errors row, test error) | 2, plus a quoted server error | **yes** (finding 1) |
| progress.md:46 (the test error's cause) | 2 | **yes**, same fact (finding 1) |
| progress.md:47 and commit 5e498ba5's subject | 2 | no values. Fine |
| review-round2.md:16-23 | 2 (quoting the leak's description) | **yes** (finding 1) |
| task_plan.md:29-32, 45-46; review-plan.md:30 | 2 | **yes**: which machine runs what and has what (finding 2) |
| findings.md:103; progress.md:32, 36 (a machine's role label) | 2 | role label only; part of finding 2's topology, harmless alone |
| findings.md:66-67, task_plan.md:74, review-plan.md:16 (Chrome saved to the last-used folder, not `~/Downloads`) | 2 | browser default behaviour and a generic `~/` path; no machine-specific path or user name. Fine |
| findings.md:104-106 ("11.6 min (17:08:29 to 17:20:04 UTC)"); log start/end stamps | 1 | a run's duration on an unnamed machine; precedent (#124's "build 8 min 41 s"). Does not identify a host. Fine |
| query logs, rebuild log: `ℹ /tmp/Rtmp<random>/duckdb` (7 in query logs, 3 in rebuild log) and the duckdb notice | 1 | a random R session temp dir, gone at exit; no user name or host; the notice says `~/.duckdb` is absent, a trivial config state. Precedent: 20261116_query_statistics_before.log, 20261121_query_statistics*.log, 20261121_rebuild_statistics.log carry the same lines. Fine |
| rebuild log: eight "Installed 48 packages in N ms" | 1 | uvx's per-worker install of markitdown: worker count (8) and cache timings; no identifier. Precedent: 20261116_build_statistics.log (8 lines), 20261121_rebuild_fish_passage.log (6). Fine |
| rebuild log header: "Zotero quit, zotero.sqlite-wal 0 bytes" | 2 | the procedure's gate state, which CLAUDE.md requires recording; precedent 20261121. Fine |
| push log: "Uploading statistics.duckdb (152 MB)", `bytes`, md5, ETag, branch, head_sha | 1 | the store's size and identity, not a machine's; the manifest has no host field (cred writes none). Fine |
| query logs: `origin` `/User…` | 1 | truncated before any user name (accepted). Fine |
| 0270 logs (dry runs, live, measures) | 1 | Zotero keys, DOIs, collection sizes in MB of library content; nothing about a machine. Fine |
| 20261125_rebuild_statistics_expected.txt | 2 | "from a copy of zotero.sqlite with its -wal": procedure, no path. Fine |
| review-round1.md:13-16 | 2 | "from a copy of `zotero.sqlite`", arithmetic on logs; nothing about a machine. Fine |
| enumeration_round0.tsv, data/detection_additions.csv | none | repo-relative `data/rag/pdf/detection/` paths only. Fine |
| commit messages f0a6cbd0..HEAD (15) | 2 | subjects and one body; none names a host, path, size, port, user or process. Fine |
| #274 body | 2 | "through a browser", Unpaywall/ResearchGate routes, store counts; nothing about a machine. Fine |
| #278 body | 2 | "measured 2026-11-24 from a guarded copy of the local database" (the Zotero database, no path). Fine |
