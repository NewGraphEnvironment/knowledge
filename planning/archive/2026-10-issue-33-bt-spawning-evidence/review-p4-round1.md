# Review — Phase 4 write-up, round 1 (#33)

Scope: `research/bt_spawning.md`, `planning/active/link-issue-draft.md`, the #33 body "Answer" section,
and the README/CLAUDE.md lines in the staged diff. Sources: `data/bt_spawn_evidence.csv`,
`scripts/logs/habitat/20261002_bt_spawn_evidence.txt`, `data/literature_evidence.csv` (1-based data rows),
`findings.md` Phases 1–2, `review-plan.md`, and the PDFs of `hagen_etal2015Criticalhabitats`,
`hagen_etal2020CriticalSpawning`, `u_s_fishandwildlifeservice2010Endangeredthreatened` (pdftotext of the
group-library attachments, run in the scratchpad).

## Findings (9; 1 major, 7 meaning/overstatement, 1 minor number)

### F1 (major). "The literature gives no number for BT spawning gradient" is false
- research `## The short answer` bullet 3; link draft "The literature gives no number."; #33 Answer
  "No source gives a number for spawning gradient"; findings Phase 2 "no number exists anywhere searched".
- `literature_evidence.csv` already carries observed BT spawning gradients: row 72 (Ford et al. 1995 p. 124,
  "< 1%", Arrow Lakes), row 74 (Gill 2006 p. 6, 1.0–1.5 %), rows 80–84 (O'Brien 1999, 1.3, 1.9, 4, 2.4,
  4.9 %), row 85 (Cope & Morris 2001, 0.6–1.0 %), row 188 (Bustard & Schell 2002 p. 101, 1–4 %).
- What rows 70–71 actually support is narrower: no source gives a numeric **maximum or minimum** (a limit).
- #33's own body still says "Reach-scale BC spawning gradients of 0.6–4 % from three studies" (Problem) and
  "three BC reach studies" (If we never do), so the Answer contradicts the issue it sits in.
- The public link draft is the costly place: link#284 (public) records that "the literature vetoes" loosening
  BT spawning gradient to 0.1949, which rests on exactly these numbers.
- Fix: "No source gives a gradient limit. Observed spawning reaches run 0.6–4.9 % (BC reach studies), and
  site-scale descriptions give < 1 % and 1–1.5 %."

### F2. "The only US statement is qualitative" / "The only gradient statement is qualitative"
- research short answer: "The only US statement is qualitative: 'preferred spawning habitat ... low-gradient'".
  Row 506 (same 2010 rule, p. 63929) is a second US gradient statement ("higher gradients" for stream-resident
  populations), and the research file quotes its substance two lines later. Rows 73 and 78 are Flathead
  (US) statements via BC reviews.
- link draft: "The only gradient statement is qualitative" (no "US") is wider and false for the reasons in F1
  as well (rows 72, 74, 80–85, 188; also row 79 and 500 are further qualitative gradient statements).

### F3. "The rule declines to set ranges at all, because conditions depend on stream order and gradient"
- 2010 rule p. 63931 (row 507 note): "we are unable to define a conclusive upper and lower range of conditions
  for specific PCEs", giving lack of detailed data, time-of-year/precipitation/drought variability, and that
  "stream flow and substrate size and composition are influenced by stream order and gradient".
- The same rule's PCE 5 sets "Water temperatures ranging from 2 to 15 °C" (pdftotext line 7621). So
  "at all" is false, and the reason is one of three. True and sufficient: the rule sets no gradient range.
- The draft's and #33's "declines to set ranges" carry the same over-reach in milder form.

### F4. Transit: "Partly supported by what can be checked" overreaches
- Hagen et al. 2015 p. 9 (row 495) reports, citing Bustard & Schell 2002 and Decker & Hagen 2007, higher
  juvenile densities above chutes and canyons. It bears on passage of difficult reaches; it says nothing about
  low-gradient spawning targets above them.
- 5 of 10 with an upstream patch has no baseline: how often an arbitrary steep segment has ≥ 200 m at
  ≤ 5.49 % within ~5 km upstream on its blue line was not measured, and is likely common. 4 of 10 are against.
- `review-plan.md` B3 records that "a prototype showed no upstream separation". That is the only comparative
  transit result, and the research file's "Dead ends" entry for the transit test omits it.
