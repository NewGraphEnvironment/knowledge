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

## In-collection size thresholds (back-chase of Thorley, Hill, Cope; 2026-10-13)

The `temperature` collection already holds size thresholds that #38 could not file (no size variable):
- **Coleman & Fausch 2007a p. 1241** (CRCT, field, southern Rockies): "cutthroat trout fry need to reach a minimum of 30–35 mm TL by the onset of winter to allow recruitment to age 1". p. 1240 Table 4 caption: "likely to survive over winter (total length [TL] greater than 30 mm at the start of winter".
- **Coleman & Fausch 2007b p. 649 (PDF p. 11)** Figure 5 caption: a shaded "approximate minimum-size threshold for overwinter survival derived from previous field research (Peterson and Fausch 2002; Peterson et al. 2004)", with no number in the text. Its discussion (PDF p. 12) says fry "must likely exceed some size threshold to survive through winter", which is qualitative.
- **Thorley et al. 2022 (UFR WCT, 2021 monitoring) PDF p. ~30**: "Age-0 fish from Ewin and LCO Dry Creeks were estimated to be less than 30 mm, suggesting poor overwintering survival (Sogard 1997; Coleman and Fausch 2007a, 2007b)". This is a WCT application of the CRCT threshold; the preceding sentence speaks of fork lengths.
- Reference lists: Thorley 2021/2022 cite Reimers 1963 (body condition, temperature and overwinter survival of hatchery trout), Kennedy & Meyer 2015 (WCT bioclimatic abundance), Sogard 1997 (size-selective mortality review), and Peterson et al. 2008. Hill 2024/2025 cite only Coleman & Fausch for GSDD. Cope 2020 cites Isaak et al. 2012. These were passed to the searchers' scope via the Coleman forward chain; Peterson & Fausch 2002 and Peterson et al. 2004 are the field origin of the size threshold.

## Search outside the collection (2026-10-13)

Two background searchers (trout and char → `search-tc.md`, salmon and steelhead → `search-ps.md`) ran web search, OpenAlex forward citations (Semantic Scholar returned 429) of Coleman & Fausch 2007a (79 citing works) and 2007b (36), Quinn & Peterson 1996 (282) and Holtby 1988 (224), and back-chased the Thorley, Hill, Cope and Teck reference lists. Each file holds its full dated search log and a Dropped list. **Neither found an independent growing-season degree-day threshold for any species outside Colorado.** What exists: applications of Coleman & Fausch's 800/900 GSDD and 30–35 mm TL to BC WCT (Teck Harmer Creek), size–overwinter-survival regressions for coho, a BC steelhead smolting degree-day rule, and counter-evidence that size does not set first-winter survival everywhere.

Both searchers each made one Unpaywall call carrying Al's email in Unpaywall's required `email=` parameter, unasked; both said so in their logs and reports, and it was reported to Al.

### Added (direct PDF; `data/temperature_additions.csv`, `data/temperature_members.csv`)

| key | why |
|---|---|
| thorley_branton2022SubjectMatter | Harmer/Grave Creek WCT: fork length at onset of winter vs GSDD; 30–35 mm TL = 28–33 mm FL |
| hocking_etal2022SubjectMatter | Coleman & Fausch functions applied to Harmer/Grave GSDD; survival logistic on fork length |
| mochnacz2021Thermalecology | bull trout: thermal units to the onset of winter; NWT populations under 800 growing-season thermal units |
| holtby_scrivener1989Observedsimulated | Carnation Creek coho: winter survival on fall fork length (Eq. 18) |
| hartman_scrivener1990Impactsforestry | coho winter survival vs fall FL (Fig. 72); age-0 trout fall FL vs thermal summation (Table 14) |
| riley_etal1998Habitatbasedassessment | Mid-Fraser steelhead: smolt age from degree-days above 7 °C |
| ebersole_etal2006JuvenileCoho | Oregon coho overwinter survival by fall size (already in the group; added to the collection) |
| ebersole_etal2009ModelingStream | Oregon coho: fall size uninformative; degree-days and smolt length |
| quinn_peterson1996influencehabitat | Big Beef Creek coho fall size and winter survival (already in the group, `intermittent_streams`) |

The two Government of Canada PDFs sit behind an archived-content interstitial, so they were fetched with a cookie jar into `data/rag/pdf/` and the rows name those paths. `0270` gained `bookTitle`, `pages`, `series` and `seriesNumber` for the Holtby & Scrivener book section.

### Browser handoff (Al, 2026-10-13)

Opened in Chrome for saving into `data/rag/pdf/`: Holtby 1988 (CJFAS), Smith & Griffith 1994 (TAFS), Meyer & Griffith 1997 (CJZ), Brakensiek & Hankin 2007 (TAFS), Bradford et al. 2001 (CJZ), Connolly & Petersen 2003 (TAFS), Zabel & Achord 2004 (Ecology).

### Dropped from the candidates, and why

- Coleman 2007 dissertation and Coleman 2007 greenback report: the same study's thresholds, published in Coleman & Fausch 2007a/b, which are held.
- Peterson 2002 dissertation: no stated threshold. Peterson & Fausch 2002 is an agency report that is not online, and Peterson et al. 2004 is paywalled and states no size.
- Harig 2000 / Harig & Fausch 2002 and Zeigler et al. 2019: mean July or warmest-30-day temperature thresholds, not degree-days or size. The temperature cells they would inform are filled; a follow-up candidate.
- Tschaplinski et al. 2025: restates Holtby, and the originals are held.
- Carlson et al. 2008, Bath & Newediuk 2026, Neuheimer & Taggart 2007, Sogard 1997: reviews or methods with no species threshold.
- Campbell et al. 2018, Crozier & Zabel 2006, Achord et al. 2007, Roni et al. 2012, Boersma 2016, Sullivan et al. 2000: no stated threshold, or abstract only and low priority.
- Biro et al. 2004/2021, Post & Parkinson 2001: lake rainbow trout, no stream size cutoff.
- Hunt 1969: brook trout, not a target species. Reimers 1963: catchable-size hatchery trout, not age-0. Kennedy & Meyer 2015: abstract names no threshold.
- Beamish & Mahnken 2001: marine phase.
- Brooks & Robinson 2022 (Lotic for Teck; Elk Valley GSDD–fry length): cited by Thorley & Branton, and not online.
