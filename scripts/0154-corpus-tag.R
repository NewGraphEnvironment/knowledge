# scripts/04_planning/0154-corpus-tag.R
# ---------------------------------------------------------------------------
# Content-tag the harvested report corpus so themes are findable without farming.
#
# WHY (see #205):
#   The only decision we make per report is a binary farm/skip, taken on a
#   TITLE-keyword regex in the triage step. That is invisible (nothing records
#   what a report contains or why it was skipped) and judges by title rather
#   than content — e.g. EcoCat 53762 "Hydrology and Water Use ..." was skipped as
#   narrative, when it ranks 28 salmon streams by 10 sensitivity indices and
#   flags Beaver Creek's licensed demand as exceeding its 7-day low flow.
#   Farming everything is not the fix (expensive, and most reports yield no
#   priority rows). Knowing what we have is.
#
# WHAT IT DOES:
#   Reads the ragnar store (text is already there — no re-download), scores each
#   document against content signals drawn from table captions, headings and the
#   opening text, and writes a diffable manifest. Cheap: regex over stored text,
#   no LLM pass.
#
# OUTPUT: data/planning/corpus_tags.csv — one row per document:
#   report_id, watershed_group_code, tags, n_table_captions, farmed, n_priority_rows
#   `farmed`/`n_priority_rows` come from priority_farmed_all.csv, so the manifest
#   also answers "which table-dense reports were never farmed?" (the 53762 class).
#
# INPUT: data/rag/<STORE>.duckdb (STORE env, default fraser)
#        data/planning/priority_farmed_all.csv (optional, for the farmed flag)
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(dplyr); library(stringr); library(readr); library(purrr)})

store_name <- if (nzchar(Sys.getenv("STORE"))) Sys.getenv("STORE") else "fraser"
store_path <- file.path("data", "rag", paste0(store_name, ".duckdb"))
stopifnot("store not found" = file.exists(store_path))

con <- dbConnect(duckdb::duckdb(), store_path, read_only = TRUE)
docs <- dbGetQuery(con, "SELECT origin, text FROM documents")
dbDisconnect(con, shutdown = TRUE)

# ---- content signals -> tags ----------------------------------------------
# Matched against table captions + headings + the opening text, NOT the title.
# Deliberately generous: a report can carry several themes and should get all of them.
RULES <- list(
  `crossing-inventory`      = "culvert|stream crossing|fish passage|barrier result|embedment|outlet drop|fish barrier score",
  `habitat-recon`           = "reconnaissance|1:20[ ,.]?000|fish and fish habitat inventory|reach (break|summary)|channel width|wetted width",
  `restoration-prescription`= "deactivat|prescription|cross[- ]ditch|water bar|road rehabilit|work completion",
  `riparian`                = "riparian|riparian vegetation type|\\bRVT\\b|streamside",
  `hydrology`               = "hydrograph|mean annual flow|discharge|water survey of canada|low flow|peak flow|7[- ]day",
  `water-demand`            = "water licen[cs]e|licensed demand|withdrawal|irrigation|water use",
  `sensitivity-ranking`     = "sensitivity ind|sensitive streams|ranking|ranked",
  `fish-sampling`           = "electrofish|minnow trap|gill net|catch per unit|fish collection permit",
  `nfc-evidence`            = "no fish captured|\\bNFC\\b|non[- ]fish[- ]bearing|nil catch|no fish observed",
  `floodplain`              = "floodplain|flood plain|off[- ]channel",
  `terrain-sediment`        = "terrain stability|sediment source|landslide|mass wasting|surface erosion",
  `water-quality`           = "water quality|turbidity|temperature monitoring",
  `planning-priority`       = "priority (rank|list|site|crossing)|high priority|prioriti[sz]"
)

classify <- function(txt) {
  L <- str_trim(str_split(txt, "\n")[[1]]); L <- L[nzchar(L)]
  caps <- grep("^Table\\s+[0-9]+\\s*[.:]?", L, value = TRUE)          # table captions (spacing varies)
  heads <- L[str_detect(L, "^[0-9]+(\\.[0-9]+)*\\s+[A-Z]") | str_detect(L, "^[A-Z][A-Z /&-]{6,60}$")]
  probe <- str_to_lower(paste(c(head(L, 120), caps, head(heads, 60)), collapse = " \n "))
  tags <- names(RULES)[map_lgl(RULES, ~ str_detect(probe, .x))]
  list(tags = paste(tags, collapse = ";"), n_caps = length(caps))
}

res <- map(docs$text, classify)
base <- basename(docs$origin)
m <- str_match(base, "^([A-Za-z]+)__([0-9]+)\\.pdf$")

out <- tibble(
  file = base,
  watershed_group_code = m[, 2],
  report_id = m[, 3],
  n_table_captions = map_int(res, "n_caps"),
  tags = map_chr(res, "tags")
)

# ---- join the farm outcome so "table-dense but never farmed" is visible ----
pf <- file.path("data", "planning", "priority_farmed_all.csv")
if (file.exists(pf)) {
  farmed <- read_csv(pf, show_col_types = FALSE) %>%
    mutate(report_id = as.character(report_id)) %>%
    count(report_id, name = "n_priority_rows")
  out <- out %>% left_join(farmed, by = "report_id") %>%
    mutate(n_priority_rows = coalesce(n_priority_rows, 0L), farmed = n_priority_rows > 0)
} else {
  out <- out %>% mutate(n_priority_rows = NA_integer_, farmed = NA)
}

out <- out %>% arrange(desc(n_table_captions))
write_csv(out, file.path("data", "planning", "corpus_tags.csv"))

message("tagged ", nrow(out), " documents -> data/planning/corpus_tags.csv\n")
message("tag frequency:")
tagfreq <- out$tags %>% str_split(";") %>% unlist() %>% discard(~ .x == "") %>% table() %>% sort(decreasing = TRUE)
print(tagfreq)
message("\ntable-dense (>=5 captions) but NEVER farmed — the 53762 class:")
cand <- out %>% filter(n_table_captions >= 5, !farmed) %>% select(watershed_group_code, report_id, n_table_captions, tags)
print(as.data.frame(head(cand, 25)), row.names = FALSE)
message("\n(", nrow(cand), " such documents)")
