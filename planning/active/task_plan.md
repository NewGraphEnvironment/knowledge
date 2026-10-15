# Task: Stream size where Chinook are caught: CH detection by MAD class across all watershed groups, and distance to a large river (#52)

#42 asks a seasonal question: is there enough flow while a life stage is present? That needs timing windows, and `life_history_timing.csv` only has two groups. A simpler question needs no life stages, and it can run anywhere we have fish records: **how big are the streams Chinook are found in?**

Until now the only MAD we had was fwapg's annual table. It covers the Fraser, Peace and Columbia, and is null on 25.3 % of FDIS visits (`research/habitat_weights.md`). wet's published flow (`research/modelled_discharge.md`, "Use this") now gives annual and monthly flow on about 4.5 M FWA segments province-wide.

## Phase 1: Build (`scripts/0294-ch-mad-build.R`, `scripts/sql/ch_dist_large.sql`)
*Revised after the plan review (`review-plan.md`, B1–B4, A2–A8); each change is marked (R).*
- [x] Visits: 0290's quality drops plus a drop where CH absence is blocked. The ledger partitions the
  53,018 input rows and names the CH caught in each drop.
- [x] (R, A2) Population WSGs follow link's CH presence rule: ≥ 5 bcfishobs CH records since 1990 (106 WSGs).
  It drops 20,832 visits, 3 of them with CH.
- [x] (R, A8) Exact duplicates (#35) are kept and flagged in `dup_of` after the drops (568), so 0295 can fit
  with and without them.
- [x] Picked annual flow plus each source's value, checked against the manifest counts. (R, B2) A segment with
  no picked flow takes its parent line's flow and codes rather than being dropped (445 visits, 140 CH).
- [x] (R, B4) Distance: an explicit route-measure walk (`ch_dist_large.sql`) to the first primary-flow segment
  with picked MAD ≥ 10. It records the target's edge, whether it is a lake, and the mouth-to-parent gap. The
  coast reads as `none`. `fwa_downstreamtrace` is not used.
- [x] (R, B3) Ambiguous placement: a MAD ≥ 10 segment on another line lies within the snap distance + 20 m.
  Side channels are flagged.
- [x] (R, B1) Regulated: downstream of a CABD dam with a reservoir or ≥ 10 % regulation (101 dams placed).
- [x] Access sensitivity: `barriers_ch_access` drops overridden barriers (0 of 265 CH override positions
  survive), so the pre-override natural barriers in `fresh_default.barriers` are used, over 56 WSGs, with and
  without USER_DEFINITE.
- [x] Output `data/fdis/derived/ch_mad_visits.csv` and `scripts/logs/habitat/20261015_ch_mad_build_ledger.csv`.

## Phase 2: Use (`scripts/0295-ch-mad-use.R`)
- [x] The spec is fixed in the header, and revised once after the review, before any fit.
  - MAD classes stay at the literature and model breaks; a merged 0.1–0.5 class is a sensitivity.
  - (R, S2) Distance classes are ≤ 500 m, > 500 m and none.
  - (R, G1) Three responses: CH caught, any fish, and CH given fish.
- [x] Raw rates on the modelled visits and on all population visits; per-WSG raw counts for WSGs with ≥ 20 CH.
- [x] Model and stream bootstrap as 0291. (R, AC3) Each class reports its top-project share and its regulated
  share.
  - CHANGE 1, after the first run and before the write-up: distance is a rate ratio against > 500 m, because
    normalising against the class mean let the 11-detection `none` class break the bounds.
- [x] Sensitivities:
  - leave out the regulated reaches, the largest project, and CHES+NECR;
  - leave out the parent-flow visits;
  - each source alone;
  - the old fwapg MAD;
  - duplicates kept;
  - no river polygons;
  - gradient as a covariate, and season as a covariate;
  - the merged class;
  - access with and without USER_DEFINITE;
  - distance with ambiguous visits kept, with lake targets out, and with entry gaps out.
- [x] (R, G7) Cross-check against non-FDIS bcfishobs CH records.
- [x] Output `data/ch_mad_use.csv` and `scripts/logs/habitat/20261015_ch_mad_use.txt`.

## Phase 3: Write-up
- [x] `research/chinook_stream_size.md` with the provenance line. It covers:
  - the rate by MAD class;
  - the small-stream-near-big-river result;
  - per-WSG spread;
  - each sensitivity's effect;
  - limits: juveniles only, big rivers under-sampled, modelled flow;
  - what it means against link's rearing 0.28 / 100 and Woll's 0.5 (not spawn_mad_min: juvenile data, S1).
    This is stated as evidence for link#331 and the CH threshold rows, not as a change.
- [x] Add a `research/README.md` row and the `scripts/README.md` run order (0294, 0295). In CLAUDE.md, list
  `ch_mad_use.csv` in the `data/` root description.
- [x] Edit the #52 body to link the research file and the result, and point #42's scope note at it.

## Validation
- [x] Both scripts run clean from the repo root, and the ledger partitions the input
- [x] `/code-check branch` clean: 4 reviewer rounds and a terminating self-enumeration (`review-round*.md`); code clean in every round, all findings in the prose
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive`, then `/gh-pr-push`

## Verification
- Ledger: the drops and the kept rows partition the 53,018 input rows; 1,186 CH visits are kept, and the
  drops name the CH they remove (AC1).
- The picked flow covers every kept visit: 445 are covered from the parent line, and 58 visits with no flow
  either way are dropped (none with CH).
- Walk spot-checks (AC2): MORK CH tributaries 227–378 m to the Fraser; a TABR side channel to its main line;
  a STUL lake target; a SALM coastal stream to the sea (`none`). An entry gap over 200 m (7.6 % of walks;
  lake tributaries coded `999`, e.g. into Shuswap Lake) is a sensitivity.
- The bootstrap re-run on 2 and 6 workers gives byte-identical `ch_mad_use.csv`.
- Restore-the-bug: blocked-absence drop and dedupe key mutated; the ledger counts move.
