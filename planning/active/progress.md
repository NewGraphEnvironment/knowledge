# Progress: revising the cut-points draft (#149)

## Session 2026-11-05
- Al's review of the rendered draft written into #149's body as tasks; this PWF opened on the PR branch.
- Phase 1: `data-raw/vignette_bib.R` cites `link`, `fresh` and `wet` from their own `citation()` (concept DOIs), keyed
  by name, versions from the run; all three articles moved to `@link`, `@fresh`, `@wet`.
- Phase 2: the places file carries MORK's 79 named streams (order 3+, 2 km+ in the group) for labels.
- Phase 3: the article restructured: why first (what knowledge does with link, rule against habitat, chinook as the
  worked example, research notes linked in the opening); the map second, on Esri topo blended with shaded relief
  (`gq::gq_basemap_tiles()`, fetched at build), with Atlas stream names on both panels and navy/orange/pink lines that
  stand off the basemap's blue water; then the profile, the examples (thinner bars, a sky/amber/orange palette, the
  visit's slopes labelled beside the line), then the frequency table with its why; the tunings as a table with plain
  definitions; counts rounded where they only give scale; the other-species paragraph cut; Limits undated and saying
  what would separate the cut sources. Rendered and every figure checked at page width.

