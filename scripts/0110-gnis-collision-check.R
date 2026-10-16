# scripts/0110-gnis-collision-check.R
# ---------------------------------------------------------------------------
# QA gate BEFORE sweeping reports by GNIS stream name: GNIS names repeat across BC
# (e.g. "Boulder Creek" is in 12 watershed groups). A name search will drag in
# reports about a same-named stream in the wrong watershed. This flags which of a
# watershed group's stream names are group-unique (safe to name-search) vs ambiguous
# (must add a geographic qualifier + verify each hit's coordinates fall in-WSG).
#
# Precedent: the "Clearwater" collision (Marjorie/Clearwater LAKE = Cariboo, not the
# PCEA "Trib to Clearwater Creek" near Mackenzie).
#
# INPUT:  data/<wsg>/gnis_seed.csv (from the PSCIS pull), live DB :63333
# OUTPUT: data/<wsg>/gnis_seed_ambiguity.csv (name, n_wsg, wsgs, wsg_only)
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(RPostgres)})

wsg  <- toupper(if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else "PINE")
seed_csv <- file.path("data", tolower(wsg), "gnis_seed.csv")
conn <- DBI::dbConnect(RPostgres::Postgres(), host="localhost", port=63333, dbname="bcfishpass", user="newgraph")

# a table carrying BOTH gnis_name and watershed_group_code (prefer bcfishpass.streams)
tbls <- DBI::dbGetQuery(conn, "
  SELECT table_schema, table_name FROM information_schema.columns
  WHERE column_name='gnis_name' AND (table_schema,table_name) IN (
    SELECT table_schema,table_name FROM information_schema.columns WHERE column_name='watershed_group_code')
  GROUP BY 1,2")
tbl <- if (any(tbls$table_schema=="bcfishpass" & tbls$table_name=="streams")) "bcfishpass.streams" else
       paste(tbls$table_schema[1], tbls$table_name[1], sep=".")

pkgload::load_all(quiet = TRUE)
seed <- readr::read_csv(seed_csv, show_col_types=FALSE)$gnis_base
amb  <- knw_gnis_collisions(conn, seed, wsg, table = tbl)
readr::write_csv(amb, file.path("data", tolower(wsg), "gnis_seed_ambiguity.csv"))

message(wsg, ": ", sum(amb$n_wsg==1), " unique names (safe), ",
        sum(amb$n_wsg>1), " ambiguous (verify location), ",
        length(attr(amb, "not_found")), " not in FWA (manual).")
DBI::dbDisconnect(conn)
