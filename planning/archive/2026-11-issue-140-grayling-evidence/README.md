# #140: grayling, the literature and where grayling were caught, as the evidence for link's default

## Outcome

Gathered the evidence a grayling baseline in link's `default` can stand on, and proposed no value (#280 does that).
The issue was split at its gate (Al, 2026-11-26): the proposal, the baselines register and the retune went to #280, and
the FISS workbook records to #281 at the plan review, because `0250` keeps no grayling. Al then chose to source here the
originals the reviews relied on: 14 were sourced (12 PDFs from EcoCat, ARLIS and ERA; Hawkshaw et al. 2013 abstract-only;
Northcote 1995 filed with neither PDF nor abstract) and filed through `0270`, and `bull_trout_grayling` was rebuilt on m1
and pushed. The evidence table gained 115 grayling rows (data rows 1190-1304; the table held 30, none on gradient,
width or MAD), `research/grayling_life_history.md` quotes 245 passages, `data-raw/grayling_use.R` writes the capture
tables (`data/gr_use.csv`) on the tuning's own grayling rearing population, `data-raw/grayling_segments.R` reads Hagen et
al. 2026's critical-habitat segments on the Atlas, and `research/grayling_habitat.md` says what each source shows about
link's six values. What was learned: no source sets a gradient, width or flow value as a limit for grayling; the catch
rate does not fall at link's gradient values, only above 5.49 %; it is lowest under 2 m and under 0.021 m³/s, where
few visits caught any fish; and most grayling, and nearly all the critical-habitat length, are in large rivers the
stream rules leave out. The gate run found that #217's replacement of three OCR scans broke 42 older evidence rows
(#282).

## Measurement

| what | number |
|---|---|
| grayling evidence rows | 115 (65 drafted, 7 re-quoted from originals, 50 added from them); all verify in `0280` |
| life-history quotes | 245 (218 text, 27 OCR); all verify |
| row meaning audit, rounds 1-4 | 14, 9, 6, 4 findings (all accepted), most later ones inside earlier fixes |
| life-history audit, rounds 1-3 | 32, 29, 6 |
| write-up audit, rounds 1-3 | 17, 18, 10; the third round's fixes checked by hand against `data/gr_use.csv` and the rows |
| code-check, rounds 1-5 | 5, 2, 5, 3, 1; one mechanism, a summary over rows that are not the units it names; ended by enumeration |
| capture population | 1,580 visits in 45 groups, 229 with grayling, of 11,567 range visits (1,231 with grayling, 882 of them in river polygons) |
| capture rate ratios (against 1-2 %, 4-8 m, 0.2-0.5 m³/s) | every gradient class to 5.49 % holds 1; 5.49-8 % 2 of 152 visits; < 2 m 0.26-0.35; 2-4 m 0.62; < 0.021 m³/s 0.31 |
| Hagen et al.'s segments on the Atlas | 1,726 km after lakes and connectors; 93 % river polygon, median MAD 30 m³/s, over 99 % under 2.49 % |
| `bull_trout_grayling` store | 197 → 208 documents, md5 `a961692d…` verified on pull |
| agents | 22: plan review 1, drafters 2, sourcing 1, fixers 3, meaning auditors 10 (rows 4, life history 3, write-up 3), code reviewers 5 |

Wrong turns kept: the first segments summary counted overlapping reaches once per segment (3,176 km, really about
1,800); the first bootstrap fix dropped separated resamples and so cut the tail the lower bound reports; the connector
fix then dropped five small creek segments; the archived #29 text helper copied `zotero.sqlite` without its `-wal`.

## Evidence

- `scripts/logs/habitat/20261126_*` (the capture and segments logs, the gate logs)
- this archive's `audit-*`, `fixes-*` and `review-round*` files

## Owed

- The next member (Phase 1's issue) starts from `research/grayling_habitat.md`

Closed by: the PR for branch `140-grayling-rebuild-link-s-default-from-the`
