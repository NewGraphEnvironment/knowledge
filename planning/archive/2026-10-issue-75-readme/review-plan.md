# Plan review for #75 (Plan agent, spawned 2026-10-20 15:13 UTC, delivered ~15:23 UTC)

Reviewed the plan and the commits landed by then (phases 1-6). Findings, condensed; each probed before acting
(disposition in progress.md).

## Blocker
- B1 figure fails cartography checks 3, 7, 9: `knw_compare_map()` draws no scale bar or keymap; no issue filed.
- B2 Installation's requirements sentence omits bcfishpass, wet's discharge, cabd/bcfishobs, Zotero, AWS, Python.
- B3 the example's prose states the model rule as biology ("Juvenile chinook rear where ...").
- B4 alt text says "streams"; the map draws only segments chinook can reach.

## Gap
- G1 the FDIS sentence names no manifest a stranger can open; `fdis/README.md` (public) names v2's.
- G2 NOTICE: `gnis_<wsg>.csv` does not exist (`gnis_seed.csv`); EcoCat-derived root `fiss_*` tables, the
  per-group `fiss_xls_*` logs, `corpus_tags.csv`, `context_*.md`, `reports_found.md` not listed; `data/fdis_*` glob
  includes the Province's `fdis_README.md`; FWA maps in `man/figures/readme-bulk.png` and `research/fig/` not
  listed; a root NOTICE.md is not installed with the package, which ships FWA geometry: use `inst/NOTICE.md`.
- G3 Data and methods misses bcfishobs, CABD, hydrologic zones, stac_floodplains_bc; wet unlinked.
- G4 gq styling not asserted in `data-raw/readme_figure.R` (the function falls back silently).
- G5 "where a species can spawn and rear" and "tuned thresholds for each species" overstate the set.
- G6 `knw_compare_map()` roxygen says `title` goes under the map; the PNG never draws it.
- G7 nothing guards the pasted example or the figure against a retune (#73, #68).
- G8 the article link shows raw Rmd on GitHub (accepted while #56 is open; owed).

## Ordering
- O1 re-set and read back About after the last review round. O2 resolved. O3 cross-link #76 from #56.
- O4 DESCRIPTION URL, inst/CITATION and CITATION.cff url point at the pkgdown site (404 until #56): owed.

## Assumption
- A1 plan text still says v3; CLAUDE.md says 0299 publishes v3. A2 gains are few at 600 px; caption should say so.
- A5 18 topic files, not 19. A6 PNG bytes depend on tmap/ragg/fonts: compare pixels, not bytes.

## Scope / Acceptance
- S1 NEWS for user-visible DESCRIPTION and doc changes. Ac1 add NOTICE, #76 table, CITATION.cff abstract to the
  claim enumeration. Ac2 R CMD check top-level NOTEs; relative LICENSE/NOTICE links on the built site.
- Ac3 example matches byte for byte (reran). Ac4 739 words; Ecosystem table ~150 of them.
