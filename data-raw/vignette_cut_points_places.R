# data-raw/vignette_cut_points_places.R
# ---------------------------------------------------------------------------
# Where each place the cut-points article (#149) names lies, so its one orienting sentence per place is computed, not
# dictated (soul's writing.md, "Orient the reader in one sentence per place"): the stream a place's stream joins, and
# the nearest town to its mouth, with the distance and a compass word.
#
# WHY / DESIGN NOTES:
#   - THE PLACES ARE THE BUNDLE'S. The concept stream, the examples and the map group are read from
#     inst/vignette-data/cut_points.rds (data-raw/vignette_cut_points.R), and this file pins that bundle's md5, so a
#     rebuilt bundle with other places is caught by the article's check, not printed beside the wrong names.
#   - THE RIVER IT JOINS comes from the Freshwater Atlas watershed code: the parent code (the last non-zero group set to
#     zeros) names the receiving stream. Where the receiving stream is unnamed the walk goes on down, and `direct`
#     records whether the named stream is the one it flows into.
#   - THE TOWN is the nearest incorporated place (city, town, village or district municipality) in the Province's BC
#     Geographical Names, measured from the stream's mouth (its downstream end on the Atlas), or, for the map group,
#     from the point on its largest named stream nearest the group's centre. That layer's catalogue licence is Access
#     Only, so this file keeps each town's name and nothing else from it (inst/NOTICE.md).
#
# INPUT:  inst/vignette-data/cut_points.rds; an fwapg database (PG* or PGSERVICE); the BC Data Catalogue (bcdata)
# OUTPUT: inst/vignette-data/cut_points_places.rds   one tibble and its meta
# RUN:    Rscript data-raw/vignette_cut_points_places.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr) })
options(warn = 1)
sf::sf_use_s2(FALSE)

f_bundle <- "inst/vignette-data/cut_points.rds"
f_out <- "inst/vignette-data/cut_points_places.rds"
town_category <- "Incorporated"

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed: ", out[1])
  out
}
dirty <- git("status", "--porcelain", "--", "data-raw/vignette_cut_points_places.R", f_bundle)
if (length(dirty)) stop("commit these first, so the file's commit is the code it ran: ", paste(dirty, collapse = "; "))

x <- readRDS(f_bundle)
places <- bind_rows(
  tibble(place = "concept", site_visit = x$concept$site$site_visit, blue_line_key = x$concept$site$blue_line_key),
  tibble(place = "example", site_visit = names(x$examples),
         blue_line_key = vapply(x$examples, function(e) e$site$blue_line_key, numeric(1)))
)

con <- DBI::dbConnect(RPostgres::Postgres())
q <- function(sql, ...) DBI::dbGetQuery(con, sql, params = list(...))
# a stream's name, watershed code and mouth (its downstream end on the Atlas)
mouth_of <- function(blk) {
  sf::st_read(con, quiet = TRUE, query = sprintf("
    SELECT blue_line_key, gnis_name, fwa_watershed_code, ST_StartPoint(ST_LineMerge(geom)) AS geom
    FROM whse_basemapping.fwa_stream_networks_sp
    WHERE blue_line_key = %s ORDER BY downstream_route_measure LIMIT 1", format(blk, scientific = FALSE)))
}
parent_code <- function(code) {
  g <- strsplit(code, "-", fixed = TRUE)[[1]]
  last <- max(which(g != "000000"))
  if (last <= 1) return(NA_character_)
  g[last] <- "000000"
  paste(g, collapse = "-")
}
# the first named stream downstream of a code, and whether it is the one the stream flows into
joins_of <- function(code) {
  p <- parent_code(code)
  hops <- 0L
  while (!is.na(p)) {
    hops <- hops + 1L
    nm <- q("SELECT gnis_name FROM whse_basemapping.fwa_stream_networks_sp
             WHERE fwa_watershed_code = $1 AND blue_line_key = watershed_key AND gnis_name IS NOT NULL LIMIT 1", p)
    if (nrow(nm)) return(list(name = nm$gnis_name, direct = hops == 1L))
    p <- parent_code(p)
  }
  list(name = NA_character_, direct = NA)
}

towns <- bcdata::bcdc_query_geodata("WHSE_BASEMAPPING.GNS_GEOGRAPHICAL_NAMES_SP") |>
  bcdata::filter(FEATURE_CATEGORY == town_category) |>
  bcdata::collect()
towns <- sf::st_transform(towns[, "GEOGRAPHICAL_NAME"], 3005)
if (nrow(towns) < 100) stop("only ", nrow(towns), " incorporated places came back from BC Geographical Names")
compass <- function(from, to) {
  d <- sf::st_coordinates(to) - sf::st_coordinates(from)
  az <- (atan2(d[, "X"], d[, "Y"]) * 180 / pi) %% 360
  c("north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west")[floor((az + 22.5) / 45) %% 8 + 1]
}
nearest_town <- function(pt) {
  i <- sf::st_nearest_feature(pt, towns)
  list(town = towns$GEOGRAPHICAL_NAME[i], km = as.numeric(sf::st_distance(pt, towns[i, ])) / 1000,
       compass = compass(towns[i, ], pt))
}

out <- bind_rows(lapply(seq_len(nrow(places)), function(i) {
  m <- mouth_of(places$blue_line_key[i])
  if (nrow(m) != 1) stop("no Atlas stream for blue line ", places$blue_line_key[i])
  j <- joins_of(m$fwa_watershed_code)
  t <- nearest_town(m)
  tibble(places[i, ], gnis_name = m$gnis_name, joins = j$name, joins_direct = j$direct,
         town = t$town, town_km = t$km, compass = t$compass)
}))

# the map group: its name, its largest named stream (highest order, then longest) and the town nearest the point on it
# closest to the group's centre
wsg <- x$map$wsg
grp <- q("SELECT watershed_group_name FROM whse_basemapping.fwa_watershed_groups_poly WHERE watershed_group_code = $1", wsg)
main <- q("SELECT gnis_name FROM whse_basemapping.fwa_stream_networks_sp
           WHERE watershed_group_code = $1 AND gnis_name IS NOT NULL
           GROUP BY gnis_name ORDER BY max(stream_order) DESC, sum(length_metre) DESC, gnis_name LIMIT 1", wsg)
pt <- sf::st_read(con, quiet = TRUE, query = sprintf("
  WITH c AS (SELECT ST_Centroid(geom) AS g FROM whse_basemapping.fwa_watershed_groups_poly WHERE watershed_group_code = '%1$s')
  SELECT ST_ClosestPoint(s.geom, c.g) AS geom
  FROM whse_basemapping.fwa_stream_networks_sp s, c
  WHERE s.watershed_group_code = '%1$s' AND s.gnis_name = '%2$s'
  ORDER BY s.geom <-> c.g LIMIT 1", wsg, gsub("'", "''", main$gnis_name)))
DBI::dbDisconnect(con)
t <- nearest_town(pt)
out <- bind_rows(out, tibble(place = "map", site_visit = NA_character_, blue_line_key = NA_real_,
                             gnis_name = grp$watershed_group_name, joins = main$gnis_name, joins_direct = NA,
                             town = t$town, town_km = t$km, compass = t$compass))
if (anyNA(out$town) || anyNA(out$joins)) stop("a place has no town or no named stream downstream")

res <- list(places = out,
            meta = list(written = format(Sys.Date()), commit = git("rev-parse", "--short", "HEAD"),
                        bundle_md5 = unname(tools::md5sum(f_bundle)), town_category = town_category))
saveRDS(res, f_out, compress = "xz")
print(as.data.frame(out))
message("Wrote ", f_out)
