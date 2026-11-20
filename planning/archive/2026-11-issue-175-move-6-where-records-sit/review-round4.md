# Code-check round 4: branch 175-backlog-move-6-where-records-sit-the-sit (76b304ff...HEAD, c07d5939)

## Checklist read

- `code-check-python.md`: read in full. The diff has no Python.
- `code-check.md`: the prose of every H3 under `## Mechanisms`, table rows skipped. The ones applied below:
  - "A guard's scope, escape hatches, and remedies": run the remedy for every input; "a byte compare … answers 'same
    build?' rather than 'same content?'".
  - "A proxy is not the property".
  - "A guard that fails toward pass": where the guard sits; the write path.
  - "Written data outlives the fix".
  - "One fact derived twice".
- `code-check-r.md`, by heading:
  - "Regenerated binaries churn git even when nothing changed" (RDS header bytes);
  - "`identical()` on two reader results tests the reader, not the file" (PLACE=FALSE compares contents, which is
    what it means to do);
  - "Under `R CMD check`, tests run from a temp dir against the INSTALLED package" (the test diffs are fixtures in
    tempdirs).
- `code-check-shell.md`, `code-check-spatial.md`: no heading applies. There is no shell code, and the spatial work is
  FWA measures in SQL and R.

Method:
- I read every file the brief names in full, along with round 3's file and the round 3 fix commits (cf1a2a86,
  c07d5939).
- Everything I ran was read-only Rscript over `data/fdis/build/*.rds`, `data/fdis/derived/{fdis_sites,visits_link}.csv`,
  `inst/vignette-data/method.rds`, the evidence ledger, and the committed logs, plus `git show` of earlier log versions.
- I touched no database and no S3, and wrote nothing under the repo except this file.

## Findings

