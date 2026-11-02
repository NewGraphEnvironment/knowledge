# Tuning on link's minimal network

**Verified:** 2026-11-02 · **Issues:** #120 (link's side: NewGraphEnvironment/link#415, link#441, link#444) ·
**Produced by:** `scripts/0300`, `0310`, `0320`, `0330` on link's four-group proof schemas, and
`data-raw/minimal_network_check.R`, `segment_gradient_check.R`, `site_gradient_check.R`; logs
`scripts/logs/habitat/20261102_*` and `scripts/logs/habitat/minimal_network_120/` · **Status:** the four-group test of
mechanics is done; the province waits on link's provincial minimal run (link#441) and its parent table (link#444).

## The answer

link cuts its streams at the fish records of the species it models, so on its full network a site where fish were
caught usually starts a segment of its own, and the gradient a rule reads there is averaged over a stretch that begins
at the catch. link's minimal network is cut only at barriers and access gradients. On link's four proof groups (BULK,
SETN, MORK and COTR), the minimal network removes the catch from the segment:

| network | stream-branch visits with fish starting their own segment | empty visits starting one | median segment length, fish / empty |
|---|---|---|---|
| full (`zz415_default`, `cut-full-top`) | 52.0 % | 5.8 % | 298 m / 458 m |
| minimal (`zz415_minimal`, `cut-min`) | 2.8 % | 1.5 % | 742 m / 742 m |

Nothing else the tuning reads moves between the two networks. The same 2,082 visits are placed on both, on the same
stream and measure; the walks to rivers and every species' outcome are byte-identical; and every species' accessible
km is equal in every group. A full segment given its minimal parent's gradient reads exactly the gradient the minimal
network reads at all 2,082 visits, so a rule tuned on the minimal network transfers to the full one through the parent:
on bull trout rearing, the one key four groups can fit, the two setups give byte-identical scores and curves.

These are four groups and a test of the mechanics. No threshold rests on them.

## The setups

Each setup holds the evidence, the flows and the walks fixed and changes only the segments or the gradient read.

