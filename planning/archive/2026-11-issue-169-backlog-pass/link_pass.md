**If we do it:** link's open issues are grouped into a short list of moves, each an umbrella issue carrying the batches that share files or a cost, planned with one `/planning-init` and landed in one PR, in an order kept in link's `planning/backlog.md`. The link issues that knowledge's tuning is waiting on are placed knowing what each one holds up there. **If we never do:** link's open issues are picked one at a time, and an issue that blocks knowledge's work looks no more urgent than any other from its title.

## Problem

link has 117 open issues (2026-11-09), no umbrella issues and no `planning/backlog.md`. knowledge ran the same pass on its own 58 (NewGraphEnvironment/knowledge#169), which ended in eleven move umbrellas and a backlog file. Two of those moves, and two of knowledge's tracks, wait on link issues, and that dependency is visible only from knowledge's side.

## Proposed

A backlog pass for link with `/backlog-sweep`, run as planned work under this issue (`/planning-init` on it), because of its size:

- [ ] Read every open issue body and its comments; measure the reference graph, each older premise against the code, and the state of peer issues a batch waits on.
- [ ] Group by the files a batch edits and the cost it shares (a provincial run, a config change, a release), not by topic; fold the batches into as few moves as can be held at once.
- [ ] Place each link issue in the table below knowing which knowledge move or track waits on it, and say so in its batch section, in words. A batch holding one of them ranks by what it unblocks downstream as well as by link's own needs.
- [ ] Report once at the plan gate; on the go, write `planning/backlog.md`, file one umbrella per move, close what was agreed, and open the PR.

## What knowledge waits on (2026-11-09)

| link issue | knowledge work it holds up |
|---|---|
| NewGraphEnvironment/link#434 (barriers each override lifted) | NewGraphEnvironment/knowledge#178, move 9: tuning on link's access with leave-one-out (NewGraphEnvironment/knowledge#131) |
| NewGraphEnvironment/link#400 (what counts as a known record) | the same move: which records lift a barrier |
| NewGraphEnvironment/link#402 (species presence against records) | NewGraphEnvironment/knowledge#132 in the same move: the record rules its access-gradient review reads |
| NewGraphEnvironment/link#460 (the `grad-fwa` token) | the last task of NewGraphEnvironment/knowledge#120 (archiving the Atlas-line setup) |
| NewGraphEnvironment/link#463, NewGraphEnvironment/link#462, NewGraphEnvironment/link#444 (classify on the parent gradient; the near-river distance under it; parent attributes) | link drawing NewGraphEnvironment/knowledge#120's parent-gradient pick |
| NewGraphEnvironment/link#346, NewGraphEnvironment/link#343 (threshold calibration; GR, RB and KO MAD minima on wet's flows) | NewGraphEnvironment/knowledge#139's baselines track: which method sets link's flow numbers, and grayling's baseline (NewGraphEnvironment/knowledge#140) |
| rainbow trout's return to `default` (paused under NewGraphEnvironment/link#432's tracker) | NewGraphEnvironment/knowledge#148 in NewGraphEnvironment/knowledge#177, move 8: the rainbow trout key's return through promotion |

## Keeping the two backlogs in step

- knowledge's waiting moves name the link issue they wait on; link's backlog names, in a placed issue's batch section, the knowledge move that waits on it.
- Each later pass on either side re-reads the other through the sweep's peer search (open issues and PRs on the subject), so a link issue closed or a knowledge move finished shows up at the next pass rather than by memory.

## Done when

- [ ] Every link issue open at the freeze is named in link's `planning/backlog.md`, and each one in the table above says which knowledge work waits on it.
- [ ] Every open move ticks cleanly on a copy of the file, and the next move is named.
