# Code-check round 3: branch 175-backlog-move-6-where-records-sit-the-sit (76b304ff...HEAD, a4be5e94)

## Checklist read

- `code-check-python.md`: read in full. The diff has no Python.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (table rows skipped). The ones applied below are "A guard
  that fails toward pass" (where the guard sits; the write path), "A guard's scope, escape hatches, and remedies"
  (run the remedy for every input), "Written data outlives the fix", "One fact derived twice" and "Verification that
  reads its own output".
- `code-check-r.md`, by heading: "Regenerated binaries churn git even when nothing changed" (RDS bytes) and
  "`identical()` on two reader results tests the reader, not the file". The rest name tools or shapes this diff does
  not use.
- `code-check-shell.md`, `code-check-spatial.md`: no headings apply. There is no shell code, and the spatial work is
  FWA measures in SQL and R.

Method: I read every changed file in full. Everything I ran was read-only: Rscript over `data/fdis/build/*.rds`,
`data/fdis/derived/visits_link.csv`, the export cache `data/fdis/2020-11-16/*.csv`, the evidence ledgers and
`data/archive_index.csv`. I connected to no database and no S3, and wrote nothing under the repo except this file.

## Findings

- **[severity: fragile]** `scripts/0230-fdis-load.R:507-517`, with the remedies at `scripts/0240-fdis-evidence.R:174`,
  `scripts/0240-fdis-evidence.R:168`, `scripts/README.md:39-40`, `CLAUDE.md:59` and `CLAUDE.md:310-312`, and the
  comment at `0230:508`.
  - **What the code does.** `PLACE=FALSE` writes `catch.rds` and `fish.rds` (and the passes) over whatever is already
    in `data/fdis/build`, without comparing first. Since this branch, `0336 PULL=TRUE` restores `fish.rds` into that
    directory, md5-checked.
  - **Where it is advised.** 0240 tells the reader to run `PLACE=FALSE` on every restored build: it prints "run
    PLACE=FALSE scripts/0230, then this", because a restore never carries `passes.rds`.
  - **What the docs claim.** CLAUDE.md says it reproduces `fish.rds` and `catch.rds` "byte for byte" and
    "byte-identically", and the 0230 comment says "byte-identical to the build's".
  - **Why the claim is narrower than stated.** It holds only under the R version that wrote the archived files. An RDS
    written in serialization version 3 carries the writer's R version in its header. Every `data/fdis/build/*.rds`
    here begins `58 0a 00 00 00 03 00 04 05 02`, which is R 4.5.2, and the ledgers' `md5_fish 8cf27351…` is that
    file. A dplyr, tibble or readr release that changes the object's attributes would break it the same way.
  - **What happens on another R.** The routine post-restore step replaces the restored, ledger-matching `fish.rds`
    with one whose md5 is not `md5_fish`:
    - `knw_archive_plan()` then refuses ("fish.rds is not the one … records");
    - `test-vignette-data.R` fails on `method.rds`'s pin of `fish.rds` (`vignette_method.R:556`);
    - a later `PULL=TRUE` refuses ("here with another md5").
  - **Scope of my check.** It reproduced here, where 0230 last wrote at 22:11 local and the md5s match the ledger,
    because this machine runs 4.5.2.
  - **Suggested fix.** Have `PLACE=FALSE` leave an existing `fish.rds` or `catch.rds` alone when its content
    (`readRDS` compared column by column) equals the new one, and refuse when it differs. Or narrow the claim to "the
    same content; the same bytes under the same R".
  - **Inside round 1's fix:** yes. `PLACE=FALSE` is that fix, and the restore of `fish.rds` makes it overwrite
    restored data.
  - **Rule:** `code-check.md` "A guard's scope, escape hatches, and remedies" (run the remedy for every input the
    clause can receive); `code-check-r.md` "Regenerated binaries churn git even when nothing changed".

