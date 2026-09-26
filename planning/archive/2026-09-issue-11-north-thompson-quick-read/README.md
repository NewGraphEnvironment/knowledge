# 2026-09 — Quick read of the North Thompson fish-passage reports (#11)

## Outcome

A cheap path from PSCIS links to read reports, without Zotero, a rag store or the LLM harvest:
`0100` (now tunnel-first with a local fallback, no default group) → new `0105`, which resolves
the `[PSCISnn]` search links through EcoCat, runs thematic and consultant-name keyword searches
geo-filtered by title with every hit and verdict recorded, fetches one PDF per report with the
HTTP status read from `curl`, and extracts text locally. Run on LNTH and UNTH: 32 distinct
reports, 18 with text after one OCR. Eighteen per-report notes and a summary per group
(`data/<wsg>/reports_summary.md`) say what people found and fixed. The finding that shapes
everything downstream: **21 of the 24 PSCIS project tags in the North Thompson have no EcoCat
report** — the largest and most recent campaigns (DFO 2021–22, Braumandl 2018–20, CWF 2019–23,
Cornice 2025) exist only as PSCIS records. The readable corpus is 2003–2011 FIA-era work: the
Fennell Creek box culverts removed in 2004, the Raft River Sites 13/15 replaced in 2007, Louis
Creek's Crown crossings being bridges, Canfor's Mann Creek Priority 1 list, and the 2003 coho
screen's open items (Pleasant Creek; the Fennell Creek km-12 log jam). A `pkg` bug surfaced on
the way: the habitat-confirmation layer names its link `habconf_ecocat_url` and every
confirmation was being skipped; fixed with a test.

## Measurement

| | LNTH | UNTH |
|---|---|---|
| PSCIS rows / distinct links (all four layers) | 25 / 21 | 9 / 8 |
| links that resolve to an EcoCat report | 3 | 0 |
| keyword hits / in region / off region (16 queries) | 313 / 29 / 251 | 313 / 31 / 251 |
| reports fetched / with text | 32 / 18 | 31 / 16 |

Consultant-name queries recovered 10 in-region FIA-era reports the thematic queries missed;
`Braumandl` returns nothing. FWA point checks moved the Raft River sites from LNTH to UNTH and
George Creek out of the region (ADMS). Wrong turns kept: the reader notes for 24146 and 24174
came back under swapped ids (caught against the EcoCat titles); `ocrmypdf` fails on m1 because
tesseract cannot read PNG, `pdftoppm -tiff` + `tesseract` works. Code-check: one round, ten
findings on `0105`, all fixed (ISO-8859-1 titles, page-count marker, typed empties, group-keyed
defaults, reuse recorded).

## Evidence

`scripts/logs/reports/20260908_reports_quick-read_*` (each run appended in order);
`data/<wsg>/reports_{resolved,search_hits,fetch}.csv`; `data/thompson/report_notes/`;
`review-round1.md` here.

## Follow-on: the spatial summary (2026-09-08)

`scripts/0106-reports-sites-geojson.R` turns the reading into `data/thompson/report_sites.geojson`
(WGS84, 36 findings) plus a generated QML, from a hand-curated `report_sites.csv`. Groups from
FWA, not from the reports: LNTH 17, UNTH 15, and four that the reports implied were North
Thompson but are not — George Creek in ADMS, the Cindy Lake outlet culvert in CLWR (1.2 km from
a LNTH point, so genuinely near the divide), and two Maury Lake sites in MAHD. Location quality
is recorded per site: 25 exact UTM, 7 exact DMS, 4 approximate.

**Wrong turn kept.** The first version placed stream-referenced sites with the end vertex of the
merged `fwa_named_streams` line, and said in a comment that this had been checked to be the
mouth. It had not. Measured against `fwa_stream_networks_sp`, Fennell Creek's merged line ends
at its *source*: its start point sits on the Barrière River at `downstream_route_measure = 0`.
Pleasant Creek and Dora Creek were 5.9 km and 5.0 km out, and the Fennell log jam was measured
12 km from the wrong end. Rewritten to read the route measures, which also gives a real
"N km upstream" interpolation. A second encoding point fell out of the same query: the FWA name
is `Barrière River` with an accent, the same class as the ISO-8859-1 defect the code-check found
in `0105`.

Closed by: PR for branch `11-quick-read-of-the-north-thompson-fish-pa`
