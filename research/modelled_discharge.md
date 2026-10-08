# Modelled discharge in BC: fwapg's MAD and PCIC's channel-scale flows

**Verified:** 2026-10-07 · **Issues:** #42, NewGraphEnvironment/fwapg#5 · **Produced by:** a reading of `fwapg/extras/discharge`
(fwapg `fbcb0a3`) and of PCIC's public repos (`chyp`, `hydromosaic-db`, `hydromosaic-service`), and an API
probe whose commands are at the end of this file.

Two modelled-flow sources reach our work. Both start from PCIC's VIC-GL runoff. They differ in how runoff
becomes flow on a stream, and in whether that stream is the FWA.

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
- Upper Bulkley Chinook (`life_history_timing.csv`, `BULK`) spawn 08-01 to 09-15, which is the annual flow
  minimum. Monthly flow against life stage is computable from this source. Its dry years should not be
  trusted without a gauge.

One segment against one gauge, on monthly means only. Daily timing, water temperature and the CMIP6 runs
were not checked.

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

- **fwapg:** already on the FWA. A monthly version is a change to `discharge.sh`, limited to the Fraser,
  Peace and Columbia.
- **PCIC hydromosaic:** wider coverage, routed, with temperature. It needs a spatial crosswalk from `subid`
  to FWA `linear_feature_id`, because the networks share no keys, and it resolves about 5× finer than
  VIC-GL's 25 km² cells, so small streams sit inside one sub-basin.

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
