# Findings — One-SE region: state it as a heuristic, publish 1.96 beside it, and give the article references (#79)

## Issue context

**If done:** the chinook rearing article states the one-standard-error rule as the heuristic it is, shows which tuned rules hold under a stricter bar, and cites its methods and data with versioned references; the README credits the author of the upstream tools it reads. **If never:** the published thresholds rest on a threshold presented as "the boundary of noise", which the literature does not support, and the article credits none of the software or data it is built on.

## Problem

The tuning keeps every rule within one standard error of the best (the "region") and picks the region rule closest to link's `default`. The article says "a gap under one standard error cannot be told from noise". The sources say otherwise:

- The rule was "first proposed for selecting the right sized tree" (Chen & Yang 2021, §1.3, citing Breiman et al. 1984). Hastie, Tibshirani & Friedman (2009) give its only rationale: it "acknowledges the fact that the tradeoff curve is estimated with error, and hence takes a conservative approach" (p. 61); §7.10 (p. 244) uses it with no citation, and its own example picks 9 predictors where the true model has 10.
- Chen & Yang (2021, §6): "there is no evidence confirming that the 1se rule can consistently outperform the regular CV"; the SE it uses can be 100 % over- or underestimated; it helps sparse variable selection and often hurts estimation.
- Bengio & Grandvalet (2004): no unbiased estimator of the variance of K-fold cross-validation exists. Bates, Hastie & Tibshirani (2024): the usual CV variance is too small and its intervals undercover; a nested scheme fixes it.

The threshold decides the result. Recomputed from `data/tune/*_tune.csv` with the same pick rule (fewest departures from `default`, then score, 200 m exception floor), the 1-SE picks reproduce the published ones; at 1.96 SE five of eight species × stages keep `default`:

| rule | `default` behind best (SE) | pick at 1 SE | pick at 1.96 SE |
|---|---|---|---|
| BT rear | 1.58 | MAD ≥ 0.35, ≤ 10.49 % | `default` |
| BT spawn | 1.06 | MAD ≥ 0.75, ≤ 5.49 %, river exception | `default` |
| CH rear | 2.40 | MAD ≥ 0.75, ≤ 9 %, river within 1 km | MAD ≥ 0.75, ≤ 5.49 %, no exception |
| CO rear | 2.47 | MAD ≥ 0.03, ≤ 4 % | width ≥ 1.5, ≤ 4 % |
| GR rear | 0.89 | `default` | `default` |
| RB rear | 2.36 | width ≥ 3, ≤ 9 % | width ≥ 3, ≤ 8.49 % |
| ST rear | 1.42 | MAD ≥ 1, ≤ 8.49 % | `default` |
| WCT rear | 1.33 | width ≥ 1.5, ≤ 4 % | `default` |

The article also has no bibliography (no `bibliography:`, no `[@key]`), and the README's Data and methods names fwapg, bcfishpass and bcfishobs without their author.

## Decided (Al, 2026-10-20)

