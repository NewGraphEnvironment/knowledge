# Findings — Backlog move 9: Access gradients and gradient on the ground (#178)

## Issue context

**If we do it:** link's access gradients are traced to their sources and checked against records, the tuning population follows link's access with leave-one-out, and gradient is read over fixed windows and against the floodplain edge. **If we never do:** every tuning rests on inherited access classes, excludes resident populations above barriers, and reads a gradient whose length depends on the catch.

**Open** since 2026-11-18: link's override table (NewGraphEnvironment/link#434) and its known-record rule (NewGraphEnvironment/link#400) closed on 2026-11-17. #70's fixed-window and lidar step still waits on fresh's fixed-window gradients (NewGraphEnvironment/fresh#257), so the plan splits it off as its own issue. #132's literature step can start before them.

### Batch 14. Access

| issue | title |
|---|---|
| #132 | Where link's access gradients come from, and whether they hold |
| #131 | Tune on link's access with its overrides, leaving each visit out of its own |

### Batch 15. Gradient on the ground

| issue | title |
|---|---|
| #70 | Gradient on the ground: field-measured against the Freshwater Atlas, fixed-window gradients, then lidar |
| #71 | Distance and gradient from the floodplain edge (ff02, ff04) for small streams near large rivers |


---

Backlog: `planning/backlog.md`, move 9. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `mcp__zotero__zotero_search_items`: missing ZOTERO_LIBRARY_ID and ZOTERO_API_KEY | Not a route (soul#590; kdot#42 removes the server). Read the group library from `zotero.sqlite` read-only, or through `/zotero-lookup`, `/zotero-api`, `/lit-search` |

## PSCIS gradient fields (2026-11-18)

`bcdata::bcdc_describe_feature()`: `WHSE_FISH.PSCIS_HABITAT_CONFIRMATION_SVW` has no gradient or slope field (41
columns: habitat value, verified length, comments, links). `WHSE_FISH.PSCIS_ASSESSMENT_SVW` has `STREAM_SLOPE`,
`CULVERT_SLOPE` and `CULVERT_SLOPE_SCORE`. So #70's "PSCIS habitat confirmations" step reads the assessment layer's
stream slope; confirmation gradients exist only in the reports (#235).

## Phase 2: expectations, written before sourcing (2026-11-18)

What each class should rest on, if the lineage is sound:
- **15 % (CH, CM, CO, PK, SK, GR, KO):** the anadromous salmon limit in the CWF BC report (Rebellato et al. 2024,
  held), from WDFW's 2009 barrier manual (16 % for CH, SK, CO; held as `BUYCVFJG`). Expect no source for GR or KO at
  15 %: they are freshwater species carried on the salmon class.
- **20 % (ST, WCT):** steelhead from the same WDFW/Rebellato line; WCT expected to have no gradient source of its
  own (borrowed from steelhead or from a resident-trout convention).
- **25 % (BT, RB, CT, DV):** the provincial Fish Passage GIS method's Version 1 limit (Norris and Mount 2016, held:
  "25% was used as the maximum gradient for fish passage in Version 1"), itself expected to cite trout passage or
  expert judgement, not a measured limit.
- **What fish are measured to pass:** leap height and burst speed in the classic passage literature (Powers and
  Orsborn 1985; Reiser et al. 2006; Bell's handbook; Castro-Santos 2005; Kondratieff and Myrick 2006; Lauritzen et
  al. 2010), and last-fish gradients in headwater studies (Trotter 2000, held; Adams et al. 2000 for brook trout
  in steep channels). Expect leap limits in metres and burst speeds in m/s, not percent gradients: a gradient limit
  is an inference from them over a reach length, and that inference is what the records review tests.

## Phase 2: the classes' lineage (2026-11-18)

- **bcfishpass** (`docs/02_model_access.md`, checkout at 620dbe43, 2026-10-01) gives the classes as a table with no
  citation: Pacific salmon 15 %, steelhead 20 %, westslope cutthroat 20 %, bull trout 25 %. Its gradient-barrier
  method reads slope over 100 m upstream of each vertex; the same page's prose says "eg 25% for salmon", which its
  own table contradicts. Gradient barriers are generated at 5, 7, 10, 12, 15, 20, 25 and 30 %
  (`model/01_access/gradient_barriers/README.md`). Its habitat page points to Rebellato et al. 2024's Table 1 for
  salmon and steelhead thresholds.
- **Rebellato et al. 2024** (`BC_report_formatted_final.pdf`, held, rows exist): "Chinook, Sockeye and Coho salmon
  pass gradients up to 16% (WDFW 2009), whereas steelhead pass gradients up to 20%", and "gradients ≥15% were
  considered barriers for all Pacific salmon".
- **Norris and Mount 2016** (held, a BT row exists at 25 %).
- Held passage-performance sources found by `0150`-equivalent `crd_search()` over `habitat_modelling`, `bull_trout`
  and `westslope_cutthroat` (all hybrid, none degraded): Katopodis and Gervais (swimming performance database),
  Blank et al. 2020 (rainbow and westslope cutthroat in an open-channel flume), Trotter 2000 (last-fish gradients),
  D'Angelo and Muhlfeld 2011 (BT and WCT distribution, waterfall barriers), the Upper Fording River fish-passage
  stressor report (WCT movement, culvert and drying reach).
