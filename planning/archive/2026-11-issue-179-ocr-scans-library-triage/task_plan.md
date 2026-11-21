# Task: Backlog move 10: Report corpus: one library, stable keys, and our own prose indexed (#179)

**If we do it:** one central Zotero library, store documents keyed on parent item and library, and our own research and archive READMEs searchable beside other people's reports. **If we never do:** 331 citation keys keep warning wherever no library is named, store documents join three incompatible ways, and our own findings stay greppable one repo at a time.

## Context

Move 10 carries batch 16 (#13 dormant Zotero libraries, #14 stable store keys, #16 our own prose indexed) and
batch 22 (#217 OCR of ten scans every store skips). Exploration found each member is a PR or more:

- #14's identity change is cred's: a store document's identity is its attachment path
  (`storage/<attachment key>/<file>`, cred `R/store.R` `.crd_origin_id()`, `R/zotero.R` `.crd_zot_key_from_path()`),
  so keying on parent item, library and version starts with a cred issue.
- #13 re-measured today (title prefix + DOI against library 9): 57 group-library candidates (libs 2: 32, 7: 16, 8: 7,
  5: 1, 6: 1) and 280 personal-library ones.
- #217's ten scans sit in **five** stores, not the three its body names: `habitat_modelling` (all ten), `temperature`
  (Bjornn & Reiser 1991, Hartman et al. 1987: SW2RXUJC), `flow` (Bjornn & Reiser, Ford et al., Neuman & Newcombe,
  Stuart & Chislett: FWTJDD8Z), `fish_passage` (Bjornn & Reiser: HJZKI75D), `bull_trout_grayling` (Stuart & Chislett:
  GELFSUTU).
- Installed cred 0.7.0 is stale (0.8.0 released, needs ragnar >= 0.4.0). `ocrmypdf` and `tesseract` are on PATH.

## Decided at the gate (Al, 2026-11-21)

1. **Scope:** this PR carries all of #217 and #13's first piece (the single-library policy in `CLAUDE.md`, a triage
   script and a per-item verdict record for the 57 group-library candidates). #14 and #16 are left unplaced for the
   next `/backlog-sweep`; #14's wrong `CLAUDE.md` sentence about BBT-named documents is fixed here.
