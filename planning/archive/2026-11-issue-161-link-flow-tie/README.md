## Outcome

`knw_link_flow()`'s parent-flow lookup and `knw_link_regulated()`'s dam snap took the nearest line by distance alone,
so between two lines at the same distance the database's scan order chose. Both now order on `linear_feature_id`
after the distance: the lower id takes a tie. Al chose that rule at the gate, because neither physical rule fits
cleanly (on one of #158's pairs the larger flow is the upstream segment). The query moved into
`.knw_link_flow_sql()` so that a fixture can stand in for the FWA and flow tables. `tests/testthat/test-link_flow.R`
pins the rule with a fixture written in both insertion orders and live tests on #158's tied lines and the two tied
dams, and each test failed on the old ordering. Grading reads the parent flow live, so the fix reaches grades at
their next grading on any build. It reaches the visits and the dam snap at the next `0310`. `0320`'s keep-check does
not compare the knowledge commit, so a candidate graded before the fix is regraded, not resumed (code-check round 2).
The durable record is `research/database_builds.md`, "A second database".

## Measurement

`data-raw/link_flow_tie_check.R` covered 34,812 lines on the host and the second database, both holding the same
build and wet load (2026-10-24, b4bbc50). Of those, 2,831 take a parent's flow or codes, and 1,800 of the 2,831 have
two parents within 1e-6 m (1,799 exactly).

- Old code: the two databases differ on 614 lines and 2 dams, every one tied. This reproduces #158.
- New code: the two databases are identical (flow md5 `edb4e53c…`, dams md5 `25bf5a6a…`).
- Old to new on one database: 632 lines change on the host and 636 on the second database, all tied. The second
  database's 2 dams also move.
- Wall time is unchanged: second call 183 s old against 176 s new on the host, 16 s against 14 s on the second
  database. The extra sort key costs nothing.
- Wrong turn: the first tie query also scanned lines with flow of their own, which touch their neighbours at 0 m, and
  flagged 26,072 of the 34,812 lines. It now looks only at lines whose parent lookup runs.

## Evidence

`scripts/logs/habitat/database_second/20261106_link_flow_tie_check*`

Closed by: PR for #161 (branch `161-knw-link-flow-picks-a-parent-flow-by-dis`)
