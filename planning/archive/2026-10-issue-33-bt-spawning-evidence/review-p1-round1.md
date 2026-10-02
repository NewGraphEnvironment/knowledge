# Review — #33 Phase 1, round 1 (scripts/0293, its CSV and log, findings.md Phase 1)

Reviewer probes ran on copies (`head.R` = lines 1-133 of 0293, sourced from the scratchpad) and on read-only
fwapg queries. No repo file other than this one was touched.

## Code: verified correct

- **Kind assignment and strongest-kind order.** `case_when` order matches the spec; NA `maturity_code`
  and NA month fall through correctly (`M` with NA month -> "M other months", as in 0240). `kinds[min(match())]`
  picks the strongest. Visits by kind sum to 1,363 = every visit with BT fish rows; none of them has U = 0.
- **n_coded** counts IM/M/MT/SP/ST. `SB` exists in fish.rds (248 rows) but never on a BT/DV fish in these
  visits, so it costs nothing.
- **S / S_large / S_small.** No spawner fish has NA length (313 spawner fish, 0 NA), so the `!is.na(length_mm)`
  in S_small excludes nothing here; 8 of 119 evidence visits carry both a large and a small spawner, none neither.
- **Population filter, assert.** v has no duplicate `site_visit`; all 119 evidence visits fall in `pop`
  (26+25+14+22+13+19 = 119); 14,463 = sum of the bt_caught cells = #28's population. The 0240 assert is a real
  set comparison on the same pooling rule as 0290.
- **month_f with one level.** `august_only` drops it; in Sep-Oct the modelled set has months 9 (178) and 10 (11)
  in 10 of 108 streams, so a resample missing month 10 (which would error -> NA) has probability ~3e-5.
- **rate_ratio reference.** Count-weighted mean of the three ref classes on the modelled data; a resample that
  loses class 0-2 returns all NA (the ref terms become NA), not a mis-based ratio. Point estimates reproduce
  (S: 1.098 / 1.038 / 0.745 / 1.215 / 0.943 / 1.142).
- **Bootstrap.** Picks drawn in the master after `set.seed`, so deterministic; workers get every helper they call.
- **Patch SQL.** `fwa_upstream(blk_a, drm_a, wsc_a, loc_a, blk_b, drm_b, wsc_b, loc_b, include_equivalents, tolerance)`
  matches the installed 10-arg signature (a = site segment, b = candidate: "b upstream of a"). Run grouping by
  `drm > lag(urm) + 1` within (site_visit, blue_line_key) splits on any non-qualifying gap. `HAVING sum >= 200`
  is per run. Same-blue-line distance and the 10 km cut are correct; the search anchor is the segment's drm and
  the distance anchor the site measure, which differ by < 1.1 m here.
- **Many-to-many join** is in fact one-to-many (site_visit unique in `steep_large`); harmless.
- **Same-WSG restriction is not a real limit for the four no-patch visits.** Queried against
  `whse_basemapping.fwa_stream_networks_sp` with no WSG filter: 0 upstream FWA segments outside their WSG for
  KOTL, UFRA, COTR and PARS. Their whole upstream channel is small: PARS 351 m, COTR 1,747 m, UFRA 8,359 m,
  KOTL 86 km (KOTL has 819 m at <= 5.49 % upstream, 282 m of it with NULL width, none in a qualifying 200 m run).

## Findings