- **[severity: fragile]** `scripts/0240-fdis-evidence.R:158` and `:163-168`.
  - **What the code does.** 0240 writes the new `fdis_sites.csv` first (`:158`), then checks the passes. When
    `passes.rds` is present but is not the passes of `sites.rds`, it stops (`:168`) without removing the earlier
    `fdis_passes.csv` and `fdis_pass_catch.csv`.
  - **Result.** The directory holds a new site table beside the old passes. That is the mixed state round 1's fix
    removed for the absent-file branch only (`:173`).
  - **Why nothing catches it.** 0299 checks only that the inputs exist (`0299:177`). It has no check that the passes
    are the sites' passes, so a v3 publish after that stop ships them.
  - **Suggested fix.** Unlink the two CSVs before the `setequal` stop, or run the check before any write.
  - **Inside round 1's fix:** yes. It covered one of the two branches that do not write the passes.
  - **Rule:** `code-check.md` "Written data outlives the fix"; "A guard that fails toward pass" (where the guard sits
    / the write path).

- **[severity: fragile]** `data-raw/fdis_downstream_end_check.R:20-21`, and `scripts/README.md:356-358` ("each on a
  restored published build").
  - **The remedy as written.** "PULL=TRUE scripts/0336-archive.R, then rerun 0240 there if fdis_sites.csv is absent."
  - **Why it fails.** A restore always brings back `fdis_sites.csv`, which is in the evidence MANIFEST. It never
    brings back `catch.rds`, which the script reads at `:57`. So the script fails on a restored build, and the remedy
    names the wrong missing file.
  - **Rerunning 0240 fails too.** 0240 reads `catch.rds` itself (`0240:46`).
  - **The working sequence.** `PULL=TRUE`, then `PLACE=FALSE 0230`, with the caveat in the first finding.
  - **Inside a round's fix:** no.
  - **Rule:** `code-check.md` "A guard's scope, escape hatches, and remedies" (a remedy in a message is code the caller
    will run, and nothing checks it).

- **[severity: bug]** `data-raw/fdis_downstream_end_check.R:16-17` against `:47-57`.
  - **The claim.** The header says `data/fdis/build/{sites,catch}.rds` and `fdis_sites.csv` are "held to the
    published run's evidence ledger … and to each other".
  - **What the code holds.** Only `sites.rds`, to `md5_sites`, and `fdis_sites.csv`, to `sites.rds`. `catch.rds` is
    read unchecked.
  - **Why it matters.** The ledger records `md5_catch` (`a31fd7bb…`), and every match class in the log comes from
    `knw_bcfishobs_match(..., catch)`.
  - **How a wrong `catch.rds` gets there.** By this branch's own remedy: `PLACE=FALSE` writes `catch.rds` from the
    current code over any build.
  - **Result.** A `catch.rds` from another build or another code version yields a log, with match rates and
    one-to-one counts, that claims the published build.
  - **Inside a round's fix:** no.
  - **Rule:** `code-check.md` "A guard that fails toward pass" (a comment stating a property is an unexecuted claim).

- **[severity: bug]** `research/discharge_resolution.md:16-18` and `:73-82`, the Q2 table column "the two sources
  differ by" (`:64-67`), and `research/README.md`'s new row ("2.5–8.6 % for the other source").
  - **The two calculations.** Both the other-source shares and the sources factor drop every visit that has no
    routed flow:
    - `flip_other_source = mean(..., na.rm = TRUE)`, where `other` is NA wherever `mad_routed` is
      (`segment_flow_resolution_check.R:207,216`);
    - `sources_factor_*` uses `quantile(na.rm = TRUE)` (`:202-203`).
  - **Size of the gap.** 4,035 of the 45,503 own-flow visits (8.9 %) have no `mad_routed`, measured on the published
    `visits_link.csv`.
  - **What the doc states.** That the other-source shares are "over the 41,983 visits", and that the factors are on
    the 31,671 and 9,417 visits of the Q2 rows.
  - **What the code counts.** Only the visits wet's routed source covers, a geographic subset.
  - **Effect on the numbers.** Counted over the stated 41,983, with no routed flow meaning no change, the shares fall
    by about a tenth (CH 2.5 % → ~2.3 %, WCT 8.6 % → ~7.8 %). The "three to eighteen times" compares numerators over
    different denominators.
  - **Effect on the conclusion.** It stands. The stated population is not the counted one.
  - **Inside a round's fix:** no.
  - **Rule:** `code-check.md` "One fact derived twice" (one column name carrying different populations).

- **[severity: fragile]** `research/discharge_resolution.md:98`: "Counts are over every placed visit."
  - **What is actually counted.** Visits in `visits_link.csv`: 45,529 visits, 45,503 own-flow, and 41,983 with
    areas. That table holds only the quality-kept visits (`knw_fdis_quality()`, via `0310:213-215`): placed, no far
    snap, no ws50 mismatch, a valid date, effort, a known catch.
  - **How far that is from "every placed visit".** The build places 49,928 (`reconcile.csv`, `sites_placed`).
  - **Inside a round's fix:** no.
  - **Rule:** `writing.md` "State each claim by the code's definition".

- **[severity: fragile]** `research/discharge_resolution.md:69-71`: "The flow gathered over a fished span is a ninth of
  that at the median."
  - **Where it holds.** For the single-line row only: 2.6 % against 23 %.
  - **What the sentence says.** It follows a two-row table, names no row, and reads as all 41,952 visits.
  - **Over all visits.** The median is much lower: the 9,417 double-line visits sit at 0.01 %, and single-line visits
    are about 75 % of the set. So "a ninth" is the single-line figure presented as the whole. The error is
    conservative.
  - **Same class as round 2's.** Round 2 found and fixed exactly this in the README row; the research file's sentence
    kept it.
  - **Inside round 2's fix:** yes, a sibling that fix did not reach.
  - **Rule:** `writing.md` "State each claim by the code's definition".

- **[severity: fragile]** Numbers with no committed producer.
  - **The "57 %"** (`research/discharge_resolution.md:86-87`, "57 % of the visits on single-line streams sit on
    segments under 0.1 m³/s").
    - **In no log.** `review-round2.md` says round 2's reviewer computed it, as 57.4 % over all 33,052 own-flow
      single-line visits. I reproduced that: 0.574.
    - **Wrong population for its sentence.** The sentence explains the 11 % median, which is over the 31,671 Q2
      visits. That population is not what was counted (round 2 got 58.3 % with a fished length).
  - **The passes figures** (`research/fdis_export.md:60-64`: 61,388 passes, 73,567 rows, 35,642 / 25,279 / 467, 885,
    161).
    - **No log.** They come only from 0230's console message, and the file's **Produced by** line names no producer
      for them.
    - **Verified.** I re-derived every one from `passes.rds`, `pass_catch.rds`, `catch.rds` and the export cache:
      each matches. The 885 are all catch on a `KEY` with no `visits.csv` row; none of them have a pass row with catch.
  - **Inside a round's fix:** the 57 % was added during round 2's review.
  - **Rule:** `planning.md` "The header is the provenance, in prose" ("Never a number without its producer").

- **[severity: fragile]** `research/fdis_export.md:256-257` and `research/discharge_resolution.md:55-56`: "over the
  19,349 matched visits".
  - **What was counted.** `s_vis` (`fdis_downstream_end_check.R:126,136,150`) is the visits of the 24,088 one-to-one
    records whose visit is placed and whose record and visit both have a blue line. It is not all one-to-one matched
    visits: 24,163 records, 75 of them dropped by that filter. The log's own label ("Fished length of the matched
    visits") carries the same mislabel.
  - **Effect.** Small: at most 75 visits, and a fished length does not depend on placement.
  - **Why it is still a finding.** It is the population-naming class round 2 fixed here.
  - **Inside round 2's fix:** yes. Round 2 made the figure per visit, and its label names the parent set.
  - **Rule:** `code-check.md` "One fact derived twice".

- **[severity: fragile]** `research/fdis_export.md:245-248`.
  - **What it says.** "Most of the rest (34,372) name a collection no kept visit holds …; a few match several visits
    of one collection on one date."
  - **What it leaves out.** The rest is 35,935: 34,372 `unmatched`, 400 `many` and 1,163 `collection_only` (the
    collection is held but no visit matches species and date). The 1,163 are not named, so the sentence implies
    the rest is the unmatched records plus a few `many`.
  - **Inside a round's fix:** a sibling of round 2's "incomplete list of reasons for unmatched records".
  - **Rule:** none.

- **[severity: fragile]** `scripts/README.md:353`: "`fdis_sites.{csv,gpkg}` (17 MB each, ignored)".
  - **The sizes.** The csv is 19,421,988 bytes (19.4 MB) and the gpkg 17.0 MB.
  - **Why it counts as this branch's.** The text predates the branch, but the line is in the diff (re-wrapped).
  - **Inside a round's fix:** no.
  - **Rule:** none.

## Mechanisms

**(a) The sentence names the population the reader thinks about. The script counts the population its filters
leave. Nothing ties the two.**

Every instance above, and in rounds 1 and 2, has the same shape. The script narrows the rows silently:
- an `na.rm = TRUE` in a mean or quantile;
- a `filter(!flag_not_placed, !is.na(blue_line_key))`;
- `visits_link` being the quality-kept table;
- one row of a two-row table.

The log then prints a label or a `visits` column naming the parent set. For Q3, `visits = sum(ok)` is printed beside
a mean whose denominator is narrower for one of its three columns. Fished length is labelled "matched visits" over
placed ones. The write-up copies the label.

So the log's denominator column and the mean's real rows are **two lists that agree for most columns and differ for
one**. Reading the log cannot show it. Only reading each statistic's filter against its label can.

The mechanism reaches every quantitative sentence over a filtered table, so Enumeration (a) walks each one to its
filter.

**(b) The remedies and the second path (`PLACE=FALSE`, 0240's stop) were written against what a restored build is
believed to hold. They do not compare with what is actually there before writing.**

- **Two lists that disagree.** The archived file set is 7 files: `fish.rds` yes, `catch.rds` no, passes no. The files
  the downstream steps need are a different list, and the remedies were written from memory of the second.
  - The downstream check's RUN line names `fdis_sites.csv`, which is always restored, rather than `catch.rds`, which
    never is.
  - The 0240 remedy rebuilds `catch.rds` but also overwrites the restored `fish.rds`.
- **"Byte-identical" is an unexecuted invariant.** It was measured on one machine, and it is part of the reason the
  overwrite is thought safe. The RDS header makes it a property of the R version, not of the code.
- **The non-default exits are guarded less strictly than the default exit.** 0240's absent-file branch cleans up. Its
  mismatch branch, which stops, does not.
- **Not this branch's.** 0230's default full run still rewrites a restored `sites.rds` with no guard. CLAUDE.md
  forbids it in prose only, and the `PLACE` gate refuses only the misspellings.

## Enumeration (a): every quantitative claim, its source and its population

Sources: FL = `scripts/logs/flow/20261119_segment_flow_resolution_check.txt`; DE =
`scripts/logs/fdis/20261119_fdis_downstream_end_check.txt`; VL = `data/fdis/derived/visits_link.csv` (md5 c746c582…);
BR = `data/fdis/build/*.rds`. "OK" means the number matches and the population named is the population counted.

### research/discharge_resolution.md

| line | claim | source | population named / counted | verdict |
|---|---|---|---|---|
| 5 | visits_link `c746c582…`, link run `20261102_203300-60ab009d`, flow load 2026-10-24 | FL:2-3 | same | OK |
| 14-15 | single-line 0.1–1 m³/s: top within 1 % of bottom (typically) | FL Q1 single 0.1-1, p50 0.0085 | segments, same | OK |
| 16-17 | class change at point / span middle 0.14–3.1 % | FL Q3 (0.0014 to 0.0309) | over the 41,983 `ok` visits, same | OK |
| 17 | other source 2.5–8.6 % | FL Q3 flip_other_source | **named: the 41,983; counted: those with both sources (`na.rm`, 4,035/45,503 own-flow lack routed)** | finding |
| 18 | "three to eighteen times" | ratios 2.8–18.1 | numerators over different denominators | finding (same) |
| 26 | none of BULK's 10,387 tributary mouths mid-segment | #137 (issue), not in either log | cited to #137 | not re-derived here |
| 34 | side channels 247,517 | FL:6, 4,907,441 − 4,659,924 | same | OK |
| 35 | 4,659,924 own-line, 4,425,507 measured | FL:6; the sum of FL Q1's 20 rows = 4,425,507 (summed here) | same | OK |
| 40-44 | Q1 table (5 rows: counts, p50, p90, over 10 %) | FL Q1 rows | segments by edges × class | OK, all 15 values checked |
| 47-48 | under 0.1 is below every minimum but WCT's 0.03 | `data/thresholds.csv` rear_mad_min: CH 0.75, ST 0.5, BT 0.35, CO 0.1, WCT 0.03 | same | OK |
| 48 | lakes and wetlands behave alike by class | FL Q1 lake rows (0.69 % vs 0.85 % at 0.1–1) | qualitative | OK |
| 53-54 | 58 % carry the visit's UTM; 81 % within 5 m | DE (0.582; 7579/9375 = 0.808) | one-to-one records; the rest on the visit's line | OK |
| 55-56 | 19,349 matched visits, median 100, p75 200, p90 800 | DE fished-length block | **visits of placed one-to-one records, both on a line (`s_vis`), lengths over 17,550 non-NA** | finding (minor) |
| 61 | 45,503 own-flow, 26 parent | FL:52; VL `flow_from` (45,503 / 26, counted here) | same | OK |
| 61-62 | 41,952 with an area at both ends of a span | FL Q2: 9,417 + 864 + 31,671 | same (`!is.na(fall_span)`) | OK |
| 66-67 | Q2 rows: 31,671 / 9,417; segment fall 11 % (100 %), 0.02 % (0.9 %); span 2.6 % (33 %), 0.01 % (1.0 %); over 10 % 27 %, 4.6 % | FL Q2 | same rows; the 864 "other" visits not shown (the table names two rows only) | OK |
| 66-67 | sources ×1.34 (×3.4), ×1.10 (×1.7) | FL Q2 sources_factor | **counted over the visits with both sources (`na.rm`)** | finding (same as 17) |
| 69 | wet off its gauges by 23 % | `research/modelled_discharge.md:44` ("23.0 % for `pick`") | same | OK |
| 70 | span gain "a ninth" of that at the median | 2.6 / 23 = 1/8.9, single-line row | **named: all visits; counted: the single-line row** | finding |
| 70-71 | sources part by more than the span, at p50 and p90 | FL Q2, both rows (34 % > 2.6 %, 240 % > 33 %; 10 % > 0.01 %, 70 % > 1 %) | both rows | OK |
| 73-74 | over the 41,983 visits | FL Q3 `visits` | same for the point and middle columns | OK; the other-source column, see 17 |
| 78-82 | Q3 table: minimum, within ×2, point, middle, other | FL Q3 (all 25 values checked) | as above | OK except the other column |
| 85 | WCT: a quarter to a third of the source choice | 2.26 / 8.61 = 0.26, 3.09 / 8.61 = 0.36 | the other column's denominator as above | OK (roughly) |
| 86 | segment fall median 11 % on single-line | FL Q2 0.1082 | the 31,671 | OK |
| 86-87 | 57 % of single-line visits under 0.1 m³/s | in no log; round 2's reviewer; VL: 0.574 over 33,052 own-flow single-line (reproduced here) | **in no log; named beside the 31,671's median, counted over 33,052** | finding |
| 98 | counts over every placed visit | VL is quality-kept (45,529) vs 49,928 placed (`reconcile.csv`) | **named: placed; counted: quality-kept** | finding |
| 101 | 1 m³/s and up: single-line 0.13 %, double-line 0.04 % | FL Q1 1–10 rows (≥10 lower) | segments | OK |

### research/fdis_export.md (changed sections)

| line | claim | source | population | verdict |
|---|---|---|---|---|
| 60 | 61,388 passes, 73,567 pass × species rows | BR `passes.rds`, `pass_catch.rds` (counted here) | kept visits' passes | OK; **in no log** (finding) |
| 61 | 35,642 fish, 25,279 nfc, 467 no record | BR `table(pass_status)` | same | OK; in no log |
| 62 | passes number n_pass, sum to time and area | 0230:459-462 stops; `sum(n_pass)` = 61,388 | every kept visit | OK (guarded) |
| 63 | 885 visit × species with no pass row, all from a KEY with no visits row | BR plus export cache: 885, and 0 of them have a pass row carrying catch | same | OK |
| 64 | 161 sum above n_caught, from per-pass max | BR: above 161, below 0 | same | OK |
| 242-243 | 375,962 records, newest 2026-10-10 | DE:3 | same | OK |
| 245 | 24,163 of 60,098 (40.2 %) | DE:19 | records, deduped | OK |
| 246-248 | rest: 34,372 unmatched, 508 dropped copies, "a few" many | DE:18 and its table (many 400, collection_only 1,163) | **the rest is 35,935; collection_only 1,163 not named** | finding (minor) |
| 249 | 58.2 % (14,056) same UTM | DE one-to-one block | one-to-one records | OK |
| 250-251 | 13,218 on the line, all within 5 m; 795 another line; 43 unplaced | DE line block; "at the downstream end TRUE 13218 1.000" | same-UTM records | OK |
| 251-252 | the rest: median 13 m, p90 80 m | DE apart_p50 13, p90 79.6, over `!same_utm` with a distance | the rest | OK |
| 252-253 | on the line: 81 / 9 / 6 / 2 / 2 % | DE where-block, FALSE rows (n 9,375) | the rest on the visit's line | OK |
| 256-257 | 19,349 visits, median 100, quartiles 38 and 200, p90 800, 1,799 no length | DE fished-length block | **visits of placed one-to-one records, not all matched visits** | finding (minor) |
| 257 | 338 spans run past the top | DE:31 | `s_vis` | OK |

### research/README.md (two changed rows)

| row | claim | source | verdict |
|---|---|---|---|
| fdis_export | coverage words only | — | OK |
| discharge_resolution | under 1 % (single-line 0.1–1) | FL Q1 | OK |
| discharge_resolution | span median 2.6 % on single-line | FL Q2 | OK (the row names single-line) |
| discharge_resolution | sources ×1.34 "there", gauge 23 % | FL Q2; modelled_discharge.md | ×1.34 over visits with both sources (finding, same as above) |
| discharge_resolution | 0.14–3.1 %, against 2.5–8.6 % | FL Q3 | the other-source range is over a narrower population (finding) |

### CLAUDE.md (changed lines)

| line | claim | source | verdict |
|---|---|---|---|
| 57-58 | PULL restores fish.rds, held to the ledger since #214 | `R/archive.R:25-31,236-241`; index rows for evidence 7fa6ad14 include fish.rds `8cf27351…` = every ledger's `md5_fish` | OK |
| 59 | PLACE=FALSE rebuilds it "byte-identically", with no database | true here (R 4.5.2); the RDS header carries the R version | **finding** (holds only under R 4.5.2) |
| 310-311 | PLACE=FALSE reproduces passes, fish, catch "byte for byte" | same | finding (same) |
| 312 | 245 of 51,587 visits placed differently, 2026-11-20 | `planning/active/findings.md:177`; sites.rds has 51,587 rows (counted here) | OK |

### scripts/README.md (changed lines)

| line | claim | verdict |
|---|---|---|
| 39-40 | PLACE=FALSE writes catch, fish, passes, stops, no database: "the remedy on a restored build" | the writes are right; the remedy overwrites restored fish.rds (finding 1) |
| 41-42 | 0240 writes fdis_sites.csv and the pass CSVs to data/fdis/derived | OK (`0240:158,170-171`) |
| 139 | PULL restores 0230's fish.rds from #214 | OK |
| 345-346 | passes kept, `fdis_passes` / `fdis_pass_catch` in v3 | OK (`0299:113-121`) |
| 353 | fdis_sites.{csv,gpkg} 17 MB each | **csv 19.4 MB** (finding, minor) |
| 356-358 | both checks run "on a restored published build" | the downstream check needs `catch.rds`, which a restore lacks (finding 3) |

## Enumeration (b): writes and stops in 0230 and 0240, and every run instruction

### scripts/0230-fdis-load.R, in order

| line | action | preceded by | safe on a restored build? |
|---|---|---|---|
| 75 | stop: PLACE not TRUE/FALSE | — | yes (refuses before anything) |
| 110-119 | export cache: aws cp of each key, manifest moved last | the manifest is absent | writes `data/fdis/<export>` only; not a build file |
| 113, 119, 124, 127 | stop: aws or rename failed | — | yes |
| 135 | stop: md5 mismatch against MANIFEST.md5 | the sync | yes |
| 137 | dir.create build | 135 | yes |
| 152 | stopifnot: unique KEY | 135 | yes |
| 459, 462 | stop: passes against n_pass, time, area | the roll-up | yes |
| 482-505 | stops: codes, fish rows, passes, repeat copies, habitat, measured, counted, catch status | everything above | yes |
| 511-514 | **PLACE=FALSE: saveRDS catch, fish, passes, pass_catch** | 75, 135, 152, 459-505 | **no**: overwrites a restored fish.rds with no comparison; the same bytes only under the same R (finding 1) |
| 517 | quit status 0 | 511-514 | — |
| 522, 527 | stop: fresh < 0.40.0; database unreachable | 459-505 | yes (before any write) |
| 587, 622, 625 | stops on placement integrity | the snap | yes |
| 662-668 | **full run: reconcile.csv, data/fdis_repeat_surveys.csv (tracked), sites.rds, catch.rds, fish.rds, passes.rds, pass_catch.rds** | every stop above | **no**: rewrites a restored sites.rds and reconcile.csv, which need not reproduce (#246); prose forbids it, and nothing in the code refuses (not this branch's) |

### scripts/0240-fdis-evidence.R, in order

| line | action | preceded by | safe on a restored build? |
|---|---|---|---|
| 45-47 | readRDS sites, catch, fish | — | fails without catch.rds (never restored) |
| 67-73 | database read (fwa_basin) | — | read only |
| 92 | write data/fdis_maturity_check.csv (tracked) | 45-47 | from fish and sites; deterministic |
| 157-158 | **write fdis_sites.csv** | 45-73 | overwrites the restored, md5-pinned table; reproduced here (2de46c60… = the archive's), depends on the database's fwa_basin |
| 163-168 | passes present: setequal or **stop** | 158 | **stop after 158, leaving stale pass CSVs** (finding 2) |
| 170-171 | write fdis_passes.csv, fdis_pass_catch.csv | 167 | yes |
| 173 | passes absent: unlink the pass CSVs | — | yes (round 1's fix) |
| 181 | st_write fdis_sites.gpkg | 158 | yes |
| 193, 231 | write data/fdis_evidence.csv, data/fdis_summary_ch_bt.csv (tracked) | 181 | from the restored inputs; deterministic |

### Every place the diff tells a reader to run 0230, 0240 or 0336

| where | instruction | safe on a restored build? |
|---|---|---|
| CLAUDE.md:57 | PULL=TRUE restores the evidence, fish.rds among it | yes (refuses over differing files) |
| CLAUDE.md:59 | a pre-#214 build: PLACE=FALSE 0230 rebuilds fish.rds | yes where fish.rds is absent; the result matches the ledger only under the same R (finding 1) |
| CLAUDE.md:310-314 | PLACE=FALSE reproduces byte for byte; restore with PULL, never by rerunning 0230 | claim narrower than stated (finding 1); the PULL advice is safe |
| R/archive.R:21-23 | a pre-#214 restore rebuilds fish.rds with PLACE=FALSE 0230 | as CLAUDE.md:59 |
| scripts/0230:62-65 | PLACE=FALSE "the remedy for a build restored from the archive" | overwrites restored fish.rds (finding 1) |
| scripts/0230:507-509 (comment) | catch, fish and passes "byte-identical to the build's" | holds only under the same R (finding 1) |
| scripts/0240:159-162 (comment) | PLACE=FALSE rebuilds the passes, leaving sites.rds alone | the passes are fine; fish.rds is overwritten |
| scripts/0240:168 | stop: "rerun PLACE=FALSE scripts/0230" | as above; and the stop leaves stale CSVs (finding 2) |
| scripts/0240:174 | "run PLACE=FALSE scripts/0230, then this" | PLACE=FALSE overwrites fish.rds (finding 1); "then this" rewrites the restored fdis_sites.csv (reproduced here) |
| scripts/0336:29-31 | PULL restores fish.rds from #214; PLACE=FALSE for earlier | as CLAUDE.md:59 |
| scripts/README.md:39-40 | PLACE=FALSE "the remedy on a restored build" | finding 1 |
| scripts/README.md:139 | PULL restores fish.rds | yes |
| scripts/README.md:356-358 | both checks run on a restored published build | the downstream check fails without catch.rds (finding 3) |
| data-raw/fdis_downstream_end_check.R:20-21 | PULL, then rerun 0240 if fdis_sites.csv is absent | **wrong**: fdis_sites.csv is always restored, catch.rds never; 0240 also needs catch.rds (finding 3) |
| data-raw/fdis_downstream_end_check.R:52-53 | stop: restore sites.rds with PULL=TRUE | PULL refuses over a differing file and says "move it aside"; safe |
| data-raw/segment_flow_resolution_check.R:31, 61-62 | PULL, then point EVIDENCE_DIR at it | yes (reads visits_link.csv only, md5-checked) |

### Checked and found correct

- **The archive's `fish.rds` gate.**
  - `knw_archive_plan()` holds `fish.rds` to `md5_fish`. Every evidence ledger in `scripts/logs` records
    `md5_fish 8cf27351…` and `md5_catch a31fd7bb…`.
  - The re-archive (evidence `7fa6ad14…`, batch `20261120T040634Z-6cd2c6ba`) holds tune rows identical to batch
    `2ce302a3`'s (object and md5), so `.knw_archive_batch_rows()` takes the newer batch, and the PULL restores
    `fish.rds`.
- **`knw_fdis_passes()`.** Its per-pass rule matches 0230's visit rule. The three-class code table makes `fish_codes`
  equal to 0230's "not zero, not non-fish".
- **`knw_fdis_span()`.** Its edges behave as stated: NA, 0, 9999, a point past the top, NA top.
- **`area_at()` after round 1.** Left-closed, with a measure past the top or in a gap giving NA.
- **The `PLACE` gate.** An empty string refuses.
