# knw_link_flow()'s parent fallback, and knw_link_regulated()'s dam snap, each take the nearest of a set of lines.
# Where two are equally near, the lower linear_feature_id wins, so every database holding a build picks the same
# line (#161). The fixture test runs the query on tables whose row order it controls; the live tests run on the
# ties #161 found in the Freshwater Atlas, where #158's two databases each took a different line.

test_that("an equidistant parent tie goes to the lower id, whatever order the rows were written in", {
  conn <- skip_if_no_pg()
  ext <- DBI::dbGetQuery(conn, "SELECT extname FROM pg_extension WHERE extname IN ('postgis', 'ltree')")$extname
  skip_if_not(all(c("postgis", "ltree") %in% ext), "no postgis or ltree in the database")
  tbl <- c(seg = "knw_fx_flow_seg", fwa = "knw_fx_flow_fwa", q = "knw_fx_flow_q")
  withr::defer(for (t in tbl) DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", t)))
  pick <- function(parents) {
    for (t in tbl) DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", t))
    DBI::dbExecute(conn, paste("CREATE TEMPORARY TABLE", tbl[["seg"]], "(linear_feature_id bigint)"))
    DBI::dbExecute(conn, paste("INSERT INTO", tbl[["seg"]], "VALUES (10)"))
    DBI::dbExecute(conn, paste("CREATE TEMPORARY TABLE", tbl[["fwa"]], "(linear_feature_id bigint,
      blue_line_key bigint, watershed_key bigint, gradient double precision, wscode_ltree ltree,
      localcode_ltree ltree, waterbody_key bigint, edge_type integer, geom geometry(LineString, 3005))"))
    DBI::dbExecute(conn, paste("CREATE TEMPORARY TABLE", tbl[["q"]], "(linear_feature_id bigint, scenario text,
      month integer, pick boolean, q_m3s double precision, source text)"))
    # the segment has no flow of its own; both parents meet it at a shared end, so each is 0 m away
    DBI::dbExecute(conn, paste("INSERT INTO", tbl[["fwa"]], "VALUES
      (10, 1, 1, 0.01, '100', '100.5', 0, 1000, ST_GeomFromText('LINESTRING(0 100, 0 200)', 3005))"))
    geom <- c(`20` = "LINESTRING(0 200, 0 300)", `30` = "LINESTRING(0 0, 0 100)")
    flow <- c(`20` = 5, `30` = 7)
    for (id in parents) {
      DBI::dbExecute(conn, sprintf("INSERT INTO %s VALUES (%s, 1, 1, 0.01, '100', '100', 0, 1000,
        ST_GeomFromText('%s', 3005))", tbl[["fwa"]], id, geom[[id]]))
      DBI::dbExecute(conn, sprintf("INSERT INTO %s VALUES (%s, 'historical', 0, true, %s, 'wet_balance')",
                                   tbl[["q"]], id, flow[[id]]))
    }
    DBI::dbGetQuery(conn, .knw_link_flow_sql(tbl[["seg"]], fwa = tbl[["fwa"]], q = tbl[["q"]]))
  }
  a <- pick(c("20", "30"))
  b <- pick(c("30", "20"))
  expect_identical(nrow(a), 1L)
  expect_identical(a$parent_dist_m, 0)
  expect_identical(b$parent_dist_m, 0)
  expect_true(is.na(a$own_mad))
  expect_identical(a$parent_mad, 5)
  expect_identical(b$parent_mad, 5)
})

test_that("on the Atlas lines #158 found tied, the flow is the lower-id parent's on any database", {
  conn <- skip_if_no_pg("discharge")
  # each visit line, and the two parent lines that meet it at 0 m (#161's table)
  tie <- data.frame(line = c(104084643, 105073914), lo = c(104084627, 105073883), hi = c(104084784, 105073915))
  q <- do.call(rbind, lapply(seq_len(nrow(tie)), function(i) {
    DBI::dbGetQuery(conn, sprintf("
    SELECT p.linear_feature_id, ST_Distance(p.geom, s.geom) AS d, q.q_m3s
    FROM whse_basemapping.fwa_stream_networks_sp p
    JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = %s
    JOIN discharge.fwa_v1_segment_monthly q ON q.linear_feature_id = p.linear_feature_id
     AND q.scenario = 'historical' AND q.month = 0 AND q.pick
    WHERE p.linear_feature_id IN (%s, %s)", tie$line[i], tie$lo[i], tie$hi[i]))
  }))
  q$linear_feature_id <- as.numeric(q$linear_feature_id)
  # the tie this test stands on: both parents of each line at one distance, with different flows
  for (i in seq_len(nrow(tie))) {
    lo <- q[q$linear_feature_id == tie$lo[i], ]
    hi <- q[q$linear_feature_id == tie$hi[i], ]
    expect_identical(lo$d, hi$d)
    expect_false(identical(lo$q_m3s, hi$q_m3s))
  }
  f <- knw_link_flow(conn, tie$line)
  expect_identical(f$flow_from, c("parent", "parent"))
  expect_identical(f$mad_pick, q$q_m3s[match(tie$lo, q$linear_feature_id)])
})

test_that("a dam equidistant from two segments snaps to the lower-id one", {
  conn <- skip_if_no_pg("cabd")
  # every regulating dam whose two nearest main-flow segments are equally near, with the lower-id segment's position
  want <- DBI::dbGetQuery(conn, "
    WITH c AS (
      SELECT d.cabd_id, x.linear_feature_id, x.blue_line_key, x.measure, x.d,
             rank() OVER (PARTITION BY d.cabd_id ORDER BY x.d) AS rk
      FROM cabd.dams d
      CROSS JOIN LATERAL (SELECT ST_Transform(d.geom, 3005) AS pt) p
      CROSS JOIN LATERAL (
        SELECT s.linear_feature_id, s.blue_line_key, ST_Distance(s.geom, p.pt) AS d,
               s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), ST_Force2D(p.pt))
                 * (s.upstream_route_measure - s.downstream_route_measure) AS measure
        FROM whse_basemapping.fwa_stream_networks_sp s
        WHERE s.blue_line_key = s.watershed_key AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
        ORDER BY s.geom <-> p.pt LIMIT 3) x
      WHERE (d.reservoir_present OR d.degree_of_regulation_pc >= 10) AND x.d <= 500)
    SELECT DISTINCT ON (cabd_id) cabd_id, blue_line_key, measure, count(*) OVER (PARTITION BY cabd_id) AS n_tied
    FROM c WHERE rk = 1
    ORDER BY cabd_id, linear_feature_id")
  want <- want[want$n_tied > 1, ]
  skip_if(nrow(want) == 0, "no regulating dam is equidistant from two segments in this database")
  pts <- data.frame(blue_line_key = numeric(), downstream_route_measure = numeric(), wscode = character(),
                    localcode = character())
  got <- knw_link_regulated(conn, pts)$dams
  got <- got[match(want$cabd_id, got$cabd_id), ]
  expect_identical(as.numeric(got$blue_line_key), as.numeric(want$blue_line_key))
  expect_identical(got$measure, want$measure)
})
