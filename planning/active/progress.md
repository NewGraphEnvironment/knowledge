# Progress — Flow needs by species and life stage: literature into the evidence table (CH, CO, SK, BT, GR, WCT) (#44)

## Session 2026-10-07

- Plan-mode exploration; phases approved by Al. Gate decisions: new variable `instream_flow`; months via stage + timing table; grid species CH, CO, SK, BT, GR, WCT, ST
- Created branch `44-flow-needs-by-species-and-life-stage-lit` off main
- Scaffolded PWF baseline from issue #44 with approved phases
- Next: start Phase 1
- Phase 1: tests first (2 new blocks, red), then `instream_flow`, `percent MAD` and the flow metrics in
  `knw_literature_vocab()`; 221 tests pass. Audited all 45 `discharge` rows: only Gottesfeld & Rabnett's CH
  migration low flow (data row 121) is a flow need, moved to `instream_flow` with metric `unstated` (the
  quote names no statistic; the old note's "instantaneous" was an inference). Isaak 2015 (August flow) and
  Boughton & Goslin 2006 (Aug-Sep flow) are summer statistics used to size streams, so they stay `discharge`;
  the roxygen says so. `0280` green: 686 rows, coverage 48/48, thermal 50/50.
- Plan review (Plan agent) returned 2 blockers and 9 gaps (`review-plan.md`). Fixed in Phase 1 before
  committing: units as written for depth/velocity, `m bankfull` for the Sloat bankfull depths (rows 250,
  257, 264), the parameter/model_id guard, `annual_mean` dropped. Gottesfeld's note now names Figure 4
  (September mean flow) and the next paragraph's coho/sockeye statement; the metric stays `unstated`.
  238 tests pass; each new guard goes red under mutation. `task_plan.md` Phases 2–5 corrected (60-cell
  grid with optima counting for flow needs, a vocabulary checkpoint, and the G2 species-coding question
  for Al at the start of Phase 4).
- Code-check on Phase 1: round 1 clean, round 2 clean (notes taken: Figure 4 context, roxygen wording).
- Code-check round 3 found a defect inside the plan-review fix: BT velocity rows 497/498 stored 0.14–0.52 and
  0.65 m/s from a quote in cm/s, and 0280's `m/s = c(1, 0.01)` rescale let the conversion pass, while the
  new rule says depth and velocity stay as written (depth in cm would have failed: the rule lived in two
  places that disagreed). Recoded both rows to `cm/s` (14, 52, 65) and set `m/s` to scale 1; roxygen names
  `ft/s` among the US units. Ended by enumeration: a frozen 0280 with every rescale at 1 fails exactly 4 of
  686 rows (row 29 gradient from a proportion; rows 162–164 substrate mm from cm), each a documented
  rescale on a variable outside the as-written rule. Accepted, pre-existing: 0280's `m = c(1, 1e3)`
  rescale (for bridge distance) also applies to depth in m; no row uses it.

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 | — |
| 2 | 0 (2 notes) | 2 notes | 0 | n |
| 3 | 1 fragile (+3 notes) | 1 (+1 note) | 1 note | y (plan-review unit fix) |
| enumeration | 4 rescaled rows of 686, all documented | — | — | terminal |
- Phase 2 (in flight): `data/flow_members.csv` (26 keys) and `data/flow_additions.csv` (9 works: Hatfield
  2003, Hatfield 2002, Ptolemy & Lewis 2002, Lewis 2004, DFO 2013, Hubert 1985, Tennant 1976, Beecher &
  Caldwell 2022, USFWS 2007 Clear Creek). `0270 --collection flow` built `Fisheries/flow` (`FWTJDD8Z`):
  26 added, 9 created, all keyed by BBT within 3 minutes. The amec 2015 instream-flow appendix had a PDF
  in another local library and was uploaded; Raleigh 1984 has none. Five items opened in Chrome for Al
  (Hatfield & Bruce 2000, Bradford & Heinonen 2008, McMahon 1983 coho HSI on DTIC, now under maintenance,
  Hickman & Raleigh 1982 and Raleigh 1984 on HathiTrust); notification sent.
- Phase 3: FLOW grid in 0280 (60 cells; baseline 2/60), `meets_flow()` enumerated over 180 synthetic row
  shapes, `percent MAD` scale. Vocabulary checkpoint on Hatfield 2003, Ptolemy & Lewis, DFO 2013, Hatfield
  2002 and Tennant: thresholds come as monthly percentiles of mean daily flow, Q95, percent MAD, and
  instantaneous flow, so `percentile` and `percent exceedance` were added (opposite conventions, so two
  units). Hatfield 2003's fish-bearing threshold names no species, which is review G2.
- Phases 2–3 code-check (rounds in `review-p3-round{1,2,3}.md`):

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|---|---|---|---|---|
| 1 | 0 (3 notes) | 1 note (0270 docstring) | 2 notes (exit 1 until filled; ×100 scale) | — |
| 2 | 1 fragile (manifest SHA) + notes | amec note; re-push after commit | corporate-author BibTeX split | n |
| 3 | 2 fragile (README habitat_modelling claim; m ×1000 for every variable) | both: README narrowed; 0280 scopes m/km rescale to bridge_distance | — | n |

  Round 3 enumerated every README/roxygen/docstring claim about units, metrics, the grid and the collection
  against the code (all hold after the fixes). The rescale scope ends by the earlier enumeration (no row
  outside bridge distance relies on m/km) and a re-run: 686 of 686 committed rows verify.
- Hubert 1985's govinfo PDF is digitally signed, so ocrmypdf refused it; 0280 now passes
  `--invalidate-digital-signatures` (only the throwaway copy is altered). Its OCR named the second author
  Helzner (Rhonda S.), not "Helzer" as the additions had it: CSV and Zotero item corrected.
- Al chose group codes for species-less standards (`FISH`, `SALMON`, `SALMONIDS`; fill no cell). Row 121
  (Gottesfeld) recoded `SALMON`. Drafter brief written; two drafters (`ps`, `tc`) spawned.
- Drafts: `ps` 191 rows (CH, CO, SK, ST; FISH 29, SALMONIDS 14, SALMON 4; one CM row, Sautner's chum
  passage depth that Raleigh adopts for chinook), `tc` 134 rows (BT, GR, WCT; 14 CT, 41 RB). Merged (ps
  then tc) as data rows 687–1011; prefix byte-identical to the committed table. Gate: 1011 rows, 0 failing,
  coverage 48/48, thermal 50/50, flow 60/60 (from 2/60). Negative run on a frozen 0280: one WCT spawning
  flow `none` row removed → `flow: 59 of 60`, exit 1. The `tc` drafter found 0280's `table_pages()`
  crashing (`NA/NaN argument`) when a table quote's first token is the last token of the text (AMEC 2015
  ends "Page 1"): `(at + 1):n` counts down past the end. Guarded; old code errors and new returns no match
  on the same input. Drafters had quoted around it, so no row depends on the fix.
- Drafters' doubts, for the audit: ps rows 819 (Ptolemy & Lewis "summer Chinook at 30 cm" passage depth may be
  a misattributed spawning depth), 783 (Roberge YOY steelhead <0.15 m/s may be carried from chinook), 831 (the
  only CH migration flow need is Hatfield 2002's worked example), year-round FISH standards coded `rearing`;
  tc draft rows 6 (McPhail & Baxter 10 cm redd depth as a min), 15 (Ford "preferred" depth as optimum),
  17–18 (Ford vs McPhail & Baxter disagree on juvenile BT velocity), 55 and 63 (WCT velocities with weak
  attribution).
- Mistake, recorded: a `git stash`/`pop` was used to test the old 0280 while the `ps` drafter shared the tree;
  both steps succeeded and nothing was lost, but for about a second the tree held HEAD's versions. Compare
  with `git show HEAD:<path>` instead (code-check-shell.md, "A destructive setup and its undo...").
