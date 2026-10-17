# #35: FDIS surveys loaded under several collection ids

## Outcome

`scripts/0230` now keeps one copy of an FDIS survey loaded under two to four collection ids, and lists
every other member of a matching group in `data/fdis_repeat_surveys.csv`. Before this, 0293 and 0294 each
flagged duplicates with their own looser signature. A survey matches on UTM, date, pass count, per-pass
fished length and width, and catch by species, where every member has its own collection id and the
members share a site number or identical measured fish (the user's rule for possible adjacent sites). The
copy kept has the most measured fish, then the most maturity-coded fish, then a known catch, then habitat,
then the lowest id. Habitat values the kept copy lacks are carried over from a dropped copy, and the ws50
placement check pools every copy's watershed codes. The downstream duplicate logic is gone, and 0299
publishes v2 with the map as a v1-to-v2 crosswalk.

During Phase 1, a provincial link run was rewriting `fresh_default` (55 to 241 WSGs, the held-out ones
included), so 0290's guard refused to run. The visit tables were therefore filtered rather than rebuilt
(`fdis_repeat_filter.py` here). That equals a rebuild, because each visit is its own row and the new
`fdis_sites.csv` is the old one less the dropped copies, except for the carried values. Rebuilding on the
new schema is #59.

Code-check took three rounds, and each found a defect inside the previous fix:
- known catch ranked above habitat dropped habitat;
- watershed codes left with the dropped copy's fish;
- the habitat checks tested for a record rather than each value.

Round 3 named the mechanism: checking a container, not each value. The loop ended on a sweep of all 60
visit columns (`findings.md`, "Terminal enumeration"). The durable verdict is
`research/fdis_export.md`, "Repeated surveys".

## Measurement

- 1,308 groups; 1,431 of the export's 53,018 visits dropped (623 fish, 623 zero catch, 185 unknown); 51,587 remain.
- The fish are not reliably on the lowest id: where one copy alone has measured fish, it is the higher id
  in 94 of 95 groups. Keeping the lowest id would have lost them.
- What one copy gives up, measured: 78 measured fish rows, 3 maturity-coded fish (no char), 1 species,
  3 count length bounds. A first count of 346 summed a triple's copies against the kept copy.
- #28's candidate BT rearing weights moved by at most 0.02 (0.89 to 0.90 at 5–8 %, 0.74 to 0.76 at
  8–10.49 %, 0.64 to 0.66, 0.50 to 0.52 or 0.51).
- #33's Aug–Oct spawner rates moved by at most 0.011, and their rate ratios by at most 0.07; the WSG
  term still removes the rise (0.81–1.16).
- CH detection by MAD class did not change its detections: the analysed visits are 19,085 against
  19,077, because 0294's looser flag had left out 507, against 499 now.
- 0297's recommended rule is unchanged (MAD ≥ 0.75 m³/s, ≤ 7 %, or a ≥ 3 m³/s river within 1 km), with
  `default` at 188.3 deviance above it (was 188.2).

## Evidence

`scripts/logs/fdis/20261017_0[1-5]_*` (01 is the baseline reproduction on main's code, 05 the final
build), `scripts/logs/habitat/20261017_*`, `scripts/logs/fiss/20261017_fiss_evidence.log`.

Closed by: the PR from branch `35-fdis-site-visits-include-surveys-loaded`.
