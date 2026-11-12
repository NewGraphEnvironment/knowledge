# Code-check round 3 (#171), branch 89ee4d3a...21d266f0

## Checklist read

- code-check-python.md: read in full (no Python in this diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows and evidence blocks skipped), in full: A guard
  that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that
  reads its own output; A guard's scope, escape hatches, and remedies (including "Compression runs both ways"); A fix
  lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree;
  A wrapper's exit is not the work; Zero-length, empty, and unset; The probe is broken before the world is; Written data
  outlives the fix; Serialization loses meaning silently; One fact derived twice. Standalone rules by index line:
  Documentation Staleness, Bare `y`/`n` booleans in YAML 1.1.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: index lines only for the headings this diff touches
  (testthat skips and `test_file()`/`NOT_CRAN`, `system.file()` under `R CMD check`, data-raw loading the source tree,
  pkgdown/knitr, mapgl hex colours, regex word boundaries). No full section of those three files was opened.

## Mechanism

All three earlier findings are one mechanism: **a sentence (or a setting's comment) this branch wrote or reworded was
composed from a summary of the source, or from the intention behind the change, and not read back against the source
it restates.** The summary drops a qualifier or a condition (Kirsch's recommendation became general life history; "a
river that holds chinook" became "a large river"; "PCIC's routed flow through the fork" became "every flow through the
fork"), or the intention is written down as if it were the effect (an apt-retries file that the runner image overrides).
The text reads right on its own; the gap shows only next to the source. This is code-check.md's "Compression runs
both ways": a compression adds or drops a condition, and neither a citation check nor a word scan sees it.

Where it reaches in this diff: every reworded sentence the #156 "rule" → "habitat definition" sweep touched (each one
re-stated around the new noun), the three new openings (README, method, chinook), the DESCRIPTION Description, the
pkgdown.yaml comments (written from one log), vignette_bib.R's design note, the CLAUDE.md entries, and the new test's
comment. Each is checked below. Four places still carry it (Findings).

## Claim enumeration

| location | claim | source checked | verdict |
|---|---|---|---|
| pkgdown.yaml:11-12 | 40 min leaves room for one second try of a setup step | step limits 8/8/15/15; healthy setup-r ≤ 233 s, deps ≤ 624 s | holds for one retry (two retries could exceed, as worded) |
| pkgdown.yaml:35 | 8 stalled runs on 3 days, 2026-11-05 to 2026-11-11 | findings.md Phase 5 table; `gh run list` | holds (11-05, 11-06, 11-11) |
| pkgdown.yaml:35-36 | every stalled run "hung here or in the next step, apt failing to resolve the Ubuntu mirror until the job's cap" | logs of 43033711487, 43033679109, 42149377267, 42115301523 attempt 1 | **does not hold for all**: 2 of 4 pkgdown stalls show `Temporary failure resolving`; 42149377267 shows 0 such lines and slow downloads (gaps of 42-287 s between `Get:` lines); 42115301523 shows `Ign:` fetch failures, no resolution error. Finding 2 |
| pkgdown.yaml:37 | limits above slowest of 25 healthy runs: setup-r 233 s, deps 624 s | findings.md Phase 5 | consistent with the record (not re-derived) |
| pkgdown.yaml:38-39 | apt retries are the runner image's `zz-retries`, which a file here would not override | accepted (round 2) | accepted |
| CLAUDE.md:23-26 | three articles one series `tuning-<name>`; `_pkgdown.yml` groups them method / case studies / checks, redirects earlier names | `_pkgdown.yml` | holds |
| CLAUDE.md:26 | prose says "fish habitat definition" at first mention and "habitat definition" after, never "rule" | grep of prose outside chunks in the three Rmds; first mentions | holds in prose (bundle-printed "rule" is #201, accepted) |
| CLAUDE.md:42-43 | method article title "Tuning fish habitat definitions with fish sampling records" | `vignettes/tuning-method.Rmd` YAML | holds |
| CLAUDE.md:92-94 | test holds settings.csv to method.rds on every printed column (all but `where`, `note`); value/label/unit/step/source/tested/issue or row change stales, `where` does not | `tuning-method.Rmd` (`val()`, `detail()`, settings table), test code; ran `test-vignette-data.R` (all pass) | holds |
| DESCRIPTION Title | tagline | accepted | accepted |
| DESCRIPTION Description | "what is known about where fish live ... (each species' life history from the cited literature with its quotes, ...)" | `data/literature_evidence.csv` species; `data/thresholds.csv` | **overstated**: the quoted literature rows are habitat-threshold values for 15 codes; KO, a species in `thresholds.csv`, has none. Finding 4 |
| DESCRIPTION Description | scores candidate habitat definitions on held-out groups; compares tuned ones with link's defaults | data/compare (every fitted key and WCT_rear has a compare table) | holds |
| R/compare_map.R labels | legend "Habitat definition"; classes "kept (both)" etc.; popup "tuned habitat definition"; "Downstream to the habitat definition's river" | code; README figure re-rendered | holds |
| README tagline + opening | approved wording | accepted | accepted |
| README opening | "each is checked on parts of the province it was not chosen from" | held-out-fold scoring | holds |
| README opening | "knowledge compares each tuned one with the one link uses today" | `data/compare/*_compare.csv` for BT rear/spawn, CH, CO, GR, ST, WCT | holds |
| README caption/alt | blue both, orange default only, green tuned only, grey neither; tuned drops more than it adds | `man/figures/readme-bulk.png` | holds |
| README Learn more | third article: "how where link cuts a stream changes the slope limit the records choose" | stream-splits article | holds |
| method Rmd:127-129 | young chinook rear in larger streams, and in small streams mostly where those join a river that holds chinook | research/chinook_rearing_tuned.md:20-21 ("larger streams than coho do") | holds (drops "than coho", a comparison, not a qualifier) |
| method Rmd:129-134 | biology sets shape; records choose values; checked out of sample | method | holds |
| method Rmd:135-138 | link maps where each species can reach and spawn/rear; runs on the Atlas through fresh | link/fresh | holds |
| method Rmd:138-141 | bcfishpass models access below natural barriers and spawning/rearing from slope and size; > half a million road and rail crossings and dams | pre-existing figure | not re-derived (number pre-existing) |
| method Rmd:141-143 | bcfishpass keeps limits as parameter sets, most an organization's own | bcfishpass@3bd2824 `parameters/`: ccira, cwf, fptwg, newgraph, psf_fraser, testing | holds (5 of 6) |
| method Rmd:146-149 | each question has a cut-off in a config | link `configs/default` | holds |
| method Rmd:156-159 | fish habitat definition = the few thresholds a species and stage uses, with any exception its biology adds | link `parameters_habitat_thresholds.csv` (`rear_river_*` columns) | holds |
| method Rmd step 3, 5, 6-10, #se, #cuts, limits | "rule" → "habitat definition" rewordings | each sentence read beside its old form | hold; no meaning moved |
| chinook Rmd:141-143 | Kirsch et al. recommend looking for more chinook rearing "in the lower reaches of small tributaries to large rivers" (p. 42) | `data/literature_evidence.csv` row 48 quote: "...small (less than 50 km2 ...) non-natal tributaries to large rivers **supporting Chinook salmon** that are <610 m ... and have moderate (0.5–1.5%) gradient" | **drops the qualifier round 2 restored in the method article**. Finding 3 |
| chinook Rmd:141 | young chinook "do not always rear where they hatched" | row 48 "non-natal tributaries" | holds |
| chinook Rmd:144-146 | BC records point the same way: more of the small streams near large rivers, fewer far from one | tuned pick (flow floor or ≥ 3 m³/s river within 1 km) | holds |
| chinook Rmd:146-147 | link is an R package that maps where each fish species can reach, spawn and rear | link | loose ("each fish species": link models 11), pre-existing wording |
| chinook Rmd:150-151 | the method article says what a habitat definition is (`#thresholds`) | anchor exists; section defines it | holds |
| chinook Rmd map/what changes/strict/limits/table | rewordings around "habitat definition", "Run by", "tie-break fixed in advance" | old sentences; inline guards | hold |
| stream-splits Rmd:143-144 | "A recipe is a config, and every threshold and exception in it is a row in a table" | link 0.78.1 `configs/default/`: `parameters_habitat_thresholds.csv` is 11 rows (one per species) × 24 columns; thresholds and the near-river exception (`rear_river_*`) are columns; `dimensions.csv` one row per species; `rules.yaml` is YAML | **does not hold**. Finding 1 |
| stream-splits Rmd:149-150 | "Because each recipe is a table, a model can be ... traced back to the rows that produced it" | same: a recipe is a directory of ~25 CSV, YAML and README files | **does not hold**. Finding 1 |
| stream-splits Rmd:155 | "the shape of a habitat definition, such as young chinook rearing in small streams close to a large river" | accepted (approved paragraph's shape) | accepted |
| stream-splits Rmd:582-584 | flows are wet's, mostly PCIC's modelled flow carried by New Graph's fwapg fork | research/habitat_thresholds_tuned.md:82-84 (routed on 86.7 % of kept visits); research/modelled_discharge.md:38 | holds |
| stream-splits Rmd rewordings | "two habitat definitions", "Every habitat definition chosen ...", etc. | old sentences | hold |
| vignette_bib.R:364-367 | upstream fwapg carries no version since the run's `fwapg_sha` is a fork commit upstream does not hold | `9a62b0c2...` from the chinook bundle; `gh api compare` smnorris/fwapg main is 213 behind it, 0 ahead | holds |
| vignette_bib.R regeneration | new keys (`kirsch_etal2014Fishinventory`, `wet` and the fork key in stream-splits) | Kirsch key is gated in `literature_evidence.csv`; fork key already in the chinook .bib; `wet` from `citation("wet")` as in the chinook bib | regeneration should not fail on them |
| test-compare_map.R | switch labels Habitat/Grade; no reader label says rule | ran: 12 of 12 pass | holds |
| test-vignette-data.R | register's printed columns match the bundle; md5 test skips settings.csv | ran: all pass (3 skips are ignored-file tests) | holds |
| _pkgdown.yml | redirects for the three old names | findings Phase 6 local build | holds |
| research/*.md, data-raw/README.md | link and path renames | file names | hold |

## Findings

- **[severity: fragile]** vignettes/tuning-stream-splits.Rmd:143-144 and 149-150. The sentences say "every threshold and
  exception in it is a row in a table" and "Because each recipe is a table, a model can be ... traced back to the rows
  that produced it". The source does not support either. link's recipe (`configs/default`, link 0.78.1) is a directory
  of about 25 files. `parameters_habitat_thresholds.csv` holds one row per species (11 rows); each threshold and the
  near-river exception (`rear_river_measure`, `rear_river_distance_max`, ...) is a column, that is, a cell in a species'
  row. `dimensions.csv` is also one row per species, and `rules.yaml` is YAML. The branch reworded the old sentence
  ("every rule and threshold in it is a row") and added the "Because each recipe is a table" clause. In the same branch
  the method article got the accurate form ("Each question has a cut-off in a config"). Suggested wording: "every
  threshold and exception in it is a cell in a table, one row per species", or "a value in a config table", with "traced
  back to the values that produced it".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (Compression runs both ways)
- **[severity: fragile]** .github/workflows/pkgdown.yaml:35-36. The comment says every stalled run hung with "apt failing to
  resolve the Ubuntu mirror until the job's cap". That generalises from one log (43033711487, findings.md Phase 5).
  Measured: 43033711487 and 43033679109 each have 8 `Temporary failure resolving` lines. 42149377267 (pkgdown, 2026-11-06)
  has none: apt kept resolving and downloading, slowly, with gaps of 42 to 287 s between `Get:` lines. Its setup-r
  finished after 19 min, and setup-r-dependencies was still downloading (`Get:24 ... proj-data`) at the cancel.
  42115301523 attempt 1 has `Ign:` fetch failures and no resolution error. The stalls are a slow or failing mirror, not
  one DNS failure, and a later reader who trusts the comment may add DNS-only remedies. Say "apt stalling on the Ubuntu
  mirror (failing to resolve it, or downloading from it slowly)".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (Compression runs both ways)
- **[severity: fragile]** .github/workflows/pkgdown.yaml:27-55. The design is unverified and the risk is reasoned, not
  measured. A second try may not recover from a first try that the step limit killed while dpkg was unpacking. The runner
  kills the step's process tree. A kill during `dpkg` unpacking leaves `/var/lib/dpkg/updates` populated, and the next
  `apt-get install` in the second try then stops with "dpkg was interrupted, you must manually run 'sudo dpkg
  --configure -a'". Both second tries would then fail deterministically. The stalls seen so far were in the download
  phase, where a kill leaves dpkg clean, so this is a gap in the retry rather than an observed failure. A `sudo dpkg
  --configure -a || true` step before each second try (`if:` the same condition) would close it.
  - **Rule:** code-check.md "A guard that fails toward pass" (Which direction it fails: a partial failure the remedy cannot reach)
- **[severity: fragile]** vignettes/tuning-chinook-rearing.Rmd:141-143. Kirsch et al.'s recommendation is paraphrased as
  "the lower reaches of small tributaries to large rivers". The quote (literature_evidence.csv data row 48, p. 42) limits it
  to "non-natal tributaries to large rivers **supporting Chinook salmon**", under 610 m and at 0.5–1.5 %. Round 2 restored
  exactly this qualifier in the method article ("a river that holds chinook"), so the chinook article is the second
  caller of the same fix. Suggest "small tributaries to large rivers that hold chinook".
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"
- **[severity: fragile]** DESCRIPTION:13-15 (and man/knowledge-package.Rd). The Description says the package gathers "each
  species' life history from the cited literature with its quotes". `data/literature_evidence.csv` holds habitat-threshold
  values (temperature, gradient, velocity, flow, depth, ...) for 15 codes, and KO, a species in `data/thresholds.csv`, has
  no row. The README opening this wording follows is the approved paragraph, but the Description field is not on the
  accepted list. "cited habitat values from the literature, with their quotes" says what the file holds.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (Compression runs both ways: a sentence that gained a quantifier)
