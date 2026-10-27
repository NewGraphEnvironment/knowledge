# #93 (with #89): a stepwise methodology article and a settings register

## Outcome

#89's corrections landed: the chinook article and `research/habitat_thresholds_tuned.md` now say how an FDIS visit
reaches the network (snapped by `fwa_indexpoint()`, kept within 100 m and, where it carries a full 1:50k tributary
code the Atlas crosswalk knows, inside it), which flows the segments carry (wet's pick: PCIC routed through the fwapg
fork's crosswalk, the balance where routed does not reach or, on a segment's own line, is under 0.2 of it), which
gradient the tuning scored (the Atlas line's), and that bcfishobs scores no rule though it shapes link's segments;
`research/modelled_discharge.md` describes the loaded build `94deeb5`, and `0310` ledgers the table comment. For #93,
`inst/method/pipeline.csv` (11 steps) and `inst/method/settings.csv` (67 rows) are the article's spine: each setting
names where its value lives (`fn:`, `script:`, `code:`, `ext:`, `record:`), `test-settings-register.R` holds the code to
the register, and `data-raw/vignette_method.R` resolves every row against the run (link at the comparison's
`config_sha`, wet at the loaded build), recomputes the record funnel and checks it against each key's population,
draws the flow and lineage SVGs and writes `inst/vignette-data/method.rds`. The draft article
`vignettes/_tuning_method.Rmd` is off the site (pkgdown skips `_` names; `.Rbuildignore`; a CI guard). What was
learned: walking the pipeline found errors in prose that had passed review (the 1:50k check overstated three times,
the 0.2 cut's own-line condition, link's `default` reading fwapg's flows not wet's, bcfishobs's FDIS share), and the
review rounds showed the register's own guards failing the same way: each checked the copies its author listed. Only
an enumeration over every file the pipeline runs closed that.

## Measurement

- Funnel (ledger `20261022`): 51,587 FDIS visits; 50,550 with a point; 50,024 placed; then far snap −5,242, 1:50k
  −1,088, date −23, effort −1,353, catch −275, no link segment −1,491: 40,552 kept. Placement accounts for 71.5 % of
  the 11,035 dropped. Per rearing key the recomputed population equals `visits_in` (CH 7,123; scored 4,490 in 43
  groups).
- 1:50k check: 12,260 placed visits carry a full tributary code and 1,295 disagree (0230 also counts unplaced visits:
  12,285 and 1,311). Round 3 measured 1,387 of the 12,260 with a code the crosswalk does not know.
- Flows on kept visits: routed 86.3 %, balance 13.7 % (1,905 of the 5,561 balance visits have a routed value).
  Build `94deeb5`: routed picked on 3,154,131 segments, balance 1,378,712 (222,906 under the cut).
- bcfishobs: 64,735 of 225,153 observations for link's twelve species codes carry an FDIS collection id (29 %; 44 %
  over all species). The earlier "about half" was the all-species share.
- Register: 67 rows, 7 tested against another value (grid_grad, prior_sd, se_region, se_strict, fit, seed, tuned_as).
  The enumeration over the pipeline's files: 565 token occurrences of register values, 142 covered; the rest share a
  value only (findings.md lists the classes).
- Bulkley stages: fresh's predicate passes 7,699 segments for `default` and 5,181 for the tuned rule; overlay and
  connectivity leave 6,700 and 4,956.
- Full suite: 1,279 passed, 0 skipped, 0 failed.

Wrong turns kept: the first funnel chart showed remaining counts as near-equal bars (replaced by losses per step); the
lineage chart read worse left to right; hex stickers were tried and dropped; the first worked "kept" example was a
visit dropped later for its effort; a `summarise()` call read summed flags (stage drops of 0).

## Evidence

`scripts/logs/habitat/20261022_evidence_build_ledger.csv`; `review-plan.md` and `review-round{1,2,3}.md` here.

## Owed

- Cite PCIC's VIC-GL (Schnorbus 2018), Raven (Craig et al. 2020) and the fwapg fork in the chinook article:
      `planning/archive/<this archive>/zotero_create_89.py` creates the three items (blocked 2026-10-27: the Zotero key
      could not be read from its credential store); then cite them in "What records were used?", rerun
      `data-raw/vignette_bib.R` (Zotero running) and check the fork item's title does not start "fwapg"
      (`vignette_bib.R`'s `key_for("^(smnorris/)?fwapg")`). Written into #89's body.
- Publish after the #91/#92 retune: rerender, drop the `_` prefix, replace
      `research/habitat_thresholds_tuned.md`'s Method with a link (the parked plan's Phase 5). Written into #92's body.

Closed by: PR (to follow) on branch `93-a-stepwise-methodology-article-the-pipel`