- **Keep 1 SE, publish 1.96 beside it** (option 1): name the threshold as a choice, not a noise boundary, and mark which recommendations hold at 1.96.
- **The article gets a bibliography.** The README does not get a references list (a software reference needs a version, which a README must not carry); the readme convention is not amended for it.
- **The README credits the author:** fwapg, bcfishobs and bcfishpass are Simon Norris's (Hillcrest Geographics), bcfishpass with contributions from many groups, as link's README words it.
- **#80's results stay out of this article.** The flow-starting-point and wetland-design comparison runs on the current flows, which #73 replaces; it adds its own section to this article after that retune. Here the article only says every comparison is against link's width rule.
- **The article gets an interactive map** (Al, 2026-10-20): a website-only map of the Bulkley, with the static map kept for print, figure numbering and the package copy. It stands in for the zoomed panel and numbered-examples table the outline cuts. Background: Carto Voyager or OpenFreeMap, whose terms suit a public site (Esri World Topo stays for the internal review maps in #81).
- **Zotero collections** (Al, 2026-10-20), in the group library, using what exists:
  - the one-SE and cross-validation sources (Breiman et al. 1984, Hastie et al. 2009, Chen & Yang 2021, Bengio & Grandvalet 2004, Bates et al. 2024) in a new `statistics/model_selection` subcollection; `statistics` exists, with 4 Bayesian-methods items;
  - glmnet, and link, fresh, wet, flooded and stac_floodplains_bc (from each repo's `CITATION.cff` where it has one), in `software`;
  - fwapg, bcfishpass and bcfishobs are already in `software` and `Fisheries/Fish Passage/references`: merge the duplicates (bcfishobs five items, fwapg and bcfishpass three each, titles in mixed case), keeping both collection memberships;
  - not `Fisheries/habitat_modelling`, which feeds the `habitat_modelling` search store (`0270`) and holds fish-habitat literature.

## Proposed: a shorter, plainer article (Al asked 2026-10-20)

Now about 2,650 words of prose, 11 sections, 6 figures or tables. Target about 1,400 words, 8 sections, every key idea kept, plain words.

| new section | says | from (words now → target) |
|---|---|---|
| The answer | the rule the records support, how it differs from link's current rule, how much less habitat; the cut-offs are a judgment call | opening (kept) |
| What does link do now? | the stream condition in three sentences; rivers, wetlands, lakes move to the last section | "What does `default` draw" (190 → ~60) |
| What records were used? | where crews fished and whether they caught chinook; visit and watershed counts; filtering in one sentence | "What evidence" (249 → ~90) |
| How were rules compared? | three dials (smallest stream, steepest slope, near-a-river allowance); scored on watersheds the rule never saw; lower is better; ranges, not every value | "Which rules were tried" + "How is a rule scored" (259 → ~130) |
| Which rule fits best, and how sure are we? | close-call rules by a common rule of thumb (cited); the 1.96 table as the stricter check; two other checks (another random split, choosing on some watersheds and testing on others) | three sections (701 → ~350) |
| Why does a nearby river matter? | young chinook use small streams beside big rivers; keep the table | (205 → ~120) |
| What changes on the ground? | Bulkley map, province-wide change, one check (catch rate inside vs outside) | (369 → ~200) |
| Before you use it | four one-sentence points: young chinook in streams only; cut-offs are a judgment call; steeper slopes fit nearly as well; map distance from each segment's bottom end | (342 → ~150) |
| References | the bibliography | replaces "Software and how to cite it" |

Cut: the "how good each value can be" plot (the 1.96 table says it plainer); the numbered-examples table and the map's zoomed panel; the breakdown of small causes of change (one sentence); bootstrap percentages (one line: the shape is steady, the slope limit is not).

Plain words: deviance → score; folds → watersheds set aside; MAD → average flow; the exception → the near-a-river allowance; connectivity pass → the step that keeps rearing only where it links to spawning; region → close-call rules, explained once in its own place.

Measure: word count before and after against the 1,400 target, and what set the floor (soul's writing.md, "Measure the simplification").

## Tasks

- [ ] Zotero (group library, collections as decided above): add Chen & Yang 2021, Bengio & Grandvalet 2004, Bates et al. 2024, Hastie et al. 2009, glmnet, and Breiman et al. 1984 (metadata only; no copy held); add link, fresh, wet, flooded from their `CITATION.cff`, and stac_floodplains_bc; merge the duplicate fwapg, bcfishpass and bcfishobs items
- [ ] Article: reword the region sentence (one SE as a parsimony heuristic, fixed before the run, citing its sources); add the 1.96 sensitivity table computed inline from the tune tables
- [ ] Article: `bibliography:` from a committed `.bib` that a `data-raw/` script writes from Zotero (pkgdown builds in CI without Zotero); cite link, fresh, wet, fwapg, bcfishpass, bcfishobs, FDIS and the one-SE sources with versions; check the rendered page shows the references section
- [ ] `research/chinook_rearing_tuned.md` and `research/habitat_thresholds_tuned.md`: the same correction to "within one SE" wording, and the 1.96 table
- [ ] Article: restructure and shorten to the proposed outline above, in plain words; report words before and after
- [ ] Article: say what the comparison is against, in words that stay true: "link can size streams by width or by flow, set group by group. Its `default` uses width in every group, and every comparison here is against that. link's own flow cut-offs were scored as candidates, not used as the starting point." The flow comparison itself is #80.
- [ ] Article, "Before you use it": one sentence that a stretch through a wetland of 1 ha or more is rearing under both rules whatever its size, slope or distance from a river (link's wetland rule), about 10,200 km of CH rearing with a median grade of 0.03 (measured 2026-10-20 on the saved comparison); stated as what the product does, with no pointer to pending work
- [ ] `knw_compare_map()`'s interactive map (used by the article first, then #81): hex colours in place of R's `grey80` / `grey85`, which MapLibre rejects so no layer draws; legend bottom-left and the layer switch top-right so they do not overlap; a grade legend beside the rules legend; a click popup per segment with class, grade, average flow, channel width, gradient, distance to the rule's river, stream order and which of link's rules kept it; a background argument
- [ ] Article: the interactive Bulkley map, drawn only when pkgdown builds the site (static map otherwise), from `inst/vignette-data/` with coordinates rounded and only the fields the popups need; check the built page's size (about 5 MB, 1 MB compressed, measured on a test copy 2026-10-20) and that it renders
- [ ] README Data and methods: the authorship clause
- [ ] `data/thresholds.csv` consumers (link#346): say which rows hold at 1.96 before the thresholds are uploaded

## Context

Sources held locally (PDFs) for filing: Chen & Yang 2021 (*Stats* 4(4):868–892), Bengio & Grandvalet 2004 (JMLR 5:1089–1105), Bates et al. (arXiv 2104.00673v4; JASA 2024 119(546):1434–1445), ESL 2nd ed. 12th printing. Breiman et al. 1984 is not held.

## Plan-mode exploration (2026-10-20)

- `.tune_sel()` (`R/tune_score.R`) sets the region as `tot - tot[best] <= se`; the tune csv carries `ddev_best`,
  `se_diff` and `converged`, so a region at k SE is `converged & ddev_best <= k * se_diff`, and `.tune_pick()`'s
  order (departures, then score; `d_floor` 200) can be replayed on the csv alone.
- `thresholds.csv` is not uploaded: `aws s3 ls s3://fresh-bc/knowledge/` lists only `fdis/`.
- Zotero group library (guarded copy, 2026-10-20): `statistics` (4 items), `software` (52),
  `Fisheries/Fish Passage/references` (84). By title: fwapg TRP69TAY (`norris2024smnorrisfwapg`, software),
  3QKQ8RBH (`norris2021SmnorrisFwapg`, references); bcfishpass JDFRATD9 (`norris2024smnorrisbcfishpass`, software),
  LNXZ5KDE (`norris2021SmnorrisBcfishpass`, references); bcfishobs 2ANZTWMP (`norris2024smnorrisbcfishobs`,
  software), C7SJX5IU (`norris2021smnorrisbcfishobs`, software), K7NDE7QF (`norris2022smnorrisbcfishobs`,
  references), UIYJKXDC (`norris2022smnorrisbcfishobsa`, references + software). None of the one-SE sources, glmnet,
  link, fresh, wet, flooded or stac_floodplains_bc is in the library.
- Local checkouts citing the keys (`.Rmd`/`.qmd`): `norris2024smnorrisbcfishobs` 26 files,
  `norris2024smnorrisbcfishpass` 8, `norris2024smnorrisfwapg` 1, every other duplicate key 0.
- Evidence ledger `scripts/logs/habitat/20261017_evidence_build_ledger.csv`: link 0.66.0 (a17e9177…;ee21eb13…),
  fresh 0.39.0 (e247ca19…), fwapg sha f9718cb7…, wet `discharge/fwa/v1` built 2026-10-15T02:06:57Z.
- `CITATION.cff` present in link, fresh, wet, flooded; absent in stac_floodplains_bc.
- PDFs in a local folder: `2104.00673v4.pdf` (Bates), `grandvalet04a.pdf`, `stats-04-00051.pdf` (Chen & Yang),
  `ESLII_print12_toc.pdf`, plus the cv.glmnet page and an R SE-rule pruning help page.
- mapgl 0.4.6: `carto_style()`, `openfreemap_style()`, `add_line_layer(popup =)`.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Zotero filing (Phase 1, 2026-10-20, Web API, key injected from the environment per command)

- New subcollection `statistics/model_selection` (K2P7XGFG). Items, with the item key: Chen & Yang 2021 64V43FIF,
  Bengio & Grandvalet 2004 897I4775, Bates, Hastie & Tibshirani 2024 DN7K8IDE (arXiv v4 attached as the preprint),
  Hastie, Tibshirani & Friedman 2009 HIFGGNV2 (full 2nd ed. 12th printing; CrossRef has no subtitle, taken from the
  title page), Breiman et al. 1984 BBA2Q7W2 (metadata only, OpenLibrary ISBN 0534980538). PDFs: the server already held
  each file (upload authorisation answered `exists`), so each attachment registered without an upload.
- `software`: glmnet (Friedman, Hastie & Tibshirani 2010, JSS) HQR5HXSS, link TZPVPG42, fresh 9A9WTK26, wet PK7HW9S6,
  flooded ZA7A3PZ5, stac_floodplains_bc 997T7F8N (no CITATION.cff; title from its repository description).
- FDIS: no item existed (only per-project `fdisdat` attachments), so a dataset item, Province of British Columbia,
  243TD7QM, unfiled (no collection is named for data).
- Merges: each master keeps its title (its Better BibTeX key is cited by report repos), gains `software` +
  `Fisheries/Fish Passage/references` and a `dc:replaces` per copy; copies trashed: fwapg 3QKQ8RBH, bcfishpass
  LNXZ5KDE, bcfishobs C7SJX5IU, K7NDE7QF, UIYJKXDC. The issue's 3/3/5 counted copies already in the trash (fwapg
  NX4NTJFN, bcfishpass TDT6ZC48); by URL bcfishobs had four live copies.

## Better BibTeX keys (read back 2026-10-20 23:56 UTC from a guarded `zotero.sqlite` copy, about 2 min after filing)

chen_yang2021OneStandard, bengio_grandvalet2004NoUnbiased, bates_etal2024CrossValidationWhat,
hastie_etal2009ElementsStatistical, breiman_etal1984ClassificationRegression, friedman_etal2010RegularizationPaths,
irvine2026linkDevelop, irvine2026freshFreshwater, irvine2026wetStream, irvine2026floodedMap,
irvine2026stac_floodplains_bcSTAC, provinceofbritishcolumbia2022FisheriesData. The masters' keys are unchanged
(norris2024smnorris{fwapg,bcfishpass,bcfishobs}); the five copies are in the trash. All four PDFs are in local storage.

## How the references render (pandoc 3.9.0.2, default Chicago author-date)

- `@software` prints a version as "V. 0.66.0. Released."; `@misc` as "Version 0.66.0."; `note` is dropped by both.
- A version of more than one token ("0.66.0 (commit a17e917)", "not recorded") prints "Versions ...", so each version is
  one token and bcfishpass and bcfishobs, whose versions the run did not record, carry none.
- Better BibTeX's biblatex export carries `file = {/Users/...}` per attachment: `vignette_bib.R` strips it, with
  abstract, keywords, urldate and origdate, and refuses an entry still holding a local path.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `ZOTERO_API_KEY` unset in shell and R | injected per command with the environment; Al approves each prompt (first prompt timed out unanswered) |
| Carto Voyager blank under the widget; "Layer water already exists" | the style has its own `water` layer: ids prefixed `knw_` |
| popup showed `match,get,vt,...` as text | mapgl 0.4.6's evaluator reads only get/concat/to-string/to-number/number-format: display strings |
| `vignette_bib.R` found no title | perl `.` does not cross newlines: `(?s)`; a lazy `\{.*?\},` stopped inside link's title: anchored to the line end |
