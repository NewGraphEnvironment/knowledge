# Findings — Stream size where Chinook are caught: CH detection by MAD class across all watershed groups, and distance to a large river (#52)

## Issue context

**If we do it:** we learn what stream sizes Chinook juveniles actually use, in every watershed group with fish records. That gives us a measured check on the stream-size (MAD) bounds the habitat models apply to CH. **If we never do:** those bounds stay as the literature and model defaults set them, with no test against where Chinook are caught here.

## Problem

#42 asks a seasonal question: is there enough flow while a life stage is present? That needs timing windows, and `life_history_timing.csv` only has two groups. A simpler question needs no life stages, and it can run anywhere we have fish records: **how big are the streams Chinook are found in?**

Until now the only MAD we had was fwapg's annual table. It covers the Fraser, Peace and Columbia, and is null on 25.3 % of FDIS visits (`research/habitat_weights.md`). wet's published flow (`research/modelled_discharge.md`, "Use this") now gives annual and monthly flow on about 4.5 M FWA segments province-wide.

## Proposed solution

1. Place every FDIS site visit on its FWA segment, as #28 did (`scripts/0290`), and attach wet's annual flow from `pick`.
2. **Detection rate by MAD class**: the share of visits that caught CH, per MAD class and per watershed group. Visits with no CH count too, because raw catches only show where people sampled. Report the counts beside each rate.
3. **Small streams near big ones.** For visits on small segments (e.g. MAD < 0.5 m³/s), measure the distance downstream along the network to the nearest large segment (e.g. MAD ≥ 10 m³/s). Then compare CH detection by that distance. This tests whether small-stream Chinook are juveniles rearing in tributaries just off a mainstem. Pick the class breaks from the data, not from these examples.
4. Cross-check against the provincial observation points (presence only, all methods). They give no absences, so they serve as a check, not the estimate.
5. Write it up in `research/`, and compare it with the CH stream-size bounds the habitat models use (link#331 moves link onto wet's flow).

## Limits to state with the result

- **Juveniles only.** FDIS is electrofishing, and it caught 2 CH ≥ 150 mm in the whole export (`research/fdis_export.md`). This says where Chinook rear, not where they spawn.
- **Big rivers are under-sampled**, because electrofishing does not work there. The top of the size range is truncated, so read it as a lower bound.
- **Never use link's CH access codes as a covariate or stratum.** They are built partly from these same observations, the same circularity as `access_bt = 2` (CLAUDE.md).
- **About 2.8 % of visits are duplicates** loaded under two or three collection ids (#35). Dedupe them or say they weren't.
- **wet's flow is modelled.** The balance runs 7–11 % high in Apr–May. Annual `pick` scores 22.9 % mean absolute error at the 290 gauges routed flow reaches. Class breaks should be coarse enough that this doesn't move a visit's class often; measure how often it does.

Relates to #42, #28

## Plan-mode exploration (2026-10-15)

- **The visits already exist.** `data/fdis/derived/fdis_sites.csv` (0240) has one row per visit, carrying
  `linear_feature_id`, `blue_line_key`/`downstream_route_measure`, `present_CH`, `blocks_absence_of`, effort, `data_set`,
  `edge_type` and the old fwapg `mad_m3s`. That old MAD is null on 39 % of usable visits.
- **Usable visits.** 0290's quality filters give 43,141 usable visits, 1,189 of them with CH, across 73 WSGs.
  CHES (284) and NECR (246) hold 45 % of the detections, so WSG enters the model and per-WSG rates are shown.
- **wet's flow is already loaded locally.** `discharge.fwa_v1_segment_monthly` in local fwapg :5432 has
  `pick`, and its counts match the 2026-10-15 manifest (routed picked 3,152,838; balance 1,380,005). It is
  read in SQL. Nothing is downloaded and link segments are not needed.
- **Network distance.** fwapg has `fwa_downstreamtrace(blk, measure)`.
- **Accessibility.** link's `fresh_default.barriers_ch_access` covers only 23 of the 73 WSGs (886 of 1,189
  detections), and link overrides barriers with observations (`lnk_barrier_overrides.R`), the circularity
  CLAUDE.md warns about. So accessibility is a sensitivity, not a filter.
- **The analysis template.** #28's `scripts/0290`/`0291` (cloglog binomial, log(area), data_set, era,
  WSG, a stream bootstrap, power flags, raw rates beside the model, ledger).

## Errors Encountered

| Error | Resolution |
|-------|------------|
