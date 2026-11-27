# Code-check enumeration for #284 (2026-11-27): every summary the research file draws from its own records

Round 3 named the mechanism behind rounds 1 to 3: every summary of the records (In brief, "What this means", Gaps, the
README row, the additions' `why` column, the script header) was written by hand from a reading of the records rather
than derived from the per-record table, and three readings drifted (a group's evidence taken as the records carrying
its group code, so NuSEDS's ungrouped NAZR survey was missed; "survey" read as unqualified; counts not re-derived after
round 1 changed the population). Round 3's own findings file holds a 49-row claim table. This enumeration derives the
summaries mechanically instead, after round 3's fixes: it parses the research file's records table, joins the records
log, places each NuSEDS population in the group holding most of its stream's Atlas lines, joins link's
`wsg_species_presence`, and places each observation against the Nechako confluence (`100.567134`).

Script (scratchpad, not tracked): parse `research/coho_upper_fraser.md`'s table, `scripts/logs/coho/20261127_coho_upper_fraser_records.csv`,
the database's `fwa_stream_networks_sp` and `bcfishobs.observations`, and `link::lnk_load_overrides()`.

Output:

```
table rows 31 | log rows 31 | ids equal: TRUE 

   compilation       doubtful no observation         survey 
            13              2              1             15 

per group (NuSEDS by most lines, marked *):
              g in_range                                      kind
1  character(0)    FALSE                                  1 survey
2          CHES    FALSE                             1 compilation
3          FRAN    FALSE                                  2 survey
4          NAZR    FALSE                                  1 survey
5          STUL    FALSE                                  1 survey
6          STUR    FALSE                             1 compilation
7          BLAR     TRUE                   1 survey, 5 compilation
8          BOWR     TRUE                                1 doubtful
9          COTR     TRUE 1 no observation, 3 compilation, 3 survey
10         LCHL     TRUE                   1 compilation, 3 survey
11         NECR     TRUE       1 compilation, 1 doubtful, 3 survey
12         WILL     TRUE                             1 compilation

groups out of range with a survey: character(0), FRAN, NAZR, STUL 
groups out of range with any record: character(0), CHES, FRAN, NAZR, STUL, STUR 
groups in range on no survey: BOWR, WILL 
records above the Nechako (100.567134): 59bce25800, ad92d4930e 
2004 entries in the log: 5 
surveys qualified 'report not held'/'not named': 4 | plain FDIS-sourced surveys: 4 
survey places: Fraser River; Ahbau Creek; West Road River; Nazko River; Nechako River; Dahl Creek; Greer Creek; unnamed stream; Ocock Lake 
```

Against the prose, after round 3's fixes:

| claim (research/coho_upper_fraser.md) | derived | verdict |
|---|---|---|
| 31 records; 15 survey, 13 compilation, 2 doubtful, 1 no observation | 31; 15 / 13 / 2 / 1; table and log ids equal | holds |
| every survey lies at or below the Nechako confluence; only two records above it (BOWR, WILL) | above `100.567134`: `59bce25800` (BOWR), `ad92d4930e` (WILL); both not surveys | holds |
| the survey places listed in In brief | Fraser River, Ahbau Creek, West Road, Nazko, Nechako, Greer Creek, Dahl Creek, the FRAN unnamed stream, Ocock Lake | holds |
| range takes in two groups on compilations alone (BOWR, WILL) | in range on no survey: BOWR, WILL | holds |
| range leaves out three groups with surveys (NAZR, FRAN, STUL) | out of range with a survey: FRAN, NAZR, STUL (the ungrouped row is Ahbau Creek's NuSEDS population, whose code matches no Atlas line; Ahbau Creek is in COTR, in range) | holds |
| five groups with records outside the range: CHES, FRAN, NAZR, STUL, STUR | CHES, FRAN, NAZR, STUL, STUR | holds |
| five 2004 entries | 5 | holds |
| Gaps: four surveys on a citation or bare entry; five on FDIS field records | 4 qualified; FDIS-sourced surveys `obs:94e4f8d30d`, `fdis:172649_1_1`, `obs:026afad5a5`, `obs:785aff6b11`, `obs:02652e805d` = 5 (the script's text test counts 4 because the second FRAN row's source cell does not say FDIS) | holds |
| additions' `why`: five 2004 entries cite the draft; two also cite the 2001 assessment; Sandercock's attachment held the same scan | 5; 2; md5 equal | holds |

Nothing in the summaries sits above its source of truth. Each summary claim is now derived from the table, not read.
