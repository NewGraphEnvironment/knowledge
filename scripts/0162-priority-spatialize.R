# scripts/0162-priority-spatialize.R
# ---------------------------------------------------------------------------
# Spatialize the reconciled priority table (0161 -> priority_farmed_all.csv)
# into ONE field layer: data/rag_priorities.gpkg, layer `rag_priorities`.
#
# WHY ONE LAYER + watershed_group_code (not 9 layers):
#   0161 now stamps the TRUE watershed_group_code per row (multi-WSG reports like
#   Hooft 50797 distribute to BOWR/TABR/WILL). A single layer with a
#   watershed_group_code column is what the field wants — load once, symbolize by
#   priority, filter/label by WSG. Per-group layers + per-group clipping is what
#   dropped Hooft's Willow sites in the first place.
#
# GEOMETRY per row, in order:
#   1. pscis_lon/pscis_lat   (WGS84, from the reconciled PSCIS crossing)
#   2. the report's printed `coords`  (parsed UTM zone 9/10/11 N -> WGS84)
#   Rows with neither are dropped (reported) — mostly reach summaries with no point.
# CLIP: drop points outside the UNION of the 9 Fraser polys (far strays, e.g. the
#   off-region 14725 "Salmon FSR" report). Union, not per-group, so WILL-stamped
#   points are kept.
# All farmed columns (incl. notes) travel into the gpkg so it is self-sufficient
# in the field.
#
# INPUT:  data/priority_farmed_all.csv (0161), live DB :63333 for polys
# OUTPUT: data/rag_priorities.gpkg (layer rag_priorities) + .kml
# ---------------------------------------------------------------------------
suppressMessages({library(sf); library(dplyr); library(stringr); library(readr); library(purrr); library(DBI); library(RPostgres)})
sf_use_s2(FALSE)
FRASER <- c("BOWR","MCGR","COTR","WILL","UFRA","TABR","FRAN","LCHL","NECR")

f <- file.path("data", "priority_farmed_all.csv")
stopifnot("run 0161 first" = file.exists(f))
d <- read_csv(f, show_col_types = FALSE) %>% mutate(.row = row_number())
num <- function(x) suppressWarnings(as.numeric(x))

# ---- parse a report `coords` string -> c(easting, northing, zone) ----
parse_utm <- function(s) {
  s <- as.character(s)
  m <- str_match(s, "GIS UTM\\s*(\\d{1,2})\\.(\\d{5,7})\\.(\\d{6,7})")
  if (is.na(m[1])) m <- str_match(s, "Field UTM\\s*(\\d{1,2})\\.(\\d{5,7})\\.(\\d{6,7})")
  if (!is.na(m[1])) return(c(num(m[3]), num(m[4]), num(m[2])))
  m <- str_match(s, "\\b(\\d{5,7})\\s+(\\d{6,7})\\b(?:\\s*(\\d{1,2}))?")
  if (!is.na(m[1])) { z <- num(m[4]); return(c(num(m[2]), num(m[3]), ifelse(is.na(z), 10, z))) }
  c(NA_real_, NA_real_, NA_real_)
}

# ---- 1) PSCIS-sourced points ----
d <- d %>% mutate(plon = num(pscis_lon), plat = num(pscis_lat))
pscis_pts <- d %>% filter(!is.na(plon) & !is.na(plat)) %>% mutate(coord_source = "pscis", lon = plon, lat = plat)

# ---- 2) report-UTM for the rest ----
rest <- d %>% filter(is.na(plon) | is.na(plat))
utm <- map(rest$coords, parse_utm)
rest <- rest %>% mutate(e = map_dbl(utm,1), n = map_dbl(utm,2), z = map_dbl(utm,3)) %>% filter(!is.na(e) & !is.na(n))
utm_pts <- if (nrow(rest)) map_dfr(split(rest, rest$z), function(g) {
  z <- g$z[1]; if (is.na(z) || !z %in% 7:11) z <- 10
  s <- st_as_sf(g, coords = c("e","n"), crs = 32600 + z, remove = FALSE) %>% st_transform(4326)
  xy <- st_coordinates(s); g %>% mutate(coord_source = "report-utm", lon = xy[,1], lat = xy[,2])
}) else NULL

