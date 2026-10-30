# Findings — Measured site gradient against link's segment and Atlas-line gradients at FDIS visits (#121)

## Issue context

**If we do it:** we know how closely the gradient every habitat rule reads (link's segment gradient, and the whole Atlas line's) follows the gradient surveyors measured at the same sites, and so how far a tuned gradient limit can be taken as a limit on the ground. **If we never do:** every gradient threshold is a threshold on a modelled quantity whose error against the stream nobody has measured.

## Problem

From #92 the tuning reads `segment_gradient`, with `fwa_gradient` as its sensitivity. Both come from the Freshwater Atlas, averaged over a segment or a whole line. FDIS surveyors measured gradient at many of the same visits, and `research/fdis_export.md` compares measured with modelled **width** (log correlation 0.54 over 3,637 sites), but not gradient: it says only that the comparison against the segment gradient the model uses has to come first. The link research that was to make it closed without doing so.

The data is already built. In the evidence build the published grades name (`data/fdis/derived/visits_link.csv`, md5 `1bd35829`), 18,759 of 45,529 visits carry a measured `gradient_pct` (from the form's `GRADIENT11`/`GRADIENT12`, sentinels over 100 % dropped by `0230`) beside `segment_gradient` and `fwa_gradient`; 9,397 also carry `gradient2_pct` (`GRADIENT21`/`GRADIENT22`). 55 visits have a negative `segment_gradient` (counted 2026-10-30). The 2026-10-25 build (md5 `d3a434e2`), which a checkout may still hold in its ignored `data/`, has 17,705 of 40,552 and 32 negative, so check the md5 before reading any count.

## Proposed

- [ ] Read what the form's two gradient fields measure (the FDIS data dictionary, or the submission template) before using `gradient2_pct`.
- [ ] Run on the evidence build the published grades name (`evidence_md5`), not whatever a machine holds.
- [ ] Write it as a script that takes the visit table's directory (`EVIDENCE_DIR`, as `data-raw/compare_structures_check.R` does), so #120 reruns it unchanged on the minimal network.
- [ ] Measured against `segment_gradient` and against `fwa_gradient`, in the same units: agreement (log or rank correlation, and the ratio's p10 to p90, as the width comparison reports), and how it varies with segment length, stream order and the measured value itself.
- [ ] The band the rules turn on: within the gradient classes where CH rearing's and BT's limits sit, how often a visit's measured and modelled gradients fall on opposite sides of the published limit.
- [ ] Whether the error differs between visits that caught a species and visits that did not, since link cuts segments at catches (the bias #120 is about).
- [ ] The negative segment gradients: what they are and whether any visit's pick depends on one.
- [ ] Results into `research/fdis_export.md` beside the width comparison, and a sentence in the methodology article's limits once it holds.

## Not proposed

No change to the gradient a rule reads. A point measure over a surveyed site and a segment average are different quantities, so this measures how far apart they are; it does not replace one with the other.

Taken from link's issue on observation points (`NewGraphEnvironment/link#294`, its question 2), which closes pointing here. Runs again under #120 on the minimal network: the two runs together show how much of the error, and of any difference between visits with and without a catch, comes from link cutting segments at catches. Relates to #70 (fixed-window gradients), #92 (segment gradient), #120 (how the cuts move the tuning).



## Errors Encountered

| Error | Resolution |
|-------|------------|
