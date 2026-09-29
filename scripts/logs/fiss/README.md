# FISS `.xls` track run logs

Console output of intentional, dated runs of `scripts/0200` → `0210` → `0220` for one watershed
group, teed as one file per run. They are retained as contemporaneous evidence of measurement
runs — which report pages answered, how many `.xls` fetched and converted, what parsed, and the
reconciliation table the run passed — not accumulated by accident. The per-group CSV outputs
they describe live in `data/<wsg>/` (`fiss_xls_reports`, `fiss_xls_fetch_log`,
`fiss_xls_parse_log`, `fiss_xls_reconcile`).

Filename: `yyyymmdd_fiss_run_<wsg>.log` — date, the workload (`fiss_run`), the group. Where one
day carries several runs of a group, a sequence segment follows the date
(`yyyymmdd_02_fiss_run_<wsg>.log`).

A run of `0220` alone is `yyyymmdd_fiss_parse_<wsg>.log`. A run of `scripts/0250` (Step 3 fish into
size-class evidence, all groups at once, deduped against FDIS) is `yyyymmdd_fiss_evidence.log`,
with no group segment.

`runs/` is gitignored debris: retries, aborted attempts, and runs kept only to show a guard firing.

Naming: `yyyymmdd_noun_verb-detail_target.ext` from 2026-09-04, the directory's first day. No
earlier pattern exists here.
