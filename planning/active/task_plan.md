# Task: Coho store: grow species/coho, build and push it, and judge the upper Fraser coho records with it (#284)

**If we do it:** coho literature can be searched like bull trout, sturgeon and cutthroat literature. Its first use is answering how far coho reach up the Fraser, and how far each upper Fraser record can be trusted. **If we never do:** the group library's coho papers stay out of every store, and questions about upper Fraser coho get answered by hand from whichever PDFs someone remembers.

## Context

The group library's coho papers sit in no store, so questions about upper Fraser coho get answered by hand. The work
follows #190 (cutthroat) step for step: a members CSV and an additions CSV drive `0270 --collection coho --parent
9U54XAND`, then `0150` builds `coho` from `ZPUIT73I` alone. `ZPUIT73I` also joins `habitat_modelling`. The first
use is the check: judging each upper Fraser coho record by its source, written up in `research/`.

What exploration settled (2026-11-26, from a copy of `zotero.sqlite` taken with its `-wal`):
- `ZPUIT73I` holds 16 live items, 15 with a PDF. The file-named item `49HFCT96` is a **standalone attachment with no
  file**, named `Life-History-of-Coho-Salmon.pdf`: almost certainly Sandercock 1991's chapter in Groot & Margolis,
  *Pacific Salmon Life Histories*. Neither the chapter nor the book is an item in the group library, so Sandercock
  1991 is not yet held. A standalone attachment has no Better BibTeX key, so no store can take it.
- The group library already holds much of the Pacific Northwest rearing and overwinter literature, outside
  `species/coho`: Nickelson et al. 1992 (seasonal habitat use), Quinn & Peterson 1996, Swales & Levings 1989, the
  1983 HSI model, Pollock et al. 2004, Rosenfeld et al. 2000, Bramblett et al. 2002, Giannico & Hinch 2003 (side
  channels), the Bulkley overwintering series and Richter & Kolmes 2005. Some appear two or three times (Swales &
  Levings, Wigington et al. 2006, Richter & Kolmes). These become member rows.
- `0270` takes any `--collection` name and needs no code change. `0150` hard-codes no build list
  (`scripts/README.md` holds it).
- cred#48 (an update leaves freed blocks in the store) is open, and Al is fixing it now.
- #285 (the PSF corrections, whose Fraser coho flags feed the check) and #228 are open.
- Records for the check: published FDIS evidence, the NuSEDS published set (`knowledge/nuseds/v1`, over HTTPS),
  bcfishobs on the database holding the published build (the observations link breaks streams at), and link's
  `default` coho range (`lnk_load_overrides()`). `inst/NOTICE.md` has no row for the Province's fish observations.

## Decided at the gate (Al, 2026-11-26)

1. **Breadth: the Interior Fraser series, on condition that the core literature is held.** The additions are the
   items the issue names (Decker & Irvine 2013, the sources of the 2018 FRAN collections and the 2004 FISS entries,
   Sandercock 1991 in place of the file-named item), plus the public Interior Fraser coho series: DFO/CSAS stock
   assessments, the recovery potential assessment, the Interior Fraser Coho Recovery Team's reports, COSEWIC 2002 and
   2016, and upper Fraser survey reports that record or look for coho (Bowron, Willow, Nechako, Stuart, Blackwater).
   The series stop at what those sites link, and EcoCat stays out. Al's condition (answer 1: "assumes we have
   Sandercock 1991 and the Pacific Northwest rearing and overwinter paper and understand the habitat and life history
   literature"): Phase 2 lists the core coho freshwater habitat and life-history works, checks each against the group
   library, makes every keyed copy a member, and files or lists for download each one missing. A quoted coho
   life-history write-up, like `bull_trout_life_history.md` (#198) and `grayling_life_history.md` (#140), is its own
   issue, filed in Phase 6. Say at the gate if you want it on this branch instead.
2. **`ZPUIT73I` joins `habitat_modelling`'s build list.** Al is fixing cred#48 now, so `habitat_modelling` is brought
   up to date with `ACTION=update` on the fixed cred once it merges, not rebuilt (answer 2).
3. Store name `coho`, built from `ZPUIT73I` alone.
4. (Mechanism, decided here.) A committed script writes the record table to `scripts/logs/coho/`. The judgement of
   each record goes in `research/coho_upper_fraser.md`, keyed by the record's id: a judged column in a generated table
   would break the rule that read-back shape matches write-back shape. The log carries only the Province's fields
   (observation id and key, date, species, life stage, source, project, survey id) plus the watershed group, so its
   terms are the Province's (OGL-BC, read from the layer's catalogue record). link's coho range is stated in the
   research file's prose, never as a tracked table, because link's presence table is sourced from bcfishpass, whose
   terms are #76's.
5. (Plan review, 2026-11-26, `review-284.md`.) The records script runs first, since its source fields name the
   reports to gather. EcoCat searches stay out, but a single EcoCat report behind a judged record is gathered: the
   issue asks for the sources of the 2004 FISS entries, and #190 kept Lamson 2020 the same way. An addition with no PDF
   stays out of the CSV until it has one, or until it qualifies as `none` (a DOI whose CrossRef record has an
   abstract), because `0270` refuses an addition with an empty `pdf`. A `bookSection` records no editors
   (`row_creators` types every creator as author, as `data/temperature_additions.csv`'s rows already do), so the book
   title carries Groot & Margolis.

## Phase 1: the records, first (the sources they name feed Phase 2)
- [x] `data-raw/coho_upper_fraser_records.R` (corrected while building it: the population is the Fraser upstream of the
      Quesnel River's mouth, set by the network, since no latitude gives the issue's 36; bcfishobs already carries
      the Province's source fields, so there is no `bcdata` join). It gathers every coho record there: bcfishobs, the
      published FDIS evidence and NuSEDS v1 (populations unplaced, since their codes are mainstems). Output:
      `scripts/logs/coho/<date>_upper_fraser_records.{txt,csv}`, one row per record with a stable id. It asserts the
      counts it was written against: 25 bcfishobs records in 10 groups (24 before code-check round 1 placed side-channel points by their local code), one FDIS visit with coho, five NuSEDS
      populations (the issue named three)
- [x] Why the 2018 FRAN FDIS coho-fry collections are missing from the published evidence (placement, range, a
      filter, or a later export)
- [x] The reports each record names (the 2004 survey ids 7501690–7503426 and the 2018 FRAN collections among them),
      listed in findings as Phase 2's record sources

## Phase 2: inventory, core literature, PDFs and the two CSVs (no Zotero writes)
- [x] Re-measure `ZPUIT73I` from a guarded copy (`0270`'s `db()`): live items, keyed, PDF on disk
- [x] Core literature (decision 1): list the coho freshwater habitat and life-history works the field cites
      (Sandercock 1991; Bustard & Narver 1975; Nickelson et al. 1992 ×2; Quinn & Peterson 1996; Swales & Levings 1989;
      Peterson 1982; Solazzi et al. 2000; Rosenfeld et al. 2000; Ebersole et al. 2006; McMahon 1983 HSI; Bradford
      et al. on interior coho; Burnett et al. 2007 intrinsic potential; anything the IFC strategy and COSEWIC 2017 lean
      on for freshwater habitat), each marked held (key, PDF), held elsewhere in the group, or missing. Recorded in
      findings, and it becomes the life-history issue's starting list
- [x] Sandercock 1991: find an open copy (ResearchGate, title search, author or institution pages). If there is none,
      list it for Al to download. The addition is a `bookSection` (decision 5), with its metadata taken from the
      chapter and the book's title and copyright pages
- [x] Interior Fraser series: Decker & Irvine 2013; DFO/CSAS IFC stock assessments and the recovery potential
      assessment; the IFC Recovery Team's reports; COSEWIC 2002 and 2016; the federal SARA registry pages (printed to
      PDF where no PDF is served, as #124 did)
- [x] Record sources (Phase 1's list), and the Bowron, Willow, Nechako, Stuart and Blackwater survey reports that
      record or look for coho, where public
- [x] Metadata for each addition from its own title page or "cite as" line, never a listing page or a sibling (#124
      round 3, #190's review)
- [x] Dedupe every addition by title and DOI against every library, trash included, from a guarded copy. A live group
      copy elsewhere becomes a member row, the keyed copy that has a PDF where there are duplicates; the duplicates are
      listed in findings and not merged here. A trashed copy is restored, not recreated
- [x] Rows follow #190's rules: a member with no PDF has an empty `pdf`; an addition is in the CSV only with a PDF
      source in hand, or as `none` with a DOI whose CrossRef record has an abstract (decision 5), and every other one
      goes on the gap or download list; URLs percent-encoded; no other library's name or key in any tracked file
- [x] Write `data/coho_members.csv` and `data/coho_additions.csv`, and record per-source counts and MB in findings
- [x] `inst/NOTICE.md`: confirm the CSVs need no row (our bibliography, not a source's data), as #190 did
- [x] #284's body: corrected premises (the file-named item is Sandercock 1991 with no file), the decided breadth and
      decisions

## Phase 3: file the collection through `0270` (Al present for the live run)
- [x] (None: Al gave no downloads before the live run; the gap list stays in findings.) Al's hand downloads in the ignored `data/rag/pdf/coho/`, their rows added to the additions CSV before the first
      dry run
- [x] Re-run the `%PDF` check on every URL through `0153`'s `fetch`
- [x] `0270 --collection coho --parent 9U54XAND --dry-run`; check every `exists` / `copy exists` hit against the item
      it was meant to match
- [x] Live run, then wait for Zotero to sync. A second dry run with no `would` lines and exit 0 proves nothing is
      left to do. Logs go to `scripts/logs/rag/<date>_0270_coho*.log`
- [x] Trash the empty standalone attachment `49HFCT96` through the Web API once Sandercock 1991's item holds its PDF.
      Until then, the build lists it as left out and it belongs in the recorded gap
- [x] Re-measure from a guarded copy: before/after table (live items, keyed, PDF on disk, MB uploaded)

## Phase 4: build, query and push `coho`; update `habitat_modelling`
- [x] Hard gate: every member's PDF on disk, Zotero quit, `-wal` 0 bytes. Then `ACTION=build STORE=coho
      COLLECTIONS=ZPUIT73I`, logged to `scripts/logs/rag/<date>_build_coho.log` with home paths written as `~/`. The
      left-out list must equal the recorded gap, and every origin must map to a live group attachment of a live member
- [x] Four `ACTION=query` checks, with the expected documents written in the log before each runs and the top 5 keys
      recorded after: how far up the Fraser coho are known; overwinter habitat of juvenile coho; causes of the
      Interior Fraser decline; temperature limits for juvenile coho. A miss is reported, not tuned away
- [x] Commit the CSVs and logs before the push (the manifest records the head sha). Then an `ACTION=push` dry run,
      then `CONFIRM=TRUE` with Al present; read the push's result before any verified connect
- [x] `habitat_modelling` (decision 2), once cred#48's fix is merged and installed:
      - pull the store with `ACTION=query VERIFY=TRUE` and confirm Ollama is running;
      - measure free space before and after (`pragma freelist_count` over `page_count`);
      - run `ACTION=update STORE=habitat_modelling` over its whole list plus `ZPUIT73I`, then push;
      - on this branch, add a cred version floor for `ACTION=update` in `0150`, and retire the rebuild-after-update
        text that `git grep -n cred#48` finds (`0150`'s messages, `scripts/README.md`, `CLAUDE.md`).
      If cred#48 has not merged when the rest is done, all of this moves to Owed

