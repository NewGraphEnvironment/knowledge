# What the dormant Zotero group libraries hold that the central library does not

**Verified:** 2026-11-21 · **Issues:** #13 (the triage, first piece here), #14 (store identity, which waits on one
library), #179 (backlog move 10) · **Produced by:** `data-raw/zotero_library_triage.py` on the local
`zotero.sqlite` (read through `0270`'s guarded copy), writing `data/zotero_library_triage.csv`; the verdicts on the
unmatched items read against each item by hand

## The answer

Of the 168 live items in the five satellite group libraries, 113 are already in the central `NewGraphEnvironment`
library (group 4733734): 110 found by evidence and 3 by hand. Of the other 55, 51 are to be merged into the central
library and 4 let go. And 27 of the 113 hold a file the central library has no copy of. None of the five libraries
can be retired until the 51 merges are carried out and each of those 27 is attached to its central copy or judged the
same document as the file that copy holds; the personal library (about 280 items with no match by title or DOI) is a separate triage, not done here.

| group | items | present | merge | discard |
|---|---|---|---|---|
| 2517476 | 46 | 14 | 29 | 3 |
| 2769586 | 20 | 19 | 0 | 1 |
| 2796581 | 24 | 23 | 1 | 0 |
| 2796596 | 59 | 43 | 16 | 0 |
| 4573988 | 19 | 14 | 5 | 0 |
| total | 168 | 113 | 51 | 4 |

The groups are named here by id only: one's name is a client project, and the items' titles can carry client and
project names, which nothing tracked in this repository may (`CLAUDE.md`, "One discipline"). All five groups are
private on zotero.org (an unauthenticated read of each answered 404 on 2026-11-21), so their ids lead nowhere public.

## How an item counts as held

The script takes the strongest evidence first, and a match on it settles the item:

| evidence | items matched |
|---|---|
| a live PDF with the same bytes (`storageHash`) as a central PDF | 43 |
| the same DOI | 27 |
| the same title, letters and digits only | 40 |
| the same title before its first colon, or its first 60 characters | 0 |
| none | 58 |

#13's first count matched titles alone and found 65 group-library items missing; with the PDF bytes and DOIs it is 58.
Three of those are recorded `present` by hand with the central key: two works under a corrected or extended title (a
typo in the central copy's title; a project number added to it), and a copy of the Bjornn and Reiser 1991 scan, which
matched by its bytes until #217 replaced the central scan with an OCRed copy. A row the script matched and no longer
does comes back undecided, so a matched verdict never outlives its evidence; a verdict decided by hand is kept on a
re-run whether or not the row matches, so a wrong match can be overridden. A title match could join two different works
sharing a generic title; the 40 title matches were not each read, so a merge that later finds its "present" copy is
another work reopens that row.

## Whether the central library holds the file, not only the work

`present` says the central library has a record of the work. It does not say it has the satellite's file, and
retiring a library deletes its files. `central_file` records that, over every stored file of an item: of the 77
`present` items holding a file, 50 have every file in the central library with the same bytes, 1 has some of its files
there and not others, 14 have a central copy holding another file (another version or scan; one is a Word file), and 12
a central copy holding none (judged over every central item that shares the evidence, since the central library holds
some works twice). The 27 that are not `same` are carried over, or the other file judged the same document,
before retirement.

## What was decided for the 55

- **merge (51):** eDNA, occupancy and detection-error methods (26, the literature `statistics/detection` collects,
  #216); fish passage and connectivity (16); a salmon thermal-tolerance review; and single reports and papers kept for
  their content. Two have no PDF, so the merge carries the record and its link. One has a truncated title, to be taken
  from its PDF when merged.
- **discard (4):** a standalone image file that is not a work, two papers outside BC freshwater fisheries, and a
  PDF-less duplicate of a work merged from another satellite library.

The verdicts were made by the agent working #179, from each item's metadata; Al reviews the four discards before
anything is retired.

## What retirement waits on

1. The 51 merges, through the Web API, each into a collection of the central library, with a note of where it came from;
   and the 27 `present` items whose files the central library lacks (`central_file` `part`, `other` or `none`): each
   file attached to its central copy, or the copy's own file judged the same document.
2. The personal library's triage (about 280 items unmatched by title and DOI, and the 11 personal items with several
   PDFs that #13 listed).
3. Al deletes each satellite group once its merges are done: a group deletion is the owner's.

Both steps 1 and 2 are the issue split from #13 at move 10's gate.
