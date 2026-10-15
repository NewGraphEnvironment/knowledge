# Round 5: terminating enumeration (session, 2026-10-15 ~23:35Z)

Round 4 (`review-round4.md`) enumerated about 150 sentences and found 14 failing, all in framing words. Two
of round 3's failures sat inside earlier fixes. Under `/code-check`'s stopping rule only an enumeration
ends the loop, and the reviewer budget (five spawns on this task, the plan review included) was spent.
This round is therefore the session's own.

**Method.** `research/chinook_stream_size.md` was rewritten in one piece, not patched. The rule was that every
figure names its population, and no comparative appears unless it is a measured comparison between two
figures from one population, or the sentence says the populations differ. Then each claim-bearing line (102
lines matched by digits or framing words, after the header) was checked against the source below. Every
figure was recomputed in this session from `data/ch_mad_use.csv`, the 0295 log, the 0294 ledger, or
`ch_mad_visits.csv` under 0295's filters.

| claim | source checked |
|---|---|
| MAD population 19,077 / 978 / 102 WSGs; model 15,626 / 978 / 67 WSGs | 0295 log lines 2 and 4 |
| distance population 7,319 / 118 / 34 WSGs | 0295 log, `distance_small` line |
| relative rates 0.14, 0.47, 0.61; 1.40–2.40 for 0.5–10 m³/s | csv `mad_pick` / `ch_caught` |
| C 0.26–0.48 under 0.5; 0.91–1.52 for 0.5–30 m³/s | csv `ch_given_fish` (1.03, 0.91, 1.52, 1.32) |
| 14.5 % / 0.8 %, 52 and 55 CH, 26.7 (15.0–58.3) | csv `distance_small` |
| 82 of 142 (every small-stream CH visit with a large river downstream) | recomputed: 153 small CH = 82 near + 60 far + 11 none |
| regulated visit shares 66 % and 81 %; 1.5 % at 0.1–0.28 and 12.3 % at 10–30 | csv `regulated_visit_share` |
| regulated detection column; 16 at 0.1–0.28 = CHES 14 + NECR 2 side channels | csv `regulated_detect_share`; recomputed |
| Nechako survey 432 of 978, and 432 of 531 at ≥ 100 | 0295 log "Largest project"; csv |
| 53,018 in; 106 WSGs; 20,832 dropped (3 CH); 21,862 / 1,186 kept | ledger |
| 507 duplicates left out | 0295 log line 2 |
| pick 17,289 routed / 1,788 balance | 0295 log, picked-source block |
| parent flow 445 kept visits, 140 CH; 31 % against 5.4 % | ledger (140/445; 1,186/21,862) |
| 101 dams; CABD regulation known for 38 of 2,592 | ledger; `cabd.dams` query |
| MAD table, all nine rows and every column | csv |
| F higher in each class than the one below; 0.42 → 3.0 | csv `any_fish`: 0.417 … 3.003, monotone |
| 14.5 % above every MAD class raw under 30 m³/s (0.9–6.9 %), populations stated as different | csv |
| 32 / 11 / 8 / 13 WSGs, in the distance analysis | recomputed on the 34-WSG distance set |
| 1,243 `none` across 102 WSGs: 558 direct (9 CH) and 685 via smaller lines (2 CH) | recomputed (`walk_hops == 0`) |
| 0.08–0.74 under 0.5 across the 10 listed sensitivities; the two exceptions from 0.5 up | csv, every listed sensitivity |
| balance 0.29 / 0.54 / 1.43; routed 0.55 / 1.46 / 1.39 | csv `sens_wet_balance_where_both`, `sens_pcic_routed_where_both` |
| agreement 53–67 % for 0.1–1; 75–99 % for the other classes | 0295 log agreement block (0.529–0.670; 0.754–0.990) |
| `modelled_discharge.md` describes the balance as weakest on small basins | that file (the balance only; round 4) |
| regulated out: 3.49 / 2.86 / 8.34 / 3.20; CH 72 / 37 / 12 / 41; 27.5 % of 149 | csv `sens_regulated_out` |
| no river polygons: 275 remain; 0.34, 0.86, 1.39, 2.49, 3.36, 4.54 | csv `sens_no_river_polygons` |
| distance sensitivities 30.2 / 28.8 / 24.0 | csv |
| bcfishobs: 4,384 non-FDIS; 13 % vs 16 % under 0.5; 71 % vs 24 % at 1–100; 54 % at ≥ 100 | csv presence_mix rows, summed |
| evidence rows 118–119 (Rebellato 0.28, 100) and 412 (Woll 0.5) | `literature_evidence.csv` lines 119, 120, 413 |
| 702 of 978 detections inside a river polygon or on a river-polygon edge | recomputed (round 4 corrected 703) |
| top project 81 % at ≥ 100 and 51 % at 30–100 | csv `top_project_share` |
| 2 CH ≥ 150 mm | `fdis_export.md` |
| the unsourced breaks 0.1, 1, 3, 30 | 0295 header (round 4) |

Comparatives kept, each with both sides from one population or the difference stated: 14.5 % against 0.8 %
(distance set); C under 0.5 against 0.5–30 (MAD set); the regulated-out rates (one sensitivity); bcfishobs
against FDIS (stated as two sources); 14.5 % against the MAD classes (stated as different populations).

The same rule was applied to the README row, the #52 Result section (rewritten whole), #42's scope note, and
the 0295 header lines round 4 flagged.

Result: no line fails. Terminated by this enumeration.
