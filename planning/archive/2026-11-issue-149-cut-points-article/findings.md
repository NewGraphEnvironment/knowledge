# Findings — An article on how link's cut points move the tuned rules, shown on our own data (#149)

## Issue context

**If done:** a reader can see, on maps and figures of our own data, how where link cuts a stream changes the slope a rule reads at a fish site, and how far the tuned rules moved with it. The methodology article carries a short section that answers the question and links here. **If never:** the cut-point bias stays in `research/minimal_network_tuning.md`, a specification few readers open, and anyone using the thresholds has no way to judge how much they depend on the network they were tuned on.

## Problem

link cuts streams into segments, partly where fish of the species it models were caught. So a site that caught fish tends to start a short segment of its own, and the slope a rule reads there is worked out over a stretch that begins at the catch. Measured on stream-branch sites that start a segment of their own:

| network | sites with fish | sites without |
|---|---|---|
| link 0.66.0's full network (published until 2026-11-04) | 86 % | 10 % |
| link 0.78.2's full network (published since #145) | 44 % | 7 % |
| link's minimal network (cut only at barriers and access gradients) | 3.4 % | 3.0 % |

The picks moved with the network. Chinook rearing's slope limit is 11 % on the first, 13 % on the second and 9 % on the third. On the same flows and range, the minimal network and the new full network pick different rules for four of seven keys, three of them outside the other's region (`research/minimal_network_tuning.md`, "The full network on the same flows and range"). This is written as a specification; it needs a public article.

## Proposed

A pkgdown article, drafted as `vignettes/_cut_points.Rmd` (kept off the site until reviewed), led by figures:

- [ ] **Concept figures.** One stream cut three ways: at a catch, at barriers only, and as a full segment reading its minimal parent's slope. Show where the segment starts and the slope each version reads.
- [ ] **Real examples where it bites.** Choose a few sites and streams from the evidence where the cut moves the slope across a tuned limit, and a watershed group where the drawn habitat differs most between setups and maps clearly. Map each setup side by side. State the selection criteria before drawing, as `0330`'s maps do.
- [ ] **The consequence for the rules.** For each key, the pick on each setup, and whether it sits in the others' regions, plus the km each draws. The numbers come from #120's chinook-on-every-setup run and #145's tables.
- [ ] **What it means for a user.** Which network a published rule was tuned on, and what changes when it is applied on another.
- [ ] A short section in `vignettes/habitat_thresholds.Rmd` that answers the question in two or three sentences and links this article. The article links back to that section.
- [ ] A `data-raw/` script that writes the article's bundle, with every number in the prose computed inline and checked by `stopifnot()`.

This issue takes over #120's last task ("`research/` gains what each break source does to the tuning, and the trade-off between the network a rule is tuned on and the one it is deployed on; the methodology article gets a short section"). That task stays listed in #120 until this lands.

~~**Blocked by** #120's chinook-on-every-setup run~~ **Unblocked (2026-11-05):** chinook rearing is scored on every setup (published `20261104_0543`, minimal `20261103_0838`, parent `20261105_0436`, Atlas line `20261105_0437`), with the transfer cost, a GeoPackage of every setup's verdict on the full network and a first figure (MORK). The results and their checks are `research/minimal_network_tuning.md`, "Chinook rearing on every setup"; the numbers are `scripts/logs/habitat/20261105_setup_compare-ch_rear.txt`, written by `data-raw/setup_compare.R`. They are on `main` since PR #150 (v0.4.28).

## How the work splits across machines

The bundle's inputs exist only where link's full and minimal builds are loaded (`fresh_default` with `streams_parent`, `fresh_default_minimal`) and where #120's runs left their ignored outputs. Everything after the bundle reads `inst/vignette-data/` and runs anywhere. So the work is two sittings:

