# Code-check round 3 (#233, #226): the mechanism, the enumeration checked, and what is left

Reviewed `b07ce5ad...HEAD` (HEAD `90714df1`), each changed file in full. One real defect, inside round 2's fix:
the window walk still reads a window short for a segment that breaks two of its conditions at once. The tracked
evidence and scores are not affected, because the evidence script's count of the load is stricter than the walk and
found no such segment. Two smaller guards fail toward pass. Everything else checked holds.

Probes ran in a detached worktree of HEAD (removed afterwards) against `PGSERVICE=fresh_local`, on temporary tables
and session-temporary functions only. `tests/testthat/test-link_walks.R` at HEAD: 15 tests, 0 failed, 0 errors,
0 skipped (2026-11-22T06:56Z). The main checkout was not touched: `inst/sql/ch_dist_profile_window.sql` is still
md5 `9c4dcfc9…`, and `inst/sql/ch_dist_profile.sql` has no diff on the branch.

## Checklist read

- `code-check-python.md`: in full (9 headings; none applies, the diff holds no Python).
- `code-check.md`: the prose of all 14 H3 under `## Mechanisms` (tables and evidence blocks skipped), and "An
  assertion that matches an interpolated value cannot see the claim around it". 23 other headings read at their
  index line only.
- `code-check-r.md`: 14 of 130 headings in full: "`$` on a list partial-matches…", "A database driver's value is not
  a base R type…", "Postgres row order is never fixed unless the query fixes it…", "`sprintf("%g", x)` writes `Inf`
  and `NA` into SQL…", "Verify a float-formatting fix in its consumer…", "`system2(stdout = TRUE)` warns on a
  non-zero exit…", "`tolerance` in testthat is RELATIVE…", "`match()` treats NA as a matchable VALUE…",
  "`identical()` on two reader results tests the reader…", "`ifelse()` with an all-NA test…", "A range total taken
  as the difference of two large running totals…", "Rscript reads a script as it runs…", "A `data-raw/` script must
  load the source tree…", "`c(name = x)` keeps `x`'s own name…". 116 at the index line only.
- `code-check-shell.md`: 1 of 73 in full ("Git plumbing calls whose default answers a different question", for the
  `git log -S` and `git status --porcelain` guards). 72 at the index line only.
