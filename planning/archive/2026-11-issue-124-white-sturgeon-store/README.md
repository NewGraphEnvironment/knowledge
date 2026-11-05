## Outcome

The White Sturgeon recovery documents, the Nechako White Sturgeon Recovery Initiative's reports and a curated set of
Nechako mainstem history now sit in one group collection, `species/sturgeon` (`WEUFTSDC`), and in one store,
`sturgeon`, pushed to `s3://fresh-bc/rag/`. `data/sturgeon_members.csv` (15 group items) and
`data/sturgeon_additions.csv` (69 new works) drive `0270 --collection sturgeon --parent 9U54XAND`; `0150` builds from
`WEUFTSDC` alone. The federal set is the 2023 amended recovery strategy and the 2014–2020 progress report (both
printed to PDF from the registry's HTML, since publications.gc.ca served no PDF to a script), the 2024 action plan
and CSAS's 2007 recovery potential assessment. The live run waited on #127 (Zotero's WAL), and the build ran with
Zotero quit because cred still reads the database immutable (cred#45). On the way, `0153`'s `api()` gained a retry on
429/503 after `Retry-After` and honours `Backoff`, after the first dry run lost 25 of 69 lookups to the rate limit.
What was learned: rows drafted for a recurring series must be read from each report's own title page (code review
round 3 found a title copied from the previous year's report and a month taken from the siblings), and correcting a
CSV row after a live run leaves the filed item behind, so a re-run would create the work again until the item is
fixed (round 4). Left for #151, because auto mode refuses Web API writes from the session: OCR and attach Tredger
et al. 1984 (a scan with no text, the one member the store lacks), merge a 2023 standalone copy of the 2016 Nechako
watershed strategy into its new keyed item, and PATCH the two items round 3 found wrong.

## Measurement

| | before | after |
|---|---|---|
| live items in `species/sturgeon` | 3 | 84 |
| keyed (BBT) | 3 | 84 |
| PDF on disk | 3 | 84 |
| store documents / chunks | none | 83 / 10,964 |

- `0270` live run: 69 created, 12 added; 43 PDFs uploaded, 27 registered without a transfer (the storage server
  already held that md5), 14 already present. All 70 PDF sources started `%PDF`, 222.8 MB in total. The second dry
  run printed no `would` line.
- Store: 151.5 MB, md5 `7c8359e5…`, cred 0.7.0 / ragnar 0.3.1, nomic-embed-text; build 8 min 41 s. Every one of the
  83 origins is a live group attachment of a live member; the bucket object's multipart ETag equals the local file's.
- Queries: side channels near Vanderhoof returned Rood and Neill 1987 and three NHC reports, and recruitment failure
  Korman and Walters 2001 and McAdam et al. 2005, as fixed in advance. The Fraser–Nechako confluence query missed its
  advance picks (the Lheidli T'enneh critical-habitat reports, Williamson et al. 2021), though all three are in the
  store: the confluence is named in many reports, so the pick was a guess about ranking.
- The gap, with no PDF anywhere: Rood and Neill's cited geomorphology study, Smith et al. 2002, French and Chambers
  1996 and 1997, and Triton's 2007 "3812 Sturgeon Report Final".

## Evidence

`scripts/logs/rag/20261105_*_sturgeon.log`; `review-plan.md` and `review-round*.md` here.

Closed by: PR (see #124)
