## Outcome

The group library's `species/bull_trout` and `species/grayling` collections were cleaned through `0270`. It gained
`--parent`, and it refuses a name that exists under another parent. The cleanup is driven by
`data/bull_trout_members.csv`, `data/grayling_members.csv` and `data/grayling_additions.csv`:
- Hagen & Weber 2019 and Gill 2006 were added to bull_trout.
- Beaudry 2014 (the keyed copy with its PDF) and Ballard & Shrimpton 2009 were added to grayling.
- The three standalone grayling PDFs got keyed parents, eight PDFs were uploaded, and two duplicates were taken out of
  grayling.

Today's Zotero merge had re-keyed Hagen & Weber to `hagen_weber2019Limitingfactors`. It was rekeyed in 22 evidence rows
and three members files, and `0280` passes. `0150 build` now names every member it leaves out. It needs cred 0.5.0,
the release that fixed the PDF pick (cross-library keys, the trash, newest-of-several; cred#40, filed from here), and it
passes the group as cred's `library`.

The new `bull_trout_grayling` store and a `habitat_modelling` store with grayling added were built and pushed. Every
document in both maps to a live group attachment.

Learned:
- The issue's first counts included trashed items.
- Zotero's database switched to WAL mode about 2026-10-30. A sync looked stalled because the main file's mtime does
  not move in WAL mode, and the guarded copies and `immutable=1` reads miss the `-wal` file (#127).
- cred's dump of the full bucket manifest names a private repo, so a push log keeps only its own store's entry.

## Measurement

| collection or store | before | after |
|---|---|---|
| bull_trout, live items | 15, 6 with a PDF | 16, 11 with a PDF |
| grayling, live items | 27, 19 with a PDF | 25, 24 with a PDF |

The remaining misses are three web pages, McMahon 2007 (paywalled), the Metolius report (not found) and Williamson &
Zimmerman 2005 (not found). `0150` names the same six (6 of 45 members), so the build drops nothing unexplained.

`bull_trout_grayling`: 36 documents (35 keys; Bottoms 2023 contributes its report and its appendix), 5,534 chunks,
2.7 min. A Williston bull trout spawning query returns Hagen & Weber 2019, Hagen et al. 2020 and Hagen & Sary 2023.

`habitat_modelling`: 222 documents to 263 (46,600 chunks), 26 min.
- No key was lost.
- 40 keys are new: 23 from grayling, 3 from bull_trout PDFs uploaded here, and 12 that joined temperature after the
  2026-10-11 build.
- 2 hydrology keys were dropped before only because cred's single pick had no file on disk.
- One trashed attachment was replaced: Martins et al. 2022, `HKTCPDVJ` to `KZU26QII`.

Details are in `findings.md`. The branch review (three rounds) found:
- a standalone counted as covered by an item outside the build;
- the private repo name in the push logs;
- home paths in planning.

The review ended on an enumeration of that one mechanism (a default population taken for the claimed one) over the
diff, plus the #56 sweep.

## Evidence

- `scripts/logs/rag/20261031_*`: the store builds and pushes.
- `scripts/logs/habitat/20261030_literature_verify*`: the `0280` run after the rekey.
- `review-plan.md` and `review-round*.md` in this directory.

Closed by: PR for #122 (branch `122-arctic-grayling-and-bull-trout-store-cle`)
