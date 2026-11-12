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
resolving 'azure.archive.ubuntu.com'`, 99 such lines until the cancel. Not every stall was that: 43033679109's log has the
same errors, but 42149377267's has none, its downloads crawling with 42 to 287 s between `Get:` lines (round 3).

The fix in `pkgdown.yaml` (this repository's own workflow): each setup step limited and tried a second time if the
first fails. A step writing apt retries (flows#3's first box) was added and then dropped in code-check round 2: the x64
runner image writes `/etc/apt/apt.conf.d/zz-retries` (one retry, 15-s timeouts), which sorts after `80-retries` and
wins, by design, so apt fails over to the next mirror sooner (`actions/runner-images`, `configure-apt.sh`). The limits come from 25 successful pkgdown runs
to 2026-11-12: `setup-r` 28–233 s, `setup-r-dependencies` 0–624 s (the long ones cache misses), so 8 and 15 min; a
first guess of 5 and 10 would have cut the slowest healthy runs. The job cap goes from 30 to 40 min so one second try
fits. The R CMD check and citation workflows are the shared ones in `flows`; flows#3 already proposed the same fix, and
knowledge's runs are now in its body.

## Phase 6: local site build (2026-11-12, before the bibliographies)

`pkgdown::build_site()` on the installed branch, exit 0. `docs/articles/` holds `tuning-method`, `tuning-chinook-rearing`
and `tuning-stream-splits`; `habitat_thresholds.html`, `chinook_rearing.html` and `stream_splits.html` are meta-refresh
pages to the new ones (through `url:`, the github.io address). Every relative `.html` link and every `#anchor` into a
sibling article resolves; no footnote marker. The rendered text says "rule" only in the method article: the bundle's
step names, settings labels and diagrams (#201), "rule of thumb", and Chen and Yang's title ("The One Standard Error
Rule for Model Selection"). The new Kirsch et al. (2014) citation renders as `kirsch_etal2014Fishinventory?` until
Phase 4 regenerates the `.bib` files: Zotero's local server answered every request with an empty reply, through a
restart, from inside and outside the sandbox, with the screen locked.

That empty reply was the probe, not Zotero: `~/.curlrc` sets a browser user agent, which Zotero's server drops without
`Zotero-Allowed-Request: true` (soul#590, closed 2026-11-04, documented in `/zotero-api` section 1). With `-A curl/8`
the ping and BBT's `cayw?probe=1` answered 200; R ignores `~/.curlrc`, so `vignette_bib.R` ran at once.

## Bibliographies regenerated (Phase 4, 2026-11-12)

Old and new `.bib` compared key by key (title, date, year, DOI, version): every shared key keeps its title, date and
DOI. The only change to a shared key is upstream fwapg's `version = {9a62b0c}` removed, in the chinook and method files,
as intended. Added keys are this branch's own citations: `kirsch_etal2014Fishinventory` (chinook), and the fork entry
(`version = {7c30f58}`) and `wet` (stream splits). None dropped.

The Kirsch et al. (2014) item in the group library was a bare `journalArticle` with no journal, URL or series, so it
would have printed with no way to find it. From the PDF's title page it is ADF&G Fishery Data Series No. 14-04
(January 2014), first author Jonathan M. Kirsch; corrected through the Web API to a report with series, number,
institution and `https://www.adfg.alaska.gov/FedAidPDFs/FDS14-04.pdf` (which served the PDF). The key held. BBT exports
the report number as `eid`, which the article's CSL style does not print, so the reference reads "Fishery Data Series"
without "14-04"; the URL leads to the report. The site rebuilt after it (exit 0) with no `citation … not found`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Zotero local server: empty reply (curl exit 52) to every request | `~/.curlrc`'s browser user agent; send `-A curl/8` (soul#590). Load `/zotero-api` before probing Zotero |
| Auto mode refused the Web API PATCH of the Kirsch item ("External System Writes") | Al switched to manual mode; the PATCH then answered 204 |

A first count of "rule" in the rendered text read zero for every article: its regex wanted 40 characters before each
hit on one line, which a heading or an SVG label never has. The recount over the whole text found the 19 above.

## Code-check (branch, 2026-11-12)

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|---|---|---|---|---|
| 1 | 1 | 1 | 0 | — |
| 2 | 3 | 3 | 0 | n |
| 3 | 5 | 5 | 0 | y (the Kirsch sentence, round 1's fix, still dropped "non-natal … supporting Chinook salmon") |

The mechanism (round 3): sentences written from a summary of a source, or from the intent of a change, and not read
back against the source. Ended by enumeration, not by a quiet round: round 3 tabled every factual sentence the branch
added or reworded (41 rows, `review-round3.md`) against its source; the five that failed were rewritten, and each
rewrite was checked against its source here:

| rewrite | source | holds |
|---|---|---|
| stream splits: a recipe is "a few tables and settings files", each species' thresholds and exceptions one row | link 0.78.1 `configs/default`: 12 files and `overrides/`; `parameters_habitat_thresholds.csv` one row per species | yes |
| chinook: "small tributaries, other than the ones they hatched in, of large rivers that hold chinook", "from earlier fish inventories in Alaska" | `literature_evidence.csv` data row 48, Kirsch et al. 2014 p. 42: "Based on prior AFFI findings … non-natal tributaries to large rivers supporting Chinook salmon" | yes |
| DESCRIPTION: "life history and habitat values from the cited literature with their quotes" | `data/literature_evidence.csv` (values and quotes), `life_history_timing.csv` | yes |
| pkgdown.yaml: apt "slow to download … or unable to resolve it" | logs: 43033711487, 43033679109 resolution errors; 42149377267 slow `Get:` | yes |
| pkgdown.yaml: `dpkg --configure -a` before each second try | reasoned (a limit can end apt mid-install), not observed; harmless when nothing is interrupted | kept |

Six reviewer agents this task (plan review, readability pass, three rounds): one past the five-per-task bound, spent
on the third round's enumeration.
