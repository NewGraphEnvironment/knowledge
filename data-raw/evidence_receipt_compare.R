# data-raw/evidence_receipt_compare.R
# ---------------------------------------------------------------------------
# Compare two evidence builds' receipts (#160): crate's verdict on the receipts alone and with both builds' tables
# re-read (the verdict to take, since crate rounds a value to its tolerance's decimals), each table's bytes, the largest
# move in access_check's km, and a grade receipt written against the first build, which must name its recipe_id.
#
# INPUT:  two evidence directories, each with the tables scripts/0310 writes and its evidence_receipt.json; the first
#         build's ledger, which its receipt names
# OUTPUT: printed; #160's run is scripts/logs/habitat/evidence_receipt_160/20261106_evidence_receipt_compare.txt
# RUN:    Rscript data-raw/evidence_receipt_compare.R <evidence dir a> <evidence dir b>   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages(pkgload::load_all(quiet = TRUE))
args <- commandArgs(trailingOnly = TRUE)
a <- args[1]; b <- args[2]
keys <- knw_receipt_keys("evidence")
f <- function(d) stats::setNames(file.path(d, paste0(keys$tables, ".csv")), keys$tables)
ra <- crate::crt_receipt_read(file.path(a, "evidence_receipt.json"))
rb <- crate::crt_receipt_read(file.path(b, "evidence_receipt.json"))
cat("recipe a", ra$recipe$recipe_id, "\nrecipe b", rb$recipe$recipe_id, "\n")
cat("same recipe:", identical(ra$recipe$recipe_id, rb$recipe$recipe_id), "\n")
t0 <- Sys.time()
cmp_r <- crate::crt_receipt_compare(ra, rb, keys = keys)
cat("receipts alone:", cmp_r$verdict, "\n")
ta <- .knw_receipt_csv_tables(f(a), keys); tb <- .knw_receipt_csv_tables(f(b), keys)
cmp <- crate::crt_receipt_compare(ra, rb, keys = keys, tables = list(a = ta, b = tb))
cat("tables re-read:", cmp$verdict, "(mode", cmp$mode, ")", format(round(difftime(Sys.time(), t0, units = "mins"), 1)), "\n")
print(as.data.frame(cmp$differences), right = FALSE)
# per table: byte match, and the largest km move in access_check
for (tb_n in keys$tables) {
  cat(sprintf("%-22s bytes %s\n", tb_n, identical(unname(tools::md5sum(f(a)[tb_n])), unname(tools::md5sum(f(b)[tb_n])))))
}
km <- merge(ta$access_check, tb$access_check, by = setdiff(names(ta$access_check), "km"))
cat("access_check rows", nrow(ta$access_check), "matched", nrow(km), "max |km diff|", max(abs(km$km.x - km$km.y)), "\n")
cat("summary a:", unlist(ra$result$summary), " b:", unlist(rb$result$summary), "\n")

# a grade receipt against build a: a fixture grade table and record written with a's evidence md5s and ledger
d <- tempfile(); dir.create(d)
ev_md5 <- paste(unname(tools::md5sum(file.path(a, paste0(c("visits_link", "visits_species", "walks"), ".csv")))),
                collapse = ";")
led <- ra$context$run$ledger
grades <- data.frame(id_segment = 1:3, length_metre = c(120, 300, 80), grade = c(0.1, 0.5, NA))
g <- file.path(d, "CH_rear_grades.csv")
utils::write.csv(cbind(grades, species_code = "CH", stage = "rear", rule = "r1", run_uid = ra$context$run$run_uid,
                       ref_population = "stream_branch", ref_edge = "1000", q_walk = 3, walk = "bank",
                       walk_md5 = knw_walk_md5(), discharge_load = "wet load", curve_prior_sd = 2.5,
                       grade_withheld = FALSE, null_heldout_curve = 1.5, evidence_md5 = ev_md5,
                       curve_grad = "segment_gradient"), g, row.names = FALSE)
knw_grade_record_write(g, tune_run = "fixture", evidence_ledger = led, knowledge_commit = NA,
                       link = c(version = "0.78.2", sha = strrep("b", 40)),
                       tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 3)
spec <- list(fit = "gam", prior_sd = 2.5, seed = 54L, folds = 5L, d_floor = 200, extra = TRUE, grad = "segment_gradient")
gr <- knw_grade_receipt_write(g, grades, spec, min_wsg = 5L, evidence_dir = a, knowledge = .knw_git_state())
cat("grade evidence input:", unlist(gr$recipe$inputs$evidence), "\n")
cat("names build a's recipe:", identical(gr$recipe$inputs$evidence$recipe_id, ra$recipe$recipe_id), "\n")
