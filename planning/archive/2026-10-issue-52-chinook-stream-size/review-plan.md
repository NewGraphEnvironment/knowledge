# Plan review (#52), Plan agent, returned 2026-10-15 ~22:31Z

Spawned 22:20Z. A read-only agent, so its reply was written here by the session. Each finding is condensed to its claim and
number. Verdict: "not ready to build". The plumbing follows 0290/0291, but the data underneath would make the
headline misleading.

## Blockers
- **B1. The top MAD classes are regulated rivers, mostly one survey.**
  - **>100 m³/s**: 432 of 472 CH detections are Nechako (CHES 236, NECR 196). They come from one FDS 2010
    Triton project: 495 visits on one blk, area 240 m², months 4/5/6/7/11. That project is 36.3 % of all CH
    detections.
  - **30–100 m³/s**: 66 of 94 detections are the lower Bridge (SETN 2007, 2015), below Terzaghi.
  - **Natural vs regulated flow.** wet's flow is natural flow, so it is wrong on both rivers. Kenney Dam's
    `degree_of_regulation_pc` is 621.1. Cheslatta reads 157 routed against 0.7 from the balance.
  - **Fix**:
    - flag visits downstream of a regulating dam (`cabd.dams`), without using observations;
    - leave out the regulated reaches, the Nechako 2010 project, and CHES+NECR;
    - report the top-project share of each class.
- **B2. The no-pick drop is not random.** 1,306 visits have no `pick`; 140 of them caught CH (10.7 % against 2.8 %
  overall), which is 12 % of detections. They are all on segments with no lut row: edges 1350, 1450, 1100 and 1400,
  i.e. side channels and secondary flow. **Fix:** give each the parent mainstem's flow, or its own class. Never drop.
- **B3. The 0–500 m class is contaminated by snap position and side channels.**
  - **Snap position.** Among small-stream visits, 74.9 % of the CH-caught ones lie within 500 m of the stream mouth,
    against 38.8 % of the rest. The CH visits also snap further (median 11.3 m against 3.95 m). Example: the MORK
    Slim Creek stub. 197 visits under 0.5 m³/s have a wetted width over 10 m.
  - **Side channels.** 1,939 visits (200 CH) sit on a blk that is not the watershed_key.
  - **Fix**: flag a visit as ambiguous where a MAD ≥ 10 segment on another blk lies within the snap distance plus
    20 m; run with and without them. Report side channels separately.
- **B4. `fwa_downstreamtrace` is not a path.**
  - **Side channels.** It includes side channels; a KSHR example sums 1,596 m against a true ~739 m.
  - **Lut gaps.** It inner-joins the lut, so connectors with no lut row (92 % of edge 1400, 61 % of 1350, 22 % of
    1450) drop out and leave gaps.
  - **Order.** It is ordered by code, not by path.
  - **Cost.** It traces to the sea.
  - **Fix**: build the path explicitly (own blk below the measure, then the parent below the confluence), measure to
    the confluence, record the target's edge and waterbody, and stop at the first hit.

## Gaps
- **G1.** Add the responses F (any fish) and C (CH given fish). Half the visits are in <0.1 m³/s, where FDS samples
  fishless headwaters.
- **G2.** Define the "model rate": a rate ratio against a reference.
- **G3.** State the population: the area trim (NA 4,265, <10 m² 1,041, >10,000 m² 286), the edge filter, and lakes
  (811 visits on lake-polygon segments).
- **G4.** Add a season/month sensitivity: CH are caught Apr–Nov, and juveniles redistribute in fall.
- **G5.** The blk bootstrap is dominated by the Nechako blk (36 %). Report the top-cluster share; a glmer project
  random effect is optional.
- **G6.** Gradient confounds MAD. Add FWA gradient as a sensitivity covariate.
- **G7.** In the cross-check, 52 % of bcfishobs CH records are FDIS. Use the non-FDIS records only, and say that
  life stage is mixed.

## Assumptions
- **A1.** The usable visits span 223 WSGs; 73 have CH. Without a filter, raw rates and model rates would describe
  different populations.
- **A2.** The bcfishobs filter admits stray ranges (LARL, REVL, OKAN). Use link's rule instead: at least 5 CH
  records since 1990.
- **A3.** `barriers_ch_access` is circular. The pre-override set is GRADIENT, FALLS, SUBSURFACE_FLOW and
  USER_DEFINITE. Coverage is 56 WSGs.
- **A4.** Run the access check with and without USER_DEFINITE. The gradient barriers partly re-encode stream size.
- **A5.** 72 % of CH detections are inside river polygons. "Big rivers under-sampled" is the wrong limit to state,
  and the no-river-polygon sensitivity removes most of the signal.
- **A6.** The two sources agree on the class 82.7 % of the time overall, but only 0.57–0.68 in the 0.1–1 classes.
  Merge those classes or note it. Also note in the header that the literature breaks deviate from #52's "breaks
  from the data".
- **A7.** `linear_feature_id` comes back as integer vs bigint, and counts as integer64. Cast in SQL.
- **A8.** Duplicates: 1,059 groups, 1,161 surplus, 24 CH. Dedupe after the drops.

## Ordering, scope, acceptance
- **O1–O3.** Answer the override and regulated-reach questions first. Write the spec after B1–B3. Trace only kept
  small-stream visits.
- **S1.** Drop the spawn_mad_min 0.46 comparison: juvenile data cannot test it.
- **S2.** There are 215 CH detections on small streams, so use the distance classes ≤500 m, >500 m and none.
- **AC1.** The ledger input is the 53,018 rows; 1,189 is a recount, not 0240's 1,377.
- **AC2.** Spot-check a side-channel start, a no-lut connector, a lake target and the MORK stub.
- **AC3.** Report the top-project and top-blk shares, the source agreement and the regulated share per class.
- **AC4.** Restore-the-bug on the no-pick handling.

## Disposition (session, 2026-10-15)
All are accepted except the following, which are taken as written below:
- **G5 glmer**: not run. The leave-outs and top-cluster shares answer it.
- **A6**: the main classes stay, because they hold link's 0.28 and the literature's 0.5. A merged 0.1–0.5
  sensitivity is added, and per-class agreement is reported.
- **G3 lakes**: the edge filter (0291's `edge_ok`) excludes lake construction lines. Lake-polygon segments are
  counted in the log, not dropped.
