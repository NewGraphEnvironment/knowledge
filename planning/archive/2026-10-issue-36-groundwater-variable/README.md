## Outcome

`knw_literature_vocab()` gained a `groundwater` variable (knowledge 0.3.1). It covers upwelling,
hyporheic exchange and springs. No unit fits it, so a groundwater row is a statement with no value: no source
read so far gives an upwelling measure (a vertical hydraulic gradient would be the likely one). Twelve BT
rows were appended as data rows 675-686:
- the four groundwater statements #33 left out, plus a fifth from the same 2010 rule page;
- four siblings that share a quote with an existing temperature, elevation or valley_width_index row;
- two Metolius observations (spawning at springs; no cold springs, no spawning, in the Crooked River);
- Pratt 1992 (groundwater offsetting fines).

Most of what was learned came from the meaning audits rather than the code:
- The plan reviewer showed the planned mutation could not fail: a variable absent from `fits` already refuses
  every unit.
- The first meaning audit found a wrong `region` copied from a sibling (now fixed on all three Hagen & Sary
  rows), and that the 2015 plan's Swan River citation is probably a slip.
- The second found two errors inside the first round's fixes. The loop then ended by enumerating every
  cross-reference claim in the changed notes.

The durable convention went to CLAUDE.md: append rows, data row vs file line, check a sibling's fields before
copying them. The verdict for readers is in `research/bt_spawning.md` ("What drives site choice").

## Measurement

- `0280` gate: 686 rows, 0 failures; the 12 new rows give verified_text 9 and verified_ocr 3.
- Rows 1-674 keep their 2026-10-06 statuses (674 compared, 0 changed). That confirms the expected: appending
  disturbed nothing.
- Package: `devtools::check()` 0/0/0. Giving `groundwater` a unit (`"m/s"`) turns both unit assertions red.
- Meaning audit: round 1 found 4 errors, 3 candidate rows and 3 firm-ups; round 2 found 2 errors inside
  fixes.

## Evidence

`scripts/logs/habitat/20261007_literature_verify*`; reviews in this directory (`review-*.md`).

Closed by: PR (see `git log --grep "#36"`)
