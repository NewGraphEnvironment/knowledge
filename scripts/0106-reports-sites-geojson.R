# scripts/0106-reports-sites-geojson.R
# ---------------------------------------------------------------------------
# Spatialise the hand-curated table of findings from the past-report reading
# (data/<region>/report_sites.csv, transcribed from data/<region>/report_notes/) into a
# WGS84 GeoJSON for QGIS, one point per finding, with the watershed group stamped from
# the FWA polygons rather than assumed. Issue NewGraphEnvironment/knowledge#11.
#
# Location types in the CSV (loc_type):
#   utm           crs (EPSG 326xx) + x + y, as printed in the report
#   dms           lat_dms / lon_dms as printed ("51 26 42.0 N", "119 38 45.6 W")
#   stream_mouth  stream_name: the downstream end of the FWA named stream (approximate)
#   stream_km     stream_name + km_upstream: that far up the FWA blue line (approximate)
# `location_quality` in the output says which.
#
# INPUT:  REGION (default "thompson") -> data/<region>/report_sites.csv
#         FWA polygons + named streams: bcfishpass tunnel :63333, else local fwapg :5432
# OUTPUT: data/<region>/report_sites.geojson (EPSG:4326)
# ---------------------------------------------------------------------------

suppressMessages({ library(dplyr); library(sf); library(readr); library(stringr); library(DBI); library(RPostgres) })
sf::sf_use_s2(FALSE)

region  <- Sys.getenv("REGION", unset = "thompson")
# groups the named-stream lookups are confined to: GNIS names repeat across BC
region_groups <- strsplit(Sys.getenv("REGION_GROUPS", unset = "LNTH,UNTH"), ",")[[1]]
in_csv  <- file.path("data", region, "report_sites.csv")
out_gj  <- file.path("data", region, "report_sites.geojson")
stopifnot("report_sites.csv not found" = file.exists(in_csv))
sites <- readr::read_csv(in_csv, show_col_types = FALSE,
                         col_types = readr::cols(.default = readr::col_character()))

# ---- connection: tunnel first, local fwapg when the tunnel is down ------------
tunnel_err <- NULL
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 63333,
                                dbname = "bcfishpass", user = "newgraph"),
                 error = function(e) { tunnel_err <<- conditionMessage(e); NULL })
if (is.null(conn)) {
  if (!grepl("connection refused|could not connect|timed out", tunnel_err, ignore.case = TRUE))
    stop("tunnel answered but failed: ", tunnel_err, call. = FALSE)
  conn <- DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 5432,
                         dbname = "fwapg", user = "postgres", password = "postgres")
  message("tunnel down — using local fwapg")
}

# ---- geometry per location type ----------------------------------------------
dms <- function(s) {
  p <- str_match(s, "^\\s*([0-9]+)\\s+([0-9]+)\\s+([0-9.]+)\\s*([NSEW])\\s*$")
  v <- as.numeric(p[, 2]) + as.numeric(p[, 3]) / 60 + as.numeric(p[, 4]) / 3600
  ifelse(p[, 5] %in% c("S", "W"), -v, v)
}
to_4326 <- function(x, y, crs) {
  st_transform(st_sfc(st_point(c(x, y)), crs = crs), 4326)
}
stream_point <- function(name, km = NA) {
  # The mouth is where FWA says it is: downstream_route_measure = 0 on the blue line.
  # Do NOT take an end of the merged named-streams line — measured 2026-09-08, the merged
  # line's END is the SOURCE for Fennell Creek (its START sits on the Barrière River), and
  # the two ends are 12 km apart, so guessing puts a site on the wrong half of the stream.
  q <- sprintf("SELECT blue_line_key, downstream_route_measure AS dsm, upstream_route_measure AS usm,
                       ST_AsText(ST_Transform(geom, 4326)) AS wkt
                FROM whse_basemapping.fwa_stream_networks_sp
                WHERE gnis_name = $1 AND watershed_group_code IN (%s)
                ORDER BY downstream_route_measure",
               paste(DBI::dbQuoteString(conn, region_groups), collapse = ", "))
  seg <- DBI::dbGetQuery(conn, q, list(name))
  stopifnot("named stream not found" = nrow(seg) > 0)
  blk <- names(sort(table(seg$blue_line_key), decreasing = TRUE))[1]
  if (dplyr::n_distinct(seg$blue_line_key) > 1)
    message("  note: '", name, "' has ", dplyr::n_distinct(seg$blue_line_key),
            " blue lines in the region; using the one with most segments (", blk, ")")
  seg <- seg[seg$blue_line_key == blk, ]
  target <- if (is.na(km)) 0 else km * 1000
  stopifnot("km_upstream exceeds the mapped stream" = target <= max(seg$usm))
  i <- which(seg$dsm <= target & seg$usm >= target)[1]
  if (is.na(i)) i <- which.min(abs(seg$dsm - target))
  line <- st_sfc(st_as_sfc(seg$wkt[i]), crs = 4326)
  if (inherits(line[[1]], "MULTILINESTRING")) line <- st_line_merge(line)
  # each segment is digitised downstream -> upstream, so the fraction along it is
  # (target - dsm) / segment length in route-measure units
  frac <- if (seg$usm[i] > seg$dsm[i]) (target - seg$dsm[i]) / (seg$usm[i] - seg$dsm[i]) else 0
  st_line_sample(st_transform(line, 3005), sample = max(0, min(1, frac))) %>%
    st_cast("POINT") %>% st_transform(4326)
}