| setup | segments | gradient a rule reads | on the four groups |
|---|---|---|---|
| full | full | its own segment's | scored, graded and compared (bull trout rearing) |
| minimal | minimal | its own segment's | scored, graded and compared (bull trout rearing) |
| full, parent gradient | full | its minimal parent's | scored; a grade and a comparison need the parent on link's full network (link#444) |
| Atlas line | full | the whole Atlas line's | scored |
| minimal, other access classes | minimal, cut at another set of access gradients | its own segment's | needs a link build cut that way |
| fixed window | full | a fixed window's | needs fresh to provide one (#70) |

"Published" is the full setup on the province-wide build; on these four groups the full setup stands in for it.

## Each check, in the order it ran

All on 2026-11-02, on the database link's proof schemas live in, through `PGSERVICE` (round trip 1.0 ms), with link
0.78.1 and fresh 0.52.0 installed and link's build at 0.78.0 (`6bf9ca06`). The flows are wet's load of 2026-10-15,
not the 2026-10-19 load the published grades name, so nothing here is compared with a published number.

| check | result | log |
|---|---|---|
| Settle (`0300`, `POLL_MIN=1`) | both schemas released after three equal polls; runs `415_recompute_default` and `415_recompute_minimal` | `20261102_link_settle-zz415_*.csv` |
| Build record | the tokens read from `<schema>.log`: `cut-full-top.acc-v5.grad-seg.q-fwapg` and `cut-min.acc-v5.grad-seg.q-fwapg` | the ledgers' `build_record` rows |
| Evidence (`0310`) | 2,082 visits placed on each; the other 43,625 lie outside the four groups. Walks 0.4 min cold on the full build; the minimal build read all 5,724 start-and-source pairs from the cache | `20261102_evidence_build_ledger-derived_zz415_*.csv` |
| Placement | every visit on both networks at one blue line, measure and Atlas line; 36 of 227 columns differ, all of them the segment's own (its elevation among them), access codes or habitat flags | `20261102_minimal_network_check.txt` |
| Walks and outcomes | `walks.csv` (40,068 rows) and `visits_species.csv` (22,902 rows) byte-identical | the same |
| Access | accessible km equal in every species × group cell. Access codes differ at 141 visit × species pairs, every one 1 on the full network and 2 on the minimal; none crosses zero, and code 2 is never a covariate | the same |
| Parent | every visit's parent is the minimal segment it sits on, with its gradient; no visit sits on a full segment that straddles a minimal break; 1,175 visits read another gradient on their full segment than on its parent | the same |
| Premise | the table above: the catch-start gap closes on the minimal network | `20261102_segment_gradient_check-derived_zz415_*.txt` |
| Tuning (`DEV=1 0320`, nine species, `MIN_WSG=4 FOLDS=4`) | bull trout rearing is the one key fitted (4 groups with both outcomes, underpowered). Minimal and full-parent give byte-identical tables and curves; full picks the same rule from a narrower region (87 rules against 117); the Atlas line picks a 20 % gradient limit against 25 %. Every other key is `too_few_groups`, `no_response` or `no_stream_rule`. Each run took 0.2 min for 18 keys | `minimal_network_120/dev_zz415_*` |
| Grading (`0320` with grades) | chinook rearing has both outcomes in three groups; at `MIN_WSG=3 FOLDS=3` the smoke gate refuses it (the previous pick's rule coefficient reaches 20.0 on one fold, against a limit of 5: separation). Bull trout rearing was graded on both networks instead (4.3 and 4.1 min); its grades are withheld, the curve being no better than no rule on held-out groups | `minimal_network_120/20261102_tune_run-*` |
| Comparison (`0330`, bull trout rearing) | `default` regenerated through all three stages equals link's stored km in every group on both networks (0 km differing); 0.6 and 0.7 min | `minimal_network_120/20261102_compare-*` |
| Stored habitat | link stores more rearing on the minimal network than on the full one: chinook 104, 97, 59 and 6 km more in BULK, COTR, MORK and SETN, bull trout 5–49 km, steelhead 8–122 km; spawning moves by under 10 km either way. The chinook figures #120 quoted are the minimal network's | `20261102_minimal_network_check.txt`, step 5 |
| Measured gradient (#121's check) | on the same 1,178 stream-branch visits with a measured gradient, the segment gradient's rank correlation with it is 0.696 on both networks; chinook rearing's 11 % limit puts a visit on the other side of its measured gradient on 8.5 % (minimal) and 8.7 % (full) | `20261102_site_gradient_check.txt` (minimal), `-2.txt` (full) |

On link 0.66.0's province-wide build, 86 % of stream-branch visits with fish started a segment of their own against
10 % of empty ones (#92). link has changed which records it cuts at since then (link#396), and these
are four groups, so the 52 % here is not compared with it.

## What four groups cannot show

- **A threshold.** Only bull trout rearing has four groups holding both outcomes, and its curve is no better than no
  rule. Chinook rearing has three, and the smoke gate refuses its fit there.
- **The transfer cost in km.** Where "minimal" and "full, parent gradient" draw different habitat needs a grade and a
  comparison on the full network with the parent's gradient, which reads link's parent table on the full schema
  (link#444).
- **Access at a dam in a neighbouring group.** link built each proof group without its downstream neighbours, so
  access read through another group's dams may be incomplete. Both networks were built the same way, so their access
  agrees here.
- **The floors.** The tuning fits a key with at least five groups holding both outcomes, on five folds. These runs used
  four and four (three and three for the chinook attempt); each summary records them and `knw_tune_promote()` refuses
  them.

## How the runs are set up

- **link's tokens** are on `<schema>.log`, one row per pipeline call and group. `knw_build_record()` reads them over
  every row and refuses a schema whose rows mix a token with none; the run check stays on `log_recompute`, whose run
  id can differ from the build's (`415_recompute_minimal` against `415_minimal`).
- **A build's evidence directory.** `0310` takes `EVIDENCE_DIR`; a directory other than `data/fdis/derived` tags its
  ledger with the directory's base name, outside the name the default readers take. `0320` (with `DEV_DIR`)
  and the checks read the directory and find its ledger by it; `0330` reads the directory and ledger the run's
  summaries name, and holds the tables to the curves' md5s. `0310` refuses the default directory to a build settled
  on another schema's log.
- **The settle log** takes `SCHEMA` and `POLL_MIN` and records both; `0310` takes it with `SETTLE=` and gates on its
  run id, never its schema.
- **The parent.** `0310` joins link's `parent_<wsg>.csv.gz` with `PARENT_DIR` (`knw_parent_join()`), adding
  `parent_gradient`, `parent_length_m` and `parent_straddle_m`; a placed visit with no parent stops the build.
  `0320` scores `GRADIENT=parent_gradient` into `grad_parent/`, which is never promoted.
- **The floors.** `0320` takes `MIN_WSG` and `FOLDS` (default 5 and 5).
- **Access per group.** `access_check.csv` is per species × group, so two builds of the same groups can be set side by
  side.
