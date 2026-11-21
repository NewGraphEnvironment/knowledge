# Code-check round 3: branch 244-backlog-move-16-nuseds-spawning-windows (base origin/main 088cd31b, head 13436fc7)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped); no
  stand-alone rule read in full (none names a shape this diff uses beyond the Mechanisms prose).
- code-check-r.md (by heading; 6 read, about 123 not): "`ifelse()` with an all-NA test returns a logical vector,
  whatever `yes` and `no` are"; "`match()` treats NA as a matchable VALUE, so two unknowns join to each other";
  "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent"; plus the index lines
  of "`data.frame()` recycles a scalar against a zero-length column", "`paste()` with a zero-length argument returns
  length ONE, not zero" and "Postgres row order is never fixed unless the query fixes it, ..." (read in full by
  rounds 1-2, rechecked against the HEAD code only).
- code-check-shell.md (by heading; 3 read, about 97 not): "Diagnose env/PATH problems in the shell that actually
  runs, not the ambient one" (its `GROUPS` bullet); "Quoting"; "`a && b || c` runs `c` when any step before the
  `||` fails".
- code-check-spatial.md: index only; no heading applies (one exact-match SQL lookup on `fwa_watershed_code`, no
  geometry read).

## Mechanism

All five earlier findings share one assumption: **the set each step computes on is the set its name, guard or
output describes** — the whole unfiltered run, one record per population-year, the filter the user typed — and
nothing in the code checks the equivalence. `GROUPS` never arrived, so "the groups asked" was every group; the
reach guard asked "is this reach in the records?" of a species-filtered subset; the comparison assumed the full
run's non-empty timing table; the tracked log took whatever run wrote it as the day's full run; and `years_*` named
population-years while counting records. In code-check.md's words, "a guard written against the whole artifact
silently redefines every mode that passes it a subset" (A guard's scope, escape hatches, and remedies), and a
column must be shown to hold the population its name says (One fact derived twice).

Places this reaches in the HEAD diff, each checked:

1. **The filter the user typed (`env_list`, lines 56-67, 188).** `SPECIES` is checked against the six codes. `WSG`
   is checked only by the stop when no key is left, so one mistyped member of a list is dropped without a word
   (finding 2).
2. **The reach guard (136-150), before the species filter (151).** It now sees every species. Its "in no record"
   means "in no record that has a watershed code the Atlas holds" (lines 97 and 133 run first). That is the right
   population for a guard on placement. Every gfe_id has exactly one watershed code (2,342 gfe_ids, 0 with more
   than one), so `crossed` and the override cannot reach records on another code. Sound.
3. **The counts printed before the filter (95-96, 131-132).** Under `SPECIES=` they count every species. They are
   printed only, never written to the CSV, and a filtered run is not meant to be copied in. Accepted in round 2.
4. **The checks (235-246).** A full run always has the UFRA, COTR and BULK keys, so all three run. A filtered run
   skips them with a printed line and still exits 0, which matters only through finding 1.
5. **The copy into the tracked logs (RUN, lines 44-50).** pipefail stops a refused run. A filtered run exits 0, so
   `&& cp` copies it over the day's full record (finding 1; inside round 2's fix).
6. **`n_*` against the header's "records ... except ..." sentence (23-26).** Re-measured on the published v1 set
   after the script's own filters: 16 dated records share a population-year, in populations 46602 and 47925, and 8
   records are extra beyond one per population-year. The header's numbers hold, and `n_start`, `n_end` and
   `n_arrival` count records, as their names now say. Sound.
7. **Population versus record in the pooling (header 11-17, code 134 and 197).** The header speaks of populations,
   but the code assigns each record by its own watershed code. Of 5,106 dated populations, 3 have records on more
   than one code. One of them sits in two groups: 46795 CO, Blue River, pooled in UNTH (gfe 281) and in MURT
   (gfe 33103 and 1921661712). It is pooled in both, with each group's records, and is never both pooled and apart
   under one group. No population is split between pooled and apart. Every number in that case is the right one for
   its group. Sound.
8. **Apart rows (215-216).** `pop_rows` takes every apart record of the population, not only those whose code
   crosses `w`, and `groups` prints `p$groups[1]`. That would be wrong for an apart population spread over several
   multi-group codes, but none exists: the only population with more than one `groups` string is 46795 above, and
   it is pooled. Sound today.
9. **The group row's other columns.** `records` counts undated records too, and `first_year`/`last_year` count only
   dated ones. Both are literal to their names. The group row's `run_type` lists runs of undated records too, while
   the per-run split uses dated runs only. That is a label, not a number. Sound.
10. **The comparison (254-295).** It reads only `scope == "group"` rows, as the header says ("pooled group
    windows"). The empty-`tt` path exits 0 after OUT. Sound (probed in round 2).

## Findings

- **[severity: fragile]** data-raw/timing_nuseds.R:44-50 (the RUN lines) — Round 2's fix stops a *refused* run from
  replacing the day's full record, but not a *filtered* one, though the header says it covers both ("a filtered or
  refused run would replace the day's full record"). The filters are documented as prefixes "before Rscript", that
  is, inside the same RUN command: `(set -o pipefail; WSG=BULK OUT=${t}_windows.csv Rscript ... | tee ${t}.txt) &&
  cp ${t}.txt ${t}_windows.csv scripts/logs/timing/`. A filtered run exits 0: it skips the three checks with a
  printed line, writes OUT and exits 0 after the comparison, or at `quit(status = 0)` when the table has no row
  (round 2 probed `WSG=ADMS SPECIES=CH`: exit 0). So `&& cp` overwrites the tracked
  `<d>_timing_nuseds.txt` and `_windows.csv` with the subset. All that stands in the way is the parenthetical "a
  run to read, not to copy in", a person reading a comment, which is the same shape round 2 flagged. Both files are
  tracked, so git can restore them, but a routine `git add scripts/logs/timing/` commits the subset as the day's
  record. Defect inside an earlier round's fix: **yes** (round 2).
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/timing_nuseds.R:60 with :188 — `WSG` is filtered with `keys$wsg %in%
  want_groups` and checked only by the "no dated records" stop, which fires only when *every* named group is
  missing. `WSG=BULK,MORX` (a typo for MORR) runs BULK alone. The comparison then drops MORR's rows, because `tt` is
  filtered by the same list, and the run exits 0 with nothing saying a group was asked for and not found. The output
  reads like a complete answer for the groups asked, and "no NuSEDS records in MORR" cannot be told from "MORR
  mistyped". `SPECIES`, the other filter, is checked member by member at line 65. Not a defect inside an earlier
  round's fix (round 1 renamed the variable; the check was never there).
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "Zero-length, empty, and unset are three different things"

## Probes run (copies in the scratchpad `r3/`, outputs only there; the repo untouched)

- Ran the script's lines 53-151 against the published v1 Parquet and the fwapg database PG* points to, then
  measured: the number of distinct watershed codes per gfe_id (0 of 2,342 have more than one); the codes, `groups`
  strings and pooled/apart assignments per dated population (3, 1 and 1 with more than one: 46795 CO, pooled in
  UNTH and MURT); populations both pooled and apart (none); and dated records sharing a population-year (16 records
  in populations 46602 and 47925, 8 beyond one each), which confirms the header.
