# Task: Intrinsic-potential model registry from the PNW literature, to seed every species' thresholds (#29)

## Problem

CH and BT thresholds now have a gated evidence table (#19). The rest of the species do not. The Pacific Northwest has about 25 years of intrinsic-potential (IP) modelling that defines species × life-stage suitability on gradient, flow or width, and valley confinement. Sheer et al. 2009 (*State of the IP 2008*, in the group library) synthesizes it. Burnett et al. 2007, the original Oregon coast coho/steelhead IP model, is in a dormant library only (#13). Rebellato et al. 2024 is a thin BC descendant of this line. Its channel widths are a discharge surrogate built on our width model.

Modelled MAD covers 104 of 246 watershed groups (the Fraser, Columbia and Peace), and none of the Skeena, Nass, Stikine or coast. Upstream precipitation, the width model's input, covers 89–95 % everywhere. Which flow representation other IP models used is therefore the question that decides our discharge work.

## Context (plan-mode exploration, 2026-10-01)

#19 gave CH and BT a gated evidence table (`data/literature_evidence.csv`, 190 rows, gate `scripts/0280`).
No other species has one. The PNW intrinsic-potential (IP) models already define species × life-stage
suitability on gradient, flow (or width) and valley confinement. Collecting them gives every next species a
starting point. It also answers the question that decides link#286 (width vs MAD outside the
Fraser/Columbia/Peace): what flow representation did the field use?

What exploration found (2026-10-01, m1):
- **Sheer et al. 2009 Table A1 (pp. 33–34)** is the model inventory: CLAMS/Burnett 2003 and 2007 (CO, ST);
  Agrawal 2005 / Bjorkstedt 2005 (CO, CH, ST, N. California); Cooney & Holzer 2006 (Interior Columbia
  CH, ST); NOAA Lower Columbia, Willamette and Puget Sound (Busch); ODFW coastal coho; BLM 2008; Lindley
  2006; Boughton & Goslin 2006; Mills 2008; Zimmerman & Reeves 2000; NetMap (Benda 2007); FishEye (Sheer
  2007, Steel 2008); Copper River (Bidlack). Species workgroup appendices C–E list variables and thresholds
  per model.
- **Flow is already half-answered.** Sheer p. ~6 (line 423 of the text): the classic models' mean annual
  flow is a "Regression of gauge data to drainage area (DEM) and mean annual precipitation". Those are the
  same inputs as our width model. The workshop notes also argue that drainage area is a more stable
  intrinsic variable than MAF.
- **Already in the group collection `U9ZCZ6RN`:** Sheer 2009, Agrawal, Busch 2011, Cooney & Holzer 2006,
  Woll 2015 and 2017, Sloat 2017, Porter 2008/2010/2014, Rebellato 2024, Beechie & Imaki 2014. Two are
  there without a PDF: Holzer and Bidlack 2014.
- **Only in dormant library 6** (with PDFs): Burnett 2007. 0270's members path copies it. *(Plan review B3:
  "Busch 2013" in library 6 is the same paper, DOI 10.1002/rra.1597, as the group's 2011 item. Dropped,
  because 0270 would have created a duplicate.)*
- **In no library:** Burnett 2003, Bjorkstedt 2005, Lindley 2006, Boughton & Goslin 2006, Benda 2007,
  Steel 2008, Mills 2008, Zimmerman & Reeves 2000, and the agency layer method documents (ODFW, NOAA
  NWFSC, CDFW, WDFW). These come from the web, through 0270's additions path.
- **Machine state:** Ollama is up. **Zotero is not running on m1.** It has to be open and synced before
  the store build or the gate can see new items. Launch it with `open -a Zotero` and wait about 30 s. If
  that fails on the headless shell, that becomes a phone-answerable checkpoint.
- **Reuse, don't rebuild:**
  - `scripts/0270-habitat-collection-build.py`: members and additions CSVs, copy from other libraries, PDF
    upload;
  - `scripts/0150-store.R`: build and push;
  - `scripts/0280-literature-verify.R`: the `snapshot()`/`resolve()` group-library lookup and the
    token-sequence quote matcher;
  - `pkg/R/literature.R`: `knw_literature_read()`/`knw_literature_vocab()`, the reader pattern to mirror.

