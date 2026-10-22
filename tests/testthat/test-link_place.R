test_that("the placement SQL prefers a segment starting in the window, then the containing one", {
  q <- knowledge:::.knw_place_sql("fresh_default", "tmp_v", c("BT", "CH"), c("BT", "CH"), 5)
  expect_match(q$place, "DISTINCT ON \\(t.site_visit\\)")
  expect_match(q$place, "BETWEEN t.downstream_route_measure - 1 AND t.downstream_route_measure \\+ 5")
  expect_match(q$place, "a.access_bt, a.access_ch")
  expect_match(q$place, "h_ch.rearing AS ch_rearing")
  expect_match(q$place, "fresh_default.streams_habitat_bt h_bt")
  # the containing segment is the fallback: greatest downstream measure first, then id_segment
  expect_match(q$place, "s.downstream_route_measure DESC, s.id_segment$")
  expect_match(q$overlap, "HAVING count\\(\\*\\) > 1")
})

test_that("a species with access but no habitat table gets no habitat columns", {
  q <- knowledge:::.knw_place_sql("s", "t", c("BT", "KO"), "BT", 5)
  expect_match(q$place, "a.access_ko")
  expect_no_match(q$place, "ko_rearing")
})

test_that("the package walk ends at the bank (#73) and the frozen scripts' copy is still #54's centreline walk", {
  pkg <- readLines(system.file("sql/ch_dist_profile.sql", package = "knowledge"))
  expect_true(any(grepl("bank_m", pkg)))
  expect_true(any(grepl("d := d \\+ par\\.g", pkg)))
  scripts <- testthat::test_path("..", "..", "scripts", "sql", "ch_dist_profile.sql")
  skip_if_not(file.exists(scripts), "scripts/ not present (installed package)")
  frozen <- readLines(scripts)
  # 0298 (frozen on the v2 tables) reads this copy; it keeps the centreline walk it was scored with
  expect_false(any(grepl("bank_m", frozen)))
  expect_identical(frozen[grep("^CREATE OR REPLACE FUNCTION", frozen)],
                   "CREATE OR REPLACE FUNCTION pg_temp.ch_dist_profile(start_blk integer, start_m double precision,")
})

test_that("placement runs against a live schema and re-gates the habitat flags on access", {
  conn <- skip_if_no_pg("fresh_default")
  one <- DBI::dbGetQuery(conn, "
    SELECT s.watershed_group_code, s.blue_line_key, s.downstream_route_measure + 2 AS m, s.id_segment
    FROM fresh_default.streams s
    JOIN fresh_default.streams_habitat_bt h ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
    WHERE s.watershed_group_code = 'BULK' AND h.rearing AND s.length_metre > 20 LIMIT 1")
  v <- data.frame(site_visit = "t1", watershed_group_code = one$watershed_group_code,
                  blue_line_key = as.numeric(one$blue_line_key), downstream_route_measure = as.numeric(one$m))
  p <- knw_link_place(conn, v, "fresh_default")
  expect_equal(nrow(p$placed), 1)
  expect_equal(as.numeric(p$placed$id_segment), as.numeric(one$id_segment))
  expect_true("BT" %in% p$species_access)
  expect_true(all(c("bt_rearing", "bt_rearing_stored", "access_bt") %in% names(p$placed)))
  expect_true(p$placed$bt_rearing <= p$placed$bt_rearing_stored)
})
