## Outcome

Backlog move 5 (#174) carried batch 8, the timing table and NuSEDS (#31, #96, #108), and batch 9, flow in windows (#42,
#105), in one PR, and split what was bigger: #226 (#105 Phase 2), #227 (low flow and dry years, the rest of #42) and
#228 (observations and literature beside NuSEDS, the rest of #108).

- **NuSEDS.** It is now read through crate (`dfo/nuseds_all_areas`, NewGraphEnvironment/crate#74, PR #75). That needed
  crate#41's read-as-character fix, an encoding on each variant, and a byte check before the read. The file is
  single-byte, and readr segfaults on a byte its declared encoding leaves undefined.
  - `knw_nuseds_fetch()` and `knw_nuseds_records()` give each record an `evidence_kind`. `0340` builds it with a
    receipt and publishes it with crate's declared types; the upload waits on crate's release.
  - One row is one estimate (`act_id`). A population can be counted on several streams in one year.
- **Timing.** The Bulkley coho migration has no sourced end (#31). UFRA and COTR chinook rows come from NuSEDS spawn
  dates and two literature quotes, which `0280` verifies (#96).
- **#105 Phase 1** passed its stop rule, set beforehand: reading both late-summer windows instead of MAD moves 6.2 % of
  the scored visits, so Phase 2 is #226. `research/chinook_window_flow.md` holds Phase 1 and #42's window flow on every
  segment.

What was learned:
- the plan review caught a project name in the baseline before any push;
- the tuning scores 4,858 visits, not the 7,823 the population holds before its both-outcome filter;
- `GROUPS` is a read-only bash variable;
- wet's readers return no `pick` (NewGraphEnvironment/wet#177);
- code-check found, round after round, one mechanism: a property fixed at its source (crate's types and encoding, a
  bigint, the code a run reads) was re-derived downstream from a stand-in that usually agreed. Five rounds and a final
  enumeration closed it.

## Measurement

**#105 Phase 1** (published run `20261103_0838`; 4,858 scored visits, 234 with chinook, 45 groups; wet's load of
2026-10-24). Visits that change side of the rule against the MAD reading:

| reading | visits | share | chinook visits | share |
|---|---|---|---|---|
| stream | 194 | 4.0 % | 9 | 3.8 % |
| river | 102 | 2.1 % | 7 | 3.0 % |
| both | 300 | 6.2 % | 16 | 6.8 % |

- The median window/MAD share is 0.59 at visits and 1.04 at the 997 rivers found at 3 m³/s; by group it runs from 0.11
  (NARC) to 1.78 (LISR). LFRA holds 138 of the 300 flips.
- wet's published parts (build 2026-11-15): their monthly basis gives the same river reading; their daily basis gives
  106 flips (2.2 %).
- The stop rule (5 % of visits or of chinook visits) was committed at `d6eff92f` before the run. Three reruns, after
  code-check fixes, gave identical flips.

**NuSEDS 20260601.**
- 421,001 rows, 9,886 populations, single-byte (0xC7 and 0xC8 its only high bytes).
- `act_id` reaches 2,146,955,744, which is why ids are strings.
- 518 rows repeat a population, species and year; none repeats a population, stream and year.
- `evidence_kind`: count 153,612, count_expert 959, presence_survey 7,904, presence_expert 2,134,
  presence_unrecorded 9,139, none_observed 50,223, not_inspected 193,463, unknown 3,567.

**#96.**
- UFRA spawning 08-11 to 09-05 (123 population-years, 1967–2000); Swift Creek alone 08-09 to 09-05.
- COTR spawning 08-10 to 09-06 (35 population-years, 1953–2009).
- Candy et al. (2002) give 2001 peak spawning weeks that agree.

**#42.**
- 2,020,158 segment × window × source rows over BULK, MORR, UFRA and COTR.
- The monthly basis is within 5 % of the daily on 75 % of rows. It drifts on short windows that cut a fast-moving month
  (MORR chinook emergence: median 28 %, 90th percentile 135 %).
- wet's two sources differ more than twofold on 13 to 87 % of segments, by window.

**Code-check.** Five reviewer rounds, then an enumeration by the session.
- Round 1: 3 findings, all fixed.
- Round 2: 4, all fixed; one sat one axis over a round 1 fix.
- Round 3: named the mechanism and enumerated 23 places it reaches; 3 open, fixed.
- Round 4: 4 open, two of them opened by round 3's fixes.
  - One was a readr segfault under windows-1252, reproduced before it was fixed.
- Round 5: 1 open.
- The final enumeration traced every record field to its source.

## Evidence

- `scripts/logs/flow_window/20261118_*`
- `scripts/logs/nuseds/20261118_*`
- `scripts/logs/timing/20261118_timing_nuseds.txt`
- `scripts/logs/habitat/20261117_literature_verify*`
- `data/tune/flow_window/ch_rear_*`
- the review rounds in this directory, `review-round*.md`, and the plan review, `review-plan.md`

## Owed

- crate release with NuSEDS registered (NewGraphEnvironment/crate#75), then `crate (>= <that version>)` in
- `PUBLISH=TRUE Rscript scripts/0340-nuseds-build.R` once crate has released #74, so the receipt names a released

Closed by: PR (opened from branch `174-backlog-move-5-chinook-flow-windows-and`)
