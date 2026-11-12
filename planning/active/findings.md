# Findings — Backlog move 2: Public articles: a tuning series, one vocabulary, a build that cannot stall (#171)

## Issue context

**If we do it:** the site's articles read as a method and its case studies, say "fish habitat definition" as the website and README do, cite upstream fwapg at a commit upstream holds, and a build that stalls fetching tiles fails fast. **If we never do:** the series stays titled by its first species and by `link`, the README and articles drift from the website's words, and a stalled build holds a runner to its timeout (twice so far).

### Batch 2. Articles as a tuning series
- **Why here:** #118 is the hub (named by four open issues); #107 is already folded into it, and #156 rewrites the same three articles' prose, so one rename, one prose pass, one bibliography regeneration and one site build cover all three.
- **Touches:** `vignettes/*.Rmd` and `.bib` (renamed), `_pkgdown.yml`, `README.md`, `data-raw/vignette_{chinook,method,bib}.R`, `inst/method/settings.csv` (`where` paths only), `tests/testthat/test-vignette-data.R`, `CLAUDE.md`, `research/` references.
- **Decided at the gate:** the titles (#118's table); whether `stream_splits` joins the series as `tuning-…`; the fwapg pin (an upstream tag, or no version); the fly row of the ecosystem table waits on fly's own README change.

| issue | title |
|---|---|
| #118 | Retitle the articles as a tuning series: the method, then a case study per species and stage |
| #107 | Upstream fwapg citation pins a commit that exists only in New Graph's fork |
| #156 | README and articles: say fish habitat definitions, and lead with life history |

### Batch 3. A build that stalls fails fast
- **Why here:** the move's own site build is the test; the candidate cause is the `stream_splits` article's tile fetch.
- **Touches:** the article's basemap call; possibly gq's `gq_basemap_tiles()` (its own issue there if the timeout belongs in gq).
- **Decided at the gate:** if the logs are gone and the cause stays open, record that and close.

| issue | title |
|---|---|
| #159 | Post-merge CI stalled to its timeout once: find whether the article's Esri tile fetch can hang a build |


---

Backlog: `planning/backlog.md`, move 2. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.





## Phase 1: the narrowed register check (2026-11-12)

The methodology article prints more of the register than #118 listed: its step lists print label, value and unit; its
settings table prints label, value, unit, step, source, tested and issue; the counts above it read `source` and
`tested`. So the check holds every column but `where` and `note`, not only key, step, label, value and unit.

Mutation table (scratch worktree, `test-vignette-data.R` with the new test, `inst/method/settings.csv` edited):

| edit | whole-file md5 loop (settings.csv skipped) | printed-columns test |
|---|---|---|
| none | pass | pass |
| a value (9999 → 9998) | pass | **fail** |
| a new row | pass | **fail** |
| a `where` (an extra space in a `code:` phrase) | pass | pass |
| a `note` | pass | pass |
| a `source` | pass | **fail** |

## Phase 2: the rename (2026-11-12)

The references were all of the file form (`<name>.Rmd`, `.bib`, `.html`), rewritten by one perl pass guarded so
`chinook_rearing.rds`, `chinook_rearing_tuned.md` and `habitat_thresholds_tuned.md` stay; no bare-name mention was left
outside NEWS history. pkgdown 2.2.0 has `redirects:` (`build_redirects()`, a meta-refresh page per old path).
`devtools::test()`: 0 failed, 0 errors; `test-settings-register.R` resolves the three `code:` phrases in the renamed
chinook article.

## Phase 3: titles, openings, one vocabulary (2026-11-12)

- **What the method article prints from its bundle cannot change here.** Its step headings come from
  `inst/method/pipeline.csv` through `method.rds` ("6. Candidate rules", "10. Running the rule on link's streams"), its
  step lists and settings table print five `settings.csv` labels that say "rule" (`gradient_col`, `smoke_tol_null`,
  `flow_src`, `grade_size_mad`, `grade_size_width`), and its two pre-rendered SVGs say "Candidate rules", "both rules
  run" and "rules scored". `pipeline.csv` is pinned whole and the labels are a printed column (Phase 1), and the bundle
  rebuild needs the published build's ignored evidence and a database (`vignette_method.R` reads
  `data/fdis/derived`, `data/fdis/build/sites.rds` and `PG*` for the snap example), which this machine lacks. Split to
  its own issue, to ride the next rebuild (a promotion reruns `vignette_method.R`). The Rmds' own prose carries no
  "rule" but "rule of thumb" and code (`rule_words()`, `panels = "rules"`, `pk$rules`).
