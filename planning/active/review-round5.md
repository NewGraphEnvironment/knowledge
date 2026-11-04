# Code-check round 5 (#145)

## Checklist read

- `code-check-python.md`: in full (no Python in this diff).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (all fourteen; `|` rows skipped), with "A proxy is not
  the property", "Zero-length, empty, and unset are three different things", "Restore the bug and prove the guard
  fires" and "A guard that fails toward pass" re-read against the three fixes.
- `code-check-r.md`: "`match()` treats NA as a matchable VALUE", "`summarise()` and `mutate()` evaluate in order",
  "`ifelse()` with an all-NA test returns a logical vector", "`paste()` with a zero-length argument returns length
  ONE", "Postgres row order is never fixed unless the query fixes it", "Inside a dplyr verb, a column named like a
  local variable wins", "testthat counts an uncaught error under `error`, not `failed`". Others not read (no tool,
  shape or pattern in this diff).
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool or shape this diff uses; 0 read.

Scratch runs (copy of HEAD via `git archive`, `PGHOST=invalid.invalid PGSERVICE=`):
- `tests/testthat/test-build_record.R`: 0 failed, 0 errors, 33 passed, 1 skipped.
- Mutation: the fallback suffix disabled (`if (FALSE)`): 1 failed. The new test pins the fix.
- `newest()` on a fresh `git clone` of a two-file repo (`...-published.csv` written first, `...-published-2.csv` one
  second later, both committed): the clone's mtimes are checkout order, `-2.csv` before `.csv`, and `newest()` returns
  `...-published.csv`, the older run.

## Findings

- **[severity: fragile]** data-raw/pick_network_compare.R:30-34 — fix 3 replaces one proxy for "newest" with another.
  The anchor-check csvs are tracked (`git ls-files scripts/logs/habitat` lists all three), and git does not keep
  modification times: a clone, a checkout of another branch and back, or a pull that touches an older file sets mtime
  to when git wrote the file. git writes in index order, and `...-published-2.csv` sorts before `...-published.csv`
  ('-' < '.'), so on any fresh clone the unnumbered first run gets the later mtime and `newest()` picks it over its
  rerun: the exact case round 4 found, now reproduced on every checkout instead of in every working tree. On a
  filesystem with coarse mtimes the files tie and `which.max()` takes the first in `list.files()` order, again the
  first run. Reproduced in the scratchpad (above). The txt still logs the path and md5 read, so the record is honest;
  the default is not "the newest". Order by what the name encodes instead: the `yyyymmdd` prefix, then the numeric
  suffix (none = 1), which is how `.knw_free_path()` assigns them and survives git.
  - **Rule:** code-check.md "A proxy is not the property" (mtime standing in for "the latest run", on files git
    rewrites)

No defect found inside fixes 1 and 2:

- Fix 1 (`coalesce(sum(...) FILTER (...), 0)`): every species x group row the join produces now reaches `wide`; the
  only rows the `> 0` filter still drops are those with no rearing and no spawning on either network (after rounding
  to 0.1 km), which are not habitat. The regenerated log differs from `6e28eaf~1`'s only by added rows: 63 CM and 89
  PK group rows in both halves of the wrapped per-group block, and CM/PK in the province block; every line of steps
  1-4 and every pre-existing row of step 5 is byte-identical (`diff` shows additions only). So no group of the seven
  other species had been dropped. `rear_pct` is NA where `rear_km_full` is 0; `spawn_pct` has no such guard but no
  species has zero full-network spawning, and a zero would print NaN/Inf, not drop a row.
- Fix 2: the suffix fires only when `.knw_build_log_runs()` took the fallback and read at least one run; an empty `log`
  (runs `logical(0)` from `ifelse()` on zero length) gives no suffix and tokens "none", which is correct. No caller
  parses the line past the schema (`minimal_network_check.R` reads `^build: schema ([^,]+),`; `0336` compares fields,
  not the line), so the longer line breaks no reader. The kept branch returns `fallback = FALSE`, and its tests still
  anchor the set-aside note at `$`.

