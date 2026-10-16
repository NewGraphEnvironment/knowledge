# Task: Tuned Chinook rearing rule: size, gradient and distance to a large river, set beside link's default (#54)

## Problem

#52 (PR #53) found Chinook rarely caught in streams under about 0.5 m³/s unless a ≥ 10 m³/s river is within 500 m downstream (14.5 % of visits against 0.8 %, rate ratio 26.7). Those three numbers were picked by hand. What link runs today:

- **bcfishpass and our `default` carry identical Chinook thresholds**: spawning gradient ≤ 4.49 %, width ≥ 4 m, MAD ≥ 0.46 m³/s; rearing gradient ≤ 5.49 %, width ≥ 1.5 m, MAD 0.28–100 m³/s.
- **The MAD bounds never act.** All 188 groups size streams by channel width (`parameters_habitat_method.csv`, `cw`), in both bundles.
- **`default` and bcfishpass differ for Chinook rearing by structure, not threshold**: +24 % (DEAD) to +184 % (BABL) rearing km in link's four-group comparison, plus lake and wetland hectares, from intermittent streams, wetlands, lakes and river polygons (link `research/default_vs_bcfishpass.md`). Spawning km are identical.

So the comparison is tuned against `default`, two side by side, with bcfishpass a one-line pointer.

The two wet flow sources agree within 2× on 81–88 % of small-stream visits, against the 1.8× between 0.28 and 0.5, so where a size step sits can depend on the flow model. wet's balance is adjusted by the Extended BC Hydrologic Zones and is weakest on small basins, headwaters and the dry interior (zones 15, 17, 23, 24; `research/modelled_discharge.md`).

## Phase 1: Walk profile and reproduce `default`'s predicate
- [ ] `scripts/sql/ch_dist_profile.sql`: an array-of-Q, per-source walk with the same path rules and statuses as
      `ch_dist_large.sql`
- [ ] Positive control: profile at Q = 10 on `pick` reproduces 0294's `dist_large_m`, `walk_status` and
      `large_lfid` on every 0294 start (exact, logged)
- [ ] Read `lnk_pipeline_classify()` / fresh's classifier for the CH stream and R-branch rearing predicate
      (inclusive bounds, NULL width, which branches take the gradient test). Write it as SQL and check it
      reproduces `fresh_default.streams_habitat_ch.rearing` (non-lake, non-wetland) on every covered segment.
      Any mismatch stops the run.

## Phase 2: Build (0296)
- [ ] Every 0294 kept visit: walks at Q ∈ {1, 3, 5, 10, 20, 30, 50} m³/s on each of `pick`, `pcic_routed` and
      `wet_balance`, keeping whether the target is a lake or a regulated reach. Every visit is walked, not only
      those under 1 m³/s, because a width rule can fail a visit above 1 m³/s.
- [ ] Attach link's channel width and its source from `fwa_stream_networks_channel_width`. In the 27 covered
      groups, attach link's segment (0290's placement and tiebreak, `overlap_max_m` stop), its gradient and
      width, and `default`'s CH rearing.
- [ ] Hydrologic zone per visit, from the BC catalogue zip, point in polygon. The count of unmatched points is
      logged.
- [ ] Ledger that partitions the input, as in 0294. Write `ch_rule_visits.csv` and the ledger log.

## Phase 3: Analysis spec, fixed and committed before any fit (0297 header)
- [ ] Population: 0295's MAD analysis (edges, area, duplicates out). Models use groups with both outcomes.
- [ ] Rule = stream-branch size test (MAD floor *m* or width floor *w*) AND gradient ≤ *g*, OR (size fails AND
      gradient ≤ *g* AND a ≥ *Q* segment within *D* downstream). It is applied where `default` applies its tests.
      River-polygon and lake-edge visits keep `default`'s branch. Grid as the issue lists it, plus `default` and
      "all in".
