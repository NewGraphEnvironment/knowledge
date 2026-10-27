# Progress — A stepwise methodology article (#93)

## Session 2026-10-27

- Plan-mode exploration against the plan parked in #93's body — phases approved by Al
- Created branch `93-a-stepwise-methodology-article-the-pipel` off main (`80ea4c1`)
- Scaffolded PWF baseline with the approved phases
- Next: start Phase 1
- Plan review spawned 05:02 UTC (Plan agent, background)
- Phase 1 (#89): chinook article's evidence paragraph (placement, PCIC flows through the fwapg fork, the gradient read,
  bcfishobs scores no rule); research Evidence/Method corrected; `modelled_discharge.md` refreshed to build `94deeb5`
  (table comment, wet's checks at that commit); `0310` ledgers `wet_loaded_build`; `0230`'s snap comment fixed.
  Rendered text diff: only the paragraph moved; `test-vignette-data.R` 87 passed.
- Citations blocked: the three missing references (Schnorbus 2018 VIC-GL, Craig et al. 2020 Raven, the fwapg fork) are
  scripted for the Web API, but `op read` could not reach the 1Password desktop app. The article links the fork
  meanwhile and names PCIC, VIC-GL and Raven without a citation.
- Phase 2: `inst/method/pipeline.csv` (11 steps) and `settings.csv` (36 rows: 2 tested, the rest the to-do list);
  `R/settings_register.R` resolves `fn:` and `script:` wheres (with `[name]`/`[i]` selectors); `0320`'s 1.96 lifted to
  `se_strict`. Register test 109 passed; planted mismatches each go red (register prior SD 2: 4 failures; script
  `snap_flag_m` 150: 1; `knw_grade` `ref_quantile` 0.9: 1), run in scratch copies.
- Plan review delivered ~05:13 UTC (`review-plan.md`, 22 findings, each probed). Phase 1 follow-up: the 1:50k check
  stated as reaching only visits with a full tributary code (12,285 of 50,024); the balance also where routed is
  under 0.2 of it; bcfishobs shapes link's segments though not the snap; link's `default` reads fwapg's flows, not
  wet's; 50,024 placed vs 40,552 kept; `0310`'s new row refuses a table with no comment; `0320`'s prior log reads
  `knw_tune_run`'s default (the one that runs). Finding 13 (bib's wet version) probed: the bib keeps only
  `discharge/fwa/v1`, true of either build; no change.
- Phase 2 follow-up (review 1, 3-6, 22): `code:` kind (a literal in a body or SQL, found with the register's value);
  `script:` takes a `Sys.getenv()` default; 24 rows added (60 in all); tests for code literals, the region multiplier in
  `.tune_sel` on a toy matrix, completeness of #93's named settings, and more "names nothing" cases. 172 passed;
  mutations go red (SQL hop cap 61: 1 failure; region at 0.1 SE: 2).
- Phase 3: DiagrammeR 1.0.12, DiagrammeRsvg 0.1, rsvg 2.7.0 installed. Stickers prototyped beside the legend
  (inside the step boxes they would crowd the labels): at a legible chart width they are identical black hexes whose
  names cannot be read, so they are dropped and package is box colour alone. `data-raw/vignette_method.R` resolves all
  60 rows (78 wheres: fn 56, code 10, script 7, ext 4 at link `102762d` / wet `94deeb5`, record 1) and stops on a
  mismatch (planted bridge 5000: stopped, nothing written); the funnel's recomputed populations equal every rearing
  key's `visits_in`; examples: BULK visit 102443_1_1 kept (38.1 m, four streams in reach), 103962_6_1 dropped (239.7 m);
  on BULK's segments the overlay and connectivity drop 999 default and 225 tuned segments the predicate passed, add
  none. `test-vignette-data.R` checks the bundle's md5s (ignored sources where present): 163 passed.
- Phase 4: `vignettes/_tuning_method.Rmd` (draft, off the site): opening with the answer; flow chart; lineage (four
  outside sources, so it fits a column); losses per step (a remaining-count funnel showed near-equal bars); per-species
  population table; eleven step blocks generated from `pipeline.csv` with counts and settings; the snap and
  segment-stage examples; the register, untested and inherited first. Rendered with `rmarkdown::render()` after
  `load_all()` and read at 820 px. `^vignettes/_` in `.Rbuildignore`: tarball has no draft; pkgdown lists only
  `chinook_rearing`. CI: a draft-article guard in pkgdown.yaml, tested both ways (clean 0; a leaked
  `tuning_method.html` or `_tuning_method.html` 1). Step 2's text and the 1:50k overstatement fixed in `pipeline.csv`;
  "open work" lists open issues only.
- `/code-check branch` round 1 (spawned 05:50 UTC, delivered ~06:03; `review-round1.md`): 11 findings, all probed and
  fixed. The "kept" example was dropped later (no fished area): now drawn from the kept visits. 1:50k counts were over
  every visit with a point, placed or not: placed-only 12,260 and 1,295. The grade's size column is chosen per rule
  (`grade_species.R:78`), so the register's `fn:knw_grade:cols` rows named the wrong thing: replaced by `code:` rows
  for the width and MAD cases and the grade's gradient. The region test's toy matrix could not tell multipliers apart:
  rebuilt with rules at 0.9 and 1.1 SE. `se_region`/`se_strict` now also watch `R/thresholds_table.R`'s literals. A
  `code:` entry now requires every occurrence outside a comment to carry the value (the distance offset had four
  unwatched copies). The YAML check errors on a missing parent instead of reading "unset". `prior_sd` marked tested
  (compared with no prior). bcfishobs FDIS share corrected (29 % for link's species, not "about half"). wet `94deeb5`
  is 0.4.13. Mutations: region at 1.96 and 0.5 SE, one offset copy changed: each 1 failure.
- Round 2 (spawned 06:09 UTC, delivered ~06:20; `review-round2.md`): 8 findings, 4 inside round 1's fixes, all probed
  and fixed: unwatched copies of the gradient ceiling (`tune_curve.R` 159, 176) and the 1:50k code length
  (`0230:449`, plus its 42 zeros as a row); a YAML leaf absent under a present parent read "unset" (now the leaf must be
  a key the sibling's R code reads at that commit); the bundle named the parent commit (the script now refuses to run
  with its code or registers uncommitted); `fit` and `seed` were compared with alternatives; step 4 and the chinook
  article dropped the own-line condition of the 0.2 cut; wet's republish dates; "four sources" against six named.
- Enumeration (the loop's end, since rounds found defects inside fixes): every token occurrence of every `code:` row's
  value in its files, comments skipped: 42, 31 covered by a where, 11 others each a different quantity or a token-match
  artefact (listed in findings.md). And every row's `tested` flag walked against its evidence: `se_strict` and
  `tuned_as` were compared with alternatives too; 7 rows tested in all.
- Round 3 (spawned 06:24 UTC, delivered ~06:34; `review-round3.md`), asked for the mechanism: each guard checks the
  copies its author listed, and the round 2 enumeration searched only files the wheres already name. Fixed: the 1:50k
  check stated with its crosswalk condition (the article said it "reaches" 12,260; a code the crosswalk does not know
  cannot disagree) in the article, research, step 2 and the chinook article; the bundle's tracked/ignored split is now
  git's (`_grades.csv` is ignored and would fail the test on a clone); the dirty check covers every file a script: or
  code: row reads and errors on a git failure; the leaf check greps link for the access path `pipeline$discharge_source`;
  the article, the funnel reasons and the snap query take their values from the register; 0320's log and the chinook
  article's 1.96 are watched; the 42-of-45 relation is tested; era labels noted against the breaks.
