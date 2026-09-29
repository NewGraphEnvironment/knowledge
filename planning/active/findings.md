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

## Prior art check (user asked, 2026-09-28)

Searched `fish_passage_template_reporting` (all remote branches) and the org
(`gh search/code "Individual Fish Data"`). Every hit is a **producer**: `0220_fish_data_tidy.R`
and `fds_prep_for_submission.R` in the template and ~12 report repos write NGE's own catch into
Step 2 / Step 3 of the submission template. None parses another submitter's Step 3, and none
builds size-class evidence. Nothing to reuse or duplicate.

One consequence for Phase 5: the template assigns Step 2 `stage` **from length**, one rule for
every salmonid (`0220_fish_data_tidy.R` on template main):
fry <= 65, parr 65-110, juvenile 110-140, adult > 140 mm. An NGE-authored workbook in the harvest
therefore carries a stage that is a length class under a different break set, not a field call.
Its agreement with our classes measures break-set overlap, not submitter judgement. The
disagreement table flags staged rows whose label equals that rule's output, so they can be read
apart.

## Phase 1 — edition variants and the NFC roll-up: before -> after (2026-09-28, local fwapg clip)

Mapped: Step 2/3 `species_code`/`method`/haul variants, and Step 1 `date_yyyy_mm_day` (found
while planning 0250: 23 of 45 UPCE workbooks had no survey date). Zero-catch codes come from
`fdis_species_codes.csv` (`catch_class == zero_catch`: NFC, ZZZ). `NFP` (24 rows) is not in the
table and carries `total_number = 1`, so it is not treated as zero catch.

Round 1 of code-check found the site roll-up flagged a site NFC whenever **any** record said no
fish, even beside a catch; older editions record NFC per trap or pass, so the variant fix grew
that from ~213 to 292 sites. Fixed: `nfc` now requires no record at the site to have caught
anything; `nfc_conflict` keeps the mixed sites visible; `species_caught` drops explicit zero
counts (LNTH 23268 writes a trap-net "RB, 0" for an empty trap); a reconcile gate asserts no NFC
site names a species caught. The gate fired on its first run (those two LNTH sites), which is
how the derived branch's missing `!any_caught` was found.

Round 2 found the new gate compared the predicate with itself (removed; `nfc_sites_listing_a_species`
is a visible count instead) and the per-fish fallback only ran when no Step 3 sheet existed (now
whenever the Step 3 sheet yields no rows, gated by `fish_layout_sheets_read_as_step3`, proven to fire).
The loop ended by enumeration (`review-enumeration-0220.md`).

Per-fish sheets filed under a Step 2 name (UNTH 16389, LNTH 16393, "Fish collection") are routed
to Step 3 (`fish_layout` in the parse log). Their rows used to create location-less sites, which
is why UNTH and LNTH lose sites.

| group | sites | NFC sites | nfc_conflict | empty species_list | undated sites |
|---|---|---|---|---|---|
| COTR | 736 -> 736 | 396 -> 394 | 7 | 583 -> 527 | 93 -> 29 |
| LNTH | 1429 -> 1427 | 241 -> 207 | 122 | 1032 -> 698 | 499 -> 30 |
| PINE | 1610 -> 1610 | 155 -> 209 | 18 | 429 -> 300 | 249 -> 1 |
| UNTH | 996 -> 989 | 185 -> 181 | 86 | 802 -> 632 | 259 -> 0 |
| UPCE | 7023 -> 7023 | 356 -> 419 | 64 | 4797 -> 926 | 4476 -> 8 |

Net NFC 1,333 -> 1,410. The published layers were wrong in both directions: missing old-edition
NFC codes, and counting mixed sites as no-fish.

Step 3 raw fish: COTR 352, LNTH 1,406, PINE 28,642, UNTH 1,539, UPCE 171,319. Name keys dropped
from the per-fish file (on the site table already): UPCE 16 -> 8.2 MB.

## Phase 3 — classifier graduated

`knw_size_class()` (pkg/R/size_class.R) replaces 0240's inline `classify()`. `data/fdis_evidence.csv`,
`fdis_maturity_check.csv` and `fdis_summary_ch_bt.csv` re-run byte-identical to HEAD. Restoring
`len <= max` makes "a fish on a break takes the upper class" fail.
