# Progress — FDIS site visits include surveys loaded twice under different collection ids (#35)

## Session 2026-10-17

- Plan-mode exploration and a read-only probe of the build — phases approved by user, with: drop and
  map in 0230, the issue's signature without fishing time, the full chain including CH, publish v2
  ("go all phases and publish to v2").
- Created branch `35-fdis-site-visits-include-surveys-loaded` off main
- Scaffolded PWF baseline from issue #35 with approved phases
- Next: Phase 1 (baseline reproduction)
- Phase 2: repeat-survey block in 0230 (signature, keep rule, map, ledger rows, guards). Dry check of
  0230 up to placement: 1,286 groups, 1,413 visits dropped (657 fish, 660 zero, 96 unknown), 4,370 fish
  rows and 1,487 passes with them; 12 single-collection groups left alone; fish differ in 132 groups,
  habitat in 112, fishing time in 47; the kept copy is not the lowest id in 117.
- Phase 3: 0293's first_copy and 0294's dup_of removed, with their consumers in 0295-0298; 0299 to v2; READMEs, CLAUDE.md and data/fdis_README.md point at v2.
- Phase 1: baseline 0230/0240/0250 reproduce exactly; 0290 stopped by fresh_default being rewritten
  by a provincial link run. User chose to filter the existing visit tables (plan correction in task_plan).
- New 0230 (233 s), 0240 (6 s), 0250 (9 s) run; visit tables filtered; log 20261017_fdis_repeat_filter.txt.
- Plan review delivered (review-plan.md). Acted on: B1 (zero and unknown copies of an empty catch
  match; known catch kept), G2 (maturity-coded tie-break), G3 (counted fish partition guard), and
  A2 by the user's rule: a group needs a shared site number or identical measured fish, otherwise its
  copies are kept and listed (status kept_site_differs). B2: publish moves after /code-check.
  Revised dry run: 1,308 groups, 1,431 dropped (623 fish, 623 zero, 185 unknown), 89 zero+unknown
  groups, 0 groups lose maturity-coded fish, 71 copies kept for differing site numbers, 15 in one
  collection; 9,597 of 990,606 counted fish dropped.
- BT reruns on the filtered visits: 0291 (236 s), 0292 (2 s), 0293 (46 s; its steep-patch block switched
  off in the frozen copy and carried from the 2026-10-02 log for the 10 visits still in the table).
- /code-check branch round 1 (review-round1.md): (1) bug inside the refined keep rule: known catch above
  habitat dropped the habitat of 3 unknown copies (90818_909_1, 90853_913_1, 90855_939_1). Fixed by
  moving a dropped copy's habitat to a kept copy that has none, with a guard that no habitat leaves with a
  copy, a ledger row, and `habitat_carried` in the map (the filter applies the same carry). (2) 0294's
  header overstated what its loose-signature count holds: reworded.
- Rebuilt with the carry (0230 413 s, 0240 27 s, 0250 36 s; logs _03): only the 3 carried rows differ from the old fdis_sites minus the dropped copies; filter carried them in ch_mad_visits and ch_rule_visits (none in bt_use_visits). 0295 rerun (279 s) on the filtered table.
- /code-check round 2 (review-round2.md): ws50 placement codes sit on fish rows and left with a dropped
  copy (the habitat defect one axis over): 5 surveys flagged ws50-mismatched only because the copy whose
  codes matched was dropped. Fixed: the ws50 check pools the codes of every copy. Because a fix carried a
  defect twice, the loop ends by enumeration (findings.md, "Enumeration"), not by a clean round.
- Rebuilt with pooled ws50 codes (0230 306 s, 0240 22 s, 0250 37 s; logs _04): tracked outputs unchanged;
  ws50 flags change on 4 kept copies (3 now pass, 1 now fails). The reviewer's PCEA pair stays flagged
  correctly: its dropped twin had no codes (unchecked), the kept copy's own codes contradict the snap.
  Filter extended: a kept copy that now fails leaves; one that now passes takes its twin's row (MAHD
  75709_133_1 into the CH tables); the 3 (BT) / 2 (CH) with neither copy in the old table have twins that
  passed every flag drop, so left at a shared later step (asserted). bt_use_visits unchanged (md5 as read by
  0291-0293); CH tables gain MAHD and lose DEAD 80783_132_1, so 0295 and 0297 rerun (the 0297 run on the
  superseded table was stopped at 44 min).
