# Code-check round 1: branch 244-backlog-move-16-nuseds-spawning-windows (base origin/main 088cd31b)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (A guard that fails toward pass; A fixture that cannot
  reach the failure mode; A proxy is not the property; Zero-length, empty, and unset are three different things;
  A wrapper's exit is not the work; and the rest skimmed for prose, `|` rows skipped). Of the 17 headings under
  "Rules that stand alone", Security and Spreadsheets, none read in full (none touch this diff).
- code-check-r.md: read "`paste()` with a zero-length argument returns length ONE, not zero", "`data.frame()`
  recycles a scalar against a zero-length column", "`bind_rows()` of all-`NULL` is a 0 x 0 tibble...", "`ifelse()`
  with an all-NA test returns a logical vector...", "`download.file(quiet = TRUE)` never tells you the HTTP status",
  "A URL handed to a reader goes through R's 60 s connection timeout", "Postgres row order is never fixed...",
  "Rscript reads a script as it runs..." (8 read; about 121 not read).
- code-check-shell.md: read "Diagnose env/PATH problems in the shell that actually runs, not the ambient one" (its
  `GROUPS` bullet), "Quoting", "A wrapper's exit..." shapes via code-check.md (2 read; about 98 not read).
- code-check-spatial.md: no heading applies (one SQL lookup on fwa_stream_networks_sp by watershed code); 0 read.

## Findings

- **[severity: bug]** data-raw/timing_nuseds.R:54 (and the RUN line at :44, scripts/README.md:494) — the group filter
  is read from an environment variable named `GROUPS`, which bash drops: `GROUPS=BULK,MORR Rscript ...` passes
  nothing, so `want_groups` is empty and the run computes and writes every group. Reproduced on this branch
  (bash): `GROUPS=ADMS SPECIES=CH OUT=... Rscript <copy>` printed "117 group x species keys in 117 groups" and wrote
  767 windows across every group; `GROUPS=ADMS env | grep -c '^GROUPS='` prints 0, `env GROUPS=ADMS ...` and zsh
  pass it. On macOS `/bin/bash` 3.2 a bare `GROUPS=x` also skips the rest of its line. The documented filter works
  only under zsh. This repo already renamed `segment_window_flow.R`'s `GROUPS` to `WSG` for exactly this (#174).
  - **Rule:** code-check-shell.md "Diagnose env/PATH problems in the shell that actually runs, not the ambient one"

- **[severity: bug]** data-raw/timing_nuseds.R:86 with :130-133 — `SPECIES=` filters `x` before the reach-table loop,
  and the loop stops when a named gfe_id is "in no record". gfe_id 2477 (FRASER RIVER - ABOVE TETE JAUNE) holds only
  Chinook (74) and Sockeye (3) records in the published v1 parquet, so every documented `SPECIES=` value but CH and SK
  (CO, PK, CM, ST) stops the run. Reproduced: `SPECIES=CO Rscript <copy>` ->
  `Error: data/nuseds_reach_groups.csv: gfe_id 2477 is in no record`, exit 1. The check meant to catch a stale
  table entry fires on a species filter instead; it needs to test the reach against the unfiltered records (or
  skip entries the filter removed). Each later reach added for #241/#242 widens this.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: bug]** data-raw/timing_nuseds.R:243-264, before :279 — when the GROUPS/SPECIES filter leaves no row of
  `data/life_history_timing.csv` (it holds only BULK, MORR, UFRA and COTR, and no PK or CM rows), `tt` has 0 rows,
  `do.call(rbind, list())` makes `cmp` NULL, and `cmp$largest <- pmax(abs(cmp$d_start), ...)` raises
  `non-numeric argument to mathematical function`. The run dies after printing the windows and before the `OUT=`
  CSV is written, so a filtered run for any of the other ~120 groups never writes its windows file. Reproduced:
  `env GROUPS=ADMS SPECIES=CH OUT=<scratch>/out_adms.csv Rscript <copy>` -> that error, exit 1, no CSV.
  (Masked today under bash by the first finding, since the filter never applies.)
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things" ; code-check-r.md "`data.frame()` recycles a scalar against a zero-length column"

Probes ran a copy of the script from the repo root (read-only; no OUT into the repo; `git status` clean after),
against the published v1 parquet and the fwapg database PG* points to. Checked and found sound: the sha256 gate,
gfe_id (character in the parquet) compared with `as.numeric()` (coerces back to "2477"), no NA gfe_id, the season-year
wrap and `day_str()` round trip, apart/pooled scoping (no pop listed both ways under one group; every apart row's
`groups` contains its group), and the 0340 RUN line's pipefail/cp sequence.
