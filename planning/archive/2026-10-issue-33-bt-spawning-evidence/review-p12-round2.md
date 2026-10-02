# Review: #33 Phase 1 fixes and Phase 2 evidence rows, round 2

What was reviewed: A) the round-1 fixes to `scripts/0293`, its CSV and log, and findings.md Phase 1; B) the 21 new
`literature_evidence.csv` rows (data rows 490-510) and the edited notes on rows 70-71.

Probes were read-only: an R script in the scratchpad reading `bt_use_visits.csv` and `fdis_sites.csv`, plus
pdftotext/OCR page text for every cited page. No repo file was touched except this one.

## A. Phase 1 fixes

### Code: verified correct
- **`nuisance <<-` override in `add_sens`.** `form()` is defined at top level, so it reads the global
  `nuisance`. `add_sens` saves it and restores it afterwards. There is no `tryCatch` in `add_sens`, so an error
  stops the script and an unrestored value can never leak into a later step. `boot()` exported `nuisance`
  inside `curve()`, before any `add_sens` call, so the workers always got the default.
  - `nuis = character(0)` gives `keep = character(0)` and the formula `S ~ cls + log_coded + month_f + log_area`.
  - `wsg_term_only` gives `S ~ cls + log_area + wsg`.
  - The `base` column reproduces the CSV's S ratios exactly.
- **`first_copy`.**
  - Every one of the 14,463 visits is in `fdis_sites` (0 missing), so no visit is flagged as a copy just
    because it has no signature row.
  - `site_visit` is unique in `fdis_sites`. No duplicate group has an NA UTM.
  - The probe reproduces 411 second copies: 776 visits in 365 groups.
  - With `with_ties = FALSE`, the result is deterministic in the 2 groups whose lowest collection id is tied.
  - The BBAR pair is flagged correctly (`76685_76_1` FALSE).
- **`site_gradient_class`.** `gradient_pct` in the visit table is a percent (median 4, max 50), so `/100` is right.
- **New log blocks.** The narrow/steep table sums to 119 (11+12+19+20+5+4+27+11+1+2+2+3+2). The agency block and
  the raw-S-in-modelled block are consistent with the CSV and with each other.
- **U as uncoded.** Fish by kind still sums to 7,979, as in round 1, and visits by kind still sum to 1,363.
  `U` is not in `coded`, so `n_coded` is unchanged.

### Findings

**F1 (real, overclaim/wrong). "The four with almost no channel upstream" (findings l.42) is false for KOTL and UFRA.**
Round 1's own probe, the source l.39 cites, measured upstream channel of PARS 351 m, COTR 1,747 m, UFRA 8,359 m
and **KOTL 86 km**. KOTL has 819 m at <= 5.49 % upstream, 282 m of it with NULL width, and none of it in a
qualifying 200 m run.
- l.39 quotes only the two short ones, so "the channel upstream is short" reads as true of all four.
- l.42 then builds the inference "fish at or near where they spawn, not in transit" on it.
- For KOTL the patch count is 0 because of the gradient and width rules, not because there is no channel. The
  NULL widths excluded by `coalesce(channel_width, 0) >= 2` are exactly the "width rule misses real patches"
  caveat. That caveat is the likely explanation for KOTL, not a remote one.

Supportable wording:
- "two (PARS, COTR) have under 2 km of channel upstream";
- "UFRA (8.4 km) and KOTL (86 km) have channel upstream but no qualifying patch; at KOTL, 282 of its 819 m at
  <= 5.49 % have no width".

**F2 (traceability, AC1). PARS 351 m and COTR 1,747 m (findings l.39) are not in the log.** They come from
review-p1-round1.md. This is the same class as round 1's F6 (the agency "38"), which was fixed by adding a log
block. Either log the upstream channel length per no-patch visit, or attribute the figures to the review.

**F3 (internal contradiction, minor). l.21 lists "more coding, a different season" as open explanations that
l.18-20 just measured.**
- l.20 says coding effort and month do not remove the rise (`coding_and_month_only` 0.83 -> 3.72).
- l.21 then says it is open whether steep WSGs "were sampled differently (more coding, a different season or
  different crews)".
