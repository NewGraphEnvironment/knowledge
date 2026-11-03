# Tuning on link's minimal network

**Verified:** 2026-11-03 (province), 2026-11-02 (four groups) · **Issues:** #120 (link's side:
NewGraphEnvironment/link#415, link#441, link#444) · **Produced by:** `scripts/0300`, `0310`, `0320`, `0330` on the
provincial minimal build `fresh_default_minimal` and on link's four-group proof schemas, and
`data-raw/minimal_network_check.R`, `segment_gradient_check.R`, `site_gradient_check.R`; logs
`scripts/logs/habitat/2026110[23]_*` and `scripts/logs/habitat/minimal_network_120/` · **Status:** the nine species link models
on the minimal build tuned on it, and the seven keys fitted (six species; the other eleven keys have no response or no stream rule)
graded and compared, as an unpromoted candidate (run `20261103_0838`; rainbow trout and kokanee are paused there); separating
the network from the flow load and species range waits on the next full `default` build, and the transfer to link's
full network on its parent table (link#444).

## The answer

link cuts its streams at the fish records of the species it models, so on its full network a site where fish were
caught usually starts a segment of its own, and the gradient a rule reads there is averaged over a stretch that begins
at the catch. A rule could then be credited for where fish were caught rather than for the stream's form. link's
minimal network (`fresh_default_minimal`, link#441, run `20261102_203300-60ab009d`) is cut only at barriers and access
gradients. On all 241 watershed groups it takes the catch out of the segment:

| network | stream-branch visits with fish starting their own segment | empty visits starting one | median segment length, fish / empty |
|---|---|---|---|
| published full network (link 0.66.0, every observation a break) | 86 % | 10 % | 113 m / 305 m |
| minimal network (link 0.78.1, `cut-min`) | 3.4 % | 3.0 % | 717 m / 699 m |

A rule's score is how well it predicts fish in groups held out of the fit; the tuning picks the simplest of the rules
the data cannot rank apart from the best (within one standard error of it, the rule's "region"). Of the seven keys
fitted on the minimal network, every published rule is inside its key's region, so the minimal network rejects none
of them. Two keys pick the published rule again. Chinook, grayling and steelhead rearing move one or two steps on one
part of the rule. Bull trout moves further: rearing goes from no working gradient limit (30 %) to 10.5 %, seven steps
down the gradient ladder, with a MAD floor four steps up (0.1 to 0.35 m³/s), and spawning's limit goes from 13 % to
25 %, three steps. Rainbow trout rearing has a published rule but is paused on this build (link models nine species
there), so it was not tested.

| key | minimal network's pick | published pick | published rule behind the minimal network's best (deviance / its standard error) |
|---|---|---|---|
| bull trout rearing | `mad>=0.35\|g<=0.1049\|none` | `mad>=0.1\|g<=0.3\|none` | 2.71 / 11.17 |
| bull trout spawning | `width>=2\|g<=0.25\|Q1@D500` | `width>=2\|g<=0.13\|Q1@D500` | 1.41 / 4.04 |
| chinook rearing | `mad>=0.75\|g<=0.09\|Q3@D1000` | `mad>=0.75\|g<=0.11\|Q3@D1000` | 4.55 / 7.97 |
| coho rearing | the same | `mad>=0.1\|g<=0.0549\|Q3@D2000` | 11.68 / 30.48 |
| grayling rearing | `width>=1.5\|g<=0.0549\|none` | `width>=2\|g<=0.0549\|none` | 3.92 / 5.25 |
| steelhead rearing | `mad>=0.5\|g<=0.0849\|Q1@D250` | `mad>=1\|g<=0.0849\|Q1@D250` | 16.91 / 19.30 |
| westslope cutthroat rearing (underpowered) | the same | `mad>=0.03\|g<=0.25\|none` | 0 |

These picks differ from the published ones in three ways at once, not only the network. The minimal build reads wet's
flow load of 2026-10-24, the published grades its load of 2026-10-19; and `0310` takes each species' range from the
installed link's presence table, which link's presence review (link#402) changed after the published build's link
0.66.0 (12,083 visit × species rows moved, `in_range` only). A tuning on the next full `default` build with this
evidence's flows and range separates the network from the other two. Until then, the table says the minimal network
leaves each published rule it tested standing, not that it moves any.

Chinook rearing's gradient limit reads three ways, each on 4,858 visits: 11 % on the published full network (164
rules in region), 9 % on the minimal network (102), and 15 % on the whole Atlas line (117, `data/tune/grad_fwa/`, on
the published evidence). The flow floor (MAD ≥ 0.75 m³/s) and the near-river exception (a stream below the floor
still counts where a river of at least 3 m³/s lies within 1 km downstream) hold on all three.

## The province run

All on 2026-11-03 UTC, on the database the minimal build lives in, through `PGSERVICE` (round trip 0.8 to 1.1 ms),
link 0.78.1 (`193cb8aa`), fresh 0.53.0 installed (the build ran on 0.52.0), and wet's flow load of 2026-10-24
(`b4bbc50`), loaded for this run because that database held an older one. The published build's database keeps the
2026-10-19 load its grades name, and wet keeps no older manifest, so the two loads now live one per database.

| step | result | log |
|---|---|---|
| Settle (`0300`, `POLL_MIN=1`) | released after three equal polls: 241 of 241 groups | `20261102_link_settle-fresh_default_minimal.csv` |
| Evidence (`0310`, `EVIDENCE_DIR=data/fdis/derived_minimal`) | 23 min; 45,529 visits placed, the published build's count; every walk cold on the new load (110,784 start-and-source pairs, 4.7 min) | `20261103_evidence_build_ledger-derived_minimal.csv`, `minimal_network_120/20261103_evidence_build.log` |
| Placement (`minimal_network_check.R`, steps 1 and 2) | every visit at the same blue line, measure and Atlas line as on the published build. 172 sit on a minimal segment that runs across Atlas lines and keeps another line's id; the visit's flow, width and walks read the visit's own line, so nothing the tuning reads moves | `minimal_network_120/20261103_minimal_network_check_console.log` |
| Premise (`segment_gradient_check.R`) | the table above; by each species' own outcome the share is 0 to 5.6 % either way | `20261103_segment_gradient_check-derived_minimal.txt` |
| Measured gradient (#121's check) | on 16,279 stream-branch visits with a gradient measured on site, the minimal segment's gradient ranks them with a correlation of 0.678 (published full network 0.690; the Atlas line 0.653 on both). Chinook rearing's 11 % limit puts 5.9 % of its 2,453 visits on the other side of their measured gradient (published 6.4 %, Atlas line 11.6 %). Each published limit, minimal network against full: bull trout rearing 0.6 % (0.8), steelhead rearing 14.2 % (17.0), coho rearing 25.5 % (25.8), grayling rearing 11.4 % (11.7), westslope cutthroat rearing 0.7 % (0.7), and two the other way, bull trout spawning 8.7 % (8.5) and rainbow trout rearing 0.8 % (0.7) | `20261103_site_gradient_check.txt` beside `20261030_site_gradient_check.txt` |
| Tuning (`DEV=1 0320`, nine species) | 5.4 min on 14 workers; every smoke gate passed; the pick table above | `minimal_network_120/20261103_tune_run-*-dev.txt`, `minimal_network_120/20261103_dev_minimal_pick_report.csv` |
| Grading (`0320`, run `20261103_0838`) | 70.9 min; the same picks; grades withheld for coho and westslope cutthroat rearing, as on the published run. The minimal network has 52 to 67 % fewer segments per key (chinook 2.65 million against 5.76 million) | `minimal_network_120/20261103_tune_run-20261103_0838-*.txt` |
| Comparison (`0330`, `GPKG=FALSE`, `default` and the tuned rule only) | 43.5 min on 6 connections; km below. `default` regenerated through all three stages reproduces link's stored km to within 0.02 % per key (residue below) | `minimal_network_120/20261103_compare_console.log` |

Habitat drawn on the minimal network, `default` against its tuned rule, both regenerated on the same build (the
run's own `compare.csv`, all groups). The published comparison is beside it only as a bracket: another network, link
build, flow load and range, so its column is not a difference due to the network.

| key | `default` km | tuned km | change | published run's change |
|---|---|---|---|---|
| bull trout rearing | 248,016 | 141,049 | −43.1 % | −23.7 % |
| bull trout spawning | 134,200 | 221,448 | +65.0 % | +49.5 % |
| chinook rearing | 104,751 | 87,606 | −16.4 % | −15.9 % |
| coho rearing | 90,350 | 88,006 | −2.6 % | −2.3 % |
| steelhead rearing | 84,880 | 70,007 | −17.5 % | −27.0 % |
| grayling rearing | 78,208 | 87,066 | +11.3 % | +3.4 % |
| westslope cutthroat rearing | 20,613 | 24,416 | +18.4 % | +18.0 % |

The residue between regenerated `default` and link's stored flags: 0 km for bull trout spawning; 0.05 to 9.3 km for
the other keys (chinook 9.3 km of 104,751, 8.5 km of it in TESR), in one to nine groups each. Almost every differing
segment is one link stores as rearing and the regeneration drops; the regenerated predicate passes every one, so the difference is
in the last stage, which drops rearing with no spawning within 10 km. In TESR chinook and grayling differ on the same
segments, 41 of chinook's 42 there; 37 of the 42 are construction lines inside lake polygons (edge types 1200 and
1450, by waterbody key) and 5 are single-line streams. Ruled out: spawning upstream in another group, the access gate (0 km
differ), user habitat, and fresh's version (the connectivity code is the same in 0.52.0, which built the schema, and
0.53.0, which regenerated it); link runs that stage one group at a time, as the comparison does. The cause is not
established. It does not touch the comparison above, which regenerates both rules the same way.

Steps 3 to 5 of `minimal_network_check.R` (access per group, the parent, stored habitat) need the published evidence
rebuilt per group, which the published build predates; they wait on the next full `default` build.

## What each break source does, as far as these runs show

- **Fish records.** On the full network they put a catch at the start of its segment (86 % against 10 %); the
  minimal network takes that away (3.4 % against 3.0 %), so a segment's length, and so its gradient, no longer
  depends on the outcome. Taking out every break but barriers and access gradients together (fish records,
  crossings and habitat end points, on another link version) barely moves the segment gradient's agreement with
  gradients measured on site (0.678 against 0.690); these runs cannot say how much of that any one break source
  carries.
- **Crossings and habitat end points.** The minimal network drops these with the fish records, so these runs cannot
  tell their effect apart.
- **Access gradients.** The minimal network still cuts at them: for each species link models, at every class
  (0.15, 0.20, 0.25, 0.30) at or above the steepest gradient that species passes (`.lnk_pipeline_prep_minimal()`). Cutting at another set is "minimal, other access classes" (#132).
- **Transfer.** link deploys a rule on its full network. A full segment given its minimal parent's gradient reads the
  minimal network's gradient at every visit (shown on four groups below); the habitat km that transfer draws needs
  link's parent table on the full network (link#444).

## The four-group test (2026-11-02)

Before the province, the mechanics ran on link's four proof groups (BULK, SETN, MORK and COTR), each network built
from one link commit, so the network was the only difference. There too the minimal network removes the catch from the
segment:

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

### The setups

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

### Each check, in the order it ran

All on 2026-11-02, on the database link's proof schemas live in, through `PGSERVICE` (round trip 0.8 to 1.0 ms), with link
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

### What four groups cannot show

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