# ---- normalize the report's priority wording -> priority_rank ----
# The farmed tables mix "standouts the report flagged for follow-up" with the full
# ranked inventory and with habitat/reach rows that carry no priority at all.
# rag_priorities must hold ONLY the standouts; everything else goes to rag_sites_all.
#   1 = top   (high, high-known-fish, priority 1, follow-up-priority-1)
#   2 = mid   (moderate/medium, follow-up-priority-2, follow-up-required)
#   3 = low ranked | 4 = explicitly ruled out (no-fix, removed, not-assessed)
#   NA = no priority stated (habitat reaches, plain inventories)
# ---- is this row a FISH-PASSAGE CROSSING priority? --------------------------
# "Priority" means different things per report type: a "high priority" row can be
# a road-deactivation prescription, a riparian-restoration reach, or a sediment
# hazard — none of which are fish-passage crossing standouts. rag_priorities keeps
# only the crossing domain; everything else stays queryable in rag_sites_all via
# table_source.
is_crossing_domain <- function(ts) {
  x <- str_to_lower(as.character(ts %||% ""))
  excl <- str_detect(x, "habitat-inventory|habitat-assessment|riparian|hazard|deactivation-prescription|fish-sampling|^restoration$|^habitat")
  incl <- str_detect(x, "crossing|passage|barrier|priority-summary|priority-narrative|priority-rank")
  !excl & incl
}
`%||%` <- function(a,b) if (is.null(a)) b else a

rank_priority <- function(p) {
  x <- str_trim(str_to_lower(as.character(p)))
  dplyr::case_when(
    x == "" | is.na(x)                                       ~ NA_integer_,
    str_detect(x, "no.?fix|removed|not.?assessed|no impact") ~ 4L,
    str_detect(x, "^l\\b|^low|\\(deactivation\\)")           ~ 3L,
    str_detect(x, "high|priority 1|follow-up-priority-1")    ~ 1L,
    str_detect(x, "moder|medium|^m\\b|follow-up")            ~ 2L,
    str_detect(x, "fish-bearing|unclassified")               ~ NA_integer_,
    TRUE                                                     ~ NA_integer_)
}

# ---- 3) stream-snap: rows with no coords but a named stream --------------------
# Some reports flag a standout by STREAM NAME with no UTM ("Sovereign Cr. - high").
# Snap those to a point ON that named stream within the same watershed group
# (whse_basemapping.fwa_named_streams = one geometry per named stream per group).
# APPROXIMATE BY CONSTRUCTION -> coord_source records it so the field user can tell
# these from surveyed coordinates:
#   stream-snap        = the named stream itself
#   stream-snap-parent = report said "Trib. of X"; we could only place it on X
snap_name <- function(s) {
  x <- str_to_lower(as.character(s))
  parent <- str_detect(x, "trib\\.?(utary)?\\s+(of|to)\\s+")
  x <- str_remove(x, "^.*?trib\\.?(utary)?\\s+(of|to)\\s+")
  x <- str_replace_all(x, "\\b(crk|ck|cr)\\b\\.?", "creek")
  num <- c("one"="1","two"="2","three"="3","four"="4","five"="5","six"="6","seven"="7","eight"="8","nine"="9","ten"="10",
           "eleven"="11","twelve"="12","thirteen"="13","fourteen"="14","fifteen"="15","sixteen"="16","seventeen"="17",
           "eighteen"="18","nineteen"="19","twenty"="20")
  for (w in names(num)) x <- str_replace(x, paste0("^", num[[w]], "\\b"), w)   # "18 mile" -> "eighteen mile"
  x <- str_squish(str_remove_all(x, "[^a-z0-9 ]"))
  list(name = str_to_title(x), parent = parent)
}

rest2 <- d %>% filter(is.na(plon) | is.na(plat)) %>%
  filter(!.row %in% (if (!is.null(utm_pts)) utm_pts$.row else integer())) %>%
  filter(!is.na(stream_name) & str_squish(stream_name) != "" & !str_detect(str_to_lower(stream_name), "^unnamed$"))