### F1 (real, data). Duplicate visits inflate the evidence counts, including one of the 7 SP/ST visits
`46561_76_1` and `76685_76_1` (BBAR) are the same survey twice: same UTM 547185/5675457, same date 1999-09-28,
same agency, 600 m2, and the same single 560 mm ST BT. Both are in S, S_large, the 5.49-8 cell, the steep-large
table and the "6 on the same blue line".
Across `pop`, keying on UTM + date + area + per-visit fish signature: **4 pairs among the 119 evidence visits**
(6938_9_1/85846_9_1, 6933_3_1/85841_3_1, 6931_1_1/85839_1_1, the BBAR pair). In the whole visit table, 876 of
14,463 visits share that key with another (300 with fish rows, 99 BT visits).
This is upstream of 0293 (0230/0290 build; #28's table has it too), so file it rather than patch here, but the
Phase 1 text should not count the BBAR pair as two visits: "11 large spawners on steep segments" is 10 distinct
surveys, "6 on the same blue line" is 5, SP/ST visits is likely 6.

### F2 (real, overclaim). "The raw rise is explained by where and how sampling was done"
Probe on the 485 modelled visits:
- the raw rise survives, and grows, in the modelled subset: 0.174 / 0.216 / 0.187 / 0.323 / 0.342 / 0.422
  (the 75 dropped visits are 2 detections in 75);
- `S ~ cls` alone: 0.90 / 1.14 / 0.97 / 1.83 / 1.97 / 2.58;
- `S ~ cls + log_coded`: 0.88 / 1.18 / 0.98 / 1.86 / 1.99 / 2.67 (coding effort does not remove it);
- `S ~ cls + wsg`: 1.13 / 1.01 / 0.72 / 1.19 / 1.01 / 0.99 (WSG alone removes it).
So "how" (coding, month) does not explain it; it is a between-WSG pattern. And WSG fixed effects absorbing it is
not the same as sampling explaining it: steep-terrain WSGs may simply hold more spawning (e.g. resident)
populations. Supportable wording: "the rise is between WSGs; within WSGs no gradient effect is detectable, and the
intervals do not exclude one." A one-df trend term within the full model agrees (p = 0.84).

### F3 (real, overclaim). The "Read" conjunction rests on 7 visits that no log line shows
"mature, mostly small BT in streams narrower than 2 m and steeper than 5.49 %" — evidence visits that are both
< 2 m and > 5.49 %: **7** (5 small, 2 large). "Evidence exists below 2 m, mostly small fish": 8 of 10 small. Neither
figure is in the log (AC1), and "mature" includes M in August, which A1 says mixes migration with spawning.
"Fits resident spawning" should be "consistent with resident spawning, on 7 visits", or the log should carry the
joint cell.

### F4 (real, spec/code mismatch). Header says patches are searched "within 10 km of channel"; the code is unbounded
The SQL has no distance limit: `patches_upstream` counts every qualifying run upstream in the WSG; only
`same_blue_line_m` is cut at 10 km. findings.md's wording ("no patch upstream within their WSG") matches the code,
so fix the header (or bound the SQL) so the spec says what ran.

### F5 (minor, label). FISS block and findings say the gradient is a fraction, but the printed column is FWA percent
The log prints `fwa_gradient_pct` (0.90, 1.32, 0.56, 3.84 — percent, correct); the fraction column is
`gradient_pct` (0.015, 0.025, NA, NA), which is not printed. "(gradient_pct is a fraction here, #34)" and
findings' "Their gradient is a fraction (#34)" read as though the shown values are fractions.

### F6 (minor). Traceability (AC1)
"Timberland, Kokanee: 38 of 119 evidence visits" — 20 + 18 = 38 verified by probe, but only the names are in the
log; the 38 comes from the plan review.

### F7 (minor). Small inconsistencies, no effect on the reported numbers
- "adult size only" requires `is.na(maturity_code)`; 9 Aug-Oct BT >= 350 mm coded `U` (unknown) fall to "none".
  Spec says "no maturity code". Descriptive kind only.
- `power` is computed on all visits in the cell (`d`), while the ratio and interval use the modelled subset (`dm`).
  No cell flips on this run (e.g. S 8-10.49 is 38 visits / 13 detections modelled), but the label describes a
  different population from the estimate beside it.
- "Sensitivities scatter around 1 with no consistent direction" is on point estimates with no intervals, ranging
  0.34 (August only, 2-4) to 1.90 (site gradient, 5.49-8); say "point estimates" so the spread is not read as a test.

## Number enumeration — findings.md Phase 1 vs log / CSV

| # | Claim in findings.md | Source value | Verdict |
|---|---|---|---|
| 1 | md5 b32e5262…e04d | log l.1 | match |
| 2 | Fish by kind: M Aug 191, M Sep-Oct 110, M other 27, SP/ST 12, adult size only 347, none 7,292 | log l.5-10 | match |
| 3 | Visits by strongest kind: 63 / 49 / 25 / 7 / 75 | log l.14-18 | match (SP/ST 7 includes the BBAR duplicate, F1) |
| 4 | Spawner flag reproduces 0240 on 119 visits | log l.20 | match (4 duplicate pairs inside, F1) |
| 5 | Coded share 0.27 at 0-2 vs 0.40-0.45 steeper | log 0.267; 0.396-0.452 | match (rounded) |
| 6 | S population 560 | log l.21 | match |
| 7 | 485 modelled in 23 WSGs | log l.32 | match |
| 8 | Raw S 0.146 / 0.188 / 0.182 / 0.293 / 0.302 / 0.352 | CSV | match |
| 9 | Each class >= 30 visits and >= 10 detections | CSV power = ok for all six S cells | match |
| 10 | Adjusted 1.10 / 1.04 / 0.75 / 1.22 / 0.94 / 1.14 | CSV 1.098 … 1.142 | match |
| 11 | Intervals roughly 0.2-3.6, some lower bounds 0 | CSV lo 0-0.583, hi 1.284-3.625 | match (loose; 0-2 is 0.58-1.68) |
| 12 | Top two agencies Timberland, Kokanee: 38 of 119 | log names only; 38 by probe | names match; 38 not in log (F6) |
| 13 | Large spawners 8 / 9 / 6 / 5 / 3 / 3 | CSV | match (5.49-8 includes BBAR pair, F1) |
| 14 | Small spawners 18 / 19 / 11 / 17 / 11 / 17 | CSV | match |
| 15 | Small raw 0.10 -> 0.32 | CSV 0.101 … 0.315 | match |
| 16 | Small adjusted 0.80-1.43 | CSV 0.801-1.426 | match |
| 17 | Sep-Oct underpowered from 4-5.49 up | CSV | match |
| 18 | U: 0.90 / 1.17 / 1.04 / 0.80 / 0.75 / 0.59 | CSV 0.902 … 0.593 | match |
| 19 | < 2 m: 7 of 41 field, 3 of 17 modelled | log l.119, 124 | match |
| 20 | Highest rate 5-10 m, 0.35 both sources | log 0.349 / 0.348 | match |
| 21 | Below 2 m "mostly small fish" | not in log; probe 8 of 10 small | untraceable (F3) |
| 22 | 11 large spawners on steep segments | log l.130 | match (10 distinct surveys, F1) |
| 23 | 4 no patch: KOTL 11.1, UFRA 15.7, COTR 10.2, PARS 11.0 % | log 0.1106 / 0.1566 / 0.1023 / 0.1097 | match |
| 24 | 6 on same blue line, 780-5,394 m | log 989, 5394, 1993, 4298, 1993, 780 | match (5 distinct, F1) |
| 25 | 1 (CLRH) with patches, none on its blue line within 10 km | log l.136, l.148 | match |
| 26 | FISS 4 char spawner rows (UPCE, MURR, LNTH x2) | log l.160-163 | match; "fraction" label wrong for the shown column (F5) |
| 27 | Read: "narrower than 2 m and steeper than 5.49 %" | not in log; probe 7 visits | untraceable (F3) |

## Verdict
Code is correct. Four real items: F1 (duplicate surveys in the evidence counts, upstream defect to file and
disclose), F2 and F3 (claims stronger than the evidence), F4 (spec header does not describe the SQL). F5-F7 minor.
