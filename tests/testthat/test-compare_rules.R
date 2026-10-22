# The comparison itself runs on the database (0330); its pure parts are pinned here: which of fresh's rules is the
# through-wetland rule, the branches read from link's rule lists before and after link 0.67.0, which structures a
# species is compared under, and default's label.

rules_067 <- list(rear = list(
  list(edge_types_explicit = c(1000L, 1100L, 2000L, 2300L), near_river = FALSE),
  list(waterbody_type = "R", channel_width = c(0, 9999), near_river = FALSE),
  list(edge_types_explicit = c(1050L, 1150L)),
  list(waterbody_type = "W", edge_types_explicit = c(1000L, 1100L), wetland_ha_min = 1, requires_connected = "spawning"),
  list(waterbody_type = "L", edge_types_explicit = c(1000L, 1100L, 1200L), thresholds = FALSE, lake_ha_min = 100)))
rules_run <- list(rear = list(
  list(edge_types_explicit = c(1000L, 1100L, 2000L, 2300L)),
  list(waterbody_type = "R", channel_width = c(0, 9999)),
  list(waterbody_type = "W", edge_types_explicit = c(1000L, 1100L), wetland_ha_min = 1),
  list(waterbody_type = "W", edge_types_explicit = c(1050L, 1150L), thresholds = FALSE, wetland_ha_min = 1),
  list(waterbody_type = "L", edge_types_explicit = c(1000L, 1100L, 1200L), thresholds = FALSE, lake_ha_min = 100)))
rules_gr <- list(rear = list(
  list(edge_types_explicit = c(1000L, 1100L, 2000L, 2300L)),
  list(waterbody_type = "R", channel_width = c(0, 9999), near_river = FALSE),
  list(waterbody_type = "L", edge_types_explicit = c(1000L, 1100L, 1200L), thresholds = FALSE, lake_ha_min = 40)))

test_that("the through-wetland rule is recognised in both of link's shapes, and the branches read around it", {
  expect_true(knowledge:::.knw_is_wetland_line_rule(list(edge_types_explicit = c(1050L, 1150L))))
  expect_false(knowledge:::.knw_is_wetland_line_rule(list(waterbody_type = "W", edge_types_explicit = c(1050L, 1150L))))
  expect_false(knowledge:::.knw_is_wetland_line_rule(list(edge_types_explicit = c(1000L, 1100L, 2000L, 2300L))))
  b <- knowledge:::.knw_fresh_branches(list(rules = rules_067), "rear")
  expect_identical(b$edge_stream, c(1000L, 1100L, 2000L, 2300L))
  expect_true(b$river && b$wetland_line && !b$wetland_line_free)
  expect_equal(b$wetland_ha_min, 1)
  expect_equal(b$lake_ha_min, 100)
  b0 <- knowledge:::.knw_fresh_branches(list(rules = rules_run), "rear")
  expect_true(b0$wetland_line && b0$wetland_line_free)
  expect_equal(b0$wetland_ha_min, 1)
  bg <- knowledge:::.knw_fresh_branches(list(rules = rules_gr), "rear")
  expect_false(bg$wetland_line)
  expect_null(bg$wetland_ha_min)
})

test_that("the structures follow the species' rules and the tuned rule's exception", {
  exc <- data.frame(exc_q = 3, exc_d = 1000)
  none <- data.frame(exc_q = NA_real_, exc_d = NA_real_)
  b <- knowledge:::.knw_fresh_branches(list(rules = rules_067), "rear")
  bg <- knowledge:::.knw_fresh_branches(list(rules = rules_gr), "rear")
  expect_identical(knowledge:::.knw_compare_structures(b, exc), c("free", "door", "door_wetland"))
  expect_identical(knowledge:::.knw_compare_structures(b, none), c("free", "door"))
  expect_identical(knowledge:::.knw_compare_structures(bg, exc), "door")
  expect_identical(knowledge:::.knw_compare_structures(b, exc, "door"), "door")
  expect_error(knowledge:::.knw_compare_structures(b, exc, "doors"))
})

test_that("default's label carries the pair it resolves to and the scope the dimensions give it", {
  rng <- list(channel_width = c(1.5, 9999), gradient = c(0, 0.0549))
  specs <- list(cw = data.frame(measure = "channel_width", threshold = 15, distance_max = 1000),
                mad = data.frame(measure = "discharge", threshold = 3, distance_max = 1000))
  dims <- data.frame(species = c("CH", "CO"), rear_near_river = c("wetland_flow", "both"))
  expect_identical(knowledge:::.knw_default_rule_label(rng, specs, dims, "CH", "rear"),
                   "width>=1.5|g<=0.0549|cw channel_width>=15@D1000; mad discharge>=3@D1000 on wetland_flow")
  empty <- list(cw = specs$cw[0, ], mad = specs$mad[0, ])
  expect_identical(knowledge:::.knw_default_rule_label(rng, empty, dims, "CO", "rear"), "width>=1.5|g<=0.0549|none")
  expect_identical(knowledge:::.knw_default_rule_label(rng, specs, NULL, "CH", "rear"),
                   "width>=1.5|g<=0.0549|cw channel_width>=15@D1000; mad discharge>=3@D1000")
})
