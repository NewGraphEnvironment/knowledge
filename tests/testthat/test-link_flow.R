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
  expect_identical(as.numeric(a$parent_lfid), 20)
  expect_identical(as.numeric(b$parent_lfid), 20)
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
      SELECT d.cabd_id, x.linear_feature_id, x.blue_line_key, x.wscode, x.localcode, x.measure, x.d,
             rank() OVER (PARTITION BY d.cabd_id ORDER BY x.d) AS rk
      FROM cabd.dams d
      CROSS JOIN LATERAL (SELECT ST_Transform(d.geom, 3005) AS pt) p
      CROSS JOIN LATERAL (
        SELECT s.linear_feature_id, s.blue_line_key, s.wscode_ltree::text AS wscode,
               s.localcode_ltree::text AS localcode, ST_Distance(s.geom, p.pt) AS d,
               s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), ST_Force2D(p.pt))
                 * (s.upstream_route_measure - s.downstream_route_measure) AS measure
        FROM whse_basemapping.fwa_stream_networks_sp s
        WHERE s.blue_line_key = s.watershed_key AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
        ORDER BY s.geom <-> p.pt LIMIT 3) x
      WHERE (d.reservoir_present OR d.degree_of_regulation_pc >= 10) AND x.d <= 500)
    SELECT DISTINCT ON (cabd_id) cabd_id, blue_line_key, wscode, localcode, measure,
           count(*) OVER (PARTITION BY cabd_id) AS n_tied
    FROM c WHERE rk = 1
    ORDER BY cabd_id, linear_feature_id")
  want <- want[want$n_tied > 1, ]
  skip_if(nrow(want) == 0, "no regulating dam is equidistant from two segments in this database")
  pts <- data.frame(blue_line_key = numeric(), downstream_route_measure = numeric(), wscode = character(),
                    localcode = character())
  got <- knw_link_regulated(conn, pts)$dams
  got <- got[match(want$cabd_id, got$cabd_id), ]
  expect_identical(as.numeric(got$blue_line_key), as.numeric(want$blue_line_key))
  expect_identical(got$wscode, want$wscode)
  expect_identical(got$localcode, want$localcode)
  expect_identical(got$measure, want$measure)
})

