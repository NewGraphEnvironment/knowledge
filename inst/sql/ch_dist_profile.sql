-- inst/sql/ch_dist_profile.sql (the package copy; scripts/sql/ch_dist_profile.sql is the same text, kept for the frozen 0298)
-- Network distance downstream from a point on an FWA blue line to the first segment whose
-- annual flow (wet, discharge.fwa_v1_segment_monthly) is at least q, for each q in an array, in
-- one walk. Issue #54, read by scripts/0296-ch-rule-build.R and 0298 into each connection as a
-- session-temporary function.
--
-- The walk is scripts/sql/ch_dist_large.sql's (#52), unchanged in its path rules and statuses;
-- see that file for why the path is walked on route measures and not taken from
-- fwa_downstreamtrace(). Two differences:
--   - qmins is an array. On each line, each q not yet found takes the nearest segment below the
--     current measure with flow >= q on a primary-flow edge; the walk moves on while any q is
--     unfound, and a terminal status is returned for the qs still unfound when it stops.
--   - src picks the flow: 'pick' is wet's default source per segment (ch_dist_large's only
--     choice); 'pcic_routed' or 'wet_balance' reads that source alone, where it exists.
-- One row per q: found | none | no_parent | too_many_hops, as in ch_dist_large.sql.
CREATE OR REPLACE FUNCTION pg_temp.ch_dist_profile(start_blk integer, start_m double precision,
                                                   qmins double precision[], src text)
RETURNS TABLE (qmin double precision, dist_m double precision, large_mad double precision,
               large_lfid bigint, large_edge integer, large_waterbody_key integer, n_hops integer,
               max_entry_gap_m double precision, status text)
LANGUAGE plpgsql AS $fn$
DECLARE
  cur_blk integer := start_blk;
  cur_m double precision := start_m;
  d double precision := 0;
  hops integer := 0;
  gap double precision := 0;
  todo double precision[] := qmins;
  done double precision[];
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
    FOR qmin, large_lfid, large_mad, large_edge, large_waterbody_key, dist_m IN
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
             AND q.q_m3s >= t.qq AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
           ORDER BY s.downstream_route_measure DESC
           LIMIT 1) h
    LOOP
      n_hops := hops;
      max_entry_gap_m := gap;
      status := 'found';
      done := done || qmin;
      RETURN NEXT;
    END LOOP;
    todo := ARRAY(SELECT x FROM unnest(todo) x WHERE NOT x = ANY (done));
    IF cardinality(todo) = 0 THEN
      RETURN;
    END IF;
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
             ST_Distance(ST_Force2D(s.geom), mouth.pt) AS g
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
      gap := greatest(gap, par.g);
      cur_blk := par.blk;
      cur_m := par.m;
      hops := hops + 1;
      IF hops > 60 THEN
        term := 'too_many_hops';
      END IF;
    END IF;
    IF term IS NOT NULL THEN
      RETURN QUERY SELECT x, d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, term
                     FROM unnest(todo) x;
      RETURN;
    END IF;
  END LOOP;
END
$fn$;
