# data-raw/database_receipts.R
# ---------------------------------------------------------------------------
# Run crate's receipt comparison over #158's outputs and check its verdicts against the ones recorded by hand
# (data-raw/database_compare.R), which tests crate's comparison on cases whose answers are known (#158, #154,
# NewGraphEnvironment/crate#43).
#
# For each output this writes two receipts with crt_receipt_write(), one for the published run's copy and one for the
# second database's, into a scratch directory, and compares them with crt_receipt_compare(), handing it both tables so
# it re-reads their cells. Each receipt states its own run's recipe truthfully: the published run's code was knowledge
# 2aacd1f and this run's is the branch's base commit, so crate answers `different` on the recipe for every output, as its
# rules require. The check is on the result: crate's result-side differences other than a part's bytes give a result
# verdict (none: identical; all `within` their tolerance: equivalent; any `refuse`: different), checked against the hand
# verdict. One difference of definition is expected: crate fingerprints a double rounded to its tolerance, so cells that
# differ by less than the rounding are identical to crate where the hand comparison, which requires exact equality for
# `identical`, calls them equivalent.
#
# What the hand comparison set aside is set aside here too, so the two judge the same cells: the columns the current
# code adds (#120's segment_fwa_gradient) and each table's context columns are dropped from both sides before the
# fingerprint. The hand tolerances map to crate's, which must be powers of ten: 0 is exact (no tolerance), 0.005 m (a
# distance stored to the centimetre) is 1e-2, and 1e-6 and 1e-9 are themselves, on every double column of the table.
#
# INPUT:  VERDICTS, the hand-verdict CSVs (default every scripts/logs/habitat/database_second/*_database_compare-*.csv
#         but -walks and -receipts); for each row, the reference and new files named in PAIRS below
# OUTPUT: OUT (default scripts/logs/habitat/database_second/<date>_database_compare-receipts.csv): one row per output:
#         output, hand_verdict, crate_verdict, crate_mode, crate_result_verdict, agree, crate_bytes_match, recipe_fields,
#         result_fields (the result fields other than a part's bytes, which are the hand comparison's bytes_match)
# RUN:    Rscript data-raw/database_receipts.R   (from the repo root; crate >= 0.12.0)
# ---------------------------------------------------------------------------
suppressMessages({ library(data.table) })
options(warn = 1)
source("data-raw/database_compare.R")  # spec_for(), read_tbl(), self_test()
self_test()
if (utils::packageVersion("crate") < "0.12.0") stop("crate >= 0.12.0 is needed (crt_receipt_compare())")

dir_log <- "scripts/logs/habitat/database_second"
verdict_files <- if (nzchar(Sys.getenv("VERDICTS"))) strsplit(Sys.getenv("VERDICTS"), ",")[[1]] else
  setdiff(list.files(dir_log, "_database_compare-.*\\.csv$", full.names = TRUE),
          list.files(dir_log, "_database_compare-(walks|receipts)\\.csv$", full.names = TRUE))
dest <- Sys.getenv("OUT", file.path(dir_log, sprintf("%s_database_compare-receipts.csv",
                                                      format(Sys.time(), "%Y%m%d", tz = "UTC"))))
# where each label's two copies live: reference directory, new directory
run <- Sys.getenv("RUN", "20261106_0423")
dirs <- list(
  evidence       = c("data/fdis/derived", "data/fdis/derived_second"),
  tune           = c("data/tune", file.path("data/tune/candidate", run)),
  tune_control   = c("data/tune", file.path("data/tune/candidate", Sys.getenv("RUN_CONTROL", "none"))),
  compare        = c("data/compare", file.path("data/compare/candidate", run))
)
git_sha <- function(ref) system2("git", c("rev-parse", ref), stdout = TRUE)
code_ref <- list(knowledge = list(commit = git_sha("2aacd1f"), version = "0.4.29", dirty = FALSE))
code_new <- list(knowledge = list(commit = git_sha(Sys.getenv("CODE_SHA", "4060cb2")),
                                  version = as.character(utils::packageVersion("knowledge")), dirty = FALSE))
inputs <- list(link_build = list(version_id = "20261103_163715-269b585a"),
               flow_load = list(version_id = "wet b4bbc50, discharge/fwa/v1 built 2026-10-24T12:23:01Z"))

crate_tol <- function(tol) if (tol == 0) NULL else 10^ceiling(log10(tol))

