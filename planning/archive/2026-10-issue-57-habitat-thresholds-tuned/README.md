# #57: Tune habitat thresholds for every species and life stage in one run, as package functions

## Outcome

One evidence build (`0310`), one tuning run (`0320`), published tables (`0325`) and one comparison (`0330`), as
`knw_*` package functions with tests, on link's province-wide `default` run (241 groups, `run_uid
20261017_004619-3f4c713b`). Eight species × stage fit; `default` is outside the one-SE region for every species
but grayling; chinook's open size floor settles at 0.75 m³/s; bull trout spawning fits but is weak. Every tuned
rule but grayling's draws less habitat than `default` and holds more of the independent bcfishobs records per
kilometre. `0290`, `0294` and `0296` became calls on the new build; `0291`–`0298` are frozen on the published v2
visit tables. Learned along the way: link#349's rainbow disagreement is whole groups (23 of 210, 37,895 km), the
regenerated `default` differs from link's stored RB flags by 45,970 km, width rules leave unmeasured first-order
streams ungraded, socket workers need connection timeouts (the run host hung three hours grading), and a
download helper must never leave a partial file where a cache hit is read. Gated and left open: `PUBLISH=TRUE`
uploads (bucket policy, #56), the two transfer issues and the link#346 comment (drafts in `phase5-drafts.md`;
the repository is still private, and nothing was posted upstream). Research: `research/habitat_thresholds_tuned.md`
and one file per species.

## Measurement

- Evidence: 51,587 FDIS sites in, 40,552 visits placed; the ledger partitions them (11,035 dropped, by cause).
  Walks: 34,192 starts × 3 flow sources × 7 sizes in 3.7 min on 4 workers.
- Tuning: scoring of 22 species × stage in 104 min on 14 workers; grading hung on the run host (connections
  with no timeout) and finished locally, RB's 210 groups in 3.2 min against the host's 54 min for BT. A one-species
  re-run rewrote its tables byte-identical.
- Province-wide km under the tuned rule against `default`: RB −19.0 %, BT rearing −37.3 %, BT spawning −25.2 %,
  CH −12.4 %, CO −4.9 %, GR 0, ST −36.9 %, WCT −21.7 %. Grade-weighted km rises only for CH (27,681 → 32,018).
  The bcfishobs outside lift rises under every tuned rule (BT rearing most, 2.45 → 5.17). Floodplain hectares
  beside the habitat (23 catalog groups) fall less than the km for BT, RB, ST and WCT and more for CH and CO.
- Comparison: parallel stage 7 min on 6 workers; floodplain and maps 3 h serial (about a minute a figure with
  the floodplain join); 306.3 min in all, then a 131.6 min `STAGE=maps` re-run.
- What the numbers changed: the thresholds table carries `CH_rear_v1` at 0.75 m³/s (not #54's open 0.5–0.75);
  BT spawning is marked weak and not to be applied; the research files gained the comparison and two limits; the
  link#349 draft gained the whole-group finding.
- Wrong turns kept: five `0330` attempts before the run that finished (the grade table's column types, a
  failed job shifting the species after it); the run-host grading hang; an internet outage during the map stage
  that left two empty floodplain downloads which every later species read as cache hits.

## Evidence

`scripts/logs/habitat/20261017_*` (link settle, evidence-build ledger, tune run, the compare attempts, compare,
compare-maps) and `scripts/logs/habitat/20261018_tune_run-wct-rerun.out`; `data/tune/`, `data/compare/`,
`data/thresholds*.csv`; the four review rounds in this directory (`review-round1.md` to `review-round4.md`).

Closed by: PR #61.