snap_pts <- NULL
if (nrow(rest2)) {
  sn <- map(rest2$stream_name, snap_name)
  rest2 <- rest2 %>% mutate(snap_nm = map_chr(sn, "name"), snap_parent = map_lgl(sn, "parent"))
  cn <- tryCatch(dbConnect(RPostgres::Postgres(), host="localhost", port=5432, dbname="fwapg", user="postgres", password="postgres"), error=function(e) NULL)
  if (is.null(cn)) cn <- tryCatch(dbConnect(RPostgres::Postgres(), host="localhost", port=63333, dbname="bcfishpass", user="newgraph"), error=function(e) NULL)
  if (!is.null(cn)) {
    look <- rest2 %>% distinct(watershed_group_code, snap_nm) %>% filter(!is.na(snap_nm) & snap_nm != "")
    pairs <- paste(sprintf("(lower('%s'),'%s')", gsub("'","''",look$snap_nm), look$watershed_group_code), collapse=",")
    fwa <- tryCatch(dbGetQuery(cn, sprintf("
      SELECT gnis_name, watershed_group_code,
             ST_X(ST_Transform(ST_LineInterpolatePoint(ST_GeometryN(ST_LineMerge(geom),1),0.5),4326)) lon,
             ST_Y(ST_Transform(ST_LineInterpolatePoint(ST_GeometryN(ST_LineMerge(geom),1),0.5),4326)) lat
      FROM whse_basemapping.fwa_named_streams
      WHERE (lower(gnis_name), watershed_group_code) IN (%s)", pairs)), error=function(e){message("  snap query: ", conditionMessage(e)); NULL})
    dbDisconnect(cn)
    if (!is.null(fwa) && nrow(fwa)) {
      key <- paste(str_to_lower(fwa$gnis_name), fwa$watershed_group_code)
      m <- match(paste(str_to_lower(rest2$snap_nm), rest2$watershed_group_code), key)
      snap_pts <- rest2 %>% mutate(lon = fwa$lon[m], lat = fwa$lat[m]) %>% filter(!is.na(lon)) %>%
        mutate(coord_source = ifelse(snap_parent, "stream-snap-parent", "stream-snap"))
      message(sprintf("stream-snap: placed %d of %d coordinate-less named-stream rows", nrow(snap_pts), nrow(rest2)))
    }
  } else message("(no DB — skipping stream-snap)")
}

keep_cols <- c("watershed_group_code","code","report_id","table_source","report_crossing_id","pscis_crossing_id",
  "stream_name","priority","barrier","fish_barrier_score","habitat_value","coords","upstream_fish",
  "recommendation","notes","reconcile_method","pscis_stream_crossing_id","pscis_barrier_result",
  "pscis_habitat_value","pscis_has_confirmation","coord_source","priority_rank","lon","lat")
pscis_pts <- pscis_pts %>% mutate(priority_rank = rank_priority(priority))
if (!is.null(utm_pts))  utm_pts  <- utm_pts  %>% mutate(priority_rank = rank_priority(priority))
if (!is.null(snap_pts)) snap_pts <- snap_pts %>% mutate(priority_rank = rank_priority(priority))
placed <- bind_rows(pscis_pts[, intersect(keep_cols, names(pscis_pts))],
                    if (!is.null(utm_pts))  utm_pts[,  intersect(keep_cols, names(utm_pts))],
                    if (!is.null(snap_pts)) snap_pts[, intersect(keep_cols, names(snap_pts))])
n_unplaced <- nrow(d) - nrow(placed)
g <- st_as_sf(placed, coords = c("lon","lat"), crs = 4326)

# ---- clip to the UNION of the Fraser polys (drop far off-region strays) ----
# remote tunnel (bcfishpass:63333), else local fresh-db (fwapg:5432) — both carry
# whse_basemapping.fwa_watershed_groups_poly.
conn <- tryCatch(dbConnect(RPostgres::Postgres(), host="localhost", port=63333, dbname="bcfishpass", user="newgraph"), error=function(e) NULL)
if (is.null(conn)) conn <- tryCatch(dbConnect(RPostgres::Postgres(), host="localhost", port=5432, dbname="fwapg", user="postgres", password="postgres"), error=function(e) NULL)
if (!is.null(conn)) {
  poly <- st_read(conn, query = sprintf(
    "SELECT ST_Union(geom) geom FROM whse_basemapping.fwa_watershed_groups_poly WHERE watershed_group_code IN (%s)",
    paste(sprintf("'%s'", FRASER), collapse=",")), quiet=TRUE) %>% st_transform(4326)
  dbDisconnect(conn)
  inside <- lengths(st_intersects(g, st_buffer(poly, 0.012))) > 0
  message(sprintf("dropped %d point(s) outside the Fraser watershed-group union", sum(!inside)))
  g <- g[inside, ]
} else message("(no DB — skipping union clip)")

gpkg <- file.path("data", "rag_priorities.gpkg")
# standouts = report-flagged (rank 1-2) AND in the fish-passage crossing domain
stand <- g[!is.na(g$priority_rank) & g$priority_rank <= 2 & is_crossing_domain(g$table_source), ]
st_write(stand, gpkg, layer = "rag_priorities", delete_dsn = TRUE, quiet = TRUE)
st_write(g,     gpkg, layer = "rag_sites_all",  delete_layer = TRUE, quiet = TRUE)  # everything placed
st_write(stand, file.path("data", "rag_priorities.kml"), delete_dsn = TRUE, quiet = TRUE)

message(sprintf("\n== rag_priorities (STANDOUTS): %d points | rag_sites_all: %d | unplaced rows: %d ==",
                nrow(stand), nrow(g), n_unplaced))
message("standouts by watershed group:")
print(as.data.frame(st_drop_geometry(stand) %>% count(watershed_group_code, sort=TRUE)), row.names = FALSE)
message("standouts by rank (1=high, 2=moderate):")
print(as.data.frame(st_drop_geometry(stand) %>% count(priority_rank, priority)), row.names = FALSE)
message("all-sites layer by rank (NA = no priority stated, 3=low, 4=ruled out):")
print(as.data.frame(st_drop_geometry(g) %>% count(priority_rank)), row.names = FALSE)
