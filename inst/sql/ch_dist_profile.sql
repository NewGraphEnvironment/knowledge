-- inst/sql/ch_dist_profile.sql (the package copy; scripts/sql/ch_dist_profile.sql is the centreline walk
-- of #54, kept unchanged for the frozen 0298)
-- Network distance downstream from a point on an FWA blue line to the first segment whose
-- annual flow (wet, discharge.fwa_v1_segment_monthly) is at least q, for each q in an array, in
-- one walk. Issue #54, read by scripts/0296-ch-rule-build.R and 0298 into each connection as a
-- session-temporary function; since #73 by knw_link_walks() for every walk.
--
-- The walk is scripts/sql/ch_dist_large.sql's (#52), unchanged in its path rules and statuses;
-- see that file for why the path is walked on route measures and not taken from
-- fwa_downstreamtrace(). Three differences:
--   - qmins is an array. On each line, each q not yet found takes the nearest segment below the
--     current measure with flow >= q on a primary-flow edge; the walk moves on while any q is
--     unfound, and a terminal status is returned for the qs still unfound when it stops.
--   - src picks the flow: 'pick' is wet's default source per segment (ch_dist_large's only
--     choice); 'pcic_routed' or 'wet_balance' reads that source alone, where it exists.
--   - The distance ends at the river's bank, not its centreline (#73), by fresh 0.42.0's rule
--     (frs_near_river()), so a distance tuned here is the distance link applies:
--       * a connector (edge types 1400, 1450) is never a target;
--       * where the target lies in a waterbody polygon, the connector segments the walk passed
--         inside that polygon (same waterbody_key) and the part of each hop's jump that crosses
--         that polygon are left out of the distance; a connector inside a polygon the walk only
--         passes through (a river too small to be the target) stays in it;
--       * every other gap between lines (the jump from a line's mouth to the nearest point of its
--         parent, where FWA leaves one) is counted at its straight length, as fresh counts it; the
--         walk before #73 counted none and only reported the largest (max_entry_gap_m, kept).
--     dist_centre_m is the distance to the centreline with the gaps counted, and bank_m what the
--     bank rule took off it: dist_m = greatest(dist_centre_m - bank_m, 0).
-- One row per q: found | none | no_parent | too_many_hops, as in ch_dist_large.sql.
CREATE OR REPLACE FUNCTION pg_temp.ch_dist_profile(start_blk integer, start_m double precision,
                                                   qmins double precision[], src text)
RETURNS TABLE (qmin double precision, dist_m double precision, large_mad double precision,
               large_lfid bigint, large_edge integer, large_waterbody_key integer, n_hops integer,
               max_entry_gap_m double precision, status text,
               dist_centre_m double precision, bank_m double precision)
LANGUAGE plpgsql AS $fn$
DECLARE
  cur_blk integer := start_blk;
  cur_m double precision := start_m;
  d double precision := 0;
  hops integer := 0;
  gap double precision := 0;
  todo double precision[] := qmins;
  done double precision[];
  bank_wb integer[] := '{}';       -- the polygons the walk crossed connectors or jumps inside
  bank_len double precision[] := '{}';
  entry_m double precision;
  conn_row record;    -- not `c`: the mouth query aliases a table `c`, which plpgsql would read as the variable
  mouth record;
  par record;
  pw ltree;
  pblk integer;
  term text;
