# Code-check round 3 (#120): `git diff 6b7c31d...HEAD` (HEAD d61ebcf)

## Checklist read

- `code-check-python.md`: in full (nothing in the diff is Python).
- `code-check-r.md` (190,768 bytes): 23 of 115 headings read in full, the ones whose index line names a shape this
  diff uses: read-back shape; `data-raw/` loads the source tree; `$` partial match; driver values; `nzchar(NA)`;
  zero-length `paste()`; `identical()` on reader results; tests under `R CMD check`; CSV whitespace; `match()` NA;
  `as.integer("NaN")`; `unlist()` names; `[[` on atomic; `data.frame()` recycling; Postgres row order; `sprintf("%g")`
  into SQL; `information_schema` lookups; Rscript reading a script as it runs; `pkg::` in tests; dplyr data masking;
  `function(...)` mocks; `ifelse()` all-NA; `sub()` replacement. 92 not read.
- `code-check-shell.md` (132,401 bytes): 0 of 70 read; the diff has no shell, git or `gh` code.
- `code-check-spatial.md` (156,392 bytes): 0 of 94 read; the diff calls no sf, terra, GDAL or bcdata function.
- `code-check.md` (334,881 bytes): the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus
  "Documentation Staleness" and "An assertion that matches an interpolated value cannot see the claim around it".
  The other standalone rules and the Security and Spreadsheets sections were not read.

Method: I read the diff in full and every changed file in the checkout. I read the consumers of each changed shape
(`R/tune_promote.R`, `R/run_ledger.R`, `R/thresholds_table.R`, `R/archive.R`, `scripts/0299`, `0300`, `0310`,
`0320`, `0325`, `0330`, `0335`, `data-raw/vignette_chinook.R`, `vignette_method.R`, `archive_seed.R`,
`site_gradient_check.R`, `compare_structures_check.R`), and link's `R/lnk_log.R` (`../link` at 552f43d6) for where the
tokens are written. In a copy (`git archive HEAD`): the five changed test files pass (19, 9, 9, 17 and 133
expectations, no failures or errors); `test-settings-register.R`, `test-vignette-data.R` and `test-data-dir.R` pass;
`pkgdown::check_pkgdown()` finds no problems; `tools:::.check_packages_used_in_tests()` prints nothing. Finding 1 is
reproduced in the copy (below).

## Findings

- **[severity: fragile]** scripts/0330-compare.R:150-160. The remedy in the md5 refusal cannot be followed. When the
  local `data/fdis/derived` is not the build the curves were fitted on, 0330 stops with "set EVIDENCE_DIR to that
  build's directory". But three lines earlier it refuses any `EVIDENCE_DIR` whose path is not the one the summaries
  name. Since #120, 0320 writes `evidence_dir` into every summary, and by default that is `data/fdis/derived`.
  So the only directory 0330 accepts is the one it has just found wrong.
  - Reproduced in a copy with lines 143-160 run verbatim. With no `EVIDENCE_DIR`, 0330 gives the md5 refusal. With
    `EVIDENCE_DIR=../staged/derived`, which holds the curves' build, it stops with "EVIDENCE_DIR=../staged/derived is
    not the directory data/tune/candidate/20261102_0000's summaries were scored on (data/fdis/derived)".
  - This is the workflow CLAUDE.md describes. Scoring runs on any machine with the build, and the comparison runs on
    the database's host. That host's `data/fdis/derived` "can be an older build than the promoted run", and CLAUDE.md
    says to "stage the promoted inputs beside the repo where they differ".
  - The two checks test one property in two ways. The md5 check is the property. The path check compares a machine-local
    string recorded on the scoring machine, which is a proxy for it.
  - Remedy: let `EVIDENCE_DIR` name any directory and rely on the md5 check, keeping the summaries' directory as the
    default. The scripts/README line "(EVIDENCE_DIR overrides, never to another)" and CLAUDE.md's "`0330` reads the
    directory the summaries name" would follow. Alternatively, have the error name the remedy that works: replace the
    tables in the summaries' directory.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "A proxy is not the property"

