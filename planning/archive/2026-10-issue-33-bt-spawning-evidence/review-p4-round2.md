# Review — Phase 4 write-up, round 2 (#33): the round-1 fixes

Scope: the rewritten passages in `research/bt_spawning.md` (short answer, transit section, width row, dead
ends), `planning/active/link-issue-draft.md` "What is known", the #33 body "Answer", and the other staged
hunks (research/README, CLAUDE.md, scripts/README, task_plan). Sources: `data/literature_evidence.csv`
(1-based data rows), `research/habitat_literature.md`, `data/bt_spawn_evidence.csv`, the 0293 log and
script, `findings.md`, `review-plan.md`, and the 2010 rule text (`scratchpad/lit/fr2010.txt`).

## Findings (6: 1 new meaning error in a fix, 3 residual sites of round-1 errors, 2 minor)

### R1 (new, in the F4 fix). "That bears on passage, not on where adults spawn."
- research, transit section, first bullet (Hagen et al. 2015 p. 9).
- The observation is higher **juvenile** densities above chutes and canyons. Row 495's note (and the source's
  own reading) is that spawners pass those reaches to reach natal reaches above them. So it does bear on
  where adults spawn: above difficult passage. What it does not say is the gradient of those spawning
  reaches, or that they are low-gradient patches.
- Round 1 F4's wording was "it says nothing about low-gradient spawning targets above them"; the fix
  narrowed that into a claim the source contradicts.
- Fix: "That bears on spawners passing steep water to spawn above it, not on the gradient where they spawn."

### R2 (residual F5). #33 Answer still drops "as small as"
- #33 Answer, Track 2 bullet 2: "Redds of large migratory BT are reported in 2 m wetted sections by one
  author group". Row 496: "found in stream sections **as small as** 2 m wetted width". The research file and
  the link draft were fixed; the issue was not. As written it reads as a typical size, not a smallest case.

### R3 (residual F1/F2, staged in this diff). research/README.md index row
- `bt_spawning.md | ... the literature's qualitative low-gradient statement ...`.
- The corrected research file now says the literature gives observed BC spawning gradients (0.6–4 %) and
  several qualitative statements. The index row still describes the literature as one qualitative statement,
  which is the round-1 F1/F2 claim.
- Fix: "observed BC spawning gradients and no limit in the literature".

### R4 (residual F3 and F1/F2/F7, outside the staged diff). The source-of-truth notes still carry them
- `literature_evidence.csv` data row 70 note: "the rule declines to set ranges because conditions depend on
  stream order and gradient (p. 63931)". Data row 507 note: "The rule declines to set ranges for its PCEs
  because 'stream flow and substrate ... gradient'". This is exactly the F3 mischaracterisation (the rule
  gives three reasons and still sets 2–15 °C for PCE 5). The research file cites rows 70–71 in the sentence
  right beside the corrected quote, so a reader following the citation reads the old claim.
