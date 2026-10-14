# Code check, round 3 (#47)

Verdict: **Clean.** No issues found.

## What was checked, and how

### 1. The 0270 re-run path, and group_copy() dedup

- I ran a dry run of `0270 --collection temperature --dry-run` on a copy: `scripts/0270` and `0153`,
  `data/temperature_additions.csv`, an empty members file and **no `data/rag/pdf/`**. All 8 additions
  came back `exists, member, pdf present`, under the same keys the 2026-10-13 build log created or
  matched: MNI96PW8, A4SNCJSD, B6DMA7X3, D5KFRFN5, JVANGHCJ, SR87NNIG, N74ZAXFD and F9HJM64P. The
  summary was `exists 8 | member 8 | pdf 8`, exit 0. `has_pdf()` short-circuits before `find_pdf()`,
  so the absent repo-path PDFs (Holtby & Scrivener, Hartman & Scrivener) are never read.
- If the earlier upload had not landed, a missing repo path returns None. `ensure(required=True)`
  then records `PDF-MISSING`, which is upper case, so `main()` exits with `problems`. That failure
  is loud, not a misleading state. A URL that returns non-PDF raises ValueError and is recorded as
  `ERROR` (also upper case).
- Wrong-match check. I made a guarded copy of zotero.sqlite (quick_check ok) and read the matched
  keys:
  - N74ZAXFD, the only first-run `exists` hit, for 10.1577/T05-144.1, is Ebersole et al. 2006,
    "Juvenile Coho Salmon Growth and Survival across Stream Network Seasonal Habitats", pp.
    1681-1697. It is the correct work.
  - D5KFRFN5 is a bookSection carrying bookTitle, series, seriesNumber 105 and pages 62-81.
  - F9HJM64P carries DOI 10.1577/T08-047.1.
  - The two Harmer Creek SME reports share a prefix and suffix but are not cross-matched, because
    `same_work` compares the full title.
  - No live (non-deleted) duplicate title exists anywhere in the local libraries for any of the 8
    works.

### 2. R package as installed

- `roxygen2::roxygenise()` on a copy regenerates `man/` and NAMESPACE byte-identical to the
  committed files.
- `R CMD build` + `R CMD check --no-manual` of the copy: **Status: OK** (tests run from the
  installed package).
- `test-literature.R` builds its fixture in-file (`literature_fixture()`, `write_literature()` to
  a tempfile) and reads nothing from the source tree. 44 expectations, 0 failed, 0 errors.
- The committed `data/literature_evidence.csv` (1136 rows) reads under the branch package: there
  are 9 fish_length rows in mm (4 fork_length, 3 total_length, 2 unstated) and 18 substrate rows
  in mm with no metric.

### 3. Readers of literature_evidence.csv outside knw_literature_read()

- `scripts/0280-literature-verify.R` is the only code reader.
  - Its `SCALE$mm = c(1, 10)` (a quote's cm read as mm) is keyed by unit, not by variable. It
    states no substrate assumption, and a fish length quoted in cm is a legitimate rescale.
  - The THERMAL grid counts temperature and degree_days cells only, and the FLOW grid excludes
    `m bankfull`. A fish_length row enters neither, so it fills no cell.
- In `research/`, the only code chunk is in `thermal_requirements.md`. It calls
  `knw_literature_read()` and does no unit-based logic.
- No other code in scripts/, research/ or pkg/R branches on `unit == "mm"` or treats mm as
  substrate. The substrate-to-mm pairing exists only in the `fits` list inside
  `knw_literature_read()`, as a per-variable allowed-unit set.
