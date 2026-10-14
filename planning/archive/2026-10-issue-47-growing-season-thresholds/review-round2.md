# Code check, round 2

## Clean

No issues found.

What was checked:
- Hand enumerations of the evidence vocabulary outside `pkg/R/literature.R`: `scripts/0280-literature-verify.R` names
  `temperature`, `degree_days`, `instream_flow`, `depth` and `velocity` only in its thermal and flow grids, which
  `fish_length` is not meant to fill. Its `SCALE` reads `mm` as x1 or x10 from cm, which suits a length in mm.
  `scripts/0150-store.R` names no variable and reads neither members CSV.
- `0270` reads the additions through `csv.DictReader` and `row.get(k)`, by name rather than position. All 8 rows of
  `data/temperature_additions.csv` parse to 18 fields with no overflow. `bookTitle`, `pages`, `series` and
  `seriesNumber` are valid Zotero `bookSection` fields. A report or thesis row that filled one its type lacks would get
  a 400 that 0270 reports as `CREATE-FAIL`, and no row does.
- The two `data/rag/pdf/` sources exist locally and follow a precedent: `flow_additions.csv` also points at that
  ignored cache.
- Tests, run in a copy at `scratchpad/r2Eqan3k`: test-literature.R gives 44 results with 0 failed and 0 errors.
  Mutations to the copy each turned the tests red:
  - fish_length dropped from `.knw_metric_fits()`: 2 tests failed.
  - fish_length dropped from the unit `fits`: 1 failed.
  - fish_length dropped from `vocab$variable`: 2 failed.
  - a loosened metric set (`growing_season` added): 1 failed.
- The committed `data/literature_evidence.csv` reads cleanly through the changed `knw_literature_read()`. It has
  9 valued fish_length rows, all in mm, with metrics fork_length 4, total_length 3 and unstated 2, plus 9 rows with
  no value.