Research section "Is the evidence the same?" against the logs: 45,529 visits and 45,463 at one place (log lines 4-5);
walks and species byte-identical (lines 107-108); access within 1.5 km (ST -1.5, province block); 4,156 pairs, 58
across zero (line 304); rearing +0.52 to +1.75 % for BT CH CO GR ST WCT and -0.11 % SK; spawning -0.01 (GR) to -2.78 %
(SK) for seven, +0.12 % CM and +0.21 % PK, both with 0.0 rearing on both networks. All match.

## Records this diff writes, and whether each channel covers its property (terminal check, re-walked)

| record | states | channel | covers? |
|---|---|---|---|
| `knw_build_record()$run_uid` | the build's run | `log_recompute` string_agg | yes |
| `$tokens` | the build's output vocabulary | `log` rows of kept runs, or every row in the fallback | yes |
| `$log_run_uid` | runs whose `log` rows were read | `lr$runs` | yes (no caller writes it; the line now carries it in the fallback) |
| `$line` set-aside note | runs set aside | `lr$aside` | yes |
| `$line` fallback note (new) | the `log` run the tokens came from, and that it is not `log_recompute`'s | `lr$fallback`, `lr$runs` | yes (tested; mutation fires) |
| `$line` as a whole | which run the tokens describe | `log_recompute` run, plus the set-aside or fallback note | yes (was no in round 4) |
| `.knw_build_log_runs()$fallback` (new) | every row read because no kept run | `TRUE` only in the `!any(kept)` branch | yes |
| refusals in `.knw_build_log_runs()` | "not one build" | as round 4 | yes (NULL `date_start` accepted) |
| 0300 released row SHAs, `log_runs_aside` | the build's SHAs, rows not counted | `lr$where`, `lr$aside` | yes |
| 0300 poll row `run_uid`, refused row, log names | as round 4 | as round 4 | as round 4 (pre-existing / accepted) |
| 0310 ledger `schema_species` | species the run modelled | `log` rows of `rec$log$where` | yes |
| 0310 ledger `build_record` | `rec$line` | as above | yes (was "as finding 2") |
| pick_network_compare txt lines 1-3, commit stamp, counts, tune-table line | as round 4 | as round 4 | yes |
| pick_network_compare csv columns | as round 4 | as round 4 | yes |
| default anchor csv choice | "the newest" | file mtime | **no on any git checkout of the tracked csvs** (finding above) |
| minimal_network_check access province block | province total per species | sum of `ac` rows, NA coalesced | yes |
| minimal_network_check stored province block | province total per species, all modelled species | sum of `wide`, every species x group with any habitat | yes (was no) |
| stored province `rear_pct` NA (new) | no full-network rearing to compare against | `rear_km_full > 0` | yes |
| research "rearing ... six species and 0.1 % shorter for sockeye; spawning ... seven ... chum and pink" | stored km over link's nine modelled species | the province block | yes (was no) |
| research picks, regions, distances | from the compare csv | as round 4 | yes |
| research "accessible km agree within 1.5 km", 45,529 / 45,463, 4,156 / 58 | access and placement | log lines 4-5, 304, access province block | yes |
| CLAUDE.md, scripts/README.md, man sentences on the `log` rows read | the code's behaviour | R/build_record.R (man regenerated with the fallback sentence) | yes |

One row reads "no": the default anchor csv choice, from fix 3. No fix added a record whose channel is narrower than
what it states, apart from that one.

## Disposition (session, 2026-11-04 UTC)

The one finding is fixed: `newest()` orders by the name's `yyyymmdd` prefix, then the day's run number (none = 1),
as `.knw_free_path()` writes them. Tested on files written in run order and in git-checkout order, a later date beside
a `-10` rerun, a non-numeric suffix and an empty directory: all as expected. The real defaults resolve to the same
two inputs and the csv is byte-identical. With it, every row of the re-walked enumeration above reads "yes": the
review ends on that enumeration (a defect was found inside round 4's fix, so a quiet round could not end it).