BEGIN
  IF src NOT IN ('pick', 'pcic_routed', 'wet_balance') THEN
    RAISE EXCEPTION 'src must be pick, pcic_routed or wet_balance, not %', src;
  END IF;
  LOOP
    done := '{}';
    FOR qmin, large_lfid, large_mad, large_edge, large_waterbody_key, dist_centre_m IN
      SELECT t.qq, h.linear_feature_id::bigint, h.q_m3s, h.edge_type, h.waterbody_key,
             d + greatest(cur_m - h.urm, 0)
        FROM unnest(todo) t(qq)
        CROSS JOIN LATERAL (
          SELECT s.linear_feature_id, s.upstream_route_measure AS urm, s.edge_type, s.waterbody_key, q.q_m3s
            FROM whse_basemapping.fwa_stream_networks_sp s
            JOIN discharge.fwa_v1_segment_monthly q
              ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical'
             AND q.month = 0 AND ((src = 'pick' AND q.pick) OR q.source = src)
           WHERE s.blue_line_key = cur_blk AND s.downstream_route_measure < cur_m
             AND q.q_m3s >= t.qq AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300, 1400, 1450)
           ORDER BY s.downstream_route_measure DESC
           LIMIT 1) h
    LOOP
      n_hops := hops;
      max_entry_gap_m := gap;
      status := 'found';
      -- the bank rule: what the walk crossed inside the target's own polygon
      bank_m := 0;
      IF large_waterbody_key IS NOT NULL THEN
        SELECT coalesce(sum(b.m), 0) INTO bank_m
          FROM unnest(bank_wb, bank_len) AS b(wb, m)
         WHERE b.wb = large_waterbody_key;
      END IF;
      dist_m := greatest(dist_centre_m - bank_m, 0);
      done := done || qmin;
      RETURN NEXT;
    END LOOP;
    todo := ARRAY(SELECT x FROM unnest(todo) x WHERE NOT x = ANY (done));
    IF cardinality(todo) = 0 THEN
      RETURN;
    END IF;
    -- the connectors this line's walk passed inside a polygon, by polygon, before leaving it
    FOR conn_row IN
      SELECT s.waterbody_key AS wb,
             sum(least(cur_m, s.upstream_route_measure) - s.downstream_route_measure) AS m
        FROM whse_basemapping.fwa_stream_networks_sp s
       WHERE s.blue_line_key = cur_blk AND s.downstream_route_measure < cur_m
         AND s.edge_type IN (1400, 1450) AND s.waterbody_key IS NOT NULL
       GROUP BY s.waterbody_key
    LOOP
      bank_wb := bank_wb || conn_row.wb;
      bank_len := bank_len || conn_row.m;
    END LOOP;
    d := d + cur_m;
    term := NULL;
    -- a line's segments share its watershed code, but connectors and side channels (edges
    -- 1400, 1450, 1100, 1350) can carry none, so the code comes from any segment that has one
    SELECT (SELECT c.wscode_ltree FROM whse_basemapping.fwa_stream_networks_sp c
             WHERE c.blue_line_key = cur_blk AND c.wscode_ltree IS NOT NULL LIMIT 1) AS w,
           s.watershed_key AS wk, ST_Force2D(ST_StartPoint(s.geom)) AS pt
      INTO mouth
      FROM whse_basemapping.fwa_stream_networks_sp s
     WHERE s.blue_line_key = cur_blk
     ORDER BY s.downstream_route_measure
     LIMIT 1;
    IF NOT FOUND THEN
      term := 'no_parent';
    ELSIF mouth.wk <> cur_blk THEN
      pw := mouth.w;          -- may be NULL: the main line is then found by its key alone
      pblk := mouth.wk;
    ELSIF mouth.w IS NULL THEN
      term := 'no_parent';
    ELSIF nlevel(mouth.w) <= 1 THEN
      term := 'none';
    ELSE
      pw := subpath(mouth.w, 0, nlevel(mouth.w) - 1);
      pblk := NULL;
    END IF;
    IF term IS NULL THEN
      SELECT s.blue_line_key AS blk,
             s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), mouth.pt)
               * (s.upstream_route_measure - s.downstream_route_measure) AS m,
             ST_Distance(ST_Force2D(s.geom), mouth.pt) AS g,
             s.waterbody_key AS wb,
             ST_ClosestPoint(ST_Force2D(s.geom), mouth.pt) AS cp
        INTO par
        FROM whse_basemapping.fwa_stream_networks_sp s
       WHERE (pw IS NULL OR s.wscode_ltree = pw) AND s.blue_line_key = s.watershed_key
         AND (pblk IS NULL OR s.blue_line_key = pblk)
       ORDER BY s.geom <-> mouth.pt
       LIMIT 1;
      IF NOT FOUND THEN
        -- a code with no lines at all is the coast (a 9xx coastal unit): the line reached the sea
        IF pw IS NOT NULL AND NOT EXISTS (SELECT 1 FROM whse_basemapping.fwa_stream_networks_sp s
                                          WHERE s.wscode_ltree = pw) THEN
          term := 'none';
        ELSE
          term := 'no_parent';
        END IF;
      END IF;
    END IF;
    IF term IS NULL THEN
      -- the part of the jump that crosses the landing line's own polygon (a side-line connector
      -- FWA drew to the bank): the walk reaches the bank where the jump enters the polygon
      IF par.g > 0.001 AND par.wb IS NOT NULL THEN
        SELECT coalesce(sum(ST_Length(ST_Intersection(ST_MakeLine(mouth.pt, par.cp), p.geom))), 0)
          INTO entry_m
          FROM (SELECT waterbody_key, geom FROM whse_basemapping.fwa_rivers_poly
                UNION ALL SELECT waterbody_key, geom FROM whse_basemapping.fwa_lakes_poly
                UNION ALL SELECT waterbody_key, geom FROM whse_basemapping.fwa_manmade_waterbodies_poly
                UNION ALL SELECT waterbody_key, geom FROM whse_basemapping.fwa_wetlands_poly) p
         WHERE p.waterbody_key = par.wb;
        IF entry_m > 0 THEN
          bank_wb := bank_wb || par.wb;
          bank_len := bank_len || entry_m;
        END IF;
      END IF;
      gap := greatest(gap, par.g);
      d := d + par.g;         -- the jump itself counts (fresh's convention, #73)
      cur_blk := par.blk;
      cur_m := par.m;
      hops := hops + 1;
      IF hops > 60 THEN
        term := 'too_many_hops';
      END IF;
    END IF;
    IF term IS NOT NULL THEN
      RETURN QUERY SELECT x, d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, term,
                          NULL::float8, NULL::float8
                     FROM unnest(todo) x;
      RETURN;
    END IF;
  END LOOP;
END
$fn$;
