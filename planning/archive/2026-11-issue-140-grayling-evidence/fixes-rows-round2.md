# Round-2 row fixes (#140), applied 2026-11-26

All 9 findings of `audit-rows-round2.md` accepted after reading the pages (findings 2, 3, 4 and 8 probed in the
source text first). Only the named fields of the named rows changed; every other line of the table is byte-identical.

| finding | data row | change |
|---|---|---|
| 1 | 1216 | `bound` blank: selection against wide channels is an interior breakpoint, not a limit |
| 2 | 1260 | note: fry reached km 29, 2 km into reach 3 (1-2 %); habitat-use sites at km 10 and 22.5 |
| 3 | 1262 | note keeps "may be" and "an assumption still to be verified"; names the shallow low-velocity glides |
| 4 | 1267 | note: yearlings and older, adults included (section 4.5.2), not all ages; "low-gradient creek" removed |
| 5 | 1266 | note: adults among the yearlings and older; 0+ to 3 years in the upper reaches |
| 6 | 1256 | note keeps "generally" |
| 7 | 1277 | note keeps "approximately", the gauge timing and the conditional "would be minimal" |
| 8 | 1283 | note keeps "apparently" |
| 9 | 1201 | `bound` blank: two group means, not two limits |

The life fixer's candidate rows (`fixes-life-round1.md`) are already rows (1201, 1231, 1237, 1241, 1258, 1286,
1288, 1292, 1297, 1300 and their siblings), except two that fill no grid cell and are left out: adults' channel width
(10 m, selection against < 6 m; the vocabulary has no adult stage, and row 1216's note carries it) and Stewart et al.
2007's Cache Creek overwintering depth.
