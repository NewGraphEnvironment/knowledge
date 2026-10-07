# Task: Evidence vocabulary has no groundwater / upwelling variable (#36)

`knw_literature_vocab()` has no variable for groundwater. In #33 the drafter left out the pure groundwater
statements, from the 2010 critical habitat rule's hyporheic passages and from Hagen & Weber 2019 p. 22. Other
statements went in under `temperature` (cold springs) or `valley_width_index` (alluvial, bounded valley reaches).

## Context

`knw_literature_vocab()$variable` (`pkg/R/literature.R:44`) has no groundwater term. In #33 the drafter left out
the statements that are only about groundwater, and put the mixed ones under `temperature` (cold springs) or
`valley_width_index` (alluvial reaches), with notes saying "(the vocabulary has no groundwater variable)".
`research/bt_spawning.md:69` names the gap. After gradient, groundwater is the site feature the BT spawning
literature stresses most.

What I found:
- `.literature_check()` checks units against a `fits` list (`literature.R:223`). A variable missing from `fits`
  takes no unit, and a value needs a unit, so an entry of `character(0)` makes a variable **qualitative only**
  with no other code. None of the #33 sources gives an upwelling flux, so I'm not adding a flux unit. That
  matches the issue's first option, and a unit can be added later without changing anything already written.
- `0280` checks a `qual` row by its quote alone, and the thermal grid (`0280:71-75`) covers only temperature
  and degree_days, so the gate needs no change. `ip.R` reads only `life_stage`/`life_history_form` from the
  literature vocab.
- Where the existing rows mention groundwater:
  - data rows 494 (Metolius p. 36), 504 (USFWS 2015 p. 5) and 506 (USFWS 2015 p. 6) are the stand-ins;
  - 502/503 (Hagen & Sary 2023 p. 4) are one sentence that already fills two rows (elevation, vwi) and also
    names "groundwater exchange";
  - row 95 (Trotter 2000 p. 9) is about springs.
- The statements left out in #33 (`planning/archive/2026-10-issue-33-*/draft-spawn-notes.md`, flag 2):
  - 2010 rule p. 63930, hyporheic flow (Baxter & Hauer 2000), spawning;
  - Hagen & Weber 2019 p. 22, aggrading areas and groundwater infiltration, spawning;
  - Hagen & Weber 2019 p. 19, groundwater areas gave higher egg-to-alevin survival (Baxter 1997), incubation;
  - USFWS 2015 p. 6, embryos survived better under upwelling (Baxter & McPhail 1999), incubation.
  - The 2010 rule's "cold-water springs … groundwater upwelling" sentence is the same claim as USFWS 2015
    p. 5 (shared ancestor, #33 flag 3). It goes in that row's note, not a second row.
- Precedent for one quote filling two variables: Hagen & Sary 2023 p. 4.

**How existing rows change (my call, stated here so you can veto it):** add `groundwater` sibling rows that
reuse the existing quote. I don't recode the original rows, because the temperature and valley claims are
true too. Then I drop "(the vocabulary has no groundwater variable)" from their notes. Each sibling gets a
per-row meaning audit (CLAUDE.md, "the gate checks words, not meaning").

The package moves from 0.3.0 to 0.3.1, with a NEWS entry in the same commit, as #38 did.

## Phase 1: Vocabulary and test
- [x] Failing tests in `pkg/tests/testthat/test-literature.R`: `groundwater` is in `knw_literature_vocab()$variable`; a `groundwater` `qual` row reads; a `groundwater` row with any unit is refused ("does not fit variable groundwater") and a `groundwater` value with a unit is refused too. (A value with no unit is the generic rule, already tested; dropped here.)
- [x] Add `groundwater` to `variable`, and `groundwater = character(0)` to `fits` in `.literature_check()`, with a comment that it is qualitative until a source gives an upwelling measure (plan review G1: a vertical hydraulic gradient would be the likely number, not a flux)
- [x] Roxygen: one sentence in `knw_literature_vocab()` docs (groundwater, upwelling, hyporheic exchange and springs; qualitative only); `devtools::document()`
- [x] NEWS 0.3.1 entry + DESCRIPTION bump; `devtools::test()` and `devtools::check()` clean
- [x] Prove the unit guard fires: give `groundwater` a unit (`"m/s"`) in a copy of the code, and both unit assertions go red. (Plan review B1: *dropping* the entry would not go red, because a variable absent from `fits` already refuses every unit; `character(0)` states the intent.)

## Phase 2: Evidence rows
- [x] Pull page text with the #29 `scratch_keytext.py` (copied to the scratchpad) for `hagen_weber2019Limitingfactorsa`, `u_s_fishandwildlifeservice2015Recoveryplan`, `u_s_fishandwildlifeservice2010Endangeredthreatened`, `trotter2000Headwaterfishes`; take verbatim quotes for the four left-out statements
- [x] Add the four new `groundwater` `qual` rows (2 spawning, 2 incubation), with `cited_source`, `scale` and `note`. Landed: five from the #33 list plus the 2010 rule's Fraley and Shepard sentence, two Metolius rows (plan review G5) and Pratt 1992 (meaning audit), all appended as data rows 675-686
- [x] Add `groundwater` siblings for data rows 493, 501/502 (one sibling), 503 and 505 (the plan's numbers were file lines). Trotter 2000 (data row 94) got none: it is about distribution, not spawning sites
- [x] Notes on 493 and 503: drop "(the vocabulary has no groundwater variable)". The 2010 rule's parallel sentence is in 677's note
- [x] Meaning audit for every new or changed row against its PDF page, one line per row, in `findings.md`
- [x] `Rscript scripts/0280-literature-verify.R`: all new quotes verify, no new failures; commit its log as the run's evidence

## Phase 3: Docs
- [x] `research/bt_spawning.md:69`: replace "has no groundwater variable (#36)" with where the groundwater rows now are; refresh the header's Verified line
- [x] CLAUDE.md `literature_evidence.csv` description: note that `groundwater` is qualitative only (one clause, if it fits the existing sentence)
- [x] Edit issue #36's body only if the work moves from what it says: no edit, since the issue already offered the no-unit option

## Validation

- [x] Tests pass
- [x] `/code-check` clean on each commit (Phase 1: two rounds Clean; Phase 2: two meaning-audit rounds plus enumeration; Phase 3 is prose only, no subagent round)
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion
