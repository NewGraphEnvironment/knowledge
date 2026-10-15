# Progress: first-winter size rows (#48)

## Session 2026-10-15
- Al saved PDFs; most of the seven are paywalled. Chose abstract rows, flagged, plus secondary citations.
- Branch `48-first-winter-size-rows-abstracts` off main `fa7df71`; PWF baseline.
- Phase 1: `abstract` quote source in the package (vocabulary, 20-character floor, no page; tests, each guard
  restored and seen to fail), 0280 checks it against the group item's abstractNote and refuses it when a PDF is
  held, 0270 carries CrossRef's abstract (and plain titles) and takes `pdf = none`.
