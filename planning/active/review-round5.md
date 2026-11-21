# Code-check round 5 (confirming round 4's fixes by enumeration): branch 244-backlog-move-16-nuseds-spawning-windows (base 088cd31b, head 2dca9069)

## Checklist read

- code-check-python.md: in full (no Python in the diff; no rule applies).
- code-check.md: the prose of the `## Mechanisms` H3s (tables and evidence blocks skipped); applied "A guard's scope,
  escape hatches, and remedies" (quantified claims), "One fact derived twice", "A proxy is not the property" (grain).
- code-check-r.md, code-check-shell.md, code-check-spatial.md: index only, as round 4 (the last two commits change one
  `cat()` argument, three comment blocks and a README line).

## Probes (outputs only under the scratchpad `cc/r5/`; repo untouched apart from this file)

- `git diff f6127b62 HEAD -- data-raw scripts/logs/timing/README.md`: the three fixes and nothing else in code.
- Round 4's cached `nuseds_records.parquet`: sha256 `ecc4716f…eee4`, the manifest's sha the tracked log prints. Dated
  records of the six species sharing a population-year: 28 of 3 populations over the release; 16 of 2 over records
  with an FWA watershed code.
- Tracked `20261121_timing_nuseds_windows.csv` (at HEAD): 6,112 rows, 20 columns; scope counts group 357, run_type
  298, population 4,921, apart 536; (wsg, species, scope, run_type, pop_id) unique; one group row per key where any;
  every key with run_type rows has at least 2; no population is both `population` and `apart` in one key; every
  population/apart row has a start or end date. 480 keys in 126 groups (matches the log's line 6); **123 keys hold
  apart rows only and no `group` row** (e.g. ADMS CH, ADMS PK, ATNA CH).
- Tracked log at HEAD: `wrote 6112 windows to 20261121_timing_nuseds_windows.csv` (L8971), the name `cp` gives it.

## Enumeration

### Fixes (3)

1. L263 `basename(out)` — the printed name is the file's own and the name `cp` lands it under; an unwritable OUT still
   fails at L262 before the `cat`; nothing else in the script prints a local path (fetch prints the public URL, the
   sha stop prints the manifest's relative path). **Sound.**
2. Header L24-26 "16 dated records with a watershed code, of two populations, in the 2026-06-01 release" — reproduced
   (16 of 2); the set is the one n is computed over (round 3: unchanged after the Atlas filter). **Sound.**
3. Header L43-45 and logs README L12 "one row per window" — by kind correct: (wsg, species, scope, run_type, pop_id)
   is the key; README's "(a group's pooled window, a run type's, or a population's)" lists kinds with no quantifier.
   The header's "per group and species its pooled window (scope group)" holds for 357 of 480 keys. **Defect
   (Finding 1).**

### C. Outputs (17: 16 printed items + the CSV)

1. L95-96 release, commit, path, sha256, rows. **Sound.**
2. L102-103 dated records / populations / no FWA code. **Sound.**
3. L138-139 codes the Atlas does not hold. **Sound.**
4. L159-160 named reaches (empty table unreachable in a full run, round 4). **Sound.**
5. L203 "N group x species keys in M groups" — 480 in 126, matches the CSV. **Sound.**
6. L241-242 per key "P populations pooled, A apart". **Sound.**
7. L243 window table, 18 columns (`show`). **Sound.**
8. L249 "check skipped" (filtered only). **Sound.**
9. L255 "check: … as published" (three lines in the log). **Sound.**
10. L263 "wrote N windows to <basename>" — N = all scopes' rows (6,112 = CSV rows). **Sound (fixed).**
11. L271 "nothing to compare" (filtered only). **Sound.**
12. L296 comparison header. **Sound.**
13. L298 comparison table, largest first. **Sound.**
14. L303 "row: apart populations in <wsg>". **Sound.**
15. L304-305 apart table. **Sound.**
16. L307-308 "rows not compared" by verdict. **Sound.**
17. CSV (L262): `wsg_code`, `species_code` + the 18 `show` columns, `na = ""`; grain as fix 3. **Defect only through
    Finding 1.**

### D. Documented command lines (9)

1. Script RUN L46-48, full run — `pipefail` in the subshell, `&& cp`; copied names are the tracked names. **Sound.**
2. Same line with a filter — stops at L72-73 before any fetch; `cp` skipped. **Sound.**
3. Script L51-53 `WSG=BULK,MORR SPECIES=CH …` — prints only; "refuses OUT, and a group with no dated record" matches
   L72-73, L196-197. **Sound.**
4. Script L54 `VERSION=v1` — default `v1` (L65). **Sound.**
5. 0340 RUN L24-28 — quoted `"$L"`, `pipefail`, `&& cp`; the clean-tree refusal is L50 (PUBLISH). **Sound.**
6. 0340 L29 `RELEASE=20260601`. **Sound.**
7. 0340 L30 `PUBLISH=TRUE`. **Sound.**
8. scripts/README.md 0340 entry (L140-145) — "tee'd to $TMPDIR and copied in after a run that succeeded". **Sound.**
9. scripts/README.md timing entry (L491-496) and scripts/logs/timing/README.md (L10-12) — flags, names and paths
   match the code and the tracked files. **Sound.**

### E. Numbered or quantified claims (19)

1. Header L3 "every watershed group and species with dated spawner records". **Sound.**
2. L5 / scripts/README "writes no row". **Sound.**
3. L8-10 sha256 refusal; release, sha256, commit printed first. **Sound.**
4. L11-12 single-group code pools into that group. **Sound.**
5. L12-15 / CLAUDE.md L166-169 / both READMEs: multi-group code apart under each group unless the reach table names
   it. **Sound.**
6. L16-17 refuses a wrong name or a group the code does not cross (L147, L152; also L146). **Sound.**
7. L17-18 named reach belongs to its group alone (L156). **Sound.**
8. L21-22 start/end fields; month and day only. **Sound.**
9. L23-24 median, 10th/90th percentiles over dated records. **Sound.**
10. L24-26 "16 dated records with a watershed code, of two populations" — reproduced. **Sound (fixed).**
11. L26-28 season year 1 April / 1 September for ST. **Sound.**
12. L28-30 population windows; per run type where a group holds more than one. **Sound.**
13. L30-31 arrival for migration rows. **Sound.**
14. L32-36 every timing row compared; every difference printed, largest first. **Sound.**
15. L37-38 / scripts/README: stops unless it reproduces UFRA, COTR, BULK CH (full run). **Sound (round 4's scope).**
16. L43-45 CSV grain. **Defect (Finding 1).**
17. L50 "Only a full run takes OUT, so only it reaches the copy." **Sound.**
18. inst/NOTICE.md L31-33: windows to `scripts/logs/timing/` (both file patterns); reach table by gfe_id and name.
    **Sound.**
19. CLAUDE.md L165-166 / scripts/README L493 "writes every group's and species' (spawning) windows" — every key gets
    windows (apart-only keys get their apart populations'); not a claim of one pooled window per key. **Sound.**

### Path grep of the two tracked logs

`grep -nE '/Users|/home/|/var/folders|/private|/tmp|~/|scratchpad|claude|/Volumes|newgraph|\bm1\b|\bm4\b'` plus this
host's short name and user name over `20261121_timing_nuseds.txt` and `_windows.csv`: no match. The only `/`s in the
.txt are `knowledge/nuseds/v1` and `data/nuseds_reach_groups.csv` (L1, L5); the CSV has none. "HAUSER CREEK"
(L6257, L6308) matches a loose `user` grep: a NuSEDS waterbody, not a user name. No R warning or error text in the log.

## Findings

- **[severity: minor]** data-raw/timing_nuseds.R:43-44 — The rewritten OUTPUT line says the CSV holds "per group and
  species its pooled window (scope group)". A group row is written only where the group holds dated pooled records
  (L213); a key reached only through apart populations gets apart rows and no group row. In the tracked CSV 123 of
  480 group x species keys (ADMS CH, ADMS PK, ATNA CH, …) have no `scope == group` row, so a reader taking the line
  at its word and expecting one group row per key finds 357. Wording such as "per group and species with pooled
  records its window (scope group)" matches the code. The logs README's version lists kinds without the quantifier
  and is fine. Inside an earlier fix: **yes** (03926044, round 4's Finding 1).
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a quantified claim checked against its
    population; also "A proxy is not the property": "check the grain")

No other defect: fixes 1 and 2 hold, no printed output or documented command line regressed, and the tracked logs
carry no local path, host or user name.