geoms <- vector("list", nrow(sites)); quality <- character(nrow(sites))
for (i in seq_len(nrow(sites))) {
  s <- sites[i, ]
  if (s$loc_type == "utm") {
    geoms[[i]] <- to_4326(as.numeric(s$x), as.numeric(s$y), as.integer(s$crs)); quality[i] <- "exact_utm"
  } else if (s$loc_type == "dms") {
    geoms[[i]] <- st_sfc(st_point(c(dms(s$lon_dms), dms(s$lat_dms))), crs = 4326); quality[i] <- "exact_dms"
  } else if (s$loc_type == "stream_mouth") {
    geoms[[i]] <- stream_point(s$stream_name); quality[i] <- "approx_stream_mouth"
  } else if (s$loc_type == "stream_km") {
    geoms[[i]] <- stream_point(s$stream_name, as.numeric(s$km_upstream)); quality[i] <- "approx_stream_km"
  } else stop("unknown loc_type: ", s$loc_type)
}
if (any(str_detect(sites$note, "approximate"))) quality[str_detect(sites$note, "approximate") & quality == "exact_utm"] <- "approx_utm"
sites$location_quality <- quality
pts <- st_sf(as.data.frame(sites), geometry = do.call(c, geoms), crs = 4326)

# ---- watershed group from the FWA polygons, not from the report -----------------
wsg <- sf::st_read(conn, query = "SELECT watershed_group_code, geom FROM whse_basemapping.fwa_watershed_groups_poly", quiet = TRUE) %>%
  st_transform(4326)
DBI::dbDisconnect(conn)
hit <- st_intersects(pts, wsg)
pts$watershed_group <- vapply(hit, function(h) if (length(h)) wsg$watershed_group_code[h[1]] else NA_character_, character(1))
stopifnot("every site falls in a watershed group" = !any(is.na(pts$watershed_group)))
pts$in_north_thompson <- pts$watershed_group %in% c("LNTH", "UNTH")

# ---- tidy columns for styling ------------------------------------------------------
pts <- pts %>%
  mutate(across(c(fpci_score, habitat_gain_m, year_found, year_fixed), ~ suppressWarnings(as.numeric(.x))),
         ecocat_url = str_replace_all(report_id, "([0-9]+)", "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=\\1"),
         ecocat_url = str_replace_all(ecocat_url, ";", " ; ")) %>%
  select(site_id, name, watershed_group, in_north_thompson, category, status, priority,
         fpci_score, habitat_gain_m, species, year_found, year_fixed,
         stream, road, report_id, report_year, org, note, location_quality, ecocat_url, geometry)

unlink(out_gj)
st_write(pts, out_gj, driver = "GeoJSON", quiet = TRUE, layer_options = c("RFC7946=YES", "WRITE_BBOX=YES"))
message(sprintf("Wrote %s: %d sites in %s", out_gj, nrow(pts),
                paste(sprintf("%s=%d", names(table(pts$watershed_group)), table(pts$watershed_group)), collapse = ", ")))
print(as.data.frame(st_drop_geometry(pts) %>% count(watershed_group, category)), right = FALSE)

# ---- QML sidecar so QGIS styles the layer on load -----------------------------
# Categorized on `category`, in the shape gq uses for its point layers
# (gq/inst/styles/vector/crossings_pscis_assessment.qml: renderer-v2
# type="categorizedSymbol" over SimpleMarker layers). Generated from the same
# category vector the data carries, so a new category cannot go unstyled.
# Written as data/<region>/report_sites.qml — QGIS loads a .qml sitting beside the
# data file automatically.
cats <- tibble::tribble(
  ~value,                     ~label,                                  ~colour,          ~shape,      ~size, ~outline,
  "barrier_open",             "Barrier — open, assessed",              "202,60,60,255",   "circle",     "3.6", "35,35,35,255",
  "barrier_open_unassessed",  "Barrier — seen in the field, no FPCI",  "202,60,60,255",   "diamond",    "3.6", "35,35,35,255",
  "barrier_needs_sampling",   "Barrier — fish presence unconfirmed",   "255,127,0,255",   "triangle",   "3.6", "35,35,35,255",
  "unassessed_flag",          "Flagged, never assessed",               "152,78,163,255",  "star",       "4.2", "35,35,35,255",
  "barrier_leave",            "Barrier — natural control, leave",      "150,150,150,255", "circle",     "2.6", "80,80,80,255",
  "natural_barrier",          "Natural barrier",                       "90,90,90,255",    "square",     "2.6", "35,35,35,255",
  "remediated",               "Remediated",                            "51,160,44,255",   "circle",     "3.6", "35,35,35,255",
  "passable",                 "Passable",                              "31,120,180,255",  "circle",     "2.8", "35,35,35,255",
  "fish_observation",         "Fish observation",                      "116,196,229,255", "circle",     "2.4", "35,35,35,255"
)
missing_cat <- setdiff(unique(pts$category), cats$value)
stopifnot("a category in the data has no symbol in the QML block" = length(missing_cat) == 0)

