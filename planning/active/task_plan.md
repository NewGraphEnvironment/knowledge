# Task: Backlog move 9: Access gradients and gradient on the ground (#178)

**If we do it:** link's access gradients are traced to their sources and checked against records, the tuning population follows link's access with leave-one-out, and gradient is read over fixed windows and against the floodplain edge. **If we never do:** every tuning rests on inherited access classes, excludes resident populations above barriers, and reads a gradient whose length depends on the catch.

## Context

Move 9 carried #132 (where link's access gradients come from), #131 (tune on link's access with leave-one-out), #70
(gradient on the ground: field, windows, lidar) and #71 (distance and gradient from the floodplain edge). Each is
several PRs, and #70's windows and lidar wait on fresh#257. The owner wants access and gradient to run concurrently
and every issue sized for one `/planning-init` (CLAUDE.md, "An issue is one plan-init's worth of work").

This branch restructures the issues and carries access piece 1: the fish-passage literature, so the access classes
(15 % CH CM CO PK SK GR KO, 20 % ST WCT, 25 % BT RB CT DV, link's `parameters_fresh.csv`) are traced to sources and
set beside what fish are measured to pass. No change to link.

Measured while planning: `data/literature_evidence.csv` already holds 35 `access_gradient_max` rows from 12 sources
(CH 12, CO 8, ST 5, BT 3, SK 3, CM 2, PK 2; none for GR, WCT, RB, KO), and the group library holds many culvert
passage reports but few swimming or leaping performance papers (Katopodis & Gervais's database is one).

## Decided at the gate (Al, 2026-11-18)

1. **Two tracks, two moves.** #132 becomes the `track:access` umbrella, #70 the `track:gradient` umbrella, each with
   a `## Members` table in order and the rest under "To file when reached". Move 9 carries access piece 1 (this
   branch); a new move 15 carries gradient piece 1, in its own worktree, concurrently.
2. **Its own store.** A `Fisheries/fish_passage` collection (`0270 --collection fish_passage`) and a `fish_passage`
   store built from it alone, like `flow` and `temperature`.
3. **Evidence: gradient and its basis.** `access_gradient_max` rows per species, plus the leap height and burst
   swimming speed a source gives as the reason for its limit, as new variables in the evidence vocabulary, each row
   audited for meaning.
4. **Tools:** sourcing through `/lit-search` and `/zotero-api`, keys through `/zotero-lookup`; never the Zotero MCP.

## Phase 1: issues sized for one plan each

- [x] New issue A, "Fish-passage literature: where the access gradients come from" (this branch): collection,
      store, evidence rows, research file. Body names move 9 as where it was split from.
- [x] New issue B, "PSCIS habitat-confirmation gradients against link's segment gradient" (#70 step 1's remaining
      FDIS-free part; FDIS was #121; FISS workbooks follow #34 in move 7). Body names move 9.
- [x] #132's body → `track:access` umbrella: members A, then (to file when reached) the review of the 1,004 records
      above modelled gradient barriers (link#402's `measures.csv`), what a lower class removes, the tuning setup on
      another access set (owed from #120), the write-up; #131 as a member (its retune on Al's word). Labels
      `umbrella`, `track:access`.
- [x] #70's body → `track:gradient` umbrella: members B, then (to file when reached) FISS workbook gradients (after
      #34), fixed windows and the mouth reach (fresh#257), the lidar pilot in one or two groups LidarBC covers
      (fresh#257's lidar sampling and coverage flag), the decision on what to carry forward; #71 as a member (measure
      and visualize first). Labels `umbrella`, `track:gradient`.
- [x] New move 15 umbrella carrying batch 24 (issue B); #178's body: batch 14 is issue A only, batch 15 left.
- [x] `planning/backlog.md`: move 9's row and batch 14 carry issue A; batch 15 → move 15 (issue B), its own lane;
      #131, #71 and both tracks named under Tracks; `backlog_moves.sh lanes` and the tick check on a copy.

## Phase 2: sourcing

- [ ] Write expectations first (findings.md): which sources should hold each class (bcfishpass's and the provincial
      fish-passage GIS method's citations, Powers & Orsborn, WDFW's barrier manual, Reiser et al., Kondratieff &
      Myrick, Katopodis & Gervais, Peterson/Thompson-style leap studies), per species.
- [ ] Trace the classes' lineage: bcfishpass's docs and code, the provincial method (Norris & Mount 2016, held),
      and what each cites.
- [ ] `/lit-search` over `habitat_modelling` and `bull_trout_grayling` for passage values already held; web and
      publisher search for the rest; PDFs fetched and checked against their title pages.

## Phase 3: the collection and the store

- [ ] `data/fish_passage_members.csv` (held items) and `data/fish_passage_additions.csv` (new works: DOI or
      grey-literature metadata, PDF URL or `pdf = none`).
- [ ] `0270 --collection fish_passage` dry run, live, then a no-op dry run (through `/zotero-api`'s key route).
- [ ] `0150 ACTION=build STORE=fish_passage COLLECTIONS=<key>`, query checks with expectations written first, push;
      `scripts/README.md`'s build list and CLAUDE.md's data-root list gain the store and the two files.

## Phase 4: evidence rows

- [x] Add `leap_height` and `swim_speed` (settled 2026-11-18: `swim_speed` with a metric `burst`, `prolonged`, `sustained`, `critical` or `unstated`, as `fish_length` names its length type, in place of a `burst_speed` variable) to `R/literature.R`'s
      variables and units, and to `0280`'s checks; tests in `tests/testthat/test-literature*.R` first.
- [ ] Append rows (never insert): `access_gradient_max` per species and stage stated, each source's leap or speed
      basis as a second row sharing the quote; region, kind (`lab` for flume and jump tests, `expert` for criteria),
      metric and note per CLAUDE.md's conventions.
- [ ] `0280` passes; a full row-by-row audit of meaning against the PDFs, repeated until a round finds nothing
      inside a previous fix, with the enumeration that ends it.

## Phase 5: write-up

- [ ] `research/access_gradients.md`: a plain-language walk (what link does, where each class comes from, what the
      measured passage limits say per species, what that leaves open for the records review), a table of each
      species' class beside its sources, the specification below; `research/README.md` row.
- [ ] #132's body links it; the records review is filed when this merges.

## Owed at the end (reported, done after merge)

- [ ] File the access track's next member (the records review) and point the backlog at it.

## Validation

- [ ] Tests pass (`devtools::test()`), lintr clean on touched files
- [ ] `/code-check branch` clean (three-round floor)
- [ ] Public sweep of tracked files, issue bodies and commit messages
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: `0280` over the whole table; the store's document count against the collection's PDFs and query
checks against written expectations; `backlog_moves.sh lanes`, `list` and a tick on a copy after the backlog edit;
every issue body re-read top to bottom after editing.

