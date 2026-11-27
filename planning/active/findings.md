# Findings — Coho store: grow species/coho, build and push it, and judge the upper Fraser coho records with it (#284)

## Issue context

**If we do it:** coho literature can be searched like bull trout, sturgeon and cutthroat literature. Its first use is answering how far coho reach up the Fraser, and how far each upper Fraser record can be trusted. **If we never do:** the group library's coho papers stay out of every store, and questions about upper Fraser coho get answered by hand from whichever PDFs someone remembers.

## Where it stands (measured 2026-11-26)

- The group library has `species/coho` (`ZPUIT73I`, under `species`). It holds 16 live items, 15 with a PDF, among them:
  - the Interior Fraser coho conservation strategy (2007);
  - COSEWIC's 2017 assessment of the interior Fraser population;
  - the Interior Fraser coho status summary;
  - Blackwater species distribution models (2000);
  - Pacific Northwest habitat and movement papers.
- The item titled `Life-History-of-Coho-Salmon.pdf` has no PDF attached and is named after a file.
- No store is built from the collection, and it is not in `habitat_modelling`'s build list (`scripts/README.md`). Chinook's collection (`RXNFPBPH`) is in that list.

**The question this store would answer first.** The conservation strategy says coho are "known to occur as far upstream as the Nechako River". It adds that in several major upper Fraser watersheds their presence "is probable but has not been confirmed", and calls the lack of records there "a major knowledge gap". COSEWIC (2017) says coho "may also occur in tributaries upstream of the Nechako (e.g., Bowron River), but their presence has not been confirmed", citing Decker and Irvine (2013). Records north of about Quesnel's latitude in the Fraser drainage:

- **FDIS electrofishing (the published evidence):** coho were caught on 1 of 7,030 visits in 33 groups: one fish in Ahbau Creek (COTR) in 2014.
- **NuSEDS (`knowledge/nuseds/v1`):** three coho populations.
  - Ahbau Creek: 6 spawners in 2001.
  - West Road (Blackwater) River: 100 in 1996, present on a 1999 survey, none observed in 2001.
  - Nechako River: present in 2004, presence and absence only.
- **bcfishobs:** 36 coho records in 12 groups (BLAR, BOWR, CARR, CHES, COTR, FRAN, LCHL, NECR, QUES, STUL, STUR, WILL).
  - 23 are FISS entries from 1986 to 1998 dated to a year or month, with no life stage.
  - Five FISS entries from 2004, all dated 1 January (survey ids 7501690 to 7503426), place coho on the Bowron, Swift, Stuart, Nechako and Blackwater mainstems.
  - Ocock Lake (1976, lakes database) is placed 1.26 km from a stream.
  - Two 2018 FDIS collections record coho fry in FRAN, which the published FDIS evidence does not hold.
- **link's `default` coho range** takes in BOWR, WILL, NECR, LCHL and COTR, and leaves out STUR, STUL, FRAN, TABR, MORK, MCGR and UFRA.

## Plan

- [ ] Grow `species/coho` with `0270 --collection coho --parent 9U54XAND` (`data/coho_{members,additions}.csv`).
  - Add Decker and Irvine (2013) and DFO's stock assessment and recovery documents for Interior Fraser coho.
  - Add the sources the 2018 FRAN collections and the 2004 FISS entries came from, where they can be found.
  - Give the file-named item its PDF or remove it.
- [ ] Build `coho` from `species/coho` alone (`0150 ACTION=build STORE=coho COLLECTIONS=ZPUIT73I`), then push. Add its build line to `scripts/README.md` and its files to `CLAUDE.md`'s data list.
- [ ] Decide at the gate whether `ZPUIT73I` also joins `habitat_modelling`'s build list, as chinook's collection does.
- [ ] As the check, judge each upper Fraser coho record above by its source: which rest on a survey, which on a compilation, and which are doubtful. Say in `research/` how far up the Fraser coho are confirmed, and what that means for BOWR and WILL being in link's range.

Relates to #124 and #190 (the sturgeon and cutthroat stores this follows), #228 (salmon records per stream) and #285 (NuSEDS beside the Pacific Salmon Foundation's corrections, whose Fraser coho flags feed the check above).



## Errors Encountered

| Error | Resolution |
|-------|------------|
