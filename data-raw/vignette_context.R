# data-raw/vignette_context.R
# ---------------------------------------------------------------------------
# What a stranger needs to place the chinook rearing map's watershed group (#77): the group's outline, British Columbia
# around it for the keymap, the towns in it, and its rivers' names, so the README figure (data-raw/readme_figure.R) and
# the article's static map can carry a keymap, a scale bar and labels with no database at build time.
#
# WHY / DESIGN NOTES:
#   - THE GROUP IS THE BUNDLE'S: the map group is read from inst/vignette-data/chinook_rearing.rds and recorded here,
#     so a bundle drawn for another group is caught by readme_figure.R and the article's check, not drawn under this
#     outline.
#   - A SCRIPT OF ITS OWN, not data-raw/vignette_chinook.R: that script rewrites bulk_segments.rds, whose md5 method.rds
#     pins, and needs the run's schema and ignored grade table. Nothing here moves a file a promotion owns.
#   - BRITISH COLUMBIA is the Freshwater Atlas's watershed groups merged and simplified at bc_simplify_m: a keymap needs
#     the province's shape, not its coast to the metre, and the Atlas is a source the package already credits.
#   - THE TOWNS come from Natural Resources Canada's Canadian Geographical Names Database (Open Government Licence -
#     Canada), its cities, towns, villages and district municipalities (concise code MUN1) inside the group's outline
#     buffered by town_buffer_m. The Province's BC Geographical Names and its municipal boundaries are both "Access
#     Only" in the BC Data Catalogue, so neither is stored here (inst/NOTICE.md). Two towns closer than town_gap_m
#     print over each other (Hazelton and New Hazelton, 5.8 km apart; Smithers and Telkwa, 12.2 km apart, both
#     fit), so of such a pair the one ranked first in town_concise (city, town, village, district) is kept.
#   - THE RIVERS are the Atlas's named streams of stream order river_order or more and at least river_km long in the
#     group, merged by name. Each label sits at the point of the river's line nearest the middle of its length,
#     turned to the line's direction there and kept upright.
#
# INPUT:  inst/vignette-data/chinook_rearing.rds; an fwapg database (PG* or PGSERVICE); NRCan's geonames service
# OUTPUT: inst/vignette-data/bulk_context.rds   aoi (the group), bc (the province), towns, rivers (sf, EPSG:3005), meta
# RUN:    Rscript data-raw/vignette_context.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages(library(dplyr))
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

f_bundle <- "inst/vignette-data/chinook_rearing.rds"
f_out <- "inst/vignette-data/bulk_context.rds"
bc_simplify_m <- 2000     # the province's outline, for a keymap a few centimetres across
aoi_simplify_m <- 100
town_buffer_m <- 5000
town_gap_m <- 8000        # two towns closer than this are one place on the map: the higher-ranked keeps the label
town_concise <- c("CITY", "TOWN", "VILG", "MUN1")   # the service's concise codes: MUN1 is a district municipality
river_order <- 6
river_km <- 20
geonames <- "https://geogratis.gc.ca/services/geoname/en/geonames.json"

wsg <- readRDS(f_bundle)$meta$map_group
stopifnot(is.character(wsg), length(wsg) == 1L, grepl("^[A-Z]{4}$", wsg))
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres()),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))

aoi <- sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT watershed_group_code, watershed_group_name, ST_SimplifyPreserveTopology(ST_Union(geom), %d) AS geom
  FROM whse_basemapping.fwa_watershed_groups_poly WHERE watershed_group_code = '%s'
  GROUP BY 1, 2", aoi_simplify_m, wsg))
stopifnot(nrow(aoi) == 1L)
# the outline alone: the merged groups keep thousands of interior rings where neighbours do not quite meet, so the
# exterior rings are taken before simplifying (143,676 vertices otherwise, 3.4 MB in the bundle)
bc <- sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT ST_SimplifyPreserveTopology(ST_Collect(ST_MakePolygon(ST_ExteriorRing(d.geom))), %d) AS geom
  FROM (SELECT (ST_Dump(ST_Union(geom))).geom FROM whse_basemapping.fwa_watershed_groups_poly) d
  WHERE ST_Area(d.geom) > 1e8", bc_simplify_m))
streams <- sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT gnis_name AS label, ST_LineMerge(ST_Union(geom)) AS geom, sum(length_metre) / 1000 AS km
  FROM whse_basemapping.fwa_stream_networks_sp
  WHERE watershed_group_code = '%s' AND gnis_name IS NOT NULL AND stream_order >= %d
  GROUP BY gnis_name HAVING sum(length_metre) / 1000 >= %d
  ORDER BY gnis_name", wsg, river_order, river_km))