# knw_link_flow_window() (#226): the flow in a seasonal window, read on the segment MAD came from (its own, or the
# parent the flow query fell back to) and on that segment's pick source. Fixtures with one flow per month, so a
# window's value is a known weighted mean.
window_fixture <- function(conn, tbl) {
  for (t in tbl) DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", t))
  DBI::dbExecute(conn, paste("CREATE TEMPORARY TABLE", tbl[["fwa"]], "(linear_feature_id bigint,
    blue_line_key bigint, watershed_key bigint, gradient double precision, wscode_ltree ltree,
    localcode_ltree ltree, waterbody_key bigint, edge_type integer, geom geometry(LineString, 3005))"))
  DBI::dbExecute(conn, paste("CREATE TEMPORARY TABLE", tbl[["q"]], "(linear_feature_id bigint, scenario text,
    month integer, pick boolean, q_m3s double precision, source text)"))
  # 10 has its own flow; 11 has none and takes 21's, on its line; 12 has none and no line to take one from
  DBI::dbExecute(conn, paste("INSERT INTO", tbl[["fwa"]], "VALUES
    (10, 1, 1, 0.01, '100', '100.1', 0, 1000, ST_GeomFromText('LINESTRING(0 0, 0 100)', 3005)),
    (11, 2, 2, 0.01, '200', '200.1', 0, 1000, ST_GeomFromText('LINESTRING(500 0, 500 100)', 3005)),
    (21, 2, 2, 0.01, '200', '200.2', 0, 1000, ST_GeomFromText('LINESTRING(500 100, 500 200)', 3005)),
    (12, 3, 3, 0.01, '300', '300.1', 0, 1000, ST_GeomFromText('LINESTRING(900 0, 900 100)', 3005))"))
  # month m carries m m3/s on 10's picked source and 10 m on 21's; the source that is not picked carries 100 m,
  # so a read of the wrong source shows
  rows <- rbind(
    data.frame(id = 10, month = 0:12, pick = TRUE, q = c(6.5, 1:12), source = "wet_balance"),
    data.frame(id = 10, month = 0:12, pick = FALSE, q = 100 * c(6.5, 1:12), source = "pcic_routed"),
    data.frame(id = 21, month = 0:12, pick = TRUE, q = 10 * c(6.5, 1:12), source = "pcic_routed"),
    data.frame(id = 21, month = 0:12, pick = FALSE, q = 100 * c(6.5, 1:12), source = "wet_balance")
  )
  DBI::dbExecute(conn, sprintf("INSERT INTO %s VALUES %s", tbl[["q"]],
                               paste(sprintf("(%d, 'historical', %d, %s, %s, '%s')", rows$id, rows$month,
                                             tolower(rows$pick), rows$q, rows$source), collapse = ", ")))
  invisible(rows)
}

test_that("a window's flow is wet's, on the segment MAD came from and its pick source", {
  skip_if_not_installed("wet")
  conn <- skip_if_no_pg()
  ext <- DBI::dbGetQuery(conn, "SELECT extname FROM pg_extension WHERE extname IN ('postgis', 'ltree')")$extname
  skip_if_not(all(c("postgis", "ltree") %in% ext), "no postgis or ltree in the database")
  tbl <- c(fwa = "knw_fx_win_fwa", q = "knw_fx_win_q")
  withr::defer(for (t in tbl) DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", t)))
  rows <- window_fixture(conn, tbl)
  win <- data.frame(start = c("08-01", "08-15"), end = c("09-30", "09-15"))
  f <- .knw_link_flow_window(conn, c(12, 10, 11, 10), win, fwa = tbl[["fwa"]], q = tbl[["q"]])
  expect_identical(names(f), c("linear_feature_id", "mad_pick", "flow_0801_0930", "flow_0815_0915"))
  expect_identical(f$linear_feature_id, c(10, 11, 12))
  expect_identical(f$mad_pick, c(6.5, 65, NA))
  # August has 31 days and September 30; 08-15 to 09-15 is 17 days of August and 15 of September
  expect_equal(f$flow_0801_0930, c((31 * 8 + 30 * 9) / 61, 10 * (31 * 8 + 30 * 9) / 61, NA), tolerance = 1e-12)
  expect_equal(f$flow_0815_0915, c((17 * 8 + 15 * 9) / 32, 10 * (17 * 8 + 15 * 9) / 32, NA), tolerance = 1e-12)
  # and it is wet's own arithmetic on the picked rows
  picked <- rows[rows$pick, ]
  wet_says <- wet::wet_flow_window(data.frame(linear_feature_id = picked$id, source = picked$source,
                                              month = picked$month, q_m3s = picked$q),
                                   data.frame(window = c("a", "b"), start = win$start, end = win$end))
  wet_at <- function(w) {
    x <- wet_says[wet_says$window == w, ]
    x$q_m3s[match(c(10, 21), x$linear_feature_id)]
  }
  expect_identical(f$flow_0801_0930[1:2], wet_at("a"))
  expect_identical(f$flow_0815_0915[1:2], wet_at("b"))
})

test_that("a segment without every month on its pick source is refused, not read short", {
  skip_if_not_installed("wet")
  conn <- skip_if_no_pg()
  ext <- DBI::dbGetQuery(conn, "SELECT extname FROM pg_extension WHERE extname IN ('postgis', 'ltree')")$extname
  skip_if_not(all(c("postgis", "ltree") %in% ext), "no postgis or ltree in the database")
  tbl <- c(fwa = "knw_fx_win_fwa", q = "knw_fx_win_q")
  withr::defer(for (t in tbl) DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", t)))
  window_fixture(conn, tbl)
  win <- data.frame(start = "08-15", end = "09-15")
  DBI::dbExecute(conn, paste("DELETE FROM", tbl[["q"]], "WHERE linear_feature_id = 10 AND month = 9 AND pick"))
  expect_error(.knw_link_flow_window(conn, c(10, 11), win, fwa = tbl[["fwa"]], q = tbl[["q"]]),
               "1 of the 2 segments read")
  # a month picked on a second source is refused too: the window would mix two sources
  DBI::dbExecute(conn, paste("UPDATE", tbl[["q"]], "SET pick = true WHERE linear_feature_id = 10 AND month = 9"))
  expect_error(.knw_link_flow_window(conn, 10, win, fwa = tbl[["fwa"]], q = tbl[["q"]]), "1 of the 1 segments read")
})

test_that("a window's month weights are the days it takes from each month, by wet's count", {
  skip_if_not_installed("wet")
  w <- .knw_window_weights("08-15", "09-15")
  expect_identical(w$months, c(8L, 9L))
  expect_equal(w$weights, c(17, 15) / 32, tolerance = 1e-15)
  # whole months, and a window across the new year
  expect_equal(.knw_window_weights("08-01", "09-30")$weights, c(31, 30) / 61, tolerance = 1e-15)
  ny <- .knw_window_weights("12-15", "01-15")
  expect_identical(ny$months, c(1L, 12L))
  expect_equal(ny$weights, c(15, 17) / 32, tolerance = 1e-15)
  expect_equal(sum(.knw_window_weights("03-10", "07-04")$weights), 1, tolerance = 1e-12)
})

test_that("a window is labelled by its dates, and a malformed one is refused", {
  w <- .knw_windows(data.frame(start = c("08-01", "08-15"), end = c("09-30", "09-15")))
  expect_identical(w$label, c("0801-0930", "0815-0915"))
  expect_identical(w$col, c("flow_0801_0930", "flow_0815_0915"))
  expect_error(.knw_windows(data.frame(start = "8-1", end = "09-30")), "MM-DD")
  expect_error(.knw_windows(data.frame(start = "08-01", end = "13-01")), "MM-DD")
  expect_error(.knw_windows(data.frame(start = character(), end = character())), "MM-DD")
  expect_error(.knw_windows(data.frame(start = c("08-01", "08-01"), end = c("09-30", "09-30"))), "same dates")
})
