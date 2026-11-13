## Outcome

Added `vignettes/tuning-bayesian-practice.Rmd`, an internal pkgdown article (built at its own URL, left out of the
articles index and navbar) that states #185's review, `research/bayesian_alignment.md`, in the reader's terms. It
covers what the tuning shares with *Statistical Rethinking*'s out-of-sample comparison, its three main defensible
departures, and the three things that should change, and it names what is tested next (#203, #186, #70). The
methodology article links it from `#se`. Every number comes from a new `scope` element of `method.rds` (each
published key's groups, groups with both outcomes, and grade gate), which `vignette_method.R` writes and holds to the
keys `data/thresholds.csv` publishes. `bayesian_alignment_check.R` now checks the article's pandoc-cited quotes
against the PDF pages too.

What was learned:
- An `internal` section makes pkgdown 2.2.0 add "More articles..." to the Articles menu. The menu is now written out
  in `_pkgdown.yml`, and a test that the pkgdown workflow runs holds it to the sections; R CMD check has no
  `_pkgdown.yml`, so there the test skips.
- The group library's *Statistical Rethinking* item was a bare `document`; it was PATCHed to a full book record.
- The article took three meaning-audit rounds plus a blind readability pass. Each of rounds 2 and 3 found errors
  inside the previous round's fixes. The worst was the effort term: under the cloglog the offset holds the catch
  *rate* per square metre constant, not the chance of a catch. The same slip was in the research file and was fixed
  there.
- `/code-check branch` took three rounds. Each found a guard that could not fail where it runs:
  - an `==` that passes on `character(0)`;
  - a test that only ever skips in CI;
  - a key set narrowed by an earlier fix.
  The loop ended on an enumeration of all 38 guards the branch adds.

## Measurement

- The `method.rds` rebuild (10 s on this machine, `PGSERVICE=fresh_local`) matched the 2026-11-04 bundle in every
  element except:
  - `scope`, new;
  - `meta`'s date, commit and two md5s (`settings.csv`; the WCT rearing summary, a new source);
  - the register's `where` paths for three keys. Those paths moved after Nov 4, and by #118 they do not stale the
    bundle.
- From `scope`, the groups the scorer keeps:
  - chinook rearing: 45 of 111;
  - steelhead rearing: 11 of 78;
  - westslope cutthroat rearing: 6 of 14;
  - bull trout spawning: 22 of 50.
- The gate withholds bull trout spawning (by 0.56 in deviance), coho rearing (58.1) and westslope cutthroat rearing
  (106.3).
- Tests: `devtools::test()` FAIL 0, PASS 2323, SKIP 3. `check_pkgdown()` reports no problems. The quote check
  passes 23 quotes in the research file and 5 in the article.
- Agents spawned: 1 plan review, 1 readability pass, 3 meaning audits and 3 code-check rounds, 8 in all. That is
  over the five-per-task bound; the audits' rounds 2 and 3 and code-check round 3 each found a defect inside an
  earlier fix.

## Evidence

- `scripts/logs/habitat/20261113_bayesian_alignment_check*`
- This archive's `review-*.md`

Closed by: PR (opened next, from branch `204-internal-article-the-tuning-against-baye`)
