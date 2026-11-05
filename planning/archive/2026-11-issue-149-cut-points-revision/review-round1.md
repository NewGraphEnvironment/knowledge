# Review round 1 (revision after b84b0de), #149

Scope: `revision.diff` (b84b0de..b0254c7, planning excluded). I read the full working-tree files: `vignettes/_cut_points.Rmd`,
`data-raw/vignette_bib.R`, `data-raw/vignette_cut_points_places.R`, `inst/NOTICE.md`, and the three `.bib` files, plus the
key changes in `chinook_rearing.Rmd` and `habitat_thresholds.Rmd`. I rendered `_cut_points.Rmd` from a scratch copy (exit 0,
references resolve, no `(key?)`), pulled out the three figures and looked at them, and recomputed the article's claims from
both bundles. I ran `test-vignette-data.R`, `test-settings-register.R` and `test-data-dir.R` with `NOT_CRAN=true`. The only
failure is the known environmental one ("every ignored source of the methodology article..."). The installed bundles' md5s
match the tree's.

## Checklist read
- code-check-python.md: in full (none of it applies; no Python in the revision).
- code-check.md: the prose of every H3 under `## Mechanisms`, read in full through "A wrapper's exit is not the work",
  "Zero-length, empty, and unset are three different things" and "The probe is broken before the world is". I skimmed
  "Written data outlives the fix", "Serialization loses meaning silently" and "One fact derived twice". Rules that stand
  alone: 0 read (none applies beyond Documentation Staleness, which I read from its index line).
- code-check-r.md, by heading, 7 read: "`sort()` and `order()` collate by `LC_COLLATE`...", "`$` on a list
  partial-matches...", "Read-back shape must match write-back shape", "A `data-raw/` script must load the source tree...",
  "Moving prose into a code chunk hides it from tools that scan the document", "`vapply(..., USE.NAMES = FALSE)`...", "A URL
  handed to a reader goes through R's 60 s connection timeout". The remaining ~110 headings were not read; they name tools
  the revision does not use.
- code-check-spatial.md: by index line only, for "A name is not a key: `GNIS_NAME` matches features all over BC",
  "sf: `st_intersection()` / `st_difference()` return a GEOMETRYCOLLECTION...", "`atan2(0, 0)` is 0..." and "`sf::st_read()`
  promotes a mixed POLYGON/MULTIPOLYGON layer...". I checked each against the code (see the notes at the end), not the full
  sections. The remaining ~95 were not read.
- code-check-shell.md: 0 read (the revision has no shell).

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:528-531 — The sentence "For chinook rearing it then draws `r pc(transfer_pct, 1)`
  less habitat than on the minimal network itself" prints **1.2 %**. That is false for the shipped data. `transfer_pct` is
  `tr$minimal_only_km / tr$minimal_km` (1,041.7 / 87,605.8 = 1.19 %), the habitat drawn by the minimal network alone. It is not
  how much less the transferred rule draws. The parent setup also draws 43.5 km that the minimal network does not. So the
  transferred rule draws 86,607.6 km against 87,605.8 km, which is (87,605.8 − 86,607.6) / 87,605.8 = **1.14 %, "1.1 %" at the
  printed precision**, less. The draft before the revision said it correctly: "draws 86,608 km against the 87,606 km ...:
  1,042 km, 1.2 %, is drawn on the minimal network alone". The guard on line 101 (`transfer_pct < 0.02`,
  `parent_only_km < minimal_only_km`) covers the gross share, not the net "less" the new wording states. The research note
  says the transfer cost is "1.2 % of the rule's habitat", meaning the minimal-only km, so it does not back a net "draws 1.2 %
  less" either. Fix: compute `1 - tr$parent_km / tr$minimal_km` for "less", or go back to wording about the share drawn on
  the minimal network alone.
  - **Rule:** writing.md "State each claim by the code's definition" ; writing.md "Check that each guard covers the set its
    sentence names"

- **[severity: fragile]** vignettes/_cut_points.Rmd:406-413 (strip figure) — The revision makes the label beside the visit line
  the only number in each panel, and both the prose and the caption say each example's two slopes "sit on opposite sides of
  a tuned limit". In the second panel (40144_1_1, the Kiteen River stream) the minimal network's slope is 0.0905. `grad()`
  prints it as **"9.0 %"**, on a bar coloured "over 9 % to 13 %" (`cut()` puts 0.0905 above 0.09). A reader sees 6.3 %
  against 9.0 % for a 9 % limit, and a 9.0 % label on a bar the legend calls "over 9 %". At the precision printed, the figure
  cannot show the crossing the text claims. No guard checks that the printed labels land on opposite sides of the limit they
  are said to cross. Fix: print the at-site labels with two decimals (`grad(gradient, 2)` gives "9.05 %"), or assert that
  the formatted values fall on the sides they are drawn on.
  - **Rule:** none

## Checked and holding (not findings)
- Map: the pink and orange km, the shares on small streams (0.75 / 0.75 / under 0.5) and the claim that the group was
  chosen before drawing as the one with the most disagreement (MORK, research note) all hold. The pink rule is the minimal
  network's rule exactly (`s_of("parent")$pick == s_of("minimal")$pick` is guarded).
- Examples: in each of the three groups the example is the largest crossing gap among visits with chinook, with or without
  the 50 m floor, on both minimal and parent slopes. So the prose sentence that leaves out the 50 m criterion is still true.
- Profile caption: the open circle (101360_2_1, 519 m) does lie on the same full-network segment (494 to 584 m, the same
  10.83 %).
- "13 other rules with a 13 % limit, differing in their flow floor or their allowance" holds: all 13 are `mad` rules.
- "among equals the best scorer ... so the choice is the best scorer" holds: on every setup the recommended rule is the
  lowest `ddev_best` in its region, and `.tune_pick()` orders by departures and then score.
- "differs by under 3 %" holds (spread 2.82 %, guarded `< 0.03`). The "about 400", "roughly 7,800" and "about 4,900"
  roundings hold.
- The bcfishpass and records-cut claim agrees with link's `CLAUDE.md` (it cuts at each species' top record so that code 2
  starts at the record; bcfishpass cuts at every observation).
- `vignette_bib.R`: `v$link`, `v$fresh` and `v$wet` match exactly (no partial-match risk). The radix sort fixes the order.
  The `.bib` entries render with versions and concept DOIs. No `irvine2026*` keys are left anywhere outside `planning/`.
- `vignette_cut_points_places.R`: the streams group by `gnis_name` within one group. A homonym pair would merge, but each
  label still carries its own name, so nothing false is printed. `st_intersection` in `stream_labels()` rendered cleanly on
  the shipped data.
- No host names, home paths or client identifiers appear in the diff or in `cut_points_places.rds`.
