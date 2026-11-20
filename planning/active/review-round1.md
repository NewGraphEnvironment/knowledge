# Code-check round 1: branch 175-backlog-move-6-where-records-sit-the-sit (76b304ff...HEAD)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables skipped).
- code-check-r.md: headings read: "Postgres row order is never fixed unless the query fixes it...", "A `data-raw/` script
  must load the source tree, not the installed package", "`ifelse()` with an all-NA test returns a logical vector...",
  "`match()` treats NA as a matchable VALUE...", "`identical()` on two reader results tests the reader, not the file".
  The rest (~150 headings) not read: they name tools or shapes this diff does not use.
- code-check-shell.md: no headings read (the diff has no shell code).
- code-check-spatial.md: no headings read (the diff's spatial work is FWA measures and SQL, none of the indexed traps).

## Findings

- **[severity: bug]** data-raw/segment_flow_resolution_check.R:180 (`area_at()`) — `findInterval(m[i], r$m_bot,
  rightmost.closed = TRUE)` treats the last breakpoint as the right end of the previous interval, so a measure equal
  to the last reach's `m_bot` is put in the wrong reach. Measured with the function copied verbatim on a toy reach
  table (scratchpad `area_toy.R`):
  - on a blue line with one reach (no tributary), `findInterval(0, 0, rightmost.closed = TRUE)` is `0`, so the area at
    the line's foot is `NA`. Every visit on the lowest segment of such a line (`m0` = the reach's `m_bot`) gets
    `a_seg_bot = NA`, and with it `fall_segment`, `q_point` and `q_mid`.
  - on a line with several reaches, the foot of the top reach falls in the reach below. `a_seg_bot` then reads that
    reach's head (`up_ha - local_ha`), which includes the tributary joining at that mouth: in the toy 220 ha, not
    120 ha. `fall_segment` comes out too large and `q_point` / `q_mid` too small, so flips appear that are not real.

  This shows in the committed log: 42,059 visits have a span (`a_span_top`), but Q3 counts only 37,834. That filter
  also needs `a_seg_bot`, and outside this defect `a_seg_bot` is NA only where `a_point` is NA too. So about 4,200
  visits, mostly the bottom segments of unbranched (small) streams, are dropped from Q3 and from Q2's segment-fall
  quantiles (which use `na.rm`). The visits on the top reach's first segment that stay in are scored against an
  inflated bottom area. So `research/discharge_resolution.md`'s Q2 "segment fall" column, its whole Q3 table (and the
  "0.15 to 2.7 %", "three and nineteen times" and "a quarter to a third" sentences built on it) and its "37,834 visits
  with an area at both the point and the span's middle" are wrong numbers, not a bound. Q1 (SQL) is not affected. Fix:
  the default `rightmost.closed = FALSE`. The `m > m_top + 1e-3` test already refuses a measure past the last reach,
  and with the default a measure at the line's top still lands in the last reach. Then rerun and redo the write-up.
  - **Rule:** none

- **[severity: fragile]** CLAUDE.md:59, R/archive.R:21-22, scripts/0336-archive.R:29-30, scripts/0240-fdis-evidence.R:159-161
  and 170-171 — each gives "rerun 0230" as the way to get `fish.rds` (a build archived before #214) or the passes (a
  restored build). But 0230 writes `fish.rds`, `passes.rds` and `pass_catch.rds` only at its end (lines 640-645),
  after placement. It connects to the database and stops if none is reachable (line 476). In the same pass it rewrites
  `sites.rds` and `reconcile.csv` with a placement that does not reproduce (#246: 245 of 51,587 visits move).
  - On a checkout holding a restored published build, the remedy overwrites the published `sites.rds`. The archive,
    `fdis_downstream_end_check.R` and the methodology bundle's md5 pins then refuse it, and `0336 PULL=TRUE` refuses to
    restore over it ("here with another md5").
  - This contradicts CLAUDE.md:313-314 ("Restore the published placement with `0336 PULL=TRUE`, never by rerunning
    `0230`").
  - 0240's comment "0230 rebuilds them from the export before placement, reading no database" is false for the script
    as run: the passes are computed before placement but written after it.

  The remedy has to say: rerun 0230 on a database, then put the published `sites.rds` and `reconcile.csv` back (what
  findings.md records doing by hand on m1). Better, give 0230 a mode that writes only the placement-free files.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0240-fdis-evidence.R:163-172 with scripts/0299-fdis-publish.R:112-121 — when
  `passes.rds` is absent, 0240 only prints a message. It leaves any earlier `fdis_passes.csv` / `fdis_pass_catch.csv`
  in `data/fdis/derived`, and 0299 checks only that the files exist, never that they are the passes of the
  `fdis_sites.csv` beside them (0240's `setequal` check runs only when it rewrites them). So v3 can publish passes from
  an earlier build or code next to a newer site table, and nothing refuses.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: fragile]** research/discharge_resolution.md:33-34 — "4,659,924 segments form reaches". That number is
  the count of segments on their own blue line (the log's `own`). The Q1 table the paragraph introduces sums to
  4,425,507 segments: 234,417 own-line segments drop out at the join (null codes, `m_top <= m_bot`, `up_ha = 0`, no
  polygon). The sentence names one population and the table another.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** research/fdis_export.md:251-252 — "on the visit's blue line 81 % of them still lie within
  5 m of its point, 9 % below it, 6 % inside its span and 2 % above it" leaves out the log's "above the point, no
  span" class (194 records, 2.1 %). The listed shares add to 98 %. If "2 % above it" means above the point, the log
  gives 3.8 % (194 + 159).
  - **Rule:** none

- **[severity: fragile]** data/fdis_README.md:35-37 — the public README now sends readers to
  `knowledge/fdis/v3/manifest.json` and describes v3's tables, but v3 is not uploaded (CLAUDE.md: v2 is the newest
  published set). 0299 uploads this file as `s3://fresh-bc/fdis/README.md` on every publish (line 249), a v2
  republish included. Until v3 is out, the file on GitHub, and any README a v2 publish uploads, links a manifest that
  does not exist.
  - **Rule:** none

## Checked and found correct

Every other number in research/discharge_resolution.md and research/fdis_export.md against the two logs: Q1 table, the
Q2 table, 247,517 side channels, the 41,883 total, 26 parent-flow visits (from the published `visits_link.csv`, md5
`c746c582…`), match counts and the 60,098 denominator, UTM shares, fished-length quantiles. Also checked:

- `knw_fdis_passes()` against 0230's visit roll-up rule.
- 0230's pass checks.
- The archive's `md5_fish` gate: every `*_evidence_build_ledger*.csv` records `md5_fish`.
- The receipt table count (13).
- Issue numbers #23, #137, #214, #225, #226, #231, #245, #246: each title matches the work.
