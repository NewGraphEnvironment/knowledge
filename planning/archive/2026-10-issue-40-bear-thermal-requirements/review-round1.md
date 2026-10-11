# Code-check round 1: branch 40 (17b7556...0def80a)

## Findings

- **[fragile]** research/thermal_requirements.md:37-38 (the `kind` paragraph), with data/literature_evidence.csv file line 155.
  The branch changes `pref` from "a preference or optimum" to "a temperature fish select or prefer", and moves
  growth optima to `lab`. Only Selong's row (file line 155) was recoded. About half of the table's `pref`
  temperature rows are still optima, which the new wording says `pref` is not:
  - data rows 140, 152, 597, 600: optimal rearing temperatures;
  - data row 150: optimal incubation;
  - data rows 619, 625: optimal growth, from reviews;
  - data row 647: Lusardi et al. 2020, "Laboratory studies have demonstrated that juvenile coho salmon growth
    and performance are optimized at...", region `laboratory`. This is a laboratory growth optimum, the case the
    new text sends to `lab`.

  Selong's recode note says it matches "the other laboratory optima", but the only rows coded that way are the
  new Bear rows, and row 647 still disagrees. Nothing in code filters on `kind` (0280's grids and
  `knw_literature_read()` ignore it), so no run breaks. The harm is to a reader: one who takes the research
  file's definition and filters `kind == "pref"` for selected temperatures gets growth and incubation optima
  as well, and one who filters `lab` for growth optima misses row 647. The fix is either to restore "or optimum"
  to the `pref` definition (keeping the lab-growth-optimum carve-out) or to sweep the optimum rows. Rows that
  read a laboratory growth optimum secondhand, such as 647, need a decision that the table applies everywhere.

## Checked and found correct

- **CSV write.** Only file lines 155, 522-523, 532-534 and 554-556 changed against base, plus lines 1072-1103
  appended. The file has LF endings, a trailing newline and no embedded line breaks: 1,103 lines, 1,102 data
  rows from both `read.csv` and `knw_literature_read()`.
- **Reproducibility.** Re-running `planning/active/draft_rows.py` in a copy reproduces file lines 1072-1103
  byte for byte, and so does the committed `draft-bear-evidence.csv`.
- **Validation.** `knw_literature_read()` on the committed table passes. The new rows use `bound` max with
  `value_max`, optimum or range with both values, `metric` constant, daily_max, daily_mean or unstated, and
  `kind` lab, expert or dist, all within the vocabulary.
- **Gate log.** `scripts/logs/habitat/20261011_literature_verify.csv` has 1,102 rows. Data rows 1071-1102 are all
  `verified_ocr` (2007) or `verified_text` (2005).
- **0270 `pdf` column.**
  - The `%20` URL goes to `z.fetch` unchanged, and `urllib.parse.unquote` names the file "cttxrbt temp TAFS.pdf".
  - The relative path resolves through `os.path.join(HERE, "..", src)`.
  - Both logs show the items as members with a PDF, and a dry re-run reports "pdf present", so on a machine
    without the ignored local file `has_pdf()` short-circuits before the file is looked for.
  - The local PDF is gitignored (`data/rag/`) and not committed.
- **Row and note references.**
  - Data row N = file line N+1 holds for rows 521/522 (Cleator, Thorley) and 1071-1102.
  - The notes' label-to-row resolution matches the order of the rows.
- **Source spot-checks.** All of these match the PDFs' text:
  - 2007 paper: 19.6 (CI 19.1-19.9) and 24.3 (CI 24.0-24.7) on p. 1115; 35.7 % at 20 C; 24.1 and the 20/24
    lethal limits on p. 1117; 26.0, the 4.5 and 1.7 differences, and 17.2 (Hokanson) on p. 1118; the niches;
    13-15 in the abstract and on p. 1119; the fluctuating-regime limitation.
  - 2005 report: 19.7 (CI 19.1-20.3) and 24.2 (CI 22.9-25.4, the abstract printing 20.3-24.2); the 120-d
    projection at 18/20 and 22/24 C; 24.7 and 31.1; 10.3-17.0, 5.5/21.8, 6.8-18.2 and 1.8/24.3; Sloat 2001
    with the Madison basin from the reference list; the 16/20 recommendations; Dwyer & Kramer 15 C; Hickman &
    Raleigh 12-15 C (in the group library as `hickman_raleigh1982Habitatsuitability`); "equally competitive
    from 12°C to 16".
- **Counts.** The research file's "45 members, 40 with a PDF" matches `temperature_members.csv` (45 rows) and
  the store-verify log (40 docs).
- **Secrets and identifiers.** None in the diff or the commit messages. The absolute `/Users/...` paths
  appear only in run logs, which is the existing practice.
