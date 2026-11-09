# Findings — Backlog pass: batch the open issues into moves with umbrellas (#169)

## Issue context

**If we do it:** the open issues are grouped into a short list of moves, each an umbrella issue carrying the batches that share files or a cost, planned with one `/planning-init` and landed in one PR, in an order kept in `planning/backlog.md`. Issues whose premise has been met or superseded are closed with the reason. **If we never do:** 58 open issues are picked one at a time by whoever remembers them, issues already done stay open (at least two were finished by a later PR and never closed), and work that shares a file or a retune is paid for more than once.

## Problem

The repo has 58 open issues (2026-11-09), filed over two months across the report corpus, the FISS workbook track, Zotero and the stores, the tuning and its articles. Nothing records which ones edit the same files, which wait on the same retune or upstream change, or which are already done. Several larger efforts already run as tracks with their own umbrellas (baselines, speed, provenance, minimal-run), so the rest need the same treatment without being folded into them.

## Proposed

A backlog pass, run as planned work because of its size:

- [ ] Read every open issue body and its comments; measure what the batching depends on: the reference graph between open issues, each older premise against the code, and the state of upstream issues a batch waits on.
- [ ] Group by the files a batch edits and the cost it shares (a retune, a Zotero sitting, one site build), never by topic alone; fold the batches into as few moves as can be held at once, marking a move **waiting** where it depends on a named check.
- [ ] Report once at the plan gate: proposed closures with their reasons, the moves and batches with their gates, a ranked first three, each umbrella's title and body, and the count of issues placed.
- [ ] On the go: write `planning/backlog.md`, scan it and the umbrella bodies for anything private (this repo is public), file one umbrella per move, close what was agreed, and open the PR.

## Done when

- [ ] Every issue open at the freeze is named in `planning/backlog.md`: in a batch, a track, the singles, or closed and transferred.
- [ ] Every open move ticks cleanly on a copy of the file, and the next move is named.

## The read (2026-11-09)

Every open issue's body and comments were read in full on 2026-11-09: 58 issues, about 226 KB of text. Only #4 carries
comments that change its spec (parked after Phase 3 on 2026-09-04, B2–B6 unfixed). `refgraph.txt` beside this file
lists, for each open issue, the other open issues its body names.

### Reference graph

Most named: #120 (6), #118 (4), #64 (3); then #96, #85, #81, #80, #70, #68, #42, #34, #23, #140, #14 and #139 (2 each).
#118 is the hub of the articles work: #107 is folded into it, #156 rewrites the same articles, #115 and #64 point at it.

### Premises checked against origin/main

| issue | verdict | evidence |
|---|---|---|
| #68 | done | 9f4b21bd (2026-10-22, #73's PR, message names #68): `R/tune_grid.R:52` `grid_grad` runs 3 to 30 %; #92 and #145 republished on it |
| #72 | done | 9f4b21bd: the curve carries `edge_stream`; `scripts/0320-tune-run.R:595` takes `ref_edge` from it, `:567` records `discharge_load`, `:613-614` compare both |
| #80 | superseded | its first task (re-pick from link's flow version) is #141's anchoring check (`research/baseline_anchoring.md`); the wetland door was built by #73 (`tuned_as = door`, `inst/method/settings.csv:68`); link#364 closed |
| #48 | done | PR #50 landed data rows 1137–1145; "What remains" describes `0280` refusing an abstract row once a PDF arrives, which needs no work |
| #3 | superseded | `scripts/0154-corpus-tag.R` (7232d463, 2026-07-30) writes `data/corpus_tags.csv` with content tags from captions and the `farmed` flag |
| #34 | open | `scripts/0250-fiss-evidence.R:136` still reads `average_gradient_percent` as is |
| #31 | open | `data/life_history_timing.csv`: BULK CO migration 08-15, no end |
| #142 | open | `tests/testthat/test-link_place.R:32-39`: no skip on an empty result |
| #77 | open | no scale bar or keymap in `R/compare_map.R` |
| #81 | partly done | maps and floodplain are `STAGE=maps`; `GPKG` still defaults on (`scripts/0330-compare.R:90`); `research/fig/` holds 102 files |
| #115 | open | `inst/method/settings.csv` has no `structures` row; `tuned_as` note unchanged |
| #136 | open | `scripts/0310-evidence-build.R` never writes `fdis_sites.csv` |
| #156 | open | README lines 13–21 and 48 say "rule" |
| #168 | open | `scripts/0153-reports-to-zotero.py:49-51` reads `ZOTERO_API_KEY` only |
| #107 | open | `data-raw/vignette_bib.R:94` pins upstream fwapg to the build's `fwapg_sha` |
| #10 | open | `data/pine/fiss_xls_fetch_log.csv` header lacks `idx` and `xls_url` |
| #120 | nearly done | one premise box answered but unticked ("Closes: … 2.8 % against 1.5 %"); last task waits on link#460 |
| #23 | consumer gone | link#294 (its consumer) closed; most of the FDIS half exists in `fdis_sites.csv` |

### Peer state (2026-11-09)

