# The README figure: chinook rearing in the Bulkley under link's `default` rule and the tuned rule,
# the whole-group panel of the chinook rearing article's map, from the same bundled data.
# Run from the repo root after data-raw/vignette_chinook.R; writes man/figures/readme-bulk.png.

pkgload::load_all()

vd <- function(f) file.path("inst", "vignette-data", f)
seg <- readRDS(vd("bulk_segments.rds"))
water <- readRDS(vd("bulk_water.rds"))

# knw_compare_map() falls back to a plain fill without gq; the README map is styled through gq's registry
stopifnot(requireNamespace("gq", quietly = TRUE), !is.null(gq::gq_reg_main()$layers$lake))

out <- "man/figures/readme-bulk.png"
knw_compare_map(seg, water, png = out, panels = "rules")

px <- png::readPNG(out)
# the website can show the figure on a dark background, where transparency does not survive
stopifnot(dim(px)[3] == 3 || all(px[, , 4] == 1))
message("README figure -> ", out, " (", dim(px)[2], " x ", dim(px)[1], " px)")
