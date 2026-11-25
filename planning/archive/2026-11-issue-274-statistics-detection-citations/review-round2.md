# Code-check round 2, #274 branch (f0a6cbd0...HEAD)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md` (read by heading): "Copy a live SQLite database with its `-wal`", "CSV whitespace: `trim_ws` and
  `strip.white` do not do what the name suggests". The other headings were not read (the diff adds no R code).
- `code-check-shell.md` (read by heading): "An S3 multipart ETag depends on the uploader's part size, so try every size
  that gives its part count". The other headings were not read.
- `code-check-spatial.md` (read by heading): none read (no spatial code or data in the diff).
- `code-check.md` (read by heading): the prose of all fourteen H3s under `## Mechanisms` (table rows and evidence
  blocks skipped). No heading outside Mechanisms read.

## Findings

- **[severity: security]** planning/active/findings.md:75 — the Errors table records facts learned about the database
  machine (removed here). This is a public
  repo, and the user's global rule says host specs and "anything else learned about our machines" go to memory, never
  to a public repo's code, commits, issues, PRs or `planning/`. The knowledge CLAUDE.md lists what tracked text must not
  carry (host or machine names, database hosts, ports, logins). Such facts are not on that list, but the global rule
  names specs. It came in with 1e43a18e, which is not yet on origin (origin's branch tip is fa8ad1d2), so it can be cut
  before the push without leaving a public revision. The sentence makes its point without them. Round 1's `public_sweep.py` patterns could not catch
  this, because they look for identifiers.
  - **Rule:** none

## Checked, nothing to report

- **scripts/README.md 187-191.** The build list (`LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG`) is the one the rebuild log
  ran. "Rebuild before the push" is what happened (`ACTION=build OVERWRITE=TRUE`). The added works (simulation
  studies, unmarked, circular densities, separation in logistic regression) are the six filed. "Seber 1982 join when a
  PDF is in hand" has the same meaning as the existing phrase for Wood's GAM book and the occupancy books. None of
  those books is filed either (none is in the build's left-out list), so the phrase already means "filed once a PDF is
  in hand". The other sentences that describe `statistics/detection` (scripts/README.md:561 and CLAUDE.md:141, "the
  methods literature for detection, occupancy, removal, eDNA, camera surveys and diversity") were not edited. They
  are still true, because the six works are that literature's cited methods. No other tracked sentence about the
  store gives a document count or a membership that the branch changed (I grepped `statistics`, `73PNRGJF`,
  `detection_` and "32 documents" outside `planning/archive` and `scripts/logs`).
- **Build and push procedure against CLAUDE.md:**
  - It was a rebuild, not an update.
  - The rebuild log's header records Zotero quit and a 0-byte `-wal`. The build picked up all six new keys with their
    PDFs, which shows the build's Zotero had synced. There was no `-wal` warning.
  - The before-pull ran first (VERIFY=TRUE at 17:06Z) and then the build (17:08Z). The after-queries opened the local
    store unverified (`verify = FALSE`), so nothing replaced the built file before the push.
  - Commit 1e89da92 (17:21:50Z) holds the build logs and is on origin. The push came after it (17:22:27Z), and the
    manifest's `branch` and `head_sha` name this branch and that commit, which shows `git -C` resolved to a real
    worktree `data/rag/`.
  - Nothing connected verified after the push. The ETag check (19 parts at 8 MiB, ceiling(159133696/8388608) = 19)
    follows the shell rule.
- **A later 0270 re-run over data/detection_additions.csv.** `group_copy()` returns a search hit that holds the row's
  DOI whatever its title or creators. The second `group_copy(crossref_item(...))` search covers an overridden title.
  So all six are found as `exists`, and none is created twice. `apply_override()` compares only the override fields
  (Taylor `publicationTitle`, Best & Fisher `pages`, Albert & Anderson `creators` through `creators_key`). The
  post-live dry run (dryrun2.log) shows `exists, member, pdf present` with no `would set` on those three rows, so the
  held values equal the rows' and a re-run patches nothing. `ensure()` checks `has_pdf()` before looking for the local
  file, so a re-run on a machine without the ignored `data/rag/pdf/detection/` uploads nothing. Once #278 decodes
  entities, Taylor's override still agrees with what is held.
- **Planning files against the issue body.** #274's body has the per-work outcome table and the Seber gap. No row is
  abstract-only, so review S1's sentence about abstract-only works is moot. The Validation boxes are open, as expected
  mid-check. One bookkeeping gap, not a defect: `progress.md` has no Phase 4 entry and still ends "Next: Phase 4, the
  README line and #274's body", although task_plan ticks both and both are done (fa8ad1d2, and the issue body). The
  "PWF checkboxes match landed work" box will catch it.