- findings Phase 1 said "Transit fits some of these fish", which matches the evidence. Suggest: "Consistent
  for 5 of 10, against for 4, untested (a prototype comparison showed no upstream separation)."

### F5. "the literature agrees on 2 m for migratory spawners" (research table, width row, status)
- The two 2 m rows (86, 496) are one author group's experience; row 496's note says "not independent".
- The same Hagen et al. 2020 p. 49 sentence continues that redds in such streams "made up a small proportion
  of the total for the population".
- Row 189 (Bustard & Schell 2002 p. 101): all spawning sites in Gosnell/Thautil were in reaches > 7 m.
- "Agrees" reads as corroboration. Accurate: "one author group's expert view, twice; one BC study found all
  sites > 7 m".
- #33 Answer "Redds of large migratory BT are reported in 2 m wetted sections" drops "as small as" (the row's
  meaning is a smallest case, not a typical one).

### F6. The August-migrant hedge is dropped where it matters most
- research file: "That fits resident spawning ... But 'spawner' includes M-coded fish in August, which may be
  migrants." (hedged).
- link draft (public) and #33 Answer: "Mature fish on steep segments are mostly small, consistent with resident
  spawning", with no caveat. 112 of the 119 evidence visits are M-coded (Aug 63, Sep–Oct 49; SP/ST 7);
  of steep small visits, 27+3 = 30 of 43 are August (log, narrow/steep table). Carry the caveat.

### F7. "small migratory" misreads row 500
- #33 Answer: "Resident and small migratory spawners are described in smaller, steeper streams." Row 500 (Hagen
  & Spendlow 2019 p. 30) is "smaller populations of **large-bodied** spawners ... in shorter, steeper
  tributaries". "Small migratory spawners" reads as small-bodied fish, the opposite of the source.
- link draft: "Resident and small migratory populations use smaller, steeper streams" asserts use as fact and
  applies "smaller streams" to the migratory case; only the resident row (506) says smaller, row 500 says
  shorter. research file's "described in smaller, steeper streams" has the same "smaller" carry-over.

### F8. #33 Answer: "Groundwater and cold water dominate site selection."
- findings Phase 2 says they dominate the site-selection **statements** (a count of what the literature says).
- The sources say "often associated with" (row 503), "strongly related to water temperature ..., migration
  barriers, and geomorphology" (rows 501–502). "Dominate site selection" is a biological claim none makes.
- research file's table cell ("what drives site choice ... cold water, groundwater upwelling and alluvial
  reaches") is acceptable; it also names the 2010 rule, whose site-choice statements are not recorded as rows
  (row 505 note) — disclosed by "some of these statements are not recorded", so fine.

### F9 (minor number). "intervals of roughly 0.2–3.6"
- research and link draft. CSV `spawner_given_bt_coded_augoct` rr_lo is 0.583, 0.270, **0.000**, 0.318, 0.183,
  0.318; rr_hi 1.68–3.625. The 4–5.49 class interval is 0–1.28. findings Phase 1 discloses "some bootstrap
  lower bounds of 0"; both write-ups dropped it. Say "0–3.6" or keep the disclosure.

### Link draft leak check: clean
- Body carries no project/client identifiers, WSG codes, agency names, report authors, private paths, or
  private-repo issue numbers. "#284" is link's own. The two-line preamble ("link is PUBLIC ... Track 3") must
  be stripped before filing (not identifying, but internal jargon).

## Enumeration