- At the visit level, coding effort (`log n coded`) and month are already adjusted for. What stays open is crews
  or agency, the coding *practice* (which fish get coded, as opposed to how many), and real between-WSG
  differences in spawning.

**F4 (minor, numbers and claim). The header and findings overstate what the repeated-survey flag is.**
- Header l.38: "about 2.5 % of visits". The measured rate is 411 / 14,463 = **2.84 %**.
- "One survey loaded under two collection ids" (header) and "a second copy of a survey loaded twice"
  (findings l.6):
  - **46 of the 365 groups are triples**;
  - 2 groups share a collection id. `91719_1_1` / `91719_2_1` are sites 1 and 2 of one collection, with a
    100 m-rounded UTM, 800 m2 and 0 fish, which is plausibly two sites rather than one survey loaded twice;
  - **363 of the 776 grouped visits caught nothing**, so their signature is only UTM + date + area.
- The 411 is therefore a heuristic count, and its zero-catch part is the least certain.
- This does not touch the S population or the `first_copy_only_35` sensitivity, because every `pop` visit has
  coded BT.
- Say "about 2.8 %, by a UTM/date/area/catch signature; includes triples and zero-catch matches".

**F5 (minor, spec honesty). The header is titled "fixed before the first fit", but now carries post-review
additions without saying so.**
- REPEATED SURVEYS and POWER labels were added after round 1, and the four new sensitivities
  (no_wsg_term, wsg_term_only, coding_and_month_only, first_copy_only_35) run without being listed in the spec at
  all. The ALSO bullet names only agency and measured site gradient.
- Mark those lines "added after code-check round 1", so the spec does not claim to be pre-registered for
  analyses chosen after the results were seen.

**F6 (minor, CSV value). `spawner_given_bt_coded_sepoct, 5.49-8` has `rr_hi = Inf`.** This was there before
round 1 and was not flagged then.
- A bootstrap ratio goes infinite on separation. `quantile(..., na.rm = TRUE)` keeps `Inf`, and the value is
  written as the literal `Inf`.
- The cell is labelled underpowered and findings does not cite it, but a consumer reading the CSV numerically
  gets an infinite upper bound. Either cap and say so, or treat non-finite values as NA in `boot()`, where
  non-converged fits already become NA.

### Number enumeration: findings.md Phase 1 against the log and CSV

