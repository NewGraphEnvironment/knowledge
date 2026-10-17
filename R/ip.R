#' Controlled vocabularies of the intrinsic-potential model registry
#'
#' The values each controlled column of a registry read by [knw_ip_read()] may
#' take, beyond the `life_stage`, `life_history_form` and `quote_source` it
#' shares with [knw_literature_vocab()]. A registry quote comes from the paper,
#' with its page, so the evidence table's `abstract` fallback is not one of them.
#'
#' `flow_metric` is the variable a model uses to say how big a stream is:
#' mean annual flow, summer low flow, channel width (bankfull or wetted; say
#' which in `note`), drainage area, precipitation, or `none`: the variable the
#' model's thresholds are written on. `flow_source` says how the model obtained
#' it: `gauged` (measured at gauges and assigned to reaches), `modelled`,
#' `field` (measured on the ground), or `unstated`, when the only source is a
#' secondary account that names the metric but not how it was obtained. `flow_inputs` names what a modelled value
#' was built from, as a `;`-separated list: `gauge` records, `drainage_area`,
#' `precipitation`, a `hydrologic_model`, or `field_measurement`s of the
#' variable (field widths regressed on drainage area and precipitation are
#' `field_measurement;drainage_area;precipitation`). `valley_confinement` is the
#' confinement variable a model uses, if any. `validation` is how a model was
#' checked against fish: not at all, fish observations, redd surveys, or
#' densities.
#'
#' @return A named `list` of `character` vectors, one per controlled column.
#' @export
#' @examples
#' knw_ip_vocab()$flow_metric
knw_ip_vocab <- function() {
  list(
    flow_metric = c("mean_annual_flow", "summer_low_flow", "channel_width", "drainage_area",
                    "precipitation", "none"),
    flow_source = c("gauged", "modelled", "field", "unstated"),
    flow_inputs = c("gauge", "drainage_area", "precipitation", "hydrologic_model",
                    "field_measurement"),
    valley_confinement = c("valley_width_index", "none"),
    validation = c("none", "fish_observations", "redd_surveys", "density")
  )
}

#' Read the intrinsic-potential model registry, filtered by species
#'
#' One row per intrinsic-potential (IP) model, species, life stage and
#' life-history form: where the model was built, how it represents flow and
#' valley confinement, and whether it was validated against fish. The registry
#' describes models and holds none of their numbers. A model's thresholds and
#' curve breakpoints are rows of the literature evidence table
#' ([knw_literature_read()]) carrying the same `model_id`, so the variables a
#' model uses are the variables of those rows. `scripts/0280` checks that link
#' both ways on model, species, stage and life-history form.
#'
#' `citation_key`, `page` and `quote` support the flow claim: how the model
#' sizes streams, or, for `flow_metric = none`, the variables it does use.
#' `cited_source` names the original when that quote is a secondary account of
#' the model (Sheer et al. 2009 describing Burnett's, for example).
#' `flow_surrogate` is the metric a model used where its `flow_metric` was not
#' available (modelled width standing in for discharge), and differs from it.
#'
#' A model with a `validation` other than `none` also needs `validation_result`
#' and its own `validation_page`, `validation_quote` and
#' `validation_quote_source`; `validation_citation_key` names the document that
#' quote is in when it is not `citation_key`'s. A model with
#' `validation = none` carries none of them, since an absence cannot be quoted
#' (say what was read in `note`). Likewise `flow_source` is required unless
#' `flow_metric` is `none`; `flow_inputs` is required when the flow is
#' `modelled`; and a `none` flow has no source, inputs or surrogate. A text quote is at
#' least 20 characters. `model_id` is a lower-case identifier that names one
#' `model`, and a model x species x stage x form appears once.
#'
#' The registry is validated before filtering, so a bad row anywhere in the file
#' is an error whichever species is asked for. A requested species absent from
#' the registry is a warning.
#'
#' @param path `character(1)` path to the registry CSV.
#' @param species_code `character` species codes to keep, or `NULL` for all.
#' @return A `tibble` with the twenty-three registry columns, all `character`.
#' @export
#' @examples
#' path <- tempfile(fileext = ".csv")
#' utils::write.csv(data.frame(
#'   model_id = "burnett2007", model = "CLAMS coastal IP", region = "Oregon Coast Range",
#'   species_code = "CO", life_stage = "rearing", life_history_form = NA,
#'   flow_metric = "mean_annual_flow", flow_source = "modelled",
#'   flow_inputs = "gauge;drainage_area;precipitation", flow_surrogate = NA,
#'   valley_confinement = "valley_width_index", validation = "none", validation_result = NA,
#'   citation_key = "key_a", cited_source = NA, page = "4",
#'   quote = "mean annual flow was estimated from drainage area", quote_source = "text",
#'   validation_citation_key = NA, validation_page = NA, validation_quote = NA,
#'   validation_quote_source = NA, note = NA
#' ), path, row.names = FALSE, na = "")
#' knw_ip_read(path, species_code = "CO")
knw_ip_read <- function(path, species_code = NULL) {
  chk::chk_file(path)
  chk::chk_null_or(species_code, vld = chk::vld_character)
  if (!is.null(species_code) && !length(species_code)) {
    stop("an empty filter matches nothing; pass NULL for all", call. = FALSE)
  }
  cols <- c("model_id", "model", "region", "species_code", "life_stage", "life_history_form",
            "flow_metric", "flow_source", "flow_inputs", "flow_surrogate", "valley_confinement",
            "validation", "validation_result", "citation_key", "cited_source", "page", "quote",
            "quote_source", "validation_citation_key", "validation_page", "validation_quote",
            "validation_quote_source", "note")
  x <- .knw_read_csv(path)
  chk::check_names(x, cols)
  x <- .knw_blank_to_na(x[cols])
  x <- .ip_check(x)

  miss <- setdiff(species_code, x$species_code)
  if (length(miss)) {
    warning("species_code not in the registry: ", paste(miss, collapse = ", "), call. = FALSE)
  }
  keep <- if (is.null(species_code)) rep(TRUE, nrow(x)) else x$species_code %in% species_code
  tibble::as_tibble(x[keep, , drop = FALSE])
}

