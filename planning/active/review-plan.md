# Plan review — #122 (Plan agent, 2026-10-30)

Read-only review of `task_plan.md` against the issue, `0270`, the `0153` helpers, `0150`, CLAUDE.md, cred 0.4.0 and the
local `zotero.sqlite`. Findings as delivered; dispositions in findings.md, "Plan review".

**Blocker — Gill 2006 already has a keyed parent.** Findings called `KXDGTBTA` "an empty, keyless parent titled
bulltroutguide.pdf". It is the stored PDF child of `8B95AXD2` = `gill2006Bulltrout`, already in habitat_modelling, created
from `data/habitat_modelling_additions.csv:10` (`zotero:P3TMRWQX`); `crd_zot_src_lookup("gill2006Bulltrout")` returns
`storage/KXDGTBTA/bulltroutguide.pdf`. Fix: put Gill in `bull_trout_members.csv` as `gill2006Bulltrout`, not an
additions row; three standalones remain to parent, all in grayling (`NNS8U574`, `GGDPSJFE`, `QPMK23EN`). An additions
row kept anyway must repeat row 10 exactly or `group_copy()` creates a second parent.

**Gap — a live run without `--parent` creates a duplicate collection.** `find_collection()` looks only under the given
parent; `--collection grayling` without `--parent` would POST Fisheries/grayling and fill it from
`data/grayling_members.csv`. Fix: search all group collections when the name is missing under the parent, and refuse if
it exists elsewhere, printing its key. Acceptance: `--collection grayling --parent 9U54XAND --dry-run` prints `exists`
with GELFSUTU (VHWEK6RE for bull_trout).

**Assumption — `group_copy()` could match an unrelated item.** A match needs an equal normalized title; creator and year
are compared only when both sides have them, so an existing same-title item with no creators or no date matches (the
species-registry and BC-explorer webpages are that shape). Low risk for the three theses and reports. Acceptance: check
every `exists` / `copy exists` gkey in the dry run against the intended item before the live run.

**0270 on species collections.**
- Tag: only created items get the `grayling` / `bull_trout` tag; no script reads Zotero tags (0154's `corpus_tags.csv`
  comes from PDF content). It sits beside human tags `Arctic grayling` (3 items) and `bull trout` (1); harmless; record
  it or add `--tag`.
- A member whose group copy has a PDF: `ensure()` adds it, then `pdf present`. Correct.
- Webpage members (`3LTG78IH`, `VJJWKPSP`, `53BBCDCP`): blank `pdf` gives `no-pdf`, fine; a `pdf` URL returning HTML
  raises in `addition_pdf` and the run exits non-zero.
- Standalones cannot be member rows (no key); the `zotero:` additions path is right, and the new parent gets a BBT key on
  sync, as `gill2006Bulltrout` shows.
- Gap: the standalone stays in the collection beside its new parent, so a "left out" report would list it on every
  build. Remove standalones once parented, or mark them covered.

**Phase 2: what 0270 cannot do.**
- `beaudry2014Assessmentassignment` resolves to one live group item (`IWJYZFS6`); a personal copy (`W8EPUHGP`) is
  ignored because the group hit wins; cred picks the group PDF `XX9MEVAV` today.
- No live, keyless, non-attachment members; the only keyless live members are the four standalones.
- 0270 cannot remove a member, so `YQVI79FL` needs its PATCH; leave `…c` out of the members file.
- Gap: `mcmahon_etal2007TemperatureCompetition` (bull_trout, no PDF) is not in the list of members with a URL; find a PDF
  or record a miss.
- Assumption: unpinned auto keys (`App78_BC_Bulltrout_Brochpdf`, `selong_etalEffectTemperature`, the long Metolius key)
  change if their metadata is edited; either edit none or regenerate the CSV after.

**Ordering.**
- Phases 1–2 do not depend on cred; only the builds do.
- "Members left out" belongs in 0150 unconditionally: 0150 passes `citation_keys` to `crd_store_build`, so cred never sees
  keyless or PDF-less members.
- Phase 6 can land now (the CLAUDE.md query note, the 0.4.0 floor and query-branch version check, the issue-body
  corrections); only the README build lines and any build-floor bump wait for the tag.
- Upgrade ragnar to 0.3.1 with the cred tag, not in Phase 3: cred 0.4.0 is not proven on its mirai ingest.

**Acceptance.**
- Phase 2: a no-op re-run means a dry run with zero `would*`, only `exists`/`member`/`pdf present`, exit 0. "PDF on
  disk" assumes Zotero downloads group files at sync; check the setting or the re-measure under-counts.
- Phase 3: add the Gill case to the cred reprex (it resolves today; shows the fix keeps a 0270-made parent working).
- Phase 5: 222 cannot separate grayling, the cleanup and cred's pick changes; pull the current store and diff document
  origins against the rebuild, accounting for every change.
- Validation: `test-data-dir.R` checks only for `.R`/`.rda` in `data/`; it does not cover the new CSVs.
