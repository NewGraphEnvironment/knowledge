fx <- function() {
  fish <- data.frame(site_visit = c("v1", "v1", "v2", "v3", "v4", "v5"), species_code = c("BT", "BT", "DV", "BT", "BT", "DV"),
                     maturity_code = c("IM", "M", "SP", NA, "M", "M"), length_mm = c(90, 410, 300, 500, 120, 200),
                     stringsAsFactors = FALSE)
  visits <- data.frame(site_visit = c("v1", "v2", "v3", "v4", "v5"), month = c(9, 6, 9, 6, 9),
                       pooling = c("BT", "BT+DV", "BT", "BT", "BT"), stringsAsFactors = FALSE)
  codes <- data.frame(code = c("BT", "DV", "SLV"), species_group = "char", stringsAsFactors = FALSE)
  list(fish = fish, visits = visits, codes = codes)
}

test_that("SP/ST at any date and M in Aug-Oct are spawner evidence; the size split follows", {
  f <- fx()
  out <- knw_spawner_evidence(f$fish, f$visits, f$codes)
  v1 <- out[out$site_visit == "v1", ]
  expect_equal(v1$S, 1L)
  expect_equal(v1$S_large, 1L)
  expect_equal(v1$S_small, 0L)
  expect_equal(v1$kind, "M Sep-Oct")
  expect_equal(v1$n_coded, 2L)
  # a pooled DV coded SP in June is evidence, small
  v2 <- out[out$site_visit == "v2", ]
  expect_equal(v2$S, 1L)
  expect_equal(v2$S_small, 1L)
  expect_equal(v2$kind, "SP/ST")
})

test_that("an uncoded large fish is adult size only and no response; M outside Aug-Oct is none", {
  f <- fx()
  out <- knw_spawner_evidence(f$fish, f$visits, f$codes)
  v3 <- out[out$site_visit == "v3", ]
  expect_true(is.na(v3$S))
  expect_equal(v3$kind, "adult size only")
  v4 <- out[out$site_visit == "v4", ]
  expect_equal(v4$S, 0L)
  expect_equal(v4$kind, "M other months")
})

test_that("an unpooled DV is not a BT fish, and only BT is supported", {
  f <- fx()
  out <- knw_spawner_evidence(f$fish, f$visits, f$codes)
  expect_false("v5" %in% out$site_visit)
  expect_error(knw_spawner_evidence(f$fish, f$visits, f$codes, species = "CH"), "BT only")
})
