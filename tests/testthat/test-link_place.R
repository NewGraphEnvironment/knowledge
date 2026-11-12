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

test_that("the species and their columns do not depend on the order the catalog returns rows in (#197)", {
  # the rows knw_link_place()'s catalog query returns, in the order one database gave them on #165
  tbl <- c(rep("streams_access", 6), rep("streams_habitat_pk", 2), "streams_habitat_bt", "streams_habitat_wct",
           "streams_habitat_gr", "streams_habitat_ko")
  col <- c("id_segment", "watershed_group_code", "access_pk", "access_bt", "access_wct", "access_gr",
           "id_segment", "rearing", "rearing", "rearing", "rearing", "rearing")
  cols <- data.frame(table_name = tbl, column_name = col)
  withr::local_seed(197)
  orders <- list(seq_len(nrow(cols)), rev(seq_len(nrow(cols))), sample(nrow(cols)))
  got <- lapply(orders, function(i) knowledge:::.knw_place_species(cols[i, ]))
  expect_identical(got[[1]], list(access = c("BT", "GR", "PK", "WCT"), habitat = c("BT", "GR", "KO", "PK", "WCT")))
  for (g in got[-1]) expect_identical(g, got[[1]])
  sql <- lapply(got, function(g) knowledge:::.knw_place_sql("s", "t", g$access, g$habitat, 5)$place)
  for (q in sql[-1]) expect_identical(q, sql[[1]])
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
  for (t in c("streams", "streams_habitat_bt")) {
    skip_if_not(DBI::dbExistsTable(conn, DBI::Id(schema = "fresh_default", table = t)),
                paste0("fresh_default holds no ", t, " table"))
  }
  one <- DBI::dbGetQuery(conn, "
    SELECT s.watershed_group_code, s.blue_line_key, s.downstream_route_measure + 2 AS m, s.id_segment
    FROM fresh_default.streams s
    JOIN fresh_default.streams_habitat_bt h ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
    WHERE s.watershed_group_code = 'BULK' AND h.rearing AND s.length_metre > 20 LIMIT 1")
  # a fresh_default rebuilt with other groups, or emptied, holds none (#142): untested, not broken
  skip_if(nrow(one) == 0, "fresh_default holds no BULK bull trout rearing segment (an empty or partial build)")
  v <- data.frame(site_visit = "t1", watershed_group_code = one$watershed_group_code,
                  blue_line_key = as.numeric(one$blue_line_key), downstream_route_measure = as.numeric(one$m))
  p <- knw_link_place(conn, v, "fresh_default")
  expect_equal(nrow(p$placed), 1)
  expect_equal(as.numeric(p$placed$id_segment), as.numeric(one$id_segment))
  expect_true("BT" %in% p$species_access)
  expect_identical(p$species_access, sort(p$species_access, method = "radix"))
  expect_identical(p$species_habitat, sort(p$species_habitat, method = "radix"))
  # the _stored copies follow the habitat list's order (the re-gating loop), so they are sorted too
  stored <- grep("^[a-z]+_rearing_stored$", names(p$placed), value = TRUE)
  expect_identical(stored, paste0(tolower(p$species_habitat), "_rearing_stored"))
  expect_true(all(c("bt_rearing", "bt_rearing_stored", "access_bt") %in% names(p$placed)))
  expect_true(p$placed$bt_rearing <= p$placed$bt_rearing_stored)
})
