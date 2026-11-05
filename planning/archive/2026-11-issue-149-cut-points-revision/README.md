## Outcome

The second pass on the cut-points draft (`vignettes/_cut_points.Rmd`, PR #153), after Al's review of the rendered page:
the article now opens with what `knowledge` does with link and why a cut at a catch matters, shows the group map
second on Esri's topographic map blended with shaded relief (fetched at build through `gq::gq_basemap_tiles()`) with
Freshwater Atlas stream names, puts the example strip before the table of how often a visit starts its own segment,
lays the four tunings out in a table with plain definitions, and states fewer, rounded counts. Our packages are now
cited from their own `citation()` with their concept DOIs in all three articles (`data-raw/vignette_bib.R`, soul#40's
convention, which the script had predated). What was learned: a blind reader before the accuracy rounds found what
five accuracy rounds had not (the page did not say what it was for), and the accuracy rounds then caught plain
rewrites that had dropped a qualifier. The lessons are soul#745; knowledge's own missing DOI is #155.

## Measurement

- The transfer cost, corrected in review: the minimal network's rule run on the full network draws 1.1 % less habitat
  than on the minimal network (86,608 against 87,606 km); the 1.2 % first printed was the share drawn by the minimal
  network alone.
- Group map, measured on the render: the panels keep their scale (each drawn on a canvas of its own box's shape).

## Evidence

`review-round*.md` in this directory (round 3 carries the 57-claim enumeration). After Al's further edits (the approved link and knowledge paragraphs, "habitat definition" for "rule", the bar
graph, the black-and-white palette on every figure, a faded basemap), `review-final-round1.md` found a count broken by
the "rule" swap ("three parameters" for "three parts") and `review-final-round2.md` ended clean on a 64-claim
enumeration. On Al's approval the article was published as `vignettes/stream_splits.Rmd` with a section in the methodology
article (`#cuts`); `review-final-round3.md` (a 20-claim enumeration of that delta) found the section dated by the
wrong bundle, a guard narrower than its plural, and two `CLAUDE.md` lines; all fixed.

## Owed

- On Al's approval of the rendered page: rename to `vignettes/cut_points.Rmd`, update `data-raw/vignette_bib.R`'s path, add the methodology article's short section linking it, and point its segments Limits bullet there.
- Tick #120's last task when this lands.

Closed by: PR #153 (branch `149-an-article-on-how-link-s-cut-points-move`)