marker <- function(name, colour, shape, size, outline) paste0(
'      <symbol alpha="1" clip_to_extent="1" force_rhr="0" frame_rate="10" is_animated="0" name="', name, '" type="marker">\n',
'        <data_defined_properties><Option type="Map"><Option name="name" type="QString" value=""/><Option name="properties"/><Option name="type" type="QString" value="collection"/></Option></data_defined_properties>\n',
'        <layer class="SimpleMarker" enabled="1" locked="0" pass="0">\n',
'          <Option type="Map">\n',
'            <Option name="angle" type="QString" value="0"/>\n',
'            <Option name="cap_style" type="QString" value="square"/>\n',
'            <Option name="color" type="QString" value="', colour, '"/>\n',
'            <Option name="horizontal_anchor_point" type="QString" value="1"/>\n',
'            <Option name="joinstyle" type="QString" value="bevel"/>\n',
'            <Option name="name" type="QString" value="', shape, '"/>\n',
'            <Option name="offset" type="QString" value="0,0"/>\n',
'            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>\n',
'            <Option name="offset_unit" type="QString" value="MM"/>\n',
'            <Option name="outline_color" type="QString" value="', outline, '"/>\n',
'            <Option name="outline_style" type="QString" value="solid"/>\n',
'            <Option name="outline_width" type="QString" value="0.2"/>\n',
'            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>\n',
'            <Option name="outline_width_unit" type="QString" value="MM"/>\n',
'            <Option name="scale_method" type="QString" value="diameter"/>\n',
'            <Option name="size" type="QString" value="', size, '"/>\n',
'            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>\n',
'            <Option name="size_unit" type="QString" value="MM"/>\n',
'            <Option name="vertical_anchor_point" type="QString" value="1"/>\n',
'          </Option>\n',
'          <data_defined_properties><Option type="Map"><Option name="name" type="QString" value=""/><Option name="properties"/><Option name="type" type="QString" value="collection"/></Option></data_defined_properties>\n',
'        </layer>\n      </symbol>\n')

qml <- paste0(
'<!-- Generated by scripts/0106-reports-sites-geojson.R — edit the `cats` block there, not this file. -->\n',
'<qgis labelsEnabled="1" simplifyDrawingHints="0" version="3.34">\n',
'  <renderer-v2 attr="category" enableorderby="0" forceraster="0" referencescale="-1" symbollevels="0" type="categorizedSymbol">\n',
'    <categories>\n',
paste0(sprintf('      <category label="%s" render="true" symbol="%d" type="string" value="%s"/>\n',
               cats$label, seq_len(nrow(cats)) - 1L, cats$value), collapse = ""),
'    </categories>\n    <symbols>\n',
paste0(mapply(marker, as.character(seq_len(nrow(cats)) - 1L), cats$colour, cats$shape, cats$size, cats$outline), collapse = ""),
'    </symbols>\n  </renderer-v2>\n',
# label with the site id; the long `name` and `note` are for the identify panel
'  <labeling type="simple">\n    <settings calloutType="simple">\n',
'      <text-style fieldName="site_id" fontFamily="Helvetica" fontSize="8" fontWeight="50" isExpression="0" textColor="30,30,30,255" textOpacity="1">\n',
'        <text-buffer bufferColor="255,255,255,255" bufferDraw="1" bufferOpacity="1" bufferSize="0.8" bufferSizeUnits="MM"/>\n',
'      </text-style>\n',
'      <placement dist="1" distUnits="MM" placement="6" quadOffset="4"/>\n',
'      <rendering fontMinPixelSize="3" fontMaxPixelSize="10000" scaleMin="0" scaleMax="0" scaleVisibility="0" upsidedownLabels="0"/>\n',
'    </settings>\n  </labeling>\n',
'  <customproperties><Option type="Map">\n',
'    <Option name="dualview/previewExpressions" type="List"><Option type="QString" value="&quot;name&quot;"/></Option>\n',
'  </Option></customproperties>\n',
'</qgis>\n')
qml_path <- file.path("data", region, "report_sites.qml")
writeLines(qml, qml_path)
message("Wrote ", qml_path, ": ", nrow(cats), " categories on `category`")
