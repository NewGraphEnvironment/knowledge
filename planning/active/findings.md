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



## What the form's two gradient fields measure (Phase 1, 2026-10-30)

- **The card.** RISC, *Reconnaissance (1:20,000) Fish and Fish Habitat Inventory: Site Card Field Guide*, Version 2.0,
  April 2008 (www2.gov.bc.ca `.../risc/sitecard20.pdf`), p. 13, "Gradient %": "Definition: The slope, or rate of
  vertical drop per unit of length, of the channel bed. Method: Measure at a minimum of two sites along the sample site
  over as long a distance as possible." Recording: "Record the method code to the nearest 0.5%" with codes GE (ground
  estimate), C (clinometer), AL (Abney type level), MAP, S (surveying equipment), GIS, O, NS. Elaboration: keep the
  channel length as long as possible, upstream and downstream; on shorter sections sight between similar habitat units
  (riffle crest to riffle crest). The card front (`scf.pdf`) has a GRADIENT % box of two rows of two cells with a method
  column.
- **The database.** `FDIS_SITE_SURVEYS` carries `GRADNT1_MTH_CODE` and `GRADNT2_MTH_CODE` (one method code per row of
  the box); the values sit in `FDIS_SITE_MEASUREMENTS` (`MEASURE_TP_CODE`, `SEQUENCE_NUMBER`, `MEASUREMENT`). So
  `GRADIENT<t><s>` in the export reads as measurement type t (gradient 1 or 2, each with its own method) and sequence s
  (the two places along the site). The export carries neither method code, so which method a value came from is not
  known: a GIS or map reading recorded as gradient 1 cannot be told from a clinometer reading.
  `0230` takes `gradient_pct` as the mean of `GRADIENT11/12`, `gradient2_pct` of `21/22`.
- **The two against each other** (published build `1bd35829`): 18,759 visits have `gradient_pct`, 9,397
  `gradient2_pct`, 9,389 both, 8 the second alone; 55 have a negative `segment_gradient`, none an NA one (the issue's
  counts, reproduced). Where both exist: median difference 0 (p10 −3, p90 +3.5 points), second higher at 47 %, equal at
  12 %, lower at 42 %; Spearman 0.90; median 5.5 % each; ratio second/first p10 0.63, median 1, p90 1.67.
  0230's comment that the second "runs higher" does not hold on this build as a typical difference.
- **Decision.** `gradient_pct` is the measured gradient compared. `gradient2_pct` is reported in one block as a second
  comparison, and the first-against-second spread (ratio p10–p90 0.63–1.67) is reported as the yardstick: how far two
  readings at the same site, by possibly different methods, already disagree. A modelled gradient cannot be expected to
  agree with a reading better than two readings agree with each other.

## Errors Encountered

| Error | Resolution |
|-------|------------|
