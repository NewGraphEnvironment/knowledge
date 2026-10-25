# #73: Rebuild the evidence and retune on the republished flows, with the walk ending at the river's bank

## Outcome

The evidence build (`0310`) was rerun on wet's 2026-10-19 flows with the river walk ending at a double-line river's
bank by fresh 0.42.0's rule, every species' gradient ladder extended to 30 % (#68), and a second pick read from link's
flow version of `default` (#80). The first tuning of CH and CO on it exposed a curve-intercept refit that ran away, and
the four-species run a second scorer defect, the held-out intercept search stopping on the clamp's plateau; the retune
was held while the tuning was organised (#84: a smoke run on four gates before any grid is scored; #83: the fit with
the group intercepts absorbed, which cut a scoring from 110 min to 17, with a normal prior SD 2.5 on the data-set and
era coefficients adopted on a measurement over every key). Every key was then rescored on m4 and graded on the
database's host (m4's grading crawled at 104 ms a query), the curve given the grid's prior, a gate adopted that
withholds grades from a key whose curve is no better than no rule on held-out groups, every key recompared under
link's through-wetland structures with a GeoPackage per key (#81), `near_river_scope` added to the thresholds table,
and the eight research files rewritten prior-first with a plain-words walk per species. The branch review (five
rounds) found the gate comparing the curve, scored over the visits with a size, with no rule over every modelled
visit: scored like for like, bull trout spawning's grade is withdrawn and the margins of the width-ruled keys shrink;
the fix put the gate's number, the evidence's identity and the pick on every record a later run reads back, with every
reader refusing a record that does not match. The regrade and recompare that make the tables on disk agree with the
corrected gate run on the database's host before merge (Owed). What was learned, generalised: a verdict written by a
run outlives a fix to the rule that made it unless the record carries the rule's own number and the reader compares
it; a database-bound step belongs on the database's host; and a check that reads two populations summed as one is
found only by scoring both on the same rows.

## Measurement

- **The walk to the bank** (`data-raw/walk_bank_check.R`, BULK, 2,460 starts): 0 differ from fresh's walk by the bank
  rule; 92.6 % of the 2,006 starts both found agree within 0.01 m; the correction is positive on 67 % of found starts,
  median 31.8 m, 90th percentile 66.1 m, largest 599 m (#65 had estimated the connector at a median of 14–88 m).
- **The scorer.** The fit with the groups absorbed reproduces the dense reference on six species rule by rule (110 min
  to 17; rainbow with every extra 16.6 min on m4's 12 workers against 8.1 h on the laptop). Without a prior the
  coefficient gate fails on GR, RB, ST and WCT (era or data set at 10 to 20 on the cloglog scale); at SD 2.5 every gate
  passes on every key and the largest coefficient is 3.12. The intercept search as the root of the deviance's
  derivative leaves no visit at the clamp (ST's no-rule model had scored 3,372 on both golden sections).
- **Where a step runs.** A trivial query costs 1.6 ms on the database's host and 104 ms from m4 (50 each); m4's grading
  ran 7.5 h without finishing one species' walk; the host graded every key in 224.6 min, and regraded in 190.9. `0330`
  one key at a time held one database core (about 5 h for five keys); every key in one process on six workers, 160 min.
  Bulk copies to m4 ran at 3.2 MB/s and the grade tables compress about 16×, so the 20 GB of ignored tables moved as one
  2.97 GB archive.
- **The picks.** BT rearing MAD ≥ 0.1 at 10.49 % (the first reading, under the defective search, from a 594-rule
  region) → MAD ≥ 0.35 at 25 % (the best rule, 316-rule region); RB width ≥ 3 m at 9 % → at 30 %; WCT width ≥ 1.5 m at
  4 % → MAD ≥ 0.03 at 30 % (underpowered); CH MAD ≥ 0.75 at 13 % with a 3 m³/s river within 1 km (9 % before the
  ladder); BT spawning width ≥ 2 m at 13 %, CO MAD ≥ 0.03 at 4 %, GR `default`, ST MAD ≥ 1 at 8.49 % unchanged.
- **The curve's prior and the gate.** The prior moved steelhead's curve from 860.8 to 553.8 held-out and grayling's
  from 786.9 to 743.6. Grades withheld: CO (4,092.0 against 4,021.5 for no rule on the curve's visits), ST (553.8
  against 419.1), WCT (1,453.4 against 1,329.7) and, after the review, BT spawning (397.3 against 378.8; it had passed
  by 4.2 against the grid's 401.4). The graded keys' margins over no rule on their own visits: BT rearing 407.9, CH
  321.5, GR 20.3 (84.4 against the grid's), RB 906.1 (3,207.6).
- **What the rules change on link's segments** (door): BT rearing 244,328 → 142,015 km (−41.9 %), BT spawning 133,382
  → 169,416 (+27.0 %), CH 99,186 → 84,294 (−15.0 %), CO −5.5 %, GR unchanged, RB −17.4 %, ST −41.2 %, WCT +18.4 %.
- **Wrong turns kept.** The first #73 bull trout write-up (2026-10-23) rested on the defective search's pick; the
  2026-10-24 grade of bull trout spawning rested on an unlike-population comparison; grading was started on m4 before
  the round-trip cost was measured.

## Evidence

`scripts/logs/habitat/20261022_*`, `20261023_*`, `20261024_*` (the evidence ledger, the walk check, the tune and compare
logs, the chain scripts); `planning/archive/2026-10-issue-73-rebuild-evidence-retune-bank/scratch/logs/2026102*` (the
runs' stdout, the probes' logs); `planning/archive/2026-10-issue-73-rebuild-evidence-retune-bank/review-round{1..5}.md`
(the review, its triage and the enumeration that ended it).

## Owed

Before merge, on the database's host:

- `SCHEMA=fresh_default_20261017 Rscript scripts/0320-tune-run.R` from a frozen copy at the branch's head (scores
  cached; every curve refits and the gate now scores no rule on the curve's own visits; every grade table is
  regraded, because none carries `null_heldout_curve`, which `0325` and `0330` now require: about 190 min on the
  host; BT_spawn's verdict moves to withheld and every summary gains the column), then
  `SCHEMA=fresh_default_20261017 SPECIES=BT Rscript scripts/0330-compare.R` (BT spawning's graded km to NA), then
  `Rscript scripts/0325-publish.R` and `SCHEMA=fresh_default_20261017 Rscript data-raw/vignette_chinook.R` (the
  CH summary's md5 moves), then the BT spawning sentences in `research/bull_trout_tuned.md` and
  `habitat_thresholds_tuned.md` that say the table on disk is the 2026-10-24 one

After merge:

- link#346's body: one line naming the published table's columns for the pair and the scope the comparison
  recommends per species
- #81's body: which tasks landed here (no maps in the default run, the GeoPackage) and which remain
- #72, #68 and #80 bodies: what landed, then close with #73 when the PR merges
- `PUBLISH=TRUE` for `0299` v3, `0325` thresholds and grade, once #56's bucket policy is in

Closed by: PR #88 (https://github.com/NewGraphEnvironment/knowledge/pull/88), from the branch
`73-rebuild-the-evidence-and-retune-on-the-r`; the host-side regrade listed under Owed runs before it merges. #83 and
#84's bodies still carry unticked boxes to reconcile with what landed here (owed after merge).
