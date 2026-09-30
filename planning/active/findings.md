# Findings — Habitat-thresholds literature store and evidence table (CH, BT first) (#19)

## Issue context

**If we do it:** each gradient, channel-width, discharge and timing cutoff for CH and BT carries a citation and a quote. **If we never do:** the thresholds stay inherited bcfishpass values with no recorded basis, and a tuned value can't be defended except by fit to observations.

## Problem

Habitat thresholds for CH and BT (spawn/rear gradient max, channel width min, MAD, lake/wetland sizes, rearing-to-spawning connection distance) are copied from bcfishpass. Nothing records why each value is what it is. link's research on the evidence for departures (NewGraphEnvironment/link#20) proposes a Zotero + ragnar workflow but has not built one; NewGraphEnvironment/link#2 is a separate store about passage, not habitat.

## Starting material (not comprehensive; needs a lot of work)

- **fish_passage_template_reporting**, `data/inputs_raw/bcfishpass_spawn_rear_model_ref.csv`: cited ranges for spawn/rear gradient max and channel width min/max, for CH, CO, ST and SK. It has **no BT row**. CH examples: spawn gradient 0.03 (Kirsch et al. 2004; Busch et al. 2011; Cooney & Holzer 2006), spawn width ≥ 3.7 m, rear gradient 0.05 (Woll et al. 2017; Porter et al. 2008), rear width ≤ 15 m. These are tighter than the bcfishpass values currently modelled (spawn 0.0449, rear 0.0549).
- Same repo, `0300-methods.Rmd` "Habitat Modelling": the threshold tables and the commented-out references table (`tab-fish-spawning-rearing-references`, `eval = F`), with a note that ST rearing was moved to 8.5 % on professional judgment against a referenced 7.49 %. Also cites channel-width work (Thorley et al. 2021; Thorley & Irvine 2021; Finnegan et al. 2005) and stream temperature (Hill et al. 2024, 2025).
- **Zotero group library** collections, with item counts as of 2026-09-25: `species/chinook` (24), `species/bull_trout` (18), `Fisheries/species` (15), `species/salmon` (9), `Fisheries/temperature` (22), `hydrology` (41 across two collections), `skeena/wedzin_kwa_chinook` (131). Seed the store from these, then fill the gaps: BT habitat use by life-history form, ocean- vs stream-type CH, and anything with measured gradient/width at use sites.

## Proposed Solution

