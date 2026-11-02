# Code-check enumeration after round 5 (#120, by the session, 2026-11-02)

Rounds 3, 4 and 5 each found a defect inside an earlier round's fix, so the loop ends on an enumeration, not a
quiet round. Rounds 4 and 5 tabulated sets A (every changed shape and its readers) and B (every prose sentence against
its code); their tables are `review-round4.md` and `review-round5.md`, and round 5's two findings are fixed. This file
closes the two sets the inside-a-fix findings came from.

## Paths written into a ledger, summary or log by the changed scripts (grep of say/add/block/write in each)

| script | path written | form |
|---|---|---|
| 0310 | evidence_dir, settle_log, parent_dir | `.knw_path_rel()` |
| 0310 | the ledger path | relative by construction (`scripts/logs/habitat`) |
| 0320 | evidence directory (log line 1, summary) | `.knw_path_rel()` |
| 0320 | ledger path (log, summary `evidence_ledger`) | relative (`.knw_evidence_ledger()` lists a relative log dir) |
| 0320 | dir_out, the pick report path (DEV logs) | from `dev_dir`, now `.knw_path_rel()` (round 5); a candidate's is `data/tune/candidate/<run>` |
| 0330 | tune_dir, dir_out | relative (TUNE_DIR is refused unless `data/tune/candidate/<run>`) |
| 0330 | evidence directory | `.knw_path_rel()` |
| 0330 | link_repo | raw `LINK_REPO`; predates this branch, so CLAUDE.md's sentence is scoped to the directories this branch writes |
| segment_gradient_check.R | evidence directory, ledger | `.knw_path_rel()`, relative |
| minimal_network_check.R | FULL_DIR, MIN_DIR, ledgers | `.knw_path_rel()`, relative |
| 0300 | its own log path | constant |

## Every guard the branch added, and its escape hatches (from `git diff 6b7c31d...HEAD | grep stop`)

| guard | empty / NA / missing | verdict |
|---|---|---|
| tokens: a NULL beside a value | no column, or every row NULL: NA (by design, before link 0.70.0) | OK |
| parent: two rows for a segment; a visit with no row | NA id has no row: stops | OK |
| parent: segment length against overlap + straddle | NA length, or no `overlap_m`/`segment_length_m`: stops (round 5) | OK |
| ledger tag's characters | `EVIDENCE_DIR=""`: basename empty, stops before any write | OK |
| no ledger for a directory; a ledger naming another | a ledger without the row is the default's (pre-#120) | OK |
| floors in main and grad_fwa/ summaries | absent: the defaults (pre-#120); unparseable: refused | OK |
| 0299 access_check without a group column | stops before writing | OK |
| POLL_MIN, SCHEMA | empty: refused | OK |
| default directory by another name; a test build in the default | the sentinel asks the disk; a missing schema in the log is not fresh_default, so refused | OK |
| no settle log | `SETTLE=""` is not given: the newest default log | OK |
| PARENT_DIR without parent files | `PARENT_DIR=""`: no join, columns absent | OK |
| MIN_WSG, FOLDS | non-integer or < 2: refused | OK |
| DEV_DIR | without DEV, empty, or not `data/tune/dev[_<name>]`: refused | OK |
| GRADIENT column absent | refused | OK |
| 0330: two directories in the summaries; md5s not the curves' | a curve with no evidence_md5 is refused | OK |

Nothing in either set sits above its source of truth.
