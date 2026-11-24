## Outcome

Set the method for reading DFO NuSEDS spawning dates (#256), the gate before the timing reviews (#241, #242) revise any
row against NuSEDS. A NuSEDS start or end of spawning is an estimate: a date on the five-day grid before the 1990s, a
ten-day bin after, often recorded before the survey began, and written even on records whose survey saw no spawner. So a
NuSEDS window speaks to the middle of a row, the bulk of spawning (bins as midpoints, present records) and its peak, and
to an edge only where 5 or more records had a survey of 3 or more visits beyond it, which is consistent with an edge
someone saw and never proof of one. `data-raw/nuseds_dates_check.R` measures what each date is made of and tested ten
candidate edge rules against a test set before it ran; `data-raw/timing_nuseds.R` now gives every window four readings
(`rec_` as recorded, equal to #240's on all 6,112 rows and still reproducing #96's UFRA and COTR windows, `bulk_`, `peak_`, `edge_`); both
read through one shared reader, `data-raw/nuseds_dates_read.R`, where every record set is defined once. The method is
written up in [`research/nuseds_timing.md`](../../../research/nuseds_timing.md). UFRA and COTR chinook rows keep their
dates (owner, 2026-11-24); their notes now say what NuSEDS shows.

What was learned in review: five code-check rounds found 33 findings, nearly all one mechanism. A sentence named a set
in plain words while its number came from a set built differently: the two scripts each defining "present", the bulk
and the edges, a denominator of records where the sentence said starts, or a number from a hand probe rather than a
printed line. Moving every set into `nuseds_survey()` closed it, and a guard added in round 4 caught a claim round 4's
own reviewer had made wrongly (one record outside the check's population was an edge). The largest data defect: DFO
writes a January-to-March end with the record's own year, so reading the written two-digit year dropped 98 present
records as running backwards; every date is now read on the season year.

## Measurement

On the published `knowledge/nuseds/v1` (release 20260601), 102,807 dated records:
- 1,910 NONE OBSERVED records had a survey overlapping the window they give, and none gives a count above 0: NuSEDS
  dates are written whatever was seen. This set the method's population (present records only).
- The test set before results (NONE OBSERVED meeting a rule at under half the present rate; under half of its records
  on the grid) passed every rule but the fence (63 % on the grid); within the 1990s the bracket rule separates (5.8 %
  of present records against 0.4 %). The plan's first test was found after the first run to need this test as well as
  a count, and it was written into the plan before it ran.
- Edges: 162 of 357 group windows get a start edge and 124 an end edge; chinook 24 of 81. Of the five chinook groups
  read closely, only MORR's end (09-25, 9 records) and UFRA's start (08-15, 11 records) qualify.
- The as-recorded window, by taking a start bin's first day and an end bin's last, sits half a bin (four or five
  days) outside the bulk at each edge.
- Wrong turns kept: the first pass read dates on their written years (98 records lost), counted the start before the
  survey against a both-dates denominator, and quoted three facts misread from the log (Buck Creek's NONE OBSERVED
  years, a COTR grid count, the upper Bulkley's years); each is in `findings.md` with its correction.

## Evidence

`scripts/logs/timing/20261124_*` (the dates check, the windows run and its CSV); #240's `scripts/logs/timing/20261121_*`
stays as the as-recorded reference.

## Owed

- Tick #256 in #243's members table once the PR merges (if `/gh-pr-merge` does not).
- After the merge: #241's and #242's "Waits on #256" lines name `research/nuseds_timing.md`'s method section and the note wording, and wet#182's body says the UFRA and COTR dates are unchanged and their notes now say what NuSEDS shows.

Closed by: PR (to follow) on branch `256-a-method-for-reading-nuseds-spawning-dat`
