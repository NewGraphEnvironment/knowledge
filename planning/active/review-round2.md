# Code-check round 2 (#284, HEAD 38d8bbbc)

## Checklist read

- code-check-python.md: in full (no Python in the diff; nothing applies).
- code-check-r.md, by heading: "A `data-raw/` script must load the source tree, not the installed package",
  "A URL handed to a reader goes through R's 60 s connection timeout", "`paste()` with a zero-length argument returns
  length ONE, not zero", "`strsplit()` drops a trailing empty field, so a trailing separator vanishes", "CSV
  whitespace: `trim_ws` and `strip.white` do not do what the name suggests", "`ifelse()` with an all-NA test returns a
  logical vector, whatever `yes` and `no` are", "Postgres row order is never fixed unless the query fixes it, so a
  pick, a float sum and a presence check can each depend on it", "`match()` treats NA as a matchable VALUE, so two
  unknowns join to each other" (8 read; the rest not read, as they name tools or shapes this diff does not use).
- code-check-shell.md: no heading read (the diff's only shell is a `RUN:` comment with `set -o pipefail` and `tee`).
- code-check-spatial.md, by heading: "A relation between FWA watershed codes is not a place", "FWA lookup area follows
  watershed codes, so side channels get the river's", "FWA main flow is not edge type 1000 alone", "FWA
  `upstream_route_measure` misses the next segment's start" (4 read; the rest not read).
- code-check.md: the prose of all fourteen H3s under `## Mechanisms`, tables skipped.

index, diff and changed files read from file

## What was checked

- `second()`/`upstream()` run (copied out, not edited) over every input: all 5,488 bcfishobs coho codes in the Fraser
  drainage (every `wscode` and `localcode` is `100(.dddddd)*`, no NA localcode; 188 carry the Fraser's own `100`), all
  45,529 FDIS `visits_link.csv` rows (no NA or empty `wscode`/`localcode`; 63 Fraser-coded, 57 placed upstream, all in
  COTR, MORK, TABR, UFRA; 7,855 upstream in total, as the log prints), and the NuSEDS coho codes (dashed; the only two
  Fraser-own-code coho populations are Maria and Nicomen sloughs, correctly out; the 54 populations with no code are
  none of them upper Fraser). NA, `""`, `100`, `100-000000-...`, a non-`100` code and a second part equal to the
  Quesnel's all return FALSE. `obs:c51f92359e` (wscode `100`, localcode `100.478686`) lies on blue line 355992659,
  edge types 1450/1350 in COTR: the Fraser connector/side channel at the Cottonwood's mouth, as the research note says.
- research/coho_upper_fraser.md against the 31-row log: all 31 record ids match both ways; the verdict counts (15 / 13 /
  2 / 1) hold; the five 2004 entries are the log's five `2004-01-01` rows and two cite Irvine et al. 2001; only two
  records lie above the Nechako's code (WILL 594120, BOWR 654493); the place order (Cottonwood 478686, West Road
  500560, Naver 520500, Nechako 567134, Willow 594120, Bowron 654493) holds; the BOWR/WILL in, FRAN/STUL/STUR out claim
  matches `link::lnk_load_overrides(lnk_config("default"))$wsg_species_presence`.
- Push logs: each keeps only its own store's entry, coho 53 documents md5 ff810881567f0c4dfcab9488ee873608,
  habitat_modelling 463 documents md5 96c88c454c83309908361c1b3206a14d. The only entry `crd_store_push()` prints is
  the dry run's (the live push prints `Uploading` and `Manifest updated` only), so the trimmed logs hold all it printed
  for their store. No commit on the branch (57c458bd, 7a8f47a5, 38d8bbbc) holds the private repository's name under
  `scripts/logs/rag/`; `vca_refs` in the store list is already on `main` in earlier push logs.
- cred 0.8.1 is the tag on cred's default branch and its NEWS says the update compacts (cred#48 closed 2026-11-27), so
  0150's new floor and the CLAUDE.md and scripts/README.md rewording hold.
- Added lines grepped for home paths, hosts, credential paths and private repositories: none outside
  `planning/active/review-round1.md`, whose naming of the seeding repository is already on `origin/main` in ten
  `planning/archive/` files (planning may name what was removed).

## Findings

- **[bug]** research/coho_upper_fraser.md:19-22 and :116-128 (and research/README.md:30) — the link range section and
  the third In brief bullet list FRAN, STUL and STUR as the groups with coho records that link's `default` range leaves
  out, but NAZR is also out (`wsg_species_presence` gives `co` blank for NAZR) and holds a survey record in this very
  table: `nuseds:44756`, the Nazko River (FWA `100.500560.326229`, 492 of its 493 segments in NAZR), present on a bank
  walk in 1999 and 6 spawners by peak live count in 2001, judged "survey". The NuSEDS rows carry no watershed group (by
  design), which is likely how it fell out of the group-by-group comparison. A reader deciding whether link's coho
  range should change is told the range is too tight only within the Nechako system ("its edge within the Nechako
  system is drawn tighter than the surveys reach"); the Nazko, in the West Road system, is a second place a survey
  reaches outside the range. Add NAZR to the In brief bullet, the "What this means" list and the research/README row.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[bug]** research/coho_upper_fraser.md:133-137 (Gaps, first bullet) — "Four more rest on FDIS field records whose
  reports are not held: Triton's 2014 Ahbau report, Marlim's 2018 culvert inventory (two records) and Triton's 2010 fry
  emergence report". Counted by record, as the "(two records)" does, it is five: the Ahbau event is two records in the
  table (`obs:94e4f8d30d` and `fdis:172649_1_1`, both "survey"), plus `obs:026afad5a5`, `obs:785aff6b11` and
  `obs:02652e805d`. The file's own total confirms it: 15 surveys = 4 citation-only + 5 FDIS + 4 NuSEDS + 2 Dahl Creek
  (report held). Write "Five more" and name the Ahbau report's two records.
  - **Rule:** none