one <- function(label, output, hand) {
  d <- dirs[[label]]
  if (is.null(d)) return(NULL)
  ref_path <- file.path(d[1], output); new_path <- file.path(d[2], output)
  if (!file.exists(ref_path) || !file.exists(new_path)) return(NULL)
  s <- spec_for(output)
  a <- read_tbl(ref_path); b <- read_tbl(new_path)
  # crate fingerprints a Date but refuses data.table's IDate, its subclass (reported to crate): plain Dates here
  for (x in list(a, b)) for (cn in names(x)) if (inherits(x[[cn]], "IDate")) data.table::set(x, j = cn, value = as.Date(x[[cn]]))
  drop <- union(s$context, s$added)
  a <- a[, setdiff(names(a), drop), with = FALSE]; b <- b[, setdiff(names(b), drop), with = FALSE]
  tol <- crate_tol(s$tol)
  dbl <- function(x) names(x)[vapply(x, is.double, logical(1))]
  tl <- if (is.null(tol)) list() else stats::setNames(as.list(rep(tol, length(union(dbl(a), dbl(b))))), union(dbl(a), dbl(b)))
  tname <- sub("\\.csv$", "", output)
  wd <- file.path(tempdir(), "receipts", label, tname)
  write_one <- function(side, x, code) {
    dd <- file.path(wd, side); dir.create(dd, recursive = TRUE, showWarnings = FALSE)
    fwrite(x, file.path(dd, output), na = "NA")
    crate::crt_receipt_write(dd, output = list(name = tname, scope = label),
      recipe = list(code = code, config = list(settings = list(schema = I("fresh_default"))), inputs = inputs, seed = NULL),
      result = list(tables = stats::setNames(list(as.data.frame(x)), tname), parts = stats::setNames(output, tname),
                    summary = list(rows = nrow(x)),
                    tolerance = list(tables = stats::setNames(list(tl), tname))),
      publish = TRUE)
    file.path(dd, "receipt.json")
  }
  ra <- write_one("ref", a, code_ref); rb <- write_one("new", b, code_new)
  cmp <- crate::crt_receipt_compare(ra, rb, tables = list(a = stats::setNames(list(as.data.frame(a)), tname),
                                                          b = stats::setNames(list(as.data.frame(b)), tname)))
  dif <- as.data.table(cmp$differences)
  # a part's bytes are the hand comparison's bytes_match, not a value: the result verdict reads every other result field
  parts <- dif[side == "result" & grepl("^result\\.parts", field)]
  res <- dif[side == "result" & !grepl("^result\\.parts", field)]
  result_verdict <- if (!nrow(res)) "identical" else if (all(res$action %in% c("within", "record", "warn"))) "equivalent" else "different"
  data.table(label = label, output = output, hand_verdict = hand, crate_verdict = cmp$verdict, crate_mode = cmp$mode,
             crate_result_verdict = result_verdict, agree = result_verdict == hand,
             crate_bytes_match = !nrow(parts),
             recipe_fields = paste(unique(dif[side == "recipe"]$field), collapse = ";"),
             result_fields = paste(sprintf("%s=%s", res$field, res$action), collapse = ";"))
}

hand <- rbindlist(lapply(verdict_files, fread, na.strings = "NA"), fill = TRUE)
hand <- hand[grepl("\\.csv$", output) & !grepl("ledger", output)]
out <- rbindlist(lapply(seq_len(nrow(hand)), function(i) {
  r <- tryCatch(one(hand$label[i], hand$output[i], hand$verdict[i]),
                error = function(e) data.table(label = hand$label[i], output = hand$output[i], hand_verdict = hand$verdict[i],
                                               crate_verdict = "error", crate_mode = NA, crate_result_verdict = NA,
                                               agree = FALSE, recipe_fields = "", result_fields = conditionMessage(e)))
  if (!is.null(r)) cat(sprintf("%-10s %-32s hand %-10s crate %-9s (%s) result %-10s agree %s %s\n", r$label, r$output,
                               r$hand_verdict, r$crate_verdict, r$crate_mode, r$crate_result_verdict, r$agree,
                               substr(r$result_fields, 1, 120)))
  r
}), fill = TRUE)
fwrite(out, dest, na = "NA")
cat(sprintf("%d outputs, %d agree. Written to %s\n", nrow(out), sum(out$agree %in% TRUE), dest))