- **[severity: fragile]** CLAUDE.md:406-409 (and the comment at scripts/0310-evidence-build.R:80-83). The sentence
  says the tag means "a test build on another schema never becomes the build a default reader takes". The code ties
  the tag to the directory, not to the schema, so the "never" holds only when the operator remembers `EVIDENCE_DIR`.
  - Before #120, the 0310 gate itself kept a test schema out. It took the newest `fresh_default` settle log, and
    `knw_build_record(conn, schema, run_uid = st$run_uid)` refused any schema built by another run.
  - This branch adds `SETTLE=` for test schemas, and that bypasses the gate. Consider
    `SCHEMA=zz415_minimal SETTLE=…_link_settle-zz415_minimal.csv` with no `EVIDENCE_DIR`: it passes the gate, then
    writes its few-group tables over `data/fdis/derived` (the published build's evidence) and writes an untagged
    `<date>_evidence_build_ledger.csv`.
  - That untagged ledger is then the one that `.knw_evidence_ledger()` (0320, `segment_gradient_check.R`) and
    `knw_run_ledger()`'s fallback take as the newest default.
  - Nothing in 0310 relates `SCHEMA` or `SETTLE` to the directory. Remedy: when `SETTLE` is given, or when the settle
    log's `schema` is not `fresh_default`, refuse the default directory unless the operator opts in. Otherwise the
    sentence should say the guarantee rests on `EVIDENCE_DIR` being given.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "A guard that fails toward pass"

- **[severity: fragile]** scripts/0299-fdis-publish.R:96. v3's description of `access_check` now reads "per species and
  watershed group". On this machine, `data/fdis/derived/access_check.csv` has no `watershed_group_code` column. Its
  columns are `species_code,habitat_accessible,access_gt0,n_segments,n_rearing,n_spawning,km,run_uid`, built
  2026-10-27, and this is the build the published grades were made on.
  - 0299 publishes whatever the file holds. Publishing v3 from the published grades' evidence would therefore put a
    manifest on the public bucket describing a column the table lacks.
  - The per-group shape exists only in a build made after #120, which has different md5s from the evidence the grades
    name. This is the changed-shape class with the reader 0299 and an artifact already written.
  - Remedy: have 0299 check that the `access_check` columns match its description before `PUBLISH=TRUE`, choosing the
    description by the columns present, or note that v3 needs a post-#120 0310 build.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: fragile]** scripts/0320-tune-run.R:371, plus the first log line at :198. `evidence_dir = evidence_dir`
  writes the raw `EVIDENCE_DIR` string into every summary.
  - Summaries become tracked on promotion. So do the run's logs, whose first line now also prints the directory.
  - An absolute `EVIDENCE_DIR` (for example a staged copy given as `$PWD/…`) therefore puts a home path into tracked
    `data/tune/<key>_summary.csv` and `scripts/logs/habitat/`. `.knw_path_key()` treats an absolute default as the
    default, so nothing else refuses it. CLAUDE.md bars home paths from tracked files.
  - The ledger rows `evidence_dir`, `settle_log` and `parent_dir` in 0310 are written raw in the same way, and the
    ledgers are committed.
  - `data-raw/site_gradient_check.R:55` and `compare_structures_check.R:87` already pass logged paths through
    `home_rel()` for this reason. Remedy: write paths repo-relative where they lie under the root, and refuse or
    `home_rel()` the rest.
  - **Rule:** code-check.md "Serialization loses meaning silently" ; none (repo discipline: CLAUDE.md "everything here
    is public")

## The mechanism, and every place it reaches

Your reading holds, with one addition. Prose written beside a change states the author's intent, and the shapes the
change altered were checked against the readers the author had in mind, not all of them. Rounds 1 and 2 found both
halves: a reader of a changed log line, and sentences describing what was meant. The addition is that guards and
remedies were checked against the case the author ran, never against the case they exist for.

- Round 3's finding 1: 0330's remedy was never run against its own path check.
- Round 3's finding 2: the "never" was not re-checked once `SETTLE=` removed the gate that had made it true.

Two pairs here are the "two lists that happen to agree" form:

- **Path identity and content identity.** Ledger-by-directory, the `evidence_dir` path check, and md5 equality agree
  only while a build stays at the path it was built at, on the machine that built it.
- **Directory tag and schema.** The ledger tag follows the directory, while the gate used to follow the schema. They
  agree only while every test build is given a test directory.

| Changed shape, guard or claim | Consumers or source checked | Verdict |
|---|---|---|
| 0320 first log line | `vignette_chinook.R:91,266` regexes, run against the new line | holds (R1 fix) |
| Summary: `+min_wsg,folds,evidence_dir` | `knw_thresholds_table()` (binds on the union of columns), `knw_tune_promote()` (`fld`), `vignette_method.R:314-320` and `vignette_chinook.R:64` (by name), `archive_seed.R:57` (by name), 0330 (new reader) | holds; the path value is finding 4 |
| Floors guard | main and `grad_fwa/` summaries in `knw_tune_promote()`; a pre-#120 summary (NA) passes; `"5"` read as text compares equal | holds (R1 fix); tests pass |
| `grad_parent/` "never promoted" | `plan_dir` moves `grad_fwa/` alone, but `logs <- list.files(run_tune, "_tune_run.*\\.txt$")` also copies a non-DEV `-grad_parent` pass log | holds for the tables; the log is copied, which does no harm (no grade lines, so `vignette_chinook.R` skips it) |
| `access_check.csv` per group | 0299 description (finding 3); `minimal_network_check.R` (guards the column); the 0310 ledger's `access_disagree_*` (summed per species) | finding 3 |
| Ledger name and new rows | `knw_run_ledger()` fallback (`_ledger\.csv$`, which excludes `-<tag>.csv`); `.knw_evidence_ledger()` (anchored); 0322 and `snap_limit_sensitivity.R` (default only); every row reader works by `step` name (grepped) | holds |
| Refused ledger name | `<date>_evidence_build_refused-<tag>.csv`; no reader pattern matches it | holds; 0310:41's comment names only the default form |
| Tag guarantee ("never") | 0310 gate with `SETTLE=` | finding 2 |
| Settle log `+schema,poll_min`, tagged name | 0310 is the only reader (by column name); its pattern `_link_settle\.csv$` excludes tagged logs | holds |
| `knw_build_record()` tokens from `log` | link's `lnk_log.R:1047` writes all four per row; feeds `knw_grade_record_write()` and then `knw_archive_setup()` (a partial set stops; link writes the four together) | holds |
| `knw_link_access_check(by_group=)` | SQL `GROUP BY 1, 2, 3`; the empty frame gains the column; 0310 is the only caller | holds |
| `visits_link` `parent_*` columns | 0320 checks for the column; `minimal_network_check.R` excludes `parent_*`; downstream readers use readr by name | holds |
| 0330 evidence directory and md5 | remedy text against the path check | finding 1 |
| 0320 `DEV_DIR` | regex plus parent check; `.gitignore` `data/tune/dev_*/`; `dir_pub` maps from `grad_dirs`, not `dir_out` | holds |
| Doc sentences: CLAUDE.md #120 paragraphs, scripts/README 0300/0310/0320/0330, data-raw/README, research "How the runs are set up", roxygen of `knw_parent_join`, `knw_build_record`, `knw_link_access_check`, `knw_tune_promote`, the 0310/0320/0330 headers | each checked against the code path | hold, except: the "never" (finding 2); research and the 0310 comment saying 0330 "find[s] its ledger by" the directory, when 0330 takes the ledger the summaries name (`knw_run_ledger(tune_dir)`), which does not change what 0330 reads; CLAUDE.md's 0330 sentence, tied to finding 1 |
| Data claims in research (BT the only key with 4 groups; CH 3) | `minimal_network_120/dev_zz415_minimal__…-dev.txt` lines 12, 22, 264-279 | hold |

/Users/airvine/Projects/repo/knowledge/planning/active/review-round3.md
