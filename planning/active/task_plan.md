# Task: Backlog pass: batch the open issues into moves with umbrellas (#169)

**If we do it:** the open issues are grouped into a short list of moves, each an umbrella issue carrying the batches that share files or a cost, planned with one `/planning-init` and landed in one PR, in an order kept in `planning/backlog.md`. Issues whose premise has been met or superseded are closed with the reason. **If we never do:** 58 open issues are picked one at a time by whoever remembers them, issues already done stay open (at least two were finished by a later PR and never closed), and work that shares a file or a retune is paid for more than once.

## Problem

The repo has 58 open issues (2026-11-09), filed over two months across the report corpus, the FISS workbook track, Zotero and the stores, the tuning and its articles. Nothing records which ones edit the same files, which wait on the same retune or upstream change, or which are already done. Several larger efforts already run as tracks with their own umbrellas (baselines, speed, provenance, minimal-run), so the rest need the same treatment without being folded into them.


## Context

The repo has 58 open issues, with no record of which edit the same files, wait on the same retune or upstream change, or are already done. The backlog-sweep procedure calls a pass this size planned work, so #169 carries it. Steps 0–4 of the sweep (reading every body and its comments, measuring, grouping) already ran in this session on 2026-11-09. This plan parks that work in the PWF first, so nothing is re-read, and then runs the sweep's steps 5–8 off this one gate: **approving this plan is the go for the sweep**.

Branch `169-backlog-pass-batch-the-open-issues-into`, cut from origin/main at b69365b.

## What the read found (lands in findings.md)

- **Reference graph** (open issues named in open bodies). Most named: #120 (6), #118 (4), #64 (3). #118 is the hub of the articles work; #120 is a track.
- **Premises checked against main:**
  - #68 is done: 9f4b21bd (#73's PR) set `grid_grad` to 3–30 % for every species (`R/tune_grid.R:52`), and #92 and #145 republished on it.
  - #72 is done in the same commit. The curve carries `edge_stream`, `0320` reads `ref_edge` from the curve (`scripts/0320-tune-run.R:573`) and records `discharge_load` (`:552`), and the readers compare both.
  - #3 is superseded by `0154-corpus-tag.R` (7232d463), which writes `data/corpus_tags.csv` (content tags, `farmed`).
  - Still open in the code:
    - #34: `0250:136` reads the gradient as a fraction.
    - #31: the BULK CO migration row has no end date.
    - #142: no skip in `test-link_place.R:32`.
    - #77: no scale bar or keymap in `R/compare_map.R`.
    - #81: `GPKG` still defaults on (`0330:90`).
    - #115: no `structures` row in `settings.csv`.
    - #136: `0310` never writes `fdis_sites.csv`.
    - #156: "rule" is still in the README.
    - #168: `0153:49` reads the key from the environment only.
    - #107: the pin still follows the build's `fwapg_sha` (`data-raw/vignette_bib.R:94`).
- **Peer state (2026-11-09):**
  - Still open: link#460, link#463, link#462, link#444, link#434, link#400, link#402, link#343, link#346, cred#45, fresh#257, wet#6, flooded#14, floodplains#123, fly#108.
  - Closed:
    - wet#70: unblocks #42's 7-day minimum.
    - wet#126: #96's first consumer.
    - link#294: #23's consumer.
    - link#364: the wetland door, done here by #73.
    - link#432, link#433, link#415, link#441, link#331, fresh#259, fwapg#25, cred#44.
- **Visibility:** link, fresh, wet, cred, gq and fly are public; the skills repo is private, so the file names it only in words.
- **Recurrences:**
  - #136 hit again on 2026-11-05 (PR #150).
  - #159's stall came back after PR #157.
- **CI:** the last 5 runs are green; the one `cancelled` is a superseded Pages run.

## Decided at the gate

Approving this plan means the following (Al, 2026-11-09). Strike any line before approving to drop it.

- **Closures**, each with a comment giving its reason:
  - **#68**: done in 9f4b21bd.
  - **#72**: done in 9f4b21bd.
  - **#48**: done in PR #50. What remains is automatic: `0280` refuses an abstract row once the item has a PDF.
  - **#80**: superseded. #141 reports the pick from the flow start, and #73 built the door. Its one open item (decide with link which method sets link's flow numbers) is written into #139's "To file" first.
  - **#3**: superseded by `0154`.
- **Transfer:** #8 goes to the skills repository, where the skill would live.
- **#23 scope:** cut to what #137 needs, because link#294 has closed. This is decided at move 6's gate, not edited now.
- **#120:** tick its answered premise box ("Closes: … 2.8 % against 1.5 %") in the body.
- **The 11 moves below**, filed as umbrella issues labelled `umbrella`, with the titles and bodies in `planning/active/umbrellas.md`. That file is copied verbatim from this session's draft, and Al has the draft's path.

