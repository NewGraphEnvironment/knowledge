## Outcome

Backlog move 6 (#175), two batches in one PR.

- **Batch 18, the FDIS load's outputs.** The per-pass electrofishing tables are kept beside the visit tables (#225):
  `knw_fdis_passes()`, written by `0230` after the repeat drop and checked against the visit table, as CSV by `0240`,
  and in the unpublished `knowledge/fdis/v3` set (13 tables). The evidence archive now holds `fish.rds`, held to the
  run ledger's `md5_fish` (#214), and the published run's evidence was archived again with it (evidence `7fa6ad14…`,
  batch `20261120T040634Z-6cd2c6ba`), so `0336 PULL=TRUE` restores it. Every grade table recompressed to its archived
  bytes, so nothing else was re-sent.
- **Batch 10, location error against flow resolution.** #23 was cut at the gate to the site span and a check of where
  a bcfishobs record sits against its visit. Its age-class counts and workbook source went to #245. A record's point
  turns out to be the visit's own point: 58 % carry its UTM. So the location error is the fished span, not the record.
  #137's answer is that one discharge per FWA segment is fine enough to tune on (`research/discharge_resolution.md`).

What was learned on the way:

- **Placement does not reproduce.** A rerun of `0230` on another database and fresh version places 245 of 51,587
  visits differently (#246). `0230` therefore gained `PLACE=FALSE` and `0240` gained `ONLY=passes`, the routes to rebuild
  what a restored build lacks without rewriting its placement.
- **The span stays out of `fdis_sites.csv`.** Its md5 is pinned in the methodology bundle, so the published column waits
  for move 12's rebuild (#231's body).

## Measurement

- **Per-pass tables, published build.**
  - 61,388 passes and 73,567 pass × species rows. 35,642 passes caught a fish, 25,279 recorded only no fish caught, and
    467 have no catch record.
  - Every kept visit's passes equal its `n_pass`, its fishing time and its area.
  - 885 visit × species have no pass row (their catch sits on a `KEY` with no visit row). 161 sum above the visit's
    `n_caught` over their passes.
- **`0230` rerun on m1.**
  - `fish.rds` and `catch.rds` came out byte-identical to every ledger's (8cf27351, a31fd7bb).
  - `sites.rds` did not: 853c… against 39f751b1, with 245 visits moved and 778 code-moved against 785. This became
    #246, and the published placement was restored from the archive.
- **Where a record sits.**
  - 24,163 of 60,098 FDIS-keyed bcfishobs records (40.2 %) match exactly one visit.
  - 58.2 % of those carry the visit's own UTM, and all 13,218 of them on its line sit at its point.
  - Of the rest on its line, 81 % lie within 5 m of the visit's point.
  - The fished span over the 19,349 visits of placed one-to-one records: median 100 m, 90th percentile 800 m.
- **Flow within a segment** (4,425,507 segments measured, wet's 2026-10-24 load).
  - Single-line segments of 0.1–1 m³/s gather a median 0.85 % of their flow (90th percentile 15 %).
  - Over the 37,506 visits with both sources, a fished span gathers a median 2.6 % on single-line streams. The two
    sources differ there by ×1.33, and the pick's gauge error is 23 %.
  - A point flow would change the class at each key's minimum flow for 0.13–2.8 % of visits, against 2.4–7.9 % for
    the other source. No point flow is needed, and no follow-up was filed.
- **Wrong turns kept.**
  - The first flow run's `findInterval(rightmost.closed = TRUE)` misplaced each line's top-reach foot. Round 1 caught
    it, and the Q3 counts moved from 37,834 to 41,983 visits, then to the one-population 37,506 in round 3.
  - The first downstream check counted fished lengths over records, not visits.
  - Holding `catch.rds` by md5 could never pass once equal contents with other bytes were present. The check now holds
    it by its species per site.
- **Review cost.** The plan review and five code-check rounds, six agents in all, over the bound of about five. Rounds
  2 to 5 each found a defect inside the previous round's fix. The loop ended on a 17-path enumeration of every write,
  stop and remedy (`review-enumeration.md`, `review-verdict.md`).

## Evidence

- `scripts/logs/fdis/20261119_fdis_*`: the passes run and the downstream-end check.
- `scripts/logs/flow/20261119_segment_flow_resolution_check.txt`
- `data/archive_index.csv`, batch `20261120T040634Z-6cd2c6ba`

## Owed

- #219's upload of v3 carries the two per-pass tables; tell the private consumer's issue that they exist.

Closed by: this move's PR (#23, #137, #214, #225; umbrella #175)
