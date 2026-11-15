# The waterbody each of a group's segments lies in, as link's rules name it, with its polygon's area: one row per
# waterbody key the group's segments carry. `water` is river, wetland or lake (a reservoir or other man-made waterbody
# reads as a lake, as link's lake rule does) and `water_ha` the summed area of the waterbody's polygons. The
# comparison's GeoPackage (#81) and the chinook article's popups (#79) read the same thing: a kept stretch with a low
# grade explains itself when it runs through a 59.5 ha wetland. It takes no package function, so a socket worker can run it as given.
.knw_segment_water <- function(conn, schema, wsg) {
  wb <- DBI::dbGetQuery(conn, sprintf("
    SELECT w.waterbody_key, w.waterbody_type,
           coalesce(l.area_ha, wl.area_ha, m.area_ha, r.area_ha) AS water_ha
    FROM whse_basemapping.fwa_waterbodies w
    LEFT JOIN (SELECT waterbody_key, sum(area_ha) area_ha
               FROM whse_basemapping.fwa_lakes_poly GROUP BY 1) l USING (waterbody_key)
    LEFT JOIN (SELECT waterbody_key, sum(area_ha) area_ha
               FROM whse_basemapping.fwa_wetlands_poly GROUP BY 1) wl USING (waterbody_key)
    LEFT JOIN (SELECT waterbody_key, sum(area_ha) area_ha
               FROM whse_basemapping.fwa_manmade_waterbodies_poly GROUP BY 1) m USING (waterbody_key)
    LEFT JOIN (SELECT waterbody_key, sum(area_ha) area_ha
               FROM whse_basemapping.fwa_rivers_poly GROUP BY 1) r USING (waterbody_key)
    WHERE w.waterbody_key IN (SELECT DISTINCT waterbody_key FROM %s.streams
                              WHERE watershed_group_code = '%s' AND waterbody_key IS NOT NULL)
    ORDER BY w.waterbody_key", schema, wsg))
  if (anyDuplicated(wb$waterbody_key)) stop("a waterbody key with two rows in fwa_waterbodies", call. = FALSE)
  wb$waterbody_key <- as.numeric(wb$waterbody_key)
  wb$water <- unname(c(R = "river", W = "wetland", L = "lake", X = "lake")[wb$waterbody_type])
  wb$water_ha <- as.numeric(wb$water_ha)
  wb[, c("waterbody_key", "water", "water_ha")]
}

# Each segment's class under two rules, from its two habitat flags: kept by both, lost (the first only), gained (the
# second only), or neither. `labels` are the four class labels in that order (the registry's, .compare_rule_labels()).
# A missing flag reads as not habitat, and a segment the species cannot reach (`accessible` not TRUE) has no class.
# Base R only, for the same reason as above.
.knw_rule_class <- function(flag_default, flag_tuned, labels, accessible = TRUE) {
  stopifnot(length(labels) == 4L)
  d <- flag_default %in% TRUE
  t <- flag_tuned %in% TRUE
  out <- labels[ifelse(d & t, 1L, ifelse(d, 2L, ifelse(t, 3L, 4L)))]
  out[!(rep_len(accessible, length(out)) %in% TRUE)] <- NA_character_
  out
}
