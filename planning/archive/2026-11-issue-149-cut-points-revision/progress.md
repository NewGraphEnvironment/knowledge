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
- Blind reader (a `Plan` agent given only the rendered text and figures) before the accuracy rounds; every point acted
  on (plainer title, which package does what, forward references gone, the standard rule defined, the panel ordinal
  computed, Table 2's uninformative column replaced by a sentence, a sentence on which limit is right).
- `/code-check` on the revision, three rounds (`review-round1.md` to `-round3.md`): the transfer stated a share as a net
  difference (now 1.1 %, the net), a visit slope printed too coarse for its colour, "best predicts" where the tuning
  keeps the close call nearest the standard rule, and round 3 (inside round 2's fix): "for each species" without
  "with enough records", "changes" for "can change", and the provenance sentence widened. Mechanism (round 3): a plain
  rewrite drops a qualifier and the shorter phrase names a larger set.
- Al: fewer labels on the inset, only Fraser River, Slim, Dome and Ptarmigan creeks; done, guarded.
- soul#745 filed with the writing and map lessons; knowledge#155 filed for Zenodo (knowledge has no concept DOI
  because Zenodo has never archived it; not a citation() limitation).

