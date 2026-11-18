# Code-check round 2: #174 branch (knowledge) and crate `nuseds-schema`

## Checklist read

- code-check-python.md: in full (no Python in either diff).
- code-check-r.md: by heading. Read "A database driver's value is not a base R type — and it fails twice", "`ifelse()` with an all-NA test returns a logical vector", "`nzchar(NA)` is TRUE", "Tests that silently do not run", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "`match()` treats NA as a matchable VALUE", "`paste()` with a zero-length argument". About 150 headings not read (no matching tool or shape in the diff).
- code-check-shell.md: by heading. None matched beyond `system2` git calls; read "`system2(stdout = TRUE)` warns on a non-zero exit" (in code-check-r.md). About 120 headings not read.
- code-check-spatial.md: by heading. None matched (no sf/terra in the diff). All headings not read.
- code-check.md: prose of every H3 under `## Mechanisms` read for "A guard that fails toward pass", "A proxy is not the property", "Serialization loses meaning silently", "One fact derived twice"; the other ten skimmed. Rules that stand alone: none read.

## Findings

- **[severity: bug]** scripts/0340-nuseds-build.R:78, 94-114 (through R/publish.R:80) — the records are typed by crate (ids `act_id`, `pop_id`, `gfe_id` as strings; counts as double), written to CSV, and then `knw_publish()` re-guesses every type with `arrow::read_csv_arrow()`. Only columns with a leading zero are forced back to string. So the Parquet that `PUBLISH=TRUE` would upload does not carry crate's types: `data/nuseds/20260601/publish/manifest.json` from the logged run has `act_id`, `pop_id` and `gfe_id` as `int64`, and the count columns split by arrow's guess, `natural_adult_spawners` and `total_return_to_river` as `double` and `natural_jack_spawners`, `other_removals`, `natural_adult_females`, `effective_females` and others as `int64`. `data/nuseds_README.md` tells readers the opposite ("the ids and the `DD-MON-YY` dates as written text"), and crate's decision file gives the reason ids must be strings. Two further effects. A column's type in the published set can change between releases, because it depends on what arrow sees. And arrow infers a column's type from its first block, so a later release whose count column shows its first decimal or `1e+05` beyond the first block (about 1 MB, a few thousand rows of a 210 MB CSV) can fail with a conversion error or come out with a different schema. Nothing has been published yet (the log says "PUBLISH is not TRUE"). A fix would give `knw_publish()` the schema crate typed (or write the Parquet from `x`) before any upload.
  - **Rule:** code-check.md "Serialization loses meaning silently" ; code-check.md "One fact derived twice"

- **[severity: fragile]** DESCRIPTION (`crate (>= 0.15.0)`, `Remotes: NewGraphEnvironment/crate`) and tests/testthat/test-nuseds.R:118-122 — `knw_nuseds_records()` and `0340` need what is only on crate's unmerged `nuseds-schema` branch: the `dfo/nuseds_all_areas` registration, the all-character read and the encoding handling. The crate branch's version is still 0.19.0, the same as crate `main`. So an install from this branch resolves a crate without the registration and `knw_nuseds_records()` errors on every input. The two fixture tests then `skip_if_not()` and CI stays green, so nothing tested the feature on such an install. Before this branch merges, crate needs a release and knowledge's floor needs raising to it.
  - **Rule:** code-check-r.md "Tests that silently do not run"

- **[severity: fragile]** data-raw/chinook_window_flow.R:137-141 — the check counts the `pick` rows per segment (`n_mon != 13L`), and its message says "13 months on one pick source", but it never checks that those rows have one source. Suppose a segment's 13 `pick` rows were split across sources. `wet::wet_flow_window()` builds one series per (lfid, source) with the missing months as NA, so both windows would come back NA. `win()` then matches the first of them and the visit reads as having no window flow, with no stop. The fix is cheap: also require one distinct `source` per lfid.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/chinook_window_flow.R:46, 273-277; data-raw/segment_window_flow.R:114-117 — round 1's fix (c) is meant to make the run record's HEAD reproduce the run. Its pathspec (`research/chinook_window_flow.md`, the script, `R/`) covers the knowledge code. But the readings also go through the `wet` package (`wet_flow_window()`, `wet_segment_daily()`, `wet_segment_monthly()`), and `ch_rear_run.csv` records wet's data build (`daily_build`) but not wet's version or commit. A wet upgrade therefore changes the result under the same recorded HEAD. One axis over, `segment_window_flow.R` writes `knowledge_commit` from an unchecked `system2("git", "rev-parse")`, with no dirty check, into the run record that research/chinook_window_flow.md cites.
  - **Rule:** code-check.md "A guard that fails toward pass"

## The questions the brief asked (no finding)

- **bigint/integer64 reaching base R.** chinook_window_flow.R converts `seg$linear_feature_id` and `seg$parent_lfid` (before `ifelse`), `mon$linear_feature_id` and `grp$linear_feature_id` to numeric before matching. segment_window_flow.R converts `seg` with `as.numeric`. `knw_link_flow()` already casts. timing_nuseds.R reads only text and `text[]`, whose `{...}` literal it parses, and the group codes have no commas. 0340 and the R functions never touch the database. `d$linear_feature_id` and the walk's `large_lfid` come from CSV as double. The logged run took no visit's flow from a parent ("flow from a parent segment: 0 visits"), so fix (a)'s parent path has never run on real data. test-link_flow.R's `parent_lfid == 20` covers the column.
- **Encoding guard, zip.** `readr::read_file_raw()` decompresses a `.zip` (measured: a 176-byte zip returned the CSV's 16 bytes), so the guard reads the CSV's bytes. On the real release, 227 MB of raw data plus one copy as a string, about 3.5 s.
- **Encoding guard, BOM.** readr strips a UTF-8 BOM even under `locale(encoding = "latin1")` (measured), but `crt_ingest_check_not_utf8()` counts the BOM's bytes as multibyte UTF-8. So under the Latin-1 variant, a file with a BOM is refused even when the rest is ASCII, and the message wrongly says "multibyte characters". The guard fails loud, never into mojibake.
- **Encoding guard, pure ASCII.** It passes, as the test shows.
- **Dirty check pathspec.** Besides the wet gap above, the tracked inputs `data/tune/CH_rear_{summary,tune,grades_record}.csv` are outside it. The script itself checks them against the evidence md5 and the published rule's `n_in`, so an edited input mostly stops the run. Untracked files under `R/` are caught, because `--porcelain` lists `??`.

## Verdict

One bug (the published Parquet's types, which are not yet uploaded) and three fragile items.
