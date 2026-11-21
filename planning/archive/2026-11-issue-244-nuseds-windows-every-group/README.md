## Outcome

Backlog move 16 carried #240 and #230. `data-raw/timing_nuseds.R` now reads the published `knowledge/nuseds/v1` set
over HTTPS (sha256 held to its manifest) and writes NuSEDS spawning windows for every watershed group and species with
dated records, every population's beside its group's, and sets every row of `data/life_history_timing.csv` beside its
group's window. The gate (Al, 2026-11-20) settled the mainstem rule: a population on a watershed code that crosses
several groups joins no window and is listed apart under each, unless `data/nuseds_reach_groups.csv` (keyed by DFO's
`gfe_id`) names its reach's group; NuSEDS alone writes no table row, which #241 and #242 add with their literature
reviews; and 0340's log (#230) is tee'd to `$TMPDIR` and copied in only after a run that succeeded, which the windows
script's own run line now does too. What was learned is in `research/nuseds_timing.md`: DFO's census-site points
cannot place a spawning reach (Morice River's falls in BULK), and coho and chum spawning ends past the new year need a
season year. The Plan review ran in the background beside Phase 1 (findings summarised in `progress.md`: it moved the
reach table's key from watershed code to reach). `/code-check branch` ran five rounds; rounds 3 and 4 each found a
defect inside the previous round's fix, so the loop ended on round 4's enumeration of every input, stop, output,
command line and quantified claim, confirmed by round 5 (`review-verdict.md`).

## Measurement

On the published v1 set (release 20260601): 102,800 dated records of 5,221 populations; 4,928 populations on a code in
one group, 189 on a code crossing several (70 waterbodies), 72 on a code the Atlas lacks; 480 group x species pairs in
126 groups, 357 with pooled populations, 6,112 windows. The UFRA and COTR chinook windows (#96) and BULK's (#240,
08-15 to 09-10 over 28 and 27 dated records) reproduce. Beside the table: BULK chinook spawning starts 14 days later
and ends 5 earlier than its row; MORR chinook spawning starts 11 days earlier, and its migration row ends 41 days after
NuSEDS's spawning starts. A full run takes about 33 s on m1.

## Evidence

`scripts/logs/timing/20261121_timing_nuseds*` (console log and windows CSV); `review-round*.md` here.

## Owed

- Tick move 16 and batches 25–26 in `planning/backlog.md` with the PR's URL (`/gh-pr-merge`'s tick commit, as for #176), and #240 in #243's member list
- #241 and #242 bodies name the windows CSV and the reach table they start from and add to

Closed by: PR (this branch, `244-backlog-move-16-nuseds-spawning-windows`)
