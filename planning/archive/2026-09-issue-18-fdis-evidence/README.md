## Outcome

Built a province-wide evidence table of CH and char (BT, DV and hybrid codes) catches by size class, with measured channel width and gradient, effort, and explicit zero catch. It comes from the FDIS electrofishing export the Province supplied. The export moved from Dropbox to `s3://fresh-bc/fdis/`. `scripts/0230` loads it at site-visit grain and places each visit on the FWA; `scripts/0240` classes fish by length and summarises against the thresholds link runs now. The durable reference is [`research/fdis_export.md`](../../../research/fdis_export.md), which covers structure, the no-data encoding of every field, and the first calibration read.

Several wrong turns were corrected by review:
- Pass-level grain double-counted depletion passes.
- `details` taken for abundance: it is a length subsample, and 87% of counted CH have no length.
- Zero catch "inferred": it is recorded explicitly as `NFC`.
- Per-field sentinel handling written ad hoc.

The four `/code-check` rounds ended only when every raw field (round 3) and every one of the 115 species codes (round 4, `data/fdis_species_codes.csv`) was enumerated against its source. Rounds 2 and 4 each found defects inside the previous round's fixes. The `.xls` Step 2/3 supplement was split to #21.

## Measurement

- 53,018 site visits from 62,892 passes; 51,450 placed within 500 m. Gazetted name = FWA name at 94.6% of the 7,894 sites carrying both.
- Catch status: 30,076 fish, 22,390 zero, 552 unknown.
- **CH is rearing-only in electrofishing:** 2 of 5,728 fish are ≥ 150 mm, and none carries a spawning code. That turned "calibrate CH spawning from observations" into "not from this source" for link#284.
- **Char size is not maturity:** a third of SP/ST-coded char are 80–200 mm. Spawner evidence uses maturity plus month.
- **First read against current thresholds** (site gradient; a point measure, not the segment average the model uses):
  - 23% of 1,377 CH-present sites are above the 5.49% rearing max;
  - 42% of 348 char spawner-evidence sites are above the 5.49% spawning max.
- **FWA "field measurement" channel widths are these same sites** (69% identical). The modelled width scored only where it is truly modelled: 3,820 sites, log correlation 0.54, p10–p90 ratio 0.44–2.58.

## Evidence

`scripts/logs/fdis/20260926_*` (load and evidence runs, each ending in its reconcile table); review files `review-round*.md` in this directory.

Closed by: PR for #18
