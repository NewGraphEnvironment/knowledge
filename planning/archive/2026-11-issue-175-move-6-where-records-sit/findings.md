# Findings — Backlog move 6 (#175)

## Issue context

**If we do it:** each FDIS visit joins its bcfishobs records with a span on the network, and we know whether discharge resolution adds error beyond where records already sit. **If we never do:** location error and flow-resolution error stay unmeasured beside each other.

### Batch 10. Location error against flow resolution
- **Why here:** #23's downstream-end check is the oracle #137's second question needs.
- **Touches:** `scripts/0230`/`0240`, `research/fdis_export.md`, a new `research/` section on discharge resolution.
- **Decided at the gate:** #23's original consumer (a link issue) has closed, so scope #23 to what #137 needs.

| issue | title |
|---|---|
| #23 | Site-visit table joining FDIS catch, effort, fished span and measured habitat to bcfishobs records |
| #137 | Is one discharge value per FWA segment accurate enough to tune on? |

### Batch 18. The FDIS load's outputs (added 2026-11-18)
- **Why here:** both act on `0230`'s outputs, which #23 rewrites: one rerun and one archive.
- **Touches:** `scripts/0230-fdis-load.R`, `R/archive.R`, `scripts/0336-archive.R`, `scripts/0299-fdis-publish.R`, `data/fdis_README.md`.
- **Decide at the gate:** whether the per-pass tables join `knowledge/fdis/v3`, which no upload has published yet (#219 owes it), or wait for a v4.

| issue | title |
|---|---|
| #225 | Publish the per-pass electrofishing tables the FDIS load already builds |
| #214 | Archive the run's fish.rds: 0320 and vignette_method.R read it, and 0336 PULL=TRUE does not restore it |

---

Backlog: `planning/backlog.md`, move 6. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.






### #23: Site-visit table joining FDIS catch, effort, fished span and measured habitat to bcfishobs records

**If we do it:** there is one site-visit table that says where each FDIS electrofishing site sits on the FWA network, how long it was, how many of each species were caught for what effort, and what gradient and width were measured, keyed so it joins to bcfishobs records. link#294 can then test its threshold evidence against it. **If we never do:** link keeps treating each bcfishobs record as one fish at one point, with no count and no site span, and the FDIS export stays unjoined to the observations everyone else uses.

#### Why

- bcfishobs (from `whse_fish.fiss_fish_obsrvtn_pnt_sp`) holds one presence record per species per site per date. Its point is usually the **downstream end** of a 100–500 m site, and it carries no count and no site length.
- 52 % of BT, DV and CH records (72 % of BT) carry `FDIS Database: fshclctn_id <n>` in `source`, the key this export uses (`research/fdis_export.md`).
- This is evidence about fish and sampling that holds whatever model is run, so it belongs here. link#294 does the model-side comparison.

#### Build

From `s3://fresh-bc/fdis/` (visits, counts and habitat; `2020-11-16`, plus the 2022 fish files), at the **site-visit** grain already used in `scripts/0230`:

1. **Join key.** Parse `fshclctn_id` from bcfishobs `source`, and map each bcfishobs record (`fish_observation_point_id`, species, date) to its FDIS site visit(s). Report the match rate by species, and the many-to-one cases (one collection, several sites).
2. **Placement.**
   - Place the site's downstream point on FWA from the visit UTM: `blue_line_key` and `downstream_route_measure`, with snap distance.
   - Add the **fished length** as an upstream span (`upstream_route_measure`), flagging visits with no length or a sentinel value.
   - Compare against the bcfishobs point for the same record, as a check on the downstream-end assumption.
3. **Abundance and effort.**
   - Number caught per species (and age class) per visit, summed over passes, with fishing time and fished area.
   - Catch per unit effort, keeping zero-catch visits (effort recorded, species absent).
4. **Measured habitat:** gradient and channel and wetted width per visit, using the sentinel handling already declared in `scripts/0230`.
5. **Output:** a derived table in `s3://fresh-bc/fdis/derived/`, with a data dictionary and an md5 in the manifest, plus a short section in `research/fdis_export.md` on match rates and the downstream-end check.

#### Second source: the Fish Data Submission workbooks (after #21)

The FDIS export covers only electrofishing, to about 2022. The workbooks parsed by `scripts/0220` (extended by #21 with Step 2 life stage and Step 3 individual fish) cover later years and other methods: minnow traps, angling, seines.

**Do not assume they are new observations.** A loaded submission reaches bcfishobs as presence only. How much is loaded depends on the year. bcfishobs (local snapshot) holds, for BT, DV and CH:

| | ≤ 2019 | 2020–2022 | 2023 on |
|---|---|---|---|
| FDIS-keyed records | 16,377 | 1,097 | **7** |

So match each workbook site × species × date to bcfishobs (species exact; date and location within a tolerance) and classify it three ways:

1. **In bcfishobs and in the FDIS export:** attributes come from FDIS, and the workbook adds nothing to the table.
2. **In bcfishobs but not in the export:** attributes (count, effort, fished length, habitat) come from the workbook, joined to the bcfishobs record.
3. **Not in bcfishobs:** a new observation, flagged by `source` so a consumer can include or exclude it.

Report the counts per class by year and species. Dedupe against FDIS as #21 plans (date + UTM + species + length).

**Caveat to state:** "not in bcfishobs" means not in the snapshot used, so check the class-3 rate against a fresh bcfishobs load before reading it as a provincial loading lag.

**Order:** the FDIS half (steps 1–5 above) can start now; this section follows #21.

#### Limits to state in the output

- Electrofishing only.
- The export runs to about 2022.
- Placement from UTM carries its own snap error.
- Many bcfishobs records are not FDIS (legacy FISS, RAB, etc.), so the table covers about half the observations.

Consumer: NewGraphEnvironment/link#294 (site span, measured vs segment gradient, presence vs abundance weighting). Depends partly on #21 (the workbook source). Relates to #18, #19.



#### What already exists (checked 2026-10-01)

`s3://fresh-bc/fdis/derived/fdis_sites.csv` (#18, `scripts/0230`) already covers most of the FDIS half:
- step 2: the downstream point, snap distance and `fished_length_m`;
- step 3: per-species counts, `fishing_time_s`, `area_m2` and zero catch;
- step 4: measured gradient and width.

**Still to build:**
- the step 1 join key (`fshclctn_id` parsed from bcfishobs `source`, with match rates);
- an explicit `upstream_route_measure` for the span;
- counts per age class;
- an md5 in the manifest;
- the step 2 check that the bcfishobs point is the downstream end.

link#294 is parked until this smaller PR lands.


### #137: Is one discharge value per FWA segment accurate enough to tune on, given how far fish records sit from where fish were caught?

**If we do it:** we know how much error the discharge resolution adds to a tuned flow threshold, measured against the error already in where records sit. Then we can decide whether discharge should vary within a segment. **If we never do:** flow thresholds keep an error of unknown size, and a finer discharge layer could be built without knowing whether it beats the sampling error.

**What is true now:**
- fwapg's fork gives each FWA segment one PCIC routed value: flow from the sub-basins above, plus an area share of local runoff.
- wet adds a water-balance source and a `pick` of the default source.
- link and knowledge join it on `linear_feature_id`, so discharge changes only between FWA segments. Neither link network crosses an FWA segment boundary, so the cuts do not move it: FWA starts a new segment at every confluence, and in BULK none of the 10,387 tributary mouths joins partway along a segment (local fwapg, 2026-11-02).
- Physically, flow grows along a segment.

**Questions:**
1. How much does area-based flow change from the bottom to the top of an FWA segment, province-wide and at rearing sizes?
2. How does that compare with location error in the evidence? A bcfishobs point is usually the downstream end of a 100 to 500 m site, not where a fish was caught (#23, the site-visit table).
3. If the resolution error matters, should discharge be given at a point (fwapg's share is area-based), and what would that move in thresholds already tuned?

Relates to #120 (chinook rearing on minimal segments) and NewGraphEnvironment/link#444 (parent gradient).


### #225: Publish the per-pass electrofishing tables the FDIS load already builds

**If we do it:** a depletion (removal) estimate, or an occupancy model that treats passes as repeat surveys, can be fitted from knowledge's output without a second parser of the FDIS export. **If we never do:** any work that needs catch per pass reads the raw export itself, and two tools hold two copies of the same parsing rules.

#### Problem

The FDIS load takes the site visit as its grain: `scripts/0230-fdis-load.R` says "Catch and effort sum over passes", because 5,748 of 53,018 site visits have two to eight depletion passes and per-pass rows would weight those sites. That is right for presence and absence per visit. It also means the published tables keep only `n_pass`: fishing time and area are summed per visit, and catch is summed per visit and species code. `knw_fiss_visits()` does the same for the Fish Data Submission workbooks, summing `ef_seconds` over `haul_pass`.

The per-pass tables exist inside the load script before the sum (the `passes` frame, and the per-`KEY` rows of `counts`).

#### Proposed Solution

Write two more tables beside the visit tables, for the visits the load keeps:

- one row per pass: the site visit, the pass (method and haul), date, fishing time, fished length, width and area;
- one row per pass and species code: the number caught, with the same rule the visit table uses for a count that is missing or short of the measured fish.

Nothing about the visit tables changes. The question of which passes are the same closed population stays with the caller.


### #214: Archive the run's fish.rds: 0320 and vignette_method.R read it, and 0336 PULL=TRUE does not restore it

**If done:** a checkout restored with `PULL=TRUE scripts/0336-archive.R` can rerun `0320` and rebuild the methodology bundle without rerunning `0230`. **If never:** both need `0230` first, and the bundle's md5 check on `fish.rds` fails on any machine whose `0230` output differs from the build's.

#### Problem

`data/fdis/build/fish.rds` (one row per measured fish, written by `0230`) is read by `0320` for bull trout's spawner evidence (`knw_spawner_evidence()`), and, since #204, by `data-raw/vignette_method.R`, which rebuilds the tuning's scoring population to count each published key's dropped groups by outcome and pins `fish.rds`'s md5 in `method.rds`. `0336` archives and restores only `reconcile.csv` and `sites.rds` from `data/fdis/build/`, so a restored checkout has no `fish.rds`, and `vignette_method.R` stops at `readRDS()`.

#### Proposed

- [ ] `0336` archives `data/fdis/build/fish.rds` with the build, md5-checked like `reconcile.csv` and `sites.rds`, and `PULL=TRUE` restores it.
- [ ] Check whether `0230` rewrites `fish.rds` byte-identically from the same export; if not, the archived copy is the only one that matches a bundle's md5.


## Exploration (2026-11-19)

- Published tables name link run `20261102_203300-60ab009d`; its evidence is archived as `3d907629ee200b4a7beb05cdd560fc0b` (batches 20261103T123953Z and 20261113T170305Z), without `fish.rds`.
- `thresholds.csv` evidence_md5: `c746c582…;6a2e28f1…;2e0f0f41…` (visits_link, visits_species, walks).
- m1's local `data/fdis/derived` is the 2026-10-22 build, not the published one.
- m1's database flow comment: wet build 2026-10-24T12:23:01Z (wet b4bbc50), scenario historical.
- `visits.csv` columns: KEY, DATA_SET, UTM_*, METHOD_NUMBER, HAUL_OR_PASS, IN/OUT date and time, FISHING_TIME, FISHING_AREA_LENGTH, FISHING_AREA_WIDTH, FREQUENCY, VOLTAGE, PULSE, AGNCY_ID, NAME.
- The per-pass consumer is a private package's issue; its settled design: site = the visit's point, visit = site visit, replicate = pass; effort = fishing time; a pass with only "no fish caught" is a no-taxon row with 0, a pass with no catch record a no-taxon row with NA; species codes raw, so blocking rules apply per pass.

## 0230 rerun on m1 (2026-11-20T03:56Z, 40 s)

- `fish.rds` 8cf273515ce2b692c3719130eac75b93 and `catch.rds` a31fd7bbe2febbe31d70fc8f4cd3a161: byte-identical to every
  evidence ledger's `md5_fish` / `md5_catch`. fish.rds is built before placement, so it reads no database.
- `sites.rds` 853c682052cc0868ef1ed7bc5b048695, not the published 39f751b174aea4a14eb0dc0d3e3b126d: same 51,587 visits
  and columns; 245 differ in `downstream_route_measure` and `linear_feature_id` (37 in `blue_line_key`, 7 in
  `snap_moved`, plus the joined FWA attributes). reconcile.csv: `sites_snap_moved` 778 against 785. The published build's
  ledger records fresh 0.52.0; m1 has fresh 0.53.0 and its own database. Placement does not reproduce here; the
  published sites.rds and reconcile.csv (from the archive) were put back into this checkout's build. The rerun's copies:
  scratchpad `build_rerun_m1/` (not tracked).
- Per-pass check on the real build: 61,388 passes and 73,567 pass x species rows; status fish 35,642, nfc 25,279,
  no_record 467. Every kept visit's pass count equals `n_pass`, and the passes' fishing time and area sum to the
  visit's (0230 stops otherwise; it did not). 885 visit x species caught have no pass row (their catch sits on a KEY
  with no visits.csv row); 161 visit x species sum above the visit's `n_caught` over their passes (a pass's count short
  of its measured fish); none below.
- Tracked outputs under m1's placement: `data/fdis_evidence.csv` and `data/fdis_summary_ch_bt.csv` moved (restored);
  `data/fdis_repeat_surveys.csv` and `data/fdis_maturity_check.csv` unchanged.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `$ operator is invalid for atomic vectors` in `knw_archive_plan()` | my loop variable `f` shadowed the tune-file frame `f`; renamed `b` |
