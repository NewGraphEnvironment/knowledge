# Code-check round 5: fef21f8..HEAD (5807326, 9418f8c, 5a47f63)

## Checklist read

- code-check-python.md: in full (no Python in this diff).
- code-check.md: under "## Mechanisms", the prose of every H3 (A guard that fails toward pass; A fixture that cannot
  reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope,
  escape hatches, and remedies; A fix lands in one of two callers; Restore the bug and prove the guard fires; A
  shared working tree; A wrapper's exit is not the work; Zero-length, empty, and unset; The probe is broken before
  the world is), tables skipped; the remaining Mechanism H3s (Written data outlives the fix, Serialization loses
  meaning, One fact derived twice) by index line only. Stand-alone rules and Security: index only.
- code-check-r.md: index; read "Tests that silently do not run", "testthat counts an uncaught error under error",
  "A data-raw/ script must load the source tree", "tolerance in testthat is RELATIVE" (headings matching this diff's
  test and bundle changes); about 90 skipped.
- code-check-shell.md, code-check-spatial.md: index only (no shell or spatial code in the diff); all headings skipped.

## What was recomputed (all match unless listed under Findings)

- Results table, every cell: n_visits/n_detect/n_wsg of the pick, region size, region floors, limits and exception
  Q/D, `default`'s ddev and SE, seeds (main + 4), grid sizes, from `data/tune/*_tune.csv`, `*_summary.csv`,
  `*_seeds.csv`. Readings 1-4 and the "Against #73's picks" sentence against the old table.
- The Atlas-gradient table and its paragraph (`data/tune/grad_fwa/*_tune.csv`): every pick, every limit list, the
  639/8 split, "every pick's limit ... inside the other's region, except coho's 5.49 %".
- The 1.96 SE table and bullets: `knw_tune_repick()` from the source tree (`pkgload::load_all()`) gives the pinned
  rules and region counts 161→1,340, 36→7,051, 164→2,456, 38→1,570, 1,656→2,612, 29→263, 425→6,627, 97→7,192;
  over-90 % shares 99.4/91.7/99.6; flow-start picks; CH best rule's floor 0.75.
- Grades table (duckdb over `data/tune/*_grades.csv`) and reference rates (log 20261027_tune_run.txt); gate margins
  (null_heldout_curve - dev_curve) 378.9, 335.0, 761.9, 32.8, 14.2, 8.0, -67.1, -103.0; BT spawning 1,177 km < 0.2.
- Comparison table and readings 1-4 from the `ALL` rows of compare.csv, change.csv (by reason and order) and
  checks.csv: every number matches under `door`; free-pass and door_wetland totals match.
- Evidence: 49,928 / 45,529 (method.rds funnel), 86.7 / 13.3 % (visits_link.csv `pick_source`).
- test-tune_repick.R: pinned vector equals `knw_tune_repick(read.csv(f), 1.96)$rule` for all eight; the file passes
  (7 tests, 0 failed, 0 error) under NOT_CRAN=true with load_all.
- habitat_thresholds.Rmd placement guard: distance drops = with-a-usable-point (50,550) - far_snap (47,987) = 2,563
  (622 no stream within 500 m + 1,941 past the snap limits) against half of the placement drops (3,977 / 2 = 1,988.5).
  It counts what step 2's "most because the stream is too far away" says, over the same denominator the prose's
  "About N visits are dropped here" uses, and it fails if the distance drops fall to half or less.

## Findings

Mechanism behind the defects below: a run or structure qualifier is stated once, at the head of a block, and every
sentence under it inherits it. When the block was rewritten for #92, sentences in the block's unrewritten tail kept
the earlier run's tag (findings 3 and 4). A sentence outside the block that quotes the block's numbers (the plain-words
paragraph) dropped the qualifier, and those numbers depend on it (finding 1). I checked every other sentence in the
file that carries a run tag ("#73's", "#65's", "on #73's grades", "#65's measurement", "#73's run"). Each names its
run correctly, and no other quoted number depends on an unnamed structure.

