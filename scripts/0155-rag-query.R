# scripts/0155-rag-query.R — query the watershed-group ragnar store.
# Usage: WSG_TARGET=pine QUERY="..." Rscript scripts/0155-rag-query.R
suppressMessages({library(ragnar); library(DBI)})
wsg   <- tolower(if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else "pine")
query <- Sys.getenv("QUERY", "recommended remediation for fish passage barrier")
store <- ragnar_store_connect(file.path("data","rag",paste0(wsg,".duckdb")))
res   <- ragnar_retrieve(store, query, top_k = as.integer(Sys.getenv("TOPK","3")))
cat("QUERY:", query, "\n")
for (i in seq_len(nrow(res))) {
  cat("\n--- [", i, "] ", basename(res$origin[i]), " ---\n", sep = "")
  cat(substr(gsub("[ \t\r\n]+", " ", res$text[i]), 1, 480), "\n")
}
DBI::dbDisconnect(store@con)
