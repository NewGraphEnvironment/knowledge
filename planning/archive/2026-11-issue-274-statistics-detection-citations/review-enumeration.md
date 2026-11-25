# Code-check enumeration for #274, ending the loop (2026-11-25)

Rounds 3 to 5 each found the same class one step past the previous fix: text learned about a machine reaching a
public repo by (1) tool or server output captured verbatim, (2) the agent's notes on where each step ran and what each
machine has, (3) review files quoting or describing what they flag. Round 4 found a defect inside round 3's fix (the
fix landed on top of unpushed commits that still held the text), and round 5 one inside round 4's (round 4's own file
listed the host names it had grepped for). So the loop ends on this enumeration, not on a quiet round.

The candidate set: every line a push would publish, against two checks run on the final tree (staged, so the review
files are tracked when the sweep reads them).

| check | set | result |
|---|---|---|
| #56 `public_sweep.py tree`, its identifier patterns (host, private repo, project slug, local path, key path, db) | every file the branch adds or changes, 22 files | 0 hits |
| #56 `public_sweep.py commits` | the branch's commit messages | 0 hits |
| a fact-kind grep (disk, space, container, deploy, volume, capacity, host, machine, server, port, connection terms, home and temp paths, GB) over the 965 added lines, each hit read and given a verdict | 965 added lines | every hit is generic (a PDF on disk, a rule's own wording, library collection sizes, a review describing a kind with no value) or accepted (findings.md's "raised by the database server, not by R code") |
| #274 and #278 bodies | read | nothing learned about a machine |

Pushed history (f0a6cbd0..fa8ad1d2) is not rewritten, because the `statistics` store's manifest names 1e89da92 in it.
It carries the earlier plan wording on where each step ran and no host name, user path, port or login.

The commit shas the round files cite for unpushed commits (1e43a18e, abcfa914, 5e498ba5, 0e0ea2d5, 81a749ac) were
folded into one commit before the push and resolve to nothing; they stand as the record of each round.
