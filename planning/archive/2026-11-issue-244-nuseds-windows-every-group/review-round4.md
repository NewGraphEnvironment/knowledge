# Code-check round 4 (enumeration): branch 244-backlog-move-16-nuseds-spawning-windows (base origin/main 088cd31b, head f6127b62)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped); stand-alone
  rules not read (none names a shape the diff uses beyond the Mechanisms prose).
- code-check-r.md: by heading only, rechecked against HEAD code: "`paste()` with a zero-length argument returns length
  ONE, not zero" (the `named reaches` line), "`ifelse()` with an all-NA test returns a logical vector, whatever `yes`
  and `no` are", "`match()` treats NA as a matchable VALUE, so two unknowns join to each other". About 125 not read.
- code-check-shell.md: by heading only: "Quoting", "`a && b || c` runs `c` when any step before the `||` fails",
  "Diagnose env/PATH problems in the shell that actually runs, not the ambient one". About 97 not read.
- code-check-spatial.md: index only; no heading applies (one exact-match SQL lookup, no geometry).

## Probes (outputs only under the scratchpad `cc/r4/`; the repo untouched apart from this file)

- Fetched the published `knowledge/nuseds/v1/nuseds_records.parquet` over HTTPS and counted dated records sharing a
  population-year: six species, every record: 28 records of 3 populations (46582, 46602, 47925); records with an FWA
  watershed code: 16 (two populations, as round 3 measured after the Atlas filter too).
- Read the tracked `scripts/logs/timing/20261121_timing_nuseds_windows.csv`: 6,112 rows; 1,119 distinct
  (wsg_code, species_code, scope); 6,112 distinct (wsg_code, species_code, scope, run_type, pop_id).
