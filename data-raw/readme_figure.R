# The README figure: chinook rearing in the Bulkley under link's `default` rule and the tuned rule,
# the whole-group panel of the chinook rearing article's map, from the same bundled data, placed for a reader who has
# never seen the area (#77): a keymap of British Columbia, a scale bar, the towns and rivers named, and Esri's World
# Topographic Map blended with its World Shaded Relief underneath, credited on the map (Al, 2026-11-13: Esri with its
# attribution drawn, and no NOTICE row). No logo: the README already carries the package's hex sticker.
# Run from the repo root after data-raw/vignette_chinook.R and data-raw/vignette_context.R; writes
# man/figures/readme-bulk.png. Needs network for the tiles.

pkgload::load_all()
sf::sf_use_s2(FALSE)

vd <- function(f) file.path("inst", "vignette-data", f)
seg <- readRDS(vd("bulk_segments.rds"))
water <- readRDS(vd("bulk_water.rds"))
ctx <- readRDS(vd("bulk_context.rds"))
map_group <- readRDS(vd("chinook_rearing.rds"))$meta$map_group
# the context bundle was written for the article's group (data-raw/vignette_context.R)
stopifnot(identical(ctx$meta$map_group, map_group))

# knw_compare_map() falls back to a plain fill without gq; the README map is styled through gq's registry
stopifnot(requireNamespace("gq", quietly = TRUE), !is.null(gq::gq_reg_main()$layers$lake),
          !is.null(gq::gq_tmap_style(gq::gq_reg_main()$layers$lake)))

# the basemap over the window knw_compare_map() draws: the group's outline padded 2 km, tiles warped to BC Albers
window <- sf::st_bbox(sf::st_buffer(sf::st_as_sfc(sf::st_bbox(ctx$aoi)), 2000))
topo <- gq::gq_basemap_tiles(window, provider = "Esri.WorldTopoMap", zoom = 10, crs = 3005)
relief <- gq::gq_basemap_tiles(window, provider = "Esri.WorldShadedRelief", zoom = 10, crs = 3005)
if (is.null(topo) || is.null(relief)) stop("the Esri tiles did not arrive: the README figure needs network")
basemap <- gq::gq_basemap_blend(topo, relief, method = "gamma", gamma = 1)
stopifnot(nzchar(attr(basemap, "credit")))

out <- "man/figures/readme-bulk.png"
# 5 in at 150 dpi (750 px), shown at 70 % of the README column (about 600 px). Each element sits where the group is not: the legend over Babine
# Lake to the north-east, the keymap to the south-west, the scale bar in the north-west corner beyond the group's edge
knw_compare_map(seg, water, png = out, panels = "rules", width = 5, scalebar = TRUE,
                keymap = list(aoi = ctx$aoi, context = ctx$bc), places = list(towns = ctx$towns, rivers = ctx$rivers),
                basemap = basemap,
                corners = c(legend = "topright", scalebar = "topleft", keymap = "bottomleft", logo = "bottomright"))

px <- png::readPNG(out)
# the website can show the figure on a dark background, where transparency does not survive
stopifnot(dim(px)[3] == 3 || all(px[, , 4] == 1))
message("README figure -> ", out, " (", dim(px)[2], " x ", dim(px)[1], " px)")
