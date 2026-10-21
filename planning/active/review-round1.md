# Code-check round 1, branch 79 (git diff 67c60ce...HEAD)

## Checklist read

- `code-check-python.md` (7,237 bytes): in full. Nothing applies; the diff has no Python.
- `code-check.md` (329 KB): the prose of all 14 H3 under `## Mechanisms`, table rows skipped. Of the 23 other
  headings, read only the index lines; none names a tool or shape in this diff beyond what the Mechanisms cover.
- `code-check-r.md` (175 KB), 12 of 111 sections read in full: Read-back shape; Moving prose into a code chunk
  (rbbt citation detection); A `data-raw/` script must load the source tree; `$` partial match; `match()` treats NA
  as a value; `tolerance` is relative; `[[` on a named atomic vector; Postgres row order; `sprintf("%g")` into SQL;
  `information_schema` lookup; a dplyr verb's column beats a local variable; `ifelse()` with an all-NA test. 99 not read.
- `code-check-spatial.md` (154 KB), 3 of 92 read: GeoJSON in a projected CRS; a GDAL failure partway through
  `st_read()`; FWA main flow is not edge type 1000 alone. 89 not read.
- `code-check-shell.md` (121 KB), 2 of 67 read, for `vignette_bib.R`'s regex replacements: a variable in a sed
  replacement is parsed; `$1` followed by a digit in a Perl replacement. 65 not read.

## What I checked by running it (scratch copy, no database, no network)

- `test-tune_repick.R` (28 pass), `test-thresholds_table.R` (29 pass), `test-compare_map.R` (39 pass), each with
  `NOT_CRAN=true` and 0 failed and 0 errors.
- `knw_tune_repick()` against `.tune_sel()` and `.tune_pick()`. The region (`ddev_best <= k * se_diff` over converged
  rules), the order (departures, then held-out deviance, then grid order) and the `d_floor` step are the same.
  On every saved table, the one-SE replay gives the `recommended` rule. Rounding to 6 decimals in 0320's CSV cannot
  flip a pick: the closest non-best rule to the 1.96 boundary is 0.0015 deviance away (GR), and to the 1 SE boundary
  0.0024 away (ST).
- The 1.96 picks, region counts and SEs behind in `data/thresholds.csv`, the research table and the article table
  all match a fresh recompute from `data/tune/*_tune.csv`. The `holds_196` values agree too.
- The article renders in both modes (`IN_PKGDOWN` unset gives the static map, `"true"` the widget). Every
  `stopifnot` holds, and all 13 references resolve.
- `knw_compare_mapgl()` on the shipped BULK data (16,686 LINESTRINGs and 310 POLYGONs). `.round_sfc` rounds exactly
  and leaves 0 polygons invalid. The popup properties come out as expected, and the popup expression uses only
  `concat` and `get`, both of which mapgl 0.4.6's `evaluateExpression` supports.

## Findings

- **[security] planning/active/findings.md:101, planning/active/task_plan.md:53**: a home path,
  `` a local folder ``. CLAUDE.md, "One discipline": from 2026-10-16, `planning/` carries "no client or project
  identifiers and no home paths", and these lines were written on 2026-10-20 in a repo being prepared to go public.
  Describe the folder in words (for example, "the source PDFs held locally"), or leave the location out.

- **[security] planning/active/findings.md:110 and :146**: "key injected from the environment per command" and
  "injected per command with the environment". CLAUDE.md's top rule says no tracked file carries
  credential-store references. The `planning/` exception covers "what was removed, hosts and our other
  repositories", not credential handling. No item or vault is named, so this is a lesser case than the home path.
  Still, it records how the Zotero key reaches the shell. Say "the key from the environment", or drop the clause.

- **[fragile] data-raw/vignette_bib.R:70 and :73**: the new title `t` (taken from Zotero's title) is passed as the
  replacement in `sub(..., new, e, perl = TRUE)`. R parses backslashes in a replacement string, so any LaTeX escape
  Better BibTeX writes into a title (`\&`, `\_`, `{\textendash}`) loses its backslash. Measured on R here: a title of
  `{wet}: Flow \& Temp\_x` is written as `{wet}: Flow & Temp_x`. The same applies to the first `sub()` on line 70,
  whose replacement is `paste0("{", x$title, "}: ")`, but that value is a literal and safe. None of the six tool titles
  in the committed `chinook_rearing.bib` has a backslash, so the current file is correct. The script would quietly
  damage the first title that does. To fix it, splice the field by position (`regexpr` then `substr`), or escape the
  replacement first with `gsub("\\\\", "\\\\\\\\", new)`.

No defects found in `R/tune_repick.R`, `R/thresholds_table.R`, `R/compare_map.R`, `data-raw/vignette_chinook.R`,
`vignettes/chinook_rearing.Rmd`, the tests, `scripts/0325-publish.R`, the README or the research files.
