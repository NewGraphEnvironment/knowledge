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

## The 2005 report and the 2007 paper are one programme

The report (January 2005) analyses only the third WCT experiment and the second RB experiment (p. 9). The
paper pools three WCT and two RB experiments (p. 1115). The 60-d values agree within 0.1 °C (WCT 19.7 vs 19.6;
RB 24.2 vs 24.3), but the 7-d UUILTs differ (WCT 24.7 vs 24.1, RB 31.1 vs 26.0). Both are kept, and each
note names the other, so an aggregation does not count them as two studies. The report's abstract gives the RB
UUILT a 95% CI of 20.3–24.2 °C, and its p. 12 gives 22.9–25.4 °C.

## Growth optima are `pref`

`research/thermal_requirements.md` defines `pref` as "a preference or optimum", and Selong et al.'s BT growth
peak (data row 154) is `pref`. The round-1 reader argued for `lab`, from CLAUDE.md's description of `lab`
("a laboratory or hatchery measurement"). The research file is the reader-facing convention, so the Bear
optima, optimal ranges and niches are `pref`. The zero-growth edges are `range` with kind `lab`, because they
are limits.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| 2007 WCT niche `10.6–14.6`: OCR `10.6—-14.6°C` fails the gate | Left out; 2005 p. 14 carries it |
| Round-1 claim that the text layer verifies it: `a text quote needs at least 20 characters` | p. 1119 opens on the value and `14.68C` ends it, so nothing longer is quotable; claim disproved |
