# Progress — Validate the fieldwork-prep pipeline on UPCE from the M1 (#4)

## Session 2026-09-03 — planning only, PARKED

- Synced `CLAUDE.md` with soul conventions (no change — already current at `c6a3110`).
- Planned #4 in plan mode. Three `Explore` agents mapped the run order, the store/Zotero
  lifecycle, and the farm/reconcile + `data/` layout.
- Probed the machine directly rather than trusting the issue's framing. Two things the issue
  assumed turned out different:
  - **We are already on the M1** (`hostname` = `m1`), so no remote driving is needed.
  - **template#207, the stated blocker, is closed** (2026-09-03T00:34Z), as are cred#22 and
    cred#24. The sync exists.
- Found six blockers, all silent, recorded in `findings.md` as B1-B6. B1 (a project `.Renviron`
  shadowing `~/.Renviron`) was found only because this is a cold run, and would have produced a
  confusing auth failure at `0100`.
- Established that the store cache is already warm — all three local md5s match `log.json` — so
  the "M1 pulls rather than rebuilds" criterion is untestable without forcing the cold path.
- Established that `priority_farmed_all.csv` is **not reproducible**: zero workflow journals on
  this machine and 1 of ~218 farm extracts surviving, so `0161` must be made to merge rather
  than overwrite.
- Decisions taken with the user: fix forward and generalize; ingest into `peace.duckdb` and
  push; harvest authorized, farm gated on a real report count.
- **Parked before Phase 1** to reserve weekly token budget. Nothing has run and nothing is
  fixed.
- Commits: this baseline.
- Next: Phase 1 (preflight), starting with B1.

### Note on this directory

`review-round{1,2,3}.md` here are code-check records from the repo-seeding work (`d29809f`),
not part of this issue. They predate this branch and were left in place.

## Session 2026-09-04 — Phase 1 complete

- **B1 fixed.** Removed the redundant repo-root `.Renviron` (backed up first); asserted from the
  repo root that every `PG_*`, `AWS_*` and `GITHUB_PAT` is visible again and
  `cred.store_source` still resolves via `.Rprofile`.
- Preflight all green: binaries, both databases from the repo root, Zotero group reachable.
  **UPCE confirmed** as Upper Peace River, 5,820 km², identical from both databases.
- Corrected an earlier finding: `soffice` **is** on PATH here (Homebrew), so `SOFFICE_BIN` is
  not needed on this machine.
- Diagnosed the click-per-report problem the user raised: `wf_report_harvest.js:69,72` issues
  two `curl` calls per report inside subagents, and `curl` was unallowed. Fixed in
  `.claude/settings.local.json` (machine-local by decision — a tracked allowlist auto-applies on
  pull and is a commit-borne escalation path). Cross-machine sync filed as
  an internal issue.
- B2 groundwork: paged all 253 Zotero collections (a default page returns 100 — the absence
  trap), searched for pre-existing Peace-region collections under any name, found none covering
  Upper Peace, and created `upper peace - UPCE` (`WKUMAXBK`) under `mackenzie`.
- Found the Zotero collection layer has drifted: `parsnip` (28 items), `carp` (0) and `crooked`
  (0) carry no group code, so `0153` cannot reach them. `parsnip` vs `parsnip arm - PARA` may
  overlap — unresolved, flagged before any Parsnip run.
- Commits: this phase.
- Next: Phase 2 — force the cold-path store pull by moving `data/rag/peace.duckdb` aside.

## Session 2026-09-04 (cont.) — parked after Phase 3

- Phase 2 proved the cold-path store pull; Phase 3 found UPCE has no PSCIS data in any of the
  four layers, confirmed against a positive control.
- Filed the cred search bug as NewGraphEnvironment/cred#27 (list columns vs `as.numeric`), and
  the cross-machine permission sync as an internal issue.
- **Parked #4 here by decision.** The remaining phases are the expensive half (report harvest +
  LLM farm) on a subject whose data is mainstem dam sampling — wrong scale for crossing work.
  The cheap half already produced the corrections the issue calls its primary deliverable.
- Corrected a number I had reported: 17,200 was FISS observation *points* with an
  `acat_report_url`, not files. `0200` enumerates distinct reportIds — UPCE has 52. PINE's 78
  reports yielded 77 `.xls`. The "20,000 files" risk was off by ~300x; the *relevance* concern
  was the sound one.
- Established that **report count, not observation count, is the cost and relevance metric**:
  UPCE 18,383 obs / 52 reports vs LNTH 5,920 / 58. Mainstem density inflates observations only.
- Next work: FISS/NFC track for COTR (45 reports), UNTH (40), LNTH (58). Sequencing agreed in
  principle: run the three groups, graduate the parser into `pkg/` once it has run on multiple
  regions, write the skill last.

## Session 2026-09-04 (end) — compact-prep

- Filed NewGraphEnvironment/knowledge#5 for the FISS/NFC track, scoped to **COTR, UNTH, LNTH and
  UPCE**. UPCE was added after the report-track objection was found not to apply: that objection
  was to an expensive LLM farm over mainstem-monitoring reports, and the NFC track is
  deterministic and cheap. UPCE has the stronger claim to the result — 3,328 modelled crossings
  and zero PSCIS assessments — so evidence of where fish were and were not found is the only
  prioritisation signal available there. Its EcoCat reports stay parked.
- Committed `data/upce/reports.csv`: the header-only file `0100` produced. It is the evidence for
  the Phase 3 structural finding — `0100` writes `reports.csv`, no `crossings.csv`, no gpkg, and
  still exits 0 when a group has no PSCIS assessments.
- Appended a row to `soul/conventions/code-check.md` under "The probe is broken before the world
  is": a per-project config file can shadow the user-level one entirely (the B1 `.Renviron`
  case). Pushed to soul, so it reaches every repo at its next `/claude-md-init`.
- `#4` remains parked after Phase 3. `#5` is the next work and has not been planning-init'd.
