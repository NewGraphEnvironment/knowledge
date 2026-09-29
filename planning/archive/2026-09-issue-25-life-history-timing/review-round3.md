# Code-check round 3: #25 timing reader + seed

## Mechanism

All four earlier findings come from one habit. Each check decides "absent" or "the case" with its own
local predicate, and it tests that predicate only against the representation the author had in mind:

- 01-01..12-31 as both the head and the tail of a split
- blank as NA
- only rows that have both ends
- whitespace trimmed with `[ \t\r\n]`

The reader normalizes blanks once, at the top. The seed script never normalizes. Its row filters
(`lost`, `across`, dedup) each pick their own subset. The findings.md table only lists reader checks
by row scope, so it cannot see the seed-side half of the mechanism. The reader rows in it hold, with
the exceptions in findings 3 and 4 below.

Everything was probed. The seed mutations ran on a copy of the script, against a throwaway git copy
of the template CSV, with output sent to the scratchpad. `data/` was not changed.

## Findings

- **[medium]** scripts/0260-timing-seed.R:57 (and 94/97/106/195). The seed reads the template
  with no `trimws()`, so a whitespace-only cell counts as a value. This is round 4's instance in the
  other caller. I measured it by putting `" "` in citation_1 on source line 3 (CH spawning, Bulkley).
  The run exited 0 and reported "27 citation(s) carried": `before_cite` trims `" "` to `""`, and
  `grepl("", ..., fixed = TRUE)` matches anything. The CSV was written with `source = " "`.
  `knw_timing_read()` then trims that to NA. So the row reaches consumers with no source and without
  the "no source in template; to confirm with knowledge holders" note: its provenance flag is
  silently gone. The same predicate gap reaches `dated`, `other_dated`, `across` and the `note` column.
  Date and code cells fail loudly (regex / `%in%` stopifnot). The current source has no such cells,
  so this is latent. Fix: normalize blanks once after `read.csv`, the same way the reader does.

- **[low-medium]** scripts/0260-timing-seed.R:97 and 103. The `lost` log only sees rows that are
  undated in *both* areas. Take a row where one area has a citation but no dates, and the other area
  has dates *and its own* citation. `across` does not fire, because the other area's cite is not NA.
  `long[long$dated, ]` then drops that citation without a log line. `before_cite` (line 166) is
  computed after this drop, so the "every citation on a dated source row lands" invariant (header
  line 26) cannot see it. The current source has no such row (checked with awk; the only one-area case
  is row 8, which `across` handles). Latent, but the invariant claims to cover it.

- **[low-medium]** scripts/0260-timing-seed.R:138-150. Dropping exact repeats carries the dropped
  row's citation across, but not its note. I measured it by adding the note "dropped note X" to source
  line 33 (the BT incubation 1901 repeat). The run exited 0 with every invariant passing. The note
  appears on MORR BT incubation and is gone from BULK BT incubation. No invariant covers notes. Fix:
  merge `note` exactly as `cite` is merged at line 146.

- **[low]** pkg/R/timing.R:106-117. The overlap check only sees complete rows, so two *identical*
  half windows (for example two `08-15..NA` rows for one key) both pass. The probe returned 3 rows
  from a 2-window input. This is narrower than the accepted "half vs full" tradeoff: the known end
  day is covered twice for certain. The seed header's claim (line 25) that knw_timing_read refuses a
  doubled window is false for half windows.

- **[low]** pkg/R/timing.R:119-121. The whole-year exclusion from round 1 is by index only
  (`outer(!=)`). So a 01-01..12-31 row beside any other row for the same key that ends 12-31 (or
  starts 01-01), such as a half window `NA..12-31`, is refused as "window split at 1 January; write it
  as one row with start > end". Refusing is right, since the days overlap. The message points at a
  remedy that does not apply. The seed (lines 179-180) excludes whole-year rows from both halves; the
  reader does not. This is the same rule fixed in one of its two callers.

- **[low]** pkg/R/timing.R:48, 97-98. `wsg_code = character(0)` or `species_code = character(0)`
  passes `vld_character`. `setdiff(character(0), ...)` is empty, so there is no warning, and the
  function returns 0 rows with nothing said. A computed empty filter therefore reads as "no data",
  which is the outcome the doc says the absent-code warning exists to prevent.

- **[low]** pkg/R/timing.R:56-57. `trimws()` strips only `[ \t\r\n]`. A no-break space (U+00A0)
  code gets past the blank check (the probe returned 2 rows with `species_code = " "`). This is
  round 4 one axis over. It matters only for hand-edited or spreadsheet-exported files.
  `trimws(v, whitespace = "[\\h\\v]")` closes it.

Not flagged: the seed's `grepl(cite, ..., fixed = TRUE)` at line 225 is a substring test rather than
a token test. It is harmless with the current keys, but it is how the blank-citation case above
passed.
