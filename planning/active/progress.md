# Progress — README: bring it to the readme convention and describe the habitat-threshold work (#75)

## Session 2026-10-20

- Plan-mode exploration — phases approved by user
- Created branch `75-readme-bring-it-to-the-readme-convention` off main
- Scaffolded PWF baseline from issue #75 with approved phases
- Next: start Phase 1
- Phase 1: hex sticker (25e23da). Phase 3: README figure (01e137c).
- Measured: `knowledge/fdis/v3` is not uploaded (v1, v2 only); README names no FDIS version (findings).
- Phases 2, 4, 5: README rewritten in the convention's order; DESCRIPTION Title, Description and canonical
  Authors@R; `man/knowledge-package.Rd`; GitHub About set to the tagline and read back.
- Phase 6: inst/CITATION, CITATION.cff (validated), update-citation-cff workflow, NOTICE.md; filed #76 (PSCIS is Access Only)
- Plan review delivered (review-plan.md). Probed and acted on: B1 filed #77 (no scale bar or keymap in
  `knw_compare_map()`), caption names Smithers and Houston (both in BULK, queried); B2 requirements sentence
  rewritten; B3 example prose states the rule, not biology; B4 alt text scoped to reachable streams; G1 links the
  public FDIS provenance note; G2 NOTICE moved to `inst/NOTICE.md` (installs with the FWA geometry, as flooded),
  file names fixed (`gnis_seed.csv`), unlisted EcoCat, bcfishpass and PCIC-derived files added, `fdis_*.csv` glob;
  #76 brought in line; G3 bcfishobs and CABD in Data and methods, wet linked; G4 gq asserted; G5 quantifiers
  narrowed; G6 `title` doc corrected; G7 rerun line added to #68 and #73; A1/A5 plan text; CLAUDE.md's v3 line;
  O4 owed items. Kept as is: S1 NEWS is written by `/gh-pr-merge` at release (NEWS has no development heading).
- Code-check round 1 (review-round1.md): 7 findings, all reproduced and fixed: opening's "smallest flow" (link
  sizes CH by width in 188/188 groups), example prose scoped to the stream-line test, requirements sentence now
  points at each script's header, Tuning desc (knw_tune_run does not grade), CLAUDE.md's PULL claim,
  data-raw/README.md, gq translation asserted. Four sat inside earlier fixes: the loop ends on an enumeration.
- Code-check round 2 (review-round2.md, 60 + 17 claim enumeration): README requirements sentence narrowed (no
  per-script header claim; the wf_*.js have none); NOTICE adds the floodplain panel's CC BY 4.0 / OGL-Canada
  source; Data and methods names stac_floodplains_bc; data-raw/README.md drops the floodplain input, adds 0322;
  alt text names the fourth class. Hydrologic zones left out: 0310 attaches them, nothing in the tuning reads
  them (grep). Soul: figure sentence reworded as a conditional permission; evidence's unrecorded "because" dropped.
  #76 notes bcfishpass's database is ODbL (share-alike).
- Code-check round 3 (review-round3.md): enumeration of all 29 sentences rewritten since 9bb77ef and 22 soul
  sentences; 3 FALSE, fixed by narrowing to the enumerated sets: the README's floodplain sentence (102 of 121
  compare maps have the panel; plus data/compare/floodplain.csv), the NOTICE's floodplain section gains
  floodplain.csv, the rerun list gains 0325 (it writes data/thresholds.csv, which the bundle hashes). The
  requirements sentence regains a non-exhaustive list (convention item 4). Each new sentence then enumerated by
  hand against its set (floodplain.csv header, knw_floodplain_ha, 0230's S3 sync, 0150's local Zotero read);
  test-vignette-data passes 43. Loop ended on enumeration.
- Soul amendment review: reviewed in knowledge rounds 2 and 3, then a soul-only round 3 (review-soul-round3.md):
  one low finding in the original draft (the absolute-link rule also covered files pkgdown publishes, such as
  the sticker), fixed by narrowing to files the site does not publish; checked by hand against what pkgdown
  builds. Stopped there rather than a sixth reviewer. Soul commits 72a52a9, 72d0c66, a3c6072 on
  `416-readme-knowledge`.