| move | batches: members | state |
|---|---|---|
| 1 | 1: #136, #142 | open: start here |
| 2 | 2: #118, #107, #156; 3: #159 | open |
| 3 | 4: #168, #151, #126; 5: #20, #95 | open |
| 4 | 6: #81, #77; 7: #90, #64 | open (after move 2) |
| 5 | 8: #31, #96, #108; 9: #42, #105 | open |
| 6 | 10: #23, #137 | open |
| 7 | 11: #7, #34, #10; 12: #17, #2, #1 | open |
| 8 | 13: #115, #63, #148 | **waiting** on Al's word for the next full retune |
| 9 | 14: #132, #131; 15: #70, #71 | **waiting** on link#434, link#400, fresh#257 |
| 10 | 16: #13, #14, #16 | open |
| 11 | 17: #4, #15 | **waiting** on Al's word to resume the report-priority pipeline |

- **Tracks**, named in the file and never folded into moves:
  - baselines: #139 → #140
  - speed: #85, #101
  - provenance: #162, #165
  - minimal-run: #120
- **Singles:** #51, #76, #130 (cred#45), #33 (Track 3 only), #11.
- **#169 itself** is named on the file's `**Verified:**` line and closes with this PR.
- **Placed count:** 58 = 40 batched, 7 in tracks, 5 singles, 5 closed, 1 transferred. Any issue filed before the freeze joins the open move whose files it touches, or is reported if none fits.

## Phase 1: Park the read
- [x] Write `planning/active/findings.md`, holding:
  - the issue context;
  - the reference graph;
  - the premise checks with their evidence;
  - the peer-state table;
  - each issue's placement and the reason for it;
  - the closures.
- [x] Copy the umbrella drafts into `planning/active/umbrellas.md`.
- [x] Commit them with the baseline, so the read survives a `/clear` or a move to another machine.

## Phase 2: Freeze
- [x] Re-list the open issues and write `backlog_frozen.txt` to the git directory. Place any issue filed since the read and note it in findings.

## Phase 3: Write the backlog file
- [x] `planning/backlog.md` in the shape the sweep sets out:
  - the `**Verified:**` header naming #169;
  - Moves (with umbrella placeholders);
  - the tracks line;
  - Order;
  - one `### <n>.` section per batch, each with its `- [ ] Carried by move` line;
  - Singles;
  - Closed and transferred.
- [x] Run the coverage check: every frozen issue is named in the file.

## Phase 4: Public scan
- [x] Draft each umbrella body to `umbrella_<n>.md` in the git directory, each ending with the backlog pointer and `/planning-init <this issue>`.
- [x] Run `public_leak_scan` on those bodies and on `planning/backlog.md`. If the scan forces a rewrite, show the rewritten body to Al before filing it.

## Phase 5: File, write in, close
- [x] File the 11 umbrellas (`--body-file`, label `umbrella`), then write their numbers into the Moves table and the batch sections.
- [x] Run the tick check: every open move ticks cleanly on a copy of the file (`backlog_moves.sh tick`).
- [x] Add #80's open item to #139's "To file", then make the five closures, each with its comment.
- [x] Transfer #8.
- [x] Tick #120's premise box.
- [x] Commit the backlog file and the checkbox flips.

## Phase 6: Hand link its pass issue
Decided at the gate (Al, 2026-11-09): this is a phase of #169, run once knowledge's moves are filed so that the list of waits is final.
- [ ] File a backlog-pass issue in link (link has 117 open issues, no umbrellas and no `planning/backlog.md`, so its sweep is planned work run under that issue), modelled on #169. Its body carries:
  - **The list of link issues knowledge's moves wait on**, each with the knowledge umbrella and what it holds up:
    - link#434 and link#400: move 9 (access).
    - link#402: the record rules #132 reads.
    - link#460: #120's last task.
    - link#463, link#462 and link#444: the parent-gradient setup.
    - link#346 and link#343: the flow-number decision in the baselines track (#139).
    - link's rainbow trout un-pause: #148 in move 8.
  - **The convention:** link's backlog places each listed issue with the knowledge move that waits on it, in words; each later pass on either side re-checks the other through the sweep's peer search.
- [ ] Write the link issue's number into `planning/backlog.md`'s header beside the waiting moves.
- [ ] Get Al to read the link body before it is filed: link is public, and the body goes through the same public scan.

## Phase 7: Land
- [ ] `/code-check` on the branch. The diff is markdown only, but the convention reviews anything an agent loads as instructions, and the backlog file is read by `/compact-prep` and `/gh-pr-merge`.
- [ ] `/planning-archive`, then `/gh-pr-push` (the PR closes #169).
- [ ] Report `backlog_moves.sh next`.

## Validation
- [x] Coverage check passes (Phase 3)
- [x] Public scan is clean (Phase 4)
- [x] Every open move ticks cleanly on a copy (Phase 5)
- [x] `backlog_moves.sh next` names move 1
- [ ] `/code-check` clean
- [ ] PWF checkboxes match the landed work
- [ ] `/planning-archive` on completion

Approve runs every phase to the PR. To park, reject with `park`: the baseline (with the parked read) is written and pushed, nothing more.
