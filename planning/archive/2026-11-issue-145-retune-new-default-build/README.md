## Outcome

link's new provincial `default` build (run `20261103_163715-269b585a`, link 0.78.2) shares the minimal network's flow
load and species range, so tuning on it separates the network from the other two differences between the minimal
run (#120) and the published rules. It was blocked by the build record reading every row of `<schema>.log`, which a
provincial run leaves holding the previous run's rows (link#458). The record, `0300`'s SHAs and `0310` now read the
rows of the runs `log_recompute` names; every row only where none of those runs is in `log` and `log` holds one run,
with the line saying so; a run set aside that was logged after the build is refused. `0300` takes `SETTLE_TAG=` so an
unpromoted `fresh_default` build's settle log is never the one a plain `0310` takes, and writes a `_refused` log when
the record refuses at release. With the build's evidence (the same visits, walks and species rows as the minimal
build's), `DEV=1 0320` on the nine species link models: the network alone moves four of seven picks, three of them
outside the other network's region, and every published pick both tunings scored stays in both regions. Written up
in `research/minimal_network_tuning.md`, "The full network on the same flows and range (#145)". The full candidate
and the promotion wait on Al's word.

## Measurement

- Settle released 2026-11-04T03:12:53Z on one link commit (`4dfbfa49`, v0.78.2); before the fix the record would have
  carried 0.68.0 and 0.78.2 together. On every link schema in both databases the scoped read gives the expected run
  (`findings.md`); two link test schemas are now refused (a run logged after the build; two `log` runs, neither the
  recompute's).
- Evidence (`0310`): 19 min, 45,529 visits as on the minimal build; walks and `visits_species.csv` byte-identical;
  access km within 1.5 km per species; access codes differ at 4,156 visit x species pairs (4,097 read 1 full, 2
  minimal), 58 across zero. Stored rearing +0.5 to +1.8 % on the minimal network for six species, −0.1 % sockeye;
  spawning −0.01 to −2.8 % for seven, +0.1 to +0.2 % chum and pink (first reported without chum and pink: code-check
  round 4 found the province block dropped rows with a NULL sum).
- Stream-branch visits starting their own segment: new full network 44.2 % with fish against 6.6 % empty (medians 305
  m and 466 m), between the published network's 86 % / 10 % and the minimal network's 3.4 % / 3.0 %.
- `DEV=1 0320`: 5.3 min on 14 workers. Network alone (minimal against new full): bull trout rearing (size, gradient),
  bull trout spawning (gradient, exception), chinook rearing (9 % against 13 %), steelhead rearing (MAD 0.5 against 1)
  move; coho, grayling, westslope cutthroat do not. The minimal network's bull trout rearing pick is outside the full
  network's region (80.8 behind, SE 73.2); the full network's bull trout spawning (7.1 / 5.1) and chinook rearing (10.4
  / 7.3) picks are outside the minimal network's. Grayling's move to `width>=1.5` is the flows, range or link build:
  both new builds pick it.
- Wrong turn: the first `DEV=1` pass ran every species and scored rainbow trout rearing with no access column (link
  models RB in neither build); rerun on the nine species, the seven shared keys identical.

## Evidence

`scripts/logs/habitat/default_build_145/`, `scripts/logs/habitat/*default_20261103*`,
`scripts/logs/habitat/20261103_minimal_network_check.txt`, `scripts/logs/habitat/20261104_pick_network_compare.*`,
`scripts/logs/habitat/20261104_tune_anchor_check-full-*`; the plan review and five code-check rounds are
`review-*.md` here.

## Owed

- On Al's word: the full candidate `0320` (grades) and `0330 TUNE_DIR=` on the database's host, then
      `RUN=<run> 0335`, the bundles and articles after it, as CLAUDE.md describes. **Done 2026-11-04 on Al's word:**
      run `20261104_0543` promoted; `planning/archive/2026-11-issue-145-promote-retune/`.

Closed by: PR #146 (closes #145)
