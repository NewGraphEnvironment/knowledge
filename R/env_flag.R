# A script's on/off setting from the environment, read one way everywhere: unset or empty takes `default`, TRUE or
# FALSE (any case) or 1 or 0 set it, and anything else stops, so a misspelt value is never read as either.
.knw_env_flag <- function(name, default = FALSE) {
  v <- Sys.getenv(name, "")
  if (!nzchar(v)) return(default)
  u <- toupper(v)
  if (u %in% c("TRUE", "1")) return(TRUE)
  if (u %in% c("FALSE", "0")) return(FALSE)
  stop(name, " must be TRUE or FALSE (or unset), not '", v, "'", call. = FALSE)
}
