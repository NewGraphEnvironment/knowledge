# Findings — Order the species columns knw_link_place() writes (#197)

## Issue context

**If we do it:** two evidence builds of one build on two databases write `visits_link.csv` and `workbook_sites.csv` with the same bytes, as four of the other five already are (`access_check.csv` moves by its float sums). **If we never do:** those two tables' bytes depend on the database's catalog, so a byte comparison of two evidence builds reads a difference that is not one, and only a column-matching comparison (crate's, `data-raw/database_compare.R`) sees through it.

## Problem

`knw_link_place()` (`R/link_place.R:50-57`) lists the species it places from `information_schema.columns` with no `ORDER BY`, and builds one group of habitat columns per species in the order the rows came back (`sp_hab`, `sp_access`). Postgres returns catalog rows in whatever order its plan reads them, so two databases holding the same build order the species differently.

Measured on #165 (2026-11-12): `0310` on the same link build, the same commit and the same inputs, on two databases. The species groups came out `pk, sk, st, wct, gr, ko, rb` on one and `gr, ko, pk, rb, sk, st, wct` on the other, in `visits_link.csv` (columns 105-139 and their `_stored` copies, 160-194) and `workbook_sites.csv`. Every value agrees: `data-raw/database_compare.R` reads both tables `identical`, crate's evidence comparison reads them agreeing, and both builds share one `recipe_id`. Only the bytes differ (`scripts/logs/habitat/receipt_165/`).

It is not only bytes. `visits_link.csv`'s md5 is the first of the three md5s every grade table, record and summary carries as `evidence_md5` (the two chinook rearing regrades on #165 differ in that column alone), so a reader that holds a grade or curve to the evidence by those md5s treats the two databases' builds as different evidence though every value agrees. A grade receipt is unaffected: it names the evidence by the build's receipt's `recipe_id`. The published sets are unaffected too: their recipes name the tuning run, and a republish of one run's tables reads the same md5s from them.

`knw_link_access_check()` and `knw_build_record()` read the same catalog but only test membership (`%in%`; SQL `IN` and `intersect()`), so their output does not depend on the order.

## Proposed

- [ ] Order the species `knw_link_place()` builds columns for by name (`sort(method = "radix")`, or `ORDER BY table_name, ordinal_position` in the query), and test that a catalog returning rows in another order gives the same columns in the same order
- [ ] Note that the next evidence build's two tables then differ in bytes, not content, from the published build's; crate's comparison and the hand comparison both read them as the same

Relates to #165 (where it was measured), #160 (the evidence build's receipt)

## Exploration (2026-11-12)

- `receipt_165` ledgers: `species_with_access` read `BT;CH;CM;CO;PK;SK;ST;WCT;G…` on both databases (the column
  ordinal order of `streams_access`, by luck); `species_with_habitat` read `…CO;PK;SK;…` on the host and
  `…CO;GR;KO;PK;RB;SK;…` on the second. Sorted, both lists read `BT;CH;CM;CO;GR;KO;PK;RB;SK;ST;WCT`.
- Sorting moves the `access_<sp>` columns too (GR, KO, RB move ahead of PK…), so the next build's column order
  differs from the published build's in both groups.
- Prose citing #197: `research/database_builds.md:260`, `research/run_archive.md:98,136`; backlog provenance track.

## Errors Encountered

| Error | Resolution |
|-------|------------|
