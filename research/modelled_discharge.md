# Modelled discharge in BC: wet's published flow per FWA segment, and what it is built from

**Verified:** 2026-10-27 for the first section, at the build the database holds; 2026-10-07 for the rest · **Issues:**
#42, #89, NewGraphEnvironment/fwapg#5, NewGraphEnvironment/fwapg#6, NewGraphEnvironment/link#331 · **Produced by:** the
table comment and a count of `discharge.fwa_v1_segment_monthly` (build 2026-10-19T06:08:31Z from wet `94deeb5`, the
wet#103 branch at 0.4.13, released as 0.4.14 at `42c3da7`), wet's `data/checks/pcic_routed_compare_20260717.txt` and `segment_output_20260717.txt` at that commit, and its
`NEWS.md`; the first section's earlier reading was of wet `647767d` (v0.4.7) and build `acb820f`; before that, `fwapg/extras/discharge`
(fwapg `fbcb0a3`), PCIC's public repos (`chyp`, `hydromosaic-db`, `hydromosaic-service`) and an API probe whose
commands are at the end of this file.

## Use this: wet's published flow per FWA segment

**Which build.** The evidence #73 graded on (`scripts/0310`, 2026-10-22) read the build loaded on 2026-10-19 from wet
`94deeb5`, and this section describes that build. wet has republished since: the live manifest read
2026-10-20T18:40:10Z when the evidence was built and 2026-10-24T12:23:01Z on 2026-10-27, after wet 0.4.15 (monthly
shares from donor gauges, wet#102), 0.4.16 (a daily product, wet#99) and later releases; the database still holds
`94deeb5`. Read the table comment
(`obj_description('discharge.fwa_v1_segment_monthly'::regclass)`) before comparing two runs.

wet publishes mean monthly and annual flow for every FWA segment at `s3://fresh-bc/discharge/fwa/v1/`. The
bucket allows reads but no listing, so start from `manifest.json` (`wet_catalog()`); 67 parquet parts,
Hive-partitioned by `scenario`, `forcing` and `source`. `segment_monthly` holds
`linear_feature_id, month, runoff_mm, q_m3s, coverage, source, period, pick`: month 0 is the annual mean,
1–12 the calendar months. Read it with `wet_segment_monthly()`, or load it to Postgres as
`discharge.fwa_v1_segment_monthly` with `wet_db_load()`.

**Two sources, each kept where it exists:**
- `pcic_routed`, 1981–2010 (1951–2012 before wet#103): PCIC's VIC-GL runoff routed by Raven on PCIC's own network (the hydromosaic
  section below), placed on FWA segments by NewGraphEnvironment/fwapg#6. Month 0 is the plain mean of the 12
  months.
- `wet_balance`, 1981–2010: wet's open water balance, province-wide, Liard included. Annual flow is climr
  precipitation less CGIAR evapotranspiration (floored by Fu–Budyko, adjusted by hydrologic zone), fitted at
  315 HYDAT gauges. Its months are shares of the annual volume, modelled from monthly climate, elevation,
  location and two ERA5-Land snow terms (wet#16, wet#77).

**`pick` is the default, chosen once per segment on annual flow.** Routed PCIC, unless its annual flow is
under 0.2 of the balance's on a segment that lies on its own watershed's line; otherwise whichever exists.
Routed on 3,154,131 segments, the balance on 1,378,712 (222,906 of them where routed is under the cut) (all of the Liard, and most of the Nechako Reservoir
groups, where PCIC's outlets are unplaced: NewGraphEnvironment/fwapg#24), neither on 374,598, almost all of
them segments with no row in `fwa_streams_watersheds_lut` (369,217).

**How good it is, at wet's calibration gauges:**
- Annual, at the 290 of 315 gauges routed flow reaches: mean absolute error 24.2 % for routed, 27.6 % for
  the balance scored held out (medians 13.1 and 18.0 %), 23.0 % for `pick`. The balance is weakest on small
  basins, at headwaters, at lake outlets and in the dry interior (hydrologic zones 15, 17, 23, 24).
- Monthly, the two fail differently. The balance reads high in April and May (median 7–11 %), within ±5 % in
  the other months, and flattens the freshet: at Buck Creek (08EE013) its highest month is under half the
  gauge's. Where routed flow does not reach, mostly the Liard, it reads low in winter. Routed PCIC reads low in
  spring and high in summer: on matching periods, 11.5 % low in March–April and 15.8 % high in July–August (wet
  0.4.14's NEWS; about 20 % and 19 % on the 1951–2012 run), so the period explains part of the shape and PCIC's
  model the rest (wet#67).

**Flow in a life-stage window.** `wet_flow_window()` gives a window's mean from the monthly values, each day
taking its month's mean (`basis = "monthly"`). wet's monthly-flow article does this for the upper Bulkley
Chinook windows, read from this repo's `life_history_timing.csv` (BULK rows at a pinned commit), at 08EE013
and 08EE003. Against the gauges' daily records the approximation is within 5 % except in fry migration
(Jul 15 – Sep 7), up to 27 % off, because the second half of July runs well below July's mean; even there
both sources miss by more. A 7-day minimum per segment needs daily flow, which neither source publishes yet
(wet#70; the routed side is NewGraphEnvironment/fwapg#25).

**These are normal-year flows.** Both sources are 30-year climatologies, so no single dry year is in them,
and the Houston check below (the model 2–3× high in drought Septembers) is a property of PCIC's year-by-year
series, not of the published means. How far a dry year falls below normal comes from gauges: wet's station
path (`wet_station_daily()`, `wet_window_stats(stats = c("mean", "min7"))`, departures through cd). At
08EE013 and 08EE003 the Chinook spawning window (1 Aug – 15 Sep) was 58–82 % below its 1981–2010 mean in
every year 2023–2026, and the 7-day minima 51–88 % below (wet's `research/station_flow_departure.md`).
Monthly bias by region and season is wet#6.

**Who reads it.** This repo's evidence, grades and comparison read its `pick` (`knw_link_flow()`, `knw_link_segments()`,
`knw_compare_rules()`). link reads it only for a bundle that sets `discharge_source: wet` (NewGraphEnvironment/link#331):
`default_tuned` does; `default` sets none, so it reads fwapg's older annual table (next section), and the province-wide
`default` run's flow flags were made on those flows.

## Where the flows come from

Two older modelled-flow products sit under this. Both start from PCIC's VIC-GL runoff. They differ in how
runoff becomes flow on a stream, and in whether that stream is the FWA.

**What the .nc files hold.** The format is the same; the arrays are not.
- **Gridded VIC-GL** (`allwsbc.*.RUNOFF.nc`, `BASEFLOW.nc`): time × lat × lon, 1/16° cells (~28 km² at 54° N).
  Each value is runoff **depth in mm** leaving that cell's land surface that day. VIC has no rivers, so a
  cell's value is not the flow of the river crossing it. Someone has to gather it from everything upstream:
  fwapg does that on the FWA; PCIC uses RVIC on the grid, or Raven on sub-basins.
- **Hydromosaic** (served by the API): outlet (`nbasins`) × time, with no lat/lon. Each value is already
  **flow in m³/s** at a sub-basin outlet, routed by Raven. Where each outlet sits is kept in the separate
  network files.

## fwapg: VIC-GL runoff accumulated on the FWA

`fwa_stream_networks_discharge` (`mad_mm`, `mad_m3s` per `linear_feature_id`) is the MAD that bcfishpass
thresholds Chinook on (`load_habitat_linear_ch.sql`). `extras/discharge/discharge.sh` builds it:

1. It downloads PCIC's gridded VIC-GL `BASEFLOW` and `RUNOFF` (`allwsbc.TPS_gridded_obs_init.1945to2099`,
   about 1/16°), daily, for index slice `[13149:24105]`: 1981-01-01 to 2010-12-31.
2. `cdo yearsum` then `timmean`: mean annual mm per grid cell, baseflow plus runoff. **The monthly signal is
   discarded here.**
3. It samples that raster at the **centroid** of each FWA fundamental watershed (`ST_Value`), a point sample
   rather than an area overlay.
4. For each fundamental watershed, it takes the area-weighted mean mm over every FWA watershed upstream
   (`FWA_Upstream` on the watershed codes), times the upstream area, giving m³/s. This is accumulation, not
   routing: no travel time, no lake storage. That costs nothing for an annual mean.
5. It skips watersheds along rivers of stream order 8 or more, so the largest mainstems have no MAD. The
   reason was processing time: each mainstem watershed sums a very large upstream set. The code comment gives
   both reasons, "we do not generally care about the discharge of these large rivers and modelling their
   discharge can be very slow (so many records upstream)".
6. It copies each value to streams through `fwa_streams_watersheds_lut`.

It covers the watershed groups whose FWA watershed codes fall under `100`, `200` or `300`, which together
are the Fraser, Peace and Columbia, because the gridded product covers only those basins. So **fwapg's MAD is fully tied to the
FWA**, and its method is public. PCIC supplies only a gridded runoff field.

A monthly version would change step 2 only: a monthly climatology (`cdo ymonmean` over monthly sums) instead
of the annual mean, carried through the same accumulation. The limits stay the same: the same three basins,
centroid sampling of ~30 km² cells, and no routing, which matters more month by month than for an annual
mean, because lakes delay and flatten the hydrograph.

## PCIC hydromosaic: VIC-GL runoff routed by Raven on its own network

PCIC's newer chain (Feb 2026 update) feeds VIC-GL runoff to Raven's routing, on a "catchment discretization
where the river network is represented as individual sub-basins with discrete stream channels". It produces
streamflow, water temperature and dissolved-oxygen saturation. The portal is `chyp`
(<https://beehive.pacificclimate.org/chyp/>).

- **Coverage.** `chyp`'s import loads river and lake GeoPackages for `Fraser`, `BC_Coast`, `Peace`,
  `Columbia`, `Kettle` and `Okanagan`, in BC Albers. That is most of BC, with no Liard. The upper Bulkley is
  present, so the Skeena is at least partly inside `BC_Coast`.
- **Network.** About 48,000 river segments, 0.5–7 km long near Houston. Each carries only `subid`, `dowsubid`
  and `uid`. Those are BasinMaker's routing-product field names, so it is probably a BasinMaker network. **It
  is not the FWA:** there is no FWA key, name or drainage area on a segment. FWA appears in `chyp` only as a
  name search against the BC Geographic Warehouse.
- **What is not public.** How the network was built (DEM and hydrography inputs), the Raven configuration, and
  how runoff cells map to sub-basins. The GeoPackages come from a `/data` mount outside the repo, and
  `hydromosaic-db` says "geography and mapping are handled by a separate database".
- **Series.** 51 per segment:
  - streamflow, water temperature and dissolved-oxygen saturation;
  - for each, 16 CMIP6 runs (8 models × SSP2-4.5 and SSP5-8.5) and one PNWNAmet run driven by observed
    historical weather;
  - daily, 1950–2100 (the PNWNAmet run 1950–2012).
  - Day 1 is a start-up artefact (18.6 m³/s, then 5.8 on day 2 at segment 8007139). Drop at least 1950.

### Check against a gauge: Bulkley River near Houston (08EE003)

The gauge (2,319 km² gross drainage) is 18 m from segment `8015011`. That segment's upstream network has 136
sub-basins against 134 at `8007139` above Houston, so it does not include the Morice, which is consistent
with the gauge's area. The table compares the PNWNAmet run with WSC monthly means, over 156 shared months
(1971–2012). Most gauge years are open-water only, so winter months have n = 3–5.

| month | gauge m³/s | model m³/s | model / gauge | n |
|---|---|---|---|---|
| Apr | 15.2 | 11.9 | 0.78 | 10 |
| May | 78.7 | 69.2 | 0.88 | 22 |
| Jun | 33.2 | 43.7 | 1.32 | 22 |
| Jul | 10.5 | 10.7 | 1.01 | 22 |
| Aug | 2.7 | 2.8 | 1.04 | 22 |
| Sep | 1.9 | 2.4 | 1.23 | 23 |
| Oct | 4.1 | 5.4 | 1.34 | 17 |

- Monthly r = 0.88; mean 19.8 (gauge) vs 20.0 (model) over the shared months.
- **The model does not reproduce drought low flows.** In the 23 shared Septembers, the gauge mean was below
  1 m³/s in 9 and the model in 3. The model ran 2–3× high in the driest years: 1991 gauge 0.37 vs model 1.31;
  1992 gauge 0.46 vs model 4.32.
- Gottesfeld & Rabnett 2007 (evidence data row 121) give 1 m³/s as the flow below which salmon migration is
  often blocked in the upper Bulkley. Below that line, the model overstates the flow that matters.
- The cited flow needs by species and stage (#44) are in `flow_requirements.md`, with how each kind of row compares
  with these monthly flows.
- Upper Bulkley Chinook (`life_history_timing.csv`, `BULK`) spawn 08-01 to 09-15, which is the annual flow
  minimum. Monthly flow against life stage is computable from this source. Its dry years should not be
  trusted without a gauge.

One segment against one gauge, on monthly means only. Daily timing, water temperature and the CMIP6 runs
were not checked. wet has since scored routed flow at 279 gauges and the balance at 315 (first section), so
this check now stands only for what it says about dry years.

## Terms

- PCIC posts no data terms on `chyp`, the hydromosaic API or the portal pages. The UVic "terms of use" footer
  link is the university's generic website policy, with nothing on reusing data.
- re3data lists PCIC's data portal under a Public Domain data license: "publicly available with an open
  license" (<https://www.re3data.org/repository/r3d100014001>, checked 2026-10-07).
- The data is provided "AS IS".
- The software (`chyp`, `hydromosaic-*`) is GPL-3.0.
- Precedent: fwapg already redistributes a PCIC derivative. Its `fwa_stream_networks_discharge.csv.gz` on the
  BC object store is built from PCIC's gridded runoff and names PCIC as the source.
- Cite PCIC as the source of anything derived. Nothing found restricts it.

## Using either one with FWA-based habitat

As of 2026-10-15 the crosswalk this section called for is built: NewGraphEnvironment/fwapg#6 placed the
hydromosaic outlets on FWA segments, and NewGraphEnvironment/fwapg PR #22 publishes the result to fresh-bc and
loads it in `load.sh`. wet republishes it beside its own balance (first section). The fwapg annual table is
unchanged and is still what link and fresh read until NewGraphEnvironment/link#331.

## Probe recipe

Base `https://beehive.pacificclimate.org`, no key, as of 2026-10-07.

```bash
B=https://beehive.pacificclimate.org
# rivers in a bbox: BC Albers coordinates, no bbox-crs (lon/lat and bbox-crs both return nothing)
curl -s "$B/bbox-server/collections/rivers/items.json?bbox=951900,1038400,963900,1050400&limit=50"
curl -s "$B/bbox-server/collections/upstreams/items/8015011.json"     # .properties.upstream_subids
curl -s "$B/hydromosaic/outlets/8015011/timeseries"                   # series list; outlet id = subid
curl -s "$B/hydromosaic/outlets/8015011/timeseries/2098588/data"      # PNWNAmet streamflow CSV
curl -s "https://api.weather.gc.ca/collections/hydrometric-monthly-mean/items?STATION_NUMBER=08EE003&limit=2000&f=json"
```

**Bulk download (the way to pull many outlets):**
- `POST $B/hydromosaic/bulk-downloads` with JSON
  `{"subids": [...], "model": "PNWNAmet", "scenario": "historical", "variable": "streamflow", "format": "netcdf"}`.
  The `format` field is required.
- It returns one netCDF (outlet × time). 1,000 outlets took 29 s and came to 159 MB (2026-10-07).
- All the subids in one request must come from one of PCIC's data files, or the request returns 422. The
  first digit of the subid looks like the region; that is not confirmed.
- `GET $B/hydromosaic/outlets` lists 68,716 outlets. That is more than the ~48,000 river segments in
  `chyp`, so the list includes lakes.

The CSV has a short `Attribute, Value` header, then `Time, streamflow (m**3 s**-1)`. Monthly means were the
mean of daily values per calendar month, from 1952 on.
