# Code-check round 3: branch 169-backlog-pass-batch-the-open-issues-into

## Checklist read

- code-check-python.md: in full (none applies: no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with evidence blocks and table rows stripped. Applied:
  "A guard's scope, escape hatches, and remedies" (a compression of several sources is executed against each source,
  not against itself; terminate by enumeration), "One fact derived twice" (a count and its members from different
  producers), "The probe is broken before the world is" (fetch the authoritative copy). `## Rules that stand alone` and
  later: headings only; none names a shape this markdown-only diff uses.
- code-check-shell.md, code-check-r.md, code-check-spatial.md: headings only. The diff adds no shell, R or spatial code.
- Every code probe ran on `origin/main` (b69365b1, fetched at the start of the round), never the checkout. Issue
  bodies and comments were fetched live on 2026-11-09.

## The mechanism

The earlier rounds' defects share one shape: a verdict ("done", "superseded", "what remains is X", "its chinook part
landed") written from a summary of an issue, or from the half of its asks that a recent PR touched, instead of from
walking every task, checkbox, "Decided" line and "Done when" item in the body against the code. The fix in round 2
reproduced it: #72's reopened remainder was itself written from two of the four places that still read or write the
literal. So the candidate set is every verdict about an issue's state, and each was checked by listing the issue's
asks and giving each one a verdict.

## What was checked (counts)

1. The four remaining closures, every ask in each body (16 asks):
   - #68 (5: extend `grid_grad`, retune every species, republish/compare/article, research files and the cross-species
     table, README example and figure): all done. `R/tune_grid.R:52` runs 3-30 %; `research/habitat_thresholds_tuned.md`
     tables give each key's limit up to 30 %; `data/thresholds.csv` CH gradient 0.13 matches README:57; README figure
     regenerated in 91ae2f5d (#145). Closure correct.
   - #48 (2: the rows, and "What remains"): rows 1137-1145 landed in PR #50; "What remains" is a conditional the gate
     already enforces. Connolly & Petersen 2003 and Smith & Griffith's 100 mm figure are recorded in the body's own
     "As built" as unobtainable, not as open work. Closure correct.
   - #80 (5 tasks): re-pick from the flow start at 1 and 1.96 SE: done (9f4b21bd; `rule_flow_196`,
     `R/thresholds_table.R:118-121`; #141 measures it). Decide with link: moved to #139's body (line 39, verified).
     Retune with #73/#68: done. Wetland door: done (`inst/method/settings.csv:68`). **Article and research files: a
     section comparing against both starting points: research files yes, article no** (finding 3).
   - #3 (6: classify from content, assign tags, write to Zotero and a CSV, record the farm/skip decision and its reason,
     farm list as a query over tags, flag table-dense skipped reports): tags, CSV, caption count done; Zotero write
     waived in the comment; **the decision and its reason not recorded and not waived** (finding 4).
2. Other state claims: 41 checked.
   - planning/backlog.md, 19: #64's chinook part (**wrong**, finding 2); #72's remainder (**incomplete**, finding 1);
     #96's consumer wet#126 closed (ok); #42 unblocked, wet#70 and fwapg#25 closed (ok); #23's consumer link#294 closed
     not planned (ok); #107 folded into #118 (ok, both bodies); #70's step 1 owes PSCIS and FISS, and the parent reading
     is #120's (ok); #148 waits on link's un-pause (ok); #132's literature step can start (ok); #33 Tracks 1-2 done (ok);
     #4 parked, B2-B6 unfixed (ok: B2 `0153:43`, B3 `0161:77-79`, B4 `0162:29`, B5 `0110:12` still on main); #130 on
     cred#45, open (ok); #120's last task on link#460, open (ok); move 9's waits link#434, link#400, fresh#257 open (ok);
     the link-pass line, moves 8 and 9 plus two tracks (ok); the four Closed and transferred lines (#68 ok, #48 ok, #80
     and #3 see findings 3 and 4; #8 no longer resolves in this repo, ok).
   - findings.md, 9 beyond round 2's: the #72 row (finding 1), #80 and #3 rows (findings 3, 4), #120 and #23 rows (ok),
     "Only #4 carries comments that change its spec" (ok: of 65 issues fetched, only #4 has comments, #72's are the
     pass's own), the peer-state table's 16 open peers (all open), the "Closed since" list's 12 peers (all closed).
   - task_plan.md, 3: line 21 (finding 1), line 84 and the move table's row 8 (finding 5).
   - Umbrella bodies #170-#180, 7 claims: #171's #107 folded (ok); #172's auto-mode refusal of #124's merge (ok, #124's
     archive progress.md:66); #174 daily flow unblocked (ok); #175 consumer closed (ok); #177's #72 row and Touches
     (finding 1); #178's waits (ok); #180's parked date (ok).
   - #139's "Moved from #80" line and its claim that #141 reports the flow-start pick (ok).
   - link#468: live body identical to `link_pass.md` apart from two trailing blank lines; "Two of those moves, and two of
     knowledge's tracks" (ok); its 11 link issues' states (9 open as stated; link#432 and link#433 closed, cited only
     as history) (ok).
3. Counts, recomputed from the batch sections and live issues:
   - Moves table: 11 rows, each "(N issues)" equals the sum of its batches' Order counts (2, 4, 5, 4, 5, 2, 6, 4, 4, 3, 2).
   - Order table: 17 rows, each count equals the issues named in its row; total 41.
   - findings.md:153: 41 + 7 + 5 + 4 + 1 = 58, and each of the 58 placement rows matches the batch that names it.
   - Coverage: 65 issues open now (59 at the freeze, less 4 closed and 1 transferred, plus 11 umbrellas, with #72
     reopened), every one named in `planning/backlog.md`.
   - link#468's waiting list: two moves (8, 9), matching the backlog's link line.
   - task_plan.md:84: stale (finding 5).
- Public scan of the added lines: no home paths, hosts, ports, credential paths or private-repo links. `rtj` (accepted)
  and the skills repository's name in review-round1.md:16 (round 2's note; `CLAUDE.md` says `planning/` may name our
  other repositories) are not reported.