- **Openings.** The method article now opens from the life history (young chinook near large rivers) and the agreed
  paragraph in soul's `ecosystem.yml`, then `link`, then bcfishpass. The chinook case study opens with Kirsch et al.
  (2014, p. 42; `data/literature_evidence.csv`, its quote gate-verified): chinook rear in the lower reaches of small
  tributaries to large rivers. The stream-splits article already opened from life history; its first mention now
  reads "fish habitat definition", every bare "definition" became "habitat definition", and it now cites `wet` and the
  fwapg fork for the flows its flow floor rests on (review G4).
- **What readers see on the maps.** `R/compare_map.R`: legend title "Habitat definition", class "kept (both)", popup
  lines "the tuned habitat definition" and "the habitat definition's river", and the layer switch labelled "Habitat"
  and "Grade" (mapgl 0.4.6 takes a named vector) instead of the layer ids `rules` and `grade`. `test-compare_map.R`
  asserts none says "rule" and the switch's labels. `research/fig/` keeps the old legend until `0330` reruns.
- **README, DESCRIPTION.** Tagline, Title and the ecosystem row now carry soul's `ecosystem.yml` tagline (readme.md:
  change them together); GitHub About follows after the merge. `R` title case wants "is", not "Is"
  (`tools::toTitleCase`).
- **A probe that lied.** A shell-quoted `Rscript -e` said R's default regex missed `\brules?\b`; the same code from a
  file matches with and without `perl = TRUE`. The shell quoting broke the probe, not the regex.

Word counts (body prose without the YAML header and code chunks; `scratchpad wc.sh`), before → after:

| file | prose words | prose lines | file lines |
|---|---|---|---|
| `tuning-method.Rmd` | 2,425 → 2,543 | 184 → 187 | 480 → 483 |
| `tuning-chinook-rearing.Rmd` | 1,356 → 1,413 | 74 → 79 | 388 → 393 |
| `tuning-stream-splits.Rmd` | 1,777 → 1,810 | 114 → 116 | 597 → 599 |
| `README.md` | 851 → 948 | 77 → 81 | 117 → 121 |

No cut was forecast: this was a change of words, not a simplification. "Habitat definition" is one word longer than
"rule" at about 90 places, and the two new openings carry the life history; the README adds the third article's link.

## Phase 5: the stalls (#159, 2026-11-12)

Eight runs stalled on three days, all in `r-lib/actions/setup-r` or `setup-r-dependencies`, before any article
rendered, so the tile fetch is not the cause seen:

| date (UTC) | run | workflow | where it hung |
|---|---|---|---|
| 2026-11-05 21:43 | 42115253520 (attempt 1) | R CMD check | setup-r 21 min, then dependencies to the cap |
| 2026-11-05 21:44 | 42115301523 (attempt 1) | pkgdown (release) | setup-r 20 min, then dependencies to the cap |
| 2026-11-06 02:17 | 42149377267 | pkgdown | setup-r 19 min, then dependencies to the 30-min cap |
| 2026-11-06 02:17 | 42149415347 | Update CITATION.cff | setup-r to the 15-min cap |
| 2026-11-11 13:56 | 43033679109, 43033711487 | pkgdown (PR #190) | setup-r to the 30-min cap |
| 2026-11-11 13:56 | 43033679680, 43033712021 | R CMD check (PR #190) | setup-r to the 45-min cap |

43033711487's log: apt `Ign:` on every `azure.archive.ubuntu.com` index about every 20 s, then `Temporary failure
resolving 'azure.archive.ubuntu.com'`, 99 such lines until the cancel. The runner could not resolve the Ubuntu mirror.

The fix in `pkgdown.yaml` (this repository's own workflow): apt retries with 30-s timeouts (flows#3's recipe), then
each setup step limited and tried a second time if the first fails. The limits come from 25 successful pkgdown runs
to 2026-11-12: `setup-r` 28–233 s, `setup-r-dependencies` 0–624 s (the long ones cache misses), so 8 and 15 min; a
first guess of 5 and 10 would have cut the slowest healthy runs. The job cap goes from 30 to 40 min so one second try
fits. The R CMD check and citation workflows are the shared ones in `flows`; flows#3 already proposed the same fix, and
knowledge's runs are now in its body.
