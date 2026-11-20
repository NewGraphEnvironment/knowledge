# One discharge per FWA segment: is it fine enough to tune on?

**Verified:** 2026-11-20 · **Issues:** #137 (the question), #23 (where a record sits), move 6 (#175) ·
**Produced by:** `data-raw/segment_flow_resolution_check.R` (`scripts/logs/flow/20261119_segment_flow_resolution_check.txt`),
on the published evidence (link run `20261102_203300-60ab009d`, `visits_link.csv` `c746c582…`) and wet's flow load of
2026-10-24; where a record sits from `data-raw/fdis_downstream_end_check.R`
(`scripts/logs/fdis/20261119_fdis_downstream_end_check.txt`, `research/fdis_export.md`) · **Status:** answered: yes,
at the sizes the habitat definitions use; no point flow is needed.

## The answer

Every Freshwater Atlas segment carries one annual flow, and link and the tuning read that one value wherever a fish
record sits on the segment. Water does gather along a segment, but at the sizes the habitat definitions are drawn at it
gathers little: on single-line streams of 0.1 to 1 m³/s, a segment's flow at its top is typically within 1 % of its
bottom's. At the published fish records, reading flow at the record's own point, or at the middle of the stretch the
crew fished, instead of the segment's value, changes which side of a key's minimum flow a visit falls on for 0.15 to
2.7 % of visits. Choosing the other of wet's two flow sources changes it for 2.8 to 8.7 %, between three and nineteen
times as many for each key.
The error a segment's single value adds is small beside the error already in the modelled flow, so there is nothing to
gain yet from giving flow at a point.

## How flow grows along a segment

Flow at a point on a stream comes from the land that drains to it. Between two tributary mouths a stream gathers only
its own local area, both banks, so its flow rises gently and evenly; at a tributary's mouth it jumps. The Atlas starts
a new segment at every confluence (#137 found none of BULK's 10,387 tributary mouths partway along a segment), so the
jumps fall between segments, and within one only the local area adds.

The check measures that local gain. A reach is the segments of one blue line that share a watershed code and a local
code, the stretch between two mouths. Every fundamental watershed with those codes drains to it, and fwapg's upstream
area of any of them is the area at the reach's foot. Along the reach the area is taken to fall evenly by measure, to
that less the reach's own local area at its head; flow is taken to scale with area. A segment's fall is the share by
which that area-scaled flow is lower at its top than at its bottom. Side channels (`blue_line_key` other than
`watershed_key`, 247,517 segments) share their main stem's codes and are left out; 4,659,924 segments form reaches.

| edges | flow class (m³/s) | segments | median fall | 90th percentile | over 10 % |
|---|---|---:|---:|---:|---:|
| single-line stream | under 0.1 | 2,832,294 | 74 % | 100 % | 73 % |
| single-line stream | 0.1 to 1 | 455,171 | 0.85 % | 15 % | 13 % |
| single-line stream | 1 to 10 | 134,134 | 0.13 % | 1.6 % | 0.9 % |
| double-line river | 0.1 to 1 | 32,279 | 0.18 % | 2.8 % | 3.0 % |
| double-line river | 1 to 10 | 80,279 | 0.04 % | 0.42 % | 0.08 % |

Streams under 0.1 m³/s are headwaters: the reach's head is the stream's source, where its area, and so its modelled
flow, runs to nothing, so most of their segments fall by most of their flow. They lie below every key's minimum but
westslope cutthroat's (0.03 m³/s). Lake and wetland skeletons behave alike by flow class (the log has them); a lake's
flow is really set at its outlet, which this measure does not try to model.

## How far a record sits from where its fish were

A bcfishobs record matched to an FDIS visit lies at the visit's own point: 58 % carry the visit's UTM, and of the rest
81 % lie within 5 m of its point on its stream (`research/fdis_export.md`, "The site span"). That point is usually the
site's downstream end, and the fish came from anywhere along the fished stretch above it: a median 100 m, 200 m at the
upper quartile and 950 m at the 90th percentile for matched visits. That stretch, not the record's point, is the
location error the evidence carries.

## The two errors side by side

Of the 45,503 published visits whose flow is their own segment's (26 take a parent's), 41,883 have an area at both
ends of a fished span:

| visits on | visits | segment fall, median (p90) | fall over the fished span, median (p90) | span fall over 10 % | the two sources differ by, median (p90) |
|---|---:|---:|---:|---:|---:|
| single-line streams | 31,605 | 7.4 % (91 %) | 2.6 % (33 %) | 27 % | ×1.34 (×3.4) |
| double-line rivers | 9,414 | 0.01 % (0.6 %) | 0.01 % (1.0 %) | 4.6 % | ×1.10 (×1.7) |

Wet's pick is off its gauges by 23 % on average (annual mean absolute error, `research/modelled_discharge.md`). The flow
gathered over a fished span is a ninth of that at the median, and the two sources part by more than the span gathers,
at the median and at the 90th percentile alike.

Read against the published minimum flows (every key's `rear_mad_min` in `data/thresholds.csv`), over the 37,834
visits with an area at both the point and the span's middle:

| key | minimum flow (m³/s) | visits within a factor of 2 of it | class changes at the record's point | at the span's middle | with the other source |
|---|---:|---:|---:|---:|---:|
| CH rearing | 0.75 | 4,791 | 0.15 % | 0.29 % | 2.8 % |
| ST rearing | 0.50 | 5,088 | 0.19 % | 0.34 % | 3.0 % |
| BT rearing | 0.35 | 5,555 | 0.27 % | 0.49 % | 3.6 % |
| CO rearing | 0.10 | 7,607 | 1.3 % | 1.8 % | 6.7 % |
| WCT rearing | 0.03 | 7,342 | 2.0 % | 2.7 % | 8.7 % |

The smaller the minimum, the more a point flow would move, because small streams gather a larger share of their flow
along each segment; even at westslope cutthroat's 0.03 m³/s it moves a quarter to a third as many visits as the source choice.

## What this does not say

- **The segment's value is taken as its bottom's.** Where wet's value stands for a point higher on the segment, a
  record near the bottom would read higher, not lower: the shares above bound the change in one direction, and the
  error either way is no larger than the segment's fall.
- **Area is spread evenly along a reach.** Local area enters where side streams too small for the Atlas come in, not
  evenly; a check against `fwa_watershedatmeasure()` at a few points would test it.
- **Mean annual flow only.** A seasonal window (#105, #226) gathers along a segment by the same area share.
- **Counts are over every placed visit,** not each key's scoring population (its range, its groups with both outcomes);
  they size the effect, they do not regrade anything.
- The near-river exception reads the flow of the river a walk reaches, not the visit's own segment, and is not counted
  here; its rivers are 1 m³/s and up, where a single-line segment's median gain is 0.13 % and a double-line river's 0.04 %.
