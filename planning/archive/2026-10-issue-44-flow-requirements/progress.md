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
- Meaning audit round 1 (`audit-ps-round1.md`, `audit-tc-round1.md`): ps 37 of 191 rows with errors, tc 21 of
  134. Largest single cause was the brief: it prescribed `seasonal_mean` for Tennant, who asks for
  *instantaneous* flows (p. 10, item 4; checked), so 12 Tennant rows and 2 Neuman & Newcombe rows carried it
  (now `instantaneous` / `unstated`; `seasonal_mean` left the vocabulary). Others: the 30–200 % MAD
  standard coded `range` (it is one stream-size-dependent minimum; now `min` with both ends kept); notes that
  took a method from a neighbouring sentence; AMEC IFN `metric` stated on p. 30 (monthly), not read; a
  secondary source's species/region taken untraced (WCT fry velocity was Cascade cutthroat → `CT`);
  class edges coded as limits (Ford's "excellent >55 %" → `optimum`). Deleted 803 (Tennant duplicate), 819
  (misattributed passage depth), 883 (open redd-depth span), 915 (an observed flow, not a need), 993 (a
  kokanee-defined IFN on an RB line). Appended 8 twins that each family had left to the other: 7 RB of the
  USFWS 2007 steelhead/rainbow curves, 1 ST of Beecher Fig. 9b's optimum. Coho `none` notes now cite the
  Ash River general list (names no species; not coded, per the auditor's option b). Applied by
  `scratch_apply_audit1.py` (edits keyed to committed rows, cross-references filled with final numbers).
  Gate: 1014 rows, 0 failing, flow 60/60; 243 tests pass.
- Accepted, not changed: both curve conventions (ps one `range` row per zero-edge pair, tc separate `min`
  and `max` rows) are legal; GR fry 0.8 m/s in three rows (one primary, two multi-study syntheses);
  year-round FISH standards (DFO 30 %, Hatfield 2003 lowest month) stay `rearing` with notes saying so, a
  vocabulary gap for the research file, not a cell (FISH fills none).
- Meaning audit round 2 (`audit-round2.md`): 24 errors in the 77 rows round 1 touched, several inside round-1
  fixes. Two came from round 1's own wording rather than the page: the Tennant note cited recommendation
  "item 4" where the page says item 1, and the USFWS 2007 depth notes turned "deepest redd in our study
  sites" into "deepest redd in the HSC sample". AMEC's summer and spawning IFN went back to `unstated`
  ("minimum monthly flows" does not say mean); the winter rows keep `monthly_mean` (p. 56 and p. 83 say mean).
  The 30–200 % MAD rows now have a blank bound: a program reading `min` would take 30 %, which is the
  minimum only for the largest streams. Raleigh's ≥50 % "excellent" (760) is `optimum`, matching Ford's
  identical scheme; nine Raleigh category-two regions named. One round-2 claim was wrong and was probed:
  the audit said no Hagen & Weber BT spawning velocity row exists, but data rows 497 and 498 are those rows
  (from #33, recoded to cm/s in Phase 1); notes 876 and 886 now cite them. 33 of the 34 mixed groups were
  explained by their own sentences; the 34th (AMEC p. 57 metric) is resolved by the `unstated` fix.
  Applied by `scratch_apply_audit2.py`; gate 1014 rows, 0 failing, flow 60/60.
- Meaning audit round 3 (`audit-round3.md`): every one of the 44 rows round 2 changed, read against its page:
  0 errors, 0 inside round-2 fixes, so the audit ends by enumeration (rounds: 58/325, 24/77, 0/44). It
  settled 825/837: on the Ash River chart (one stream) the 30–200 % standard resolves to a single 45 %, while
  summer steelhead passage stays "50-100%", so that span is not stream-size-set and stays `range`. Its two
  wording suggestions applied. Gate: 1014 rows, flow 60/60.
- Phase 5: `research/flow_requirements.md` written. Its numbers were derived from the table, and two draft claims
  were wrong (Tennant's "good" class is 20/40 %, not 30/50 %; the depth "minima" mixed criteria, HSI edges and
  observed redd depths, e.g. row 777's 4.0–8.1 m dam-outfall spawning). `research/README.md` row and a
  back-link from `modelled_discharge.md`; `CLAUDE.md` data line and drafting conventions; NEWS 0.4.0.
- Phase 5 code-check (`review-p5-round{1,2}.md`): the 0280 guard and the `seasonal_mean` removal clean. Round 1:
  4 research-file claims contradicted by the table (row 858 is a recommendation, not a WUA peak; "means with no
  bound" were in fact written for BT; "depth covered for every species" vs BT/WCT passage `none`; ST passage
  50–100 % left out) and 7 lesser. Round 2 found one inside a round-1 fix: narrowing Table 5 to rows 819–825 kept
  825, an ST row, under "The generic floor (fills no cell)", with 810–817 (ST) beside it. Ended by enumeration:
  a script resolved every row number the file cites (464 references) and checked each against its section's
  species or group; 0 misplaced (one false hit, "350 and 600 cfs").

| Round | Findings | Fixed | Inside previous fix? |
|---|---|---|---|
| 1 | 4 contradicted + 7 lesser (prose) | 11 | — |
| 2 | 1 bug + 5 fragile | 6 | y (825 kept under the generic floor) |
| enumeration | 464 row references vs section | 0 misplaced | terminal |
