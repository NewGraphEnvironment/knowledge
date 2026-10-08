# Review p3, round 1: FLOW grid in 0280, flow units and 7day_low rule

Scope: staged diff (`pkg/R/literature.R`, `pkg/man/knw_literature_vocab.Rd`, `pkg/tests/testthat/test-literature.R`,
`scripts/0280-literature-verify.R`, `scripts/README.md`). I read all of 0280, literature.R and the README's 0270 / 0280
section in full, ran the literature tests, and ran the grid code alone against the committed evidence table plus
synthetic rows (no repo file edited; scratch script in the session scratchpad).

## Clean

No bugs found. What I checked, and what each check showed:

- **NA traps in `meets_flow()`.** `.literature_check()` stops on a blank `species_code`, and `life_stage`,
  `variable` and `kind` are in `required`, so all four are non-NA by the time 0280 sees `ev`. The `==` comparisons
  therefore cannot produce NA. `unit` and `bound` can be NA, and both go through `%in%`: an NA unit is "not bankfull"
  (TRUE, so a `none` row with no unit counts), and an NA bound meets no cell, so a `none` row must name its bound.
  That matches the header comment ("A `none` row meets a cell by the same bound") and THERMAL's `meets()`.
  `valued | kind == "none"` keeps out `qual` rows, which the reader stops from carrying a value.
- **Synthetic rows** (GR depth spawning): bankfull `min` 1 → not counted; `qual` `min` → not counted; `none` `min`
  → counted; `cm` `range` 10–20 → counted. `meets_flow` returned 2, which is correct.
- **Grid shape.** `merge(by = NULL)` is a cross join (7 × 9 = 63). The skip join removes exactly the three SK cells,
  leaving 60, and SK keeps instream_flow spawning, incubation and migration, both depth cells and velocity spawning.
  Each cell is computed from its own row (`flow[i, ]`), so the row order of `merge()` does not matter, and neither
  does the non-contiguous row names left by the subset.
- **Baseline** against the committed table: 2 of 60 (CH instream_flow migration: 1 row; BT velocity spawning:
  2 rows). This matches progress.md.
- **Print and exit.** The printed columns (`species_code`, `variable`, `life_stage`, `side`) all exist on `flow`,
  and none of THERMAL's (`window`) is referenced. `rows` is integer from `vapply(..., integer(1))` and cannot be NA
  (above), so `any(flow$rows == 0)` in the `if` cannot be NA.
- **`percent MAD` scale c(1, 100).** A quote "20 % MAD" with value 0.2 fails: the set is {20, 2000}. A quote that
  writes a proportion ("0.2 MAD") verifies a value of 20, which is the purpose. "Q95" tokenizes as `q`, `95`, so a
  `percent exceedance` value of 95 verifies at scale 1. `percentile` and `percent exceedance` have no SCALE entry,
  so they read at scale 1 and fail closed, as the comment says.
- **literature.R.** `percentile` and `percent exceedance` are in the vocab and fit only `instream_flow`. The
  `7day_low` rule excludes `none` rows, which already need a note, and no committed row uses `7day_low`, so
  existing data still reads. Tests: `FAIL 0 | PASS 116` on the literature filter. The new test's assumptions
  hold: fixture row 1 is gradient, has no note, and `daily_mean` fits instream_flow.
- **README.** The claims match the code: the unit list for instream_flow, the FLOW species and cells, min/range/
  optimum for a need, never `m bankfull` for depth, max/range for velocity, and the SK skips. The additions-`pdf`
  local-path claim is supported by `addition_pdf()` in 0270, and `data/rag/pdf/` is ignored (`.gitignore:6`).

## Notes (not defects)

- **The gate is now red by design.** With 2 of 60 cells met, every 0280 run exits 1 until the grid is filled. The
  plan says this (the grid "joins the exit condition"). The consequence is that anyone running 0280 to check an
  unrelated evidence or registry change on this branch, or on main after merge, gets a failing exit and has to
  read the summary to see why.
- **The ×100 rescale also widens what verifies.** Because `percent MAD` now takes c(1, 100), a value 100 times
  *any* number in the quote verifies. For example, a quote containing "for 1 month" lets a value of 100 `percent
  MAD` pass. This is the same exposure `percent` already has, and the gate checks words, not meaning (CLAUDE.md).
  It is one more thing for the per-row meaning audit to catch.
- **Pre-existing, outside the diff.** The 0270 docstring (lines 26-27) still says an additions `pdf` is a URL or
  `zotero:<key>`. `addition_pdf()` also accepts a repo-root path, which the README now documents.