- **[severity: claim]** research/habitat_thresholds_tuned.md:43-45. "On link's segments the picks draw less rearing
  habitat than its current test for five of the seven rearing keys (from 2 % less for coho …)". This holds only under
  `door`, and the sentence names no structure. Under `free`, which line 272 calls "the structure the rules were scored
  under", coho draws 1.4 % more (80,949 km against `default`'s 79,829; compare.csv `ALL`, `free`), so the count is four
  of seven. The other percentages move too: BT rearing -18.6 % against -23.7, CH -8.1 against -15.9, RB -11.3 against
  -17.4, ST -22.3 against -27.0. Line 321 says the structure is still link's call. Name `door` (link's `stream`) in the
  sentence.
- **[severity: claim]** research/habitat_thresholds_tuned.md:319. "`free` and `door` read alike on every check." The
  bcfishobs ratio does read alike (within 0.003 for every key). The FDIS shares do not:
  - CH's detection on the rule's segments is 17.6 % under `free` against 18.4 % under `door` (980/5,339 against
    982/5,572), a 0.8-point gap. That is about a fifth of the whole `default` → `door` move (14.9 → 18.4).
  - CO reads 32.8 against 33.5 inside and 10.4 against 10.1 outside; ST reads 7.2 against 7.4 inside.
  - The next sentence counts smaller gaps as differences ("leaves more … ST 0.6 against 0.3", a 0.2-point gap
    unrounded: 0.57 % against 0.35 %).

  So "alike" is applied to a larger gap than the one the next sentence treats as a difference. Either state the FDIS
  gaps or restrict "alike" to the ratio.
- **[severity: claim]** research/habitat_thresholds_tuned.md:330-331. "`data/compare/gpkg/<key>.gpkg` (ignored) is
  #73's view of each comparison for QGIS (#81)." #92's comparison wrote them. Its log
  (`scripts/logs/habitat/20261027_compare.txt`) has a "GeoPackage data/compare/gpkg/<key>.gpkg: N segments" line for
  all eight keys, and the local files' mtimes (2026-10-27 23:41 to 2026-10-28 01:12 PDT) fall inside that run
  (00:25Z-08:12Z). Line 323 was updated to "#73 or #92" two paragraphs above, but this sentence was not.
- **[severity: claim]** research/habitat_thresholds_tuned.md:358-359. "#73's picks differ from #65's for BT rearing,
  BT spawning, CH, RB and WCT, so those rows no longer describe the recommended rule." The file now presents #92's
  picks, and those differ from #65's for all eight keys. #65's picks from `git show 4534f40:data/thresholds.csv`
  against #92's:
  - CO: `mad>=0.03|g<=0.04|none` against `mad>=0.1|g<=0.0549|Q3@D2000`
  - GR: `width>=1.5|g<=0.0349|none` against `width>=2|g<=0.0549|none`
  - ST: `mad>=1|g<=0.0849|none` against `mad>=1|g<=0.0849|Q1@D250`

  As written, the sentence implies the CO, GR and ST floodplain rows still describe the recommended rule. None does.
- **[severity: claim]** (outside the diff, pre-existing; the numbers also hold on #92's grades)
  research/habitat_thresholds_tuned.md:392-393. "A distance of 0 still occurs … (BT rearing 53,897 graded km, CH
  51,257)". Those totals are graded km at `dist_m < 1`. At exactly 0 they are 31,109 and 30,027 km (accessible, graded,
  `dist_m = 0`, `data/tune/{BT,CH}_rear_grades.csv`). Say "within 1 m", or quote the zero totals.
- **[severity: claim]** planning/active/progress.md (the 0325 entry). "46 threshold rows, 8 keys fitted". In
  `data/thresholds.csv`, WCT's status is `underpowered`: 7 keys are fitted and 1 is underpowered. The Phase 4 entry
  below it says "the article's keys (fitted only) are seven". This is a planning record only, but it is the archive's
  evidence.
