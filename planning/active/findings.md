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
