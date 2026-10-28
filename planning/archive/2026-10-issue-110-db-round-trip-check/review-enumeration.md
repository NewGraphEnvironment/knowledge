# Code-check enumeration — #110 (2026-10-28, after round 4)

Round 4 found a defect inside round 3's fix, so the loop ends on an enumeration, not a quiet round.

**Mechanism (round 4's statement, checked):** two states the code or a test must tell apart were given one
representation, because the cases were assumed uniform. Round 1: a refused run and a real run shared a log path.
Round 3: a fixture with equal per-query times could not tell a median from a sum, max, mean or first query. Round 4:
the fix's two fast queries were equal (both 0 s), so min and a warm-up drop still passed.

**Candidate set:** every fixture behind an expectation in the branch's new tests, and every name, key or flag the
branch writes that must keep two states apart. 12 members.

| # | candidate | states it must separate | verdict |
|---|---|---|---|
| 1 | latency test 1, 30 ms each (fake clock) | ms against s; all n queries against one | separates: `/ 1000` and `seq_len(1)` mutations fail it |
| 2 | latency test 2, 100 / 5 / 10 ms (fake clock) | median against sum, mean, max, min, first, median without the first | separates: each of those six mutations fails it |
| 3 | check test, mocked 105 ms | over the limit: stop, or run on `remote` | separates: guard removed, `remote` ignored and `limit_ms = Inf` fail it (rounds 3 and Phase 1) |
| 4 | check test, mocked 1.6 ms | under the limit, with and without `remote` | separates: the line carries no override text in either |
| 5 | live latency test | none (reports the measurement) | not a discriminating fixture by design |
| 6 | timer test, sleeps 0.05 / 0 / 0.02 s | contiguous ticks against overlapping or from-start ticks | separates: no-advance and from-start mutations fail the sum-to-total check (rounds 3, 4) |
| 7 | timer labels in `knw_compare_rules()` | one stage against another | six labels, each used once (grep) |
| 8 | 0310 `<date>_evidence_build_refused.csv` | refused run against the run ledger readers glob | separate: no reader's `_evidence_build_ledger\.csv$` matches it (rounds 1, 2) |
| 9 | 0320 `<date>_tune_refused.txt` | refused run against `_tune_run*.txt` | separate from runs; refused runs of two modes share it (accepted) |
| 10 | 0330 `<date>_compare_refused.txt` | refused run against `_compare*.txt` | separate from runs; refused runs of two STAGEs share it (accepted) |
| 11 | 0310 ledger `db_remote_override` | the override acted against it did not | 1 only when over the limit and `REMOTE=TRUE`; the measured line sits beside it |
| 12 | the check's `line` under the limit | `REMOTE` set against unset | identical by design, since no override acted; pinned by test 4 |

Not pinned and not a defect: `ms > limit_ms` against `>=` at exactly 20 ms, a boundary with no practical case.

**Result:** no member sits above its source of truth. The loop ends here.
