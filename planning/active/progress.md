# Progress — Get the Bear et al. 2005 and 2007 WCT thermal-requirement PDFs and read them into the evidence table (#40)

## Session 2026-10-11

- Plan-mode exploration — phases approved by user
- Created branch `40-get-the-bear-et-al-2005-and-2007-wct-the` off main
- Scaffolded PWF baseline from issue #40 with approved phases
- Next: start Phase 1

## Session 2026-10-11 (run)

- Phase 1: both members got a `pdf` source; `0270 --collection temperature` uploaded both (the Web API
  answered `exists` for the bytes and linked the attachments; a dry re-run reports `pdf present`).
  Zotero synced both into local storage. `temperature` store rebuilt (38 → 40 docs, 8,013 chunks),
  pushed, and verified on a fresh connect; Bear chunks return for a UUILT query.
  `habitat_modelling` rebuild running (it reads the `temperature` collection).
- Phase 2: drafted 31 rows (12 from the 2007 paper, checked against OCR because its text layer prints the
  degree sign as '8'; 19 from the 2005 report's text layer). WCT and RB 60-d and 7-d UUILTs, growth optima,
  optimal ranges, zero-growth edges, fundamental niches, the 2005 report's Sloat field associations and its
  daily-mean and daily-maximum recommendations, and the 2007 13–15 °C criterion. Appended as data rows 1071–1101 (1102 added after round 2).
  The WCT degree-day `none` notes (data rows 531–533) and the Cleator and Thorley secondaries (521, 522) now point at what
  #40 read. No source gives degree-days, so no `none` row was replaced.
- Phase 3, round 1: a Plan-type reader audited every row (`audit-round1.md`): 14 findings, 12 fixed, 1 disproved
  (the WCT 2007 niche cannot be quoted at the gate), 1 left out of scope. Gate: 0 failing quotes, thermal 50/50.
- Phase 4: `research/thermal_requirements.md` revised (provenance, status, degree-day paragraph, limits table,
  Left out, link#21 guidance). No other file mentions Bear.
- Phase 3, round 2 (`audit-round2.md`): 9 findings, 4 inside round-1 work, all fixed. The WCT 2007 niche is in
  (OCR quote past the RB range); the report and paper are one set of fitted estimates (identical coefficients);
  growth optima are `lab` per `pkg/R/literature.R` (Selong recoded to match). Gate rerun to the committed log:
  1,102 rows, 0 failing, thermal 50/50.
- `habitat_modelling` store rebuilt (220 → 222 docs, 38,653 chunks; the same three keys without an attachment as
  #38), pushed, md5 verified on connect.
- Meaning round 3 and code-check round 1 (`audit-round3.md`): 6 + 1 findings (one shared), five inside round-2
  work, all fixed. Gate: 1,102 rows, 0 failing, thermal 50/50.
