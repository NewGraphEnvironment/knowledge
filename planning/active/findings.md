# Findings — Internal article: the tuning against Bayesian practice, and where it goes next (#204)

## Issue context

**If we do it:** an article at its own URL, not listed in the site's articles index or navbar, linked from one sentence of the methodology article, says in plain terms where the tuning stands against Bayesian practice with the two books cited: what it shares with the out-of-sample comparison *Statistical Rethinking* teaches, where it differs and why that is defensible, and how the method could evolve (what is tested next). It is for us first, a record of where the method is heading, and for the reader who follows the link. **If we never do:** the method's resemblance to Bayesian practice, and its departures (a penalty rather than a posterior, refit group intercepts, a pick and a range rather than a distribution), stay in a research file no reader of the site sees.

From #185's review (`research/bayesian_alignment.md`), which recommended an article state its findings itself rather than point to the research file.

## Decisions

- A separate internal article, not a section of `vignettes/tuning-method.Rmd` (Al, 2026-11-13: "seems relevant but not a main thing we are advertising. its more for educating ourselves how we will evolve"). The methodology article keeps one sentence that links it.

## Proposed

- `vignettes/tuning-bayesian-practice.Rmd`, in the `tuning-<name>` series (#118), listed in `_pkgdown.yml` under an articles section titled `internal`: pkgdown builds it at `articles/tuning-bayesian-practice.html` and leaves it out of the index and navbar. Not a `_<name>.Rmd` draft, which pkgdown skips and `pkgdown.yaml` refuses on the site. Not advertised is not private: the repo and site are public, and anyone with the link reads it.
- One sentence in `vignettes/tuning-method.Rmd`, after "How are two habitat definitions told apart?" (`#se`) or at the gate, linking it.
- Its questions: the held-out comparison and the SE of a difference (aligned), the prior as a penalty at BDA3's scale, what the held-out score measures (ranking within a group, not a new group's level), groups pooled in the curve and fixed in the scorer, the gate, and what changes next (#203). Teach each principle in a sentence before its result, as the series does; it stands alone (`writing.md`, "Write each article to stand alone").
- Cite McElreath (2020) and Gelman et al. (2013) from the group library (`mcelreath2020StatisticalRethinking`, `gelman_etal2013Bayesiandata`): a `bib_write()` line for the new article in `data-raw/vignette_bib.R`, rerun with Zotero running.
- If it adds a number that shapes a result, that number gets a row in `inst/method/settings.csv` and the method bundle is rebuilt by `data-raw/vignette_method.R`, as its header says; numbers it reads come from `method.rds`, not typed.
- Review the rendered article on a phone before the merge.

Waits for #203 (the scorer and curve changes) only if the article describes them as made; otherwise it states the method as it is and lists them as next.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1: the method bundle rebuild (2026-11-13)

- Ignored inputs copied from the main checkout (`data/fdis/derived`, `data/fdis/build`); each md5 equalled the
  bundle's `md5_local` before the run.
- `PGSERVICE=fresh_local Rscript data-raw/vignette_method.R` took 10 s. Against the 2026-11-04 bundle (f6b6d0a),
  every element is `identical()` except: `scope` (new); `meta$written`, `meta$commit`; `meta$md5` gains
  `data/tune/WCT_rear_summary.csv` (the underpowered key's summary, now a source) and `settings.csv`'s md5; and
  `settings`/`resolved` differ only in `where` for `snap_limit`, `snap_limit_code` and `se_strict`. Those paths moved
  after Nov 4, and by #118's rule a moved `where` does not stale the bundle. No printed value moved.
- `scope`: CH rearing 45 of 111 groups, ST rearing 11 of 78, WCT rearing 6 of 14; withheld by the gate: BT spawning
  (by 0.56), CO rearing (by 58.1), WCT rearing (by 106.3); GR rearing published by 14.4.
