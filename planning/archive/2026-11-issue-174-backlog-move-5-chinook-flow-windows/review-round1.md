# Code-check round 1: branch `174-backlog-move-5-chinook-flow-windows-and` (knowledge) and crate `nuseds-schema`

## Checklist read

- code-check-python.md: in full (it does not apply: the diff has no Python).
- code-check-r.md, by heading, 9 read: "A database driver's value is not a base R type — and it fails twice";
  "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are"; "`system2(stdout = TRUE)`
  warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires"; "A `data-raw/` script
  must load the source tree, not the installed package"; "Postgres row order is never fixed unless the query fixes it,
  so a pick, a float sum and a presence check can each depend on it"; "A fetcher's test helper must make the network
  fail, not just mock the reader"; "A `function(...)` mock hides arguments the real callee no longer accepts";
  "`download.file(quiet = TRUE)` never tells you the HTTP status — read it from `curl`"; plus the index lines of the
  rest. Not read in full: about 150 headings, none naming a tool or shape this diff uses beyond the index line.
- code-check-shell.md: 0 headings read in full (the diff holds no shell script; its one `aws s3 cp` and `git` calls
  go through R's `system2()`, covered by the R heading above). Not read: all.
- code-check-spatial.md: 1 read ("A name is not a key: `GNIS_NAME` matches features all over BC", for
  timing_nuseds.R's placement of the Fraser mainstem by DFO's reach name). Not read: the rest (no terra/sf/GDAL in
  the diff).
- code-check.md: every H3 under `## Mechanisms`, prose only, table rows skipped. "Rules that stand alone",
  "Security" and "Spreadsheets and PDFs": index lines only.

## Verified, no finding

- chinook_window_flow.R's verdict implements the stop rule at d6eff92f exactly: `main` is the three `basis ==
  "monthly"` rows (the daily-check rows carry other labels), and `any(flips >= 0.05 * 4858 | ch_flips >= 0.05 * 234)`
  is "243 or more, or 12 or more" for any one reading, judged on totals. The stop-rule section is byte-identical
  between d6eff92f and HEAD.
- knw_rule_in() reuse: the rule columns are the five it checks; `exc_q = "win"` gives key `"pick|win"`, which the
  added index entry supplies (`pt` over every visit, `dist` Inf where no ladder river qualifies, `lake`/`reg` FALSE,
  matching the defaults the MAD reading reproduced 1,400 / 197 with); `cols_win` swaps only `mad`.
- Every number in research/chinook_window_flow.md checked against data/tune/flow_window/*.csv, both logs and the
  ignored parquet: flips and shares, LFRA 119 / 138 of 646, 162 over 30 groups with FRAN 21 at most, 16 chinook over
  11 groups at 2 at most, 14 groups under 0.5 and 9 over 1, the five lowest and highest, 0.59 / 1.04 / 0.44 / 3.11 /
  997, daily 106 flips and 4 apart; segment counts per group, 2,020,158 rows, 75 % within 5 %, and every median
  (absolute) and p90 gap and twofold share in the chinook gap table.
- The four timing rows' numbers match scripts/logs/timing/20261118_timing_nuseds.txt; both new literature rows parse
  through knw_literature_read() and are `verified_text` in the 0280 log; knw_timing_read() accepts the table.
- NuSEDS 20260601 typed by the new schema: no filled count or integer cell becomes NA (every double/integer column
  checked on the release zip), max act_id 2,146,955,744 (kept as a string). test-nuseds.R (7 tests),
  test-link_flow.R and test-receipt.R pass from a detached worktree.
- crate's all-character read against its other two `file` registrations: the fish_data and bcfp fixtures type as
  before (`date` arrives as ISO text the day parser already accepts); the `"1,208"` -> NA change is crate#41's
  acknowledged second half.
- No home path, host or private repo in any added tracked line.

## Findings

- **[severity: bug]** data-raw/chinook_window_flow.R:107 — `seg$src_lfid <- as.numeric(ifelse(!is.na(seg$own_mad),
  seg$linear_feature_id, seg$parent_lfid))`. `parent_lfid` is `p.linear_feature_id`, a `bigint`, which RPostgres
  returns as `integer64` (the new test-link_flow.R lines already `as.numeric()` it for that reason), while
  `t.linear_feature_id` is the double column the temp table was written from. Base `ifelse()` copies the `no`
  values' raw bits into a plain double, so every visit whose flow comes from a parent gets an lfid like
  `1.76e-315` (measured: `ifelse(c(TRUE, FALSE), c(701747495, 701747496), bit64::as.integer64(c(NA, 356385867)))`
  gives `7.017475e+08 1.760780e-315`). That id formats to `0` in the `ANY($1::bigint[])` query, gets no monthly
  rows, and the `n_mon != 13` check cannot see a segment with zero rows, so `win_rear` is NA, the visit fails the
  stream test and is counted as a flip; the MAD-equality check still passes because it reads `parent_mad`, a double.
  This run is unaffected (the log reads "flow from a parent segment: 0 visits"), but the design notes say the script
  handles parents, and Phase 2's population (or another key's) need not have none. Fix: `as.numeric()` each operand
  before the `ifelse()`, and make the 13-month check cover every requested lfid (`setdiff(lfids, names(n_mon))`
  empty).
  - **Rule:** code-check-r.md "A database driver's value is not a base R type — and it fails twice" ; code-check.md "A fixture that cannot reach the failure mode"

- **[severity: fragile]** crate R/crt_ingest.R:136-144 with inst/extdata/schemas/dfo/nuseds_all_areas.yaml
  (`encoding: latin1`) — the variant is chosen from the header alone, then the file is read in that variant's
  encoding, and the UTF-8 check runs only when the variant declares UTF-8. A later NuSEDS release with the same 51
  columns written in UTF-8 (the case decisions/dfo/20261117_nuseds_all_areas.md gives as the reason the encoding sits
  on the variant) matches the `latin1` variant and is decoded as Latin-1 with no refusal. Measured with the installed
  branch crate: the fixture re-encoded to UTF-8 ingests and returns `local_name_1` = `"FRANÃ\u0087OIS LAKE"`.
  knowledge's 0340 would publish it (the Maxan Creek check holds no accented name). The decision text claims a
  protection the code gives only in the other direction. A cheap guard: on a non-UTF-8 variant, refuse when the raw
  bytes are themselves valid UTF-8 and contain multibyte sequences (a Latin-1 file almost never does).
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/chinook_window_flow.R:45-48 and data/tune/flow_window/ch_rear_run.csv — the run
  record names `head = d6eff92f`, but that commit holds neither the script (`git cat-file -e
  d6eff92f:data-raw/chinook_window_flow.R` fails) nor the `parent_lfid` column it reads from
  `.knw_link_flow_sql()`; both were committed afterwards in 57075184 (the log's start, 02:16Z, precedes that
  commit). The script refuses only an uncommitted rule file, so the tracked record's commit cannot reproduce the run
  it describes. The script is unchanged between 57075184 and HEAD, so the numbers stand; the record does not say
  which code made them. Fix: refuse a dirty tree for the script and `R/` as well as the rule file (as
  data-raw/vignette_method.R does), or record 57075184 and rerun.
  - **Rule:** code-check.md "A proxy is not the property"
