# Findings — White Sturgeon store: gather the recovery documents and Nechako reports into one collection, build it, and push it (#124)

## Issue context

**What changes if we do it:** the White Sturgeon recovery documents and the Nechako White Sturgeon Recovery Initiative's reports can be searched in one store and quoted verbatim, for side-channel and floodplain work on the Nechako and Upper Fraser. **If we never do:** that reading is done by hand, one PDF at a time, and quotes from it go unchecked against their source.

## Problem

Measured 2026-10-30 in the local Zotero database:

- Group library `species/sturgeon` holds 3 items, all with a PDF and a Better BibTeX key: the 2019 Fraser River White Sturgeon provincial action framework, the 2020 lower Fraser status report (Challenger et al. 2021) and the 2023 lower Fraser monitoring program summary. All three are about the lower Fraser.
- Other sturgeon items sit in other group collections. `Nechako - NECR` holds Antill et al. 2013, a recruitment biochronology of Nechako White Sturgeon with its PDF, and two NWSRI webpages with no PDF. `eDNA` holds two sturgeon eDNA papers with PDFs (Pfleger et al. 2016, Farrington and Lance 2014).
- A personal-library `fraser/nechako` collection holds Nechako habitat history. Four of its ten items carry a PDF: Helm et al. 1980, Tredger et al. 1984, Albers et al. 2015 on Nechako flooding, and an Upper Fraser Fisheries Conservation Alliance report. `0150` resolves collections in the group library only, so none of them can reach a store.
- The federal documents with the numbered measures are absent: the recovery strategy for the four White Sturgeon populations (Upper Fraser, Nechako, Upper Columbia, Kootenay) and the 2024 action plan. So are the NWSRI recovery plan and technical reports, and the side-channel history the strategy cites (Rood and Neill 1987; Hay and Company Consultants 2000).
- `0150 build` drops an item with no key or no PDF without saying so, so the webpage items add nothing as they stand.

## Proposed Solution

1. **Fill `species/sturgeon`:** add the recovery strategy, the 2024 action plan, the NWSRI recovery plan and the technical reports on its reports page, and Rood and Neill 1987 and Hay and Company 2000 where a PDF can be found. Add the existing sturgeon items from `Nechako - NECR` and `eDNA` to the collection too; Zotero items can sit in several collections.
2. **Bring the Nechako habitat history into the group:** copy the four personal-library items with PDFs into a group collection the build can name.
3. **Check keys and PDFs** for every item, and list what has no PDF anywhere, so the gap is on record rather than silently absent.
4. **Build and push:** `ACTION=build STORE=sturgeon` over the collection key(s), then `ACTION=push`, and add the line to `scripts/README.md` beside the temperature and flow stores.
5. **Smoke-test with three queries:** side-channel loss near Vanderhoof, habitat use at the Fraser–Nechako confluence, and recruitment-failure hypotheses. Record each result's top citation keys in the build log.

Out of scope: threshold tuning. White Sturgeon is a large-river and floodplain species, so it is carried by floodplain and side-channel layers, not stream rules.

Relates to #122 (the same build for grayling and bull trout) and #14 (keying the corpus on stable Zotero identity), which this does not wait on.

## Exploration (2026-10-31, plan mode)

Read from `zotero.sqlite` with `immutable=1`, so writes not yet checkpointed out of the WAL are invisible (#127).

- `species/sturgeon` (`WEUFTSDC`, under `species` `9U54XAND`): three live members, each with a PDF and a key:
  `fraserriversturgeonconservationsociety2023FRSCSLower`, `bcministryofforests2019FraserRiver`,
  `challenger_etal2021StatusWhite`. Two more in the trash (`J7V2YWA7`, `VQ32RFH8`).
- `Nechako - NECR` (`977GE58E`, 64 rows): `antill_etal2013RecruitmentBiochronology` (PDF). NWSRI webpages `6CRM75L3`
  and `3CVKLDY8` have no PDF. `nechakowhitesturgeonrecoveryinitiative202420232024annual` (`PH5REA3P`) is keyed with no PDF, and its
  URL is `https://nechakowhitesturgeon.org/uploads/Reports/Annual_Reports/2023-24_Annual_Report.pdf`. Already in the
  group with PDFs and the personal copies' keys: `helm_etal1980ReviewNechako` (`EE97YVZ3`), `tredger_etal1984NechakoRiver`
  (`AHE9BFQQ`) and `albers_etal2015FloodingNechako` (`KIWJSBYW`). Also mainstem context:
  `bcwatersurveysunitandcanada-bcfloodplainmappingprogram1984NechakoRiver` (`WEM5QPA8`),
  `macdonald_etal2007ExaminationFactors` (`XVK9G9ZF`), `nfcptechnicalcommittee2023NechakoFisheries` (`HJ39IHTM`),
  `fraserbasincouncil2015NechakoWatershed` (`SGCU6NSQ`) and `levy_nicklin2018ChinookSockeye` (`AFM6VEG9`).
- `eDNA` (`ACQ9YXXL`): `pfleger_etal2016Savingdoomed` (PDF). There is also a standalone attachment `PPMDY4K7` "Ferrington 2014 Monitoring of
  Sturgeon.pdf". `farrington_lance2014DevelopmentGenetic` (`HC9VUJQS`) is keyed in the group with a PDF and sits in
  `eDNA` too.
- Personal `fraser/nechako` (`RYZSBUFC`, library 1): `levy_nicklinreportprepared` (`KHRI3JZZ`, PDF) is
  the UFFCA report, the only one held in personal alone. It may be `levy_nicklin2018ChinookSockeye`, and the group has a trashed copy with the same title,
  `Z9BNRLJL`. There are two standalones, `Y2RWLG9W` Chronology-NFCP.pdf and `733T5ZJV` Nechako_Watershed_Strategy-31Oct2016-FINAL.pdf,
  and several webpages with no PDF.
- Federal (SAR registry): the 2023 amended recovery strategy replaces the 2014 one. The other documents are the 2024 action plan,
  the 2014–2020 progress report, CSAS SAR 2007/014 (the recovery potential assessment, cited from the NWSRI page) and the
  Upper Fraser critical habitat order.
- NWSRI Technical Reports (`https://www.nechakowhitesturgeon.org/publications/reports`): 68 items, about 62 linking a
  PDF under `uploads/Reports/`. The recovery plan is on `/recovery/recovery-plan`.
- Ordering: #128 merged during the gate (`023d466`). #127, the WAL fix, is being worked in another worktree, and Phases 2–3 wait for it.

## Errors Encountered

| Error | Resolution |
|-------|------------|