- `strsplit("", ",")[[1]]` is `character(0)`; `getconf DARWIN_USER_TEMP_DIR` is `/var/folders/<2>/<id>/T/`.
- Issue numbers the diff cites (#96, #230, #240, #241, #242, #244) resolve to titles about this work.
- The three tracked revisions of `20261121_timing_nuseds.txt` print OUT as `scripts/logs/timing/...` (twice) and, at
  HEAD, `/tmp/20261121_timing_nuseds_windows.csv` (this agent shell has no TMPDIR).

## Enumeration

### A. Environment inputs (12)

1. `WSG` — read L61 (`env_list`: split on `,`, trim, upper, drop empty); validated L194-196 (any member with no key for
   the species asked stops, naming it). Unset or only commas/spaces: no filter (a full run: OUT allowed, checks
   enforced). Lower case: folded. Typo in any member: stop. Space-separated list: one unknown member, stop. **Sound.**
2. `SPECIES` — read L62; validated L66-68 against the six codes before any network or database work. Empty: no
   filter. Unknown: stop. **Sound.**
3. `VERSION` — read L63, default `v1` only when unset; `VERSION=` (empty) builds `.../nuseds//manifest.json`, which
   fails at L80 with the HTTP status (loud). An unpublished version: S3 answers 403/404, stop at L80. A published
   version with other records: the L255-257 checks stop a full run. **Sound.**
4. `OUT` — read L64; refused with a filter at L70-72 (before any fetch); empty: no CSV; an unwritable path fails at
   L260 with non-zero exit after the windows print, before the comparison. Written verbatim into the console at L261
   (see C10 and Finding 3). **Sound as a guard.**
5. `PG*` / `PGSERVICE` (libpq, L128) — not validated; an unreachable server errors, a database without
   `whse_basemapping.fwa_stream_networks_sp` errors at L129. A different FWA load would move groups; the full run's
   three checks are the only control. **Sound.**
6. `PGCONNECT_TIMEOUT` — not set by any RUN line; an unreachable server hangs rather than fails (CLAUDE.md "Database
   access"). Every script here shares this; not this diff's. **Sound (pre-existing convention).**
7. Working directory — `pkgload::load_all()`, `data/nuseds_reach_groups.csv` (L141) and `data/life_history_timing.csv`
   (L265) are relative; RUN says "(repo root)". From elsewhere `load_all` fails first. **Sound.**
8. `TMPDIR` (script RUN L44, 0340 RUN L24) — `${TMPDIR:-/tmp}`; macOS's trailing `/` gives `T//`, harmless. The
   value reaches the tracked log through the printed OUT path (Finding 3). **Defect (Finding 3).**
9. `d`, `t` (script RUN L44) — shell variables, not exported; the `( … )` subshell inherits them. Unquoted `${t}`:
   breaks only on a TMPDIR holding spaces (macOS's has none; 0340's sibling quotes `"$L"`). **Sound.**
10. `L` (0340 RUN L24) — quoted; `<yyyymmdd>` is a template placeholder, as before this diff. **Sound.**
11. `RELEASE` (0340 RUN) — read 0340 L37 (`nzchar` else newest). Unchanged code. **Sound.**
12. `PUBLISH` (0340 RUN) — read 0340 L35 (`identical(…, "TRUE")`); anything else is a no-publish run. Unchanged code.
    (0340 also reads `REPUBLISH` and `VERSION`, which no RUN line in the diff documents; code unchanged.) **Sound.**

### B. stop() and early quit/return (13 stop() + 1 quit + 1 early return = 15)

1. L67 SPECIES outside the six — tests the typed list against the fixed set its message names. Every mode. **Sound.**
2. L71 OUT with a filter — tests `filtered` (non-empty WSG or SPECIES after `env_list`) and `nzchar(out)`; message
   matches; before any fetch. **Sound.**
3. L80 HTTP status != 200 — per object fetched; message names the URL and status. **Sound.**
4. L85 manifest lists `nuseds_records` != 1 time — `man$files` NULL also gives 0 and stops. **Sound.**
5. L89 sha256 not the manifest's — the Parquet as downloaded. **Sound.**
6. L113 dates not in format — the full set of start/end/arrival dates of the six species with an FWA code (before the
   SPECIES filter), and the timing rows' `start`/`end` in `mmdd` at the comparison (filtered rows only, which is the
   set compared). Records with no FWA code are not parsed (they are dropped at L102 and never used). **Sound.**
7. L144 reach gfe_id in no record — set: records of the six species with an FWA code the Atlas holds, every species
   (the filter moved after it in round 1). "in no record" means in no placeable record, the right set for placement.
   Every mode sees the same set. **Sound.**
8. L146 reach name differs — same set. **Sound.**
9. L151 reach's code does not cross its group — `crossed` from the same set; every gfe_id has one code (round 3).
   **Sound.**
10. L195 WSG member with no key — keys built after the SPECIES filter, and the message says "for the species asked".
    Reached only when WSG is given. **Sound.**
11. L200 no keys — after L195 it is reachable only with WSG unset and SPECIES naming a species with no dated record;
    message matches. **Sound.**
12. L248 a full run has no group window for UFRA/COTR/BULK CH — `!filtered` only; windows are per group x species and
    do not depend on which other groups are in the run, so a filtered run that includes the key checks the same
    numbers. **Sound.**
13. L251 window differs — compares start/end medians and n_start/n_end (`as.integer` of a character vector).
    **Sound.**
14. L270 `quit(status = 0)` when the filtered timing table is empty — reachable only in a filtered run (the full table
    is non-empty), which cannot have written OUT; message names "the groups and species asked". **Sound.**
15. L247 early return "check skipped" — only `filtered && no group window`; a full run cannot reach it. **Sound.**

### C. Outputs (16 printed items; the window table's 18 columns and the CSV's 20)

1. L93-94 release, commit, path, sha256, "`nrow(x)` rows" — rows read from the Parquet, every species. **Sound.**
2. L100-101 "N dated records of M populations; K dated records carry no FWA watershed code" — the six species,
   every group, before the SPECIES filter (accepted in round 2: printed only). **Sound.**
3. L136-137 "dated records carry a watershed code the Atlas does not hold" — same population, after L102. **Sound.**
4. L157 "named reaches" — the reach table; an empty table would print a phantom ` -> ` (zero-length `paste`), but an
   empty table fails the UFRA check (pop 44549 on gfe 2477 is in #96's UFRA window), so a full run cannot print it.
   **Sound.**
5. L201 "N group x species keys in M groups" — the keys after the filters. **Sound.**
6. L239 per key "P populations pooled, A apart (on a stream crossing several groups)" — P = populations with a dated
   record in the group; A = populations with a dated apart record whose code crosses the group; apart is `wsg` NA,
   which only a multi-group code gives. **Sound.**
7. L241 window table, columns: `scope`, `run_type` (group row: runs of all records; run_type rows: runs of dated
   records — a label, round 3), `pop_id`, `waterbody`, `groups` (codes' groups; for the reach-placed pop 44549 the 14
   Fraser groups, though pooled in UFRA alone — what the column means), `records` (all records, dated or not, of the
   row's set), `n_start`/`n_end`/`n_arrival` (records with that date; header now says records), `first_year`/
   `last_year` (dated records only), `start_*`/`end_*`/`arrival_median` (type-7 quantiles over records, rounded, on the
   season year, `day_str` maps day 367 to 01-01 correctly). **Sound.**
8. L247 "check skipped: w sp not in this run". **Sound.**
9. L253 "check: w sp start to end as published" — also checked n_start/n_end; the line names only the window.
   **Sound.**
10. L261 "wrote N windows to OUT" — N = all rows of every scope; OUT printed verbatim (Finding 3).
    **Defect (Finding 3).**
11. L269 "nothing to compare" — filtered only. **Sound.**
12. L294 "(days: NuSEDS minus the row; pooled group windows)" — d_* = group window minus row; only `scope == group`
    read. **Sound.**
13. L296 comparison table: `wsg_code`…`source` (the row), `start_nuseds` (spawning: group median start; migration:
    "arrival <median>", "arrival NA" when the group has no arrival — cosmetic), `end_nuseds` (spawning: median end;
    migration: day before median start), `d_start`, `d_end`, `compared`. Sorted by `largest`, descending. **Sound.**
14. L301 "row: apart populations in <wsg>" — for each compared row. **Sound.**
15. L302 apart table — apart rows of the group x species. **Sound.**
16. L305-306 "rows not compared" — rows whose differences are all NA, by verdict. **Sound.**
17. CSV (L260): `wsg_code`, `species_code` + the 18 columns of C7, same values; `na = ""`. The header (L42-43) and the
    timing logs README call it "one row per group x species x scope": the file has 6,112 rows over 1,119 group x
    species x scope combinations. **Defect (Finding 1).**

### D. Documented command lines (9)

1. Script RUN L44-46, full run — `pipefail` inside the subshell makes the subshell's status Rscript's; any stop
   (sha256, reach, check, OUT write, comparison) skips `cp`; success requires OUT written, so both files copied are
   this run's. **Sound.**
2. Same line with a filter prefixed before `Rscript` (or exported) — stops at L71 before any fetch; `cp` skipped; the
   day's tracked logs untouched (tee writes only the `$TMPDIR` copy). **Sound.**
3. Script L49 `WSG=BULK,MORR SPECIES=CH Rscript …` — prints only; text ("refuses OUT, and a group with no dated
   record") matches L70-72 and L194-196. **Sound.**
4. Script L52 `VERSION=v1 before Rscript` — default `v1`. **Sound.**
5. 0340 RUN L24-25 — quoted `"$L"`, `pipefail`, `&& cp`; a stop skips the copy. The claim "a tracked log in
   scripts/logs/ would be a change the clean-tree check refuses" matches 0340 L50 (`--untracked-files=no`, PUBLISH
   only): a same-day tracked log truncated by tee is a tracked change. **Sound.**
6. 0340 `RELEASE=20260601 before Rscript`. **Sound.**
7. 0340 `PUBLISH=TRUE before Rscript` — inside the subshell; the copy lands after the upload. **Sound.**
8. scripts/README.md 0340 entry ("tee'd to $TMPDIR and copied in after a run that succeeded … the clean-tree check
   refuses") — the refusal is PUBLISH-only, which the entry's previous sentence states. **Sound.**
9. scripts/README.md timing entry and scripts/logs/timing/README.md — names, flags and paths match the code; the
   logs README's "one row per group x species x scope" is Finding 1; its "from 2026-11-21" matches the first CSV
   (UTC-dated `20261121`). **Defect only through Finding 1.**

### E. Numbered or quantified claims (19)

1. Header L3 "every watershed group and species with dated spawner records" — every group reachable from a record
   whose code the Atlas holds; the 554 + 1,017 unplaceable dated records are printed. **Sound.**
2. L5 / scripts/README "writes no row" — writes only OUT. **Sound.**
3. L8-10 refuses a Parquet whose sha256 is not the manifest's; release, sha256 and commit printed first. **Sound.**
4. L11-12 "a population whose code lies in one group pools into that group's window" — per record, which agrees for
   every dated population (round 3). **Sound.**
5. L14-15 / CLAUDE.md / both READMEs: multi-group code → apart under each group "unless" the reach table names it.
   **Sound.**
6. L16-17 refuses an entry whose name is not the reach's or whose group the code does not cross — L145, L150 (and a
   gfe_id in no record, L144). **Sound.**
7. L17-18 a named reach belongs to its group alone, not apart elsewhere — L154 sets `wsg`, so not in `apart_x`.
   **Sound.**
8. L21-22 start/end fields and "only the month and day are read". **Sound.**
9. L23-24 median and 10th/90th percentiles over dated records (n_start, n_end). **Sound.**
10. L24-26 "a record is one population, stream (gfe_id) and year" (CLAUDE.md's NuSEDS sentence) and "(16 dated records
    of two populations in the 2026-06-01 release)" — 16 of two holds for records with a watershed code, the set n is
    computed over; over the release it is 28 of three. **Defect (Finding 2).**
11. L26-27 season year from 1 April, 1 September for ST; a January end counts after December. **Sound.**
12. L27-29 each population's window and run type; a window per run type where a group holds more than one (dated
    runs). **Sound.**
13. L29-30 arrival printed for migration rows. **Sound.**
14. L31-35 "every row of the timing table" set beside its group's window; "every difference is printed, largest
    first". **Sound.**
15. L36-37 / scripts/README "stops unless it reproduces" UFRA, COTR and BULK CH — true of every full run (L248); a
    filtered run skips with a printed line and cannot write OUT or reach the copy. **Sound (scoped by the RUN text).**
16. L42-43 "one row per group x species x scope" — **Defect (Finding 1).**
17. L47-48 "Only a full run takes OUT, so only it reaches the copy." **Sound.**
18. NOTICE: the windows go to `scripts/logs/timing/` (`*_timing_nuseds.txt`, `*_timing_nuseds_windows.csv`); the
    reach table names reaches by gfe_id and name. **Sound.**
19. 0340 RUN "a refused run's log never replaces the day's tracked one" — `pipefail` + `&&`. **Sound.**

## Findings

- **[severity: fragile]** data-raw/timing_nuseds.R:42-43 and scripts/logs/timing/README.md:12 — Both describe the
  windows CSV as "one row per group x species x scope (group, run_type, population, apart)". The tracked
  `20261121_timing_nuseds_windows.csv` has 6,112 rows and only 1,119 distinct (wsg_code, species_code, scope); its
  key is group x species x scope x run_type x pop_id (6,112 distinct), since run_type, population and apart scopes
  each hold one row per run type or population. A reader who takes the stated grain and joins on group, species and
  scope multiplies rows. Not inside an earlier round's fix (from 749f8cfd / d015364c).
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (claims naming a population: "count, member
    list … universal quantifier")

- **[severity: fragile]** data-raw/timing_nuseds.R:24-26 — "(16 dated records of two populations in the 2026-06-01
  release)" scopes the count to the release. Measured on the published v1 Parquet: over the release's six species, 28
  dated records of three populations (46582, 46602, 47925) share a population-year; 16 of two is the count over
  records with an FWA watershed code, which is the set n is computed over. The number is right for n and wrong for
  the population the sentence names. Inside an earlier round's fix: **yes** (round 2's 3ea72860 added it).
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/timing_nuseds.R:261 with the RUN line L44-46 — The script prints `out` verbatim
  ("wrote N windows to <OUT>"), and round 2's RUN line now puts OUT under `$TMPDIR` and copies the console log into
  the public, tracked `scripts/logs/timing/`. Before the fix the logged path was repo-relative
  (`scripts/logs/timing/...`, two tracked revisions); at HEAD it is `/tmp/...` only because this agent's shell had no
  TMPDIR. In a normal macOS session it is `/var/folders/<2>/<per-user id>/T//<d>_timing_nuseds_windows.csv`, a
  machine-local path, and where TMPDIR names a per-session or home directory (a harness scratch path holding the
  user name, or anything under `~`) it is a local path the #56 sweep's `local_path` pattern matches. CLAUDE.md's rule
  for paths written into logs is repo-relative or `~` (`.knw_path_rel()`); no helper is applied here, and
  `.knw_path_rel()` would not strip a `/var/folders` or `/private/tmp` path anyway, so printing `basename(out)` (or
  the repo-relative destination) is the shape that cannot leak. Inside an earlier round's fix: **yes** (round 2).
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" (the fix changed what the
    unchanged `cat()` writes into a tracked file); none in the checklist names the public-path rule itself, which is
    CLAUDE.md "One discipline: everything here is public"

No finding above is a failure of a run or a guard that passes when it should stop: every stop() and the quit
(section B) tests the set its message names, and no documented command (section D) copies a filtered or refused run
into the tracked logs.
