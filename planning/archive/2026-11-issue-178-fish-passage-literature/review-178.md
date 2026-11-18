# Plan review for #178 (move 9), 2026-11-18

A background Plan agent read `task_plan.md` against #178, #132, #131, #70, #71, the backlog and the code; its report
came back as reply text, written here. Each finding was probed before it was folded or declined.

| # | finding | verdict |
|---|---|---|
| 1 | Blocker: `Fisheries/Fish Passage` (`ESNB4BQB`, six subcollections) already exists; `fish_passage` would sit beside it | Confirmed by a read of the group's collections. Put to Al: the collection is `Fisheries/Fish Passage/passage_limits` (`0270 --collection passage_limits --parent ESNB4BQB`), the store stays `fish_passage` (Al, 2026-11-18) |
| 2 | Blocker: WDFW 2009 has two group items and no PDF; 0270 cannot carry the personal library's | Declined as a blocker: `addition_pdf()` (0270, ~line 465) fetches an `https?://` pdf, and the member row already names WDFW's public PDF (200 `application/pdf`). Folded: merge `BUYCVFJG` into `VDT8YQJT`, and `9EAU75IL` into `TK4PDDE2`, in the live 0270 sitting |
| 3 | GR, KO, RB, CT and DV classes appear in no bcfishpass doc; trace them in fresh's and link's history | Folded into Phase 2 (`git log -S` in fresh and link) |
| 4 | Vocabulary changes; name it `swim_speed` with a metric | Done before the report landed (c46e7750: `swim_speed`, metric burst, prolonged, sustained, critical, unstated). `BL/s` added only if a row needs it. README and CLAUDE.md variable notes folded into Phase 4 |
| 5 | `velocity` is water speed; rows 690-695 and 727 stay | Agreed; no change |
| 6 | A leap or speed row must not carry `parameter` or `model_id` | Folded: a guard in `knw_literature_read()` with a test |
| 7 | "Add to 0280's checks" undefined; an ACCESS grid over the 13 link species | Folded: an access grid met by a value, a `qual` or a `none` row |
| 8 | The research file joins `0280`'s `QUOTED_DEFAULT` | Folded into Phase 5 |
| 9 | Members: the 12 keys behind the 35 rows, `TK4PDDE2` not the duplicate | Already so in the draft members file |
| 10 | Members file must exist; additions columns; check each DOI row's title and creators against its PDF | Folded into Phase 3 |
| 11 | Three places in `scripts/README.md` | Folded |
| 12 | #131 and #71 unlabelled and not pointing at their umbrellas; #234 and #235 unlabelled; #71 and #131 still several PRs | Labels and pointers done now; #71 and #131 are cut when reached (their umbrellas say so) |
| 13 | #70's spec still says "PSCIS habitat confirmations" | Fixed in #70's body |
| 14 | #235: "tens of thousands" unmeasured; PSCIS is Access Only; read the parent gradient beside the segment's | Folded into #235's body |
| 15 | Build the store last, after the audit settles the sources | Folded: Phase 3 files the collection; the store builds after Phase 4 |
| 16 | Merges and uploads in the same sitting as the live 0270 | Folded |
| 18 | Backlog Order table: row 24 before 23 | Fixed |
| 19-20 | Shared quotes only for one statement; settle life_stage and kind per row | Folded as conventions in Phase 4 |
| 21 | The hand placement of #235 has no Verified line | A line added to the backlog |
| 22 | Bound capability values: only a limit's stated basis, plus one capability summary per species | Folded into Phase 4 |
| 23 | No duplicate of the 35 rows; link `research/habitat_literature.md`'s BT trace | Folded |
| 24-27 | Acceptance for the store, 0280, rows per species; stale plan text | Folded into Validation; plan text updated |
