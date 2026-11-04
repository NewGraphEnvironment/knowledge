# Code-check round 1 (#145): branch 3140693...HEAD

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped).
- code-check-r.md: read in full the sections "Postgres row order is never fixed unless the query fixes it...",
  "A database driver's value is not a base R type...", "A value compared as `::text`...", "`strsplit()` drops a
  trailing empty field...", "`match()` treats NA as a matchable VALUE...", "An `information_schema` lookup by the
  literal table name...", "Inside a dplyr verb, a column named like a local variable wins", "`system2(stdout = TRUE)`
  warns on a non-zero exit...", "A `function(...)` mock hides arguments...", "`ifelse()` with an all-NA test...",
  "`$` on a list partial-matches..." (11); the rest by index line only (about 95 not read in full).
- code-check-shell.md, code-check-spatial.md: index only; no shell, sed, git plumbing or spatial code in the diff beyond
  `system2("git", ...)` (covered by the R heading above). 0 sections read in full.

## Findings

- **[severity: fragile]** data-raw/pick_network_compare.R:96-99: the clean-tree check runs
  `git status --porcelain --untracked-files=no -- R data-raw`, so it cannot see an untracked script, the script
  itself included. The committed log `scripts/logs/habitat/20261104_pick_network_compare.txt` says "at knowledge
  2f01980" with no "(uncommitted changes)", but `data-raw/pick_network_compare.R` was first committed in b0eda7d, so
  it was not part of 2f01980 when the log was written (it was untracked; a staged new file would show as `A ` and set
  the flag). I reran the committed script on a scratch copy against the same inputs, and the csv is byte-identical,
  so the numbers stand. The provenance stamp is still false, and the check will keep reporting clean for any new
  `data-raw/` producer. Fix: drop `--untracked-files=no` for the script's own path (or
  `git ls-files --error-unmatch data-raw/pick_network_compare.R`), and correct or annotate the committed log line.
  - **Rule:** code-check.md "A guard that fails toward pass"

- **[severity: fragile]** scripts/0300-link-settle-wait.R:83 (shas) with 111-113 (the release branch):
  `shas()` now calls `.knw_build_log_runs()`, which can `stop()` (two `log` runs with neither the recompute's, or a
  run set aside that was logged at or after the build). That happens on the release poll after `rows[[n]] <- r` and
  before `write_log()`, so the process dies and the file's last row stays `polling`. The header promises "the last
  row the verdict" and says a waiter reads the file. A waiter watching the CSV for `released|timeout` never sees an
  end, and the refusal's reason goes only to stderr. Before this branch `shas()` failed only on a database error.
  CLAUDE.md asks that a new refusal leave its record under a `_refused` name or as an explicit status. Fix: catch the
  error in the release branch, set `rows[[n]]$status <- "refused"` with the message, `write_log()`, and
  `quit(status = 3)`.
  - **Rule:** none (CLAUDE.md, Database access: "A refused run writes its ledger or log under a `_refused` name ...
    any new refusal does the same")

- **[severity: bug, prose]** research/minimal_network_tuning.md:180-181: "Steps 3 and 5 of
  `minimal_network_check.R` ... ran against the new full `default` build in the next section". That sentence is in
  "## The province run" (line 138). The section after it is "## What each break source does" (line 183). The
  section it means, "## The full network on the same flows and range (#145)", is the one before (line 80). Write
  "in the section above" or name the section.
  - **Rule:** none

## Checked and holding

- Every number in the new research section and the README index row matches the committed logs. That covers the
  segment-start table row (44.2 / 6.6 %, 305 / 466 m), 45,529 / 45,463 / 66 placements (the 66 are
  `segment_linear_feature_id` differences), 4,156 access pairs (4,097 full 1 against minimal 2), 58 across zero,
  access km within 1.5, stored rearing +0.52 to +1.75 % and SK -0.11 %, spawning -0.01 to -2.78 %, every pick and
  part in the table, and the region distances (7.16/8.28, 80.81/73.24, 65.31/73.69, 7.07/5.13, 10.37/7.34,
  4.80/10.83). It also covers 3 of 7 the same, every published pick in both regions, link 0.78.1 installed on both
  ledgers, and fresh 0.52.0 and 0.53.0 installed against fresh 0.52.0 for both link runs.
- "0.78.2 changed no code": `git diff 193cb8aa 4dfbfa49` in link touches only DESCRIPTION and CITATION.cff outside
  logs, planning and markdown. `R/` and the configs have no diff.
- test-build_record.R passes on a scratch copy (6 tests, 0 failed, 0 errors).
- Considered and not reported: `.knw_build_log_runs()` errors with "missing value where TRUE/FALSE needed" if every
  `date_start` of the kept run is NULL, and it sets aside without the late check a run whose `date_start` are all
  NULL (both reproduced with a mock). Neither is plausible on link's log as probed. A schema with `log_recompute` but
  no `log` is now refused where it used to be accepted. `0300` has always read `log`, so a build that settled has one.

Note: the scratch test run reached the `PG*` database once, through `skip_if_no_pg()` in "the live build record reads
a link schema": two read-only queries on `fresh_default_20261017`. I did not intend it, and it was read-only.