| # | Claim (findings line) | Source | Verdict |
|---|---|---|---|
| 1 | md5 b32e5262…e04d (l.3) | log l.1 | match |
| 2 | 411 of 14,463 second copies (l.6) | log l.2 | match (but see F4 on what it counts) |
| 3 | Kinds: M Aug 63, M Sep-Oct 49, M other 25, SP/ST 7, adult size only 79 (l.7) | log l.15-19 | match |
| 4 | 119 visits, assert passed (l.8) | log l.21 | match |
| 5 | Coded share 0.27 vs 0.40-0.45 (l.9) | log 0.267; 0.396-0.452 | match |
| 6 | S population 560; 485 modelled in 23 WSGs (l.9) | log l.22, l.33 | match |
| 7 | Raw S 0.146/0.188/0.182/0.293/0.302/0.352 (l.12) | CSV | match |
| 8 | Modelled raw 0.174 -> 0.422 on 485 (l.12) | log l.127-132 (149+116+75+62+38+45 = 485) | match |
| 9 | Adjusted 1.10/1.04/0.75/1.22/0.94/1.14 (l.14) | CSV | match |
| 10 | Intervals roughly 0.2-3.6, some lower bounds 0 (l.15) | CSV lo 0-0.583, hi 1.284-3.625 | match |
| 11 | Without WSG term 0.87 -> 3.07 (l.17) | log no_wsg_term 0.872 … 3.073 | match |
| 12 | Coding and month only 0.83 -> 3.72 (l.18) | log 0.834 … 3.721 | match |
| 13 | WSG term alone 0.76-1.28 (l.19) | log 1.120/0.999/0.763/1.178/1.031/1.283 | match |
| 14 | Sensitivities range 0.34-1.90 (l.22) | log: min 0.338 (August only), max 1.899 (site gradient) over the five listed | match |
| 15 | Timberland 20, Kokanee 18 of 119 (l.22) | log l.136-137; 119 = sum of S detections | match |
| 16 | Repeated surveys removed 0.84-1.22 (l.22) | log first_copy_only_35 0.841-1.215 | match |
| 17 | Large spawners 8/9/6/5/3/3, all underpowered (l.25) | CSV | match |
| 18 | Small 18/19/11/17/11/17; raw 0.10 -> 0.32; adjusted 0.80-1.43 (l.26) | CSV | match |
| 19 | Sep-Oct underpowered from 4-5.49 up (l.27) | CSV | match |
| 20 | U 0.90/1.17/1.04/0.80/0.75/0.59 (l.29) | CSV | match |
| 21 | < 2 m: 7 of 41 field, 3 of 17 modelled (l.32) | log l.144, l.149 | match |
| 22 | Highest 5-10 m, 0.35 both (l.32) | log 0.349 / 0.348 | match |
| 23 | 10 spawner visits < 2 m, 8 small (l.33) | log narrow block: 1+2+2+3+2 = 10; small 1+2+3+2 = 8 | match |
| 24 | 7 also steep: 2 large Sep-Oct, 3 small Aug, 2 small Sep-Oct (l.33) | log l.167-169 | match |
| 25 | 11 visits, 10 distinct (l.37) | log l.171; first_copy FALSE x1 | match |
| 26 | KOTL 11.1, UFRA 15.7, COTR 10.2, PARS 11.0 % (l.39) | log 0.1106/0.1566/0.1023/0.1097 | match |
| 27 | PARS 351 m, COTR 1,747 m (l.39) | not in log; review-p1-round1.md | **untraceable (F2)** |
| 28 | 5 distinct with same-blue-line patch, 780-5,394 m (l.40) | log: 989, 5394, 1993, 4298, 1993 (BBAR x2), 780 | match |
| 29 | CLRH patches, none on own blue line (l.41) | log l.189 (2, NA) | match |
| 30 | "almost no channel upstream" for all four (l.42) | round 1: KOTL 86 km, UFRA 8.4 km | **wrong (F1)** |
| 31 | FISS 4 rows UPCE, MURR, LNTH x2 (l.44) | log l.201-204 | match |
| 32 | "Mature BT, mostly small, on steep segments" (l.46) | log steep: small 43, large 11 | match |

## B. Literature rows (21 new, data rows 490-510; edits to rows 70-71)

Every page was read: the Metolius OCR cache; pdftotext of each library key; FR 2010 (PDF page n = FR page
63897 + n); the USFWS 2015 plan (PDF 20 = p. 5).

### Findings

**B1 (real, meaning). Row 508 note misattributes McPhail and Baxter 1996's 9 C source.** The note says
"mcphail_baxter1996 and hagen_weber2019 cite Fraley and Shepard 1989 (with McPhail and Murray 1979) for 9 C".
- McPhail and Baxter 1996 (PDF p. 15, section 3.1.2) say: "McPhail and Murray (1979) and Weaver and White (1985)
  suggest that about 9°C is the threshold temperature". The table's own row 149 note says the same.
- They do not cite Fraley and Shepard for 9 C. Only hagen_weber2019 p. 22 cites Fraley and Shepard 1989 (with
  McPhail and Murray 1979) for 9 C.

Fix: "hagen_weber2019 (p. 22) cites Fraley and Shepard 1989 and McPhail and Murray 1979 for 9 C; mcphail_baxter1996
cites McPhail and Murray 1979 and Weaver and White 1985; this rule cites Fraley and Shepard for 10 C." The same
error is in draft-spawn-notes.md, under "Contradictions", first bullet.

**B2 (real, meaning). Row 505 note claims that two sources identify the Swan River work as Baxter and Hauer 2000.
Neither page says so.** The note reads "the Swan River work is cited elsewhere as Baxter and Hauer 2000
(hagen_sary2023 p. 4; the 2010 rule p. 63930, hyporheic flow)".
- hagen_sary2023 p. 4 cites Baxter and Hauer 2000, among four sources, for alluvial sections and groundwater
  exchange.