2. **Personal library out of scope:** a new issue carries the personal-library triage (about 280 items, and the 11
   multi-PDF items listed in #13), carrying out the group-library merges, and retiring the five satellite groups
   (a group deletion is Al's).
3. **#16 gets a separate store** for our own prose, each document keyed by repo + path + commit; written into #16's body.
4. **Upgrade cred to 0.8.0 and ragnar to 0.4.0** on this machine and rebuild under them; the PR says every machine that
   updates stores (the database's host included) needs cred 0.8.0.

Policy (from #13's body, into `CLAUDE.md`): the central `NewGraphEnvironment` group library is the single source; a share
library holds copies only, and a copy gets a new key so nothing joins on a share-library key.

## Phase 1: OCR the ten scans and rebuild the stores that hold them (batch 22, #217)

- [x] Upgrade cred to 0.8.0 and ragnar to 0.4.0 (`pak::pak()`), and check `0150`'s version gates still pass
- [x] Download each of the ten attachments (keys in #217's table), `ocrmypdf --deskew` each into `data/rag/pdf/ocr217/`
      (ignored), check each title page reads correctly, and record its word count
- [x] Append ten `replace` rows to `data/zotero_attachment_verdicts.csv`, in the shape of #151's and #194's rows
      (item, citation key, attachment, file, `why` with the word count and the md5-mismatch note)
- [x] Run `0275 --only <the ten item keys> --dry-run`, then live, then a no-op dry run; record the new attachment keys;
      commit the verdict rows before any push (review)
- [x] Sync Zotero, then quit it (or wait for a 0-byte `-wal`: cred reads the live file immutable, cred#45, and a
      `replace` keeps the citation key, so a build could take the old scan again; review), check each new
      `~/Zotero/storage/<new key>/<file>` exists with its OCR file's md5, then pull and rebuild
      (`ACTION=build OVERWRITE=TRUE`, each store's whole build list from `scripts/README.md`) `habitat_modelling`,
      `temperature`, `flow`, `fish_passage` and `bull_trout_grayling`; log each to `scripts/logs/rag/`, read each
      dropped list, and check per store: the new attachment keys in its origins (10, 2, 4, 1, 1), none of the old ones, no
      `-wal` warning in its log, and a query hit for Bjornn & Reiser and Ford et al.
- [x] `peace` is left out (review): it also holds Stuart & Chislett (`data/rag/_pdfs/peace/XDKIU3UA.pdf`), but it is a
      key-named store of local copies that `0150` cannot update, and rebuilding it renames all 117 documents, which is
      #14's key change; say so in #217's body
- [x] Push each store (`ACTION=push`, dry run first), and read each push's result before any verified connect; each
      manifest entry shows `store_schema: "0.4.0"`, and a verified connect after the push passes
- [x] Correct #217's body: five stores, not three; tick its plan
- [x] Two more textless scans the first `flow` rebuild skipped (McMahon 1983, Hubert et al. 1985): OCRed, replaced
      through `0275`, `flow` rebuilt again (found mid-run; same issue, same mechanism)

## Phase 2: The single-library policy and the group-library triage (batch 16, #13's first piece)

- [x] Write the single-library policy into `CLAUDE.md` (Zotero working notes), and correct the store sentence: a
      cred-built document is named by its attachment path, which `crd_search()` resolves to a citation key (#14); the
      same sentence in `scripts/0150-store.R`'s header and `scripts/README.md` (review)
- [x] `data-raw/zotero_library_triage.py`: from a guarded copy of `zotero.sqlite` (the `snapshot()` rule), match each
      live top-level item of the five satellite groups (by group id) against library 9 by PDF md5 (`storageHash`), DOI, then
      normalised title, and write `data/zotero_library_triage.csv` (group id, item key, match kind, library-9 key,
      verdict, reason). No titles or library names in the tracked file (a satellite library's name and titles can
      carry client identifiers); the script prints titles to the terminal for review
- [x] Give each unmatched candidate a verdict (`present` under another title / `merge` / `discard`) with a reason,
      checking each against the item itself
- [x] `research/zotero_libraries.md`: what each library holds against library 9, the match counts by kind, the
      verdict counts, and what retirement waits on; add a row to `research/README.md`
- [x] File the new issue (personal-library triage, the 11 multi-PDF items, carrying out the `merge` verdicts,
      retirement), naming move 10 as where it was split from; move the "Personal-library items" list and the
      `fisheries/fish_passage` note out of #13 into it
- [x] File a cred issue for document identity on parent item key, library and version, with a resolve check for
      merged-away keys; write "blocked by cred#N" into #14's body, and tick its `CLAUDE.md` sentence fix there
- [x] Write the separate-store decision into #16's body
- [x] `planning/backlog.md`: batch 16 keeps #13 only; #14, #16 and the new issue are named nowhere in the file (batch
      22's mentions of #14's rebuild and the personal-library pointer included, review), so the next sweep places them;
      the move 10 row says so; record it in #179's body; the PR closes #13 and #217

## Owed at the end (reported, done after merge)

- [ ] cred 0.8.0 installed on every machine that updates stores (the database's host included)
- [ ] Al reviews the `discard` verdicts before the new issue carries out any merge or retirement
- [ ] A read of one rebuilt store on another machine once its cred is 0.8.0

## Validation

- [x] Tests pass (`devtools::test()`)
- [x] `/code-check branch` clean
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion

Verification: each OCR's title page and word count are read by eye; `0275`'s second dry run reports every row done;
each rebuild's log shows the ten ingested (none in its "no text" skip list) and its dropped list read; a query on two
stores returns OCR text from Bjornn & Reiser 1991 and Ford et al. 1995; each push's manifest md5 matches the local file.
The triage script runs twice to the same CSV (deterministic order); a spot check of five verdicts against the items;
`public_sweep.py`-style grep of the new tracked files for library names and client terms.

