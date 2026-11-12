## Outcome

Backlog move 2 (#171) carried #118, #107, #156 and #159 in one branch. The three articles became a series:
"Tuning fish habitat definitions with fish sampling records" (`tuning-method`), "Tuning habitat: chinook rearing"
(`tuning-chinook-rearing`) and the stream-splits article (`tuning-stream-splits`) under "Checks on the method", with
pkgdown redirects from the old URLs, which the website and email drafts link. The method and chinook articles open
from the species' life history, and the articles, README, DESCRIPTION and the comparison map's labels say "fish
habitat definition" at first mention and "habitat definition" after, never "rule"; the README tagline is soul's
ecosystem tagline. The register check now holds `settings.csv` to what the method article prints (every column but
`where` and `note`) rather than its bytes, so the rename's path edits did not stale the bundle. fwapg is cited
upstream with no version, and the fork (with its commit) wherever an article rests on its routed flows. The pkgdown
workflow limits each setup step and tries it a second time. Three code-check rounds found 9 defects, mostly sentences
that claimed more than their source, and one inside round 1's fix; the loop ended on an enumeration of every factual
sentence the branch added. Split out: #200 (README fly row), #201 ("rule" in the method bundle's text, next rebuild),
#202 (older readability gaps).

What was learned: the "Zotero is broken" diagnosis that held Phase 4 for most of a session was the probe. `~/.curlrc`
sets a browser user agent, which Zotero's local server drops; `/zotero-api` (soul#590) already said so, and was not
loaded before probing. The bare Kirsch et al. (2014) item was corrected in the group library (ADF&G Fishery Data
Series 14-04, with its URL).

## Measurement

- CI stalls (#159): 8 runs on 3 days (2026-11-05, 11-06, 11-11), all inside `setup-r` or `setup-r-dependencies`
  before any article rendered, so the tile fetch was not the cause. Some were DNS failures resolving the Ubuntu
  mirror, some crawling downloads (42–287 s between `Get:` lines). 25 healthy runs to 2026-11-12: `setup-r` 28–233 s,
  dependencies 0–624 s, which set the limits at 8 and 15 min (a first guess of 5 and 10 would have cut healthy runs);
  job cap 30 → 40 min. An apt-retries step was added and dropped: the runner image's `zz-retries` overrides it.
- Prose words before → after (no cut forecast; a change of words): method 2,425 → 2,543, chinook 1,356 → 1,413,
  stream splits 1,777 → 1,810, README 851 → 948.
- Tests: 2,296 expectations, 0 failed, 0 errors, 4 skipped. Bibliographies: every key the old and new `.bib` share
  keeps its title, date and DOI; only upstream fwapg's version changed.

## Owed

- GitHub About: the ecosystem tagline the README and DESCRIPTION now carry (`gh repo edit --description`), once main holds them
- Website repo: point the Open Source page's two knowledge links at `tuning-method.html` and
  `tuning-chinook-rearing.html` (a PR there, after the deploy serves the new pages)
- Offer the rendered articles in a form that opens on a phone (with the PR)

Closed by: PR (opened from branch `171-backlog-move-2-public-articles-a-tuning`, last commit before the archive 1bf62cbb)