- `findings.md` line 178 (same "declines to set ranges"), line 183 ("the only US gradient statement ... no
  number exists anywhere searched", F1/F2), line 184 ("Resident and small migratory spawners use smaller,
  steeper streams", F7). findings is append-only by convention, so a correction entry rather than an edit;
  but it moves into the archive as the record and currently contradicts the research file.

### R5 (minor). Dead ends: "sliver segments dominating"
- review-plan B3: "36 % of BT visits sit on segments under 50 m". 36 % is a large minority, not dominating.
  Say "a third of visits on sliver segments (< 50 m)".

### R6 (minor). Transit section cites the prototype null without B3's qualifier
- "A prototype in the plan review found no upstream separation between spawner and non-spawner visits." —
  supported by B3 ("A prototype showed no upstream separation"; groups are evidence vs null, the null being
  other BT visits in the class per the dead-ends entry). But B3 reports it while calling that test design
  invalid (censoring, slivers, network position differing). In the transit section, placed after "There is
  no baseline", it reads as a usable negative result. The dead-ends entry pairs it with the invalidity; the
  transit section should too ("under the design the review rejected").

## Checks asked for specifically

- **"0.6–4 %" vs rows 72–85, 188.** Faithful as a summary of **reach** studies with confirmed spawning:
  85 (0.6–1.0), 80/81/82 (1.3, 1.9, 4), 188 (1–4). Row 83 (2.4) is spawning-period residency, redds not
  confirmed, and lies inside the range anyway. **Row 84 (4.9) is not a spawning reach**: one radio-tagged
  fish resided below the falls in the spawning period, redds not confirmed — correctly excluded (round 1's
  suggested "0.6–4.9 %" would have been wrong). Rows 72 (< 1 %) and 74 (1.0–1.5 %) are site scale and
  correctly left out of a "reach studies" range. Matches `habitat_literature.md` lines 47–49.
- **Rows 73/78 Montana.** Yes: row 73 region "Flathead Lake tributaries, Montana" (Ford 1995 citing Fraley &
  Shepard 1989); row 78 "Flathead Basin, Montana" (Hagen & Weber 2019 citing Graham et al. 1981). The
  citing documents are BC reviews; the underlying sources are Montana. "Montana sources" holds.
- **2010 rule quote, verbatim and page.** Verbatim: "unable to define a conclusive upper and lower range of
  conditions for specific PCEs, given this complexity" (fr2010.txt lines 7544–7546). Page: the text sits
  after footer `Frm 00035` and the odd-page number `63931` (line 7533). Frames map as page = 63896 + frame
  (Frm 00004 = 63900), and pdftotext emits an odd page's right column after its page number, so lines
  7535–7607 are p. 63931's third column; 63932 starts at line 7608. **p. 63931 is correct.** The PCE 5
  "ranging from 2 to 15 °C" (lines 7621–7622) is on p. 63932; the research file gives no page for it.
- **"Prototype found no upstream separation".** Supported by review-plan B3 line 23 (see R6 for framing).

## Enumeration

| claim (where) | value | source | match |
|---|---|---|---|
| raw S by class (research, issue) | .146 .188 .182 .293 .302 .352 | csv `spawner_given_bt_coded_augoct` | yes |
| class range (research) | ≤ 2 to > 10.49 % | csv classes 0-2 … >10.49 | yes |
| RR with WSG term (research, draft, issue) | 0.75–1.22 | csv 0.745–1.215 | yes |
| intervals (research, draft) | roughly 0–3.6 | csv rr_lo 0–0.583, rr_hi 1.284–3.625 | yes |
| zero lower bounds from separating resamples (research) | — | csv: one class (4–5.49) rr_lo 0; 0293 header names separation for Inf | yes (one class) |
| RR without WSG at > 10.49 (research) | 3.07 | log no_wsg_term 3.073 | yes |
| coding & month do not remove rise (research, issue) | — | log coding_and_month_only 0.834→3.721 | yes |
| WSG term removes it (research, dead ends) | — | log wsg_term_only 0.763–1.283 | yes |
| large ≥ 350 mm, 3–9 per class (research) | 3–9 | csv large n_detect 8,9,6,5,3,3 | yes |
| < 2 m spawner visits / small (research) | 10 / 8 | log narrow TRUE 1+2+2+3+2; small 1+2+3+2 | yes |
| steep mature mostly small; many August (draft, issue) | 43 small vs 11 large; 30 of 43 Aug | log narrow/steep table | yes |
| BC reach studies 0.6–4 % (research, draft, issue) | 0.6–4 | rows 80–82, 85, 188 (84 not spawning) | yes |
| Cope & Morris 0.6–1.0 (research) | 0.6–1.0 | row 85 | yes |
| O'Brien 1.3, 1.9, 4 section averages (research) | 1.3, 1.9, 4 | rows 80, 81, 82 | yes |
| Bustard & Schell 1–4 (research) | 1–4 | row 188 | yes |
| "#19 rows" (issue) | — | habitat_literature.md 47–49 (#19) | yes |
| Montana low-gradient (research) | rows 73, 78 | rows 73, 78 regions | yes |
| no max or min (research, issue) | rows 70–71 | rows 70, 71 | yes |
| 2010 rule quote verbatim, p. 63931 (research) | — | fr2010.txt 7544–7546; page mapping above | yes |
| 2010 rule "2 to 15 °C" for one PCE (research) | — | fr2010.txt 7621–7622, PCE 5, p. 63932 | yes |
| Fraley & Shepard quote via 2010 rule (research, draft, issue) | verbatim | row 507, p. 63930 | yes |
| US statements qualitative (research, draft, issue) | — | rows 506, 507 (504 same claim) | yes |
| resident: smaller, higher-gradient; restating McPhail & Baxter (research, draft, issue) | — | row 506 (cites M&B 1996, Mullan 1992; note restates M&B p. 12) | yes |
| Hagen & Spendlow 2019 large-bodied, shorter steeper (research, issue) | — | row 500 | yes |
| Hagen 2015 p. 9 juvenile densities above chutes (research) | p. 9 | row 495 | yes |
| "bears on passage, not on where adults spawn" (research) | — | row 495 note: spawners pass to natal reaches above | **no (R1)** |
| 10 distinct large-spawner surveys > 5.49 % (research, issue) | 10 | log 11 visits, BBAR 76685 first_copy FALSE | yes |
| patch definition ≥ 200 m, ≤ 5.49 %, ≥ 2 m (research) | — | log header; 0293 `coalesce(channel_width,0) >= 2` | yes |
| 5 with same-blue-line patch, 780–5,394 m (research; issue 0.8–5.4 km) | 5 | log 989, 5394, 1993, 4298, 780 | yes |
| 4 with none upstream in WSG, 10.2–15.7 % (research, issue) | 4 | log KOTL .1106, UFRA .1566, COTR .1023, PARS .1097 | yes |
| no-width segments cannot be a patch (research) | — | 0293 coalesce(…, 0) | yes |
| prototype: no upstream separation (research ×2) | — | review-plan B3 | yes (framing R6) |
| B1/B3 cited for too few to test (research) | — | review-plan B1 power, B3 | yes |
| width row: Hagen 2020 p. 49 "as small as 2 m" (research) | p. 49 | row 496 | yes |
| same lead author as 2015 row; not independent (research) | — | rows 86, 496 keys and note | yes |
| small share of redds (research, draft, issue) | — | row 496 note | yes |
| Morice all > 7 m (research) | 7 m | row 189 | yes |
| "2 m wetted sections" (issue) | "as small as" | row 496 | **no (R2)** |
| dead end: searches mostly censored (research) | — | B3 | yes |
| dead end: sliver segments dominating (research) | 36 % | B3 | **no (R5, minor)** |
| dead end: coded share 0.27 vs 0.40–0.45 (research) | — | B2 27 % vs 40–45 % | yes |
| research/README index row: "qualitative low-gradient statement" | — | research file, rows 80–85, 188 | **no (R3)** |
| csv rows 70, 507 notes; findings 178/183/184 | — | as F1/F2/F3/F7 | **no (R4, residual)** |
| site selection most often groundwater/cold (issue) | — | #33 rows 490, 492–494, 501–505 | yes (among new rows) |
| link draft leaks | none | read | yes |
