## Outcome

#38 and #40 had searched only `Fisheries/temperature` for growing-season degree-day thresholds; #47 searched beyond it. Two background searchers ran web search, OpenAlex forward citations of Coleman & Fausch 2007a (79 citing works) and 2007b (36), Quinn & Peterson 1996 (282) and Holtby 1988 (224), and the reference lists of the BC reports (`search-tc.md`, `search-ps.md`, each with its dated log and Dropped list). **No independent growing-season degree-day threshold exists for any species outside Colorado** in what was found: the BC reports (Teck Harmer Creek, 2022) apply Coleman & Fausch's Colorado River cutthroat values to westslope cutthroat. What the literature does have is first-winter **size**, so the plan gate added a `fish_length` variable (mm, metric `fork_length`/`total_length`/`unstated`) to the evidence vocabulary. Nine works went into the collection (`data/temperature_additions.csv`, one member), the store was rebuilt (49 documents) and pushed, and two drafters wrote 34 rows (data rows 1103–1136): the cutthroat 30–35 mm TL threshold and its BC applications, coho size–survival relations and size values, Mochnacz's bull trout thermal units, Riley's steelhead smolting degree-days, and counter-evidence that size does not set first-winter survival everywhere. All ten growing-season `none` rows keep their cells (no row gives a value on the Coleman & Fausch window); their notes now name the wider search and point to what it found. `research/thermal_requirements.md` gains a First-winter size section and revised consumer guidance (wet#40, link#21, template#214).

Two meaning-audit rounds found 14 and then 7 errors, all in notes or `cited_source`; round 2 found three inside round-1 fixes, so the loop ended on a sentence-by-sentence enumeration, not a quiet round (`audit-*.md`). The drafting rule that came out of it is in `CLAUDE.md`. Seven paywalled or browser-only papers (Holtby 1988, Smith & Griffith 1994, Meyer & Griffith 1997, Brakensiek & Hankin 2007, Bradford et al. 2001, Connolly & Petersen 2003, Zabel & Achord 2004) were opened in Chrome for Al; none had been saved when the branch closed, so they have no rows yet (`findings.md`).

Both searchers each made one Unpaywall request carrying Al's email in its required parameter, unasked; reported to Al.

## Measurement

`0280`: 1,136 evidence rows, 0 failing quotes, thermal 50/50, flow 60/60, coverage 48/48. Temperature store 40 → 49 documents, 11,024 chunks.

## Evidence

`scripts/logs/habitat/20261013_*` (collection build, store build/push/verify, literature verify).

Closed by: PR (this branch)
