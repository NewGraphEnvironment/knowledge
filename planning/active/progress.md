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
