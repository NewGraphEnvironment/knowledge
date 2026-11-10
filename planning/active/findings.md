# Findings — Backlog move 3 (#172)

## Issue context

**If we do it:** the Zotero scripts run with the key in a file, the library's duplicates, mistitled items and multi-PDF items are settled in one sitting, and the DFO threat-layer document and a statistics store reach the stores. **If we never do:** `0270 --collection sturgeon` stays unsafe to re-run, the citation audit keeps reading map sheets, and the method has no statistics store to be read against.

### Batch 4. Library writes
- **Why here:** one sitting with Zotero running and the Web API key; #168 makes the key easy to supply first; #151 and #126 share CLAUDE.md's duplicate-merge recipe and end in one store update.
- **Touches:** `scripts/0153-reports-to-zotero.py`, `scripts/0270-habitat-collection-build.py` (one shared key helper), `scripts/README.md`, `CLAUDE.md`, `data/sturgeon_additions.csv`.
- **Decided at the gate:** a verdict per item for #126's 25 group-library items (merge, keep one, or split out); the personal-library items wait on #13. The Web API writes need a person present: auto mode refused #124's merge.

| issue | title |
|---|---|
| #168 | Zotero scripts: read the API key from a file when ZOTERO_API_KEY is unset |
| #151 | Sturgeon store follow-ups: OCR Tredger 1984, merge the duplicate watershed strategy, correct two items |
| #126 | Zotero items with several PDFs: merge appendices and report parts into one file, drop the copies |

### Batch 5. New sources into the stores
- **Why here:** both run `0270` → `0150` build → push (and `0280` for #20's rows) in the same Zotero sitting as batch 4.
- **Touches:** `data/statistics_{members,additions}.csv`, `data/literature_evidence.csv` (appended rows, audited for meaning), the `habitat_modelling` and new `statistics` stores.
- **Decided (2026-11-09):** #95 is the `statistics` store only. Its alignment review and its partially pooled curve are each a PR of their own: this move's plan files them as issues before its PR closes #95, each naming move 3 as where it was split from, and leaves them out of `planning/backlog.md` for the next `/backlog-sweep` to place in a move other than move 3.
- **Decided at the gate:** whether #20's data-availability question is still open.

| issue | title |
|---|---|
| #20 | DFO CSAS 2025/013 (Iacarella et al.): Fraser flow and temperature threat layers on the FWA |
| #95 | A statistics store to read the method against Statistical Rethinking (the alignment review and a pooled curve follow as their own issues) |


---

Backlog: `planning/backlog.md`, move 3. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.


## Planning measurements (2026-11-09)

- cred installed 0.1.0 (`check_pkg_stale.sh`: 0.7.0 released). 0.7.0 exports `crd_store_update()`; cred#44 closed, cred#45 open.
- `statistics` collection `LP4R4VYR` is top level: McElreath 2020 (`7UX9T7RQ`) and Hill 2025 (`DLL6RYLL`) have PDFs; Bayesian Belief Nets, Kendall 1975, Theil 1950, Sen 1968, Mann 1945 have none; Toffolon & Piccolroaz 2015 has one.
- #126 group items: 25 items, 67 PDFs. Fileless locally: ban E27ZSTHD; garnett K4WGW3Q7, EI8Z6FME; polfus IBHTXREZ; rahr B7ZEGMZQ, 9Q9GZ5WU, 7H5GK2IR; rapp 4Z5EMI6B; sloat W8HLSVEI; tran PEVEUP6I; zhang K28A3DMR.
- Skeena G9Z8UYVS is "Valuation of the Wild Salmon Economy of the Skeena River Watershed" (2006); 2GQC2I9J is the 2013 project plan.
- hall_stednick: BWFWGKAW = Chapman et al. 1961 Alsea summary (OSU Misc. Paper 110); L3FA3AZ6 = USGS Circular 490; P9ZV6GDE = 6 pp OCR scan, unidentified.
- banner: 9S2ERUGD/P9M7DEJQ are part 1 (281 pp, md5 8434f913/b192e3ec); B7V8RRZQ/T3CF6Z7W are part 2 (253 pp, same md5 6db00933), across items fieldguide and fieldguidea.
- davidbustard: 2DVK6KM4 Vol. 1, Y6K63TML Vol. 2 survey cards. mackay: 33222K2G report, AGU7Y3I4 appendices, GKL97JYY photos.
- viveiros U2HCSH69 is a maps .zip carrying contentType application/pdf.
- bcgov/nr-bcwat public, pushed 2026-11-09; wet#5 open.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `ls` aliased with colour codes broke path capture | `command ls` |
| A dropped connection failed the `habitat_modelling` and `statistics` pushes; my md5-verified reconnect then replaced the updated local `habitat_modelling` with the bucket's old copy (the trap CLAUDE.md names under "Ragnar stores live in S3") | Read every push's result before any verified connect; redid the update (local, minutes) and pushed again over the hotspot |
| I edited `scripts/0150-store.R` while a push of it ran; the push finished (its expression was parsed at launch), then R read on into the changed file and printed `unexpected end of input` | Harmless here; the rule (`code-check-r.md`, "Rscript reads a script as it runs") stands: no edits to a script with a run in flight |
| `sqlite3 -readonly` on a WAL-mode copy with no `-wal` beside it: "unable to open database file" | open the scratch copy read-write |

## Meaning audit of evidence rows 1146-1151 (#20)

`0280` proved every quote verbatim from the start; each round below audited meaning, sentence by sentence.

| round | reviewer | found | fixed |
|---|---|---|---|
| self | me | class edges on the wrong sides; "names no species" (the policy speaks of fish); two notes paraphrasing past the text | same commit as the rows (db579b27) |
| 1 | subagent | `cited_source` set on the policy's own words; 10 % edge coded with a basis the policy gives only for 20 %; 10 % edge read in the opposite direction to 20 %; DFO rows `reach` not `segment`; the May high flow's coding unstated; "matched gauges least well" overstated | 4723ce89 (10 % re-quoted from the moderate-class bullet as its lower edge) |
| 2 | subagent | "grounds the 20 % edge in Ptolemy & Lewis" reads placement as a stated link; "no basis for 10 %" ignores p. 14's general grounding; `instream_flow` vs "not a need" tension unstated; classes are regional defaults (p. 8) | 09040e98 |
| 3 | subagent | "directly after" (an equation paragraph intervenes); p. 14's Tennant is an example, not the grounding; "the method" for "the EFN risk screening approach", "and other jurisdictions" dropped | rewritten from the policy's own words |

Termination by enumeration, not a fourth round: every phrase round 3's fix introduced is quoted from the policy, and each
was grep-checked on its page (pp. 7, 8, 14: 10 of 10 found). No round found a wrong value, page or cross-reference.
