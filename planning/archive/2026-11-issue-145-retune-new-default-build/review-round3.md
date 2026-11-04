# Code-check round 3 (#145): branch 3140693...HEAD at 3998b24

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped).
- code-check-r.md: read in full "`$` on a list partial-matches", "A database driver's value is not a base R type",
  "A value compared as `::text` in SQL", "`nzchar(NA)` is TRUE", "`paste()` with a zero-length argument",
  "`strsplit()` drops a trailing empty field", "`match()` treats NA as a matchable VALUE", "`data.frame()` recycles a
  scalar against a zero-length column", "Postgres row order is never fixed unless the query fixes it", "An
  `information_schema` lookup by the literal table name", "`system2(stdout = TRUE)` warns on a non-zero exit", "A
  `function(...)` mock hides arguments", "`ifelse()` with an all-NA test" (13). The other sections (about 95) I read
  by their index line only.
- code-check-shell.md, code-check-spatial.md: index only. The diff has no shell, sed or spatial code beyond
  `system2("git", ...)`, which the R heading covers. I read 0 sections in full.

## The mechanism behind rounds 1 and 2

Each earlier finding was a record that states a property of the run (the tree was clean; the verdict; where a
section is) through a channel narrower than that property. The writer covers the paths and inputs it anticipated,
and anything else falls through to the reassuring default: an untracked file reads as clean, an unhandled exit
leaves `polling`, and a moved anchor still reads as "the next section". This is code-check.md "A guard that fails
toward pass" ("Provenance, and repair"), plus "A relative descriptor is meaningless without its anchor".

These are the places in this diff that the mechanism reaches, each checked:

1. `0300`'s verdict row. Release, refusal at release (`shas()` raising) and timeout each write a terminal status.
   `poll()` raising still leaves `polling`, which is older than this branch and accepted. Holds.
2. `pick_network_compare.R`'s commit stamp now sees `R/` and the script itself, untracked included. Holds.
3. `pick_network_compare.R`'s input md5s cover the three anchor csvs but not the tune tables `place()` reads.
   **Finding 1.**
4. `knw_build_record()`'s `line` names every set-aside run, and `0310`'s species note reads the same rows through
   `rec$log`. `0300`'s record carries `log_runs_aside`. Holds.
5. The quantifiers in the new prose: every number and range is checked against the logs below. One "every" covers
   a key that neither new tuning scored. **Finding 2.**
6. The relative anchors in the research file: "The next section" and "(…, above)" both resolve correctly. Holds.

## Findings

- **[severity: fragile]** data-raw/pick_network_compare.R:240-248 (`place()`) and 260-264, 291 (the log's input
  lines). The header (line 189-190) says the .txt records "the inputs' md5s". The script records md5s only for the
  three anchor-check csvs. Every in-region verdict and every "behind their best" figure comes from `place()`, which
  reads `<key>_tune.csv` from `TUNE_MINIMAL` and `TUNE_FULL`. The log records only those directories' paths
  (`tune tables (full): data/tune/dev_default_20261103`). Nothing checks that those tables belong to the tunings the
  anchor csvs describe. The anchor csv carries `run_uid` and `evidence_md5`; each tune directory's
  `<key>_summary.csv` carries `run_uid`, `evidence_md5` and `tune_run`; nothing compares the two.
  `data/tune/dev_default_20261103` is ignored, and any later `DEV=1 0320` with the same `DEV_DIR` rewrites it. This
  has already happened once on this branch: the first all-species run was rerun with `SPECIES=`. A rerun of the
  script after such a pass would mix one tuning's picks with another's regions, and the log would look the same.
  These are the numbers the research section quotes as its conclusions: 80.8/73.2, 7.1/5.1, 10.4/7.3, 4.8/10.8,
  7.2/8.3, and "every published pick lies in both new tunings' regions". It is the same class as round 1's untracked
  script: the stamp names fewer inputs than the numbers depend on.
  Fix:
  - md5 each `<key>_tune.csv` that `place()` reads into the log;
  - or refuse a directory whose `<key>_summary.csv` `run_uid`/`evidence_md5` differ from the anchor csv's for that
    side;
  - or drop "the inputs' md5s" from the header.

  (`TUNE_PUBLISHED` is required to exist, but `place()` never reads it: every pair's second member is `minimal` or
  `full`. That is harmless.)
  - **Rule:** code-check.md "A guard that fails toward pass" (Provenance, and repair)