## Phase 5: the check: upper Fraser coho records judged by their source
- [x] (Four, as written: survey, compilation, doubtful, and no observation for NuSEDS's not-inspected record.) Define the three verdicts before judging: survey (the record comes from a field survey whose report says how the
      fish were caught or seen), compilation (it is carried from another record or a summary, with no survey behind
      it in the source), doubtful (its date, place or identity conflicts with its source or with other records)
- [x] One verdict per record id in the Phase 1 log: 25 bcfishobs (the 2018 FRAN collections among them), 5 NuSEDS
      and the FDIS visit. Each verdict quotes its passage from a keyed group item with a PDF where a document carries it
- [x] `research/coho_upper_fraser.md`: open with the answer (how far up the Fraser coho are confirmed), then the
      records table, then what it means for BOWR and WILL in link's range and for STUR, STUL and FRAN outside it.
      Gaps at the end. The PSF flags are read in if #285 has landed; otherwise #285's body gets a task to feed them in
- [x] (Its 5 quotes verify; the gate's exit 1 is #282's 42 OCR rows, unchanged from 2026-11-26.) Add `research/coho_upper_fraser.md` to `0280`'s `QUOTED_DEFAULT` and to NOTICE's "Quotes from published sources"
      row; `0280` passes with it
- [x] (None placed: a row moves `timing_nuseds.R`'s coho windows, which #228 and #285 own; the research table leaves the five populations' group blank.) `data/nuseds_reach_groups.csv`: a row for each NuSEDS mainstem reach the check places in a group
- [x] `research/README.md` row. `inst/NOTICE.md` row for the Province's fish observations (licence read from its
      catalogue record), and the FDIS and NuSEDS rows name the new log file

