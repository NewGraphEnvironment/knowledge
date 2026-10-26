suppressPackageStartupMessages(library(DBI))
con <- dbConnect(duckdb::duckdb())
for (sp in strsplit(Sys.getenv("KEYS"), ",")[[1]]) {
  f <- sprintf("data/tune/%s_grades.csv", sp)
  q <- sprintf("SELECT count(*) n, sum(accessible::int) acc, sum(CASE WHEN grade IS NOT NULL THEN 1 ELSE 0 END) graded,
    sum(length_metre)/1000 km, sum(CASE WHEN accessible THEN length_metre END)/1000 km_acc,
    sum(CASE WHEN grade IS NOT NULL THEN length_metre END)/1000 km_graded,
    sum(CASE WHEN grade IS NOT NULL THEN length_metre*grade END)/1000 km_gw,
    sum(CASE WHEN grade < 0.2 THEN length_metre END)/1000 km_lt02,
    sum(CASE WHEN grade >= 0.8 THEN length_metre END)/1000 km_ge08,
    any_value(ref_edge) ref_edge, any_value(q_walk) q_walk, any_value(walk) walk, any_value(discharge_load) flow_load,
    sum(CASE WHEN dist_m < 1 AND grade IS NOT NULL THEN length_metre END)/1000 km_dist0,
    sum(CASE WHEN target_in_group = false THEN length_metre END)/1000 km_other_group
    FROM read_csv('%s', sample_size = 200000)", f)
  r <- dbGetQuery(con, q); cat("\n==", sp, "\n"); print(t(r))
  cat("by grade class (km, share of graded):\n")
  print(dbGetQuery(con, sprintf("SELECT grade_class, sum(length_metre)/1000 km, count(*) n FROM read_csv('%s', sample_size = 200000) WHERE grade IS NOT NULL GROUP BY 1 ORDER BY 1", f)))
  cat("by edge group: river polygon vs stream branch share of km >= 0.8:\n")
  print(dbGetQuery(con, sprintf("SELECT CASE WHEN edge_type IN (1000,1100,2000,2300) THEN 'stream' WHEN edge_type IN (1250,1350,1400,1450) THEN 'river_poly' ELSE 'other' END br,
     sum(length_metre)/1000 km_graded, sum(CASE WHEN grade >= 0.8 THEN length_metre END)/1000 km_ge08, sum(CASE WHEN dist_m < 1 THEN length_metre END)/1000 km_dist0
     FROM read_csv('%s', sample_size = 200000) WHERE grade IS NOT NULL GROUP BY 1 ORDER BY 1", f)))
}
