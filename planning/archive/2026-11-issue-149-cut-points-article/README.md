## Outcome

A draft pkgdown article, `vignettes/_cut_points.Rmd` ("How link's cut points move a tuned slope limit"), shows on our
own data how where link cuts a stream changes the slope a rule reads at a fish visit, and how far chinook rearing's
tuned rule moved with it. It leads with a longitudinal profile of one real stream cut both ways, then the share of
visits starting their own segment on three networks, three example visits drawn as a strip of each network's segments,
chinook rearing tuned four ways (full network 13 %, minimal 9 %, full network on its minimal parent's slope 9 %, Atlas
line 15 %), the group map (Morkill), what it means for a user, and limits. The work split across two machines: the
stage (`data-raw/cut_points_stage.R`) and the bundle (`data-raw/vignette_cut_points.R`) ran on the database's host;
the article, places (`data-raw/vignette_cut_points_places.R`), references, tests and review ran on the other. What
was learned: the branch review's seventeen-plus findings were all in the article's words, never in the scripts' code,
because each sentence was written from the research notes and guarded on its number rather than the words that scope
it; cutting restated detail (population filters, cut-source lists) in favour of links ended the loop where adding
guards had not. Side-by-side maps of the example visits failed at page width and became a strip diagram.

## Measurement

- Visits starting their own segment, with fish / without: 86.2 / 10.2 % (link 0.66.0 full), 44.2 / 6.6 % (0.78.2
  full), 3.4 / 3.0 % (minimal), each equal to its segment gradient check log.
- Chinook rearing's 7,823 starting visits (235 with chinook): 408 read a slope on opposite sides of 9 or 13 % on the
  two networks, 7 with chinook; of the 4,858 scored visits, 225 and 7. The full network reads the steeper slope at most
  of them; these runs do not say which of its cuts move them.
- The transfer: the minimal network's rule run on the full network through each segment's parent draws 86,608 km
  against 87,606 km (1,042 km, 1.2 %, minimal network only).
- Group map scale, measured on the render after round 5's fix: 6.17 px/km upper panel (20 km bar 123 px), 36 px/km
  zoom (4 km bar 143 px; the dashed 15 km square 540 of 1,050 px). Before the fix tmap padded both panels and the bars
  read short (round 5).
- Body prose 1,503 words before the review; the review cut restated detail.

## Evidence

`scripts/logs/habitat/20261105_cut_points_stage*` (the stage's md5s and build ids); the reviews in this directory,
`review-round*.md`, each with its claim enumeration from round 3 on.

## Owed

- Tick #120's last task when this lands (it stays listed there until then).
- If the article is still a draft at merge: its rename and the methodology section.
- File "the same layout for the species" when reached (named in #149, not in scope).
- On Al's approval of the rendered page (review copy published as a private Artifact): rename to
  `vignettes/cut_points.Rmd`, update `data-raw/vignette_bib.R`'s path, add the methodology article's short section
  linking it, and point its segments Limits bullet there.

Closed by: PR (to be opened from branch `149-an-article-on-how-link-s-cut-points-move`)
