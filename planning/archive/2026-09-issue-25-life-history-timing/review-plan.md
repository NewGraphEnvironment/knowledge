# Plan review (Plan agent, 2026-09-28) — 17 findings, disposition

| # | finding | disposition |
|---|---|---|
| 1 | Set-equality coverage invariant cannot see a doubled window or a missed merge | Reader refuses overlapping windows and 12-31/01-01 split pairs per key (Phase 1); script also asserts per-key expected row counts |
| 2 | Half windows cover no days, so the invariant cannot see them | Script checks half windows by identity |
| 3 | Source CSV has a UTF-8 BOM | Script reads with `fileEncoding = "UTF-8-BOM"`; reader too, with a test |
| 4 | Day-of-year must come from one MM-DD helper on both sides; 1901 end crosses the year | One helper, leap-year calendar, on both sides |
| 5 | Merge must be order-independent, union sources, error unless exactly one 12-31 and one 01-01 row, dedupe per wsg after pivot | Adopted |
| 6 | Assert year is 1900, or 1901 only in end and only when crossing | Adopted |
| 7 | Citation check must be per row, and dropped undated citations logged | Adopted |
| 8 | Reader validators: overlap, start == end, unknown filter codes, empty -> NA | Adopted (overlap, split, start == end, warning on absent codes, BOM). NA start with an end is allowed like NA end |
| 9 | Keys are Better BibTeX citation keys, not Zotero item keys | `source` holds citation keys; docs say so |
| 10 | "see Shepher 1979 for peak spawning" sits on CH Migration, about spawning | Carried on CH migration rows as given, both groups; not reinterpreted |
| 11 | PL correct | — |
| 12 | Positional citations leave several BULK rows unsourced | Listed in the run log |
| 13 | Round-trip needs `pkgload::load_all("pkg")`, so Phase 1 commits first | Yes |
| 14 | TEMPLATE_DIR is a new precedent; SHA pins the input | Header says so |
| 15 | RUN: line; logs under `scripts/logs/timing/` | Adopted |
| 16 | Deliberately failing tests for the invariant | Reader tests cover doubled / split / overlapping; script restore-the-bug run |
| 17 | Pin expected seed output numbers in the log | Adopted |