## Findings

- **[severity: fragile]** #72's reopen comment (GitHub, 2026-11-09T21:55Z), planning/backlog.md:161, planning/active/findings.md:41, planning/active/task_plan.md:21, and #177's body (its #72 row and its Touches line). Each states #72's remainder as "`0330` and `0325` still gate on the `ref_population` literal" (and `0320:665` writes it). That is two of the four places on origin/main that still read the literal, and one of two that write it. `scripts/0322-tune-grad-extend.R:266` (`done_rule()`) gates on `identical(unique(readRDS(g)$ref_population), "stream_branch")` and `:284` writes the literal. `data-raw/vignette_chinook.R:104` refuses a grade table on the same literal. #72's body names `0322` twice: in its Problem ("`0322`'s `done_rule()` ... check that literal") and its "If never" (a literal "that `scripts/0320` and `scripts/0322` write"). Its "If done" asks that "every consumer checks that". A move-8 planner working from these remainders would fix `0330` and `0325`, then close #72 with `0322` and the chinook bundle still passing on the hand-written label. This is round 2's defect again, inside its own fix: the remainder was written from the files a reviewer named, not from the issue's asks. #177's Touches also omits `scripts/0330-compare.R`, which is the first place the remainder names. task_plan.md:21 still ends "and the readers compare both", contradicting its own parenthesis. `git grep ref_population origin/main -- R/ scripts/ data-raw/` lists every site.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a compression is executed against each source; terminate by enumeration)
- **[severity: fragile]** planning/backlog.md:114 (batch 7): "#64 (one template per species; its chinook part landed in PR #147)". Only one of #64's chinook asks landed in PR #147: the ticked box, which moves the method sections behind links to the methodology article. #64's "Chinook rewritten to it first (with its vignette, in #118)" is unticked. #118's plan still carries "#64's chinook part: the case study in #64's order (life history and prior, evidence, what the data supports, recommended and why, what it draws, left open)", also unticked. PR #147 orders the article answer and map first, not prior first. A move-4 planner would take chinook as done and write the template for the other species only. Batch 2's summary (backlog.md:72-73) does not mention #64's chinook part, so the chinook case study in #64's order is carried only inside #118's body.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"
- **[severity: fragile]** #80's closure comment (GitHub), planning/backlog.md:206-207, planning/active/findings.md:42, planning/active/task_plan.md:56. #80's last task reads "Article and research files: a section comparing against both starting points". Its "Decided" section says "The flow comparison is a section of the same article and research files". The research files have that section (`research/habitat_thresholds_tuned.md:180` and `:311`, `research/chinook_rearing_tuned.md:60`). No article on origin/main does: `git grep -i -E "flow (start|version)|starting point" origin/main -- vignettes/` returns nothing, and #143's rewrite (462ff8ec) deleted the article's only sentence about the starting point. The closure comment accounts for the other four tasks and moves the link decision to #139. It says nothing about the article section: the section is not done, not moved, and not judged unneeded. Either move it (for example into #118's or #64's chinook case study) or say in the comment why it is not needed.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"
- **[severity: fragile]** #3's closure comment (GitHub), planning/backlog.md:208, planning/active/findings.md:44. #3's step 4 asks to "record the farm/skip decision and its reason alongside, so triage becomes reviewable rather than a regex buried in a scratch script". `data/corpus_tags.csv`'s `farmed` is `n_priority_rows > 0` (`scripts/0154-corpus-tag.R:109-110`). It records whether a report yielded priority rows, not whether it was farmed or skipped. On main all 163 TRUE rows have rows and all 120 FALSE rows have none, so a report farmed with no rows reads as skipped. No column holds a reason. The comment calls this "the farm flag" and waives only the Zotero tag write, so this ask is closed as covered when it is not. Either say in the comment that the decision and reason are not needed, or keep the ask open somewhere named.
  - **Rule:** code-check.md "A proxy is not the property"
- **[severity: fragile]** planning/active/task_plan.md:84 ("58 = 40 batched, 7 in tracks, 5 singles, 5 closed, 1 transferred") and the move table at task_plan.md:72 (move 8: "13: #115, #63, #148"). Both are stale since #72 was reopened. findings.md:153 says 41 batched and 4 closed, and batch 13 holds four issues. The #72 closure line in the same section was struck through and annotated, but these two lines were not, so the archived plan contradicts itself and the backlog.
  - **Rule:** code-check.md "One fact derived twice"
