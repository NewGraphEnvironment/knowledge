# Code-check round 4: branch 169-backlog-pass-batch-the-open-issues-into

## Checklist read

- code-check-python.md: in full (none applies: no Python in the diff).
- code-check.md: `## Mechanisms` prose (the section header, "A guard that fails toward pass", "A guard's scope, escape
  hatches, and remedies", "One fact derived twice", with the other mechanism headings); `## Rules that stand alone` and
  later by heading ("Documentation Staleness" read). Applied: "A guard's scope, escape hatches, and remedies" (a
  remainder written from a summary is checked against every ask of its source; terminate by enumeration), "A proxy is
  not the property", "One fact derived twice", "The probe is broken before the world is" (a shell-grep coverage probe
  reported 35 issues missing; re-run with a Python parser, none missing).
- code-check-shell.md, code-check-r.md, code-check-spatial.md: headings only. The diff adds no shell, R or spatial code.
- Code probes ran on `origin/main` (b69365b1, fetched at the start of the round). Issue bodies, comments and edit
  histories fetched live on 2026-11-09.

## What was checked (counts)

1. `ref_population` on origin/main, every hit in R/, scripts/, data-raw/, tests/, vignettes/, inst/ (22 code hits; none
   in vignettes/ or inst/; plus 2 man/ examples and 7 tracked `data/tune/*_grades_record.csv`):
   - gates on the literal value (4): `scripts/0330-compare.R:274`, `scripts/0325-publish.R:81`,
     `scripts/0322-tune-grad-extend.R:266`, `data-raw/vignette_chinook.R:104`. All four are named.
   - presence of the column only (3): `0325:79`, `0330:274` (the `%in%` half), `R/grade_record.R:3` via `:78` (the
     record writer refuses a table without the column). Not a gate on the literal; not a finding.
   - writes (2): `0320:665`, `0322:284`. Reads as a log label (1): `0320:650`.
   - comments and messages (5): `vignette_chinook.R:96`, `0320:660`, `0322:26`, `0322:259`, `0330:291`.
   - fixtures and examples (7): `R/grade_receipt.R:50`, `R/grade_record.R:56`, `data-raw/evidence_receipt_compare.R:44`,
     `tests/testthat/test-archive.R:73`, `test-grade_receipt.R:15`, `test-grade_record.R:7` and `:57`,
     `test-tune_promote.R:35` (8 lines, 7 files).
   - Also: `0325` checks `ref_edge` only for agreement across tables (`:112-113`) and derives `stream_branch` from it
     (`:176`); `0330` never reads `ref_edge`; `0325` publishes the grade's flow load and refuses a live difference
     (`:114-118`), so #72's fourth proposal bullet is done. The comment's line numbers all hold on b69365b1.
   - Places stating the list (6): #72's reopen comment, backlog.md:163-165, findings.md:41, task_plan.md:21, #177's #72
     row and its Touches line. All name the same four readers. **Complete.**
2. #3: 7 asks (classify from content; tags; tags to Zotero; manifest CSV; record the farm/skip decision and reason;
   farm target list as a query over tags; flag table-dense skipped reports), 2 notes, and 7 places that state the
   remainder (the reopen comment, backlog.md:56 and :195-196, #180's row and "Why here", findings.md:44 and :96,
   task_plan.md:22 and :57). One finding (1).
3. #80: 5 tasks, 3 "Decided" lines, and the Problem's "needs deciding": all 9 done, moved or folded. Places (6): the
   closure comment, #139's moved line, backlog.md:210-211, findings.md:42 and :123, task_plan.md:56. One stale count
   (finding 2).
4. #64: 5 boxes; #118: its "Folded in" line, the #64 bullet and the plan item for #64's chinook part (3). Backlog
   batch 7 (114-116), findings.md:116 and #173's batch 7 agree with them: the chinook case study in #64's order is
   #118's, the template, `research/README.md` and coho are #64's. Clean.
5. Bodies (17): #170-#180, #139, #120, #72, #3, #80, link#468. Each full, tables intact; each umbrella's members table
   equals its backlog batch sections (17 sections, 42 issues). Edit histories: #177's four revisions (create 1487 B, +#72
   row 1628 B, blank, restore 1774 B): the restore keeps every line of the pre-blank revision and changes only the
   Touches line and the #72 row, as intended. #180 (3 revisions: +blank line, then the #3 row and "Why here"), #139
   (the moved line, then its extension), #120 (one box ticked) changed only as stated. #72, #3, #80 bodies untouched by
   the pass (last edits October). link#468 equals `link_pass.md` bar the accepted trailing blank lines.
6. Counts: Moves 11 rows, each "(N issues)" equals its batches' Order counts; Order 17 rows, each count equals the issues
   named, total 42; findings.md placement table 58 rows = 42 batched + 7 tracks + 5 singles + 3 closed + 1 transferred,
   each batched row's move and batch matching the backlog; findings.md:153 and task_plan.md:84 say the same; task_plan's
   move table matches. On a copy: `list` reads 11 rows; `next` prints `/planning-init #170`; all 11 moves tick
   (`TICKED`, no stderr), 17 batch boxes ticked, then `next` is `NONE: every move is ticked`. Coverage: 66 issues open
   (55 frozen and still open plus 11 umbrellas), all named in backlog.md.

Public scan of the added lines: no home paths, hosts, ports, credential paths or private-repo links; `rtj` and the
review-round1.md:16 name are accepted per earlier rounds.

## Findings

- **[severity: fragile]** #3's reopen comment (GitHub, 2026-11-09T22:05Z), planning/backlog.md:195-196, #180's #3 row,
  planning/active/findings.md:44 and :96, planning/active/task_plan.md:22 and :57. Each states #3's remainder as ask 4
  alone ("record the farm/skip decision and its reason"), with the Zotero write waived. Two more asks of #3's body are
  neither done nor waived. (a) "Then the farm target list becomes a **query over tags** ('everything tagged
  `crossing-inventory` not yet farmed') instead of a hand-built title regex": on origin/main nothing reads
  `data/corpus_tags.csv` (`git grep corpus_tags` hits only `0154`, `scripts/README.md`, `CLAUDE.md`, `inst/NOTICE.md`),
  and the farm still takes a hand-built target list (`scripts/wf_farm_priority.js:20-24`, `A.targets`). (b) "flag
  reports that are table-dense but were skipped": `0154:122-128` lists `n_table_captions >= 5 & !farmed`, and `farmed`
  is the same rows-yielded proxy the comment faults, so a report farmed with no rows is listed as skipped. A move-11
  planner working from the comment would add a decision and reason column and stop, leaving the target list
  hand-built and the flag on the proxy. Name both as the remainder (they follow from ask 4), or waive them in the
  comment.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a remainder is checked against every ask
    of its source); code-check.md "A proxy is not the property" for (b)
- **[severity: fragile]** planning/active/findings.md:42. #80's verdict cell reads "superseded, one task moved", and its
  evidence cell names only the re-pick and the door. Since round 3, two items moved to #139 (the link decision and the
  articles' section comparing both starting points), as findings.md:123, backlog.md:210-211, task_plan.md:56, #80's
  closure comment and #139's body all say. The archived record contradicts itself on how much of #80 remains.
  - **Rule:** code-check.md "One fact derived twice"