- **[severity: bug]** `data-raw/fdis_downstream_end_check.R:56-59`, with the RUN line `:20-22` and
  `scripts/README.md:357-359`.
  - **What the check does.** Since round 3 it holds `catch.rds` to the ledger's `md5_catch` (`a31fd7bb…`) by file
    md5. The archive never holds `catch.rds`. So the only way to produce it is the remedy the stop message names,
    `PLACE=FALSE 0230`.
  - **Where the bytes come from.** An RDS written by `saveRDS()` carries the writing R's version in its serialization
    header. Here `serialize(1, NULL)[1:14]` = `58 0a 00 00 00 03 00 04 05 02 …`, which is R 4.5.2. The ledger's md5 is
    a file written under 4.5.2: the current `catch.rds` (PLACE=FALSE, 22:27) is `a31fd7bb…`, the same.
  - **What happens on another R.** Under any other R version, or a package set that changes the object's bytes,
    `PLACE=FALSE` writes a `catch.rds` with the same contents but another md5. The check then stops: "rebuild it with
    PLACE=FALSE".
  - **Why the remedy loops.** Rerunning it now finds `catch.rds` present with equal contents and keeps it (round 3's
    fix, `0230:514-523`). The check stops again. No input to the remedy ever passes, so the check cannot run on a
    restored build anywhere but under the R that wrote the published build.
  - **This is round 3's finding one axis over.**
    - Round 3 found a byte identity, md5, asked of a file that is reproducible only by content (fish.rds), and fixed
      the writer to compare contents.
    - The same fix's new guard, in the downstream check, asks bytes of `catch.rds` again.
  - **Suggested fix.** Either:
    - hold `catch.rds` by content. For example, compare an md5 of its contents (`write.csv` to a tempfile, or
      `serialize()` with the header stripped) against a content md5 recorded beside the ledger's. Or check that the
      keys of `catch.rds` are a subset of `sites.rds`'s site visits, and accept a non-matching md5 with a logged
      warning when PLACE=FALSE produced it;
    - or narrow the RUN line and the message to "on the R that wrote the build (the RDS header carries its version)",
      as CLAUDE.md:59 already does for `fish.rds`.
  - **Inside a round's fix:** yes, round 3's (the `md5_catch` gate, together with PLACE=FALSE keeping equal files).
  - **Rule:** `code-check.md` "A guard's scope, escape hatches, and remedies" ("run the remedy yourself, for every
    input the clause can receive"; "A byte compare … answers 'same build?' rather than 'same content?'"); `code-check.md`
    "A proxy is not the property".

- **[severity: fragile]** `scripts/0240-fdis-evidence.R:158` and `:175-176` (the remedy "run PLACE=FALSE
  scripts/0230, then this").
  - **Why the remedy is advised on a restored build.** A restored build holds `fdis_sites.csv`. It is in the
    evidence MANIFEST, and `inst/vignette-data/method.rds`'s `meta$md5_local` pins it at `2de46c60…`. To get the pass
    CSVs, 0240 tells the reader to rerun 0240 whole after PLACE=FALSE. `scripts/README.md:41-42` says the same.
  - **What the rerun does.** It rewrites `fdis_sites.csv` at `:158` with no comparison, before it looks at the passes
    at all.
  - **What the bytes depend on.** They come from `readr::write_csv`'s formatting and from `fwa_basin`, read from
    whatever database the PG* variables reach (`:67-74`). Neither is held to the build.
  - **Where it reproduces.** Here it reproduced: the file's mtime is 21:11 and its md5 is still `2de46c60…`.
  - **Elsewhere.** Where either input moves, the restored, pinned table is overwritten silently:
    - `test-vignette-data.R` then fails on `method.rds`'s pin;
    - a later `0336 PULL=TRUE` refuses ("here with another md5"), so the restore has to be moved aside;
    - an `0336` archive stores the table under a new evidence id. `.knw_archive_sites_check()` passes, because it
      holds only the columns shared with `sites.rds`.
  - **The same mechanism as round 3.** Round 3's keep-if-equal rule was applied to 0230's RDS outputs, and the next
    step of the same remedy rewrites another pinned file. The `:168` stop (round 3's fix) also leaves the rewritten
    `fdis_sites.csv` behind. That one is harmless when the bytes reproduce.
  - **Suggested fix.** When `fdis_sites.csv` exists, write the new table to a tempfile and keep the old file if the
    md5s match, refusing (or warning loudly) if they differ. Alternatively, let the passes step run on its own, so that
    a restored build needs only the pass CSVs written.
  - **Inside a round's fix:** a sibling of round 3's fix to finding 1. Round 3's enumeration listed this row
    ("rewrites the restored fdis_sites.csv (reproduced here)") without a finding.
  - **Rule:** `code-check.md` "A guard's scope, escape hatches, and remedies" (run the remedy for every input);
    "Written data outlives the fix".

- **[severity: fragile]** `research/discharge_resolution.md:85`: "The smaller the minimum, the more a point flow would
  move".
  - **The numbers on round 3's population (37,506).** The two middle keys are out of order:
    - ST (0.50 m³/s): 0.13 % at the point, 0.27 % at the middle;
    - CH (0.75 m³/s): 0.15 % at the point, 0.28 % at the middle.
  - **Where the order broke.** On the previous population (41,983, `git show
    a4be5e94:scripts/logs/flow/20261119_segment_flow_resolution_check.txt`) the sequence was monotone: CH 0.14, ST
    0.17, BT 0.26, CO 1.29, WCT 2.26. Round 3's repopulation broke it and the sentence was kept.
  - **Effect.** The tendency holds across the range (0.13–0.21 % for the three large minima against 1.2–2.1 % for
    CO and WCT). The literal comparative does not. Write "the small minima (CO, WCT) move far more than the large
    ones", or similar.
  - **Inside a round's fix:** yes, round 3's. The numbers changed and the sentence did not.
  - **Rule:** `agent-operations.md` §3 "Documents that share an ancestor corroborate nothing" (walk the per-member
    evidence before writing the quantifier); `code-check.md` "A guard's scope, escape hatches, and remedies"
    (re-measure after a fix: "Write the numbers last").

- **[severity: fragile, minor]** `research/discharge_resolution.md:55-57`: "over the 19,349 visits of the placed
  one-to-one records a median 100 m, 200 m at the upper quartile and 800 m at the 90th percentile".
  - **What the log counts.** The quantiles come from `stats::quantile(..., na.rm = TRUE)` (`fdis_downstream_end_check.R:157-159`)
    over the 17,550 visits with a fished length. The log shows `missing 1799`.
  - **What the sentence says.** It names the 19,349. `research/fdis_export.md:258-260` states the same figures and
    names the 1,799 without a length; this sentence drops them.
  - **Effect.** It is the `na.rm` population class round 3 corrected elsewhere in this file. It does not move the
    figures' meaning much.
  - **Inside a round's fix:** a sibling of round 3's population fixes.
  - **Rule:** `code-check.md` "One fact derived twice".

## Round 3's fixes, reviewed

| round 3 finding | fix | verdict |
|---|---|---|
| PLACE=FALSE overwrote restored fish.rds; "byte-identical" only under one R | `0230:509-528` compare contents (`identical(readRDS(f), x)`), write absent, keep equal, refuse differing before any write; CLAUDE.md:59, 310-316 qualified | holds for 0230's files. Two notes. (1) The downstream check's new md5 gate on `catch.rds` reintroduces the byte identity (finding 1). (2) Not a finding: `identical()` also refuses where a different dplyr or tibble builds an attribute differently. The refusal then writes nothing (not even `catch.rds`) and says "another build's?". It fails closed, with a misleading cause. |
| 0240's mismatch stop left stale pass CSVs | `0240:167-170` unlinks both CSVs, then stops | holds. 0299 refuses on the missing inputs (`0299:177`). `fdis_sites.csv` was already rewritten at `:158` (folded into finding 2). |
| downstream RUN line named the wrong missing file | `:20-22` names PULL for sites.rds and fdis_sites.csv, PLACE=FALSE for catch.rds | the sequence is right; the gate it feeds loops on another R (finding 1) |
| catch.rds read unchecked | `:56-59` md5 against `md5_catch` | catches a wrong build. The proxy (bytes) is narrower than the property (contents) (finding 1). |
| Q2/Q3 shares over a narrower population | `segment_flow_resolution_check.R:187-190` one `cmp` mask for every column; `:208-213` log the population and the 59 % | holds. `fall_segment` is not in `cmp` and is summarised with `na.rm`. By construction it is non-NA wherever `q_point` is: `a_seg_top` lies in the same reach as `a_seg_bot`, which `q_point` needs. Not verifiable without the database; not a finding. |
| "every placed visit" | `:99` "the published visit table (the visits that passed the evidence build's quality filter)" | holds |
| "a ninth" named no row | `:70-71` "On single-line streams" | holds (2.64 / 23 = 1/8.7) |
| 57 % with no producer | log line 64 (0.593 over the 28,001 single-line `cmp` visits); `:87-88` "59 % of those visits on single-line streams" | holds; producer and population match |
| passes figures with no log | `scripts/logs/fdis/20261119_fdis_load_passes.txt` cited at `fdis_export.md:60` | holds; every figure is on log line 3 |
| "19,349 matched visits" | "the 19,349 visits of the placed one-to-one records" in both files | matches the log's `s_vis` (visits of `s`, the 24,088 placed records). The `na.rm` part remains (finding 4). |
| collection_only not named | `fdis_export.md:246-250` names 34,372 + 1,163 + 400 = 35,935 | holds |
| "17 MB each" | `scripts/README.md:353` "about 19 and 16 MB" | csv 19,421,988 B (19.4 MB), gpkg 16,998,400 B (17.0 MB, 16.2 MiB). The two use different units, but "about" covers both. Not a finding. |

## Enumeration (a): every quantitative claim, its producer and its population

Sources:
- FL = `scripts/logs/flow/20261119_segment_flow_resolution_check.txt` (line numbers as in the file);
- DE = `scripts/logs/fdis/20261119_fdis_downstream_end_check.txt`;
- PL = `scripts/logs/fdis/20261119_fdis_load_passes.txt`;
- VL = `data/fdis/derived/visits_link.csv` (`c746c582…`).

"OK" means the number matches and the population named is the population counted.

### research/discharge_resolution.md

| line | claim | producer | population named / counted | verdict |
|---|---|---|---|---|
| 3-8 | log paths, link run, `c746c582…`, flow load 2026-10-24 | FL:1-3 | same | OK |
| 14-15 | single-line 0.1–1 m³/s: top typically within 1 % of bottom | FL:26 fall_p50 0.0085 | segments | OK |
| 16-17 | point or middle flips 0.13–2.8 % | FL:69-79 min 0.0013 (ST point), max 0.0284 (WCT middle) | the 37,506 `cmp` | OK |
| 17 | other source 2.4–7.9 % "of the same visits" | FL:75-79 0.0241–0.0789 | the 37,506, same mask (`ok <- v$cmp`) | OK |
| 18 | "three to twenty times as many for each key" | ratios other/middle 2.78 (WCT) … other/point 20.2 (ST) | same | OK |
| 26 | BULK's 10,387 mouths | #137 | not re-derived (accepted in round 3) | — |
| 34 | side channels 247,517 | FL:6, 4,907,441 − 4,659,924 | segments | OK |
| 34-36 | 4,659,924 own-line; 4,425,507 measured | FL:6; sum of Q1's 20 rows (round 3 summed it) | segments | OK |
| 40-44 | Q1 table, 5 rows × 4 values | FL:25-27, 11, 13, 46-48, 32-34 | segments by edges × class | OK, every value checked |
| 47-48 | under 0.1 is below every minimum but WCT's 0.03 | `data/thresholds.csv` (CO 0.10 the next lowest) | — | OK |
| 53-54 | 58 % same UTM; of the rest on the visit's stream, 81 % within 5 m | DE (0.582; 7,579 / 9,375 = 0.808) | one-to-one records; the rest on the visit's line | OK |
| 55-57 | 19,349 visits; median 100, p75 200, p90 800 | DE fished-length block | **quantiles over 17,550 with a length (`na.rm`), named over 19,349** | finding 4 |
| 61 | 45,503 own-flow; 26 parent | FL:52; VL `flow_from` 45,503 / 26 (counted) | same | OK |
| 61-63 | 37,506; 39,321 of the 43,843 | FL:63 | same | OK |
| 67 | single-line: 28,001; 11 % (100 %); 2.6 % (34 %); 27 %; ×1.33 (×2.8) | FL:58, 62 | `cmp` single-line (segment fall `na.rm`, non-NA by construction) | OK |
| 68 | double-line: 8,852; 0.01 % (0.9 %); under 0.01 % (0.8 %); 4.2 %; ×1.10 (×1.6) | FL:56, 60 | `cmp` double-line | OK |
| 70 | gauge error 23 % | `research/modelled_discharge.md` (round 3) | — | OK |
| 70-71 | single-line span gain a ninth of that | 2.64 / 23 = 0.115 | single-line row, named | OK |
| 71-72 | sources part by more than the span on both edges, at p50 and p90 | 33 % > 2.6 %, 184 % > 34 %; 10 % > 0.00 %, 60 % > 0.78 % | both rows | OK |
| 74-75 | over the same 37,506 | FL:69-73 `visits` | same | OK |
| 79-83 | Q3 table, 5 keys × 5 values | FL:69-79 | `cmp` | OK, all 25 checked |
| 85 | "the smaller the minimum, the more a point flow would move" | FL: ST 0.0013 / 0.0027 < CH 0.0015 / 0.0028 | **not monotone for ST against CH** | finding 3 |
| 86 | WCT: a quarter to a third of the source choice | 0.0207 / 0.0789 = 0.26; 0.0284 / 0.0789 = 0.36 | same | OK (roughly) |
| 87 | segment fall median 11 % single-line | FL:58 0.1061 | `cmp` single-line | OK |
| 87-88 | 59 % of those single-line visits on segments under 0.1 | FL:64 0.593 | `cmp` single-line (28,001) | OK |
| 99-101 | counts over the published visit table | VL is the quality-kept table; the narrower 37,506 is stated at 61-63 | — | OK |
| 103 | 1 m³/s and up: single-line 0.13 %, double-line 0.04 % | FL:28, 13 (1–10; ≥ 10 lower) | segments | OK |

### research/fdis_export.md (changed sections)

| line | claim | producer | population | verdict |
|---|---|---|---|---|
| 57-60 | passes kept, by method then haul; files | `knw_fdis_passes()`, `0230:453`, `0240:171-172`, `0299:113-121` | — | OK |
| 60-61 | 61,388 passes, 73,567 rows | PL:3 | kept visits' passes | OK |
| 61-62 | 35,642 fish, 25,279 nfc, 467 no record | PL:3 | same | OK |
| 63 | every kept visit's passes number n_pass and sum to time and area | `0230:460-464` stops (all.equal, relative 1.5e-8) | every kept visit | OK (guarded) |
| 63-64 | 885 with no pass row, KEY with no visits row | PL:3; round 3 traced every one | same | OK |
| 64-66 | 161 sum above n_caught | PL:3 (below 0) | same | OK |
| 243-244 | 375,962 records, newest 2026-10-10 | DE:3 | same | OK |
| 246 | 24,163 of 60,098 (40.2 %) | DE:19 | deduped records | OK |
| 246-250 | rest: 34,372 unmatched (508 repeat copies), 1,163 collection_only, 400 many | DE:18 and the match table (sums 35,935) | same | OK |
| 251 | 58.2 % (14,056) same UTM | DE one-to-one block | one-to-one | OK |
| 252-254 | 13,218 on the line, all within 5 m; 795 another line; 43 unplaced | DE line block; "at the downstream end TRUE 13218 1.000" | same-UTM records | OK |
| 254-255 | rest: median 13 m, p90 80 m | DE apart_p50 13, p90 79.6 (`!same_utm`, same zone) | the rest | OK |
| 255-256 | on the line 81 / 9 / 6 / 2 / 2 % | DE where block FALSE rows (n 9,375) | the rest on the visit's line | OK |
| 258-260 | 19,349 visits, median 100, quartiles 38 and 200, p90 800, 1,799 no length; 338 capped | DE fished-length block; DE "338 with a span capped" | visits of the placed one-to-one records (`s_vis`); quantiles over those with a length, which the 1,799 states | OK |

### research/README.md (two changed rows)

| row | claim | producer | verdict |
|---|---|---|---|
| fdis_export | coverage words only | — | OK |
| discharge_resolution | under 1 % (single-line 0.1–1) | FL:26 | OK |
| discharge_resolution | span median 2.6 % on single-line | FL:58 | OK |
| discharge_resolution | sources ×1.33, gauge 23 % | FL:62; modelled_discharge.md | OK, same `cmp` population |
| discharge_resolution | 0.13–2.8 % against 2.4–7.9 % | FL:69-79 | OK, one population |

### CLAUDE.md (changed lines)

| line | claim | producer | verdict |
|---|---|---|---|
| 57-59 | PULL restores fish.rds, held to the run's ledger since #214 | `R/archive.R:25-31, 236-241`; ledger `md5_fish 8cf27351…` = file here | OK |
| 59-60 | pre-#214: PLACE=FALSE rebuilds fish.rds, byte-identical under the R that wrote the build | RDS header carries R version (`58 0a 00 00 00 03 00 04 05 02`) | OK, now qualified |
| 310-314 | PLACE=FALSE writes absent, keeps equal (bytes stay the build's), refuses differing | `0230:514-528` | OK |
| 314-315 | 245 of 51,587 placed differently on 2026-11-20 | round 3 (`findings.md`; sites.rds 51,587 rows) | OK |

### scripts/README.md (changed lines)

| line | claim | verdict |
|---|---|---|
| 39-40 | PLACE=FALSE writes catch, fish, passes and stops, no database: the remedy on a restored build | OK (it keeps present equal files rather than writing them) |
| 41-42 | 0240 writes fdis_sites.csv and the pass CSVs | OK (`0240:158, 171-172`); rewriting fdis_sites.csv is finding 2 |
| 139 | PULL restores fish.rds from #214 | OK |
| 342-344 | passes kept, in v3 | OK |
| 353 | fdis_sites.{csv,gpkg} about 19 and 16 MB | 19.4 MB and 17.0 MB (16.2 MiB): mixed units within "about"; not a finding |
| 357-359 | both checks on the published build: PULL, then PLACE=FALSE adds catch.rds | the flow check: OK (visits_link only). The downstream check: the gate loops on another R (finding 1) |

A note outside the brief's list: `data-raw/segment_flow_resolution_check.R:26` names `fdis_sites.csv` as an input held
to `evidence_md5`. The script reads only `visits_link.csv`. The comment is harmless.

## Enumeration (b): writes and stops in 0230 and 0240, and every run instruction

A restored build holds `sites.rds`, `fish.rds`, `reconcile.csv`, `fdis_sites.csv` and the visit tables. It does not
hold `catch.rds` or the passes.

### scripts/0230-fdis-load.R, in order

| line | action | guarded by | safe on a restored build? |
|---|---|---|---|
| 76 | stop: PLACE not TRUE / FALSE | — | yes (before anything) |
| 104-130 | export-cache sync (aws), manifest last; stops 114, 120, 125, 128 | the manifest is absent | writes `data/fdis/<export>` only; yes |
| 136 | stop: md5 against MANIFEST.md5 | the sync | yes |
| 138 | dir.create build | 136 | yes (exists) |
| 153 | stopifnot unique KEY | 136 | yes |
| 453 | `knw_fdis_passes()` stops (duplicate KEY, unclassified code) | — | yes |
| 460, 463 | stop: passes against n_pass, time, area | 453 | yes |
| 484-507 | stops: codes, fish rows, passes, repeat copies, habitat, measured, counted, catch status | everything above | yes |
| 517-522 | PLACE=FALSE: compare every present output by content; stop if any differs, nothing written | 76-507 | yes (refuses before any write) |
| 523 | PLACE=FALSE: saveRDS the absent ones (catch, passes, pass_catch on a restored build; fish too before #214) | 517-522 | yes; fish.rds kept. The md5 of what it writes matches the ledger only under the same R, which matters for catch.rds (finding 1) |
| 527 | quit status 0 | 523 | — |
| 531-537 | stops: fresh version; database unreachable | 507 | yes (before any write) |
| 597, 631-636 | stopifnot / stops on placement integrity | the snap | yes |
| 672-678 | full run: reconcile.csv, data/fdis_repeat_surveys.csv (tracked), sites.rds, catch.rds, fish.rds, passes.rds, pass_catch.rds | every stop above | no: rewrites a restored sites.rds and reconcile.csv; accepted, documented, #246 |

### scripts/0240-fdis-evidence.R, in order

| line | action | guarded by | safe on a restored build? |
|---|---|---|---|
| 45-47 | readRDS sites, catch, fish | — | stops at 46 without catch.rds (before any write); yes |
| 67-73 | database read (fwa_basin) | — | read only; stops at connect if unreachable, before any write |
| 92 | write data/fdis_maturity_check.csv (tracked) | 45-47 | from fish, sites, catch; a change shows in git |
| 157-158 | **write fdis_sites.csv** | 45-73 only | **no**: overwrites the restored, md5-pinned table with no comparison (finding 2) |
| 164-170 | passes present and not the sites' passes: unlink the pass CSVs, stop | 158 | removes stale CSVs (round 3's fix); `fdis_sites.csv` already rewritten |
| 171-172 | write fdis_passes.csv, fdis_pass_catch.csv | 167 | yes |
| 174-176 | passes absent: unlink the CSVs, message | — | yes |
| 182 | st_write fdis_sites.gpkg (delete_dsn) | 158 | yes (not pinned) |
| 194, 232 | write data/fdis_evidence.csv, data/fdis_summary_ch_bt.csv (tracked) | 182 | a change shows in git |

### Every place a doc tells a reader to run 0230, 0240 or 0336

| where | instruction | safe on a restored build? |
|---|---|---|
| CLAUDE.md:57-59 | PULL=TRUE restores the evidence, fish.rds among it | yes (md5-checked; refuses over differing files) |
| CLAUDE.md:59-60 | a pre-#214 build: PLACE=FALSE rebuilds fish.rds (byte-identical under the same R) | yes; the caveat is stated |
| CLAUDE.md:310-316 | PLACE=FALSE keeps equal, refuses differing; restore placement with PULL, never 0230 in full | yes |
| R/archive.R:21-23 | a pre-#214 restore rebuilds fish.rds with PLACE=FALSE | yes where absent; the same-R caveat is not repeated here (CLAUDE.md carries it) |
| scripts/0230:62-66 | PLACE=FALSE, the remedy for a restored build | yes |
| scripts/0240:159-162 (comment) | PLACE=FALSE rebuilds the passes, leaves sites.rds alone | yes |
| scripts/0240:169 | stop: "rerun PLACE=FALSE scripts/0230" | yes for the passes. PLACE=FALSE refuses where passes.rds differs, and the reader must move it aside |
| scripts/0240:175-176 | "run PLACE=FALSE scripts/0230, then this" | PLACE=FALSE yes; **"then this" rewrites the pinned fdis_sites.csv (finding 2)**. Unreachable on a bare restore: 0240 stops at 46 first |
| scripts/0336:29-31 | PULL restores fish.rds from #214; PLACE=FALSE for earlier | yes |
| scripts/README.md:39-40 | PLACE=FALSE, the remedy on a restored build | yes |
| scripts/README.md:41-42 | 0240 writes fdis_sites.csv and the pass CSVs | as 0240:175 (finding 2) |
| scripts/README.md:139 | PULL restores fish.rds | yes |
| scripts/README.md:357-359 | PULL, then PLACE=FALSE, then the two checks | flow check yes; downstream check **only under the R that wrote the build** (finding 1) |
| data-raw/fdis_downstream_end_check.R:20-22 | PULL restores sites.rds and fdis_sites.csv; PLACE=FALSE adds catch.rds | as above (finding 1) |
| data-raw/fdis_downstream_end_check.R:53-54 | stop: restore sites.rds with PULL | yes (PULL refuses over a differing file and says to move it aside) |
| data-raw/fdis_downstream_end_check.R:57-58 | stop: "rebuild it with PLACE=FALSE" | **no on another R: PLACE=FALSE keeps the equal-content file and the check stops again** (finding 1) |
| data-raw/fdis_downstream_end_check.R:60 via `R/archive.R:43` | stop: "rerun scripts/0240" | rewrites fdis_sites.csv from sites.rds; the right fix where the table is wrong |
| data-raw/segment_flow_resolution_check.R:31, 61-62 | PULL, then point EVIDENCE_DIR at it | yes (visits_link.csv only, md5-checked) |

### Checked and found correct

- **PLACE=FALSE refuses before it writes.** `differ` is computed over every present file before the single write loop,
  so a refusal leaves the directory as it was.
- **The PLACE=FALSE run that produced PL.** It wrote catch, passes and pass_catch and kept fish.rds. The current
  `catch.rds` md5 equals the ledger's `md5_catch`, and `fish.rds` equals `md5_fish`, on this machine (R 4.5.2).
- **0240's stop at 167-170.** It removes both CSVs before stopping. 0299 refuses a v3 on the missing inputs.
- **The flow check's single mask.** `ok <- v$cmp` in Q3, and the Q2 summary is `filter(cmp)`. The logged 37,506
  equals every Q3 `visits` and the sum of the three Q2 rows (28,001 + 8,852 + 653).
- **The 59 %.** It is computed over `cmp` single-line visits, the population of the 11 % median it explains.
