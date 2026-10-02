# #33: BT spawning evidence by gradient and channel size

## Outcome

- **Track 1 (FISS/FDIS).** `scripts/0293` measured BT spawner evidence on link's segments: maturity-coded fish, Aug–Oct, split by fish size. Spawner evidence does not discriminate spawning gradient within watershed groups. The raw rise with gradient is between groups. Mature fish on steep segments are mostly small.
- **Track 2 (literature).**
  - 21 rows added, all through the 0280 gate.
  - The USFWS recovery plan and the 2010 critical habitat rule were filed to the group library, and the `habitat_modelling` store was rebuilt and pushed.
  - Observed BC spawning gradients run 0.6–4 %, and no source gives a limit.
- **Track 3 (Williston critical spawning segments)** is deferred: the layer is on m4, which did not answer ssh.
- **Write-up:** `research/bt_spawning.md`. A link follow-on is drafted in `link-issue-draft.md`, not filed. It keeps the thresholds and scores them against redd segments when they are on FWA.
- **Issues spun off:** #34 (FISS gradient read as a fraction), #35 (FDIS surveys loaded twice), #36 (no groundwater variable).

The review record matters more than the result. The plan review rewrote the design before any fit:
- the raw rate measured who maturity-coded fish;
- most spawners were small;
- the transit test's null was invalid.

Every later round found claims written beyond the logged result, and twice inside the previous round's fix. The worst was "the literature gives no number", written while the table already held observed gradients from #19. Each loop was ended by enumerating the claim set.

## Measurement

All figures are from `data/bt_spawn_evidence.csv` and the 0293 log.

- **Population.** 560 Aug–Oct BT visits with at least one maturity-coded BT; 485 modelled, in 23 WSGs.
- **Raw spawner evidence:** 0.146, 0.188, 0.182, 0.293, 0.302, 0.352 across ≤ 2 to > 10.49 %.
- **Rate ratios with a WSG term:** 0.75–1.22, intervals of roughly 0–3.6.
- **Ruling the alternatives out:**
  - without a WSG term the ratios climb to 3.07;
  - with coding effort and month only, to 3.72;
  - with the WSG term alone, they are 0.76–1.28.

  This changed the reading from "sampling explains it" to "a between-group pattern".
- **Large spawners** (≥ 350 mm): 3–9 visits per class, all underpowered. 10 distinct large-spawner surveys sit on steep segments: 5 have a low-gradient patch upstream on the same stream, 4 have none upstream in their WSG.
- **Repeated surveys:** 411 of 14,463 visits are second copies (#35). Dropping them moves ratios little (0.84–1.22).
- **Reproducibility:** 0293 re-runs byte for byte.
- **Literature:** 510 evidence rows pass the gate. The store has 210 documents and 37,145 chunks (md5 `728c4782…`).

## Evidence

- `scripts/logs/habitat/20261002_bt_spawn_evidence.txt` (0293)
- `scripts/logs/habitat/20261002_literature_verify*` (gate)
- `scripts/logs/habitat/20261002_habitat_store_push.txt`
- `review-*.md` in this directory: the plan review, Phase 1 rounds 1–2, Phase 4 rounds 1–2.

Research: `research/bt_spawning.md`.

Closed by: PR (this branch, `33-bt-spawning-evidence-by-gradient-and-cha`). Track 3 stays open on #33 (`Relates to`, not `Closes`).
