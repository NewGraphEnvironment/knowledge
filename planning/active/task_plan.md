# Task: Grayling: rebuild link's default from the literature and where grayling were caught (#140)

**If done:** grayling's starting rule rests on what the literature and grayling capture records say about where they
rear and spawn, so the tuning refines a baseline we stand behind. **If never:** grayling's thresholds stay a refinement
of numbers set to get started, and the tuning can only move them a short way from there.

link's `default` for grayling (`configs/default/parameters_habitat_thresholds.csv`): rearing ≤ 3.49 %, width ≥ 1.5 m,
MAD ≥ 0.021 m³/s; spawning ≤ 2.49 %, width ≥ 4 m, MAD ≥ 0.2 m³/s. These values were set to get the work started, not
chosen from a review of grayling habitat. The tuning cannot correct a weak start on its own, because its pick is the
smallest change to `default` that the data accept (#139). `data/literature_evidence.csv` holds 30 GR rows, every one
depth, velocity or a flow need (one access-gradient row with no value): no habitat-gradient, width, MAD or
spawning-site row.

## Decided at the gate

- **Split (Al, 2026-11-26, at this plan's gate):** #140 keeps issue steps 1 (literature) and 2 (where grayling were
  caught), plus a research file saying what they show. Steps 3-5 (the proposed `default`, the baselines register
  `inst/method/baselines.csv` and its test, the link issue beside link#343, the retune from the new start, the
  standing) become a new #139 member, filed in Phase 1, so Al reads the evidence before a baseline is proposed.
- **Capture tables are a `data-raw/` analysis**, `data-raw/grayling_use.R`, not a `0290`-series script: `0291`-`0298`
  are frozen on the v2 tables, and this reads the published evidence (`data/fdis/derived`, the minimal-network
  build). It follows `0291`'s model (cloglog binomial on catch, `log(area)` as a covariate, data set, era, group;
  groups with one outcome dropped and counted), with the spec written to `findings.md` before the first fit.
- **Hagen et al. 2026's critical-habitat segments** (EcoCat zip) are downloaded to an ignored directory and read for
  aggregates only (segment gradient and size by life stage, on the FWA); no derived file is tracked, because
  EcoCat-derived files are under NOTICE's "Terms not yet settled" (#76).