- The 2010 rule p. 63930 cites it for hyporheic flow across spatial scales.
- Neither mentions the Swan River or redd abundance against bounded alluvial valleys.

Fix: "Baxter and Hauer 2000 is cited for related claims (alluvial sections, hagen_sary2023 p. 4; hyporheic flow,
2010 rule p. 63930), but neither names the Swan River; attribution not checked against either paper."

**B3 (minor, page convention). Row 490 cites PDF page 5, but the same quote is on printed p. 20.** The gate
matched PDF 5 and PDF 24, and PDF 24 carries the printed footer "20".
- The column convention is the printed page, and the note concedes p. 5 has no printed number. Use `20`.
- On p. 20 the sentence is about the adfluvial majority ("These bull trout"). On p. 5 it is "Most bull trout". If
  the page moves to 20, the note's "adfluvial and fluvial spawners together" no longer describes the cited page.
  Keep p. 5 and note p. 20, or change the note.

**B4 (minor, inference in a note). Row 500 note says "Large-bodied (adfluvial) spawners".** p. 30 says
"large-bodied spawners" in tributaries "close to the reservoir", within a passage on "large-bodied, migratory"
populations. Adfluvial is an inference from proximity to the reservoir, and the row's own `life_history_form` is
`migratory`. Drop "(adfluvial)", or say it is inferred.

**B5 (minor, region). Rows 501 and 502 give the region as "Williston Reservoir watershed, BC" for a general
statement whose cited evidence is mostly elsewhere.**
- Graham et al. 1981 (Flathead), Baxter and Hauer 2000 (Swan River, Montana), Baxter 1997 and Williamson 2006.
- The sentence describes redd distribution in general, not a Williston finding. "BC and Montana (review)" or
  "(review)" would avoid reading it as local evidence.

### Row enumeration

