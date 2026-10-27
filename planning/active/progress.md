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