| open | holds up |
|---|---|
| link#434, link#400 | #131 (move 9) |
| link#402 | #132's record rules |
| link#460 | #120's last task (the Atlas setup's archive token) |
| link#463, link#462, link#444 | link drawing #120's parent-gradient pick |
| link#346, link#343 | the flow-number decision (#80's remainder, baselines track) and #140 |
| cred#45 | #130 |
| fresh#257 | #70's windows and lidar, #71's profiles |
| wet#6 | #42's monthly bias by region |
| flooded#14, floodplains#123 | #71 |
| fly#108 | #156's fly row |

Closed since the issues that name them were written: wet#70 (daily flow: #42's 7-day minimum is unblocked), wet#126
(#96's first consumer), link#294 (#23's consumer), link#364 (the wetland door), link#432 and link#433 (rainbow trout
paused; un-pause still pending for #148), link#415, link#441, link#331, fresh#259, fwapg#25, cred#44.

Visibility: link, fresh, wet, cred, gq and fly are public; the skills repository is private, so nothing here names it
by repository or links it.

### Recurrences

- #136: met again on 2026-11-05 (PR #150), after filing.
- #159: the stall came back after PR #157 (2026-11-06), in a workflow that fetches no tiles.

### CI at the read

Last five runs green; the one `cancelled` is a Pages run superseded by the next push.

## Placement, issue by issue

| issue | placed | why |
|---|---|---|
| #1 | move 7, batch 12 | a report-repo deliverable; gate asks if still wanted |
| #2 | move 7, batch 12 | #17's SHA in the GeoPackage may make it unnecessary (gate) |
| #3 | closed | superseded by `0154` |
| #4 | move 11, batch 17 | parked 2026-09-04; B3, B4, B6 rewrite `0161`/`0162`, as #15 does |
| #7 | move 7, batch 11 | graduates the parser the regeneration runs through |
| #8 | transferred | the skill lives in the skills repository |
| #10 | move 7, batch 11 | re-fetch PINE through the graduated parser |
| #11 | single | a one-off read of 24 reports |
| #13 | move 10, batch 16 | the single-library decision #14 depends on |
| #14 | move 10, batch 16 | store keys; same rebuild as #16 |
| #15 | move 11, batch 17 | rewrites `0161`/`0162` with #4 |
| #16 | move 10, batch 16 | one store or two is the keying decision |
| #17 | move 7, batch 12 | rolls up batch 11's outputs |
| #20 | move 3, batch 5 | Zotero item + evidence rows + store, in the Zotero sitting |
| #23 | move 6, batch 10 | the downstream-end check is #137's oracle; scope cut at the gate |
| #31 | move 5, batch 8 | `life_history_timing.csv` |
| #33 | single | Tracks 1–2 done; Track 3 waits on the Williston redd layer |
| #34 | move 7, batch 11 | `0250` fix, regenerated with batch 11 |
| #42 | move 5, batch 9 | window means #105's Phase 1 needs |
| #48 | closed | done in PR #50 |
| #51 | single | its own analysis (FDIS lengths × temperature series) |
| #63 | move 8, batch 13 | adds a column to the published tables: only a promotion may |
| #64 | move 4, batch 7 | one template with #90's skeleton |
| #68 | closed | done in 9f4b21bd |
| #70 | move 9, batch 15 | waits on fresh#257 |
| #71 | move 9, batch 15 | waits on floodplain data and fresh#257 |
| #72 | closed | done in 9f4b21bd |
| #76 | single | reading terms of use; `inst/NOTICE.md` |
| #77 | move 4, batch 6 | `R/compare_map.R` with #81's example maps |
| #80 | closed | superseded by #141 and #73; open item moves to #139 |
| #81 | move 4, batch 6 | `0330` and the example-map script |
| #85 | track (speed) | |
| #90 | move 4, batch 7 | generated research pages |
| #95 | move 3, batch 5 | statistics store in the Zotero sitting |
| #96 | move 5, batch 8 | timing rows; NuSEDS is its input |
| #101 | track (speed) | |
| #105 | move 5, batch 9 | Phase 1 on #42's window means |
| #107 | move 2, batch 2 | folded into #118 |
| #108 | move 5, batch 8 | NuSEDS fetcher and records table |
| #115 | move 8, batch 13 | stales the method bundle: rides the promotion |
| #118 | move 2, batch 2 | the hub |
| #120 | track (minimal-run) | last task waits on link#460 |
| #126 | move 3, batch 4 | Zotero writes, merge recipe |
| #130 | single | blocked on cred#45 |
| #131 | move 9, batch 14 | waits on link#434, link#400 |
| #132 | move 9, batch 14 | access homework; record rules from link#402 |
| #136 | move 1, batch 1 | recurred |
| #137 | move 6, batch 10 | needs #23's location error |
| #139 | track (baselines) | umbrella |
| #140 | track (baselines) | |
| #142 | move 1, batch 1 | errors every full test run on an empty schema |
| #148 | move 8, batch 13 | promotion-path test; second half waits on link |
| #151 | move 3, batch 4 | Zotero writes; blocks a safe `0270 --collection sturgeon` |
| #156 | move 2, batch 2 | same articles' prose as #118 |
| #159 | move 2, batch 3 | the move's site build tests it |
| #162 | track (provenance) | |
| #165 | track (provenance) | |
| #168 | move 3, batch 4 | key helper first, for the sitting's writes |

58 = 40 batched, 7 in tracks, 5 singles, 5 closed, 1 transferred.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Main's branch protection is not readable with this token (HTTP 403) | the pass lands through a PR anyway |
