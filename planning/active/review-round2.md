# Code-check round 2: branch 149 (cut-points article), base 0db4bef, HEAD 7616af4

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, skipping table rows and evidence blocks. Of the
  standalone rules, none read (0 of 22 non-Mechanisms headings opened).
- code-check-r.md (by heading): "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is
  locale-dependent"; "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a
  presence check can each depend on it". 2 read, 115 not read. (The other R headings this diff touches, such as
  `system2()` status and `tolerance`, were covered in round 1, and I re-checked their call sites without re-reading.)
- code-check-spatial.md: none read; round 1 covered the places script's spatial headings, and the script has not
  changed since then. 94 not read.
- code-check-shell.md: none read. The diff has no shell. 70 not read.

What I ran, all read-only: rendered `vignettes/_cut_points.Rmd` from a scratch copy after `pkgload::load_all()`. It
rendered with no stopifnot failure, and I read the rendered text. I also ran R reading both bundles,
`inst/vignette-data/method.rds` and `data/thresholds.csv`, one read-only query against the local database's break
tables for the concept stream, and `test-vignette-data.R`. That test gives 5 failures, all in the pre-existing
methodology-evidence test, and 2 skips.

Round-1 fixes re-checked and found sound:
- Close calls are now stated by rule. `n_lim()` gives 13 for 13 % rules on the minimal records, matching round 1's
  count.
- The example rule names the exclusion of the concept site's group. There are only 5 candidates (UFRA, KLUM, LNAR,
  LSKE, COTR), so the rule as worded gives KLUM, LNAR and LSKE.
- The crossing count and the steep shares now read `minimal_gradient` (408 sites, 7 with chinook, 309 steeper on the
  full network). Each example is guarded `parent_gradient == minimal_gradient`.
- The Atlas-line length claim is gone.
- On the tie-break: every close call has `departures == 3`, and every recommended rule has `ddev_best == 0`, so "the
  choice is the best scorer" holds. It also follows from `knw_tune_repick()`'s ordering
  `order(dep, dev_heldout)`.
- The provenance sentence now names only what the script checks.
- "fish" became "chinook".
- In all three examples the full segment is shorter than the minimal one, as "the shorter segment" requires (60 vs
  214 m, 109 vs 764 m, 201 vs 739 m).
- No ties in gap at any pick, so the test's base `order()` cannot disagree with `dplyr::arrange()`'s C collation on
  this bundle.

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:436-438 (and the opening, line 127) — "The thresholds this package
  tuned on 4 November 2026 ... Each is a property of that pairing as well as of the fish: on another network, or with
  slopes read another way, the same records choose another rule."
  - "Each" covers every published threshold. The article's own bundle contradicts it. `x$other_keys` has
    `network_moved == "same"` for CO_rear, GR_rear and WCT_rear: on the minimal network the same records choose the
    same rule for 3 of the 7 keys. For ST_rear the two picks differ, but each is a close call on the other's records.
    By the article's own definition (line 320-321), that is not a disagreement.
  - On the slope axis, `method.rds$gradient_sensitivity` shows BT_rear and GR_rear choosing the same rule on the
    Atlas line's slope (`pick == pick_atlas`).
  - The paragraph three sections earlier (lines 361-364) states the narrower result correctly: 4 of 7 move, and 3 of
    7 fall outside the other's region.
  - No guard covers the sentence. It holds for chinook rearing only.
  - The opening, "That moves the thresholds this package tunes from the same catches", makes the same generalisation
    in milder form.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "A proxy is not the property"

- **[severity: bug]** vignettes/_cut_points.Rmd:453-454 — Limits: "Chinook rearing is the only species and stage
  tuned on all four; the others were tuned on the full and minimal networks only."
  - The other keys were also tuned on the full network reading the Atlas line's slope:
    - run `20261104_0543`'s `grad_fwa` sensitivity (`scripts/logs/habitat/20261104_tune_run-20261104_0543-p20261104072745-grad_fwa.txt`
      scores every modelled key on `fwa_gradient`);
    - `inst/vignette-data/method.rds$gradient_sensitivity` holds BT_rear, BT_spawn, CO_rear, GR_rear and ST_rear picks
      on that slope.
  - The methodology article publishes the result ("Scored on the whole Atlas line's slope instead, the chosen rule is
    still a close call for N of M species", habitat_thresholds.Rmd:400-401).
  - That sensitivity reads the visit's own Atlas line (`fwa_gradient`), not the segment's (`segment_fwa_gradient`,
    this article's fourth setup). The two differ at 732 visits. So the accurate statement is narrower: only chinook
    rearing was tuned on the minimal parent's slope, and on the segment's Atlas line. "On the full and minimal
    networks only" is wrong as written, and it contradicts a sibling article.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/_cut_points.Rmd:457-458 (computed at 113, 118) — Limits: "Few sites carry the
  difference: 7 of the 408 sites whose slope changes side of a chosen limit caught chinook."
  - "The difference" is the tuned choice, but the 408 are counted on the 7,823-site population before the tuning drops
    groups with only one outcome. Only 225 of the 408 are among the 4,858 sites the four tunings scored (`both_out`,
    line 116). The other 183 sit in groups where chinook were caught at no site or at every site, and they contribute
    nothing to any choice.
  - The numerator is unaffected: all 7 chinook crossings are in the scored set. So the honest statement is 7 of 225.
  - The paragraph at lines 225-229 counts the 408 explicitly on the 7,823, and is fine as written. This Limits bullet
    reuses the count for a claim about what moved the choice, which is a different population. Same axis as round 1's
    population fixes, moved from the slope column to the site set.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:208, 220, 323-324 — The counts called "electrofishing sites" are
  site visits.
  - The population and premise tables are keyed by `site_visit`. The bundle's 7,823 rows hold 7,814 distinct site ids
    (the `<site>_<visit>` suffix stripped), at 6,861 distinct (blue line, rounded measure) positions.
  - The footnote's 29,335 and the 4,858 are visit counts too. Research and the methodology article count them as
    visits ("site visits", "45,529 visits").
  - The gap is small for the 7,823 (9 visits), but "N sites" is not what the code counts.
  - **Rule:** code-check.md "A proxy is not the property"
