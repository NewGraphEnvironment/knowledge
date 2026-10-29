## Outcome

#101 asked whether link's `default` rule, regenerated unchanged on every `0330` rerun, is worth caching. Al ruled at the
plan gate to measure and stop: link's stream layers are being reworked, so a cache keyed on today's build would be
reset before it paid. Mid-run, #112's branch turned out to be timing each rule on the same lines of
`.knw_compare_bin()` and measuring on the database at that moment; Al ruled #112 first, and this branch read its
measurement rather than contend with it. After #112 merged (PR #116), this branch kept #112's timing and added, on top,
a per-worker projection (`bin_minutes`, with `walk_dropped`) and a log line naming the rules whose predicate reads the
near-river table, retired its own measurement script, and wrote `default`'s cost into `research/database_builds.md`,
"Reading `default`'s flags instead of making them" (also linked from #101's body, which now carries the parked design).
The branch review's three rounds all found prose defects, two inside earlier fixes; round 3 named the mechanism (one
computation restated by hand in six places), the roxygen became its one definition, and an enumeration of the nine
restatements left closed the loop.

## Measurement

From #112's idle-database run (every-structure runs, the structures `0330` no longer runs taken out), `default`'s share
of classify, overlay and connect worker minutes: CH rearing 74 % (9.3 own + 19.5 walk of 39.0, 20 largest groups),
BT rearing 60 % (19.2 of 31.8, 20 largest), WCT rearing 51 % (6.3 of 12.4, all 16). For CH rearing only `default`'s
predicate reads the near-river table (checked by building every fitted species' predicates at link configs 102762da,
fresh 0.44.0), so a cache would skip the walk too. Projected onto #87's host run less #112's drop (about 89 of 115.2
classify minutes): about 52 to 56 min saved, a full `0330` from about 2.5 h to 1.6 h; an estimate, since two keys were
timed on 20 groups, five borrow a share, and wall time is the slowest worker's. This replaced #101's own guess of
about 41 min (equal cost per rule), which was low: `default` costs more than the tuned rule on every key timed (BT
rearing nearly twice). Wrong turns kept: the first projection gave CO and ST #92's two-rule dropped share where #87's
run had one (round 1), and its fix rounded the borrowed keys' range up to 30 (round 2).

## Evidence

`scripts/logs/habitat/20261028_compare_structures_check*` (#112's run), `scripts/logs/habitat/20261026_compare.txt`
(#87's per-key minutes).

## Owed

- Build #101's cache when link's reworked stream layers are out and Al says so (in #101's body)

Closed by: PR for #101 (branch `101-cache-link-s-default-flags-in-the-compar`); part of #101 and #112, #101 stays open.