## Decisions (answered at the gate, 2026-10-01)
1. **Thresholds live only in `literature_evidence.csv`**, linked to their model by a new `model_id`
   column. The registry holds model descriptors only: region, flow metric and source, confinement,
   validation. "Variables used" is derived from the linked rows. Each number is stored once.
2. **Rows are written for every species a model covers** (CO, ST, CH, plus SK and CM from Woll). The
   coverage gate requires only CH, BT, CO and ST.


## Phase 1: Issue body, schema and gate (tests first)
- [x] Edit #29's body to add:
  - the inventory above;
  - the registry/evidence split (decision 1);
  - the species scope (decision 2);
  - "flow is a regression on drainage area + precipitation" as the starting hypothesis.
- [x] `pkg/tests/testthat/test-ip.R` (written first). The new reader `knw_ip_read()`:
  - reads a valid registry;
  - refuses an off-vocabulary `flow_metric`, `flow_source`, `valley_confinement` or `validation`;
  - refuses missing columns, a blank key or quote, and a duplicate `model_id × species × life_stage`;
  - requires a validation quote unless `validation = none`.
- [x] `test-literature.R`:
  - the new `model_id` column is accepted;
  - new variables `valley_width_index` (unit `ratio`) and `drainage_area` (unit `km2`) are accepted;
  - an off-vocabulary unit for them is refused.
- [x] `pkg/R/ip.R`: `knw_ip_read()` and `knw_ip_vocab()`, with roxygen and a runnable example on a
  bundled fixture. *(After the review, registry columns were added: `flow_inputs`, `flow_surrogate`,
  `cited_source`, `validation_citation_key`. `flow_source` dropped `surrogate`. `bankfull_width` became
  `channel_width`.)*
- [x] `pkg/R/literature.R`: add the `model_id` column (the column is required; its value may be blank) and
  the two variables and units, plus `cfs`, `mi2` and `ft` as written. Bump `pkg` DESCRIPTION
  0.1.0 → 0.2.0 and add `pkg/NEWS.md`.
- [x] `data/literature_evidence.csv`: add the `model_id` column. Backfill it on the two seed models'
  rows (Rebellato, Cooney & Holzer: 20 rows), following the tag rule in findings. Busch, Woll, Agrawal
  and the Sheer rows are tagged in Phase 3 together with their registry rows (review B2).
- [x] `scripts/0280`:
  - verify `data/ip_model_registry.csv` quotes (and validation quotes) with the existing matcher;
  - referential checks: every evidence `model_id` is in the registry, and every registry model × species ×
    stage has at least one evidence row;
  - ~~`COVERAGE$species` becomes `CH, BT, CO, ST`~~ → moved to Phase 3 (review B1);
  - a per-run OCR work dir; `model_id` in the evidence log.

  Prove each new guard fires by restoring the defect in a copy. *(Done for 5 cases:
  - flow quote fabricated;
  - validation quote fabricated;
  - a registry row with no evidence;
  - an unknown `model_id`;
  - a known model under the wrong species.

  Each run exited 1 and named the row.)*
- [x] Gate green on the backfilled table plus a seed registry (Rebellato, Cooney & Holzer rows), so the
  schema is exercised before bulk drafting.

