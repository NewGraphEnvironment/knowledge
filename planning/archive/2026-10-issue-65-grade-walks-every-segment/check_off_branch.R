# Run from the repo root: Rscript planning/archive/2026-10-issue-65-grade-walks-every-segment/check_off_branch.R > planning/archive/2026-10-issue-65-grade-walks-every-segment/check_off_branch.txt
# How much of each key's graded km, and of its km graded 0.8 or more, lies off the stream branch (the edge types
# the curve's visits were on and the reference was taken over), and of graded edge-1200 km (main flow through lakes
# and wetlands) the share at 0.8 or more and the share within 1 m of the curve's river.
suppressMessages(library(dplyr)); options(width = 200)
pkgload::load_all(quiet = TRUE)
br <- eval(formals(knw_grade_species)$ref_edge)
out <- lapply(c("BT_rear", "BT_spawn", "CH_rear", "CO_rear", "GR_rear", "RB_rear", "ST_rear", "WCT_rear"), function(k) {
  g <- readr::read_csv(sprintf("data/tune/%s_grades.csv", k), col_select = c(edge_type, length_metre, accessible, grade, dist_m),
                       show_col_types = FALSE) |> filter(accessible, !is.na(grade))
  on <- g$edge_type %in% br
  hi <- g$grade >= 0.8
  tibble(key = k, graded_km = round(sum(g$length_metre) / 1000), off_km = round(sum(g$length_metre[!on]) / 1000),
         off_pct = round(100 * sum(g$length_metre[!on]) / sum(g$length_metre)),
         hi_km = round(sum(g$length_metre[hi]) / 1000),
         hi_off_pct = round(100 * sum(g$length_metre[hi & !on]) / sum(g$length_metre[hi])),
         branch_hi_pct = round(100 * sum(g$length_metre[hi & on]) / sum(g$length_metre[on]), 1),
         e1200_hi_pct = round(100 * sum(g$length_metre[hi & g$edge_type == 1200]) / sum(g$length_metre[g$edge_type == 1200])),
         e1200_within1m_pct = round(100 * sum(g$length_metre[g$edge_type == 1200 & g$dist_m <= 1 & !is.na(g$dist_m)]) /
                                      sum(g$length_metre[g$edge_type == 1200])))
})
print(as.data.frame(bind_rows(out)))
