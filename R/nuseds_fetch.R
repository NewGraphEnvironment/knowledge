#' Fetch a release of DFO's NuSEDS All Areas file
#'
#' NuSEDS (Fisheries and Oceans Canada's New Salmon Escapement Database System)
#' is published on the Open Government Portal as `All Areas NuSEDS_<YYYYMMDD>.zip`,
#' one CSV of every salmon population, stream, species and year, under the Open
#' Government Licence - Canada. This finds the release through the portal's CKAN
#' API (`ckanr`), downloads it once to `<dir>/<YYYYMMDD>/`, and returns where it
#' is with its md5.
#'
#' A release already held is never downloaded again or overwritten: a later
#' release is a new directory, so a run names the input it read. Asked for the
#' latest, the function takes the newest release the record lists. The download
#' is refused unless it is a zip holding exactly one CSV, the shape
#' [knw_nuseds_records()] reads through crate.
#'
#' @param dir `character(1)` the directory releases are kept under.
#' @param release `character(1)` a release date as `YYYYMMDD`, or `NULL` for the
#'   newest the record lists.
#' @param dataset `character(1)` the portal's dataset id for NuSEDS.
#' @param url `character(1)` the CKAN site.
#' @return A list: `path` (the zip), `release` (`YYYYMMDD`), `md5`, `url` (where
#'   it came from, `NA` when the release was already held) and `downloaded`
#'   (`TRUE` when this call fetched it).
#' @export
#' @examples
#' \dontrun{
#' x <- knw_nuseds_fetch()
#' x$release
#' }
knw_nuseds_fetch <- function(dir = "data/nuseds", release = NULL,
                             dataset = "c48669a3-045b-400d-b730-48aafe8c5ee6",
                             url = "https://open.canada.ca/data/en") {
  chk::chk_string(dir)
  chk::chk_null_or(release, vld = chk::vld_string)
  chk::chk_string(dataset)
  chk::chk_string(url)
  if (!is.null(release) && !grepl("^[0-9]{8}$", release)) {
    stop("release must be a date written YYYYMMDD", call. = FALSE)
  }
  file_of <- function(rel) file.path(dir, rel, paste0("nuseds_all_areas_", rel, ".zip"))

  if (!is.null(release) && file.exists(file_of(release))) {
    return(.knw_nuseds_held(file_of(release), release))
  }
  res <- .knw_nuseds_resources(dataset, url)
  rel <- sub("^All Areas NuSEDS_([0-9]{8})\\.zip$", "\\1", res$name)
  ok <- grepl("^All Areas NuSEDS_[0-9]{8}\\.zip$", res$name)
  if (!any(ok)) stop("the NuSEDS record lists no All Areas NuSEDS_<YYYYMMDD>.zip", call. = FALSE)
  res <- res[ok, , drop = FALSE]
  rel <- rel[ok]
  pick <- if (is.null(release)) which.max(as.integer(rel)) else match(release, rel)
  if (is.na(pick)) {
    stop("release ", release, " is not on the NuSEDS record (it lists ", paste(sort(rel), collapse = ", "), ")",
         call. = FALSE)
  }
  release <- rel[[pick]]
  dest <- file_of(release)
  if (file.exists(dest)) return(.knw_nuseds_held(dest, release))

  tmp <- tempfile(fileext = ".zip")
  on.exit(unlink(tmp), add = TRUE)
  .knw_nuseds_download(res$url[[pick]], tmp)
  inside <- tryCatch(utils::unzip(tmp, list = TRUE)$Name, error = function(e) {
    stop("the download of release ", release, " is not a zip", call. = FALSE)
  })
  if (length(inside) != 1L || !grepl("\\.csv$", inside, ignore.case = TRUE)) {
    stop("release ", release, " holds ", length(inside), " file(s) (", paste(inside, collapse = ", "),
         "), not one CSV", call. = FALSE)
  }
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(tmp, dest)) stop("could not write ", dest, call. = FALSE)
  list(path = dest, release = release, md5 = unname(tools::md5sum(dest)), url = res$url[[pick]],
       downloaded = TRUE)
}

.knw_nuseds_held <- function(path, release) {
  list(path = path, release = release, md5 = unname(tools::md5sum(path)), url = NA_character_, downloaded = FALSE)
}

# the record's resources, name and url, through the CKAN API
.knw_nuseds_resources <- function(dataset, url) {
  if (!requireNamespace("ckanr", quietly = TRUE)) stop("install ckanr to fetch NuSEDS", call. = FALSE)
  p <- ckanr::package_show(dataset, url = url, as = "list")
  r <- p$resources
  field <- function(x, f) if (is.null(x[[f]])) NA_character_ else as.character(x[[f]])
  data.frame(name = vapply(r, field, character(1), f = "name"), url = vapply(r, field, character(1), f = "url"),
             stringsAsFactors = FALSE)
}

# one download to `dest`, refusing anything but HTTP 200
.knw_nuseds_download <- function(src, dest) {
  if (!requireNamespace("curl", quietly = TRUE)) stop("install curl to fetch NuSEDS", call. = FALSE)
  h <- curl::new_handle(followlocation = TRUE)
  r <- curl::curl_fetch_disk(src, dest, handle = h)
  if (r$status_code != 200L) stop("NuSEDS download returned HTTP ", r$status_code, ": ", src, call. = FALSE)
  invisible(dest)
}
