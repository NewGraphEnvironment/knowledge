# Code-check round 4 — knowledge#57 branch, the delta since `12933fc`

Reviewed 2026-10-17 read-only on the working tree while `0330 STAGE=maps` ran (no file under `data/compare/`,
`research/fig/` or `scripts/logs/` touched; probes ran from a copy of `R/`, `DESCRIPTION` and `NAMESPACE` in the
scratchpad, `r4/`). Scope: the code delta `12933fc..tree` in `R/compare_map.R`, `R/compare_rules.R`, `R/publish.R`,
`R/thresholds_table.R`, `R/tune_run.R`, `scripts/0330-compare.R` and `tests/testthat/test-compare_map.R` (108+ / 39−).
Read in full: the seven files, rounds 1–3 (their accepted items and the three mechanisms), the code-check family
(R, shell, spatial, the general mechanisms), fresh 0.39's `frs_habitat_overlay()` source, tmap 4.4.1's
`tm_scale_intervals()` formals, curl 8.0.0's `curl_fetch_disk()`.

## Verdict: Clean

No defect found in the delta. Every claim the delta makes was measured rather than read; the table is the evidence.

## What was checked, and how

| claim in the delta | checked how | verdict |
|---|---|---|
| lint-only edits changed nothing but whitespace (SQL inside `sprintf()`, the `paste()`d format, braces, the `else` wrap) | parsed `12933fc` and the tree for each of the four `R/` files, collected every `STR_CONST`, collapsed whitespace, set-differenced (`r4/strdiff.R`) | `publish.R`, `thresholds_table.R`, `tune_run.R`: no string changed. `compare_rules.R`: two differences only — `IN ('L', 'M')` → `IN ('L','M')` inside a SQL list (same SQL), and the `say()` format split in two, which `paste()` reassembles to the byte-identical sentence with 5 conversions (`%d %s %d %d %d`) against 5 arguments. The lake/man-made `UNION` string normalises identical |
| `else` across a line break inside braces (`tune_run.R:151-152`) | `parse("R/tune_run.R")` and a three-way probe of the same form | parses; `A`/`B`/`C` for the three branches |
| `intersect()` reordered (`compare_rules.R:200`) | read `frs_habitat_overlay()` to the end | one independent idempotent `UPDATE … SET <hab> = TRUE … WHERE (h.<hab> IS NULL OR FALSE)` per type, inside `for (hab in habitat_types)`: order cannot change the result |
| `gkm` removal | grep | no remaining reference |
| `knw_compare_map()` early return | ran the new test file from the scratch copy with `sf_use_s2(TRUE)` first, as a fresh session has it | both tests pass (3 + 3 expectations). With the guard removed the empty `seg` reaches tmap and errors, so test 1 fires on the defect it was written for |
| `expect_message()` with `sf::sf_use_s2(FALSE)` messaging first ("Spherical geometry (s2) switched off" precedes the message under test) | measured on testthat 3.3.2: `expect_message({message("a"); message("target")}, "target")` | PASS. The checklist's "checks only the FIRST condition" does not describe 3.3.2's behaviour; non-matching messages pass through and the matching one is caught. Not a finding, noted so nobody "fixes" the test toward `capture_messages()` on the checklist's word alone |
| the early return leaves `0330`'s loop consistent | read `0330:245-249` | `tryCatch` around the call; `character()` returned; nothing written for that group, loop continues. The `say("%s: maps for %s.", k, map_wsg)` line still lists the group among the maps drawn — a log inaccuracy, not a failure (see notes) |
| `labels` on the floodplain interval scale | `tm_scale_intervals()` has a `labels` formal in 4.4.1; rendered a 3-panel figure from the scratch copy with a 4×4 raster holding 0, 0.1, 0.19, 0.2, …, 1 and NA (`r4/labels.R`, `r4/labels.png`) | legend reads `0-0.2 … 0.8-1`; cells at exactly 0 and 1 are drawn in the first and last class, none dropped |
| `STAGE=maps`: every object the map stage reads exists with the full run's types | `jobs[[k]]` (named at line 122, before either branch), `jobs[[k]]$stage`/`$species_code`, `r$compare$tuned_rule[1]`, the per-key rds; `res` named from `names(jobs)` **before** `Filter()`, which keeps names. Read every one of the eight `<key>_compare.csv` with the stage's exact `col_types` (`r4/readback.R`) | 0 parse problems in all eight, 0 non-finite values, `tuned_rule[1]` populated; readr's own guess calls every other column double, so the five character columns named are the only ones. The writer (`per_group()`) produces doubles, two integer counts (`gained_n`, `lost_n`, read back as double; nothing in the map stage reads them) and the two rule strings |
| `gpkg_of()`'s `on.exit(unlink(part))` cannot delete the finished file | read | `part` is `paste0(f, ".part")`, never `f`; after `file.rename(part, f)` the `unlink(part)` is a no-op on a path that no longer exists. On a timeout (raised inside `curl_fetch_disk`) or a non-200 the `.part` holding the partial body or the error page is removed. A `.part` left by a killed process is reopened `"wb"` (curl 8.0.0), so it is overwritten, not appended to |
| `file.size(f) == 0` on a missing or directory path | read | guarded by `file.exists(f) &&`, so never evaluated on a missing path; a directory would read non-zero and fall through to `st_read`'s own error. Neither is a reachable state of `data/compare/catalog/` |
| the 0-byte guard's scope ("Written data outlives the fix": a truncated **non-empty** GeoPackage left by the old code path would pass as a cache hit, and the new guard cannot see it) | `HEAD` on all 23 bucket objects against the cached files' sizes | 23 of 23 equal (`bowr` 10,678,272 … `will` 10,317,824 bytes). No such record exists, and the `.part` path cannot create one, so the guard's narrower scope has no member to miss today |
| the `-maps` log suffix | read | `paste0(…, if (stage_only == "maps") "-maps", ".txt")`: `NULL` is dropped by `paste0`, so the full run's path is unchanged |
| `STAGE` validation | read | `!stage_only %in% c("", "maps")` parses as `!(… %in% …)`; unset reads `""` and passes |
| packages the new test reaches are declared | `DESCRIPTION` | `sf`, `tmap`, `terra`, `chk` all declared (Imports/Suggests), `skip_if_not_installed("tmap")` gates the file |

## Notes (not defects)

- `0330:251` under either stage logs `maps for <every map_wsg>` including a group where `knw_compare_map()` drew
  nothing (RB in the 23 link#349 groups). The message is printed above it, so the log is not misleading read whole,
  but a reader counting figures from the `maps for` lines will count one too many per such group.
- Under `STAGE=maps` the stage still reads `visits_link.csv`/`visits_species.csv`, pulls link's configs with `git
  show`, and opens the database to list each species' groups, none of which the map stage uses. Cost only; and the
  `git show` makes a maps-only run depend on `LINK_REPO` being present, which a full run needs anyway.
- `STAGE=maps` stopping on "no saved comparison" writes no log file, where the full run's "every comparison job
  failed" does. Cosmetic.
- Test 2 does not pass `fp_cells`, so the `labels` change is exercised only by `r4/labels.R` in the scratchpad, not
  by anything in `tests/`. Per the brief, not a finding; the render above is the evidence it works.

## Mechanism

None new. Rounds 1–3's three shapes (another system's semantics re-derived and checked at one point; one fact written
at every consumer; a fix landing at one end of a contract) were each looked for in this delta: the `STAGE=maps`
branch is the one place a contract was re-stated (the CSV's column types, the keyed `res`/`jobs` lookup), and both
ends were measured above against the writer and against all eight saved files.
