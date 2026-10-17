# Code-check round 1 — branch 35-fdis-site-visits-include-surveys-loaded

Scope: scripts/0230, 0293–0299, planning/active/fdis_repeat_filter.py, CLAUDE.md, README.md,
scripts/README.md, data/fdis_README.md; outputs on disk (data/fdis_repeat_surveys.csv,
data/fdis/build/*, data/fdis/derived/*.csv).

## Findings

- **[severity: bug]** scripts/0230-fdis-load.R:329-330 — the keep order ranks a known catch above
  habitat (`catch_status == "unknown"` before `desc(has_habitat)`), so in a zero/unknown pair where
  only the unknown copy has habitat rows, the habitat is dropped with that copy. Measured on the
  current outputs (habitat.csv keys against data/fdis_repeat_surveys.csv): 3 dropped copies carry
  habitat and their kept copy has none — `90818_909_1` -> `80740_909_1`, `90853_913_1` -> `80780_913_1`,
  `90855_939_1` -> `80782_939_1` (all FDIS, dropped `unknown`, kept `zero`, n_measured 0). Their
  measured gradient, channel and wetted width and water temperature leave sites.rds, fdis_sites.csv and
  every table built from it. No guard or ledger row reports this, unlike lost maturity-coded fish
  (`repeat_groups_maturity_coded_lost`), and findings.md:38-39 still says the keep rule "loses no fish and
  no habitat in any group". That was true of the earlier order (fish, habitat, id); the refined order
  broke it. Fix options: carry the dropped copy's habitat onto the kept one, rank habitat above catch
  status (the zero/unknown choice matters only to catch_status, which could be taken from the zero copy
  without dropping the other's habitat), or at least add a `repeat_habitat_lost` ledger row and correct
  findings.md.

- **[severity: fragile]** scripts/0294-ch-mad-build.R:19-22 — the header says the visits the old loose
  signature still flags "differ in per-pass effort or per-species counts, so they are distinct visits".
  That is not the whole set the ledger row counts: it can also include (up to) the 86 visits 0230 matched on the
  full strict signature and kept on purpose (`kept_site_differs`, 71; `kept_one_collection`, 15 in
  data/fdis_repeat_surveys.csv), which do not differ in effort or counts. Anyone reading
  `loose_signature_surplus` against this sentence will misread it; state it as "differ in per-pass effort
  or per-species counts, or were kept by 0230 (see data/fdis_repeat_surveys.csv)".

## Checked and not a problem

- KEY format: all 62,892 visit keys have 5 underscore fields (coll_site_visit_method_pass), so the method
  and pass parses in `pass_sig` never return NA.
- A spot group with collection offset 14,340 (`100400_1_1` kept; `114740_1_1`, `114741_1_1` dropped) is a
  real repeat: identical UTM, date, time, effort and per-age counts, different agency ids.
- Invariants on disk: every `kept_site_visit` is in sites.rds; no dropped visit is in sites.rds or fish.rds.
- 0299: Parquet writes are byte-deterministic (two writes of fdis_repeat_surveys gave the same md5), so the
  new REPUBLISH sha256 guard does not refuse an unchanged rerun. `tables$source` builds the right paths
  (`c(...) |> paste0(".csv")`). fdis_repeat_surveys reads back with logical and int64 columns as written.
- No `dup_of`, `first_copy`, `v_dup` or `sens_duplicates_kept` remains in scripts. data/ch_mad_use.csv
  still carries `sens_duplicates_kept` rows, but 0295's rerun is Phase 4 (pending), so that is expected.
- fdis_repeat_filter.py: the walk filter keys on (blue_line_key, drm) text; 42 of 372,687 walk rows
  dropped, so the formatting matches. Per-visit independence of 0290/0294/0296 rows holds (0290's
  elevation cuts are per WSG from the network, not from visits).
- README.md, CLAUDE.md and data/fdis_README.md name `knowledge/fdis/v2/`, which does not exist until Phase 6
  publishes; fine as long as the publish lands before the merge, as the plan orders.

Verdict: 1 bug (habitat lost on 3 copies, unreported, contradicting findings.md), 1 fragile header claim.