- [ ] Score: 0295's cloglog (log area, data set, era, WSG) + the rule term. Five folds hold out whole WSGs,
      assigned by a fixed seed. Held-out deviance: rule, area, data-set and era coefficients from training; only
      each held-out WSG's intercept refit on its own visits (the same one parameter per WSG for every rule).
      Unseen nuisance levels go to the reference and are counted.
- [ ] Optimum: the rules whose held-out deviance is within one SE of the best. The SE is of the paired difference
      from the best, with the WSG as the unit. "Simplest" is the fewest departures from `default` (size variable
      and value, gradient, exception). Ties go to the lower deviance. Each component's value range inside the
      region is reported.
- [ ] Stability: 200 bootstrap resamples, by stream, of the per-visit held-out deviances; the region and the pick
      are recomputed each time. Report the share choosing each component value.
- [ ] Width results always shown beside their source split (`FIELD_MEASURMENT` / `MODELLED`), with the
      field-measured visits-out sensitivity. Optimum D < 200 m is reported, not recommended.

## Phase 4: Tune (0297)
- [ ] Grid, CV, 1-SE region, bootstrap stability (socket workers, seed fixed, resamples drawn before the fits)
- [ ] GAM check (mgcv): s(log MAD) or s(log width), s(gradient), and on small streams s(log distance to tuned Q),
      with WSG `bs = "re"`. Where each tuned threshold sits on its curve.
- [ ] Repeat on the 27 covered groups with link's segment gradient. Report how far the optimum moves.
- [ ] Flow sources: re-run the grid and the GAM on routed alone, balance alone (walks per source) and fwapg's old
      MAD (size floor only; exception on `pick`). At the chosen rule, count visits whose in/out flips between
      sources, by hydrologic zone and MAD class.
- [ ] Sensitivities: lake targets out; regulated targets and visits out; ambiguous placements out; CHES and NECR
      out; C (CH given any fish) in place of U
- [ ] Outside check: bcfishobs non-FDIS CH records (1,346 in covered groups), placed on link segments with the
      same tiebreak. Records on rearing segments as a share, against rearing km, for `default` and the tuned rule
      (access is `default`'s for both)
- [ ] Write `data/ch_rule_tune.csv` (aggregates only) and `scripts/logs/habitat/<date>_ch_rule_tune.txt`

## Phase 5: Side by side (0298)
- [ ] Walk the accessible stream-edge CH segments that fail the tuned size floor (profile, `pick`), in covered
      groups
- [ ] Tuned predicate in SQL over `fresh_default`. Per group: rearing km under each rule, segments and km gained
      and lost, with lake and wetland rearing unchanged and reported beside. No link change.
- [ ] Maps of three groups (one small-stream-heavy, one interior, one coastal, chosen by a stated criterion before
      drawing) → `research/fig/chinook_rearing_tuned_<wsg>.png`
- [ ] Write `data/ch_rule_compare.csv`

## Phase 6: Write-up and handoff
- [ ] `research/chinook_rearing_tuned.md`: provenance line, every figure naming its population (the #52 rule),
      `default` beside tuned, flow-model section by zone, the limits stated up front, structured to lift into a
      link vignette, and a bcfishpass one-line pointer
- [ ] `research/README.md` row; `scripts/README.md` run order; CLAUDE.md `data/` root list (`ch_rule_tune.csv`,
      `ch_rule_compare.csv`); a forward pointer in `chinook_stream_size.md`
- [ ] Draft the link issue (a `default_tuned` CH rearing rule plus the vignette) in `planning/active/`, not filed
- [ ] Push `ch_rule_visits.csv` to `s3://fresh-bc/fdis/derived/`

## Validation

- [ ] Positive controls pass (walk reproduces 0294; SQL predicate reproduces `default`)
- [ ] Ledger partitions; bootstrap identical across worker counts
- [ ] Tests pass
- [ ] `/code-check` clean (each commit, or once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
