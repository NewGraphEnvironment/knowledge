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
  # reported alone (#112): tuned_as, held to the species x rule's own set
  expect_identical(knowledge:::.knw_compare_structures(b, exc, "reported", "door"), "door")
  expect_identical(knowledge:::.knw_compare_structures(b, exc, "reported", "door_wetland"), "door_wetland")
  expect_identical(knowledge:::.knw_compare_structures(bg, exc, "reported", "door"), "door")
  expect_error(knowledge:::.knw_compare_structures(bg, exc, "reported", "free"), "not a structure")
  expect_error(knowledge:::.knw_compare_structures(b, none, "reported", "door_wetland"), "not a structure")
  expect_error(knowledge:::.knw_compare_structures(b, none, c("door", "door_wetland")), "not a structure")
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

test_that("groups split into bins balanced by segment count, every group once, largest first (#87)", {
  n <- c(A = 10, B = 50, C = 30, D = 30, E = 5)
  b <- .knw_bin_groups(n, 2L)
  expect_length(b, 2L)
  expect_setequal(unlist(b), names(n))
  expect_false(anyDuplicated(unlist(b)) > 0)
  expect_identical(b[[1]][1], "B")                      # the largest group opens the first bin
  loads <- vapply(b, function(g) sum(n[g]), numeric(1))
  expect_lte(diff(range(loads)), max(n))                # greedy: no bin heavier than another by more than one group
  expect_identical(.knw_bin_groups(n, 2L), b)           # deterministic
  expect_length(.knw_bin_groups(n, 10L), 5L)            # never more bins than groups
  expect_identical(.knw_bin_groups(c(A = 1), 6L), list("A"))
  expect_setequal(unlist(.knw_bin_groups(c(A = NA, B = 2), 2L)), c("A", "B"))
})

test_that("the worker function calls no name of this package, so it runs where the package is not loaded (#87)", {
  # a socket worker resolves this package's names in the installed copy, or in none; each worker's near-river
  # table is proved by data-raw/compare_parallel_check.R on chinook, whose default walks one
  pkg_names <- ls(asNamespace("knowledge"), all.names = TRUE)
  expect_length(intersect(all.names(body(.knw_compare_bin)), pkg_names), 0L)
  expect_length(intersect(all.names(body(.knw_walk_chunk)), pkg_names), 0L)
})

test_that("the stage timer records each stage once, in order, and the stages sum to the whole (#110)", {
  tm <- .knw_timer()
  Sys.sleep(0.05)
  a <- tm$tick("first")
  b <- tm$tick("second")
  Sys.sleep(0.02)
  tm$tick("third")
  x <- tm$ticks()
  expect_identical(names(x), c("first", "second", "third"))
  expect_true(all(x >= 0))
  expect_gt(x[["first"]], 0.04 / 60)
  expect_identical(x[["first"]], a)
  expect_equal(sum(x), tm$total(), tolerance = 1e-9)
})

test_that("a bin without default's own minutes keeps the shared ones, and drops the walk only when asked (#101)", {
  b1 <- list(setup_s = 60, walk_s = 120, rule_s = c(default = 60, door = 60))
  b2 <- list(setup_s = 60, walk_s = 0, rule_s = c(default = 180, door = 60))
  x <- .knw_bin_minutes(list(b1, b2), drop_rules = "default")
  expect_equal(x$minutes, c(5, 5))
  expect_equal(x$minutes_without, c(4, 2))
  expect_false(any(x$walk_dropped))
  # a bin that stopped before its times (NULL) is skipped, and the walk goes only when asked
  y <- .knw_bin_minutes(list(b1, list(flags = NULL), b2), drop_rules = "default", drop_walk = TRUE)
  expect_equal(y$minutes_without, c(2, 2))
  expect_true(all(y$walk_dropped))
  expect_identical(y$bin, 1:2)
  expect_error(.knw_bin_minutes(list(list(flags = NULL)), "default"), "no bin")
})
