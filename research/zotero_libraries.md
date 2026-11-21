# What the dormant Zotero group libraries hold that the central library does not

**Verified:** 2026-11-21 · **Issues:** #13 (the triage, first piece here), #14 (store identity, which waits on one
library), #179 (backlog move 10) · **Produced by:** `data-raw/zotero_library_triage.py` on the local
`zotero.sqlite` (read through `0270`'s guarded copy), writing `data/zotero_library_triage.csv`; the verdicts on the
unmatched items read against each item by hand

## The answer

Of the 168 live items in the five satellite group libraries, 113 are already in the central `NewGraphEnvironment`
library (group 4733734): 111 found by evidence and 2 under another title. Of the other 55, 51 are to be merged into
the central library and 4 let go. None of the five libraries can be retired until the 51 merges are carried out; the
personal library (about 280 items with no match by title or DOI) is a separate triage, not done here.

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
| a live PDF with the same bytes (`storageHash`) as a central PDF | 44 |
| the same DOI | 27 |
| the same title, letters and digits only | 40 |
| the same title before its first colon, or its first 60 characters | 0 |
| none | 57 |

#13's first count matched titles alone and found 65 group-library items missing; with the PDF bytes and DOIs it is 57,
and two of those are the same works under a corrected or extended title (a typo in the central copy's title; a project
number added to it), recorded `present` by hand with the central key. A title match could join two different works
sharing a generic title; the 40 title matches were not each read, so a merge that later finds its "present" copy is
another work reopens that row.

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

1. The 51 merges, through the Web API, each into a collection of the central library, with a note of where it came from.
2. The personal library's triage (about 280 items unmatched by title and DOI, and the 11 personal items with several
   PDFs that #13 listed).
3. Al deletes each satellite group once its merges are done: a group deletion is the owner's.

Both steps 1 and 2 are the issue split from #13 at move 10's gate.
