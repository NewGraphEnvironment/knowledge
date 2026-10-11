# Findings — Get the Bear et al. 2005 and 2007 WCT thermal-requirement PDFs and read them into the evidence table (#40)

## Issue context

**If we do it:** the WCT thermal cells are read from the WCT study itself. That may also give the first WCT degree-day values (to hatch, and growing season), which today exist only as a transfer from Colorado cutthroat. **If we never do:** the WCT upper limits stay secondary citations (19.6 °C UILT via Cleator et al. 2009; "survival declines sharply above 19 °C" via Thorley et al. 2021), and the WCT degree-day `none` rows stay qualified as "Bear et al. not read".

## Problem

Both items are in the group library and in `Fisheries/temperature`, with no PDF:

- `bear_etal2007ComparativeThermal`: Bear, McMahon & Zale 2007, TAFS 136:1113–1121, doi:10.1577/T06-072.1. Closed access (Unpaywall and Semantic Scholar both report no open copy).
- `bear_etal2005ThermalRequirements`: the 2005 final report to the Wild Fish Habitat Initiative (Montana State University). Only copy found is ResearchGate (https://www.researchgate.net/publication/239856422_Thermal_Requirements_of_Westslope_Cutthroat_Trout), which blocks scripted download.

#38 left these WCT cells resting on secondary citations or `none`:

- rearing upper limit: rows 521–522 (Cleator, Thorley);
- incubation degree-days to hatch: row 531;
- growing-season degree-days for rearing and overwintering: rows 532–533.

`research/thermal_requirements.md` names Bear 2005 as the likeliest unread source of WCT degree-days.

## Proposed solution

1. Get both PDFs by hand: ResearchGate for 2005, and institutional access or interlibrary loan for 2007. Put them in `data/rag/pdf/`.
2. Add a `pdf` path to their rows in `data/temperature_members.csv`, then run `0270 --collection temperature` and rebuild and push the `temperature` store.
3. Draft rows from both under the #38 brief (`planning/archive/2026-10-issue-38-thermal-requirements/drafter-brief.md`): UILT, CTmax, growth optimum, and any degree-days. Then:
   - replace the WCT `none` rows a value fills;
   - add the primary rows beside the Cleator and Thorley secondaries;
   - run a meaning audit and the `0280` gate.
4. Revise `research/thermal_requirements.md` (the WCT lines, the "Left out" bullet, the consumer guidance).

Relates to #38

## Sources located (2026-10-11)

- Bear et al. 2007 (TAFS 136:1113–1121): author-hosted on McMahon's MSU lab site,
  https://naturefilm.montana.edu/mcmahon/documents/cttxrbt%20temp%20TAFS.pdf — 200, application/pdf,
  260,911 bytes; pdftotext confirms the DOI 10.1577/T06-072.1 front page.
- Bear et al. 2005 (WFHI final report, January 2005, 31 pp.): ResearchGate copy downloaded by hand to
  `data/rag/pdf/Thermal_Requirements_of_Westslope_Cutthroat_Trout.pdf`.
- Bear's 2005 MSU MS thesis (ScholarWorks handle 1/885) covers the same experiments. Not used: the
  report reached the library. ScholarWorks accepted TLS and then hung on every scripted GET.
- First read: 2005 gives WCT UUILT 19.7 °C (95% CI 19.1–20.3) and RB 24.2; 2007 gives 19.6 (19.1–19.9) and
  24.3. Optimum growth is 13.6 (WCT) and 13.1 (RB) in both. Neither has degree-days.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## The upload answered `exists`

`0270`'s live run printed `pdf exists`, not `pdf uploaded`, for both Bear items. The Web API answers `exists`
when it already holds a file with that md5, and still links the new attachment item. The dry re-run that
followed read both as `pdf present`, and Zotero synced both files into local storage (`QNK6GJDJ`,
`H7XFPUPT`), so both landed.

## The 2005 report and the 2007 paper share their fitted curves

The report's growth curves and 60-d survival curves use the third WCT and the second RB experiment (p. 9); its
LD50 regressions pool all three WCT and both RB experiments (Figs. 6 and 8, pp. 28 and 30). The paper's survival
and growth curves carry the report's coefficients exactly (WCT growth `-4.1727 + 0.9496 T - 0.0348 T²`, WCT
survival midpoint 19.6253; 2007 Figs. 1 and 4, report Figs. 1, 2 and 5; the 2007 OCR misreads the RB survival
coefficients as 24.3622 and -0.6033, where the printed figure reads 24.3522 and -0.5033). So the survival-curve
UUILTs (19.6, 24.3 °C) and the growth optima are one estimate published twice. The LD50-regression UUILTs (19.7,
24.2 °C), which the report's abstract headlines, appear only in the report. The 7-d UUILTs differ in method and in
data: the paper takes the day-7 point of its LT50-over-time plot (Fig. 2, p. 1116); the report predicts 7 d from
its pooled LD50 regression, with LD50 set to 120 d where survival never fell below 50% (p. 10), so its RB 31.1 °C is
an extrapolation above the 28 °C top test temperature. Only some survival percentages are pooled in the paper (RB
at 24 °C: 72.8%, between the report's two experiments). The report's abstract gives the RB UUILT a 95% CI of
20.3–24.2 °C, while its p. 12 gives 22.9–25.4 °C.

## Measured growth optima are `lab`; stated or reviewed optima are `pref`

`pkg/R/literature.R` defines `lab` as "a lethal limit, CTmax, survival or growth at held temperatures, or a
development time in degree-days". Round 1 coded the Bear optima `pref`, after the research file's gloss "`pref` (a
preference or optimum)" and Selong's BT growth peak (data row 154). Round 2 recoded them `lab` and narrowed the
`pref` gloss to "a temperature fish select". Code-check round 1 and meaning round 3 then showed that the narrower
gloss contradicts the table: #38 coded its stated or reviewed optima `pref` (data rows 140, 150, 152, 600, 619, 625,
645, 647; 647 is Lusardi's review of laboratory coho growth), and its `lab` optima (data rows 589, 591, 614) are
survival optima, not growth optima. Settled: an optimum the source itself measured at held temperatures (Bear,
Selong) is `lab`; an optimum a source states or reviews is `pref`. The research gloss says so, and #38's rows stand.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| 2007 WCT niche: OCR quote `10.6—-14.6°C; rainbow trout: 10.1` was `quote_not_found` | It stopped inside the range `10.1-14.1`; the gate refuses that. Extending the quote past the range verifies (round 2) |
| Round-1 suggestion of a text-layer quote `10.6–14.6`: `a text quote needs at least 20 characters` | Text layer prints `14.68C`, one token, so no text quote can hold 14.6; the OCR quote is the route |
| Dropping the niche row was first written up as "fails the gate" | Wrong reason; the row is in (appended last, data row 1102) |

## Audit closed by enumeration

Every same-source, same-page group of Bear rows with mixed `kind` or `metric` (after round 2):
- 2005 p. 17 (data rows 1096–1101): one sentence of field association (Sloat 2001; `dist`), with "average
  daily" (`unstated`: the page does not say each day's mean or a period mean) and "maximum daily" (`daily_max`)
  per clause; then one sentence of recommendation (`expert`), "maximum average daily" (`daily_mean`) and "maximum daily" (`daily_max`). Each
  difference is its own clause's wording.
- 2007 p. 1119 (data rows 1079, 1081, 1102): the fundamental niche (derived from a held-temperature growth optimum;
  `lab`, `constant`) and the Discussion criterion citing field studies (`expert`, `unstated`): separate sentences.
Every other page group (2005 pp. 11, 12, 14, 15, 16; 2007 pp. 1113, 1115, 1117, 1118) is uniform.
