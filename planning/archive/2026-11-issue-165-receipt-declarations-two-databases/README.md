## Outcome

#165 rebuilt the evidence (`0310`) and regraded chinook rearing (`0320 SPECIES=CH`) at one commit on the two databases
that hold the published build, and compared the receipts knowledge's own writers made. The evidence builds shared one
`recipe_id` and compared `equivalent`; the two chinook grade receipts compared `identical`, every total bit for bit,
so #161's fix holds across databases. The receipt declarations were revised from that and from a bound on how far a
reordered float sum can move each grade total: the grade table keeps 1e-3 on graded km and grade sum (now on a
measured basis), the published grade set widens to 1e-2, and thresholds, evidence and the visit set keep their
roundings. Every header says what it rests on; only fdis.yaml stays provisional, for the six tables the evidence build
does not write. `data-raw/database_receipts.R` lost its `IDate` conversion (crate#49). The measurement found one new
defect, filed as #197: `knw_link_place()` takes the species from the catalog unordered, so `visits_link` and
`workbook_sites` come out with their species columns in each database's order, and `visits_link`'s md5 (every grade's
`evidence_md5`) differs with it. Five review rounds kept finding the same mechanism in the prose: a claim about what an
output covers, written from the one measurement in view without listing the artifact's own members; the review ended
on an enumeration of 85 claims. The durable record is `research/run_archive.md` ("How the grade roundings were set",
"The evidence build") and `research/database_builds.md` ("A second database").

## Measurement

- Evidence across two databases: one `recipe_id`; `access_check` moved 5.3e-11 km at most over 2,193 rows (its sum
  1.5e-9 km); four tables byte-identical, `visits_link` and `workbook_sites` identical in value but not bytes (#197);
  `mad_pick` the same on all 45,529 visits (it moved on 3 in #158, before #161's fix).
- Chinook rearing grades across two databases: receipts `identical` (`rows` 3,016,042, `graded_rows` 872,418,
  `km_graded` 232,928.75963606851, `grade_sum` 253,887.60172207703 on both); every segment's grade and length the same
  in the same order; ten tune CSVs identical, the smoke table equivalent at 2.27e-13. Every walk came from the cache
  (876,268 hits), so #162 was not exercised.
- Summing-order bound n × eps × Σ|x| over the published grade tables: 2.7e-4 for BT rearing (2.1 million graded
  segments), 1.07e-3 km and 1.20e-3 over the published set (4.2 million); the moves actually seen over four orders were
  8.1e-8 per key and 8.7e-7 over the set. This set the grade totals at 1e-3 (unchanged) and the set's at 1e-2 (from
  1e-3).
- Timings: `0320` for chinook rearing 14.0 min (14 workers) and 17.2 min (8 workers, beside another session's link
  tests); `0310` 19.3 and 11.9 min by the run markers (not in a committed log).
- Wrong turn: round 2 of the review concluded the published sets would read `different` across databases "until #197";
  round 3 showed their recipes name the tuning run, so a regrade is another recipe anyway and a republish reads the
  same md5s. The sentence was cut back to what the recipe names.

## Evidence

`scripts/logs/habitat/receipt_165/20261112_*`, and the two evidence ledgers
`scripts/logs/habitat/20261111_evidence_build_ledger-derived_165_*`.

## Owed

- Remove the m4 worktree `~/Projects/repo/knowledge-165` and the scratch copies (m4's evidence and candidate on
  m1), on Al's word. On the second's checkout (the `knowledge-receipt` worktree) these are the ignored
  `data/fdis/derived_165_host`, `data/fdis/derived_165_second` and `data/tune/candidate/20261112_0647`, beside #160's
  `derived_receipt_a`/`_b`; the host's candidate copy lived in this session's scratch directory.

Closed by: PR (to be opened from branch `165-revise-the-receipt-declarations-from-158`)