| Row | Key, page | Columns checked | Quote on page | Note claims | Verdict |
|---|---|---|---|---|---|
| 70 | none (gradient max) | appended: USFWS 2015 and 2010 give no number; rule declines PCE ranges because flow and substrate depend on stream order and gradient, p. 63931 | n/a | p. 63931 (PDF 34): "attributes such as stream flow and substrate size and composition are influenced by stream order and gradient. Accordingly, we are unable to define a conclusive upper and lower range"; no gradient number in either document (searched all "gradient"/"slope") | OK |
| 71 | none (gradient min) | same text | n/a | same | OK |
| 490 | Metolius, 5 | BT, spawning, migratory, channel_width, spawn_channel_width_min, qual, reach | PDF 5 and PDF 24 (p. 20) | tributaries list: p. 14 (PDF 18); Heising Spring and Jack Creek mouth: p. 28 (PDF 32) | **B3** (page); parameter follows the row 88 precedent ("small streams") |
| 491 | Metolius, 36 | substrate range 8-32 mm, dist, site, Riehle 1993 | PDF 40 = p. 36 | fines 22-33 % in four creeks: correct | OK |
| 492 | Metolius, 36 | temperature max 9 degC, dist | PDF 40 (and exec summary PDF 6) | "repeated on p. 37": PDF 41 = p. 37, "Riehle (1993) found … fell below 9°C"; mcphail p. i 9 C = row 149 | OK |
| 493 | Metolius, 36 | temperature qual, reach, Riehle 1993 | PDF 40 | Roaring and Candle 4-6 C: correct; p. 6 (PDF 10) Crooked River has no perennial cold springs, no spawning documented: correct (the text says the upper basin) | OK |
| 494 | hagen_etal2015, 22 | elevation qual, network | PDF 30 = p. 22, fn. 11 | Pack River rated low potential, "predominately low elevation", left out of aerial surveys: correct | OK |
| 495 | hagen_etal2015, 9 | migration, migratory, gradient qual, reach, Bustard and Schell 2002; Decker and Hagen 2007 | PDF 17 = p. 9 | competitive advantage: correct (the source says "other salmonids"; downstream areas are rainbow and steelhead) | OK |
| 496 | hagen_etal2020, 49 | spawn_channel_width_min min 2 m wetted, expert, reach | PDF 50 = p. 49 | small share of redds (Thutade, Hagen 2000): correct; row 87 is hagen_etal2015 p. 23: correct | OK |
| 497 | hagen_weber2019, 22 | velocity range 0.14-0.52 m/s, dist, site, Baxter and McPhail 1996 | PDF 24 = p. 22 | matches row 77 (roberge p. 80, 0.14-0.52, same review): correct | OK |
| 498 | hagen_weber2019, 22 | velocity max 0.65 m/s, dist, site | same | "typically", not absolute: correct | OK |
| 499 | hagen_weber2019, 90 | substrate qual, migratory, reach, Hagen and Spendlow 2018, 2019 | PDF 92 = p. 90 | Carruthers, upper Osilinka, Lay: correct; restated in spendlow p. 30 ("unembedded cobble substrate"): correct | OK |
| 500 | hagenj_spendlowi_2019, 30 | migratory, gradient, spawn_gradient_max qual, reach | PDF 37 = p. 30 | Big Creek "relatively steep, high energy", 26 redds on foot, p. 18 (PDF 25): correct; larger populations in pristine upper reaches, same page: correct | **B4** |
| 501 | hagen_sary2023, 4 | elevation qual, network | PDF 10 = p. 4 | elevation as a temperature proxy, no value: correct | **B5** (region) |
| 502 | hagen_sary2023, 4 | valley_width_index qual, reach | same | reading "alluvial" as unconfined is labelled an inference | **B5** (region) |
| 503 | USFWS 2015, 5 | temperature qual, reach, five cited sources | PDF 20 = p. 5 | p. 6 redds near springs and groundwater: correct | OK |
| 504 | USFWS 2015, 6 | temperature range 5-9 degC, pref, Goetz 1989 | PDF 21 = p. 6 | late summer to early fall: correct; 4-10 C Howell 2010, same page: correct; 2010 rule gives Goetz 4-10: correct; low-gradient clause is the 2010 sentence: correct | OK |
| 505 | USFWS 2015, 6 | valley_width_index qual, network, Swan River, Baxter and McPhail 1999 | PDF 21 | Swan River claim about the other two sources | **B2** |
| 506 | FR 2010, 63929 | resident, gradient, spawn_gradient_max qual, reach, McPhail and Baxter 1996; Mullan et al. 1992 | PDF 32 = 63929 | residents in spawning and rearing areas year round, same page: correct; restates mcphail p. 12 (row 100): correct | OK |
| 507 | FR 2010, 63930 | gradient spawn_gradient_max qual, reach, Fraley and Shepard 1989 | PDF 33 = 63930 | 2015 plan p. 6 repeats it: correct; p. 63931 quote: correct | OK |
| 508 | FR 2010, 63930 | temperature max 10 degC, dist, Flathead, Fraley and Shepard 1989 | PDF 33 | McPhail and Baxter 1996 attribution | **B1** |
| 509 | FR 2010, 63930 | temperature range 4-10 degC, dist, Goetz 1989 | PDF 33 | "could be wider (Howell et al. 2010, p. 102)": correct; 2015 plan p. 6 attributions: correct | OK |
| 510 | FR 2010, 63930 | incubation range 1.2-5.4 degC, dist, Fraley and Shepard 1989; McPhail and Baxter 1996 | PDF 33 | optimum 2-4 C as in row 150: correct | OK |

## Verdict
- **A.** The code fixes are correct.
- **A, findings.md.** Two real text defects: F1, where "almost no channel upstream" is false for KOTL (86 km)
  and UFRA (8.4 km), and F3, where coding and month are listed as open explanations right after they were shown
  not to remove the rise. F2 is a traceability gap of the same kind as round 1's F6. F4-F6 are minor.
- **B.** Two meaning errors in notes: B1 (McPhail and Baxter 1996's 9 C source) and B2 (the Swan River
  attribution). Three minor: B3, B4, B5. All values, units, bounds, kinds, cited sources and pages otherwise
  check out against the pages.
