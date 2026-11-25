# Plan review for #274 (Plan agent, 2026-11-24, run beside Phase 1)

Each finding is followed by its verdict after a probe.

## Blocker
- **B1.** Seber's book metadata (publisher, edition, ISBN) has no column in `data/detection_additions.csv`; 0270 reads
  them with `row.get()`, so they would be dropped silently. **Confirmed** (`statistics_additions.csv`'s header has
  `publisher,edition,place,ISBN`; detection's does not). Folded: if Seber is filed, extend the header with those
  columns (existing rows unchanged), or carry the ISBN in `why` as the RISC row does. Moot if Seber is a gap.

## Gap
- **G1.** The build gate dropped #216's "every PDF of the four collections is on disk". **Accepted**, restored.
- **G2.** The dry run returns before the PDF and abstract checks for a new item, so the manual `%PDF` check and the
  CrossRef abstract check are the only gates. **Accepted**, stated in Phase 2.
- **G3.** No step moved browser downloads into the repo. **Accepted.** Measured: Chrome saved Morris 2019 to the
  folder last used for a save, outside `~/Downloads`; it was moved into `data/rag/pdf/detection/`.
- **G4.** Only `detection` is re-measured, though the expected document count assumes the other three collections
  are unchanged since #223. **Accepted**: measure all four.
- **G5.** The enumeration should compare what 0270 files (CrossRef's title after `plain()`). **Accepted.**

## Ordering
- **O1.** Files on disk ran ahead of `progress.md`. **Accepted**; the HTML saved as `albert_anderson1984.pdf` was an
  ORBi request-a-copy page and was deleted. Progress is recorded with this commit.
- **O2.** Rename Taylor's file to the `_accepted.pdf` convention. **Done** (`taylor2008_accepted.pdf`).

## Assumption
- **A1.** The plan's decision 4 cited #216's decision 4 for "abstract-only when CrossRef holds it", but that
  decision made every no-PDF work a gap and filed none abstract-only. **Confirmed.** Decision 4 is withdrawn; whether
  a no-PDF work is filed abstract-only or listed as a gap goes to Al after the search (Open decisions).
- **A2.** The plan's note on where 0270 runs needed rewording. **Accepted**, reworded.

## Scope
- **S1.** An abstract-only work never reaches the store (0150 leaves out items with no PDF). **Accepted**: it goes
  with A1's question, and #274's body says so.
- **S2.** Seber 1982 is a copyrighted book in print; an unlicensed full-text site must not be used or recorded.
  **Accepted**: only lawful copies, and no such URL in any tracked file.

## Acceptance
- **X1.** A Taylor query on activity patterns would hit Ridout & Linkie 2009 and Rowcliffe 2014. **Accepted**: the
  query is on Taylor's own method (von Mises kernel, plug-in bandwidth), with those two listed as acceptable hits.
- **X2.** No Kellner query and no before-run. **Accepted**: a before-run of the queries on the pulled store, a
  Kellner query, and expected hits written as author and year.
- **X3.** Code-check's closing re-check of the enumeration against the filed items. **Accepted**, restored.
- **X4.** #223's check that the worktree's `data/rag` is real, not a symlink. **Accepted**, added.

## Public-repo hygiene
- **P1.** No other library's name or key in a tracked file; logs with home paths as `~/`. **Accepted**, restored.
- **P2.** Planning files clean. Noted.