DBI::dbDisconnect(conn)
aoi <- sf::st_zm(aoi, drop = TRUE)
bc <- sf::st_zm(bc, drop = TRUE)
streams <- sf::st_zm(streams, drop = TRUE)

# each river's label: the point of its line nearest the middle of its length, and the line's direction there
river_label <- function(g) {
  ls <- sf::st_cast(sf::st_sfc(g, crs = 3005), "LINESTRING")
  ls <- ls[which.max(as.numeric(sf::st_length(ls)))]
  xy <- sf::st_coordinates(ls)[, 1:2]
  d <- c(0, cumsum(sqrt(rowSums(diff(xy)^2))))
  i <- max(1L, min(nrow(xy) - 1L, findInterval(d[length(d)] / 2, d)))
  j <- min(nrow(xy), i + 5L)
  k <- max(1L, i - 5L)
  ang <- atan2(xy[j, 2] - xy[k, 2], xy[j, 1] - xy[k, 1]) * 180 / pi
  if (ang > 90) ang <- ang - 180
  if (ang < -90) ang <- ang + 180
  list(point = sf::st_point(xy[i, ]), angle = round(ang, 1))
}
lab <- lapply(sf::st_geometry(streams), river_label)
rivers <- sf::st_sf(label = streams$label, km = round(streams$km, 1), angle = vapply(lab, `[[`, numeric(1), "angle"),
                    geometry = sf::st_sfc(lapply(lab, `[[`, "point"), crs = 3005))

# the towns, from NRCan's open names service, inside the group buffered
bb <- sf::st_bbox(sf::st_transform(sf::st_buffer(aoi, town_buffer_m), 4326))
url <- sprintf("%s?bbox=%.4f,%.4f,%.4f,%.4f&concise=%s", geonames,
               bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]], paste(town_concise, collapse = ","))
tmp <- tempfile(fileext = ".json")
h <- curl::curl_fetch_disk(url, tmp, handle = curl::new_handle(timeout = 60, followlocation = TRUE))
if (h$status_code != 200) stop("geonames: HTTP ", h$status_code, " for ", url)
gn <- jsonlite::fromJSON(tmp)$items
if (!length(gn) || !nrow(gn)) stop("geonames returned no town for ", wsg)
towns <- sf::st_as_sf(data.frame(label = gn$name, concise = gn$concise$code, geonames_id = gn$id,
                                 lon = gn$longitude, lat = gn$latitude),
                      coords = c("lon", "lat"), crs = 4326) |>
  sf::st_transform(3005)
towns <- towns[lengths(sf::st_intersects(towns, sf::st_buffer(aoi, town_buffer_m))) > 0, ]
# one name per place: by rank, a town is kept only where no kept town lies within town_gap_m
towns <- towns[order(match(towns$concise, town_concise), towns$label), ]
keep <- logical(nrow(towns))
for (i in seq_len(nrow(towns))) {
  near <- any(as.numeric(sf::st_distance(towns[i, ], towns[keep, ])) < town_gap_m)
  keep[i] <- !near
}
if (any(!keep)) message("towns within ", town_gap_m, " m of a higher-ranked one, not labelled: ",
                        paste(towns$label[!keep], collapse = ", "))
towns <- towns[keep, ]
towns <- towns[order(towns$label), ]
stopifnot(nrow(towns) > 0)

out <- list(aoi = aoi, bc = bc, towns = towns, rivers = rivers,
            meta = list(written = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), map_group = wsg,
                        bundle_md5 = unname(tools::md5sum(f_bundle)),
                        sources = c(aoi = "Freshwater Atlas watershed groups (fwa_watershed_groups_poly)",
                                    bc = "the same, merged and simplified",
                                    towns = "Canadian Geographical Names Database, NRCan (geonames service)",
                                    rivers = "Freshwater Atlas stream network (fwa_stream_networks_sp)"),
                        settings = c(bc_simplify_m = bc_simplify_m, aoi_simplify_m = aoi_simplify_m,
                                     town_buffer_m = town_buffer_m, town_gap_m = town_gap_m,
                                     river_order = river_order, river_km = river_km)))
saveRDS(out, f_out)
message(f_out, ": ", wsg, "; towns ", paste(towns$label, collapse = ", "),
        "; rivers ", paste(rivers$label, collapse = ", "), "; ", round(file.size(f_out) / 1024), " KB")
