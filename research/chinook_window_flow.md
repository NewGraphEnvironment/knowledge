# Chinook rearing: does flow in a seasonal window size streams differently from MAD?

**Verified:** 2026-11-18 (Phase 1: the question, the readings and the stop rule set and committed at `d6eff92f` before
any flip was counted, and run the same day); 2026-11-22 (Phase 2's readings and verdict rule, set at the plan gate and
committed before any score was made) · **Issues:** #105 (Phase 1), #226 (Phase 2), #42 (window flow per segment,
below), move 5 (#174), move 14 (#233) · **Produced by:** `data-raw/chinook_window_flow.R` (tables
`data/tune/flow_window/ch_rear_*.csv`, log `scripts/logs/flow_window/20261118_chinook_window_flow.txt`);
`data-raw/segment_window_flow.R` (ignored `data/flow_window/segment_windows.parquet`, log
`scripts/logs/flow_window/20261118_segment_window_flow.txt`) · **Status:** Phase 1 done. Phase 2 (#226): the rule
below is on record; nothing is scored yet.

## Short answer

Reading late-summer flow instead of MAD moves **6.2 % of the 4,858 scored visits and 6.8 % of the 234 with chinook**
to the other side of the rule when both windows are read. That passes the 5 % the stop rule set, so a tuning on
window flow could come back different, and Phase 2 is worth running. Either window alone moves fewer than 5 %. The
change is concentrated: one group, the lower Fraser (LFRA), holds 138 of the 300 visits that move, and only 16
visits with chinook move in all. What a juvenile stream holds in August and September, as a share of its MAD, runs
from about a tenth in coastal rain-fed groups to above one and a half in snow- and glacier-fed ones.

## The question

The published chinook rearing rule (`data/thresholds.csv`, from run `20261103_0838` on link's minimal network)
reads stream size as mean annual discharge (MAD) twice:

> a stream counts where it carries at least 0.75 m³/s and is no steeper than 9 %; a smaller stream also
> counts if it passes the slope test and a river carrying at least 3 m³/s lies within 1 km downstream.

MAD is a year-round average. What a juvenile meets is the flow in the months it is in the stream, and what a
spawner needs is the river's flow when it is there. If late-summer flow as a share of MAD differs enough between
regions, one MAD threshold picks a different summer stream in each. Phase 1 asks only whether the difference is
large enough to change which visits the rule takes in. If it is not, a tuning on window flow (Phase 2) cannot
come back different, and #105 stops here.

## The windows and readings

Two fixed windows, province-wide, as #105 proposed:

- **rearing, 08-01 to 09-30**, read on the stream the visit is on (does it still hold water when juveniles are
  in it?);
- **spawning, 08-15 to 09-15**, read on the river downstream (is it large enough when spawners are in it?).

Each window's flow is the mean over its days of wet's monthly flow (`wet::wet_flow_window()`, `basis =
"monthly"`) on the source wet picks for the segment (`pick`), from `discharge.fwa_v1_segment_monthly` in the
database that holds the published build. The flow is read on the segment the visit's MAD came from, its own or the
parent `knw_link_flow()` fell back to.

Three readings of the rule, each against the MAD reading:

1. **stream**: the stream test uses the rearing window flow instead of MAD;
2. **river**: the exception uses the river's spawning window flow instead of its MAD;
3. **both**.

**Matched thresholds.** Window flow is not on MAD's scale, so each threshold is scaled by the median ratio of
window flow to MAD: 0.75 m³/s by the median over the visits' segments, 3 m³/s by the median over the distinct
rivers the walk found at 3 m³/s for those visits. A window reading then differs from MAD's only where a stream's
or river's seasonal share departs from the typical one, which is the difference the question is about.

**The river reading is an approximation.** The evidence keeps, for each visit, the nearest river downstream at
each rung of the walk's ladder (1, 3, 5, 10, 20, 30 and 50 m³/s of MAD). The river reading takes the nearest of
those rivers within 1 km whose spawning window flow reaches the scaled threshold. A river smaller than the lowest
rung (1 m³/s MAD) is not seen, nor a segment between two rungs' rivers. An exact window walk is Phase 2's.

## The population

The visits the tuning scores the rule on: chinook rearing's population (`.tune_population()` on the published
evidence, 7,823 visits, 235 with chinook, 111 groups), less the groups where chinook were all caught or all
missed (`.tune_modelled()`): **4,858 visits, 234 with chinook, 45 groups** (`data/tune/CH_rear_tune.csv`). The MAD
reading must first reproduce the published rule there: **1,400 visits in, 197 with chinook**. The script stops
otherwise.

## The stop rule

Set at the plan gate (Al, 2026-11-17) and made exact here before any flip was counted:

- A **flip** is a visit the window reading puts on the other side of the rule from the MAD reading, either way.
- Flips are counted over the 4,858 visits, and separately over the 234 visits with chinook.
- The rule is judged on the totals, not group by group.
- **Stop** if, for every one of the three readings, fewer than 5 % of the visits **and** fewer than 5 % of the
  visits with chinook flip. **Continue** (file Phase 2, which waits on Al's word) if any reading reaches either
  share: 243 or more of the 4,858 visits, or 12 or more of the 234 with chinook.

The script refuses to run unless this file is committed, and logs the commit it read.

## What came back (Phase 1, 2026-11-18)

**The checks held.** The rebuilt population gave 7,823 visits, 235 with chinook and 111 groups, and 4,858, 234 and 45
once the groups with only one outcome were left out. The MAD reading gave the published rule's 1,400 visits in, 197
with chinook. The database's flow load was the grade record's (wet's build of 2026-10-24). MAD, read again on each
visit's segment, equalled the evidence's at every visit, and no visit's flow came from a parent segment.

**The typical seasonal share.** Over the scored visits, the rearing window's flow is a median 0.59 of MAD. At the
997 rivers the walk found at 3 m³/s, the spawning window's flow is a median 1.04 of MAD. So the matched thresholds
are 0.44 m³/s for the stream and 3.11 m³/s for the river.

**Flips**, against the MAD reading, over the 4,858 visits (234 with chinook):

| reading | visits in | visits that move | moved in | moved out | share | chinook visits that move | share |
|---|---|---|---|---|---|---|---|
| stream (rearing window) | 1,324 | 194 | 59 | 135 | 4.0 % | 9 | 3.8 % |
| river (spawning window) | 1,302 | 102 | 2 | 100 | 2.1 % | 7 | 3.0 % |
| both | 1,220 | 300 | 60 | 240 | 6.2 % | 16 | 6.8 % |

**The verdict.** "Both" reaches 5 % of visits and of chinook visits. By the rule set beforehand, Phase 2 (a tuning on
window flow) goes ahead, and like any tuning it waits on Al's word.

**Where they move.** A flip happens where a stream's or river's late-summer share departs from the typical one. That
happens far more in some groups than others:
- The lower Fraser (LFRA, 646 visits) holds 119 of the stream reading's 194 flips and 138 of the 300 in both. Its
  streams hold a median 0.18 of MAD in August and September, a third of the typical share, so many fall below the
  matched stream threshold.
- In "both", the other 162 spread over 30 groups, none with more than 21 (FRAN).
- The 16 chinook visits that move are spread over 11 groups, two at most in any one.

**The seasonal share by group.** The median rearing-window share is under 0.5 in 14 of the 45 groups and over 1 in 9:
- lowest: NARC 0.11, SALM 0.18, LFRA 0.18, SQAM 0.19, GOLD 0.22;
- highest: SETN 1.32, LSKE 1.34, HOMA 1.45, KSHR 1.63, LISR 1.78.

The spread is in `data/tune/flow_window/ch_rear_ratio_by_group.csv`, with the river's spawning share beside it.

**The river reading barely gains.** Two visits move in and 100 move out. A visit can only move in through a river that
reaches 3.11 m³/s in the spawning window but carries under 3 m³/s of MAD. That needs a river between the walk's 1 and
3 m³/s rungs whose September share is well above the typical one, and few lie within 1 km of a visit.

**Checks on the monthly basis.** wet's published parts (build 2026-11-15) were read for the same rivers:
- Their monthly basis gave the database's river reading exactly: the same median share, the same 102 flips.
- Their daily basis, which takes the spawning window's part months day by day, gave a median share of 0.95 and 106
  flips (2.2 %), four visits apart from the monthly reading.

The result does not rest on the monthly approximation.

## Phase 2: is the rule better tuned on window flow? (#226)

Phase 1 counted the visits a window reading moves. Phase 2 asks whether the moved set predicts chinook better: the
rule is tuned again with window flow in MAD's place, and each tuning's held-out score is set beside MAD's.

### The four readings

The windows are Phase 1's, fixed province-wide, on wet's monthly flow and the source wet picks for the segment.

| reading | the stream's size | the river downstream is found by |
|---|---|---|
| control | MAD | MAD |
| stream | flow in the rearing window, 08-01 to 09-30 | MAD |
| river | MAD | flow in the spawning window, 08-15 to 09-15 |
| both | flow in the rearing window | flow in the spawning window |

- **Each reading is tuned as the published rule was.** The same grid of rules, the same five folds of watershed
  groups (seed 54), the same one-SE region and pick, with the bootstrap, the nested selection and four more fold seeds
  (55 to 58). Nothing is scaled: where Phase 1 matched thresholds by the median window share, here each reading finds
  its own thresholds on its own scale.
- **The river is found by a walk on window flow.** Phase 1 read the river off the MAD walk's ladder, which misses a
  river under 1 m³/s of MAD and any segment between two rungs. Phase 2 walks downstream to the first segment whose
  spawning-window flow reaches each size, by the published walk's path and bank rules.
- **All four score the same visits.** The window flow is read on the segment MAD came from, so it is present exactly
  where MAD is. A reading changes which side of a rule a visit falls on, never which visits are scored: 4,858 visits,
  234 with chinook, 45 groups.
- **The control must give the published table back**: every rule's held-out score, the pick and the region of run
  `20261103_0838`. The scoring stops otherwise.

### The verdict rule

Set at the plan gate (Al, 2026-11-21) and made exact here before any score was made. The scoring script refuses to
run unless this file is committed, and logs the commit it read.

A reading's **rule** is the one its tuning recommends (the tuning's `recommended` rule, the fewest-departures pick
inside the one-SE region). The **difference** between a window reading and the control is the window rule's held-out
deviance less the control rule's, summed over the same 45 groups on the same folds; lower deviance is better, so a
negative difference favours the window. Its **SE** is the scorer's: the standard deviation of the 45 groups'
differences times the square root of 45.

A window reading **beats MAD** only if all three hold:

1. **On the main folds (seed 54)** the difference is negative and larger than one SE.
2. **On the four other fold seeds (55 to 58)**, with the same two rules scored on each seed's folds, the difference is
   negative on at least three.
3. **Without the lower Fraser (LFRA)**, the group that held 138 of Phase 1's 300 moved visits: both readings are
   tuned again on the visits outside LFRA (seed 54), and the window rule's deviance is still the lower.

If more than one window reading beats MAD, each is reported, the one with the lowest held-out deviance on seed 54
first.

**What the verdict decides.** Only which follow-ups are filed. If a window beats MAD: windows that move by group
with timing, link reading a window flow, and the window column in the evidence build. If none does: the rule stays
on MAD, and `research/chinook_stream_size.md` and the methodology article's limits say so. Nothing is graded,
compared or published either way; each waits on Al's word.

**Every check is reported whatever the verdict**, each with the way it points: each reading's best and recommended
rule and their held-out deviance, the size of its region, the rule each nested fold picked and its held-out deviance,
the rule each other seed picked (the exact rule, and each of its parts), the bootstrap's share for the exact rule and
for each part, and the curve's held-out deviance.

## Window flow on every segment (#42)

`data-raw/segment_window_flow.R` reads every complete window of `data/life_history_timing.csv` onto every FWA segment
of its group. Both of wet's sources are kept, each from wet's published build of 2026-11-15, on the daily basis (the
mean of the window's own days of the year) with the monthly basis beside it. It writes 2,020,158 rows to ignored
`data/flow_window/segment_windows.parquet`:

| group | segments with flow | windows |
|---|---|---|
| BULK | 30,037 | 11 |
| MORR | 22,218 | 26 |
| UFRA | 30,522 | 2 |
| COTR | 20,480 | 2 |

The BULK coho migration has no end (#31) and is skipped. There is no `pick` column, because wet's readers return
none (NewGraphEnvironment/wet#177), and no 7-day minimum (#227: wet publishes mean days, not each year's days).

**How far the monthly basis sits from the daily one.** Over every row, the monthly basis is within 5 % of the daily
one on 75 %. For the chinook windows, the median and 90th-percentile gap over segments and both sources are:

| group | stage | window | median gap | 90th percentile | segments whose two sources differ more than twofold |
|---|---|---|---|---|---|
| BULK | migration | 05-01 to 08-01 | 0.1 % | 0.2 % | 16.5 % |
| BULK | spawning | 08-01 to 09-15 | 1.7 % | 3.8 % | 53.6 % |
| BULK | fry migration | 07-15 to 09-07 | 10.4 % | 28.2 % | 48.5 % |
| MORR | emergence | 03-15 to 04-15 | 27.8 % | 135.2 % | 50.1 % |
| MORR | spawning | 09-01 to 10-07 | 1.3 % | 6.8 % | 46.2 % |
| UFRA | migration | 04-01 to 08-10 | 1.6 % | 2.2 % | 12.7 % |
| UFRA | spawning | 08-11 to 09-05 | 7.0 % | 16.8 % | 35.5 % |
| COTR | migration | 04-01 to 08-09 | 0.2 % | 0.7 % | 35.2 % |
| COTR | spawning | 08-10 to 09-06 | 6.4 % | 14.5 % | 86.7 % |

The monthly basis holds for windows of whole months. It drifts for short windows that cut a month where flow is moving
fast: spring emergence on the freshet's rise, and fry migration and the interior spawning windows on the late-summer
fall. The two sources disagree more than the bases do. On spawning windows, a third to almost nine-tenths of
segments differ more than twofold between wet's balance and PCIC's routed flow, so a window flow on one source alone
says little about a small stream.

## Caveats

- **Phase 1 counts flips; it does not score them.** A flip says the window reading takes a different set of visits.
  Whether that set predicts chinook better is Phase 2's held-out score. 16 chinook visits is a small difference to
  tune on.
- **Most of the change is one group's.** A tuning on window flow could move largely because of the lower Fraser's
  rain-fed streams. Phase 2 should read its result with and without LFRA.
- **The river reading is approximate** (above): it sees only the ladder's rivers.
- **Both flow sources are 30-year means.** No dry year is in them, and the monthly basis is weakest on small basins
  (`research/chinook_stream_size.md`, `research/modelled_discharge.md`).
- **The windows are fixed province-wide.** Stock timing differs by a month between neighbouring groups (BULK and MORR).
  Windows that move by group are not here.

## What next

Phase 2 is #226, carried by move 14 (#233): the window column and the window walk on a copy of the published
evidence, the four readings scored into `data/tune/flow_window/`, and the verdict by the rule above. The low flows
and dry years the 30-year means cannot show are #227.

Nothing is graded, compared or published without Al's word.
