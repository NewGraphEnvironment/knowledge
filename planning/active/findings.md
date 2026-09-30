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

## Phase 3: the store (2026-09-29/30)

**Pre-build check.** Once Zotero had synced, a checked copy of the local DB showed 87 collection members: 72 with
the PDF on disk, 0 with a PDF attachment whose file was missing, and 15 with no PDF.

**Build.** `0150 ACTION=build STORE=habitat_modelling` read U9ZCZ6RN plus `chinook`, `bull_trout`, `W4425VK5`,
`temperature`, `wedzin_kwa_chinook`, `X29BX4U8`, `545K8HP4` and `species`. It found 205 keys and ingested 202 PDFs,
giving 202 documents and 33,746 chunks with `nomic-embed-text`, in about 40 minutes on m1.
`cred::crd_zot_src_lookup()` dropped three keys because the attachment it chose was not on disk:
`nagel_etal2014LandscapeScale`, `opperman_etal2010EcologicallyFunctional` and `rapp_abbe2003FrameworkDelineating`.
That is plan-review G1, measured. **All 202 ingested PDFs came from the group library** (each origin's attachment
key was mapped back to its library), so no other library's paper entered the store.

**Push.** The store is in `s3://fresh-bc/rag/habitat_modelling.duckdb` (437 MB), with manifest md5 `039363d0…` at
head `4bf3c69`. A verified connect matched the manifest and replaced nothing.

