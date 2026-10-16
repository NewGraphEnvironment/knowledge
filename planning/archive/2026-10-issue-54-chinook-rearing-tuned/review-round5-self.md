# Code review, round 5: closing enumeration (#54), by the lead

Rounds 2, 3 and 4 each found a defect inside the previous round's fix. Under `/code-check`'s stopping rule, only an
enumeration ends the loop then. Round 3 named the mechanism: every figure comes from a filter in code, while the prose
names its population with a noun defined elsewhere, and the two lists are kept equal by hand. Round 3 enumerated the
whole candidate set, 140 rows covering every ratio, share, "x of y" and range in the write-up, the draft and the
CLAUDE.md note. Round 4 re-enumerated every line round 3's fixes changed. This round enumerates every line round 4's
fixes changed, and checks each claim by script against `data/ch_rule_tune.csv`. Five reviewer agents were spent
(one plan review, four rounds), which is the per-task bound, so the lead did this one.

| # | file:line (after the fix) | claim | check | result |
|---|---|---|---|---|
| 1 | research:38-40 | the proposed config holds the gradient in three settings | draft config: two stream rules with `thresholds: false` and an explicit gradient, plus the CSV's `rear_gradient_max` for the river rule (fresh `.frs_rule_to_sql()`: explicit wins, `thresholds: false` stops inheritance) | ✓ |
| 2 | research:62-64 | main rule in 13 regions; outside both link-placed readings | script: in 13 of 15; missing `link_gradient`, `link_visits_fwa_gradient` | ✓ |
| 3 | research:62-64 | 2,826 modelled visits, 16 WSGs | script: n_visits 2,826, n_wsg 16 in both link readings | ✓ |
| 4 | research:62-64 | MAD ≥ 0.75 in region only at 9 % on link's gradient | script: {0.09} | ✓ |
| 5 | research:62-64 | and only at 5.49 % and 7 % on the FWA gradient | script: {0.0549, 0.07} | ✓ |
| 6 | research:257 | the best rule's floor is 0.5 m³/s on link's segments | script: best = MAD ≥ 0.5, 9 %, Q 3 @ 1,000 m on both link readings | ✓ |
| 7 | research:287, :289 | "each sensitivity's own pick", column "pick" | script: every sensitivity's recommended row is its pick | ✓ |
| 8 | draft:32-33 | 15 readings = main, sensitivities, flow sources, two link-placed | script: 1 + 7 + 5 + 2 = 15 | ✓ |
| 9 | draft:34-36 | same as rows 2-5, for 16 groups with both outcomes | as rows 2-5 | ✓ |
| 10 | draft:48-49 | order-1 gains are what `default`'s stream branch leaves out | round 4: every order-1 stream-edge width in the 31 groups is a field measurement; the wetland branch rears 1,430 km of order-1 without width | ✓ (wording now scoped to the stream branch) |
| 11 | draft:77-79 | three settings | as row 1 | ✓ |
| 12 | CLAUDE.md:218-220 | 1450 connectors carry their tributary's flow; some 1250 main lines carry a small flow of their own | round 4: 315 of 363 km of 1450 in polygons whose main line carries ≥ 10 m³/s; 114.1 of 152.3 km of 1250 in small rivers carrying their own flow | ✓ |

No row sits above its source. The loop ends here, by enumeration.

## Round 4's notes, disposition

- CLAUDE.md "and so do": reworded (row 12).
- draft :48-49: scoped to the stream branch (row 10).
- research :271 (2,695 is the modelled share of 3,227): accepted. The page states no other size.
- draft :32 parenthetical: now names all 15 readings (row 8).
- research :257 "leans to 0.5": now "the best rule's floor is 0.5" (row 6).