- **[severity: fragile, prose]** research/minimal_network_tuning.md:120 ("**The published rules stand.** Every
  published pick lies in both new tunings' regions.") and research/README.md:28 ("every published pick stays in both
  regions"). The published tables have eight picks. `20261104_pick_network_compare.csv` holds `RB_rear`
  (`width>=3|g<=0.3|none`), and both of its region lookups are empty: neither new build models rainbow trout, so
  neither tuning scored it. The statement holds for the seven keys both tunings scored. The research section names
  RB two sentences later; the README index row does not. Write "each of the seven published picks both tunings
  scored" (or "every published pick of the seven keys"). A reader of the README row could otherwise take RB
  rearing's published rule as re-confirmed on the new builds.
  - **Rule:** none (CLAUDE.md, Agent Operating Rules §3: "Treat `every`, `each`, `all N` ... as words to check")

## Public-repo check (nothing found)

- The 11 logs this branch adds under `scripts/logs/habitat/` (including `default_build_145/`), read in full by
  pattern (BSD grep over every line) and by header. I found no home or temp paths, user names, machine or host names,
  `localhost`, ports, `PGSERVICE` entries, credential files or logins. The paths they hold are repo-relative
  (`data/fdis/derived_default_20261103`, `data/tune/dev_default_20261103`, `scripts/logs/habitat/...`). The URLs are
  the public wet manifest on `fresh-bc.s3.us-west-2.amazonaws.com` and the BC Data Catalogue zip, which are already
  on main.
- The diff's code, CLAUDE.md, research and scripts/README: none either. `PGSERVICE` appears only as the mechanism,
  never an entry name.
- Commit messages 3140693..HEAD: no host or machine names, and no paths.
- `planning/active/findings.md` and `task_plan.md` name machines (m1, m4) and a service entry name. CLAUDE.md
  allows planning/ to name hosts ("may name what was removed, hosts and our other repositories included"), and these
  files carry no home path or client identifier. Not a finding.

## Quantified claims checked against the logs (all hold except finding 2)

- Placement claims hold: 45,529 visits on both builds, 45,463 at one blue line, measure and Atlas line, and 66
  otherwise (`minimal_network_check.txt` step 1). The walks and visits_species are byte-identical (step 2).
- "Accessible km agree within 1.5 km" holds: the province table's largest |diff| is ST, 1.5.
- "4,156 pairs; almost all 1 on full, 2 on minimal; 58 cross zero" holds: 4,097 pairs read 1→2, 58 read 1→0 and
  1 reads 2→1, which sums to 4,156.
- "Rearing 0.5 to 1.8 % longer for six species and 0.1 % shorter for sockeye; spawning 0.01 to 2.8 % shorter"
  holds. The province table has seven species. Rearing is +0.52 (BT), +1.75 (CH), +0.52 (CO), +0.54 (GR),
  +1.55 (ST) and +0.66 (WCT), and −0.11 for SK. Spawning is negative for all seven, from −0.01 to −2.78.
- "fresh 0.52.0 against 0.53.0" holds: the two ledgers' build-record lines. The installed link is 0.78.1 on both.
- Segment-start row 44.2 % / 6.6 %, 305 / 466 m: `segment_gradient_check-derived_default_20261103.txt`, by catch
  (stream branch). The prose says this "halves the published network's gap": the gap goes from 76 points to 37.6.
- Pick table, parts moved, and "three of seven" / "four" hold. Region bullets: 7.16/8.28, 80.81/73.24 (minimal BT
  rear outside full), 65.31/73.69, 7.07/5.13 and 10.37/7.34 (full outside minimal), 4.80/10.83. README "three of them
  outside" (BT rear, BT spawn, CH rear) holds.
- CLAUDE.md, the research bullet and `R/build_record.R`'s roxygen state the rule exactly as
  `.knw_build_log_runs()` implements it.
- test-build_record.R on a scratch copy (`PGHOST=invalid.invalid`, `NOT_CRAN=true`): 6 blocks, 33 expectations,
  0 failed, 0 errors; the live block skipped.
