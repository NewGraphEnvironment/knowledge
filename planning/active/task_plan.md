# Task: Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

Third branch of #120 (the first two are PRs #135 and #138).

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch 86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m; link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches, but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92), so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's half: NewGraphEnvironment/link#415, with outputs named from NewGraphEnvironment/link#414. The minimal network still cuts at access gradients, and those cuts depend on which species link models and at which classes (0.15, 0.20, 0.25 and 0.30, each species cut at every class at or above the steepest gradient it passes), so pausing a species (NewGraphEnvironment/link#432, NewGraphEnvironment/link#433) or changing a class moves the segments a minimal-network tuning reads; #132 reviews the classes themselves.

## Context

#120's last open work. link#444 built `fresh_default.streams_parent` (5,546,370 rows, all 241 groups, beside
`fresh_default_minimal`), so the "full, parent gradient" setup can now be scored. The goal is to score chinook rearing
on every setup that exists, from one flow load and species range, so that the network and the gradient are the only
differences between setups. Each setup is reported with its pick, region membership, km drawn and graded, and a map
of where the drawn habitat differs, then archived under its link tokens. #149 (the public article) is blocked on this
run. Branch `120-chinook-rearing-every-setup` off `main` (`6f4499e`); both earlier #120 branches are merged (#135, #138).

| setup | segments | gradient read | state today | this branch |
|---|---|---|---|---|
| published | full (`cut-full-top`) | own segment | promoted run `20261104_0543` | read only |
| minimal | minimal (`cut-min`) | own segment | candidate `20261103_0838`, archived | read only |
| full, parent gradient | full | minimal parent's (`grad-parent`) | none | evidence, grade, compare, archive |
| Atlas line | full | FWA segment's own | `DEV`-level sensitivity (`data/tune/grad_fwa/`) | graded candidate and compare; link token requested |
| other access classes / fixed window | | | wait on #132 / #70 | untouched |

All four read wet's 2026-10-24 flow load and link 0.78.1's range, on m4's database (`PGSERVICE=fresh_local`), where
`data/fdis/derived` is the promoted build's evidence (md5 `db5ca99a…`, matching the grade record).

## Decided at the gate (Al, 2026-11-04)

