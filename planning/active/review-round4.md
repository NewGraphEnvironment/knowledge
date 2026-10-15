# Code-check round 4: terminating enumeration of framing (#52)

Reviewed at dbd3551. Each sentence carrying a number, quantifier, comparative, direction word or population label
was checked against `data/ch_mad_use.csv`, `scripts/logs/habitat/20261015_ch_mad_use.txt`, the build ledger, and
where those do not hold the figure, recomputed from `data/fdis/derived/ch_mad_visits.csv` (0295's population:
19,077 visits, 978 CH) or read from local fwapg.

## Sentences checked

| source | sentences checked | failing |
|---|---:|---:|
| `research/chinook_stream_size.md` | 78 | 10 |
| `research/README.md` new row | 1 (5 clauses) | 1 |
| issue #52 `## Result (2026-10-15)` | 17 | 1 |
| `scripts/0294-ch-mad-build.R` header | 20 | 0 |
| `scripts/0295-ch-mad-use.R` header | 27 | 2 |
| `scripts/sql/ch_dist_large.sql` header | 7 | 0 |

Confirmed and not listed: every table cell (MAD and distance tables), the sensitivity range 0.08–0.74 and its two
exceptions, the agreement ranges 53–67 % and 75–99 %, the regulated visit shares, 16 regulated detections at 0.1–0.28 m³/s
(all own-flow side channels, CHES 14 and NECR 2), the WSG split 32 = 11 + 8 + 13, the `none` split 558 (9 CH) / 685
(2 CH). Every `none` walk is on a 9xx coastal code, so "reaches the sea" holds. Also confirmed: the Nechako stream holds exactly the
432 detections of the one survey, the 30–100 top project is BC Hydro 2007 on the Bridge (56 of 71 class detections on the
Bridge, all regulated), and Kenney Dam is 621.1 % and Terzaghi 53.4 % in CABD, with 38 dams carrying a degree of regulation.
link's CH 0.28/100/0.46 and 5 records since 1990, evidence rows 118, 119 and 412, the 702 river-polygon detections (72 %)
and the ledger partition (53,018 − 31,156 = 21,862) all match. Parent-flow visits are all side channels (445, 140 CH).

## Findings

1. **`research/README.md` new row**: "small streams within 500 m downstream of a ≥ 10 m³/s river (rate ratio 26.7)".
   The direction is reversed. The measured class is a ≥ 10 m³/s segment within 500 m downstream of the small-stream
   visit, so the stream is upstream of the river (research L33 and 0294 have it right).

2. **research L32**: "On small streams, CH sit next to large rivers." The outputs do not support this as a statement about
   where small-stream CH are. Of the 153 small-stream (MAD < 0.5) detections, 82 have a large river within 500 m downstream,
   60 have one farther down and 11 reach the sea first. In the table population, 52 of 118 are near (44 %). What the outputs
   support is the rate contrast: detection is higher near a large river (14.5 % against 0.8 %).

3. **research L36, L37–38, and the issue's Result bullet 2** ("52 of the 107 small-stream detections with a large river
   downstream", "(49 %)", "Small streams near a large river carry about half of the small-stream CH that have a large river
   downstream (52 of 107)"). The label names all small-stream detections with a large river downstream. That population is
   142 detections, 82 of them within 500 m (58 %). The 107 is what is left after side channels (20 found-walk detections) and
   ambiguous placements (15) are taken out. Taking out side channels only gives 65 of 120 (54 %). Neither the short
   answer nor the issue states the exclusion. Research L94 and L143 do. The 14.5 % / 0.8 % in L33–34 and in the issue rest on the
   same unstated exclusion, and on the 34 modelled WSGs only.

4. **research L103 and L144–145**: "Beyond 500 m, small streams have the rate of the < 0.1 m³/s class" and "Away from a large
   river, small streams carry CH at the < 0.1 m³/s rate (0.8 %)". The 0.8 % is the > 500 m rate (55/6,523, in the 34
   distance-modelled WSGs), not the < 0.1 class rate, which is 0.9 % (70/7,840, in the 67 MAD-modelled WSGs). The two come
   from different populations, and the sentence does not say so. On all analysed visits they are 0.51 % (55/10,723) against
   0.74 % (70/9,397).

5. **research L119–120**: "Small-stream flow is where both models are weakest (`modelled_discharge.md`)." The cited file
   (L37–38) says only that *the balance* is weakest on small basins, and nothing of the kind for routed flow. The outputs show
   the sources disagree most at 0.1–1 m³/s, but they agree on 94 % of visits under 0.1 m³/s.

6. **research L125**: "The rise above 10 m³/s is therefore not only the Nechako, but it rests on few unregulated visits." The
   section heading names its metric as relative rates. On that metric there is no rise above 10 m³/s once regulated reaches
   are out: 10–30 is 2.86 and ≥ 100 is 3.20, both below 3–10 at 3.49. Only 30–100 rises (8.3, from 12 detections). In the
   main table, 10–30 (2.16) is also below 3–10 (2.40). On raw rates with regulated reaches out, 10–30 (4.9 %) is below 3–10
   (6.2 %) too. Any rise starts at 30 m³/s, not 10.

7. **research L126–127**: "The class ranks hold, rising from 0.34 to 4.5 between < 0.1 and 3–10 m³/s." The ranks do not
   hold. In the main analysis 0.5–1 (1.52) is above 1–3 (1.40), and with no river polygons it is below (2.49 against 3.36).
   Also, with no river polygons 0.28–0.5 is 1.39, above the average, so the step below 0.5 does not hold against 1 in
   this sensitivity. L111 correctly leaves it off the "survives" list.

8. **research L133**: "They are spread over 1–100 m³/s much more evenly than FDIS." Within 1–100 m³/s both are about as
   even: FDIS shares run 0.041–0.074 (max/min 1.8), bcfishobs 0.129–0.237 (1.8). What differs is the mass in that range:
   71 % of non-FDIS bcfishobs records against 24 % of FDIS CH visits, which sit 54 % at ≥ 100.

9. **research L169–170**: "A WSG with CH only near or only far informs the distance contrast only through its rate against
   other WSGs." This is false for the model as fitted. With a WSG fixed effect, a WSG whose CH were caught on one side
   but which has visits on both sides gives a within-WSG contrast (detections on one side, none on the other). All 8
   only-near WSGs have > 500 m visits (31–248 each). 9 of the 13 only-far WSGs have ≤ 500 m visits. Only DEAD, LNIC, SALR
   and UCHR (no near visits) contribute nothing within-WSG.

10. **research L19**: "This needs no life-stage timing, so it runs in every watershed group with fish records." As run, it
    covers the 106 WSGs in link's CH range (102 after the analysis filters). 20,832 visits in other WSGs were dropped by
    that rule (ledger `wsg_outside_ch_range`).

11. **0295 header L13–16**: "These are literature and model breaks (link's CH rear_mad_min 0.28 and rear_mad_max 100,
    Woll 2015's 0.5, #52's 0.5 and 10), not breaks chosen from the data". This holds for 4 of the 8 breaks only.
    0.1, 1, 3 and 30 m³/s come from none of the named sources, and the header gives no source for them.

12. **0295 header L20–21**: "Half the visits are under 0.1 m3/s, where FDS surveys look for the upper fish limit". The
    half is right (9,397 of 19,077, 49 %), but those visits are not mainly FDS. Only 2,242 of the 9,397 (24 %) are
    `data_set == "FDS"`, and 7,155 are FDIS. So the clause does not explain the population it is attached to.
