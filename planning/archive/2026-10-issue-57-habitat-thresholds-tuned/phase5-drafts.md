# Phase 5 drafts: the transfer issues and the link comment

Filed after the repository is public (#56); until then these are drafts on the branch. Numbers are read
from `data/thresholds.csv` and the research files once `0320`–`0330` have run; the bodies point at those
rather than restating them.

## Issue A (this repo): WCT thresholds from link#322, scored here

**Title:** Westslope cutthroat thresholds: carry link#322's calibration into the tuning run

**Body:**

> **If done:** WCT's rearing and spawning thresholds are tuned here with every other species, from the
> published electrofishing evidence, and link's `default_tuned` reads them from the thresholds table
> (`knowledge/thresholds/v1`). **If never:** link keeps its own WCT calibration harness
> (NewGraphEnvironment/link#322) beside the one here, on a subset of the same evidence.
>
> ## What #57 already gives
>
> `scripts/0320` tunes WCT rearing wherever the evidence admits it; the `WCT_rear` row of
> `data/thresholds.csv` says whether it fitted, was underpowered (fewer than 10 groups with both outcomes),
> or had too few groups, and `data/thresholds_groups.csv` lists the groups scored. WCT spawning has no
> electrofishing response (no maturity-coded WCT spawners in the export), so its row says `no_response`.
>
> ## To carry from link#322
>
> - its held-out design and the groups it scored, compared with the folds here;
> - the ladder of WCT gradient and MAD values it tested, against `knw_tune_grid()`'s;
> - anything it learned about WCT's range in link's presence rule that the evidence build should
>   gate on.
>
> Depends on #57 (merged), NewGraphEnvironment/link#346.

## Issue B (this repo): GR, RB and KO on wet's discharge, from link#343

**Title:** Grayling, rainbow and kokanee MAD minima: carry link#343's re-tune into the tuning run

**Body:**

> **If done:** GR, RB and KO rearing and spawning minima are tuned here on wet's discharge with the other
> species, and link's `default_tuned` reads them from the thresholds table. **If never:** link re-tunes
> them in its own harness (NewGraphEnvironment/link#343), on fwapg's old MAD or on wet, apart from the
> evidence here.
>
> ## What #57 already gives
>
> `0320` tunes GR and RB rearing on wet's `pick` flow wherever the evidence admits it (`GR_rear`, `RB_rear`
> in `data/thresholds.csv`). KO rears in lakes only under `default` (no stream rule), so its rearing row
> says `no_stream_rule`; KO spawning has no electrofishing response. RB's access columns disagree in link
> (NewGraphEnvironment/link#349: 17 % of habitat-accessible segments have `access_rb = 0`, and the
> comparison shows it is whole groups: in 23 of RB's 210 groups every segment has `access_rb = 0`, 37,895 km
> of stored rearing; GR has three such groups and BT one), and the build's `access_check.csv` carries the
> cross-tabulation on every run; RB's grades are gated on `streams_access` until link says which column is
> meant.
>
> ## To carry from link#343
>
> - the MAD ladders it tested per species and stage, against `knw_tune_grid()`'s;
> - its treatment of RB's two access columns;
> - the KO and SK lake-rearing question, which no stream rule here reaches.
>
> Depends on #57 (merged), NewGraphEnvironment/link#346, NewGraphEnvironment/link#349.

## Comment on NewGraphEnvironment/link#346 (draft; not posted)

> The evidence repository is public and #57 there has landed: one evidence build on the province-wide
> `default` run (`run_uid 20261017_004619-3f4c713b`) and one tuning run across species and stages.
> Two tables are published under the bucket's `knowledge/` prefix, manifest first:
>
> - `knowledge/thresholds/v1`: one row per species × stage × component of the recommended rule, with
>   `link_parameter` naming the column of `parameters_habitat_thresholds.csv` the value fills
>   (`rear_mad_min`, `rear_gradient_max`, …), the unit, `model` (`cw`/`mad`), the one-SE range, the
>   readings the rule holds in, `default_in_region`, the groups scored (`thresholds_groups`), and the
>   evidence version and link run. The near-a-river exception (`exception_q`, `exception_d`) has no
>   link column yet.
> - `knowledge/habitat_grade/v1`: one row per segment × species × stage, keyed by FWA position
>   (`blue_line_key`, downstream and upstream measure) plus `linear_feature_id` and `length_metre`, with
>   the 0–1 grade (expected use relative to the 95th percentile of accessible segments) and its class,
>   Hive-partitioned by `species_code` and `stage`.
>
> §2 of this issue can read them: `default_tuned`'s thresholds file from `thresholds` by
> `link_parameter`, recording `rule_id` and `evidence_version` per row; `habitat_validate.R` from the
> grade table by URL. #322 and #343 are taken up as knowledge#A and knowledge#B.
