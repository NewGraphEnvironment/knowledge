# Findings — FISS .xls: parse Step 2 life stage and Step 3 individual fish into the size-class evidence (#21)

## Issue context

**If we do it:** submissions after the FDIS export dates (2020/2022) and non-electrofishing methods (minnow traps, angling, seines) join the size-class evidence. Those methods are where adult and large-river CH could appear at all. **If we never do:** the evidence stops at the export dates and at electrofishing, which under-represents large rivers and adult fish.

## Problem

`scripts/0220` parses Fish Data Submission workbooks for Steps 1, 2 and 4. It does not read:
- Step 2's life-stage column (it is in the sheet; not in `wanted_cols`);
- Step 3, Individual Fish Data (length, weight, maturity, age).

#18 built the evidence from the FDIS export instead (`scripts/0230`–`0240`), and left this as the supplement.

## Proposed Solution

1. Add Step 2 life stage to `wanted_cols` in `0220`, keeping the submitter's label as-is.
2. Parse Step 3 per fish, keyed to `site_key` and the Step 2 sampling event.
3. Class the fish with the same `data/fdis_size_breaks.csv` and emit rows in the `data/fdis_evidence.csv` shape, with a source column. Dedupe against FDIS where a submission is already in the export (match on date + UTM + species + length).
4. Report the submitter-label vs length-class disagreement rate.

Relates to #18, NewGraphEnvironment/link#284

## What exploration measured (5 groups fetched: COTR LNTH PINE UNTH UPCE, 247 workbooks)

- **Step 3 is on 232 of 247 workbooks**, `Step 3 (Individual Fish Data)`, header anchored on
  `REFERENCE NUMBER` like the other steps — `read_step()` works unchanged. 203,092 fish rows,
  200,894 with a length; 171k are UPCE. **Focal: ~3,650 BT, 88 CH**, across 50 reports. Methods
  include boat EF (1,596 focal), angling, gill net, minnow trap, snorkel — the large-river and
  non-EF evidence the issue is after.
- **Four Step 3 header editions.** Old ones write `species_code` (codes) + `method` +
  `haul_or_pass`; the 2016+ edition writes `species` (common names, mixed case) +
  `sampling_method` + `haul_number_pass_number`. Haul/pass is populated on only 36% of rows, so
  the Step 2 event key must degrade to (`site_key`, `method_number`) when haul is absent.
- **Step 2 life stage is `stage`**, on 14,730 of 39,581 rows: adult / juvenile / fry / parr /
  alevin, mixed case. Step 2 also carries `min_length_mm` / `max_length_mm` per row.
- **Existing 0220 defect found on the way:** 82 of 232 Step 2 sheets (old editions) have
  `species_code` and `method`, not `species` / `sampling_method`. `wanted_cols` names only the
  new ones, so those workbooks' species are NA today — `species_list` is empty for them and
  the NFC picklist code `NFC` (621 rows) is never matched by `str_detect("no fish")`.
  The fix changes the published NFC counts for already-run groups; the plan reports before/after.
- Step 3 maturity is free text (immature / mature / spawning / spent / maturing / undetermined,
  any case); FDIS uses IM / M / SP / ST / MT. Species labels: 97 of 112 match
  `data/fdis_species_codes.csv` by code or name case-insensitively; the 15 misses are
  lowercase codes (`rb`, `ccg`), `UN`/unidentified, and a few non-table codes (`LSC`, `LNS`).
- **No shared key with FDIS.** FDIS `KEY` starts with `fshclctn_id`, an FDIS-internal id; no
  EcoCat report id. Dedupe has to be on date + UTM + species + length, as the issue says.
  FDIS exact duplicate rows are distinct fish, so the match is a **multiset** (count-matched),
  not a set join.
- `classify()` in 0240 is the one piece that will now run on two sources → graduates to
  `pkg/` (`knw_size_class()`), which is also where the repo's tests live.

## Errors Encountered

| Error | Resolution |
|-------|------------|
