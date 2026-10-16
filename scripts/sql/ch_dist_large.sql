-- scripts/sql/ch_dist_large.sql
-- Network distance downstream from a point on an FWA blue line to the first segment whose
-- picked annual flow (wet, discharge.fwa_v1_segment_monthly) is at least qmin. Issue #52,
-- read by scripts/0294-ch-mad-build.R into each connection as a session-temporary function.
--
-- The path is walked explicitly, not taken from fwa_downstreamtrace(): that function returns
-- side channels off the path and drops segments with no fwa_streams_watersheds_lut row, so its
-- rows cannot be summed into a distance (plan review B4, planning archive for #52). Here each
-- step is measured on route measures, which have no gaps:
--   1. on the current blue line, the nearest segment below the current measure with picked flow
--      >= qmin, on a primary-flow edge: found -> add (measure - its upstream measure), stop;
--   2. otherwise add the current measure (to the line's mouth) and move to the line it flows
--      into: for a side channel (blue_line_key <> watershed_key) the main line with the same
--      watershed code; else the main line on the parent code. The entry measure there is where
--      the mouth point projects onto the nearest parent segment. A main stem's mouth lies on the
--      receiving river's centreline, so a tributary's distance includes the reach across the
--      receiving river's polygon to its centreline.
-- Status: found | none (reached the sea: a code of one level, or a parent code with no lines,
-- as on the coast; no hit on the way) | no_parent (lines at the parent code, none on its main
-- line) | too_many_hops.
CREATE OR REPLACE FUNCTION pg_temp.ch_dist_large(start_blk integer, start_m double precision,
                                                 qmin double precision)
RETURNS TABLE (dist_m double precision, large_mad double precision, large_lfid bigint,
               large_edge integer, large_waterbody_key integer, n_hops integer,
               max_entry_gap_m double precision, status text)
LANGUAGE plpgsql AS $fn$
DECLARE
  cur_blk integer := start_blk;
  cur_m double precision := start_m;
  d double precision := 0;
  hops integer := 0;
  gap double precision := 0;
  r record;
  mouth record;
  par record;
  pw ltree;
  pblk integer;
BEGIN
  LOOP
    SELECT s.linear_feature_id, s.upstream_route_measure AS urm, s.edge_type, s.waterbody_key, q.q_m3s
      INTO r
      FROM whse_basemapping.fwa_stream_networks_sp s
      JOIN discharge.fwa_v1_segment_monthly q
        ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical'
       AND q.month = 0 AND q.pick
     WHERE s.blue_line_key = cur_blk AND s.downstream_route_measure < cur_m
       AND q.q_m3s >= qmin AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
     ORDER BY s.downstream_route_measure DESC
     LIMIT 1;
    IF FOUND THEN
      RETURN QUERY SELECT d + greatest(cur_m - r.urm, 0), r.q_m3s, r.linear_feature_id::bigint,
                          r.edge_type, r.waterbody_key, hops, gap, 'found'::text;
      RETURN;
    END IF;
    d := d + cur_m;
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
      RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'no_parent'::text;
      RETURN;
    END IF;
    IF mouth.wk <> cur_blk THEN
      pw := mouth.w;          -- may be NULL: the main line is then found by its key alone
      pblk := mouth.wk;
    ELSIF mouth.w IS NULL THEN
      RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'no_parent'::text;
      RETURN;
    ELSIF nlevel(mouth.w) <= 1 THEN
      RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'none'::text;
      RETURN;
    ELSE
      pw := subpath(mouth.w, 0, nlevel(mouth.w) - 1);
      pblk := NULL;
    END IF;
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
        RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'none'::text;
      ELSE
        RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'no_parent'::text;
      END IF;
      RETURN;
    END IF;
    gap := greatest(gap, par.g);
    cur_blk := par.blk;
    cur_m := par.m;
    hops := hops + 1;
    IF hops > 60 THEN
      RETURN QUERY SELECT d, NULL::float8, NULL::bigint, NULL::int, NULL::int, hops, gap, 'too_many_hops'::text;
      RETURN;
    END IF;
  END LOOP;
END
$fn$;
