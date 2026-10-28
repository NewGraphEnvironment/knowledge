# Findings — Check the database's round trip before a database-bound run, and time 0330 by stage (#110)

## Issue context

## Problem

`CLAUDE.md` says to run the grade and the comparison on the database's own host, and nothing checks it. #92 ran `0330`
from a machine on a remote link and paid for it (`scripts/logs/habitat/20261026_compare*.txt` on the host,
`scripts/logs/habitat/20261027_compare.txt` from the remote link; different runs, so the ratios are approximate):

| part of `0330` | host | remote link | slower by | what it is |
|---|---|---|---|---|
| classify, overlay and connect | 115 min | 164 min | ×1.4 | SQL the database runs itself |
| the rest of the comparison | 48 min | 105 min | ×2.2 | not broken out in the log |
| GeoPackages | 14 min | 197 min | ×14 | 10 million segments' geometry over the link |

Round trips are mostly already paid for: since #87 a grade walks 500 segments per query, 12 to 18 ms per walk from the
remote link against about 3 ms on the host and 116 ms one query per walk (`research/database_builds.md`). What is left
is the database's own work, which a second machine cannot add cores to, and volume, which batching does not reduce. A
second machine adds speed to a database-bound step only with its own database holding the same build. Scoring is
CPU-bound and runs well from either.

## Proposed

1. **A check with an estimate.** `knw_db_latency(conn, n = 20)` returns the median round trip of `n` trivial queries in
   ms. At connect, before any long work, `0320` (grading only: not `DEV=1` or `GRADIENT=`, which write no grades),
   `0330` (every stage, `STAGE=gpkg` included) and `0310` (its visit walks) call it. Over 20 ms (the host measures 1.6,
   the remote link 104 to 110), the script prints the measured round trip and the expected cost from the table above,
   and stops unless `REMOTE=TRUE`. Every run logs the measurement and whether `REMOTE` overrode it. The check measures
   the connection, so nothing names a machine.
2. **A timing line per stage in `0330`'s log**, so the next run on either side splits the unexplained ×2.2 (catalog and
   segment reads, the outside check, the summaries, the writes). If one stage is chatty, batching it is a follow-up
   issue; if it is volume, it is not worth pursuing.

## Acceptance

- A test with a mocked slow connection: the run stops and names the round trip and the estimate; `REMOTE=TRUE` runs it.
- On the host the check passes and logs its round trip; from the remote link it stops.
- `0330`'s log carries one timing line per stage per key.
- `CLAUDE.md`'s "Run the comparison on the database's own host" paragraph names the check and the override.

Related: #85 and #87 (batched walks), #101 (`default`'s flags cached), #81 (GeoPackages opt-in).


## Review finding 1 corrected on implementation (2026-10-28)

The plan folded review finding 1 as "the check's stop writes the ledger first". 0320, 0325 and 0330 (and four
`data-raw/` scripts) read the newest `scripts/logs/habitat/*_evidence_build_ledger.csv`, so a refused 0310 that wrote
its partial ledger there would become the ledger every downstream run reads, or overwrite a good ledger written the
same day. A refused run writes `<date>_evidence_build_refused.csv` instead, which no reader's pattern matches.

## The live round trip from this machine (2026-10-28)

`knw_db_latency_check()` measured 1.4 ms (median of 5) on a localhost connection here, not the ~100 ms the plan
expected of a remote link. So the plan's live "from the remote link it stops" cannot be run from this machine; the
mocked test is that acceptance line's evidence.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `'\.' is an unrecognized escape` from an inline `Rscript -e` check | Run the check from a file in the scratchpad |