1. A Zotero collection in the group library (seeded from the collections above) for habitat use by life stage: gradient, channel width/stream size, discharge, substrate, thermal limits and life-cycle timing. Start with CH (stream- and ocean-type) and BT (resident, fluvial, adfluvial).
2. A ragnar store `habitat_thresholds` built with `crd_store_build()` and pushed to `s3://fresh-bc/rag/`.
3. An evidence table in `data/`, starting from the template CSV rows and adding a BT row: species, life stage, life-history form, variable, value or range, region, citation key, page, quote.
4. Include life-cycle timing (spawn, incubation, emergence and outmigration windows by region), because tying habitat to seasonal discharge needs it. The timing table itself (start/end windows per watershed group, species and life stage, seeded from the template's Gantt CSV) is #25. This store supplies its citations.

Link the table to link's CH/BT threshold research as an input.

Relates to NewGraphEnvironment/link#284, NewGraphEnvironment/link#20



## Context

The CH and BT habitat thresholds (gradient, channel width, MAD, lake/wetland size, the rearing bridge) are inherited
from bcfishpass, and nothing records the basis for each value. The issue asks for four things:
- a Zotero collection;
- a ragnar store;
- a cited evidence table in `data/`;
- timing citations for #25's table.

**link#284 has already reviewed the literature on CH and BT gradient and channel width.** The issue body says link
has no literature workflow yet, but that is no longer true. The review is at
`link/planning/archive/2026-09-issue-284-ch-bt-habitat-thresholds/literature.md`: ~60 rows, each with a Zotero key,
page, quote and "kind" (param / HSI / max-obs / dist / pref / expert / qual). It already found three things:
- the template CSV's "5 %" (Porter 2008) is not in Porter;
- the 1.5 m rearing widths and the 10 km / 5 % bridge have no literature origin;
- bcfishpass cites no source for BT.

That file is the main seed. The template CSV is secondary: it has prose citations, no keys and no BT row.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Timing table cites a key that resolves nowhere (2026-09-29)

`data/life_history_timing.csv` cites `officeofthewetsuweten2013Wetsuwet`, but no library on m1 has that
citation key. The candidates in the group library are `officeofthewetsuweten2013WetsuwetenTitle` (title and
rights, DFO) and `officeofthewetsuweten_etal2013Moricefish` (Morice fish). The row it sources is a Morice
row, so the second is the likely one. It is settled by reading the source in Phase 4.

## Curated member list

`data/habitat_modelling_members.csv` has 74 keys:
- the personal `habitat_modelling` collection (35);
- link#284's literature review;
- the timing sources;
- 20 items from the group-library title search.

Three are not in the group library and are copied in by `0270`: agrawal_etal (library 6), beamer_etal2013
(library 1) and shallinbusch_etal2013 (library 6). `cooney_holzerAppendixInterior`
(library 6) duplicates `cooney_holzer2006AppendixInterior` and was dropped.

## Code-check round 1 on Phase 1 (2026-09-29)

Four fixes came out of this round:
- **Non-UTF-8 input.** `read.csv(fileEncoding = "UTF-8-BOM")` stops at the first byte that is not UTF-8 and only
  warns. A cp1252 degree sign therefore returned a truncated table, and that table then passed validation.
  `knw_timing_read()` had the same bug. Both readers now go through `.knw_read_csv()`, which refuses a file that
  is not UTF-8.
- **`none` rows.** A `none` row that carries a key or a quote is now refused.
- **Error positions.** Errors now give the file line as well as the data row.
- **Trashed collections.** `0150` now skips collections in the Zotero trash.

The round also showed that `JI7EBZNF` (`aquatic/hydrology`) holds only standalone attachments, so it has no
keyed items. It was dropped from the Phase 3 build list, because `collection_keys()` refuses a collection with no
keyed PDFs.

## Code-check round 2 on Phase 1: a defect inside round 1's fix, closed by enumeration

Round 2 found that round 1's "file line N+1" was wrong whenever blank lines sat above the row, because
`read.csv()` skips them. The claim was dropped rather than computed; errors name the data row only.

Everything else held. `.knw_read_csv()` matched the old reader on all of these:
- BOM;
- CRLF and CR line endings;
- line breaks inside quoted fields;
- no trailing newline;
- a header-only file;
- a BOM-only file;
- non-ASCII text.

The real timing table reads `identical` through the old and new paths.

**How the loop ended.** Once a round had found a defect inside a fix, it could end only on an enumeration. All
23 `stop()` calls in `read.R`, `literature.R` and `timing.R` were walked from the parse data:
- 11 report a position, and all 11 go through `first()`, which states only `which()`'s data row;
- none of the others claims a line.

CSV readers in `pkg/`: `.knw_read_csv()` has 2 callers and nothing else reads a CSV. `scripts/0260` still reads
its template CSV the old way. That code predates this change and is not in this diff. The file is all ASCII
today, and `0260` is not re-run once the table has been hand-edited.

## Phase 2: the group collection (2026-09-29)

`Fisheries/habitat_modelling` is `U9ZCZ6RN` in the group library. It has 87 members: the 77 curated keys and 10
new items. 72 have a stored PDF (server md5 set) and 15 have none anywhere on this machine. Most of those 15 are
web-page snapshots or have no attachment: the Thorley channel-width pages, Finnegan 2005, COSEWIC 2012/2018,
Hill 2024/2025, D'Angelo & Muhlfeld, Muhlfeld 2012, FPTWG 2014, Bidlack, Davies, Holzer and TopicModel2.

**The PDFs were in linked files from an old Windows machine.** 24 of the personal collection's 35 group copies had
no PDF. Library 1 holds its PDFs as *linked* files, and 158 of its 177 links are old Windows paths
(`D:\...\al_newgraph_account\storage\<Author>\<file>`). 152 of those 158 resolve once the part after `storage\`
is rebased onto Zotero's `baseAttachmentPath`. `0270` does that rebase, and PDFs are taken only from same-titled
items (G5).
- An audit of all 25 uploads found no source item titled differently from the group item it was uploaded to.
- A server-side audit found no orphan attachment from this run. It found one older orphan: `sloat_etal2017`'s
  group attachment `W8HLSVEI` has no file. The md5-aware `has_pdf()` saw through it, and the rerun attached
  Sloat's PDF.

**The "relevant standalone PDFs" in the plan were not standalone.** The title search matched *attachment* rows.
Gregersen 2019, Beamer (rearing preferences), Keeley & Slaney 1996 and Kondolf & Wolman 1993 are keyed items
already in `species/chinook` and `Fisheries/species`; they were added as members. Screening the 211 true
standalone PDFs found three that are relevant:
- O'Brien 1999 (Duncan BT telemetry: spawning sites and timing);
- Gill 2006 (Forsite BT account);
- Sauter et al. 2001 (EPA Region 10 Issue Paper 1, salmonid temperature).

Each got a new parent item with its own PDF, and the standalone is untouched: re-parenting would have dropped it
from its collections.

**Gap references created.** All seven that were in no library were added:
- `rebellato_etal2024Effectsrail`
- `montgomery_etal1999Channeltype`
- `isaak_etal2015coldwaterclimate`
- `mcphail_baxter1996reviewbull`
- `rieman_mcintyre1993Demographichabitat`
- `dunham_chandler2001Modelspredict`
- `trotter2000Headwaterfishes`

Every PDF was checked to start with `%PDF`, and each title page was read to confirm the document. BBT keyed every
new item within the sync, with no Zotero restart needed. Three items were copied into the group from other
libraries: agrawal, beamer_etal2013 and shallinbusch→busch. `shallinbusch_etal2013` matched `busch_etal2011` by
title (the same paper) and was dropped from the members list.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `URLError SSLV3_ALERT_HANDSHAKE_FAILURE` fetching `https://fs.usda.gov/...` from Python (curl works) | Use the `www.fs.usda.gov` host, which Python's TLS reaches. The item was created before the failed fetch, and the rerun attached its PDF. |
| `database disk image is malformed` on every member when rereading `zotero.sqlite` with `immutable=1` | Zotero was syncing our own writes: an immutable read of the live file sees pages mid-write, and Zotero's exclusive lock blocks a normal read-only connection or backup. `0270` reads a copied file after `PRAGMA quick_check` and retries. The live file was checked (`quick_check` ok on a copy). |

## Code-check round 1 on Phase 2 (2026-09-29)

A re-run was confirmed idempotent, and the review found five latent issues:
- **Copy detection by title alone.** It now requires the same first creator and year wherever both sides have
  them, pages through the results, and never matches an empty title. Probed: "Bull trout Salvelinus
  confluentus" finds Gill 2006, and finds nothing when the creator or year differs.
- **Attachment type from the filename.** `upload()` types an attachment from its filename, and `has_pdf()`
  counts only `application/pdf`, so a non-PDF, or a PDF named without the suffix, would have been re-uploaded on
  every run. `ensure()` now requires `%PDF` bytes and appends `.pdf`.
- **`sys.exit` in `get_json()`** escaped the per-member handler; it now raises.
- **Missing named PDFs.** A `zotero:` or URL PDF named in the additions file that cannot be found is now
  `PDF-MISSING`, a failure rather than `no-pdf`.
- **Torn copies.** A byte copy can pass `quick_check` and still be torn. Both snapshot readers (`0270`'s `db()`
  and `0280`'s `snapshot()`) now keep a copy only when the live file's change counter is unchanged across the
  copy, and `0270` removes its temporary copy on exit.

## Code-check round 2 on Phase 2: a defect inside round 1's snapshot fix, closed by enumeration

Round 1's change-counter guard is blind under Zotero. Zotero opens its database in exclusive locking mode
(hard-coded in its `db.js`), and in that mode SQLite does not bump the header counter per commit: the reviewer
measured five commits leaving the counter unchanged while the mtime moved every time. The guard is now:
- the live file's mtime and size are unchanged across the copy;
- no transaction is open, meaning the rollback journal is absent or its first 8 bytes are zero, before and after;
- the copy passes `quick_check`.

**Proved:** with a copy raced by an exclusive-mode commit, `db()` took 2 copies. It rejected the raced one and
retried.

**Enumeration.** Every reader of `zotero.sqlite` this work touches:

| Reader | Read | Status |
|---|---|---|
| `0270` `db()` | guarded copy | fixed |
| `0280` `snapshot()` | guarded copy, same rule | fixed |
| `0150` `collection_keys()` | `immutable` read of the live file | as before this branch |
| `cred::crd_zot_src_lookup()` | `immutable` read of the live file | upstream; added to the cred issue draft |

`0150`'s likely failure during a sync is the loud "malformed" error. The README says to build only after
`0270`'s writes have synced and the files are on disk. No other script in the repo reads the database.
