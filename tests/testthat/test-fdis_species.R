fx <- function() {
  sites <- data.frame(
    site_visit = c("v1", "v2", "v3", "v4", "v5"), watershed_group_code = c("BULK", "BULK", "MORR", "MORR", "BULK"),
    year = c(2000L, 2010L, 2005L, 2005L, 2001L), catch_status = c("fish", "fish", "zero", "fish", "unknown"),
    stringsAsFactors = FALSE
  )
  catch <- data.frame(
    site_visit = c("v1", "v1", "v2", "v2", "v4", "v4", "v5"),
    species_code = c("DV", "CH", "BT", "SLV", "AO", "RB", "SP"),
    n_caught = c(3, 2, NA, 1, 4, 1, 1), n_measured = c(2, 0, 1, 0, 0, 1, 0),
    stringsAsFactors = FALSE
  )
  fish <- data.frame(
    site_visit = c("v1", "v1", "v2", "v4"), species_code = c("DV", "DV", "BT", "RB"),
    length_mm = c(55, 120, 400, NA), stringsAsFactors = FALSE
  )
  codes <- data.frame(
    code = c("BT", "DV", "SLV", "CH", "AO", "RB", "SP", "NFC"),
    catch_class = c(rep("fish", 7), "zero_catch"),
    species_group = c("char", "char", "char", "CH", "", "", "", ""),
    blocks_absence_of = c("", "", "", "", "CH;CM;CO;KO;PK;SK", "", "BT;CH;CM;CO;GR;KO;PK;RB;SK;ST;WCT;char", ""),
    stringsAsFactors = FALSE
  )
  breaks <- data.frame(
    species_group = c("char", "char", "CH", "CH"), size_class = c("fry", "adult", "fry", "parr"),
    length_min_mm = c(0, 80, 0, 70), length_max_mm = c(80, Inf, 70, Inf)
  )
  list(sites = sites, catch = catch, fish = fish, codes = codes, breaks = breaks)
}

run <- function(species, pooled = NULL) {
  f <- fx()
  knw_fdis_species(f$sites, f$catch, f$fish, f$codes, f$breaks, species = species, pooled = pooled)
}

test_that("one row per visit and species, in order, with the size-class columns", {
  out <- run(c("CH", "BT"))
  expect_equal(nrow(out), 10)
  expect_equal(out$site_visit, rep(c("v1", "v2", "v3", "v4", "v5"), each = 2))
  expect_equal(out$species_code, rep(c("BT", "CH"), 5))
  expect_true(all(c("n_fry", "n_adult", "n_parr", "n_unmeasured") %in% names(out)))
})

test_that("unpooled, DV is a BT absence and a BT catch is BT presence", {
  out <- run("BT")
  expect_equal(out$status[out$site_visit == "v1"], "absent")
  expect_equal(out$status[out$site_visit == "v2"], "present")
  expect_equal(out$pooling, rep("BT", 5))
})

test_that("pooled DV counts as BT, with its fish in the size classes, up to obs_year_max", {
  out <- run("BT", pooled = data.frame(watershed_group_code = "BULK", obs_year_max = 2005))
  v1 <- out[out$site_visit == "v1", ]
  expect_equal(v1$status, "present")
  expect_equal(v1$n_caught, 3)
  expect_equal(v1$n_fry, 1L)
  expect_equal(v1$n_adult, 1L)
  expect_equal(v1$n_unmeasured, 1)
  expect_equal(v1$pooling, "BT+DV")
  # v2 is 2010, past the pooling year: BT alone still counts
  expect_equal(out$pooling[out$site_visit == "v2"], "BT")
  expect_equal(out$status[out$site_visit == "v2"], "present")
})

test_that("a sentinel count gives NA n_caught, presence kept", {
  out <- run("BT")
  v2 <- out[out$site_visit == "v2", ]
  expect_true(is.na(v2$n_caught))
  expect_true(v2$present)
  expect_equal(v2$n_adult, 1L)
})

test_that("a blocking code makes an absence blocked, not absent", {
  out <- run(c("CH", "CO", "RB", "ST"))
  v4 <- out[out$site_visit == "v4", ]
  # AO (all salmon) blocks CH and CO; RB is present; ST is simply absent
  expect_equal(v4$status[v4$species_code == "CH"], "blocked")
  expect_equal(v4$status[v4$species_code == "CO"], "blocked")
  expect_equal(v4$status[v4$species_code == "RB"], "present")
  expect_equal(v4$status[v4$species_code == "ST"], "absent")
})

test_that("a char code other than BT or DV blocks a BT absence either way", {
  f <- fx()
  f$catch <- f$catch[f$catch$site_visit == "v2" & f$catch$species_code == "SLV", ]
  f$fish <- f$fish[0, ]
  out <- knw_fdis_species(f$sites, f$catch, f$fish, f$codes, f$breaks, species = "BT")
  expect_equal(out$status[out$site_visit == "v2"], "blocked")
  out <- knw_fdis_species(f$sites, f$catch, f$fish, f$codes, f$breaks, species = "BT",
                          pooled = data.frame(watershed_group_code = "BULK", obs_year_max = NA))
  expect_equal(out$status[out$site_visit == "v2"], "blocked")
})

test_that("a group-level block (char) blocks BT, and SP blocks everything", {
  out <- run(c("BT", "CH", "RB", "WCT"))
  expect_equal(out$status[out$site_visit == "v5"], rep("unknown", 4))
  f <- fx()
  f$sites$catch_status[5] <- "fish"
  out <- knw_fdis_species(f$sites, f$catch, f$fish, f$codes, f$breaks, species = c("BT", "CH", "RB", "WCT"))
  expect_equal(out$status[out$site_visit == "v5"], rep("blocked", 4))
})

test_that("an explicit zero catch is an absence for every species", {
  out <- run(knw_species())
  expect_equal(unique(out$status[out$site_visit == "v3"]), "absent")
  expect_equal(unique(out$n_caught[out$site_visit == "v3"]), 0)
})

test_that("a measured fish with no length is counted as unmeasured", {
  out <- run("RB")
  v4 <- out[out$site_visit == "v4", ]
  expect_equal(v4$n_caught, 1)
  expect_equal(v4$n_measured, 1)
  expect_equal(v4$n_unmeasured, 1)
})

test_that("a duplicated visit or code is refused", {
  f <- fx()
  expect_error(knw_fdis_species(rbind(f$sites, f$sites[1, ]), f$catch, f$fish, f$codes, f$breaks, "BT"),
               "site_visit appears twice")
  expect_error(knw_fdis_species(f$sites, f$catch, f$fish, rbind(f$codes, f$codes[1, ]), f$breaks, "BT"),
               "code appears twice")
})

test_that("the species vocabulary is link's default set", {
  expect_setequal(knw_species(), c("BT", "CH", "CM", "CO", "GR", "KO", "PK", "RB", "SK", "ST", "WCT"))
})
