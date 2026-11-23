# Code-check round 2 (#226 on branch 233): the window walk, the window flow, the two data-raw scripts

Reviewed `b07ce5ad...HEAD` (tip `1b27910e`), each listed file in full and by diff. Probes ran in a detached
worktree and a scratch clone (both outside the checkout; the worktree is removed) and read-only against the
local database. The checkout was not touched but for this file. Measured 2026-11-22 06:22 to 06:40 UTC.

## Checklist read

- `code-check-python.md`: in full (9 headings).
- `code-check.md`: the prose of all 14 H3 under `## Mechanisms`, table rows skipped. Under "Rules that stand
  alone", read: "Test the cold/create path of idempotent code, not just the warm no-op", "Documentation
  Staleness", "An assertion that matches an interpolated value cannot see the claim around it". Not read: the
  other 11 standalone rules, Security (6), Spreadsheets and PDFs (4).
- `code-check-r.md` (130 headings), read in full: "Postgres row order is never fixed unless the query fixes it,
  so a pick, a float sum and a presence check can each depend on it"; "`$` on a list partial-matches, so a
  longer sibling key answers for a missing one"; "`system2(stdout = TRUE)` warns on a non-zero exit instead of
  raising"; "`sprintf("%g", x)` writes `Inf` and `NA` into SQL as bare words"; "Verify a float-formatting fix in
  its consumer, not through `as.numeric()`"; "A `data-raw/` script must load the source tree, not the installed
  package"; "`on.exit()` at a script's top level never fires"; "`identical()` on two reader results tests the
  reader, not the file"; "`tolerance` in testthat is RELATIVE"; "`match()` treats NA as a matchable VALUE"; "A
  database driver's value is not a base R type"; "CSV whitespace: `trim_ws` and `strip.white`"; "`ifelse()` with
  an all-NA test returns a logical vector"; "A value compared as `::text` in SQL has PostgreSQL's spelling";
  "`expect_message(expr, regexp)` checks only the FIRST condition"; "Rscript reads a script as it runs";
  "`c(name = x)` keeps `x`'s own name"; "`paste()` with a zero-length argument returns length ONE". Read in part
  (the rule and its first screen): "Under `R CMD check`, tests run from a temp dir against the INSTALLED
  package"; "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check`"; "`[[` on a named ATOMIC
  vector with an absent key is an error"; "`data.frame()` recycles a scalar against a zero-length column"; "Two
  repos pinning the same remote at different tags"; "testthat counts an uncaught error under `error`"; "Never
  name a durable artifact by a hash the library reserves the right to change". Not read: 105.
- `code-check-shell.md` (73 headings), read: "Git plumbing calls whose default answers a different question",
  "psql does not interpolate `:'var'` inside a dollar-quoted string". Not read: 71.
- `code-check-spatial.md` (96 headings): none read. The diff calls no terra, sf or GDAL; the FWA path text in the
  window walk is the annual walk's, held to it line for line by a test, and was not reviewed as new.

## Findings

- **[severity: fragile]** `inst/sql/ch_dist_profile_window.sql:73` and
  `data-raw/chinook_window_evidence.R:108-111` — the HAVING holds the *number of flows* to the number of
  months, not *each month once*. `count(m.q_m3s) = cardinality(months)` is also true for a segment that carries
  one window month twice and another not at all (August twice, no September), and the walk then reads
  `2 * q_aug * w_aug` as the window flow: a window read short, with no sign. The table does not rule that row
  shape out: its primary key is `(scenario, forcing, source, linear_feature_id, month, period)` (read from
  `pg_constraint` on the local database), so one source can hold a month twice under a second `period` or
  `forcing` of `historical`. The evidence script's pre-count has the same form (`n_win <> length(months)` over
  `count(q_m3s) FILTER (month IN (...))`), so it passes the same segment; `.knw_link_flow_window()`'s check
  (`identical(sort(x$month), 0:12)`) does refuse it, but only on the segments it reads.
  - Not reachable on the current load: `historical` holds one period (`1981-2010`), and forcing is one per
    source (`climr` with `wet_balance`, `PNWNAmet` with `pcic_routed`; three segments read, and the forcings
    walked on the key). A whole second period loaded under `historical` is caught everywhere (count 4, not 2:
    the walk passes over every segment, the pre-count and the R check stop). Only the ragged case slips, and
    through the R callers as readily as by a direct call.
  - Closing it: `HAVING count(*) = cardinality(months) AND count(m.q_m3s) = count(*) AND
    count(DISTINCT m.month) = cardinality(months) AND count(DISTINCT m.source) = 1`, and the same
    `count(DISTINCT month)` in the pre-count.
  - **Rule:** code-check.md "A proxy is not the property"
  - INSIDE round 1's fix 2 (the same assumption one step over: rows were counted, now flows are, and neither
    is "every month once").

- **[severity: fragile]** `inst/sql/ch_dist_profile_window.sql:68` — `sum(m.q_m3s * w.wt)` adds the months in
  whatever order the join returns them, so for a window of three or more months `large_mad` depends on row
  order in its last bit. Measured on the local database, window 07-15 to 09-15, picked segments of one group:
  summed by ascending month against descending, 5,164 of 18,504 segments differ (largest relative difference
  2.8e-16). Nothing on this branch is affected: both of its windows take two months, and a two-term sum has
  one order. For a longer window the walk's `large_mad` can differ between a cached row and a fresh walk, or
  between two databases holding one load, which `expect_identical(warm, plain)` in the cache test and any
  md5-held table of walks would then see; a river's `found` could move only at an exact tie with a size.
  `sum(m.q_m3s * w.wt ORDER BY m.month)` fixes the order.
  - **Rule:** code-check-r.md "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it"
  - New (not inside a round 1 fix).

No bug or security finding.

## Round 1's fixes, as checked (no finding unless listed above)

**1. `$` reads on records.** Every `x$name` in both scripts was listed (script, not by eye) and held to the
names the object carries: `knw_tune_run()`'s record (`species_code, stage, response, status, population, smoke,
score, pick, pick_flow, curve, curve_error, null_heldout, null_heldout_curve, grade_withheld`), the score
(`rules, folds, spec, population, boot_recs, honest, seeds`), the smoke result (`rules, checks, pass,
null_insample, null_heldout, lines`), the curve (`heldout`, `data` among 15, no prefix pair), and the columns
of each CSV read with `$`. The three prefix pairs on a record (`pick`/`pick_flow`, `curve`/`curve_error`,
`null_heldout`/`null_heldout_curve`) are read only by `[[ ]]` or by their longer name. `rules`/`ctl`/`rec` are
tibbles (exact match only); `summ`, `tab_pub`, `pub`, `rec` (grade record), `p1`, `win_run` are data frames
whose every `$` name exists exactly (`n_wsg` beside `n_wsg_varies`, `pick` beside `pick_flow`, `walk_md5` beside
`walk`, `boot_rec_share` and `seeds_same_rec` present). None left.

**2. Ways to read a window short.**

| way | walk (SQL) | reachable through R callers |
|---|---|---|
| NULL array, NULL element, two lengths, no month | refused (mutations D and E below go red) | no: `.knw_pg_array()` refuses a missing weight, months are `which(wt > 0)` |
| a month with no row, or a NULL flow | passed over (`count(m.q_m3s)`) | data only; the pre-count stops on it |
| duplicate months in the array | not short: both rows join, the weights add | no: direct call only |
| weights that do not sum to 1 | not checked | no: `.knw_window_weights()` holds the sum to 1e-9; direct call only |
| a month twice on one source in the table, another absent | **read wrong** | yes, were the load ragged: the first finding |
| the whole window twice (a second period) | every segment passed over | yes; the pre-count and `.knw_link_flow_window()` both stop |
| a month picked on two sources | passed over (`count(DISTINCT m.source) = 1`) | data only; the pre-count stops (`n_src`) |
| a NaN flow | counted, and `NaN >= q` is true in Postgres, so the segment is taken with a NaN flow | data only (none in the group probed); the annual walk does the same, and the evidence script refuses a NaN `large_mad` |

`.knw_link_flow_window()` does not count flows, only months: a NULL flow in a window month comes back as an NA
window flow (wet's `mean()` keeps the NA), never a short one, and the evidence script stops on it
(`identical(is.na(win_flow), is.na(vl$mad_pick))`).

**3. The HAVING's test.** Run in a copy against the local database (135 expectations green at HEAD), then
with one guard removed at a time:

| mutation of `ch_dist_profile_window.sql` | suite |
|---|---|
| HAVING deleted | red: "reads no window short", `any(short$status == "found")` is TRUE |
| NULL-element checks deleted | red: the two `"no NULL"` expectations throw no error |
| `IS NULL` array checks deleted | red: the two NULL-array expectations throw no error |
| `count(m.q_m3s)` put back to `count(*)` (round 1's defect) | **green** |
| `count(DISTINCT m.source) = 1` deleted | **green** |

So the test fails for the right reason on a missing month and on each refusal, and pins the HAVING's presence.
It does not pin what its name says about "a month with no flow": a month with no *row* is what it walks, and
the count of flows against rows is held by nothing. That is the accepted limit (the walk reads the live tables
by name; the pre-count is the guard), so it is not listed as a finding; the two-source arm is the same kind and
is likewise untested. One smaller thing: `expect_false(any(short$status == "found"))` would pass on zero rows;
the walk always returns one row per size, so it cannot be vacuous today.

**4. The cache key.** `meta$walk_md5` is one R string used twice: interpolated as `'%6$s'` and bound as `$6`
in the hit query. It holds hex, `|`, digits, `,`, `{}`, `.`, and at most `e-NN`: no quote or backslash, so the
literal is safe and equal to the parameter. `%.17g` names a double uniquely, so two weight vectors cannot share
a key, and months and weights are separate fields. One vector gives one key on any libc that rounds correctly.
What can differ between machines is the vector itself: wet takes a weight as `mean()` of a 0/1 series, and R's
`mean()` refines in `long double`, which is a double on arm64. Measured here for 07-15 to 09-15: weights
`0.26984126984126972, 0.49206349206349204, 0.23809523809523833` against R's own `17/63` and `15/63`,
`0.26984126984126983` and `0.23809523809523808`. An x86 R may give other neighbouring doubles (not measured: both
machines here are arm64), so a cache written on one architecture can miss on the other and be walked again. That
is the safe direction, and the kept rows are right for the weights in their key. Of the branch's own windows,
17/32 and 15/32 are exact on any platform; 31/61 and 30/61 are held to 1e-15 by a test.
By reading, not by mutation: a key without the weights fails the cache test's `kept$walk_md5` expectation, and
a hit query that ignored `walk_md5` fails its "0 of 2 ... read" after the UPDATE.

**The `rule_commit` guard.** Run from a scratch clone, on the script's own lines 50 to 92:

| state of `research/chinook_window_flow.md` | guard |
|---|---|
| as committed | passes, names `267fcd06` |
| a word changed inside the block, committed | refuses |
| the same, uncommitted | refuses (dirty) |
| changed, then changed back, both committed | passes |
| a line added after the block, committed | passes |
| the heading renamed, committed | refuses |

`git log -S` lists a commit where the count of the phrase changes, oldest first with `--reverse`, so a removal
and a re-add list three commits and `[1]` stays the first; the block is then held to that first commit.
`shQuote()` keeps the `#` from the shell, and `git()` reads the status attribute. "Unchanged since" means "reads
as it did at the first commit": a rule changed and restored passes, and a run between the two is refused. A
CRLF file would refuse for ever (`system2()` keeps the `\r`, `readLines()` drops it): the file is LF, and that
is the abort direction. The guard covers the document's block, not the script's own `c1`, `c2`, `c3`, which I
read against the block: they are the three conditions as written.

**Also checked, clean:** `inst/sql/ch_dist_profile.sql` is unchanged on the branch and its md5
(`c3f7bdbe...`) is the grade record's; the window walk's md5 (`53d2c1ff...`) is the evidence run record's;
`devtools::document()` writes nothing; `pkgdown::check_pkgdown()` passes; `test-link_flow.R` passes (7 blocks);
wet is public and at 0.4.39; no test table is left in the database. The rows of the research file's tables that
I checked against `ch_rear_readings.csv`, `ch_rear_pairs.csv` and `ch_rear_verdict.csv` agree at the precision
printed: the verdict table, and the recommended rule's score with and without LFRA, the best rule's score, the
region's size, the nested selection, the seeds on the same rule, the bootstrap share on the rule, and the
curve's score with and without LFRA. The other five rows (nested folds, bootstrap shares by part) were not
checked.

Left behind: a scratch clone and three probe scripts in this session's scratchpad directory, outside the repo.