- **Each setup is graded, not given a carried grade.** Grading, the comparison and the archive take a gradient
  source (the segment's own, its minimal parent's, or its FWA segment's), so the parent and Atlas setups become
  ordinary graded candidate runs (`0320` → `0330` → `0336`). Al first chose to carry the parent's grade, then chose
  this when it was offered, because the Atlas line gets graded km too and the archive needs no second path.
- **The Atlas line is drawn and graded, and gets a link token.** A link issue asks for a `grad` token naming the FWA
  segment's own gradient (Al: "isn't a token helpful regardless for cataloguing and statistics?"). The run is archived
  under that token once link mints it.
- Approving this plan is Al's word for the two chinook-rearing candidate runs (parent, Atlas) and their comparisons.
  **No promotion:** both are refused by `knw_tune_promote()`, `0325` and `0335`, whose segment-gradient guards stay.
- Installed link stays at 0.78.1 for `0310`, so the parent evidence reads the same range as the published evidence.

## Phase 1: the parent from link's table

- [x] `knw_parent_read(conn, schema, minimal_schema)`: reads `<schema>.streams_parent` and maps
      `watershed_group_code` to `knw_parent_join()`'s `wsg`. Refuses a table whose `run_id_full` values are not runs
      `knw_build_record(conn, schema)` names, or whose `run_uid_minimal` is not `minimal_schema`'s build. That closes
      #120 round 4's "a parent table of another run joins silently" through the table's own provenance, beside the
      existing length check. Tests: fixtures for each refusal, with each guard shown to fire by restoring the bug.
- [x] `0310`: `PARENT=TRUE` (with `PARENT_MINIMAL`, default `fresh_default_minimal`) joins the table.
      `PARENT_DIR` stays for link's four-group proof schemas, which have no table. Ledger rows as for `PARENT_DIR`,
      plus the table's provenance.
- [x] Run `SCHEMA=fresh_default PARENT=TRUE EVIDENCE_DIR=data/fdis/derived_parent 0310` on m4. Check:
      `visits_species.csv` and `walks.csv` are byte-identical to `data/fdis/derived`, and `visits_link.csv` equals it
      apart from the four parent columns.
- [x] Mechanics on the table: `minimal_network_check.R` step 4, `derived_parent` against `derived_minimal`,
      province-wide. Every visit's parent should be the minimal segment it sits on, with that segment's gradient,
      apart from straddles. Then tick #120's line and link#444's first acceptance line, with the result written into
      link#444's body.
- [x] `DEV=1 GRADIENT=parent_gradient SPECIES=CH EVIDENCE_DIR=data/fdis/derived_parent DEV_DIR=data/tune/dev_parent 0320`:
      the parent setup's pick against the minimal network's (`mad>=0.75|g<=0.09|Q3@D1000`). These should agree, as
      they did on the four groups.

## Phase 2: grading and the comparison on a chosen gradient

- [x] `knw_link_segments(conn, schema, species, wsg, gradient = "segment")`: `"parent"` reads
      `p.gradient_minimal` from `<schema>.streams_parent` (an inner join that refuses a segment with no row); `"fwa"`
      reads `whse_basemapping.fwa_stream_networks_sp.gradient` on `linear_feature_id` (no link segment crosses an FWA
      segment, link#444).
- [x] (kept `.knw_grade_grad` as the publishable value; `.knw_grade_grads` is the lookup) `.knw_grade_grad` becomes a lookup (`segment_gradient` → segment, `parent_gradient` → parent, `fwa_gradient` →
      fwa). `knw_grade_species()` grades with the curve's own gradient read from that source, and refuses any other.
- [x] `knw_compare_rules(gradient =)`: the scratch copy's `gradient` comes from that source, so `default`, the tuned
      rule, the other stage and the connectivity pass all read it, as a `grad-parent` build would.
- [x] `0320`: `SETUP=1` with `GRADIENT=parent_gradient|fwa_gradient` makes a graded candidate of its own (every seed
      and check), separate from the main run's sensitivity (`GRADIENT=fwa_gradient RUN=<main>` is unchanged). Its
      grade record carries the setup's `token_grad` (`grad-parent`, or link's Atlas token) in place of the build's
      `grad-seg`.
- [x] `0330`: takes the gradient from the curves' `curve_grad` (all keys of a run must agree), relaxes its stale check
      to "the curve's gradient is one grading supports", and passes it to `knw_compare_rules()`.
- [x] Refusal tests: `knw_tune_promote()`, `0325` and the article bundles refuse `curve_grad` other than
      `segment_gradient`, shown by restoring the bug. Add a settings-register row if a new number shapes a result.
      (Review G1: promotion has no such guard today; it is added, not kept.)
- [x] `0320 SETUP=1` (review G2, Q3): writes the run root (not `grad_fwa/`), runs every seed and check, needs no
      `RUN=`, logs as `-setup_<parent|fwa>`; refused over a run whose summaries name another `curve_grad`, and the
      sensitivity (`GRADIENT=… RUN=`) refused on a SETUP run. `token_grad` from a fixed map of `curve_grad`
      (`grad-parent`; `grad-fwa`, the name the link issue proposes), checked against it (review G3).
- [x] File the link issue for the Atlas-line `grad` token now (review ordering), proposing `grad-fwa`: link#460.
- [x] `data/compare/setups/` in `.gitignore` (review G5).

## Phase 3: the two chinook-rearing runs (m4)

- [x] `SETUP=1 GRADIENT=parent_gradient SPECIES=CH EVIDENCE_DIR=data/fdis/derived_parent 0320` →
      `0330 TUNE_DIR=<run> SPECIES=CH` (GeoPackage on).
- [x] (run as `GRADIENT=segment_fwa_gradient` on `derived_parent`, findings) `SETUP=1 GRADIENT=fwa_gradient SPECIES=CH 0320` (published evidence) → `0330`.
- [x] Read `pg_stat_activity` before timing anything. Each run's log and minutes go to
      `scripts/logs/habitat/every_setup_120/`.

## Phase 4: the every-setup report and the map

- [x] (it reads the database for the parent map and geometry) `data-raw/setup_compare.R` (no database): for each of the four setups, its pick, whether every other setup's pick
      lies in its region (from each `CH_rear_tune.csv`), how far behind its best each sits (deviance / SE), and km
      drawn (`default` and tuned) and graded. The transfer cost is the minimal setup's km against the parent setup's.
      Writes `scripts/logs/habitat/<date>_setup_compare.{csv,txt}`, holding input md5s and the commit.
- [x] The map: on the full network's segments, each setup's tuned verdict, with the minimal network's carried through
      `streams_parent`. Write `data/compare/setups/CH_rear_setups.gpkg` (ignored) for QGIS, and one static figure in
      `research/fig/` (tmap and gq, per the cartography conventions) for the group chosen by a criterion stated before
      drawing: the most km where the setups' tuned verdicts disagree, among groups with chinook `default` rearing.

## Phase 5: archive

- [x] `RUN=<parent run> EVIDENCE_DIR=data/fdis/derived_parent 0336` →
      `archive/knowledge/tune/CH_rear/cut-full-top.acc-v5.grad-parent.q-fwapg/`, with the `derived_parent` evidence.
      Commit the `data/archive_index.csv` rows.
- [ ] The Atlas run is archived when link mints its token (owed below); `knw_archive_setup()` refuses it until then.

## Phase 6: write-up

- [x] `research/minimal_network_tuning.md`: a section "Chinook rearing on every setup" (a plain-language walk, then the
      table and the transfer cost), its header and "What each break source does"; `research/README.md` if needed.
- [x] `scripts/README.md` and `CLAUDE.md`: `PARENT=TRUE`, `SETUP=1`, and grading on a chosen gradient.
- [ ] #120 body: tick the lines, set each row's status in the setup table; #149 body: unblocked, with the run's names.

## Owed at the end (reported, done after merge)

- [ ] Archive the Atlas-line run under link's new token once it is minted.
- [ ] #149: the public article and the methodology article's short section (#120's last task stays listed until it
      lands, so this PR relates to #120 rather than closing it).
- [ ] Other species on every setup, one at a time; "other access classes" (#132) and "fixed window" (#70).

## Validation

- [ ] Tests pass (`devtools::test()`), lintr clean, `devtools::document()`
- [ ] `/code-check branch` clean, three-round floor
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Acceptance criteria fixed before the runs (review): "the parent and minimal picks agree" means each pick lies in
the other's one-SE region, the exact same rule being the stronger result; `visits_link.csv` is compared column by
column (0310 inserts the parent columns mid-table); `stored_vs_default_differ_km` is nonzero on the parent and Atlas
setups by design, since link stores the segment gradient's flags; the parent run's grade record must read
`curve_grad = parent_gradient`, `token_grad = grad-parent`, `run_uid = 20261103_163715-269b585a`, and the Atlas run's
`fwa_gradient` / `grad-fwa`. The evidence's Atlas gradient is the visit's own `linear_feature_id`'s and grading reads
the segment's: count the visits where the two ids differ.

How each change is proved: the parent reader by fixture tests of each refusal with the bug restored. The swap by the
segment source reproducing today's grades and comparison exactly (a regression test on a fixture, and the published
CH grade table's rows for one group reproduced by a regrade of that group with `gradient = "segment"`). The evidence by
byte comparison with `data/fdis/derived`. The mechanics by step 4's counts. The parent setup by its DEV pick against
the minimal pick. Each run by its smoke gates and its grade record's fields.