## Phase 2: Collect into `Fisheries/habitat_modelling`
- [x] Precheck: Zotero running and synced, API key file, Ollama with `nomic-embed-text`.
- [x] Candidate list in `findings.md`: Sheer Table A1, the appendix C–E model lists, post-2009 work (Woll,
  Bidlack, Sloat, Rebellato) and the agency layers. Each candidate records its library status: group,
  dormant (#13) or absent.
- [x] `data/habitat_modelling_members.csv`: add the library-6 key (Burnett 2007) and any dormant-library
  hits. Holzer and Bidlack need a PDF only through an additions row whose metadata matches the group item
  exactly; the dry-run must say `exists` (review G9).
- [x] `data/habitat_modelling_additions.csv`: add the web finds with a `why`, using a DOI where there is
  one. Paywalled works are noted and skipped, not chased.
- [x] `0270 --dry-run`, then live. Wait for the sync and confirm each new item has a key and a PDF on a
  checked copy.
- [x] Rebuild the `habitat_modelling` store (0150 `ACTION=build OVERWRITE=TRUE`, with the collection list
  from the #19 archive's `task_plan.md:107`). Push it with `CONFIRM=TRUE` and confirm with a verified
  connect. Commit the log in `scripts/logs/habitat/`. *(207 documents, 35,130 chunks, md5 `2f8fd201…`,
  matched by a verified connect. The same 3 keys as #19 were dropped by cred's lookup.)*

## Phase 3: Registry and threshold rows
- [x] Draft `data/ip_model_registry.csv`, one row per model × species × life stage, with these columns:
  - `model_id`, `model`, `region`, `species_code`, `life_stage`, `life_history_form`;
  - `flow_metric` (`mean_annual_flow`, `summer_low_flow`, `bankfull_width`, `drainage_area`,
    `precipitation`, `none`), `flow_source` (`gauged`, `modelled`, `surrogate`, `field`);
  - `valley_confinement` (`valley_width_index`, `none`);
  - `validation` (`none`, `fish_observations`, `redd_surveys`, `density`), `validation_result`,
    `validation_page`, `validation_quote`;
  - `citation_key`, `page`, `quote`, `quote_source` (the quote supports the flow claim), `note`.
- [x] Threshold and curve-breakpoint rows in `data/literature_evidence.csv`, tagged by `model_id`, for every
  species each registry model covers. CO and ST get their own `none` rows wherever the coverage gate
  needs one.
- [x] `COVERAGE$species` becomes `CH, BT, CO, ST` (moved here from Phase 1).
- [x] Drafting is split across 3 drafter subagents by model family:
  - Oregon/Washington: Burnett/CLAMS, Busch, BLM/ODFW, Sheer appendices;
  - California: Agrawal/Bjorkstedt, Lindley, Boughton;
  - Interior/Alaska/BC: Cooney & Holzer, Woll, Bidlack, Rebellato.

  Each drafter writes a CSV into `planning/active/`, and I merge them. Every row must pass the gate; none is
  hand-waved.
- [x] Gate green. Commit the dated `*_literature_verify.csv` log.

## Phase 4: Flow finding and docs
- [x] New `research/ip_models.md`. It holds:
  - per-model flow metric and source (from the registry);
  - whether any model needed gauged or modelled discharge, or got by on drainage area, precipitation or
    width;
  - validation outcomes;
  - species with no IP model (RB, WCT, GR), with what was searched;
  - the implication for link#286 (Skeena, Nass, Stikine and coast have no modelled MAD).
- [x] An index row in `research/README.md`. A short pointer from `research/habitat_literature.md`.
- [x] `CLAUDE.md` data-root bullet for `ip_model_registry.csv`. `scripts/README.md`: the 0280 line (:49)
  and the "CH/BT × parameter" wording (:326-329). `research/habitat_literature.md`: the title and the
  header line (review G13).
- [ ] A cross-repo pointer comment on link#286 linking the research file.

## Phase 5: Close
- [ ] `/planning-archive`, with the README carrying Measurement and Evidence sections.
- [ ] `/gh-pr-push`, re-reading origin/main first.

## Validation

- [ ] `devtools::test("pkg")` passes; `R CMD check` is clean on `pkg`.
- [ ] `Rscript scripts/0280-literature-verify.R` exits 0, with coverage of 48/48 cells (4 species × 12
  parameters) and the model links green both ways.
- [ ] Every Sheer Table A1 model has registry rows, or a line in findings saying why not (no PDF,
  paywalled, not a threshold-defining document) (review AC1).
- [ ] `/code-check` clean on each commit.
- [ ] The store manifest md5 matches after the push.
- [ ] PWF checkboxes match landed work.
- [ ] `/planning-archive` on completion

## Subagent budget

- One Plan review (concurrent, after the baseline).
- Three drafters.
- At least 2 code-check rounds on Phases 1 and 3.

That is about 8–10 in total, over the ~5 default. Reported in the final summary.
