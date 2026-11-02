# Code-check round 2: branch 120-tune-chinook-rearing-on-minimal-segments (`git diff 6b7c31d...HEAD`)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md (190 KB): read these sections in full: "A `data-raw/` script must load the source tree, not the installed package", "`$` on a list partial-matches, …", "A database driver's value is not a base R type …", "`paste()` with a zero-length argument …", "`match()` treats NA as a matchable VALUE, …", "Postgres row order is never fixed unless the query fixes it, …", "An `information_schema` lookup by the literal table name …" and "Inside a dplyr verb, a column named like a local variable wins". The other ~100 headings I judged from their index lines.
- code-check-shell.md (132 KB): no section read. The diff has no shell, sed, awk or git code.
- code-check-spatial.md (156 KB): no section read. The diff has no spatial code.
- code-check.md (335 KB): read the prose of all 14 H3s under `## Mechanisms` (without the `|` table rows or the evidence blocks), plus "Documentation Staleness". The other headings I judged from their index lines.

## Method

- Read the diff in full and every changed file at HEAD.
- Read the callers and readers of everything whose shape changed:
  - the first line of the 0320 log: `data-raw/vignette_chinook.R:61-91,167,190`;
  - the ledger names: `knw_run_ledger`, 0325, 0330, `vignette_method.R`, `snap_limit_sensitivity.R`;
  - the settle log: 0310;
  - the summary columns: `knw_tune_promote`, `knw_thresholds_table`, 0325, 0330, `vignette_method.R`, `vignette_chinook.R`;
  - `access_check.csv`: 0299 and `minimal_network_check.R`;
  - the promotion's handling of logs and `grad_parent/`: `R/tune_promote.R:219-300`.
- Ran these tests in a `git archive HEAD` copy with `NOT_CRAN=true` and `test_file()`. All pass, with 0 failures and 0 errors:
  - the five changed test files: 19, 9, 9, 17 and 133 passes;
  - `test-settings-register.R` (272), `test-data-dir.R` and `test-thresholds_table.R` (57).
- Checked every number in `research/minimal_network_tuning.md` against the committed logs it cites:
  - the ledgers, the settle logs, `20261102_minimal_network_check.txt`, both segment_gradient_check logs and both site_gradient_check logs;
  - the four dev logs and the four `minimal_network_120/` tune and compare logs.
  - All hold, among them 52.0/5.8 %, 2.8/1.5 %, 298/458 m, 742 m, 2,082, 43,625, 5,724, 36 of 227, 40,068, 22,902, 1,175, 87 against 117, 20 against 25 %, 20.0 against 5, 4.3/4.1 min, 0.6/0.7 min, the stored km deltas, 1,178 visits, 0.696, and 8.5/8.7 %.
  - The "141 pairs, every one 1 on full and 2 on minimal" claim is not in the log it cites, so I recomputed it from the two ignored `visits_link.csv` files: 141 pairs, all `1 2`. It holds.
  - The `default` km match link's stored km on both networks: the compare logs give 10,287 and 10,392 km, and the stored per-group sums are the same.

The round-1 fixes hold:
- The vignette_chinook regex extracts the ledger from the new first line, and no other reader parses that line.
- `floors_check` covers the candidate's `grad_fwa/` summaries.
- The roxygen of `knw_parent_join()` matches the code.

## Findings

No bugs. Three doc sentences say something the code does not:

- **[severity: fragile]** scripts/0310-evidence-build.R:124. This branch rewrote the comment as "0320, 0325 and 0330 read the newest `*_evidence_build_ledger*.csv`". The trailing `*` says the default readers match tagged ledgers (`…_ledger-<base>.csv`), which is the opposite of the branch's design. Two readers do something else:
  - 0320 finds its ledger by directory, with an anchored pattern (`.knw_evidence_ledger()`).
  - 0325 and 0330 take the ledger the summaries name (`knw_run_ledger()`). That function falls back only to the anchored `_evidence_build_ledger\.csv$`.

  A reader who trusts the comment could conclude that a test build's ledger reaches the default readers. The comment should name the untagged pattern, or say "the ledger their directory or summaries name".
  - **Rule:** none

- **[severity: fragile]** scripts/README.md:64. It reads "`PARENT_DIR=<link's parent_<wsg>.csv.gz>`", which tells the user to pass a file. The code (0310 lines 214-217, `list.files(parent_dir, "^parent_[a-z]{4}\\.csv(\\.gz)?$")`) wants a directory that holds those files. Its own header agrees (`[PARENT_DIR=<dir>]`). Given a file path, the build stops with "holds no parent_<wsg>.csv.gz". That fails safe, but the README sends the user there.
  - **Rule:** none

- **[severity: fragile]** data-raw/minimal_network_check.R:4. The header says "Four checks, on two evidence builds", then lists five, numbered 1 to 5. The fifth (STORED) reads the database, not the builds. The script runs all five and its log numbers them 1 to 5.
  - **Rule:** none
