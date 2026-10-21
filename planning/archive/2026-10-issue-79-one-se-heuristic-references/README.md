# One-SE region: state it as a heuristic, publish 1.96 beside it, and give the article references (#79)

## Outcome

The tuning's "within one standard error of the best" is now stated everywhere as a parsimony rule of thumb fixed
before the run, with its sources (Breiman et al. 1984; Hastie et al. 2009; Chen & Yang 2021; Bengio & Grandvalet 2004;
Bates et al. 2024), and the same pick at 1.96 SE is published beside it. `knw_tune_repick()` replays the pick from a
saved tune table at any width; `data/thresholds.csv` gains `rule_196` and `holds_196`; `research/habitat_thresholds_tuned.md`
has an "At 1.96 SE" section and link#346's body says which rules hold. The chinook article was rewritten shorter and
plainer, with the 1.96 table computed inline, a bibliography written from Zotero by `data-raw/vignette_bib.R` with the
run's software versions, and an interactive Bulkley map (`knw_compare_mapgl()`) on the website only. The sources,
software and an FDIS dataset item were filed in the group library, and the fwapg, bcfishpass and bcfishobs duplicates
merged into the keys report repos cite. The README credits fwapg, bcfishobs and bcfishpass to Simon Norris.

What was learned: at 1.96 SE five of eight species × stages keep `default`, but for four of them the 1.96 region holds
most or all of the grid, so the stricter bar cannot separate rules rather than supporting `default`; chinook keeps
only its 0.75 m³/s flow floor (back to 5.49 % and no near-a-river allowance). Tooling facts that cost a retry are in
`findings.md`, "Errors Encountered": mapgl 0.4.6's popup evaluator, a Carto style's own `water` layer id, citeproc's
"Versions" plural, and Better BibTeX's local `file` paths.

## Measurement

- 1.96 replay against the saved tables (`knw_tune_repick()`, `data/tune/*_tune.csv`): at 1 SE it returns the recommended
  rule for all 8 tables; at 1.96 it reproduces the issue's column exactly. `default` behind the best, in SEs: BT rear
  1.58, BT spawn 1.06, CH 2.40, CO 2.47, GR 0.89, RB 2.36, ST 1.42, WCT 1.33. Rules within 1 → 1.96 SE: BT spawn 18 →
  3,010 of 3,010; GR 799 → 3,493; ST 330 → 3,307; WCT 677 → 3,010; BT rear 196 → 1,066; CH 23 → 1,098; CO 87 → 1,023;
  RB 81 → 323. Nearest rule to either boundary: 0.0015 deviance, so the csv's 6-decimal rounding cannot flip a pick.
- Article words (prose outside YAML and chunks, inline `r` as one word): 2,434 before, 1,303 after, against a 1,400
  target; 11 sections before, 7 plus References after. The floor was the 1.96 table's framing and the surface table's
  reading, which the outline keeps.
- Interactive map, Bulkley: segment GeoJSON 8.3 MB with a prebuilt HTML popup per segment, 5.3 MB with popups built in
  the browser from short fields and classes as integer codes; the built article page 5.5 MB (742 KB gzipped) plus
  11 MB of shared widget libraries.
- Wetland lines (edge 1050/1150), province-wide: default 10,286.8 km, recommended 10,197.0 km, both 10,075.1 km, median
  grade 0.0307. In the Bulkley 259 of 270.5 km pass link's wetland condition and the connectivity step keeps 178.8,
  so the article says a wetland line must still connect to spawning (code-check round 3).
- Code-check over the branch: three rounds, ten findings, all fixed; closed on an enumeration (`findings.md`,
  "Code-check"). Round 2 found round 1's review file re-quoting what round 1 removed; the unpushed branch's history was
  rewritten so no commit carries it.

## Evidence

`planning/archive/2026-10-issue-79-one-se-heuristic-references/review-*.md` (the plan review and three code-check rounds).

Closed by: PR (opened from branch `79-one-se-region-state-it-as-a-heuristic-pu`)
