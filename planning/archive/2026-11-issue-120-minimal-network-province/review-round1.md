# Review round 1: branch `120-minimal-network-province` (de9924c...6f99782)

## Checklist read

- `index.md`: in full.
- `code-check-python.md` (7 KB): in full. Nothing in it applies; the diff has no Python.
- `code-check.md` (341 KB): the prose of every H3 under `## Mechanisms`, with the `|` table rows skipped. Of the
  "Rules that stand alone", "Security" and "Spreadsheets and PDFs" sections I read only the index lines; their
  full sections were not read (about 20 headings), because no tool or shape they name appears in this diff.
- `code-check-r.md` (199 KB), `code-check-shell.md` (135 KB), `code-check-spatial.md` (156 KB): index lines only.
  The diff changes no R, shell or spatial code, so no heading names a tool or shape it uses. That leaves every
  section unread (about 120 in R, 75 in shell, 100 in spatial).
- soul `writing.md`: "State each claim by the code's definition" and "Check that each guard covers the set its
  sentence names", in full.

## Method

I checked every number in the new CLAUDE.md paragraph and the province sections of
`research/minimal_network_tuning.md` against the committed logs. I also checked them against
`data/tune/candidate/20261103_0838/` (pick_report, `*_tune.csv`, `*_grades_record.csv`), the published `data/tune/`
(`*_tune.csv`, `grad_fwa/CH_rear_tune.csv`, `*_grades_record.csv`, `*_summary.csv`) and `data/thresholds.csv`.

These hold:
- the pick table and its ddev / SE columns
- the chinook region counts (164 / 102 / 117 on 4,858 visits)
- the premise figures (3.4 / 3.0 %, 717 / 699 m, 0 to 5.6 %)
- the site-gradient figures (0.678 / 0.690 / 0.653; 5.9 / 6.4 / 11.6 %; BT 0.6 (0.8), CO 25.5 (25.8), GR 11.4 (11.7))
- the evidence build (45,529 visits; 110,784 = 36,928 × 3 pairs, 4.7 min)
- the settle log (three polls, released, 241 of 241 groups)
- the grading (70.9 min; segments 52 to 67 % fewer, CH 2,653,426 against 5,757,827; withheld CO and WCT on both runs)
- placement (45,529 − 45,357 = 172)
- the 12,083 `in_range` rows
- link 0.66.0 as the link installed at the published evidence build (`20261027_evidence_build_ledger.csv`)

The rule grids are identical between the two runs for every key, so a grid change is not a fourth confound.

The code claims hold: `0310` takes range from `lnk_load_overrides()` and `lnk_species_pooling()` (lines 194-215),
and flow and width are read on the visit's own `linear_feature_id` (lines 265 and 271).

Every cited issue resolves to its subject: #120, #121, #132, link#402, link#415, link#441 and link#444.

No new log, CLAUDE.md line or research line carries a home path, host name, port, login or credential.
`planning/active/` names m1 and m4, which CLAUDE.md allows.

## Findings

- **[bug] research/minimal_network_tuning.md:25-28.** The section says "five keys pick a
  rule one or two steps away", and that "the thresholds the tuning picks on it stay close to the published ones".
  Measured on the run's own ladders (`data/tune/candidate/20261103_0838/<key>_tune.csv`), this holds for chinook,
  grayling and steelhead and fails for both bull trout keys:
  - **Chinook rearing:** g 0.11 → 0.09, one step.
  - **Grayling rearing:** width 2 → 1.5, one step.
  - **Steelhead rearing:** MAD 1 → 0.5, two steps.
  - **Bull trout rearing:** MAD 0.1 → 0.35 is four steps (0.15, 0.2, 0.28, 0.35). Gradient 0.3 → 0.1049 is seven
    steps (0.25, 0.2, 0.15, 0.1349, 0.13, 0.11, 0.1049). That moves the rule from no effective gradient limit to a
    10.5 % one.
  - **Bull trout spawning:** g 0.13 → 0.25 is three steps (0.15, 0.2, 0.25).

  `planning/active/findings.md` (Phase 3, "five move one or two steps") carries the same claim. The sentence after it
  in the research file stays true: every published rule is in its region, less than one SE behind. The distance
  sentence is the one that is false.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies". A quantifier ("one or two steps",
    over five keys) holds for only three of its members.

- **[bug] research/minimal_network_tuning.md:27-28, 45 and the Status line 7-8.** These lines say:
  - "Every published rule is inside its key's region on the minimal network, so the minimal network does not reject
    any of them"
  - "the table says the minimal network leaves every published rule standing"
  - Status: "every species tuned, graded and compared"

  The published tuning has eight fitted keys. `data/tune/RB_rear_summary.csv` is `fitted`, and
  `data/thresholds.csv` publishes `RB_rear_v1` with rule `width>=3|g<=0.3|none`. The minimal run tuned nine
  species, with no RB and no KO, because link paused them on this build (findings: "the run modelled 9, this build
  carries 11 (KO, RB paused)"). Its pick report therefore has seven keys. The DEV log names the RB pick on file
  and never scores it: "previous picks on file for … RB_rear …".

  So rainbow trout rearing's published rule was not tested on the minimal network, and "every published rule" and
  "every species" are false. The research file never says RB or KO were left out. A reader would take the RB
  threshold as confirmed when it was not run.
  - **Rule:** code-check.md "A proxy is not the property". The claim is made over the pick report's seven keys,
    which stand in for the published set of eight. See also writing.md "State each claim by the code's definition".

- **[bug] research/minimal_network_tuning.md:76-78.** The "Fish records" bullet says the correlation moved
  0.690 → 0.678, "so the cut at the catch was not making the gradient much better or worse as a measure of the site".
  The two networks differ in more than the cuts at fish records:
  - The minimal network also drops crossings and habitat end points. The next bullet says "these runs cannot tell
    their effect apart".
  - The full network is link 0.66.0's build and the minimal network is link 0.78.1's.

  The comparison cannot single out the fish-record cut, so this bullet's attribution contradicts the one after it.
  Credit the change to the minimal network as a whole, or state the confound.
  - **Rule:** code-check.md "The probe is broken before the world is". Its "Before attributing a difference" part
    says to enumerate everything else that differs between the two sides.

- **[fragile] research/minimal_network_tuning.md:66 (the Tuning row).** The row cites the pick report as a bare
  `20261103_dev_minimal_pick_report.csv`. In this table a bare name means `scripts/logs/habitat/` (the settle,
  ledger and site-gradient rows), and nothing exists at that path. The file is
  `scripts/logs/habitat/minimal_network_120/20261103_dev_minimal_pick_report.csv`. A reader following the citation
  finds nothing there.
  - **Rule:** none.
