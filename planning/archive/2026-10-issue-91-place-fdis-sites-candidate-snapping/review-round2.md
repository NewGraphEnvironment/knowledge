# Code check, round 2 (#91 branch, after 7b1fa7f / d3ce108)

## Checklist read

- `code-check-python.md` (7,237 bytes): in full (no Python in the diff).
- `code-check.md` (330,698 bytes): the prose of every H3 under `## Mechanisms`, without the table rows (all 14). Of the
  `## Rules that stand alone`, Security and Spreadsheets sections, read only through the index lines; none of their
  headings names a tool or shape this diff uses. Not read in full: about 30 headings.
- `code-check-r.md` (178,405 bytes): in full, "Postgres row order is never fixed…", "A database driver's value is not a
  base R type", "`ifelse()` with an all-NA test…", "Inside a dplyr verb, a column named like a local variable wins",
  "A `data-raw/` script must load the source tree", "Rscript reads a script as it runs". The rest (about 105 headings)
  checked against the diff by their index lines only.
- `code-check-shell.md` (125,440 bytes) and `code-check-spatial.md` (155,517 bytes): index lines only. The diff has no
  shell, and its spatial code is fresh's snap and one PostGIS `ST_DWithin`/`ST_Distance` query, which no heading names.

Checked by running code (in a copy outside the repo): `test-settings-register.R` (261 pass), `test-fdis_place.R` (25),
`test-fdis_quality.R` (13), all 0 fail and 0 error. Read-only DB probe: `fwa_streams_20k_50k` has no NULL
`blue_line_key_20k`, so no hinted row can arrive unconstrained. The committed logs and the derived tables were checked
against the round-1 prose: 10,210 confirmed and 748 moved among the 45,523 rows of `visits_link.csv`; across the
sensitivity's 12 cell-by-key picks, the only pick outside another cell's region is CH 200/200 (`g<=0.13`) against
500/500 (51 rules); 13 nearest lines are 1425 and 3 are 6010. All hold.

## Findings

- **[fragile] `data-raw/vignette_method.R:185-189` with `scripts/0310-evidence-build.R:115-119`: inside a round-1 fix.**
  The fix records the snap limits in two places, and the methodology bundle checks the wrong one. `0310` ledgers
  `snap_limit_m` / `snap_limit_code_m`; its comment says "readers compare these". No reader does: grep finds no
  consumer of those ledger rows. `vignette_method.R` compares the register with `rn()`, which is
  `data/fdis/build/reconcile.csv`, the *current* `0230` build, not the build the evidence came from. Nothing else in
  the script ties that reconcile to the ledger's evidence on a limit-sensitive quantity:
  - line 180 compares `sites_placed`, and placement does not depend on the limits;
  - line 206 compares `visits_link` with the ledger's own drops;
  - line 241 compares only row and placed counts of `fdis_sites.csv`;
  - nothing compares the ledger's `md5_sites` with `sites.rds`.

  So suppose `0230` ran with `SNAP_LIMIT=500 SNAP_LIMIT_CODE=500` and `0310` then built the evidence: this branch's own
  sensitivity sequence. If `0230` is then rerun at the defaults without `0310`, the bundle passes the guard and labels
  the evidence's far-snap drop (0 at 500 m) "more than 200 m from its stream". The reverse order fails loudly, but on
  the wrong artifact: a rerun at an override after a correct build refuses a correct bundle. This is the "field you
  write that your own code never reads back" shape (`code-check.md`, "Verification that reads its own output"). The
  check should read the ledger's rows (`ln("snap_limit_m")`, `ln("snap_limit_code_m")`) and refuse a ledger that lacks
  them. It could also require them to equal `rn()`, so a later `0230` run is caught too.

- **[fragile] `scripts/0230-fdis-load.R:500,525`: one axis over from the round-1 1425/6010 fix.** The reconcile row
  `sites_snap_subsurface_excluded` holds `n_nearest_excluded`, which counts visits whose nearest line is *any*
  `snap_edges_excluded` type. That is 1425 and 6010, so the 2026-10-27 `reconcile.csv` records 16 under a "subsurface"
  label. `research/fdis_export.md` (from the probe) says 13 are subsurface and 3 are 6010 connectors. Round 1 corrected
  prose that called 6010 a generic "connector". This row conflates the two the other way, so anyone reading
  `reconcile.csv` gets a subsurface count 3 too high. Either count `edge_type == 1425` and `== 6010` as separate rows,
  or name the row for the excluded set.

No other issues. The rest of the diff checks out:
- `knw_fdis_place()` and its partitions;
- `0230`'s snap wiring against fresh 0.43.0's `frs_point_snap()`: the `col_blk` hint, `exclude_edge_types = NULL`
  meaning none excluded, and the guards matching `vignette_method.R`'s `near()`;
- the `bigint = "numeric"` id formatting in `0230` and `0240`;
- `0310`'s `SCHEMA`, `knw_build_record()` and walk cache (the cache is keyed on start, load and walk md5, not on the
  schema, which the walk does not read);
- the `info` rows `0310` now carries (no ledger reader filters on `kind`);
- the probe's refusal of a `sites.rds` with `snap_method`;
- the register rows (`test-settings-register.R` passes).
