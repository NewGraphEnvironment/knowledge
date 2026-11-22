# The window walk's guards, enumerated (#233, review rounds 1 and 2)

Round 1 found the window walk's month check counted rows where it meant flows; round 2 found, inside that fix, that
it held the number of flows to the number of months and not each month once. Two rounds, one mechanism: **a count
standing in for "each month of the window, once, with a flow, on one source"** (`code-check.md`, "A proxy is not the
property"). So the loop ends on the set that mechanism reaches, not on a quiet round.

## The set: every way a window's flow can be wrong at a segment, and what stops it

The window's flow is `sum(q * weight)` over the rows of one segment that match the window's months on the source.
It is right only if the arguments are a window's (months and their shares) and the rows are exactly one flow per
month on one source. Each way either can fail, with the guard and how the guard is proved:

| # | the way | the guard | proved by |
|---|---|---|---|
| 1 | `months` or `weights` is NULL | refused (`IS NULL`) | "reads no window short", two expectations; mutation below |
| 2 | a NULL month or weight inside an array | refused (`array_position(…, NULL)`) | the same test, two expectations; mutation |
| 3 | the arrays differ in length | refused | the same test; mutation |
| 4 | no month at all | refused | the same test; mutation |
| 5 | a month named twice | refused ("must not repeat a month") | the same test; mutation |
| 6 | weights that are not a window's shares (not positive, or not summing to 1) | refused | the same test, two expectations; two mutations |
| 7 | the segment has no row for a month | passed over: fewer flows than months | fixture segment 60; live test with month 13; mutation |
| 8 | a month's flow is NULL | passed over: flows are counted, not rows | fixture segment 50; mutation (`count(*)`) |
| 9 | a month twice and another absent | passed over: each month once | fixture segment 40; mutation |
| 10 | a month twice, every month present | passed over: more flows than months | fixture segment 30, which the unmutated walk passes; the count's mutation goes red at segment 50, nearer, so no mutation isolates this one |
| 11 | the window's months picked on two sources | passed over: one source | fixture segment 20; mutation |
| 12 | the whole window twice (a second period) | passed over, by 10 | the evidence pre-count stops first |
| 13 | a flow that is not a number | **not guarded in the walk**, on purpose: the annual walk takes it too, and the window walk is that walk but for the flow it reads. The evidence pre-count stops on one, and the evidence script refuses a river whose flow is not a number | `data-raw/chinook_window_evidence.R` |
| 14 | the sum's last bit depending on row order (three months or more) | `ORDER BY m.month` inside the sum | by reading: this branch's windows take two months, where the order cannot matter |

The same three row conditions (as many flows as months, each month once, one source) are counted over the whole
load by the evidence script before any walk: 4,532,843 picked segments, none failing.
`.knw_link_flow_window()` holds its own read to months 0 to 12 once each on one source, and its window flow to be
present where MAD is.

## The mutation table

Each guard removed in turn from the file, `tests/testthat/test-link_walks.R` run against the database, the file
restored (md5 `9c4dcfc9…` before and after). Unmutated, all 15 tests pass.

| guard removed from `inst/sql/ch_dist_profile_window.sql` | tests red, of 15 | the test that fails |
|---|---|---|
| none (the file as committed) | 0 |  |
| HAVING deleted | 2 | "reads no window short"; "on a line of malformed segments" |
| flows counted as rows: count(m.q_m3s) -> count(*) | 1 | "on a line of malformed segments" |
| count of flows deleted | 1 | "on a line of malformed segments" |
| each month once deleted | 1 | "on a line of malformed segments" |
| one source deleted | 1 | "on a line of malformed segments" |
| NULL array check deleted | 1 | "reads no window short" |
| NULL element check deleted | 1 | "reads no window short" |
| length check deleted | 1 | "reads no window short" |
| empty check deleted | 1 | "reads no window short" |
| repeated month check deleted | 1 | "reads no window short" |
| weights check deleted | 1 | "reads no window short" |
| weights' sum check deleted | 1 | "reads no window short" |
| weights positive check deleted | 1 | "reads no window short" |
| the window's flow read back as the annual flow | 3 | "reads no window short"; "on a line of malformed segments"; "finds rivers by their window flow" |

Nothing in the set sits above its guard except 13, which is the annual walk's behaviour kept, and 14, which no test
of two months can reach.
