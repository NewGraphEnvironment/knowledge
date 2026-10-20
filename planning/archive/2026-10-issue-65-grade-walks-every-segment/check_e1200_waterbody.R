# Run from the repo root: Rscript planning/archive/2026-10-issue-65-grade-walks-every-segment/check_e1200_waterbody.R > planning/archive/2026-10-issue-65-grade-walks-every-segment/check_e1200_waterbody.txt
# Which waterbodies FWA's main-flow construction lines (edge type 1200) lie in, province-wide, by length.
c <- DBI::dbConnect(RPostgres::Postgres())
print(DBI::dbGetQuery(c, "
  SELECT round((sum(length_metre) / 1000)::numeric) km,
         round((100 * sum(length_metre) FILTER (WHERE wb = 'lake') / sum(length_metre))::numeric, 1) lake_pct,
         round((100 * sum(length_metre) FILTER (WHERE wb = 'wetland') / sum(length_metre))::numeric, 1) wetland_pct,
         round((100 * sum(length_metre) FILTER (WHERE wb = 'manmade') / sum(length_metre))::numeric, 1) manmade_pct,
         round((100 * sum(length_metre) FILTER (WHERE wb = 'river') / sum(length_metre))::numeric, 1) river_pct,
         round((100 * sum(length_metre) FILTER (WHERE wb IS NULL) / sum(length_metre))::numeric, 1) none_pct
    FROM (SELECT s.length_metre,
                 CASE WHEN EXISTS (SELECT 1 FROM whse_basemapping.fwa_lakes_poly l WHERE l.waterbody_key = s.waterbody_key) THEN 'lake'
                      WHEN EXISTS (SELECT 1 FROM whse_basemapping.fwa_wetlands_poly w WHERE w.waterbody_key = s.waterbody_key) THEN 'wetland'
                      WHEN EXISTS (SELECT 1 FROM whse_basemapping.fwa_manmade_waterbodies_poly m WHERE m.waterbody_key = s.waterbody_key) THEN 'manmade'
                      WHEN EXISTS (SELECT 1 FROM whse_basemapping.fwa_rivers_poly r WHERE r.waterbody_key = s.waterbody_key) THEN 'river'
                 END wb
            FROM whse_basemapping.fwa_stream_networks_sp s WHERE s.edge_type = 1200) x"))
DBI::dbDisconnect(c)