.ip_check <- function(x) {
  first <- function(i) paste0(" (data row ", which(i)[1], ")")
  required <- c("model_id", "model", "region", "species_code", "life_stage", "flow_metric",
                "valley_confinement", "validation", "citation_key", "page", "quote",
                "quote_source")
  for (col in required) {
    if (anyNA(x[[col]])) stop(col, " is blank", first(is.na(x[[col]])), call. = FALSE)
  }
  lit <- knw_literature_vocab()
  lit$quote_source <- setdiff(lit$quote_source, "abstract")   # a registry quote carries a page
  ip <- knw_ip_vocab()
  vocab <- c(ip[c("flow_metric", "flow_source", "valley_confinement", "validation")],
             lit["life_stage"], lit["life_history_form"],
             list(flow_surrogate = setdiff(ip$flow_metric, "none"),
                  quote_source = lit$quote_source, validation_quote_source = lit$quote_source))
  for (col in names(vocab)) {
    v <- x[[col]]
    bad <- !is.na(v) & !v %in% vocab[[col]]
    if (any(bad)) stop(col, " outside its vocabulary: ", v[bad][1], first(bad), call. = FALSE)
  }

  cell <- x$flow_inputs
  cell[is.na(cell)] <- ""
  inputs <- strsplit(cell, ";", fixed = TRUE)
  inputs <- lapply(inputs, function(v) {
    v <- trimws(v)
    v[nzchar(v)]
  })
  # Written back in canonical form, and returned: a cell of separators alone names no
  # input, so it is blank for the checks below and for the caller.
  x$flow_inputs <- vapply(inputs, function(v) if (length(v)) paste(v, collapse = ";") else NA_character_,
                          "")
  bad <- vapply(inputs, function(v) any(!v %in% ip$flow_inputs), TRUE)
  if (any(bad)) {
    v <- inputs[bad][[1]]
    stop("flow_inputs outside its vocabulary: ", v[!v %in% ip$flow_inputs][1], first(bad),
         call. = FALSE)
  }

  bad <- !grepl(.knw_model_id_pattern, x$model_id)
  if (any(bad)) {
    stop("model_id must be a lower-case identifier: ", x$model_id[bad][1], first(bad),
         call. = FALSE)
  }
  n_names <- tapply(x$model, x$model_id, function(v) length(unique(v)))
  if (any(n_names > 1)) {
    stop("model_id ", names(n_names)[n_names > 1][1], " names more than one model", call. = FALSE)
  }
  dup <- duplicated(x[c("model_id", "species_code", "life_stage", "life_history_form")])
  if (any(dup)) {
    stop("duplicate model x species x stage x form: ", x$model_id[dup][1], first(dup),
         call. = FALSE)
  }

  no_flow <- x$flow_metric == "none"
  if (any(!no_flow & is.na(x$flow_source))) {
    stop("flow_source is blank on a row with a flow_metric", first(!no_flow & is.na(x$flow_source)),
         call. = FALSE)
  }
  for (col in c("flow_source", "flow_inputs", "flow_surrogate")) {
    if (any(no_flow & !is.na(x[[col]]))) {
      stop("flow_metric none has no ", col, first(no_flow & !is.na(x[[col]])), call. = FALSE)
    }
  }
  modelled <- x$flow_source %in% "modelled" & is.na(x$flow_inputs)
  if (any(modelled)) stop("flow_inputs is blank on modelled flow", first(modelled), call. = FALSE)
  same <- !is.na(x$flow_surrogate) & x$flow_surrogate == x$flow_metric
  if (any(same)) stop("flow_surrogate repeats the flow_metric", first(same), call. = FALSE)

  claimed <- x$validation != "none"
  for (col in c("validation_result", "validation_page", "validation_quote",
                "validation_quote_source", "validation_citation_key")) {
    if (col != "validation_citation_key" && any(claimed & is.na(x[[col]]))) {
      stop(col, " is blank on a validated model", first(claimed & is.na(x[[col]])), call. = FALSE)
    }
    if (any(!claimed & !is.na(x[[col]]))) {
      stop("validation none carries no ", col, first(!claimed & !is.na(x[[col]])), call. = FALSE)
    }
  }

  for (q in c("quote", "validation_quote")) {
    short <- x[[paste0(q, "_source")]] %in% "text" & nchar(x[[q]]) < 20
    if (any(short)) {
      stop(q, ": a text quote needs at least 20 characters to be checked against its PDF: ",
           x[[q]][short][1], first(short), call. = FALSE)
    }
  }
  invisible(x)
}
