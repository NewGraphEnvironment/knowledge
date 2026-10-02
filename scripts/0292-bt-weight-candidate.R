# scripts/0292-bt-weight-candidate.R
# ---------------------------------------------------------------------------
# Candidate BT rearing weight per gradient class, from the use curve 0291 wrote. Issue #28.
# Consumer: the link issue that would report use-weighted km beside cutoff km.
#
# RULE (fixed here; the reasoning is in research/habitat_weights.md):
#   - The weight is expected BT use per standard electrofishing visit on BT-accessible stream,
#     relative to core rearing: the `bt_caught` (U) weight for all WSGs.
#   - Capped at 1, then made non-increasing along link's gradient ladder by pooling adjacent
#     violators (weighted by visits). The ladder is the four core classes, then the four
#     steeper ones. Pooling makes an underpowered class borrow from its neighbours rather than
#     stand alone.
#   - `not rearing <= 10.49` is not on the gradient ladder: it is low-gradient stream that link
#     does not rear, and its weight is a question about the spawning connection, not
#     gradient. It is reported, not given a candidate weight.
#   - The `bt_caught_given_fish` (C) and `any_fish_caught` (F) weights ride along, so a
#     consumer can see that the decline is the share of fish-bearing visits (F), not BT among
#     fish (C). The weight is expected use, not habitat preference.
#
# INPUT:  data/bt_rear_use_curve.csv (scripts/0291)
# OUTPUT: data/habitat_weight_bt_rear.csv   aggregates only, no private references; can leave this repo
# RUN:    Rscript scripts/0292-bt-weight-candidate.R   (after 0291, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(tidyr) })

ladder <- c("core 0-2", "core 2-5", "core 5-8", "core 8-10.49", "10.49-12.49", "12.49-13.49",
            "13.49-14.49", ">14.49")
bounds <- tibble(class = ladder,
                 gradient_min = c(0, 0.02, 0.05, 0.08, 0.1049, 0.1249, 0.1349, 0.1449),
                 gradient_max = c(0.02, 0.05, 0.08, 0.1049, 0.1249, 0.1349, 0.1449, NA),
                 rearing_under_default = c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))

# pool-adjacent-violators for a non-increasing sequence, weighted
pava_down <- function(y, w) {
  blocks <- lapply(seq_along(y), function(i) list(v = y[i], w = w[i], n = 1L))
  i <- 1L
  while (i < length(blocks)) {
    if (blocks[[i]]$v < blocks[[i + 1L]]$v) {
      a <- blocks[[i]]; b <- blocks[[i + 1L]]
      blocks[[i]] <- list(v = (a$v * a$w + b$v * b$w) / (a$w + b$w), w = a$w + b$w, n = a$n + b$n)
      blocks[[i + 1L]] <- NULL
      i <- max(1L, i - 1L)
    } else {
      i <- i + 1L
    }
  }
  unlist(lapply(blocks, function(b) rep(b$v, b$n)))
}

curve <- read_csv("data/bt_rear_use_curve.csv", show_col_types = FALSE) |>
  filter(role == "all")
wide <- curve |>
  select(class, response, n_visits, n_detect, weight, weight_lo, weight_hi, power) |>
  pivot_wider(names_from = response, values_from = c(n_visits, n_detect, weight, weight_lo,
                                                     weight_hi, power))
if (!all(ladder %in% wide$class)) stop("a ladder class is missing from the curve")

cand <- bounds |>
  left_join(wide, by = "class") |>
  mutate(order = match(class, ladder)) |>
  arrange(order)
if (anyNA(cand$weight_bt_caught)) stop("a ladder class has no bt_caught weight (fit did not converge)")
cand$weight <- round(pava_down(pmin(1, cand$weight_bt_caught), cand$n_visits_bt_caught), 2)

out <- cand |>
  transmute(species_code = "BT", life_stage = "rearing", class, gradient_min, gradient_max,
            rearing_under_default, weight,
            basis = "U weight (BT caught per visit, effort and nuisance adjusted, all WSGs), capped at 1, pooled to non-increasing",
            weight_bt_caught = weight_bt_caught, weight_bt_caught_lo = weight_lo_bt_caught,
            weight_bt_caught_hi = weight_hi_bt_caught,
            weight_bt_given_fish = weight_bt_caught_given_fish,
            weight_any_fish = weight_any_fish_caught,
            n_visits = n_visits_bt_caught, n_present = n_detect_bt_caught,
            power = power_bt_caught,
            sources = "BC FDIS electrofishing site visits on link default segments, effort-adjusted; context: Isaak et al. 2015; Dunham and Chandler 2001; Porter et al. 2008")
write_csv(out, "data/habitat_weight_bt_rear.csv", na = "")
print(as.data.frame(out[c("class", "weight", "weight_bt_caught", "weight_bt_given_fish",
                          "weight_any_fish", "n_visits", "power")]))
