# Code-check round 2: #19 phase 1 (review of the round-1 fixes)

Reviewer: subagent, 2026-09-29. Suite: `devtools::test()` in `pkg/` gives 104 pass, 0 fail, 0 warn.

## Findings

- **[fragile] pkg/R/literature.R:101-102 (`first()`)**: the round-1 fix (c) reproduces one axis over.
  `read.csv()` defaults to `blank.lines.skip = TRUE`, so a blank line anywhere above the offending row
  shifts the real file line as well, not only a quoted line break (the comment names only that case).
  Measured on a scratch file: header, blank, row, blank, row, row with `kind = "guess"`. The error said
  `(data row 3, file line 4)`, but the row is on **line 6**. Stray blank lines are a common by-product of
  hand edits, which is exactly when the pointer gets used. The "data row" half is still correct. Either
  drop "file line", or map rows to physical lines. For example, count the non-blank, non-continuation
  lines, or `count.fields()` on the same text. Low severity: it sends a human to the wrong line, but it
  corrupts no data.

## Fix (a) `.knw_read_csv()`: behaviour compared with the old read path

The old `read.csv(path, ..., fileEncoding = "UTF-8-BOM")` and `.knw_read_csv()` were run side by side
(`all.equal`, and `identical` where relevant) on crafted byte files. Results were **identical** for all of
these: a UTF-8 BOM, CRLF, CR-only (classic Mac), an embedded LF or CRLF inside a quoted field, no trailing
newline, a header-only file with and without a newline, a BOM-only file, blank lines, `""` cells, `#`
in a cell, an apostrophe, a trailing ^Z, whitespace-only trailing lines, and non-ASCII text (NBSP,
degree sign, `≤`, em space). An empty file raises the same error on both paths ("no lines available in
input"). The only differences are these:
  - The old path's "incomplete final line" warning is gone, which is an improvement.
  - A non-ASCII string is now marked `Encoding() == "UTF-8"` rather than `"unknown"`. `identical()` is
    still TRUE, and `trimws(whitespace = "[\\h\\v]")` still strips NBSP and em space. Any hash of the
    serialized object would differ for such strings, but nothing in the package hashes them.
  - A gzip-compressed path used to be decompressed transparently by `file()`. It is now refused with the
    NUL-byte error. Nothing uses that, and the docs say CSV.
- **`data/life_history_timing.csv` reads identically**: 38 x 7, `identical(old, new)` is TRUE, and it is
  all ASCII with no BOM and no CR.
- cp1252 bytes are refused with the new message. Both new UTF-8 tests go **red** when `.knw_read_csv()` is
  swapped back to the old read line in a temp copy of `pkg/` (`test-literature.R:154` and
  `test-timing.R:200` fail). So the guard fires.
- `read.table(text=)` wraps the text in `textConnection(text, encoding = "UTF-8")` (R 4.5.2), so the
  marking is deliberate, not incidental.

## Not defects in this diff (for the record)

- **C locale (`LC_ALL=C`)**: both the old and new paths turn non-ASCII into literal `<c2><b0>` escape
  text, so quotes are silently altered. Both give the same output, so it is not a regression. It does not
  arise in unattended runs on this Mac: `env -i Rscript` starts in `en_CA` (UTF-8). It only arises if C is
  forced explicitly.
- **`scripts/0260-timing-seed.R:59-60`** still reads its source CSV with the old
  `fileEncoding = "UTF-8-BOM"` line. It is outside the package and outside this diff, but it has the same
  silent-truncation exposure if its template source ever carries a cp1252 byte. Nothing in `pkg/` reads
  CSVs any other way: `.knw_read_csv()` is the only reader, and `literature.R` and `timing.R` are its only
  callers.
- `utils::` is not declared in Imports, but `tools:::.check_packages_used()` reports nothing (utils is
  exempt). The `timing.R` call predates this diff anyway.

## Checked and fine

- Fix (b): a `none` row with a stray `quote` or `citation_key` is refused, and the test reaches it. The
  `none`/`has_value`/`cited` masks carry no NA, because `kind` is required, `%in%` is used on optional
  columns, and every `which(i)[1]` input is NA-free.
- Fix (d): the `deletedCollections` exclusion is a LEFT JOIN anti-join and is correct. Library 9's
  one trashed collection (`3XZYB9D8`) has no children, so descendant handling is untestable locally.
  Numeric `ids` are pasted into `IN (...)`: even an id such as 100000, which `paste()` renders as
  `1e+05`, compares equal in SQLite. vapply's `numeric(1)` accepts the integer `collectionID`.