1. **On the database's host (about 15 minutes): stage the inputs.** Write a staging script that copies into one ignored directory, with a manifest of md5s:
   - [ ] `data/compare/setups/CH_rear_setups.gpkg` (every full-network segment any setup draws, with geometry and all four setups' verdicts; written by `data-raw/setup_compare.R`)
   - [ ] `data/fdis/derived_parent/visits_link.csv` and `data/fdis/derived_minimal/visits_link.csv` (each site's slope under each setup)
   - [ ] full- and minimal-network segments, with geometry, gradient and parent ids, on every stream holding a site whose slope crosses 9 % or 13 % between setups (a few hundred streams), for the "one stream cut three ways" figure: the minimal network's geometry is not in the GeoPackage

   Then carry the directory to the machine that writes the article (copy it, or put it in the bucket's private `archive/knowledge/` beside #120's runs). The Atlas-line run (`20261105_0437`) is not archived until link mints its token (NewGraphEnvironment/link#460), so its segments travel only in the GeoPackage.
2. **On any machine: the rest.** The bundle script (`data-raw/`) reads the staged directory by its manifest, not the database. Then the article, the methodology article's section, the tests and pins, and the review rounds. A stream the drawing needs outside the staged set is one more short query on the database's host.

Settle at the plan gate: the article's per-key table. Only chinook rearing has all four setups; the other six keys have the published and minimal runs (#145's tables). Chinook alone, or every key on the setups it has.

**Related, not in scope:** the same layout for the species. An article on the tuned outcomes across species, with a short section per species that links that species' own article. File it when reached.

Relates to #120, #145.

## The sites where the cut moves the slope across a limit (2026-11-05, m4)

On the tuning's chinook rearing population before its model filters (knw_tune_run()'s visits_in: 7,823 sites, 235
with fish), 1,215 sites read gradients on opposite sides of 9, 11 or 13 % on two of the four setups; 24 of them caught
chinook, on 22 blue lines in 14 groups. Between the full network's own gradient and its minimal parent's alone, 7
fish sites cross. The strongest: UFRA `101349_1_1` starts a 90 m full segment at 10.8 % on a 570 m minimal parent at
3.4 %, with its Atlas line at 15.8 %. So the effect on a pick comes mostly from the many empty sites that cross, not
the few fish sites; the article has to say so.

## The bundle (2026-11-05)

- The crossing used for the examples is the full segment's gradient against its minimal parent's at 9 or 13 %: 407
  population sites cross, 7 of them with chinook caught. The stage's wider criterion (any two of four setups, 9, 11 or
  13 %) counts 1,215 and 24.
- Concept stream, UFRA `101349_1_1` (blue line 356358218, no GNIS name): the full network cuts at 489 m and 494 m
  (the catch) and 584 m, so the site reads 10.8 % over 90 m; the minimal network reads 3.4 % over 14–584 m; the
  Atlas line 15.8 % over 3 km. Above 584 m both networks agree (17.4–19 %).
- One example window (LSKE) has no lake or river within it; its water layer is empty.
- Phase 4's tests should cover the plan review's C1/C2: the premise, setups, transfer and other-keys counts as the
  bundle holds them, and the staged md5s where the stage exists.

## The branch review (2026-11-05)

Every finding of five rounds was in the article's words, not the scripts' code. The cause: claims written from the
research notes and guarded on the number they quote, not on the words that scope it. What ended it was cutting
restated detail (cut-source lists, population filters) in favour of links to the methodology article and "among
them" lists, then enumerating every claim. tmap pads a panel whose box is another shape than its canvas, and the scale
bar then reads short: draw each panel on a canvas of its own box's shape.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `GEOS does not support XYM or XYZM geometries` at `st_buffer()` on staged Atlas lines | `st_zm()` before the buffer |
| `pick_network_compare.csv` refused: 8 rows (rainbow trout empty) and `same`, not `none` | read the rows both networks fitted; moved is `!= "same"` |
| `id_segment` missing on Atlas lines in the profile | a common `id` (segment id or linear feature id) |
| `%-d` in `format()` printed "-d" in the rendered date | build the day with `as.integer(format(d, "%d"))` |
| `expect_equal(..., scale = 1)` warned "Unused arguments" under testthat 3e | `expect_lt(abs(a - b), tol)` |
| `read.csv()` read an empty cell as `""`, so a key no network fitted counted | `na.strings = c("", "NA")`, as `read_csv` reads it |
| tmap scale bars read short on the group map | each panel on a canvas of its own box's shape |
