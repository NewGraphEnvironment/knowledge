# #120, second branch: tuning on link's provincial minimal network

## Outcome

Every species link models on its provincial minimal network (`fresh_default_minimal`, link#441, run
`20261102_203300-60ab009d`, link 0.78.1) was tuned there. The seven fitted keys were graded, compared and archived as
an unpromoted candidate, run `20261103_0838`. The premise holds province-wide: on the minimal network a visit with
fish starts its own segment about as often as an empty one (3.4 % against 3.0 %; the published full network was 86 %
against 10 %). Every published rule of the seven keys stays in its key's region, so the minimal network rejects none
of them. Bull trout's picks move furthest, and chinook rearing's gradient limit goes from 11 % to 9 %. These picks mix
three changes, not only the network: wet's 2026-10-24 flow load, loaded for this run into the minimal build's
database, and the species ranges link#402 revised after the published build's link 0.66.0. A run on the next full
`default` build with this evidence's flows and range separates the network from the rest. Regenerated `default`
reproduces link's stored km to within 0.011 % per key, but not exactly: the residue is all in the connectivity stage
and its cause is not established. The durable result is `research/minimal_network_tuning.md` ("The answer", "The
province run", "What each break source does"). The issue body carries the results and the every-setup table's status.

## Measurement

- **Grading** (`0320`, 14 workers): 70.9 min for seven keys, with walks cold on the new load (BT rearing 17.3 min,
  WCT 3.3). The minimal network has 52 to 67 % fewer segments per key than the published full one.
- **Comparison** (`0330`, `GPKG=FALSE`, `default` and the tuned rule only): 43.5 min. The plan's 2.7 h was the full
  network's figure for every structure, which led to a wrong estimate given to Al mid-run.
- **Archive:** 35 objects, 1,755 MB.
- **Measured gradient:** the minimal segment gradient's rank correlation with gradients measured on site is 0.678,
  against 0.690 on the full network. Five of the published limits flip fewer visits on the minimal network, one ties,
  and two flip more.
- **The `default` residue, a wrong turn kept:** I guessed spawning in another group, then the access gate (link#349),
  then fresh 0.52.0 against 0.53.0. Each was ruled out by a query or a code diff (findings, Phase 4). The next probe
  is link's own pipeline on TESR into a scratch schema.
- **Branch review:** four rounds (4, 2, 4 and 0 findings). Rounds 2 and 3 each found a defect inside the previous
  round's fix: claims about a set written from a nearby set. Round 3's enumeration of every quantified claim, which
  round 4 re-verified, ended it.

## Evidence

- `scripts/logs/habitat/minimal_network_120/20261103_*` (the flow load, the evidence build, the checks, the DEV and
  full tuning runs, the comparison and the archive console).
- `scripts/logs/habitat/2026110[23]_*-*minimal*` and `scripts/logs/habitat/20261103_site_gradient_check.txt`.
- `data/archive_index.csv`, batch `20261103T123953Z-2ce302a3`.
- Two commit messages that named a machine were reworded before the PR (findings has the old-to-new map). The
  candidate's grade records name the pre-rewrite `c5caacb` as their `knowledge_commit`; it is now `6ecb13c`, with
  identical code.

## Owed

- File the follow-up issue once tomorrow's full `default` build and link#444 exist: every species retuned on it and
  on the minimal build, the "full, parent gradient" setup, the transfer-cost map, the article's section, the
  promotion decision
- Maps of where the habitat drawn differs (the issue's static figure, from the candidate's saved segments for the
  most interesting groups; `STAGE=gpkg` for QGIS if wanted) and the methodology article's section: with the
  follow-up, since the transfer cost needs the parent table
- "Minimal, other access classes" (#132) and "fixed window" (#70): their own issues
- The cause of the `default` residue (findings, Phase 4), with the follow-up

Closed by: the PR from branch `120-minimal-network-province`