- `code-check-spatial.md`: 2 of 96 in full ("FWA `upstream_route_measure` misses the next segment's start", "FWA
  main flow is not edge type 1000 alone"). 94 at the index line only: the diff's spatial content is the annual
  walk's path text, which the branch does not change and a test holds identical.

## The mechanism

**A summary of a set is accepted where the property is about the set's members.** The property every round has
circled is a one-to-one match: each month of the window has exactly one row, that row has a flow, and all the rows
are on one source. Each fix added one more aggregate for the instance in front of it (rows, then flows, then
distinct months), and the aggregates do not range over the same rows: `count(m.q_m3s)` and `sum()` see only rows
with a flow, while `count(DISTINCT m.month)` and `count(DISTINCT m.source)` see every row. A conjunction of counts
over different row sets is still a proxy, so a segment that is wrong on two axes at once can satisfy every count.
Round 1's other two findings are the same shape one layer up: a name prefix answering for a key (`r$curve`), and a
window's dates answering for its weights (the cache key). The fixture has the matching blind axis: each of its five
malformed segments breaks exactly one condition, so no test or mutation can reach an interaction between two.

The count is equivalent to the property only where something else supplies uniqueness. That is the line between the
places below that hold and the one that does not.

| place | property intended | what is tested | verdict |
|---|---|---|---|
| `inst/sql/ch_dist_profile_window.sql:83-84`, the HAVING | each window month once, with a flow, on one source | flows = n; distinct months over all rows = n; one source | **stand-in: finding 1** |
| same file `:55-65`, the argument checks | the arrays are a window's months and shares | NULLs, lengths, empty, repeats, positive, sum to 1 | holds. NaN and ±Infinity weights are refused (`NaN > 1e-9` is true in Postgres), zero is refused, and no path reaches a NULL condition. Months outside 1 to 12 are accepted (`{0}`,`{1}` must be); R never builds one |
| same file, `{0}`,`{1}` as the annual walk | row for row the annual walk | live test, 3 starts × 3 sources × 4 sizes | holds. One intended difference: a segment with two matching month-0 rows is two candidates in the annual walk and passed over here |
| `R/link_flow.R:157`, `whole` | months 0 to 12 once each, on one source | rows by month, not flows | stand-in, fails safe: a NULL flow in a window month gives `NA` (wet's `mean()` has no `na.rm`), never a short mean. The roxygen's "present exactly where `mad_pick` is" is not held by the function; the evidence script holds it (`:157`) |
| `R/link_flow.R:163-166`, the annual flow read twice | the months' row 0 is the flow query's, per segment | `all.equal()` at 1e-12: a mean relative difference over all segments | stand-in, harmless: one segment hides only under about 1e-12 of the summed flow |
| `R/link_flow.R:195-203`, `.knw_window_weights()` | the walk weighs months as wet does | wet's own arithmetic on unit series | the property itself |
| `R/link_walks.R:258`, `.knw_walk_key()` | a kept row is read only by the walk that would make it | file md5, months, weights (the literal the query carries), label in `src`, flow load | the property, for everything the function is given; the FWA tables stay unkeyed, as documented |
| `R/link_walks.R:151-152`, the cache hit | every size of the grid is kept for the start | a count of hits = `length(q_grid)` | equivalent: the primary key and `chk_unique(q_grid)` make the count one row per size |
| `R/link_walks.R:118,178,287`, the label | a row's `src` names the walk that made it | derived three times (SQL insert, R after the walk, hit levels) | held by the cache test: warm, cold and uncached are `identical()` |
| `data-raw/chinook_window_evidence.R:104-116`, the pre-count | the walk passes over no picked segment and misreads none | flows = n, distinct months **with a flow** = n, one source, annual once, no NaN | sufficient for the walk as committed (see finding 1); its comment calls these "the walk's own three conditions", and they are not. NaN stands in for "not finite": **finding 2** |
| same script `:145-160`, MAD read again and presence | same flow, same visits | per visit, both directions | the property |
| same script `:190-196`, against Phase 1 | every group's median share is Phase 1's | `max(..., na.rm = TRUE)` | **fails toward pass: finding 3** |
| same script `:222-227`, trial against kept walk | the same walk | `all.equal()` at its default 1.5e-8 | stand-in, harmless |
| same script `:299-322`, the read-back | published values unchanged, window values as computed | exact per column through the tuning's reader; 1e-12 for what the run computed | the property |
| `data-raw/chinook_window_tune.R:204-218`, the control | the published table and summary | rule strings, deviance at six decimals, pick, recommended, region; nested selection, seeds, bootstrap share | the property, at the published precision |
| same script `:226-234`, same folds | same visits, groups and folds | folds and groups exactly; visits by three counts | counts stand in for visit identity, but the population is built without reading a reading's columns, so it holds by construction |
| same script `:333-356`, the pair | the two rules' own scores, differenced | seed 54 held to each reading's own deviance at 1e-6 | the property on seed 54; the same code on 55 to 58 and without LFRA |
| same script `:382-393`, the verdict | the three conditions of "The verdict rule" | as written: negative and beyond one SE; at least 3 of 4 negative; negative without LFRA | matches the rule. `converged` is recorded per pair and not read by the verdict; all 18 pairs are `TRUE` in this run |
| same script `:75-88`, `rule_commit` | the rule was on record before any score | today's text equals the text at the first commit holding the heading (`267fcd06`) | the accepted reading |

### The enumeration (`planning/active/review-enumeration.md`), checked

- **The set is not complete.** It lists each way alone. Missing: a segment that breaks two conditions at once
  (finding 1); a month twice where one copy has no flow and every month still has one flow (taken, at the right
  flow, though the header says a month twice is passed over); a flow of ±Infinity (finding 2); a second `forcing`,
  which is in the table's primary key beside `period` and behaves as way 12 does.
- **Row 9 is wrong as stated.** "A month twice and another absent: passed over" holds only when the absent month
  has no row. With a row whose flow is NULL the segment is taken.
- **Row 10 is wrong on the mutation.** "No mutation isolates this one": changing `count(m.q_m3s) =` to `>=` goes red
  at segment 30 alone (measured: taken at 125 m³/s, 500 m), so way 10 has a mutation.
- **The closing sentence does not hold**: "nothing in the set sits above its guard except 13 and 14".
- **Two guards have no red arm**, measured on the fixture: `ORDER BY m.month` deleted (the table says so), and
  `x <= 0` changed to `x < 0` (a zero weight; the table's "weights positive check deleted" covers only a negative
  one).
- The rest of the table reproduces: each fixture segment breaks exactly the one condition its comment names, the
  fixture runs the file's own text with three substitutions, and "reads no window short" still tests a missing
  month now that weights must sum to 1 (`{8,13}`, `{0.5,0.5}`).

## Findings

- **[severity: bug]** `inst/sql/ch_dist_profile_window.sql:83-84` (the claim at `:15-19`) — the HAVING takes a
  segment where one window month has two flows and another month's row has no flow, and reads it short.
  `count(m.q_m3s)` counts the two August flows (2 = months), `count(DISTINCT m.month)` counts August and the
  September row with the NULL flow (2 = months), one source: every condition passes and the sum is August twice,
  September never. The header says such a segment "is passed over, never read short".
  - **Measured**, on the file's own text through the test's `window_walk_fixture()` with one segment added above
    segment 60 (August 100 twice, September NULL, months `{8,9}`, weights `{0.25,0.75}`): taken at 50 m³/s, where
    the test expects segment 10 at 70.
  - **Over the whole small population** (225 segments: 0 to 2 rows in each of two months, each row with or without
    a flow, on source A or B): the property holds for 2; the walk as committed takes 16. Of the 14 malformed ones
    taken, 8 are read at a wrong flow (50 or 90 where a whole segment reads 70) and 6 at the right flow with a
    spare NULL row.
  - **The fix**: add `count(*) = cardinality(months)` to the HAVING, so the three counts range over the same rows
    (n rows, n flows, n distinct months is exactly one row with a flow per month). Measured on the same 225: takes
    the 2 whole segments and nothing else, and the committed fixture test still passes. The fixture needs a segment
    that breaks two conditions, or better the 225 as the acceptance test, since the population is enumerable.
  - **What it did not reach.** The evidence script's pre-count counts distinct months among rows *with a flow*
    (`chinook_window_evidence.R:113`), which stops on all 8 misread shapes, and it found 0 of 4,532,843 picked
    segments. So `data/fdis/derived_window`, the walk cache and every score are right. The defect is in the exported
    path: `knw_link_walks(window = )` on a load nobody pre-counted, or on a source other than `pick`, which the
    pre-count does not cover. The live table allows the shape: its primary key is (scenario, forcing, source,
    linear_feature_id, month, period) and `q_m3s` is nullable.
  - The walk and the pre-count state one fact two ways and disagree; the pre-count is the right one, and its comment
    (`:102`) says they are the same.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A fixture that cannot reach the failure
    mode" ; code-check.md "One fact derived twice"
  - INSIDE round 2's fix (`3edfa6f8`, the `count(DISTINCT m.month)` condition and fixture segment 40).

- **[severity: fragile]** `data-raw/chinook_window_evidence.R:114` (and `:237`) — the pre-count stops on a flow that
  is NaN, "which the walk would take as larger than any size", but not on `Infinity`, which the walk takes the same
  way: counted as a flow, at least any size, found with `large_mad = Inf`. The check after the walk (`:237`,
  `large_mad < qmin`) passes it too. Test `q_m3s IN ('NaN', 'Infinity', '-Infinity')`.
  - No effect on this run: the built evidence holds 0 non-finite window flows at visits and 0 among the 233,984
    rivers found.
  - **Rule:** code-check.md "A proxy is not the property"
  - INSIDE round 2's fix (the `n_nan` arm was added in `3edfa6f8`).

- **[severity: fragile]** `data-raw/chinook_window_evidence.R:190` — `max(abs(by_group[...] - p1_group$rear_q50),
  na.rm = TRUE)` drops any group whose median is `NA` on one side, so a group whose scored visits all lost a finite
  share since Phase 1 passes the check it exists for. `setequal()` on the names does not see it, `is.finite()`
  fires only when every group is `NA`, and the log's "over 45 groups" is `nrow(p1_group)`, not the number compared.
  Stop on `anyNA()` of the differences instead.
  - No effect on this run: all 45 medians are finite on both sides (3 of 4,858 ratios are not finite, none emptying
    a group).
  - **Rule:** code-check.md "A guard that fails toward pass"
  - New (the original script, `e129f421`).

Nothing found in `R/link_walks.R`, `R/link_flow.R`, `data-raw/chinook_window_tune.R`, the two test files beyond the
fixture's blind axis, `DESCRIPTION`, `_pkgdown.yml` or the changed `man/` pages.
