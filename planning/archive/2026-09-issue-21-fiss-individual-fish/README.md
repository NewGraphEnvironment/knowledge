## Outcome

`0220` now reads Step 3 (Individual Fish Data) and the Step 2 life-stage label from Fish Data Submission workbooks. The new `0250` turns them into `data/fiss_evidence.csv`, in the `fdis_evidence.csv` shape, deduped against the FDIS export. `0240`'s classifier moved to `pkg/` as `knw_size_class()`.

The main lesson is that most of the workbook fish were already in FDIS: the export was built from these submissions. The workbooks add Peace boat-EF index sites in years FDIS lacks, plus non-EF methods. Nothing in the five harvested groups postdates 2020, so the post-export gap the issue named is still open.

On the way, we found the no-fish-captured layer had been wrong in both directions. Pre-2016 template editions name their columns differently, so their species, NFC codes and survey dates were never read. And a site was flagged no-fish whenever any one trap was empty.

Code review ran four rounds across two scripts. Both loops ended by enumeration after reviewers found defects inside earlier fixes (`review-enumeration-*.md`). Three of those defects were reconcile gates that compared a quantity with itself; each replacement gate was shown to fire with the defect restored. The prior-art check found nothing in `fish_passage_template_reporting` to reuse: it only writes Step 2/3, and its length-based stage rule is why the stage comparison makes no authorship claim.

## Measurement

- **NFC sites, 5 groups:** 1,333 → 1,410. Inside-group: PINE 142 → 146, COTR 62 → 67, UNTH 136 → 106, LNTH 136 → 90, UPCE 228 → 251. Sites with no survey date: UPCE 4,476 → 8, all groups 5,576 → 68.
- **Step 3:** 175,414 fish after taking one group per report. 100,297 are dropped as already in FDIS (2,952 sites). Of the 68 reports with electrofished fish, 45 match ≥ 90 % by date, place, species and length, and 13 match none. The 50 m radius is insensitive: going to 2 km adds 1.5 % more matched sites, mostly weak matches.
- **New evidence:** 1,283 CH and char fish at 1,154 sites, 2006–2020. CH: 45 fish, all from minnow traps. Char: 1,238 fish, of which 1,005 are boat EF.
- **Life-stage label vs length class:** char disagree on 8.6 % of fish and 12.1 % of Step 2 rows. CH disagree on 58 % of fish and 76 % of rows, almost all age-0 fish under 70 mm labelled "juvenile". That is a vocabulary difference, and the stage table was not tuned to hide it.
- **Wrong turns kept:**
  - A gate on `species_caught` restated the NFC predicate.
  - A "label equals the NGE length rule" split was offered as authorship. It is confounded, and the harvest records no submitter.
  - A round-1 note said the FDIS allocation left evidence untouched. It had put 13 char fish back.

The durable version of the FDIS overlap is in `research/fdis_export.md`, under "Supplement: Fish Data Submission workbooks".

## Evidence

- `scripts/logs/fiss/20260928_*`: 0220 per group, and 0250.
- `scripts/logs/fdis/20260928_fdis_evidence.log`: 0240 with `source`/`method` added.

Closed by: PR (this branch, `21-fiss-xls-parse-step-2-life-stage-and-step`)
