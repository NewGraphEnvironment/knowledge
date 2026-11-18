# Chinook rearing: does flow in a seasonal window size streams differently from MAD?

**Verified:** 2026-11-18 (the question, the readings and the stop rule, set before any flip was counted) ·
**Issues:** #105 (Phase 1, this file), #42 (window flow per segment), move 5 (#174) · **Produced by:**
`data-raw/chinook_window_flow.R` (to come) · **Status:** OPEN: the stop rule is set; Phase 1 has not run.

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
