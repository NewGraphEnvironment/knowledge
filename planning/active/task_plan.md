# Task: Stream size where Chinook are caught: CH detection by MAD class across all watershed groups, and distance to a large river (#52)

#42 asks a seasonal question: is there enough flow while a life stage is present? That needs timing windows, and `life_history_timing.csv` only has two groups. A simpler question needs no life stages, and it can run anywhere we have fish records: **how big are the streams Chinook are found in?**

Until now the only MAD we had was fwapg's annual table. It covers the Fraser, Peace and Columbia, and is null on 25.3 % of FDIS visits (`research/habitat_weights.md`). wet's published flow (`research/modelled_discharge.md`, "Use this") now gives annual and monthly flow on about 4.5 M FWA segments province-wide.

## Phase 1: Build (`scripts/0294-ch-mad-build.R`)
- [ ] Visits: 0290's quality drops (not placed, far snap, ws50 mismatch, junk date, effort sentinel or none,
  catch unknown), plus a drop where CH absence is blocked (`blocks_absence_of` has CH). The ledger partitions
  the input.
- [ ] Population WSGs are those where `bcfishobs.observations` holds any CH record. This is a range filter
  independent of the FDIS outcome. Count visits dropped outside it.
- [ ] Exact duplicate visits (#35: same UTM, date, area, catch) are collapsed to one and counted. The
  `site_visit` ids kept are logged.
- [ ] Attach annual flow (month 0) from `pick`, plus each source's own value where present, and record which
  source was picked. A visit with no picked flow is counted and dropped.
- [ ] Distance: for visits on segments with MAD < 0.5 m³/s, trace downstream (`fwa_downstreamtrace`) to the
  first segment whose picked MAD is ≥ 10 m³/s. Record the network distance in m and that segment's MAD;
  NA means none before the sea or the edge of the data.
- [ ] Accessibility sensitivity column, for the 23 covered WSGs only: does a natural CH barrier sit
  downstream? First check whether `barriers_ch_access` already has observation overrides removed. If it
  does, use the pre-override set (gradient and falls). Never use `streams_access` codes.
- [ ] Output `data/fdis/derived/ch_mad_visits.csv` (ignored, private, like `bt_use_visits.csv`) and
  `scripts/logs/habitat/<date>_ch_mad_build_ledger.csv`.

## Phase 2: Use (`scripts/0295-ch-mad-use.R`)
- [ ] Fix the spec in the header before the first fit, as 0291 did.
  - **MAD classes** (m³/s): <0.1, 0.1–0.28, 0.28–0.5, 0.5–1, 1–3, 3–10, 10–30, 30–100, >100. The breaks
    include link's 0.28 and 100, the 0.5 from the literature, and #52's 0.5 and 10.
  - **Distance classes** (small streams only): 0–500 m, 0.5–2 km, 2–10 km, >10 km, and no large river.
- [ ] Raw detection rate per class: overall, and per WSG for WSGs with ≥ 20 CH detections.
- [ ] Model: CH caught ~ class + log(area) + data_set + era + WSG, binomial with a cloglog link. Drop WSGs that
  never or always detect CH, and count them. Run 200 bootstrap resamples by `blue_line_key` with a fixed seed.
  A class is `ok` at ≥ 30 visits and ≥ 10 detections. The same model is run with distance class on the
  small-stream subset.
- [ ] Sensitivities, logged only:
  - each source (`pcic_routed`, `wet_balance`) on its own, where both exist;
  - the share of visits whose MAD class changes between sources (the "does model error move a visit" number);
  - accessibility-filtered (23 WSGs);
  - no dedupe;
  - excluding river polygons (edge 1250/1350);
  - the old fwapg `mad_m3s` where present.
- [ ] Cross-check: the MAD distribution of `bcfishobs.observations` CH records (presence only, all methods)
  against FDIS CH-present visits.
- [ ] Output `data/ch_mad_use.csv` (aggregates only: analysis × class with n, detections, raw rate, model
  rate, CI, power) and `scripts/logs/habitat/<date>_ch_mad_use.txt`.

## Phase 3: Write-up
- [ ] `research/chinook_stream_size.md` with the provenance line. It covers:
  - the rate by MAD class;
  - the small-stream-near-big-river result;
  - per-WSG spread;
  - each sensitivity's effect;
  - limits: juveniles only, big rivers under-sampled, modelled flow;
  - what it means against link's 0.28 / 0.46 / 100 and Woll's 0.5. This is stated as evidence for
    link#331 and the CH threshold rows, not as a change.
- [ ] Add a `research/README.md` row and the `scripts/README.md` run order (0294, 0295). In CLAUDE.md, list
  `ch_mad_use.csv` in the `data/` root description.
- [ ] Edit the #52 body to link the research file and the result, and point #42's scope note at it.

## Validation
- [ ] Both scripts run clean from the repo root, and the ledger partitions the input
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive`, then `/gh-pr-push`

## Verification
- Ledger: kept + dropped = 43,141-equivalent input. The CH-present count is reconciled against 0240's 1,189.
- Picked-MAD coverage of kept visits is reported (expected near 100 % against 61 % for the old MAD).
- Spot-check 3 distance traces by hand in SQL (a CHES tributary, a NECR one, one with no large river).
- Restore-the-bug: break the dedupe key, and break the blocked-absence drop. Confirm the ledger counts move.
- The bootstrap is re-run on a different worker count and gives identical output.
