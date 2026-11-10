# #120, third branch: chinook rearing on every setup

## Outcome

Chinook rearing was scored, graded and compared on every setup that exists, all on one flow load, one species range
and one set of visits and walks, so that the network and the gradient a rule reads are the only differences. The two
new setups are graded candidates that promotion refuses: the full network reading each segment's minimal parent's
gradient (link#444's `streams_parent`), and the full network reading the Atlas line of each visit's segment. To make
them possible, `knw_parent_read()` reads link's parent table and holds it to both builds; `0310 PARENT=TRUE` joins it;
grading, `0330` and the archive take a gradient source; and `0320 SETUP=1` makes a setup. The parent setup picks the
minimal network's rule exactly (`g<=0.09`, the same 102 rules in region). The published 13 % lies outside those
regions, and their 9 % lies inside the published one. Applied on the full network, the minimal network's rule loses
1,042 of 87,606 km, all through the near-river exception's distance, which the parent table does not carry
(link#462). The Atlas line picks 15 %. Two findings changed the plan. 732 visits sit on a segment of another Atlas line
than their own, so the Atlas setup reads a new evidence column, `segment_fwa_gradient`. And the review found that
setup status, the gradient and the parent table are run-level facts, which readers must take from run-level signals:
the `setup.txt` marker and the evidence ledger's parent line. The durable result is `research/minimal_network_tuning.md`,
"Chinook rearing on every setup".

## Measurement

- **Parent evidence** (`0310 PARENT=TRUE`, 19 min, walks all cached): 45,529 visits, with `visits_species` and `walks`
  byte-identical to the published build's. The parent is the minimal segment a visit sits on for 45,450 visits, the 12
  straddling visits included. The other 79, all with fish, are placement taking the short piece cut at the catch.
- **Atlas lines:** 732 visits are placed on a link segment of another Atlas line than their own. Their gradients differ
  on 637 of them (median 0.022), and 136 cross a 13 % limit. That moved the Atlas setup onto the segment's line. The
  first evidence build was rebuilt with the new column, and its ledger and log are kept as `*-first*`.
- **Runs** (m4, walks warm): parent `0320` 8.2 min after the smoke run and `0330` 18.9 min; Atlas 8.5 and 18.8.
- **Picks:** published 13 % (169 rules in region), minimal and parent 9 % (102), Atlas 15 % (117). Pick km: 88,458,
  87,606, 86,608 and 85,962.
- **Transfer:** 1,042 km of the minimal network's verdicts are not drawn on the full network, and 44 km are drawn only
  there.
  - Of the 1,042 km, 0.4 km is the connectivity stage; the rest passes on the minimal network only by the near-river
    exception (minimal median distance 507 m, the full network's pieces 1,326 m).
  - A wrong turn: link#444's four-group note pointed at the connectivity stage; the measured split put 0.4 km there.
- **Regression:** on MFRA, the gradient source reading the segment's own gradient reproduces the published grades and
  comparison exactly.
- **The map:** the first figure's classes were fixed before seeing the patterns and put the two largest disagreements in
  "other". They were revised; the group (MORK) is the one the rule fixed before drawing chose.
- **Branch review:** four rounds (5, 2, 3 and 0 findings). Round 2 found a defect inside round 1's fix. Round 3 named
  the mechanism and enumerated its readers, and round 4 re-verified every row.

## Evidence

`scripts/logs/habitat/every_setup_120/20261105_*`, `scripts/logs/habitat/20261104_evidence_build_ledger-derived_parent.csv`,
`scripts/logs/habitat/20261104_minimal_network_check.txt`, `scripts/logs/habitat/20261105_setup_compare-ch_rear.*`;
`data/archive_index.csv` (the parent setup under `tune/CH_rear/cut-full-top.acc-v5.grad-parent.q-fwapg/`).

## Owed

- Archive the Atlas-line run under link's new token once it is minted.
- #149: the public article and the methodology article's short section (#120's last task stays listed until it
  lands, so this PR relates to #120 rather than closing it).
- Other species on every setup, one at a time; "other access classes" (#132) and "fixed window" (#70).

Filed on the way: link#460 (the Atlas token), link#462 (the near-river distance under `grad-parent`), an internal issue (the
skill helper's bash 3.2 parse). link#444's last acceptance line was ticked; all its boxes are done.

Closed by: PR (to be opened), relates to #120
