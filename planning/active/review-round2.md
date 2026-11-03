# Review round 2: branch `120-minimal-network-province` (de9924c...a848c35)

## Checklist read

- `index.md`: in full.
- `code-check-python.md` (7 KB): in full. Nothing in it applies; the diff has no Python.
- `code-check.md` (341 KB): the prose of every H3 under `## Mechanisms`, with the `|` table rows and evidence blocks
  skipped. The other sections ("Rules that stand alone", "Security", "Spreadsheets and PDFs", about 20 headings) I
  read as index lines only, because no tool or shape they name appears in this diff.
- `code-check-spatial.md` (156 KB): I read three sections in full: "FWA main flow is not edge type 1000 alone",
  "FWA `upstream_route_measure` misses the next segment's start" and "A Freshwater Atlas main stem's downstream end
  lies on the receiving river's centreline, not at the confluence". The new prose names FWA edge types. The other
  sections, about 97, I read as index lines only.
- `code-check-r.md` (199 KB) and `code-check-shell.md` (135 KB): index lines only. The diff changes no R or shell
  code, so no heading names a tool or shape it uses. That leaves every section unread (about 120 in R, about 75 in
  shell).

## Method

**Round 1's fixes (a848c35).** I re-derived each one from the data:

- **Step counts.** I took them from the candidate `<key>_tune.csv` rule ladders, and they hold:
  - BT rearing: gradient 0.3 → 0.1049, seven steps (0.25, 0.2, 0.15, 0.1349, 0.13, 0.11, 0.1049); MAD 0.1 → 0.35,
    four steps.
  - BT spawning: 0.13 → 0.25, three steps.
  - CH: one step. GR: one step (width). ST: two steps (MAD).
  - CO and WCT pick the published rule again.
- **"Seven keys fitted."** The comparison's own log says "7 fitted species x stage", and `R/tune_run.R` counts
  `underpowered` as a fitted outcome, so WCT counts.
- **RB.** It is the only paused species with a published rule: `KO_rear` is `no_stream_rule`.
- **The log path.** Fixed. Every cited log exists and is tracked.

**New comparison numbers.** I checked them against `data/compare/candidate/20261103_0838/compare.csv`, rows
`ALL`. These all match:

- the `default` and tuned km
- the change percentages
- the gained and lost km
- the graded km

**The published column.** I checked it against `data/compare/compare.csv`, `ALL`, in the `door` structure, which
is every published key's `tuned_structure`: −23.7, +49.5, −15.9, −2.3, −27.0, +3.4 and +18.0 all match.

**The residue.** I checked `stored_vs_default_differ_km` per group in the `<key>_compare.csv` files:

- BT spawning is 0. The other keys run 0.048 to 9.302 km.
- They fall in 9, 4, 2, 3, 4 and 1 groups, so "one to nine" holds.
- CH has 8.496 km in TESR.
- The largest share is 0.011 %, inside the "within 0.02 %" claim.
- The comparison log gives 43.5 min on 6 workers.

**CLAUDE.md paragraph.** Every claim matches findings Phase 0, Phase 1 and Phase 2:

- the 0-segment `fresh_default_minimal` in the published database
- wet's manifest having no older version
- the 2026-10-24 (`b4bbc50`) and 2026-10-19 loads
- the 12,083 `in_range` rows

**Leaks.** No tracked file outside `planning/` names a host, a home path, a login or a service entry.
`~/.pg_service.conf` is libpq's standard file and is already named in CLAUDE.md's Database access section. The
committed logs carry only the public `fresh-bc` discharge manifest URL. `planning/active/` carries no home paths.

## Findings

- **[bug] research/minimal_network_tuning.md:7-9 (Status line).** Round 1's fix is wrong one axis over. It
  narrowed "every species tuned, graded and compared" to "the nine species link models on the minimal build tuned,
  graded and compared on it". The new sentence still over-claims "graded and compared" for three of the nine
  species:
  - The candidate summaries mark chum, pink and sockeye (`CM_rear`, `PK_rear`, `SK_rear`) `no_stream_rule`, and all
    nine species' spawning keys except BT's `no_response`.
  - The comparison log reads "Compared 7 species x stage". Its keys are BT rearing, BT spawning, CH, CO, ST, GR and
    WCT rearing, which is six species. `0330` never compared CM, PK or SK, and `0320` never graded them.

  A reader of the Status line would take chum, pink and sockeye to have graded habitat comparisons on the minimal
  network. True form: the nine species were tuned, and the seven keys with a rule (six species) graded and compared.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies". Its "Compression runs both ways"
    paragraph says a narrowed quantifier must be re-checked against each member of the set it now names.

- **[bug] research/minimal_network_tuning.md:92-93.** "In TESR chinook and grayling differ on the same lake segments
  (edge types 1200 and 1450)."
  - FWA edge type 1450 is a connector inside a double-line river's polygon, not a lake line. The repo says so itself:
    CLAUDE.md "Width and flow carry two traps" ("Connector lines inside river polygons (edge 1450)"), and
    `R/link_walks.R:14` and the bank-rule notes class 1400/1450 as river-polygon connectors. Through-lake main flow is
    1200, and a lake connector is 1400 (code-check-spatial.md "FWA main flow is not edge type 1000 alone").
  - So either the segments are not all lake segments, or the edge-type list is wrong. The same claim is in
    `planning/active/findings.md:226` ("lake edges (1200, 1450)").
  - It matters because the paragraph offers the lake setting as the one concrete lead on an unexplained residue. The
    next probe is aimed by it.
  - I could not open `CH_rear_segments.rds` or `GR_rear_segments.rds` (they need R) to say which half is wrong. The
    sentence contradicts the repo's own definition of 1450 either way.
  - **Rule:** none.
