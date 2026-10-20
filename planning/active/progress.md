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
