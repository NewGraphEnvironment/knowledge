# The window walk's guards, enumerated (#233, review rounds 1 to 3)

Three rounds each found the window walk's month condition letting a malformed segment through:

- round 1: it counted rows where it meant flows, so a NULL flow read a window short;
- round 2, inside that fix: it held the number of flows to the number of months, not each month once;
- round 3, inside that fix: its counts ranged over different rows (flows for two of them, every row for the other
  two), so a segment breaking two conditions at once (August twice with flows, September present with no flow)
  passed, and the fixture of round 2 could not see it, because each of its segments broke one condition.

**The mechanism** (round 3's words, checked): a summary of a set accepted where the property is about its members.
The property is a one-to-one match between the window's months and the segment's rows on the source: each month,
one row, with a flow, on one source. So the loop ends on the whole population of row shapes, not on a list of
shapes somebody thought of, and not on a quiet round.

## The condition now

```
HAVING count(*) = cardinality(months) AND count(m.q_m3s) = cardinality(months)
   AND count(DISTINCT m.month) = cardinality(months) AND count(DISTINCT m.source) = 1
```

As many rows as months, every row with a flow, every month distinct, one source: together, a one-to-one match.

## The row shapes: all 225, and the walk takes exactly the 2 whole ones

`test-link_walks.R`, "of every shape a two-month window's rows can take": a month's rows are none, one or two, each
with a flow or without, on source a or b. That is 15 shapes a month (1 + 4 + 10) and 225 segments for a window of
two months, each alone on its own line. A segment is whole when each month has one row, with a flow, both on one
source: 2 of the 225. The test runs the walk's own text (its two table names and its name swapped) from each line
and requires `found` on those 2 and on no other, at the weighted flow.

- Three rows or more in a month fail `count(*) = cardinality(months)` as two do.
- A second `period` or `forcing` is two rows for one month and source: among the 225.
- Before round 3's fix the same population took 16 segments, 14 of them malformed (round 3's measurement).

## The arguments

| the way | the guard | proved by |
|---|---|---|
| `months` or `weights` is NULL | refused | "reads no window short"; mutation |
| a NULL month or weight | refused | the same test; mutation |
| the arrays differ in length | refused | the same test; mutation |
| no month at all | refused | the same test; mutation |
| a month named twice | refused | the same test; mutation |
| a weight of zero or less | refused | the same test, three expectations; two mutations |
| weights that do not sum to 1 | refused | the same test; mutation |

## Not guarded in the walk, on purpose

- **A flow that is not a finite number** (NaN, or infinite): the annual walk takes it too, and the window walk is
  that walk but for the flow it reads. The evidence script's pre-count stops on one anywhere among the picked rows
  of the window's months and the annual flow, and it refuses a visit's window flow or a found river's flow that is
  not finite.
- **The sum's last bit depending on row order** for three months or more: `ORDER BY m.month` inside the sum fixes
  the order; no test of two months can show it, and its mutation below stays green.

## The same condition elsewhere

- `data-raw/chinook_window_evidence.R` counts, over every picked segment of the load before any walk, the segments
  that fail the same four counts on the window's months, or the annual flow's: 4,532,843 segments, none.
- `.knw_link_flow_window()` requires months 0 to 12 once each on one source for every segment it reads, and a
  missing flow comes back `NA`, which its caller holds to "present exactly where MAD is".

## The mutation table

Each clause removed or weakened in turn in the file, `tests/testthat/test-link_walks.R` run against the database,
the file restored (md5 `35cd4ee5…` before and after).

| changed in `inst/sql/ch_dist_profile_window.sql` | tests red, of 16 | the tests that fail |
|---|---|---|
| none (the file as it is) | 0 |  |
| HAVING deleted | 3 | "reads no window short"; "on a line of malformed segments"; "of every shape" |
| rows = months deleted | 2 | "on a line of malformed segments"; "of every shape" |
| rows = months weakened to >= | 2 | "on a line of malformed segments"; "of every shape" |
| flows = months deleted | 2 | "on a line of malformed segments"; "of every shape" |
| flows = months weakened to >= | 0 |  |
| each month distinct deleted | 2 | "on a line of malformed segments"; "of every shape" |
| one source deleted | 2 | "on a line of malformed segments"; "of every shape" |
| NULL array check deleted | 1 | "reads no window short" |
| NULL element check deleted | 1 | "reads no window short" |
| length check deleted | 1 | "reads no window short" |
| empty check deleted | 1 | "reads no window short" |
| repeated month check deleted | 1 | "reads no window short" |
| weights check deleted | 1 | "reads no window short" |
| weights' sum check deleted | 1 | "reads no window short" |
| weights positive check deleted | 1 | "reads no window short" |
| a zero weight allowed: x <= 0 -> x < 0 | 1 | "reads no window short" |
| the window's flow read back as the annual flow | 4 | "reads no window short"; "on a line of malformed segments"; "of every shape"; "finds rivers by their window flow" |
| the sum's order deleted | 0 |  |

Two rows stay green, and neither is a gap. With rows held equal to months, flows cannot exceed rows, so `>=` on the
flows is the same condition as `=`. The sum's order is the one named above.
