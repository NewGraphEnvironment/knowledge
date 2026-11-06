# #160: receipts for the evidence build and the published visit tables

## Outcome

The evidence build and the published visit set now carry crate receipts, and the rule the provenance track started
from is written down as a declaration. `scripts/0310` writes `evidence_receipt.json` beside its tables
(`knw_evidence_receipt_write()`, held to `inst/receipt/evidence.yaml`): every table exact except `access_check`'s km,
rounded to 1e-6 km. The recipe is knowledge's commit, the method register and the walk, the build's settings, link's
build and its installed default configs, wet's flow load, the FDIS extract and 0230's load of it, the tracked tables
0310 reads, and the hydrologic zones; each input is hashed as it is read.

A grade receipt now names the evidence as one input, `evidence`. It is the build's receipt's `recipe_id`, or the visit
tables' md5s for a build from before receipts, so an equivalent evidence rebuild is the same input to every grade.
`0320` reads that input at its start and regrades a kept table whose receipt names other evidence.

`0299` publishes through `knw_publish()`, and v3 carries a receipt (`inst/receipt/fdis.yaml`). The archive stores the
evidence receipt in its build's folder, outside the MANIFEST, so the evidence id stays the tables'.

Decided at the gate (Al): one `evidence` input; `visits_link` declared exact now, so a rebuild reads `different` until
#161 lands; the evidence receipt archived with its build. The durable account is `research/run_archive.md`,
"The evidence build: every table exact but `access_check`'s km".

What was learned. A receipt's bytes carry its write time and its context, so nothing whose identity must survive a
rebuild can be keyed on them; the archive's id was, until round 2. And every path that puts tables in an evidence
directory has to agree with the receipt: 0310, the archive's restore, and 0299's pull. The review rounds found these
one path at a time, and an enumeration over every writer, restore, reader and recipe input ended them.

## Measurement

- Two `0310` builds of the published build (link run `20261103_163715-269b585a`, wet's 2026-10-24 load) into tagged
  directories on the second database took 11.9 and 11.6 min. They gave one `recipe_id`. Six tables were
  byte-identical, and `access_check` differed by at most 1.0e-10 km over 2,193 rows. The verdict was `equivalent`,
  both on the receipts alone and with the tables re-read; the re-read comparison took 0.9 min.
- A grade receipt written against the first build named its `recipe_id`.
- This confirmed the motivating case (9.5e-11 km, then #158's 6.0e-11) on the code that writes receipts. Both builds
  ran on one database, so #161's tie did not fire. The comparison across two databases is owed to #161.
- The plan review corrected one claim: the measured moves are not "one ulp" on the per-group table, whose values are
  smaller than the pre-#120 province-wide rows. The rounding rests on #158's tolerance instead.
- Spend: one plan review and three code-check rounds, four reviewer spawns in all. They found 2, 2 and 3 issues; 6
  were fixed and 1 accepted. Round 3 found a defect in the other caller of round 2's fix, so the loop ended on an
  enumeration (`review-round3.md`).

## Evidence

`scripts/logs/habitat/evidence_receipt_160/20261106_*` (both build logs, their ledgers and the comparison), produced
by `scripts/0310-evidence-build.R` and `data-raw/evidence_receipt_compare.R`.

## Owed

- #161's fix turns the evidence receipt's `visits_link` verdict `identical`: rerun the phase 7 comparison once it lands (written into #161's body in phase 6)

Publishing v3 for real means rebuilding the default evidence directory with this code, rerunning 0290, 0294 and 0296,
then retuning, because the grades must name the new build.

Closed by: the PR for branch `160-write-receipts-for-the-evidence-build-an`
