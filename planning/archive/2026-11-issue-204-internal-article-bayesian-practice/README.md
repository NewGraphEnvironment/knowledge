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

## Revision after Al's review (2026-11-13)

Al asked why the article said `link` cuts streams at fish records when the tuning had moved to the minimal network,
what "the gate" is, for a better title, for Cauchy to be defined, and for figures. Measured: the published tuning
(#145) reads `link` 0.78.2's full network with the minimal run's flows and range, not the minimal network (#120,
not promoted), so the sentence held but was out of date. On the published network 44.2 % of visits with fish start
their own segment against 6.6 % of empty ones (86 % against 10 % on 0.66.0; 3.4 % against 3.0 % on the minimal
network), and chinook rearing's slope limit is 13 % on it against 9 % on the minimal network and through minimal
parents.

Changes: retitled "Checking the tuning of fish habitat definitions against Bayesian practice"; "the gate" is the
publishing test throughout; the prior section defines Cauchy against the tuning's normal (beyond three scales: 0.3 %
of the normal, 20 % of the Cauchy) with a figure; the pooling section explains why a group with one outcome is
dropped, with a figure; the publishing test and the cuts at fish records each get a figure, the cuts their own
section and #120 a next-step bullet; a glossary closes the article. `knw_tune_run()`'s scoring population moved into
`.tune_base()`/`.tune_population()`, which `vignette_method.R` calls to split each key's dropped groups by outcome,
stopping unless it reproduces the summaries' counts: chinook rearing keeps 45 of 111 groups and drops 65 where no
site caught chinook and 1 where every site did; in every key the never-caught groups outnumber the all-caught ones.
`fish.rds`, which that needs, is not restored by `0336` (#214, filed).

Review: four code-check rounds (`review-revision-round*.md`): round 1 four findings (a result credited to fish-record
cuts alone, a network described too narrowly, an issue's status, a proxy guard); round 2 clean; round 3, an
enumeration of every claim, found the research file's line cites broken by the refactor and a clause inside round 1's
fix that the sources rule out; round 4 re-enumerated the fixed lines and found two wording gaps, fixed by hand. Tests
FAIL 0, PASS 2326, SKIP 3; both quote checks pass. Agents this revision: 4, 12 for the issue.

## Evidence

- `scripts/logs/habitat/20261113_bayesian_alignment_check*`
- This archive's `review-*.md`

Closed by: PR (opened next, from branch `204-internal-article-the-tuning-against-baye`)
