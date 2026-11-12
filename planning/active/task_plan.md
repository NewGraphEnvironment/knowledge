# Task: Order the species columns knw_link_place() writes, so an evidence build's bytes do not depend on the database (#197)


`knw_link_place()` (`R/link_place.R:50-57`) lists the species it places from `information_schema.columns` with no `ORDER BY`, and builds one group of habitat columns per species in the order the rows came back (`sp_hab`, `sp_access`). Postgres returns catalog rows in whatever order its plan reads them, so two databases holding the same build order the species differently.

Measured on #165 (2026-11-12): `0310` on the same link build, the same commit and the same inputs, on two databases. The species groups came out `pk, sk, st, wct, gr, ko, rb` on one and `gr, ko, pk, rb, sk, st, wct` on the other, in `visits_link.csv` (columns 105-139 and their `_stored` copies, 160-194) and `workbook_sites.csv`. Every value agrees: `data-raw/database_compare.R` reads both tables `identical`, crate's evidence comparison reads them agreeing, and both builds share one `recipe_id`. Only the bytes differ (`scripts/logs/habitat/receipt_165/`).

It is not only bytes. `visits_link.csv`'s md5 is the first of the three md5s every grade table, record and summary carries as `evidence_md5` (the two chinook rearing regrades on #165 differ in that column alone), so a reader that holds a grade or curve to the evidence by those md5s treats the two databases' builds as different evidence though every value agrees. A grade receipt is unaffected: it names the evidence by the build's receipt's `recipe_id`. The published sets are unaffected too: their recipes name the tuning run, and a republish of one run's tables reads the same md5s from them.

`knw_link_access_check()` and `knw_build_record()` read the same catalog but only test membership (`%in%`; SQL `IN` and `intersect()`), so their output does not depend on the order.

## Context (from plan-mode exploration)

`knw_link_place()` (`R/link_place.R:50-57`) reads the species it places from `information_schema.columns` with no
order, so `sp_access` (the `access_<sp>` columns of `streams_access`) and `sp_hab` (the `streams_habitat_<sp>` tables)
come back in each database's catalog order. That order fixes the column order of `placed`, which `scripts/0310` writes
into `visits_link.csv` and `workbook_sites.csv`. On #165 two databases holding one build wrote the same values in
different column orders (`scripts/logs/habitat/receipt_165/`: `species_with_habitat` read `…CO;PK;SK;…` on one and
`…CO;GR;KO;PK;RB;SK;…` on the other), so the bytes, and the `evidence_md5` every grade table carries, differ. Sorting
both lists by name makes the bytes depend on the build only. Nothing published moves until the next evidence build.

Exploration: `sp_access` happened to agree on both databases (column ordinal order) but is equally unordered, so both
lists are sorted. `knw_link_access_check()` and `knw_build_record()` only test membership (as the issue says). The
ledger rows `species_with_access` / `species_with_habitat` (`scripts/0310-evidence-build.R:256-257`) paste the same
lists, so they become deterministic too.

## Decided at the gate

Approved by Al at the plan gate, 2026-11-12:

- Sort in R with `sort(method = "radix")` (the repo's canonical-order rule), not `ORDER BY` in the query: one
  mechanism, testable without a database.
- Both `sp_access` and `sp_hab` are sorted, not only the habitat list the issue measured.

## Phase 1: Order the species and test it

- [x] Write the failing test first in `tests/testthat/test-link_place.R`: a catalog frame (the `table_name`,
      `column_name` rows the query returns, including non-`access_` columns and `streams_habitat_long_vw`-free tables)
      given in two orders (as-is, reversed and shuffled) yields identical species lists, sorted, and identical
      `.knw_place_sql()` text
- [x] Split the catalog parsing out of `knw_link_place()` into `.knw_place_species(cols)` returning
      `list(access =, habitat =)`, each `sort(unique(...), method = "radix")`; `knw_link_place()` calls it and keeps
      its empty-`access` stop
- [x] Restore the bug (drop the sort) and confirm the new test goes red, then put it back
- [x] `@return` says both species lists are sorted by name; `devtools::document()`
- [x] Live test: assert `p$species_access` is sorted (it skips without a database, as now)

## Phase 2: Say what it changes

- [ ] `research/database_builds.md:260` and `research/run_archive.md:98,136`: the column-order difference is fixed from
      this release; the next evidence build's `visits_link.csv` and `workbook_sites.csv` differ from the published
      build's in column order (bytes), not content, and crate's comparison and `data-raw/database_compare.R` read them
      as the same; its `visits_link` md5 (the first of `evidence_md5`) moves accordingly
- [ ] NEWS line drafted in the PR body for `/gh-pr-merge` (it writes NEWS and bumps the version)

## Owed at the end (reported, done after merge)

- [ ] `planning/backlog.md`'s provenance track: note #197 done in its PR (as #165's was, a `[skip ci]` commit after
      the merge)

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: `NOT_CRAN=true` run of `test-link_place.R` (new test red without the sort, green with
it), then the full `devtools::test()`; `lintr` per file/linter/line against an `origin/main` worktree; no evidence
rebuild on this branch (that is the next `0310`, on Al's word).
