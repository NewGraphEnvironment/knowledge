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