**Querying is broken upstream.** `0150 ACTION=query` fails on *every* store, not only this one:
`crd_search -> .crd_retrieval_score: 'list' object cannot be coerced to type 'double'`. ragnar 0.3.0 returns
`cosine_distance` as a list column. The spot-check therefore called `ragnar::ragnar_retrieve()` directly as a
probe, and the hits came from the expected sources (Busch, Rebellato, Montgomery, Dunham & Chandler, Richter &
Kolmes, McPhail & Baxter, O'Brien). The fix is not worked around here; it is a second cred issue draft in
`cred-issue-draft.md`.

## Phase 4: the evidence table (2026-09-30)

`data/literature_evidence.csv` has 186 rows: 108 CH and 78 BT, from 47 sources. Three drafting agents wrote the
rows, split by variable group, and each self-checked against the gate. The merge was checked again with the gate
and by reading rows; two duplicate CH bridge rows were dropped.
- **Gate:** 139 `verified_text`, 24 `verified_table`, 8 `verified_ocr`, 1 `verified_ocr_fuzzy` (OCR reads
  "spawned ina few"; checked by hand) and 14 `none_row`.
- **Coverage:** 24 of 24 CH/BT × parameter cells have a row.
- **Timing sources:** all 3 resolve.
- **Store:** all 47 evidence keys are in the pushed store.
- **Mutation proof:** a changed quote, an unknown key and a deleted coverage row each turned the gate red.

**What the table establishes that was not recorded before:**
- **CH spawning MAD 0.46 m³/s has no source.** Rebellato cites five works for it; none gives a discharge threshold
  (both scans were read through OCR). Rearing MAD 0.28 traces to Agrawal, through Sheer 2009 p. 13.
- **The template's CH spawning 3 % is not in any source it cites.** Kirsch 2004 is not in the library, and Busch
  and Cooney & Holzer give 4–7 % and 5 %. The rearing 5 % attributed to Porter 2008 and Woll 2017 is in neither.
  Woll 2015 does rate juvenile CH "No potential" above 5 %, so "Woll 2017" may be a mis-citation of it.
- **The rearing bridge (10 km, 5 %)** has a documented origin only as Rebellato's rearing criterion 4, a design
  choice with no literature. There is nothing for BT.
- **Roberge's CH juvenile "0.5 m" bankfull width is a transcription error.** Porter et al. 2000 Table 2 gives
  20.2 m; the row is kept with a "do not use" note.
- **First reach-scale BT spawning gradients:**
  - O'Brien 1999 (Duncan, adfluvial), 1.3–4 % at reaches with confirmed redds;
  - Bustard & Schell 2002 (Morice), 1–4 % in reaches over 7 m wide;
  - Cope & Morris 2001 (Wigwam), 0.6–1.0 %.

  BT rearing in the Morice spans 1–14.5 % (mean 3.2 %).
- **Page corrections to link's review:** Cooney & Holzer's 5 % exclusion is on C-8, not C-7; Hagen 2015's 2 m
  sentence on p. 23, not 22; Hagen 2020's footnote 9 on p. 31, not 30; Trotter's last-fish values on p. 10, not 9.

**Timing table (Decision 5).**
- **No new sources.** None of the six unsourced CH/BT windows (BULK/MORR incubation, BULK BT migration and
  spawning) is supported *exactly* by any source, so no `source` was filled. The pieces that are supported, mostly
  start dates, are timing rows in the evidence table.
- **One key corrected.** The BULK CO migration row cited `officeofthewetsuweten2013Wetsuwet`, a truncation of
  `officeofthewetsuweten2013WetsuwetenTitle`. The full key resolves in the group, and p. 24 reads "Coho and
  steelhead migrate into the Bulkley watershed in early to mid-August", checked by hand. The dates are unchanged.

**Gate defect found by a drafter.** `find_quote()` used `substring(all_text, at)`, whose default `last` is
1,000,000, so a quote past that character was never found. Fixed and proved on Gottesfeld & Rabnett 2007 (1.19 M
normalized characters): a p. 435 sentence fails under the old gate and verifies under the new one. That is the
only truncating call in the gate.

**Process note.** `0280` was edited while one drafter's gate run was in flight. The run died with a syntax error
on a line that does not exist (the `karpathy.md` §5 tell). The drafter re-ran from a frozen copy, and later
edits waited until no run was active. `ocrmypdf` also needs a writable `TMPDIR` in a sandboxed shell, so the gate
now passes R's `tempdir()`.

## Code-check round 1 on Phase 4: the gate passed fabricated rows

The reviewer changed 8 real rows into fabrications and the gate passed all 8. It also read all 172 cited rows
against their quotes by hand and found no value that contradicts its quote, so the data was sound and the gate
was not. What was wrong, and what changed:

| Hole | Fix |
|---|---|
| A quote that is only an ellipsis or a `[insert]` had no fragments. `0 == 0` passed, and the page came back `-Inf`, not `NA`. | Every fragment must be at least 12 normalized characters. A quote with none fails as `quote_fragment_too_short`. |
| A fragment after an ellipsis could match anywhere later in the document. | Each fragment must start within 2,000 characters of the previous one. |
| A quote ending "13" matched the source's "13.2". | A number at a fragment's edge may not continue into digits: a lookahead, and a lookbehind in which a dot blocks only as a decimal point. |
| The `joined` variant fused "2-\n4 %" into "24%". | Line-end hyphens are joined only between letters. |
| A `table` quote passed when all its numbers sat anywhere on one page. Small numbers are on almost every page. | Table rows are matched against `pdftotext -layout`, which keeps a table row on one line. Their tokens (numbers and words) must occur in order, each within 80 characters of the last, and the quote needs 3+ tokens including a number and a word. |
| Fuzzy OCR at 10 % let a digit or an order word change. | A fuzzy hit must still contain every number and number word of the quote exactly. |
| Values were never compared with the quote. | New `value_not_in_quote`: every value must occur in its quote, as a number, a power-of-ten rescaling of one (proportion/percent, cm/mm, km/m), or a number word. Timing months must be named. |
| Only the first matching page was logged. | `pdf_pages` lists every page where the quote matches. |

**The stricter gate rejected 7 genuine rows.** All were quotes stitched across pages or garbled by the text layer.
- O'Brien's two BT ranges were split into five per-reach rows (1.3, 1.9, 4, 2.4 and 4.9 %).
- Cope & Morris's rearing range was split into its two sites.
- Selong and Schell were moved to OCR with the full sentence, because the text layer renders "13.2°C" as
  "13.28C" and fuses "midOctober".
- Rieman & McIntyre's "fourthorder" now matches: number words are found inside fused words.
- Norris & Mount failed on my own lookbehind bug (see the table).

The in-order table check then rejected Rebellato's Table 1 rows. Their quotes stitched the species name to
citation lines several layout lines away. Each is now the CH row as laid out on the page,
`Chinook 0-3 0.46-322.5 4 0-5 0.28-100 1.5`, with the cited works moved to `cited_source`.

**Result.** 190 rows, gate green:
- 141 text, 24 table, 10 OCR, 1 fuzzy OCR, 14 `none`.

Mutation proof on the hardened gate:
- a changed quote, an unknown key, a coverage gap and a value absent from its quote each turn it red;
- of the reviewer's 8 fabrications, 7 now fail. The 8th ("2 mm < Substrate < 16 mm" on Woll p. 84) says the
  same thing as the page's "16 mm > Substrate > 2 mm", so passing it is correct.

**OCR in a sandboxed shell.** `ocrmypdf` failed here even with `TMPDIR` set to R's `tempdir()`, because that is
under `/tmp`. Its work directory is now inside the gitignored OCR cache and is removed afterwards.

**The corrected timing source (`officeofthewetsuweten2013WetsuwetenTitle`) was not a collection member.**
`0270` added it; the collection now has 88 items. The pushed store has the other 87: no evidence row cites this
item, so no rebuild was run for it.

## Code-check round 2 on Phase 4: the mechanism, the rewrite, and the enumeration that ended the loop

Round 2 built 13 more fabrications and all passed the round-1 gate. It named the mechanism: every check asked
whether a **lossy version of the claim** occurred somewhere in a **lossy version of the page**. Each round-1 fix
closed one instance and left the lossiness itself in place, so the class returned one step over each time. The
committed data held throughout: re-run under a strict comparison, no row changed status. Only row 15 had passed
without its claim actually being matched.

**The rewrite.** Quote and page are compared as token sequences:
- numbers as written, words, and every other character as its own token;
- matching is contiguous;
- the value is read from the quote's own fragments;
- there is no fuzzy tier.

Table rows use the `-layout` text with adjacent tokens (a hop of 0) across at most 3 lines.

**Data changes it forced (all genuine rows):**
- Row 15 is quoted in layout order, `≥0 None None None BF < 3.7 m`.
- Row 54 skips the OCR's "ina" with an ellipsis.
- Row 183 moved to OCR ("late-August"; the text layer fuses "lateAugust").
- Rows 131 and 132 exposed a too-eager sign rule ("3.3° –13.3°" is a range).
- Row 176 exposed a too-strict day rule ("first week of September … September 10").

**Proof.** The committed table has 190 rows, exit 0: 140 text, 24 table, 12 OCR, 14 `none`. Red:
- round 2's 13 fabrications, plus T3, a fabricated row in layout order;
- round 1's 8 fabrications;
- the 4 whole-table mutations (a changed quote, an unknown key, a coverage gap, a value absent from its quote).

With a table hop of 12, fabrication T1 still passed by collecting "High"s from later rows. With a hop of 0, all
24 real table rows still pass.

**Enumeration.** Every place the gate treats two different strings as the same, what remains there, and why it
cannot pass a false claim:

| Place | What is still equated | Why no false pass |
|---|---|---|
| `clean()` | curly and straight quotes; primes; every dash and the minus sign → "-"; soft hyphens and zero-width characters dropped; the no-break space family → space; ligatures ff/fi/fl/ffi/ffl spelled out; º and ˚ → °; lower case | Typography only. No digit, operator (`<`, `>`, `≥`, `≤`, `%`, `°`) or word is created, merged or removed. NFKC is gone, so "½", "³" and "◦" stay distinct characters. The dash unification makes "3 — 12" and "3-12" the same, which is the same range reading. |
| `TOKEN` | runs of whitespace, including line breaks | Only separators. A number is one token as written: "1.5", "1. 5", "13,2" and "20,653" all differ. |
| joined variant | "habi-\ntat" = "habitat" | Between two **letters** only; digits are never joined. |
| `occurs()` | none: exact contiguous token equality | Plus both edges guarded: a quote may not stop inside a number or a "-", "." or "," continuation of one. |
| fragments | text between an ellipsis or `[insert]` | Each fragment is at least 3 tokens, in order, and starts within 200 tokens of the previous one. The committed rows need fewer than 150. |
| `table_pages()` | line breaks between adjacent tokens (at most 3 lines) | Tokens are adjacent in the layout; no token may be skipped (hop 0). |
| `quote_numbers()` | a number after a non-numeric "-" may be read with either sign | The only sign loss. A range after a unit symbol ("3.3° –13.3°") cannot be told from a negative. No committed row has a negative value. |
| `quote_numbers()` | a number word, or one fused with "order" ("fourthorder") | Whole tokens only: "none", "often" and "network" no longer count. |
| `SCALE` | percent ×100 (from a proportion), mm ×10 (from cm), m ×1000 and km ×0.001, m/s ×0.01 | Set per unit. Temperature, discharge, area and order are ×1, so "148 °C" no longer passes as 14.8. |
| `timing_in_quote()` | a month's full name, or its three-letter form except may/mar/jun | Whole words. A stated day binds when every mention of the month carries one, and the start month must be named before the end month. |

Nothing else in the gate compares text. That ends the loop by enumeration rather than by a quiet round.