- **Life history goes in a quoted research file** (`research/grayling_life_history.md`, as #198 did for bull trout),
  added to `0280`'s `QUOTED_DEFAULT`; threshold-bearing statements go in `literature_evidence.csv`.
- **The store is read, not rebuilt,** unless a needed primary source is missing from the group library: then it is
  added with `0270` and `bull_trout_grayling` is rebuilt and pushed on m1 (where stores build), per CLAUDE.md's
  `-wal` and rebuild rules. `0280` verifies quotes against the PDFs, not the store.
- **FISS workbook records move to #281 (Al, 2026-11-26, at the plan review):** the built workbook tables hold no
  grayling (`0250` keeps only species with a `species_group`), and reading them needs `0250` extended and the sites
  placed. This PR uses the FDIS visits and says the workbooks are not yet read.
- **Originals sourced in this PR (Al, 2026-11-26, mid-run):** the drafters found the reviews' values rest on originals
  the group library lacked. 14 are sourced here (Blackman 2002a, 2002b, 2004; Blackman and Hunter 2001; Hawkshaw and
  Shrimpton 2014; Hawkshaw et al. 2013; Mathias et al. 1998; Cowie and Blackman 2003, 2004, 2007; Northcote 1995;
  Stewart et al. 1982; Den Beste and McCart 1984; Stanislawski 1997), filed through `0270` into `species/grayling`,
  the affected rows and quotes re-drafted from them and audited, and `bull_trout_grayling` rebuilt and pushed on m1.
  Two the drafters missed are already held (`ballard_shrimpton2009Summaryreport`, `cowie_blackman2012OverviewSummary`).
- **The plan review's other findings are folded below** (`review-plan.md`, 20 findings with verdicts). `grayling_habitat.md`
  cites evidence rows by data row and quotes nothing, so it stays out of `QUOTED`; GR is not added to `0280`'s
  `COVERAGE`, which would demand all 12 parameters.

## Phase 1: Split the issue
- [x] File the new #139 member (steps 3-5 of #140's body, the "before" table, and "blocked by #140" in its body)
- [x] Edit #140's body: steps 1-2 and the research file only, a `## Decisions` line for the split naming the new issue
- [x] Add the new issue to #139's `## Members` table after #140

## Phase 2: Find the grayling literature
- [x] Query `bull_trout_grayling` and `habitat_modelling` (`0150 ACTION=query`, cred ≥ 0.4.0; hybrid rows only, a
      `bm25`-only row is a failed search) for rearing and spawning gradient, channel size, discharge, spawning
      substrate and site, fluvial/adfluvial movement, overwintering; list each source with its key in `findings.md`
      (drafter brief: `planning/active/drafter-brief.md`; drafters `rows` and `life`)
- [x] Trace each review's claim to its original (drafter notes list them)
- [x] Source the 14 missing originals (`planning/active/originals-sourcing.csv`); file the found ones through
      `data/grayling_additions.csv` and `0270 --collection grayling --parent 9U54XAND` (paywalled ones abstract-only)
- [x] Re-draft the rows and quotes that cite an original as `cited_source` from the original itself, and add what
      the originals give for the six cells; held `ballard_shrimpton2009` and `cowie_blackman2012` read too
- [x] Rebuild and push `bull_trout_grayling` on m1 with its whole build list (`0150 ACTION=build OVERWRITE=TRUE`),
      after Zotero has synced and with a 0-byte `-wal`
- [x] Read Hagen et al. 2026 (`hagen_etal2026futureArctic`) for its habitat definitions by life stage

## Phase 3: Literature rows and their audit
- [x] Append GR rows to `data/literature_evidence.csv` (gradient, channel_width, discharge, stream_order,
      substrate, groundwater, overwintering habitat, depth/velocity a held source does not already give), each by
      CLAUDE.md's drafting conventions; never insert. Timing and onset temperature are quoted in Phase 4's file
- [x] Each of the six cells (spawning and rearing gradient, width, MAD) has a value, `qual` or `none` row
- [ ] `Rscript scripts/0280-literature-verify.R` passes (quotes verbatim, values in quotes)
- [ ] Meaning audit of every new row against its PDF by fresh reviewers, rounds until one finds nothing inside an
      earlier fix, ending on an enumeration of every row's claim with its verdict (review files in `planning/active/`)

## Phase 4: Grayling life history, quoted
- [x] `research/grayling_life_history.md`: forms (fluvial, adfluvial, lacustrine), movement and timing, spawning
      sites, fry and juvenile rearing, overwintering, each statement quoted with key and page
- [x] Add it to `0280`'s `QUOTED_DEFAULT`; `0280` passes
- [ ] Meaning audit of every quoted sentence, rounds as Phase 3's

## Phase 5: Where grayling were caught
- [x] Write the analysis spec in `findings.md` before any fit: population (quality-passed visits placed on the
      published network, groups where link marks GR present, no code blocking a GR absence; `access_gr` 1 or 2,
      code 2 never a covariate or stratum, code 0 counted and dropped; link's GR edge types, stream and canal, with
      river-polygon edges counted apart; area 10-10,000 m²), columns (the tuning's: `segment_gradient`,
      `cw_deploy`, `mad_pick`; a blank width its own class), classes (gradient past 5.49 %, width around 1.5/2/4 m,
      MAD around 0.021/0.2 m³/s), responses (GR caught; any fish; GR given fish), model (`0291`'s: cloglog,
      `log(area)`, data set, era from year, group), a fixed seed with resamples drawn before any parallel fit, and
      stop rules
- [x] `data-raw/grayling_use.R`: reads `data/fdis/derived/{visits_link,visits_species}.csv` and
      `data/fdis/build/fish.rds`, refuses tables whose md5s are not the run ledger's, writes `data/gr_use.csv`
      (rates and intervals per class) and a log under `scripts/logs/habitat/` naming the evidence md5s
- [x] Spawning: what the records can say (GR by month and length from `fish.rds`), stated as what they cannot say
      where spring spawning is unsampled
- [x] Hagen et al.'s segments: download to ignored `data/hagen_segments/` (`.gitignore` line), read gradient and
      size by life stage on this machine's fwapg, log aggregates only

## Phase 6: Write it up
- [ ] `research/grayling_habitat.md`: plain-language walk first (life-history expectation, the literature, the
      catch tables, Hagen's segments), what each says about each of link's six GR values, what it is not; no
      proposed value (the next member's)
- [ ] Rows in `research/README.md` for both new files; `data-raw/README.md` entry; CLAUDE.md's root-tier entry
      for `data/gr_use.csv`; `inst/NOTICE.md`'s quotes line names `research/*_life_history.md`
- [ ] Point `research/baseline_anchoring.md` (the "before" section) and `research/README.md`'s rows for it and for
      `grayling_rearing_tuned.md` at #280 and the new file

## Owed at the end (reported, done after merge)

- [ ] The next member (Phase 1's issue) starts from `research/grayling_habitat.md`

## Validation

- [ ] Tests pass (`devtools::test()`)
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: `0280` passes on the appended rows and the quoted file; the meaning audit ends on a claim-by-row
enumeration; `data-raw/grayling_use.R` reruns to identical `data/gr_use.csv`; `public_sweep.py` patterns hold
(no host or client identifiers in tracked text).
