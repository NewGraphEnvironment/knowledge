# Code-check round 5: branch 175-backlog-move-6-where-records-sit-the-sit (round 4's fixes 92e737eb, ca218904)

## Checklist read

- `code-check-python.md`: read in full. The diff has no Python.
- `code-check.md`: the prose of every H3 under `## Mechanisms`, table rows and evidence blocks skipped. The ones applied:
  - "A guard's scope, escape hatches, and remedies": run the remedy yourself, for every input the clause can receive;
    a byte compare answers "same build?", not "same content?".
  - "A guard that fails toward pass": "The write path" (two files that must move together) and "Where the guard
    sits" (a precondition ahead of the writes it guards).
  - "Written data outlives the fix"; "One fact derived twice".
- `code-check-r.md`, by heading:
  - "Regenerated binaries churn git even when nothing changed" (an RDS's bytes);
  - "`identical()` on two reader results tests the reader, not the file" (PLACE=FALSE keeps a file by its contents);
  - "`on.exit()` at a script's top level never fires" (not used here);
  - "Rscript reads a script as it runs" (I ran nothing from the repo's scripts).
- `code-check-shell.md`, `code-check-spatial.md`: no heading applies. The fixes are R and prose.
- Also `agent-operations.md` §3, "A relative descriptor is meaningless without its anchor".

Method:
- I read `git show 92e737eb ca218904`, all of the current `scripts/0240-fdis-evidence.R`, and the PLACE=FALSE block
  and its checks in `0230` (440-528).
- I read `data-raw/fdis_downstream_end_check.R:1-75`, `R/archive.R:17-45`, `0336:20-60`, the changed CLAUDE.md
  and README paragraphs, and all of `research/discharge_resolution.md` against both logs.
- Everything I ran was read-only Rscript over `data/fdis/build/catch.rds`. The one write went to the scratchpad. I
  touched no database and no S3, and wrote nothing under the repo except this file.

## Findings

- **[severity: bug]** `data-raw/fdis_downstream_end_check.R:57-60` (the stop) and `:22-23` (the RUN comment).
  - **What the remedy says.** It now reads "rebuild it with PLACE=FALSE scripts/0230-fdis-load.R under the R that
    wrote the build".
  - **The case it was reworded for.** A `catch.rds` already present, written by another R (or another locale or
    compressor). Its contents are equal and its md5 is not the ledger's.
  - **What PLACE=FALSE does there.** It keeps a present file whose contents are equal (`0230:514-523`, round 3's
    fix). So rerunning it under the right R leaves the wrong-byte `catch.rds` in place. It prints "kept catch.rds
    (contents equal)", and the check stops again with the same message. The loop round 4 found is still there; only
    the case of an absent `catch.rds` works.
  - **Proven here.** `readRDS(catch.rds)` re-saved with another serialization header (`version = 2`, standing in for
    another writer):
    - md5 `f6727bb2…`, against the ledger's `a31fd7bb…`;
    - `identical(readRDS(copy), x)` is TRUE, which is the test PLACE=FALSE keeps a file by.
  - **The R version is not the only thing in the bytes.** The md5 is of the gzip-compressed file, and its header
    carries the native encoding too: `58 0a 00 00 00 03 00 04 05 02 00 03 05 00 … 55 54 46 2d 38`, that is format 3,
    R 4.5.2, reader 3.5.0, then "UTF-8". So "under the R that wrote the build" is necessary but not sufficient.
  - **Suggested fix.** Write "remove catch.rds, then run PLACE=FALSE scripts/0230 under the R that wrote the build"
    in both places. Better, hold `catch.rds` by its contents, which round 4 offered as the first option.
  - **Inside round 4's fix:** yes. It is round 4's finding one axis over: the reworded remedy assumes PLACE=FALSE
    rewrites a file that it keeps.
  - **Rule:** `code-check.md` "A guard's scope, escape hatches, and remedies" ("run the remedy yourself, for every
    input the clause can receive"; "A byte compare … answers 'same build?' rather than 'same content?'").

- **[severity: minor, wrong claim]** `CLAUDE.md:315`: "A full run also rewrites `sites.rds`".
  - **What changed.** Round 4's inserted clause ends "(a full `0240` would rewrite the restored, md5-pinned
    `fdis_sites.csv`)". The next sentence, "A full run also rewrites `sites.rds`", now reads as a full `0240` doing
    so.
  - **Why it is wrong.** `0240` writes no `sites.rds`. The sentence means a full `0230`, as its own close says
    ("never by rerunning `0230` in full").
  - **Suggested fix.** "A full `0230` also rewrites `sites.rds`".
  - **Inside round 4's fix:** yes; the insertion moved the sentence's anchor.
  - **Rule:** `agent-operations.md` §3, "A relative descriptor is meaningless without its anchor".

- **[severity: fragile, minor]** `scripts/0240-fdis-evidence.R:72-73`, and for the full path `:128`, `:193` before
  `:194`.
  - **(a) The pair is split.** `write_passes()` writes `fdis_passes.csv` (72) before it reads `pass_catch.rds` (73).
    If that read fails (a truncated or unreadable file), the run stops with a new `fdis_passes.csv` beside the
    previous build's `fdis_pass_catch.csv`.
    - `0299` checks only that both inputs exist (`0299:177`). It would publish the mismatched pair.
    - The code this replaced read both RDS files before any write, so the reorder came in with the fix.
  - **(b) The check comes after the writes.** On the full path the passes' visit check (inside `:194`) runs after
    `data/fdis_maturity_check.csv` (`:128`, tracked) and `fdis_sites.csv` (`:193`) are written. A mismatch stop
    leaves those two new beside the previous run's `fdis_sites.gpkg`, `data/fdis_evidence.csv` and
    `data/fdis_summary_ch_bt.csv`.
    - This is reachable only with a mixed build directory: the passes of one build and the `sites.rds` of another.
    - The position predates round 4.
  - **Suggested fix.**
    - In `write_passes()`, read both RDS files before writing either CSV.
    - On the full path, run the passes' check (presence and `setequal`) right after the RDS reads at `:82-83`,
      ahead of the database read and the first write. Call `write_passes()` where it is now.
  - **Inside round 4's fix:** (a) yes; (b) no, a pre-existing position on this branch.
  - **Rule:** `code-check.md` "A guard that fails toward pass", "The write path" ("Where two files must move
    together…") and "Where the guard sits".

## Round 4's fixes, reviewed

| round 4 finding | fix | verdict |
|---|---|---|
| downstream check's catch md5 gate loops on another R | message and RUN comment name "the R that wrote the build" | **does not hold**: on an existing wrong-byte `catch.rds`, PLACE=FALSE keeps it and the check stops again (finding 1) |
| a rerun of 0240 rewrote the restored, pinned `fdis_sites.csv` | `ONLY=passes` path: `write_passes()` and `quit()` before `catch.rds`, the database and every other write; remedies say `PLACE=FALSE 0230` then `ONLY=passes 0240` | holds. The ONLY path reads only `sites.rds`, `passes.rds` and `pass_catch.rds`, and writes only the two pass CSVs. `write_passes()` reads `build` and `derived`, both assigned at `:47-48` before the function is defined, and neither reassigned later. It reads nothing else from the script's environment. Under ONLY it is passed `sites$site_visit` from `sites.rds`; on the full path `site_out$site_visit`. These are the same set, because `site_out` is `sites` left-joined and `setequal` ignores any duplication. Write order: finding 3(a) |
| "the smaller the minimum…" not monotone | "At the two smallest minimums, coho's and westslope cutthroat's, a point flow moves several times as many visits as at the others" | holds. Point: CO 0.0123 and WCT 0.0207, against 0.0013–0.0021 for the others, which is ×5.9 or more. Middle: 0.0167 and 0.0284 against 0.0027–0.0039, ×4.3 or more (FL:69-79) |
| fished-length quantiles named over 19,349 | "the 17,550 that record a length (1,799 do not)" | holds. DE "Fished length" block: n 19349, missing 1799, p50 100, p75 200, p90 800, and 19,349 − 1,799 = 17,550 |
| flow check header listed `fdis_sites.csv` | header names `visits_link.csv` alone | holds (`:26`; the script reads only `f_visits`, `:59`) |

## Enumeration (b): every write and stop in 0240, in order, on a restored build

A restored build holds `sites.rds`, `fish.rds`, `reconcile.csv`, `fdis_sites.csv` and the visit tables. It does not
hold `catch.rds` or the passes until `PLACE=FALSE 0230` has run.

| line | action | guarded by | holds? |
|---|---|---|---|
| 50 | stop: ONLY not unset or "passes" | — | yes; before any read or write |
| 51 | readRDS `sites.rds` | — | yes; stops before any write if it is absent |
| ONLY 59-63, 80 | passes absent: unlink both pass CSVs, message ("run PLACE=FALSE scripts/0230, then ONLY=passes scripts/0240"), quit 0 | 51 | yes. It removes CSVs of another build, and `0299` refuses on the missing inputs. Exit 0 with nothing written is backstopped by `0299:177` |
| ONLY 65 | readRDS `passes.rds` | 59 | yes |
| ONLY 66-69 | visits differ: unlink both CSVs, stop ("remove passes.rds and pass_catch.rds, then run PLACE=FALSE scripts/0230 and ONLY=passes scripts/0240") | 65 | yes. The remedy is executable: PLACE=FALSE writes the absent passes and keeps an equal `fish.rds`. It rebuilds the visits of `sites.rds` wherever the export and the code build that build's visits; otherwise PLACE=FALSE's `fish.rds` check usually refuses first |
| ONLY 71-73 | dir.create; write `fdis_passes.csv`; readRDS `pass_catch.rds`; write `fdis_pass_catch.csv` | 66 | **no**: a failed read at 73 leaves the pair split (finding 3a) |
| ONLY 77-80 | message, quit 0 | 72-73 | yes; nothing else is written |
| 82-83 | full: readRDS `catch.rds`, `fish.rds` | 76 | yes; without `catch.rds` it stops before any write |
| 84, 87 | read the size-break and species-code CSVs | — | yes (read only) |
| 103-109 | database read (`fwa_basin`) | — | yes; a connection failure stops it before any write |
| 119 | `knw_size_class()` can stop | — | yes; before any write |
| 128 | write `data/fdis_maturity_check.csv` (tracked) | 82-119 | first write; a change shows in git |
| 192-193 | write `fdis_sites.csv` | 82-119 | rewrites a restored, pinned table. Documented at `0240:40-42`, CLAUDE.md:315 and scripts/README.md:360, with `ONLY=passes` as the route that avoids it |
| 194 | `write_passes()`: absent → unlink and message, continue; differ → unlink and stop; else write both CSVs | 193 | **partly**: a stop here comes after the 128 and 193 writes and leaves the gpkg and tracked tables from the previous run (finding 3b); split pair as in finding 3a |
| 199-200 | st_write `fdis_sites.gpkg` (delete_dsn) | 194 | yes (not pinned) |
| 211 | write `data/fdis_evidence.csv` (tracked) | 199 | yes |
| 249 | write `data/fdis_summary_ch_bt.csv` (tracked) | 211 | yes |

The full path writes the same files as before the fix: the maturity check, `fdis_sites.csv`, the pass CSVs (or their
removal), the gpkg, the evidence and the summary. Only the absent-passes message changed ("then this" became "then
ONLY=passes scripts/0240").

## Every place a changed doc tells a reader to run 0230, 0240 or 0336

| where | instruction | executable as written on a restored build? |
|---|---|---|
| CLAUDE.md:57-59 | PULL=TRUE restores the evidence, `fish.rds` among it | yes (md5-checked; refuses over a differing file) |
| CLAUDE.md:59-60 | pre-#214: PLACE=FALSE rebuilds `fish.rds`, byte-identical under the R that wrote the build | yes where `fish.rds` is absent, which is that case |
| CLAUDE.md:310-315 | PLACE=FALSE writes the absent files, keeps equal ones, refuses differing; then `ONLY=passes 0240` | yes |
| CLAUDE.md:315-318 | "A full run also rewrites sites.rds"; restore placement with PULL, never 0230 in full | the restore advice holds; the "full run" now reads as 0240 (finding 2) |
| R/archive.R:21-23 | pre-#214 restore: PLACE=FALSE rebuilds `fish.rds` | yes |
| R/archive.R:43 (via the downstream check `:61`) | "rerun scripts/0240" where `fdis_sites.csv` is not the `sites.rds` table | yes. It fires only where the table is wrong. A full 0240 needs `catch.rds` (from PLACE=FALSE) and the database |
| scripts/0230:62-66 | PLACE=FALSE, the remedy for a restored build | yes |
| scripts/0240:40-42 | ONLY=passes after PULL then PLACE=FALSE | yes |
| scripts/0240:53-56 (comment) | PLACE=FALSE rebuilds the passes and leaves `sites.rds` alone | yes |
| scripts/0240:61-62 | "run PLACE=FALSE scripts/0230, then ONLY=passes scripts/0240" | yes |
| scripts/0240:68-69 | "remove passes.rds and pass_catch.rds, then run PLACE=FALSE scripts/0230 and ONLY=passes scripts/0240" | yes (see the table above) |
| scripts/0336:29-30 | `fish.rds` from #214; PLACE=FALSE for an earlier build | yes |
| scripts/README.md:39-40 | PLACE=FALSE, the remedy on a restored build | yes |
| scripts/README.md:41-42 | 0240 writes `fdis_sites.csv` and the pass CSVs; ONLY=passes writes the pass CSVs alone | yes |
| scripts/README.md:138 | PULL restores, md5-checked | yes |
| scripts/README.md:357-360 | the two checks: PULL, then PLACE=FALSE adds `catch.rds` and the passes, then ONLY=passes writes the pass CSVs | the flow check yes. The downstream check runs where PLACE=FALSE wrote `catch.rds` under the build's R; on a wrong-byte `catch.rds` already present it loops (finding 1). ONLY=passes is not needed by either check; it is harmless |
| data-raw/fdis_downstream_end_check.R:20-23 | PULL restores `sites.rds` and `fdis_sites.csv`; PLACE=FALSE adds `catch.rds` under the build's R | **no where a `catch.rds` of another writer is present** (finding 1) |
| data-raw/fdis_downstream_end_check.R:53-55 | stop: restore `sites.rds` with PULL | yes (PULL refuses over a differing file and says to move it aside) |
| data-raw/fdis_downstream_end_check.R:57-60 | stop: "rebuild it with PLACE=FALSE … under the R that wrote the build" | **no**: PLACE=FALSE keeps the equal-content file and the check stops again (finding 1) |
| data-raw/segment_flow_resolution_check.R:31-32, 60-62 | PULL, then point EVIDENCE_DIR at it | yes (`visits_link.csv` only, md5-checked) |

## Enumeration (a), re-checked: research/discharge_resolution.md

Sources:
- FL = `scripts/logs/flow/20261119_segment_flow_resolution_check.txt`;
- DE = `scripts/logs/fdis/20261119_fdis_downstream_end_check.txt`.

`git diff c07d5939 HEAD -- research/ scripts/logs/` shows that only the two sentences changed, and neither log did.
I re-read every row against the logs.

| line | claim | producer | verdict |
|---|---|---|---|
| 3-8 | log paths, link run, `c746c582…`, flow load 2026-10-24 | FL:1-3 | holds |
| 14-15 | single-line 0.1–1: top typically within 1 % of bottom | FL single-line 0.1-1 fall_p50 0.0085 | holds |
| 16-18 | 0.13–2.8 %; other source 2.4–7.9 % of the same visits; three to twenty times | FL:69-79 (min 0.0013, max 0.0284; 0.0241–0.0789; ratios 2.78 to 20.2) | holds |
| 26 | BULK's 10,387 mouths | #137 (not re-derived; accepted in round 3) | — |
| 34-36 | 247,517 side channels; 4,659,924 own-line; 4,425,507 measured | FL:6 (4,907,441 − 4,659,924); Q1 rows | holds |
| 40-44 | Q1 table | FL Q1 single-line <0.1 (2,832,294, 0.7435, 1.0000, share 0.7313), 0.1-1 (455,171, 0.0085, 0.1473), 1-10 (134,134, 0.0013, 0.0161), double 0.1-1 (32,279, 0.0018, 0.0275), double 1-10 (80,279, 0.0004, 0.0042) | holds, as in round 4 (the over-10 % column was checked there) |
| 47-48 | below every minimum but WCT's 0.03 | `data/thresholds.csv` | holds |
| 53-54 | 58 %; 81 % within 5 m | DE (0.582; 7,579 / 9,375) | holds |
| 55-57 | 19,349 visits; the 17,550 with a length (1,799 without): median 100, p75 200, p90 800 | DE "Fished length": 19349, 1799, p50 100, p75 200, p90 800 | **holds (fixed)** |
| 61-63 | 45,503 own (26 parent); 37,506; 39,321 of 43,843 | FL:52, 63 | holds |
| 67 | single-line 28,001; 11 % (100 %); 2.6 % (34 %); 27 %; ×1.33 (×2.8) | FL Q2 single-line 0.1061, 1.0000, 0.0264, 0.3378, 0.2726, 1.33, 2.84 | holds |
| 68 | double-line 8,852; 0.01 % (0.9 %); under 0.01 % (0.8 %); 4.2 %; ×1.10 (×1.6) | FL Q2 double-line 0.0001, 0.0088, 0.0000, 0.0078, 0.0424, 1.10, 1.60 | holds |
| 70-71 | 23 %; a ninth at the median | `research/modelled_discharge.md`, FL:65; 2.64 / 23 = 0.115 | holds |
| 71-72 | sources part by more than the span, both edges, p50 and p90 | 33 % > 2.6 %, 184 % > 34 %; 10 % > 0.00 %, 60 % > 0.78 % | holds |
| 74-75 | the same 37,506 | FL Q3 `visits` | holds |
| 79-83 | Q3 table (25 values) | FL:69-79 | holds |
| 85-86 | two smallest minimums move several times as many visits at the point as the others | CO and WCT: ×5.9 or more (point), ×4.3 or more (middle) | **holds (fixed)** |
| 86 | WCT: a quarter to a third of the source choice | 0.0207 / 0.0789 = 0.26; 0.0284 / 0.0789 = 0.36 | holds (as in round 4) |
| 87-88 | 11 % median; 59 % on segments under 0.1 | FL Q2 0.1061; FL:64 0.593 | holds |
| 99-101 | counts over the published visit table | the visit table; the narrower 37,506 stated at 61-63 | holds |
| 103 | 0.13 % single-line, 0.04 % double-line at 1 m³/s and up | FL single 1-10 0.0013; double 1-10 0.0004 (≥ 10 lower) | holds |
