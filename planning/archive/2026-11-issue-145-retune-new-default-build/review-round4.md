# Code-check round 4 (#145)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (all fourteen; `|` rows skipped). Headings outside
  Mechanisms not read: 21.
- `code-check-r.md`: read "`match()` treats NA as a matchable VALUE", "`summarise()` and `mutate()` evaluate in
  order", "Postgres row order is never fixed unless the query fixes it", "An `information_schema` lookup by the
  literal table name misses what Postgres resolves", "Inside a dplyr verb, a column named like a local variable
  wins", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising", "`tryCatch()` nests its handlers".
  Not read: the other ~110 headings (no tool, shape or pattern in this diff).
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool or shape this diff uses (no shell scripts,
  no spatial calls); 0 read.

Scratch run: `tests/testthat/test-build_record.R` on a copy, `PGHOST=invalid.invalid`: 0 failed, 0 errors, 32 passed,
1 skipped. A reproduction of finding 1 (pivot_wider + filter on explicit NA) ran in the scratchpad.

## Findings

- **[severity: bug]** data-raw/minimal_network_check.R:166-181, and the new province block at :189-193 — the stored
  habitat query returns `sum(...) FILTER (WHERE h.rearing)` (and spawning), which Postgres returns as NULL, not 0,
  for a species x group with no rearing (or no spawning) segment. `pivot_wider(values_fill = 0)` fills only absent
  cells, not explicit NA, so `filter(rear_km_full + rear_km_minimal + spawn_km_full + spawn_km_minimal > 0)` reads NA
  and **drops the row**. Reproduced in the scratchpad: a spawning-only row (rear NA, spawn 5) and a BT group with
  spawning but no rearing both vanish. In the committed log `20261103_minimal_network_check.txt` the access block
  lists nine species (BT CH CM CO GR PK SK ST WCT) but "stored rearing and spawning km, the province" lists seven:
  chum and pink (spawning-only in link; their `cm_spawning`/`pk_spawning` differ at 284 and 356 visits in the same
  log's step 1) are gone, and any group of a listed species with rearing but no spawning, or the reverse, is missing
  from that species' total. The block is titled "the province" and its comment says "the sum of the rows above",
  which is true of the rows and not of the province. research/minimal_network_tuning.md (the "Is the evidence the
  same?" paragraph) quotes it: "spawning is 0.01 to 2.8 % shorter" omits two modelled species, and both ranges rest
  on totals that can omit groups. Fix: `coalesce(sum(...) FILTER (...), 0)` in the SQL (or `replace_na` before the
  filter), rerun step 5, and restate the sentence from the new totals.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things" (a value absent folded into a
    filter that drops it); also code-check.md "Serialization loses meaning silently" (`values_fill` fills the missing
    cell, not the NA value)

- **[severity: fragile]** R/build_record.R:78-82 — `rec$line`, the record every reader writes (0310's ledger
  `build_record` row, 0320's and 0330's logs, `compare_structures_check.R`), names the `log_recompute` run and the
  tokens, and appends a note only when rows were set aside. In the fallback branch (`.knw_build_log_runs()` lines
  117-123: no `log_recompute` run is in `log`, `log` holds one run) the tokens come from a `log` run the line never
  names, so a ledger reads "run X ... tokens T" as if T were X's. The accepted design says the fallback cannot tell a
  proof layout from a log holding only a stale run; this finding is not about telling them apart, but that the
  record does not say the fallback was taken, so the stale-run case (the one the design cannot rule out) reaches
  every ledger looking identical to a normal build. `rec$log_run_uid` carries it, but no caller writes that field
  (grep: no reader of `log_run_uid` outside R/build_record.R). Same mechanism as round 3: the property (which run's
  rows the tokens came from) travels through a channel (the set-aside note) that covers only one of its two branches.
  Fix: in the fallback, append e.g. "; tokens from log run <lab> (log_recompute names <rec>)".
  - **Rule:** code-check.md "A guard that fails toward pass" ("Provenance, and repair"; "Defaults and normalisers": a
    fallback that fires when an input is missing proceeds on a choice no rule made, so print the resolved decision)

- **[severity: fragile]** data-raw/pick_network_compare.R:30-35 — `newest()` defaults PUBLISHED and MINIMAL to "the
  newest" anchor csv by the patterns `_tune_anchor_check-published\.csv$` and `...-minimal-20261103_0838\.csv$`, but
  `tune_anchor_check.R` names a second run of the same UTC day `...-published-2.csv` (`.knw_free_path()`), which the
  pattern cannot match. A same-day rerun is then silently skipped in favour of the first. For MINIMAL the round-3
  md5 guard catches a changed candidate (it stops); for PUBLISHED nothing does, because the published side is never
  looked up (`place()` runs only for `minimal` and `full`). The txt does log the path and md5 read, so the record is
  honest; the header's "the newest" is not. Low risk (the published tables move only by promotion).
  - **Rule:** code-check.md "A proxy is not the property" (a filename pattern standing in for "newest")

## Round-3 fixes (81ff466, 394d19d)

- `place()`'s md5 guard: correct. It short-circuits to NA only when the rule or the other tuning's `tune_md5` is NA,
  which happens only when that tuning has no anchor row for the key (tune_anchor_check.R writes `tune_md5` for every
  table it reads, line 49). Every table actually read is md5-held to the csv that computed the picks; a mismatch
  stops. `published` is never `pr[2]`, so dropping `TUNE_PUBLISHED` from `dirs` loses nothing. Stale only in prose:
  the RUN line (line 23) still lists `[TUNE_PUBLISHED=…]`, which is no longer read (setting it does nothing).
- "each of the seven published picks both scored": the csv has `published_pick_in_{minimal,full}_region` TRUE for
  BT_rear, BT_spawn, CH_rear, CO_rear, GR_rear, ST_rear, WCT_rear and NA for RB_rear: seven, correct.
- The regenerated log: header stamp `at knowledge 81ff466` with no "(uncommitted changes)"; the columns are the old
  ones plus `tune_md5_*`; picks, regions and distances unchanged from a950b3d's run. No defect found inside the fix.

## Records this diff writes, and whether each channel covers its property (terminal check)

| record | states | channel | covers? |
|---|---|---|---|
| `knw_build_record()$run_uid` | the build's run | `log_recompute` string_agg | yes (unchanged) |
| `$tokens` | the build's output vocabulary | `log` rows of kept runs, or all rows in the fallback | yes for the rows read; which rows is stated only by `log_run_uid` |
| `$log_run_uid` | runs whose `log` rows were read | `lr$runs` (fallback: the single `log` run, "(no run id)" if NULL) | yes, but no caller writes it |
| `$line` set-aside note | runs set aside | `lr$aside` | yes |
| `$line` as a whole | which run the tokens describe | names `log_recompute`'s run only | **no in the fallback** (finding 2) |
| refusals in `.knw_build_log_runs()` | "not one build" | two `log` runs with none kept; a set-aside run with `max(date_start) >= min(kept date_start)` | yes for non-NULL dates; NULL `date_start` errors on `if (NA)` (accepted) |
| 0300 released row `log_run_uid`, `link_version`, `link_sha`, `fresh_*`, `fwapg_sha`, `config_hash`, `n_log_rows` | the build's SHAs | `log` rows `lr$where` selects | yes |
| 0300 `log_runs_aside` | rows not counted | `lr$aside`, `""` for none | yes |
| 0300 `run_uid` (poll row) | the run | `max(run_uid)` of `log_recompute`, with `n_runs` beside it | pre-existing; two runs show only in `n_runs`, and 0310's `knw_build_record(run_uid=)` then refuses |
| 0300 refused row `status = refused`, `note` | "a log the record cannot attribute to one build" | any error from `shas()`, `note` = its message | status word is broader than the header's meaning (a database drop at release also reads `refused`); the note carries the real cause, and the outcome (no release, exit 3, `_refused` name) is right. Not a finding |
| 0300 log name `-<tag>` / `_refused` | which build, and that it did not release | `SETTLE_TAG`/schema; `_refused` suffix | yes: 0310's default pattern `_link_settle\.csv$` matches neither, and a `SETTLE=` refused log fails 0310's `status == released` gate |
| 0310 ledger `schema_species` | species the run modelled | `log` rows of `rec$log$where` | yes |
| 0310 ledger `build_record` | `rec$line` | as above | as finding 2 |
| pick_network_compare txt lines 1-3 | each anchor csv, its md5, its link run | path, `md5sum`, unique `run_uid` | yes |
| txt "at knowledge <sha>(uncommitted changes)" | the code the numbers came from | `git status --porcelain -- R data-raw/pick_network_compare.R` (untracked included) | yes |
| txt "Minimal against new full …: N of M keys tuned on both" | count over keys both scored | `!is.na(network_moved)` | yes |
| txt "New full against published …: N of M keys" | same, for the other pair | `!is.na(build_moved)` | yes (wording omits "tuned on both"; count is right) |
| txt "tune tables (<nm>): <dir>, each the table its anchor csv read" | identity of every table read | md5 stop in `place()` | yes |
| csv `rule_recommended_*`, `*_ddev_*`, `*_se_*`, `rule_best_*`, `rec_moved_parts_*`, `run_uid_*`, `evidence_md5_*`, `tune_md5_*`, `status_*`, `n_visits_*` | each tuning's numbers | copied from the anchor csv | yes |
| csv `network_moved`, `build_moved` | parts two picks differ in | positional split of three-part rules; NA when either missing; stops on a non-three-part rule | yes |
| csv `*_pick_in_*_region`, `*_pick_behind_*_best` | the pick in the other tuning's region, distance | md5-verified `<key>_tune.csv`, `in_region`, `ddev_best`, `se_diff`; "not in grid" when absent | yes |
| default anchor csv choice | "the newest" | filename pattern | **no for a same-day rerun** (finding 3) |
| minimal_network_check "access km per species, access > 0, the province" | province total per species | sum of `ac` rows, NA coalesced to 0 | yes |
| minimal_network_check "stored rearing and spawning km, the province" | province total per species | sum of `wide`, which drops every species x group with a NULL rearing or spawning sum | **no** (finding 1) |
| research "spawning is 0.01 to 2.8 % shorter"; "six species … and sockeye" | stored km over link's modelled species | the province block above | **no** (finding 1: chum and pink missing) |
| research "four of seven picks", "three outside", "each of the seven published picks both scored … both regions", the per-key distances | from the compare csv | checked against `20261104_pick_network_compare.csv` | yes |
| research "accessible km agree within 1.5 km" | province access | access block (ST −1.5) | yes |
| CLAUDE.md, scripts/README.md, man sentences on the `log` rows read and `SETTLE_TAG` | the code's behaviour | R/build_record.R, 0300 | yes |
