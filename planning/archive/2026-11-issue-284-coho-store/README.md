## Outcome

The group collection `species/coho` (`ZPUIT73I`) was grown through `0270` from `data/coho_{members,additions}.csv`. The
additions are Sandercock 1991, DFO's Interior Fraser coho series (2000 to 2021), COSEWIC 2002, the 2026 SARA scenarios
page and seven core journal articles; 25 items held elsewhere in the group became members (24 core coho works and
the Westworth Chilako–Nechako inventory). The `coho` store
was built from `ZPUIT73I` alone, queried and pushed, and `ZPUIT73I` joined `habitat_modelling`, brought up to date in
place on cred 0.8.1 (cred#48's fix, which merged mid-branch), so `0150` now needs cred >= 0.8.1 for an update and the
rebuild-after-update rule is gone from `0150`, `scripts/README.md` and `CLAUDE.md`. The check is
`research/coho_upper_fraser.md`: every coho record in the Fraser upstream of the Quesnel River's mouth
(`data-raw/coho_upper_fraser_records.R`), judged by its own source. Surveys reach through the Nechako system and no
further up the Fraser; link's `default` coho range takes in BOWR and WILL on a doubtful 2004 entry and a compilation,
and leaves out three groups with surveys (NAZR, FRAN, STUL).

What was learned: the issue's own premises needed correcting three times (the latitude cut was not reproducible, the
"file-named item with no PDF" held the same Sandercock scan, and there were five NuSEDS populations and five 2004
entries, not three and four). A point on a Fraser side channel carries the Fraser's watershed code and a measure along
its own line, so it must be placed by its local code. `cred::crd_store_push()` prints the bucket's whole merged
manifest, which names other, private repositories: a committed push log keeps only its own store's entry, as CLAUDE.md
says, and round 1 caught two that did not before they were pushed. A failed `0270` PDF upload leaves an empty
attachment that the retry duplicates (#286). The code-check ended on an enumeration after round 3 found a defect
inside round 2's fix: every summary in the research file is now derived from its records table.

## Measurement

| `ZPUIT73I` | before (2026-11-26) | after (2026-11-27) |
|---|---|---|
| live items | 16 | 61 |
| with a Better BibTeX key | 15 | 61 |
| with a PDF on disk | 15 | 55 |
| MB on disk | 25.0 | 271.1 |

- `coho`: 53 documents, 10,059 chunks, 139,735,040 bytes, 0 free blocks, md5 `ff810881567f0c4dfcab9488ee873608`;
  build about 7 min; the bucket's ETag matched the local file (8 MiB parts, 17). Left out: exactly the recorded gap
  (4 members with no PDF, 2 abstract only); 2 scans with no text.
- `habitat_modelling`: 414 → 463 documents (49 added, 0 dropped), 78,529 chunks, 1,239,429,120 bytes, 0 free blocks
  (cred 0.8.1; #194's updates on 0.7.0 left 32 to 76 % free), md5 `96c88c454c83309908361c1b3206a14d`; ETag matched
  (148 parts).
- Queries (expectations first): 1 hit (the upper limit), 3 partial (overwinter habitat, the decline, temperature).
- Records: 31 (25 Province observations, 1 FDIS visit, 5 NuSEDS populations): 15 survey, 13 compilation, 2 doubtful, 1
  no observation. The issue's 36 bcfishobs records "north of about Quesnel's latitude" lay between the 41 north of
  52.7° and the 31 north of 52.8°; the network cut gives 25 in 10 groups.

## Evidence

`scripts/logs/rag/20261127_*coho*`, `scripts/logs/rag/20261127_*habitat_modelling*`,
`scripts/logs/coho/20261127_*`, `scripts/logs/habitat/20261127_literature_verify*` (the coho file's 5 quotes verify; the
gate's exit 1 is #282's 42 OCR rows, unchanged from 2026-11-26).

## Follow-ups

#286 (`0270`'s failed upload), #287 (coho life history), #285's body (read the PSF flags into the research file).
Gap with no PDF held: Bisson et al. 1988, Beechie et al. 1994, Holtby 1988, Bramblett et al. 2002, Swales et al. 1986,
Brakensiek & Hankin 2007; OCR owed for DFO 1996 Fraser coho and Donas & Newman 2007.

Closed by: PR for #284
