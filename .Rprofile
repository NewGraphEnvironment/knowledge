# R reads one user profile and this one wins over ~/.Rprofile, so source that first: it holds the user's options
# and, on CI, the Posit binary repository r-lib/actions/setup-r writes there; without it every package builds
# from CRAN source (#94).
if (file.exists("~/.Rprofile")) source("~/.Rprofile")

# Evidence-store source for cred::crd_store_connect() / crd_store_push().
# Committed so it travels with the repo; a project .Renviron would replace the user's (CLAUDE.md).
options(cred.store_source = "s3://fresh-bc/rag/")
