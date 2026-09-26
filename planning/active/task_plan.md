# Task: Parse FISS life stage and individual-fish lengths into a per-site species x size-class evidence table (#18)

## Context

link#284 calibrates CH and BT gradient and channel-width thresholds. It needs evidence the public FISS layers don't carry:
- fish size, so spawning (adult) and rearing (juvenile) use can be told apart;
- measured channel width and gradient at the sampled site;
- sampling effort;
- zero catches.

We hold a province-supplied FDIS export (now `s3://fresh-bc/fdis/`, private) with exactly that. The `.xls` track (`0220`) is a supplement for later submissions and is deferred (see "Out of scope").

What exploration established (2026-09-26):
- **2020 export** (`2020-11-16/`). Electrofishing only, per `queries/*.sql`. All files are keyed on `KEY` = `fshclctn_id_site_seq_method_pass`.
  - `visits.csv`: 62,892 passes. 4,770 have no fished-area length despite the query's filter, and 1,084 have no UTM. Dates include junk years (0200, 2028, 2029).
  - `details.csv`: 326,389 fish.
  - `habitat.csv`: 23,450 passes, with `GRADIENT11..22`, `CHANNELWIDTH1..7` and `WETTEDWIDTH1..7`.
  - `counts.csv`: species × age tallies with min/max length.
- **2022 export** (`2022-03-22-ef-export/Details*.csv`). 20,122 keys ⊇ all 19,817 of the 2020 `details` keys, and it adds UTM, watershed code and gazetted name. So it is the fish table; the 2020 files supply visits, effort and habitat.
- **BT and CH fish** (2020 counts): BT 15,309 (99.7% with length) and CH 4,910 (97%).
- **Maturity codes** (BT/CH): IM, U, MT, M, SP, ST, or blank. They give an independent check on a length-based adult break. Code meanings come from `fiss-database-structure/`.
- **Network placement.** The local fwapg (5432) has `whse_basemapping.fwa_indexpoint`, the same routine bcfishobs uses. `fresh.streams` (1:1) carries modelled `gradient` and `channel_width`, so measured-vs-modelled comes almost free.
- **Repo conventions.** Scripts are numbered `NNNN-noun-verb.R` (`0200`–`0220` is the FISS track). The cross-group tier goes in `data/` root. Nothing graduates to `pkg/` until it has run on two regions, and this is province-wide, so it stays a script.


## Phase 1: Source audit and gap statement
- [x] Record what the public layers carry vs FDIS, field by field: `fiss_fish_obsrvtn_pnt_sp`, `fiss_stream_sample_sites_sp`, `bcfishobs.observations`, FIDQ. Cover life stage, length, weight, maturity, effort, measured width and gradient, and zero catch.
- [x] Confirm the join structure: the 2022 export as a superset of 2020 `details`; fish-row dedupe rule; `habitat`/`visits` key coverage.
- [x] Decode units and codes from `fiss-database-structure/`: gradient (%), widths (m), length (mm, fork vs total), and the maturity and sex code lookups.
- [x] Write `research/fdis_export.md`: provenance, contents, units, known defects (area blanks, UTM blanks, junk dates), and the gap statement.

## Phase 2: Load and QA (`scripts/0230-fdis-load.R`)
- [x] Sync `s3://fresh-bc/fdis/` into an ignored local cache `data/fdis/` in one `aws s3 sync` call. Add it to `.gitignore`.
- [x] Build a pass table: visits ⋈ habitat, with mean measured channel width, wetted width and gradient; effort (fishing time, area); and date.
- [x] Build a fish table from 2022 `Details*`, deduped, keyed to the pass.
- [x] QA flags, never silent drops: no UTM, junk date, no area, zero-length fish. Write a reconcile log that `stop()`s when row counts don't add up (same pattern as `0220`).

## Revisions after plan review (2026-09-26)

A plan review (Plan agent), each finding reproduced before acting, changed the build:
- The grain is the site visit, not the pass: depletion passes repeat the same population.
- Abundance comes from `counts`; `details` is a length subsample (87% of counted CH have no measured fish).
- Zero catch is explicit (`NFC` in `counts`), not inferred. A conflict means NFC and fish on the same pass.
- No fish-row dedupe: exact duplicates are distinct fish (the fish sequence number wasn't exported).
- Habitat joins at site level. GRADIENT11/12 are primary; 21/22 are kept separate.
- Placement uses province-wide FWA tables, not `fresh.streams` (98 groups locally), and is checked against the 50k watershed code.
- CH has no adults in EF data, so CH gives rearing evidence only. BT spawning evidence needs month plus maturity, not length alone.
- The maturity check compares SP/ST with IM only (MT median length is 135 mm).
- BT/DV: codes are kept as recorded, plus a combined char column.

## Phase 3: Place on the network (`0230`, continued)
- [x] Index each pass location with `fwa_indexpoint` on 5432, falling back to the tunnel. Return `blue_line_key`, `downstream_route_measure`, snap distance and `watershed_group_code`.
- [x] Join the snapped segment's modelled `gradient`, `channel_width` and `channel_width_source` from `fresh.streams`, so measured and modelled values sit side by side.
- [x] Flag snaps beyond a distance threshold (reported, not dropped).

## Phase 4: Size classes for CH and BT (`scripts/0240-fdis-size-classes.R`)
- [x] Plot length distributions per species by region (major drainage) and by month of capture. Emergence timing shifts fry sizes, so month matters. *Tabulated by month and maturity (log); breaks are province-wide, and `fwa_basin` is carried for regional splits later.*
- [x] Set class breaks (fry / parr-juvenile / sub-adult / adult) in `data/fdis_size_breaks.csv`, with a `basis` column: distribution mode, maturity-code check, or citation (to be filled from knowledge#19).
- [x] Check the adult break against maturity codes (M/MT/SP vs IM). Report the agreement rate.

## Phase 5: Evidence table (`0240`, continued)
- [x] Write `data/fdis_evidence.csv`: one row per pass × species × size class, with count, measured cw/gradient, modelled cw/gradient, effort, `blue_line_key`/`drm`, WSG, date, the class basis, and QA flags.
- [x] Emit zero-catch rows as a species-absent row per pass, from passes with effort and no fish. *Landed at site level: `catch_status` plus per-species counts in the site table; absence is asserted only where the catch is known.*
- [x] Write `data/fdis_evidence.gpkg` (points) for QGIS spot checks. *Landed as `fdis_sites.{csv,gpkg}` in `s3://fresh-bc/fdis/derived/` (17 MB each, too big for git); `data/fdis_evidence.csv` is tracked.*
- [x] Summary for link#284: CH and BT measured gradient and width at fry/juvenile vs adult captures, against the current thresholds (spawn/rear gradient max, cw min).

## Phase 6: Docs
- [x] `scripts/README.md`: an FDIS track section and its run order.
- [x] CLAUDE.md working note: the FDIS export lives at `s3://fresh-bc/fdis/`, EF-only, 2022 ⊇ 2020.
- [x] Update the knowledge#18 body: FDIS built; the `.xls` Step 2/3 parse split to a follow-up issue.

## Out of scope (follow-up issue: #21)
- `0220` Step 2 life stage and Step 3 individual-fish parse. These cover submissions made after 2020 and non-EF methods. Split out so this PR ships the bulk of the evidence.


## Validation

- [ ] Reconcile log passes (fish in = fish out + flagged; every pass accounted for)
- [ ] QGIS spot-check of 10 random passes
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