## Phase 6: docs and issues
- [x] `scripts/README.md`: the `0270 --collection coho --parent 9U54XAND` line, `0150 ACTION=build STORE=coho
      COLLECTIONS=ZPUIT73I`, and `ZPUIT73I` added to `habitat_modelling`'s list (with the update note)
- [x] `CLAUDE.md` layout: `coho_{members,additions}.csv` beside the cutthroat ones, the `coho` store, and that
      `species/coho` also feeds `habitat_modelling`
- [x] (#287) File "Coho life history: one research file quoted from the coho store" (decision 1), seeded with Phase 2's
      core list and gaps
- [x] #284's body: the gap (documents with no PDF anywhere) and the outcome

## Owed at the end (reported, done after merge)
- [x] (Not owed: cred#48 merged and the update ran on this branch.) The `habitat_modelling` update and push and the retired cred#48 text, only if cred#48 has not merged by the PR
      (Phase 4's last box)

## Validation
- [ ] Tests pass (`devtools::test()`; no `R/` change expected)
- [ ] `/code-check branch` (three-round floor; ends on an enumeration of every CSV row against its title page, and
      every research claim against its passage), and #56's `public_sweep.py` over the branch
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- CSVs: every PDF source starts `%PDF`, and every metadata row is read against its title page.
- `0270`: the second dry run does nothing.
- Collection: the before/after counts from a guarded copy.
- Store: its manifest entry (documents, chunks, md5), every origin mapped to a live attachment, the left-out list
  equal to the gap, the bucket ETag matched, and four queries with expectations written first.
- `habitat_modelling`: document counts before and after, the free-page share before and after the update (cred#48's
  fix), ETag matched.
- Check: the script asserts its counts (25, 1, 5), one verdict per record id, each with its source passage, and `0280`
  passes with the research file in `QUOTED`; `public_sweep.py` finds no database host in the script or log.

