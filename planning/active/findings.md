# Findings — Habitat weights, not only cutoffs: what BT use by gradient, elevation, size and effort should mean (#28)

## Plan-mode exploration (2026-10-02)

What exploration found that shapes the plan:

- **Effort and zero catch already exist, so this work does not wait on #23.** `data/fdis/derived/fdis_sites.csv` (from 0240) has 53,018 site visits. 51,450 are placed on FWA (`blue_line_key`, `downstream_route_measure`) and 49,037 of those have usable effort (`fishing_time_s`, `area_m2`). It also carries `catch_status` (fish 29,280, zero 21,639), `blocks_absence_of`, `n_bt`/`n_dv`, measured gradient and width, `fwa_gradient_pct`, `stream_order`, `mad_m3s`, and `modelled_channel_width_m`. 7,044 visits caught char, in 155 WSGs; 1,366 of those are in the 8 held-out WSGs. #23 is only the join to bcfishobs, and the curve does not need that join.
- **link's segmentation is on local fwapg :5432.** `fresh_default.streams` (55 WSGs), `streams_access` (`access_bt`) and `streams_habitat_bt` (accessible/spawning/rearing) are there, and `score284_default.*` covers the step-5 closure, which holds the 8 held-out pilots. So FDIS visits can be read against the segment gradient the model actually tests, as step 5 did.
- **Pooling:** `link::lnk_species_pooling()` and `inst/extdata/configs/default/species_pooling.csv` are installed. Reuse them rather than restate the region rule.
- **Life stage (Q4):** `data/fdis_evidence.csv` has char size classes (fry, juvenile, subadult, adult, spawner_evidence) per visit. That answers whether steep-water char are juveniles. link's `bands_pooled.csv` also shows some bcfishobs BT do carry a stage (10 of 46 band-1 records are "rear"), which partly corrects the issue's "bcfishobs has no BT life stage".
- **Not independent:** about 72 % of bcfishobs BT records are FDIS (#23). An FDIS curve and link's step-5 taper share a large part of their data, so their agreement is a consistency check, not corroboration. This gets stated.
- **Literature:** `data/literature_evidence.csv` has 12 BT rearing-gradient rows and 8 temperature rows (Isaak 2015, Porter 2008 HSI/CPUE, Bustard & Schell, Trotter, Dunham & Chandler 2001). It has no elevation rows, and `variable` has no `elevation` in `pkg/R/literature.R`'s vocabulary.
- **Temperature:** #20 and link#21 (GSDD) are open. Elevation is the proxy here.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Issue context

**If we do it:** BT (then CH) habitat quality becomes a defended weight between 0 and 1, built from fish use with the confounds named. link can then report quality-weighted km beside the familiar cutoff km, so "km of habitat unlocked above a crossing" stops jumping every time a threshold moves. **If we never do:** habitat stays on/off at a gradient cutoff. That cutoff silently stands in for temperature, channel size and sampling effort as well as steepness, and every km figure inherits the yes/no.

## Problem

link models habitat with hard cutoffs: a segment is BT rearing if its gradient is at or under `rear_gradient_max`, and not otherwise. That makes maps easy to read, but fish don't see a cliff. NewGraphEnvironment/link#284 step 5 measured what the cliff hides: BT and DV sightings per km of stream, by gradient band, on eight watershed groups held out from the threshold's calibration (ELKR, BULL, UARL, REVL, CLRH, LILL, BABL, BABR).

Sightings per 100 km, held out. "Core" is rearing under every cutoff tested; bands are the stream each looser cutoff adds.

| stream | km | sightings | per 100 km | vs core |
|---|---|---|---|---|
| core, gradient ≤ 2 % | 4,872 | 908 | 18.6 | 1.03 |
| core, 2–5 % | 3,045 | 603 | 19.8 | 1.10 |
| core, 5–8 % | 1,592 | 249 | 15.6 | 0.87 |
| core, 8–10.5 % | 687 | 81 | 11.8 | 0.65 |
| band 10.5–12.5 % | 422 | 46 | 10.9 | 0.60 |
| band 12.5–13.5 % | 163 | 21 | 12.9 | 0.71 |
| band 13.5–14.5 % | 138 | 8 | 5.8 | 0.32 |

Use tapers; it doesn't stop. The cutoff (link's `default_tuned` keeps 0.1349) is one line drawn across that taper.

**The taper is not gradient alone.** Core rearing itself thins with elevation: 24.6, 19.3 and 10.2 sightings per 100 km in the low, mid and high thirds of each watershed's own rearing. The steep bands sit mostly in the high third (263 of 422 km for the first band). Comparing each band with the core at its own elevation raises the first two bands to about 0.75 and 0.89 of the core rate, and leaves the third at about 0.40. So part of what reads as "too steep" is "higher up": colder, smaller, less sampled.

A second number argues the other way: about a quarter of the first band (101 of 422 km) is not steep at all. It is lower-gradient stream newly counted as rearing because the looser cutoff connects its cluster to spawning. A weight on gradient would miss that.

## Questions this should settle, before any math in link

1. **What should a habitat weight represent: intrinsic potential, or observed use?** Sightings per km are use. They carry sampling effort, access and detectability, not only preference.
2. **Which driver belongs in which weight?**
   - gradient;
   - elevation and temperature (growing degree-days), per #20 for the Fraser;
   - channel size (width is null on about half of accessible BT length in link's `fresh_default`);
   - sampling effort.

   They are correlated, and a gradient-only weight absorbs all four.
3. **Can effort be corrected for?** The FDIS site-visit table (#23) carries catch, effort and no-fish-captured. That is what separates "avoided" from "never sampled", which bcfishobs presence records cannot.
4. **Rearing vs adults.** bcfishobs has no BT life stage. The size classes from FISS submissions (#18, #21) could say whether steep-water records are juveniles rearing or adults moving through.
5. **What does the literature give as a use curve,** not a single cutoff, for BT by gradient and elevation? #19's evidence table and store are the starting point.

## Proposed Solution

1. From the questions above, a written position per driver: in the weight, handled elsewhere (for example temperature by NewGraphEnvironment/link#21's GSDD work), or treated as bias to correct.
2. A candidate weight curve for BT rearing (gradient, and elevation if it earns its place) with sources and the fish evidence behind it. Aggregates only where it leaves this repo, since link is public.
3. Then a separate link issue for the applied side: use-weighted km beside cutoff km in the rollups and per-crossing aggregation, with the weights as bundle data like the thresholds.

## Evidence

- link#284 step 5: `data-raw/logs/habitat_score_284/` in link (`taper.csv`, `elevation.csv`, `elevation_adjusted.csv`, `bands_pooled.csv`, `bridge_band.csv`, `verdict.csv`), produced by `data-raw/habitat_variants_score.R`. The method and the rule are in link's `research/habitat_thresholds.md`, "Step 5".
- Pooling: DV counts as BT per link's `configs/default/species_pooling.csv`. All eight held-out groups are in pooled regions.

Relates to #18, #19, #20, #23, NewGraphEnvironment/link#284, NewGraphEnvironment/link#21
