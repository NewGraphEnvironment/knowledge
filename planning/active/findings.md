# Findings — Growing-season degree-day thresholds for BC salmonids: search beyond the temperature collection (#47)

## Issue context

**If we do it:** GSDD consumers (NewGraphEnvironment/wet#40, NewGraphEnvironment/link#21, NewGraphEnvironment/fish_passage_template_reporting#214) get a threshold from a species or region closer to BC than Colorado cutthroat, or a documented absence wider than our own collection. **If we never do:** every GSDD cutoff we apply is a transfer from Coleman & Fausch 2007 (800 / 900 / 900–1,200), and the `none` rows say only that our 44 items lack one.

## Problem

#38 and #40 searched only `Fisheries/temperature`. The growing-season cells (`degree_days` × `rearing`/`overwintering`, metric `growing_season`) are `none` for WCT, BT, CH, CO and ST. The only values in the table are CRCT (Coleman & Fausch 2007a p. 1231; Coleman & Fausch 2007 p. 652; `research/thermal_requirements.md`).

## Proposed solution

1. Search outside the collection (Web of Science/Scholar, citation chains forward from Coleman & Fausch 2007a/b and back from Hill et al. 2024/2025) for:
   - first-summer degree-days or overwinter size and survival thresholds in age-0 rainbow trout, WCT, BT, coho and Chinook;
   - studies from BC, Alberta, Montana and the Pacific Northwest first.
2. Add hits to `data/temperature_members.csv` and run `0270`. Rebuild and push the store.
   - A hit with no direct PDF (ResearchGate, a publisher page behind a login) is opened in a Chrome tab for Al to download, saved straight into `data/rag/pdf/` (Chrome's "Ask where to save" or its download location), because the agent cannot read `~/Downloads` (macOS folder protection). Batch these into one handoff after the search, not one per paper, and set each row's `pdf` to the repo path, as #40 did for Bear et al. 2005.
3. Draft rows under the #38 brief. A threshold measured as fish size (mm at winter onset) rather than degree-days is still useful, so decide at the plan gate whether it gets a row and under which variable.
4. Revise the `none` notes to name the wider search. Revise `research/thermal_requirements.md`.

Relates to #38, #40

## Errors Encountered

| Error | Resolution |
|-------|------------|