| claim | value | source | match |
|---|---|---|---|
| research provenance: spawned #34 #35 #36 | issues exist | gh: #34 fraction, #35 loaded twice, #36 groundwater var | yes |
| literature rows 490–510 | 21 rows | csv rows 490–510; findings P2 "21 of 23" | yes |
| gate log path | exists, tracked | `20261002_literature_verify.csv`, 510 rows | yes |
| spawn_gradient_max / cw min | 0.0549 / 2 m | link#284 table | yes |
| raw S by class | .146 .188 .182 .293 .302 .352 | csv rows 7–12 | yes |
| RR with WSG term | 0.75–1.22 | csv 0.745–1.215 | yes |
| intervals | ~0.2–3.6 | csv rr_lo 0–0.583, rr_hi ≤ 3.625 | **no (F9)** |
| RR without WSG at >10.49 | 3.07 | log no_wsg_term 3.073 | yes |
| coding & month don't remove rise | 0.834→3.721 | log coding_and_month_only | yes |
| WSG term removes it | 0.763–1.283 | log wsg_term_only | yes |
| large spawners per class | 3–9 | csv large n_detect 8,9,6,5,3,3 | yes |
| large ≥ 350 mm | 350 | 0293 `large_mm <- 350` | yes |
| < 2 m spawner visits / small | 10 / 8 | log narrow table 1+2+2+3+2; small 8 | yes |
| steep mostly small | 43 small vs 11 large | log narrow/steep table | yes |
| "spawner" includes Aug M | yes | log kinds; findings P1 | yes |
| fits resident spawning (research) | hedged | findings P1 | yes |
| same in link draft / #33 | unhedged | — | **no (F6)** |
| literature gives no number for gradient | — | rows 72, 74, 80–85, 188 | **no (F1)** |
| only US statement qualitative | — | rows 506, 73, 78 | **no (F2)** |
| Fraley & Shepard quote via 2010 rule | verbatim | row 507 | yes |
| rule declines to set ranges at all | — | p. 63931; PCE 5 2–15 °C | **no (F3)** |
| resident & smaller migratory in smaller steeper streams | — | rows 506, 500 ("shorter") | partial (F7) |
| Hagen 2015 p. 9 juvenile densities above chutes | p. 9 | row 495; PDF line 749 | yes |
| 10 distinct large-spawner surveys > 5.49 % | 10 (11 visits) | log; BBAR first_copy FALSE | yes |
| 5 with patch on same blue line | 5 | log: 989, 5394, 1993, 4298, 780 | yes |
| distance range | 780–5,394 m (0.8–5.4 km) | log | yes |
| 4 with no patch upstream in WSG | 4 | log KOTL, UFRA, COTR 77518, PARS | yes |
| their gradients | 10.2–15.7 % | log .1023–.1566 | yes |
| transit "partly supported" | — | review-plan B3 prototype; no baseline | **no (F4)** |
| Hagen 2020 p. 49 2 m redds | p. 49 | row 496; PDF page marker 49 | yes |
| same lead author as 2015 2 m row | Hagen | rows 86, 496 | yes |
| literature agrees on 2 m | — | rows 86/496 not independent; 189 > 7 m | **no (F5)** |
| site choice: cold, groundwater, alluvial; sources | Metolius, H&S 2023, 2015 plan, 2010 rule | rows 490/493, 501–502, 503/505; 2010 not rowed (disclosed) | yes |
| #36 no groundwater variable | — | gh #36 title | yes |
| Hagen 2015 p. 23 no < 2 m surveyed; row 86 | p. 23 | row 86 | yes |
| row 79 p. 33 steep turbulent streams prevented viewing | p. 33 | row 79; PDF lines 2193–2196 (small 2–5 m, steep) | yes |
| Baxter & Hauer 2000 DOI | 10.1139/f00-056 | findings | yes |
| Baxter & McPhail 1999 DOI | 10.1139/z99-090 | findings | yes |
| Shepard 1984 BHL blocks | — | findings P2 | yes |
| Fraley & Shepard WSU JS | — | findings P2 | yes |
| Pearce 2019 no PDF | — | findings P2 | yes |
| #35 2.8 % of visits | 411/14463 = 2.84 % | log | yes |
| dead end: coded share 0.27 vs 0.40–0.45 | .267; .396–.452 | log coding table | yes |
| dead end: transit test cut | — | review-plan B3 (prototype result omitted) | partial (F4) |
| #33: 21 rows added | 21 | csv | yes |
| #33: raw 0.146 → 0.352 | — | csv | yes |
| #33: no source gives a number | — | as F1 | **no (F1)** |
| #33: small migratory spawners | — | row 500 large-bodied | **no (F7)** |
| #33: groundwater/cold water dominate site selection | — | rows 501–503 | **no (F8)** |
| #33: redds in 2 m wetted sections | "as small as" | row 496 | partial (F5) |
| #33: #34/#35 descriptions | — | gh titles | yes |
| link draft: "#284 scored rearing" | BT rear 0.1349 scored | link#284 status | yes |
| link draft: leaks | none in body | grep + read | yes |
| scripts/README 0293 line, CLAUDE.md, research/README rows | paths/outputs | staged diff | yes |
