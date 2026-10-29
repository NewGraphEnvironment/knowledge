# R reads one user profile and this one wins over ~/.Rprofile, so source that first: it holds the user's options
# and, on CI, the Posit binary repository r-lib/actions/setup-r writes there; without it every package builds
# from CRAN source (#94).
# The option stops a loop where ~/.Rprofile is this file (HOME at the checkout, a symlink or a hard link). It is an
# option, not an environment variable, so child R processes (callr, pak) still read ~/.Rprofile.
if (is.null(getOption("knowledge.home_rprofile")) && file.exists("~/.Rprofile")) {
  options(knowledge.home_rprofile = TRUE)
  source("~/.Rprofile")
}

# Evidence-store source for cred::crd_store_connect() / crd_store_push().
# Committed so it travels with the repo; a project .Renviron would replace the user's (CLAUDE.md).
options(cred.store_source = "s3://fresh-bc/rag/")
