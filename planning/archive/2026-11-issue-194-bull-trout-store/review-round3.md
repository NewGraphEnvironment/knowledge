# Code-check round 3 (#194 branch, base 89ee4d3a, to 4703f759)

## Checklist read

- The five indexes, in full: code-check.index.txt, code-check-r.index.txt, code-check-shell.index.txt,
  code-check-spatial.index.txt, code-check-python.index.txt.
- code-check-python.md: in full.
- code-check.md: the headings of all 14 `## Mechanisms` H3s (via `mech.txt`); the prose of "A guard's scope, escape
  hatches, and remedies" read in full (table rows skipped), and "Documentation Staleness" in full (its three bullets).
  The other 13 mechanism H3s were read from their index lines only. Standing-alone, Security and Spreadsheet headings:
  index lines only.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: no full section read. The diff since round 2 is docs,
  planning prose and log comments; no R, shell, spatial or Python code changed on the branch after round 1, and
  `scripts/0150-store.R` is unchanged on the branch.

## The mechanism behind round 2's findings

Each round-2 finding was a sentence written from the case in hand and stated for the whole set its words name:
"before a push" from this branch's three cred-built stores (covering `fraser`, which it would wipe); "an update
leaves the file mostly free blocks" from `habitat_modelling`'s 76 % (false for `bull_trout`'s 32 %); and a rebuild
remedy written into one place while other places kept the old update-then-push procedure. The remedy is one claim
written in several places, so a fix to some instances leaves the rest ("A remedy repeated across sibling messages is
one claim written many times").

Every place it reaches in tracked text, checked:

| place | verdict |
|---|---|
| CLAUDE.md:167-169, "32 to 76 % ... `habitat_modelling` 3.6 GiB holding 0.9" | holds (findings.md:66: 32, 71, 76 %; round 2's block count) |
| CLAUDE.md:169-171 and scripts/README.md:266-267, "harvest store" / "their harvest documents" for `fraser`, `peace`, `pine` | **false for `peace` and `pine`** (finding 1) |
| scripts/README.md:491-492, the bull_trout paragraph | holds: points at the update bullet |
| scripts/README.md:24, :172 and :501-502; scripts/0150-store.R:16 and :246 | **still give update-then-push** (finding 2) |
| CLAUDE.md:241-242, "joins a store at its next `0150 ACTION=update`" | holds: describes how a document joins, gives no push step |
| scripts/logs/rag/20261115_rebuild_*.log line 1, "mostly free blocks" | **false for `bull_trout`** (finding 3) |
| the two update logs' new `dropped:` notes | hold: the session's dumps of the updated stores before the rebuild (scratchpad `updated/*_docs.csv`, 197 and 414 origins) hold neither HYSNCHBC nor N2IJDSIN and both of 8PADNGFE and PWRE9XAM; the 2026-10-31 build logs show both scans ingested before |
| progress.md:41, "built 17:26–17:47Z" | holds (build log: start 17:26:39Z, exit 17:46:56Z) |
| task_plan.md:162-163, G6 "lines were dropped, not rewritten" | holds |
| "0150 does not guard a build" | holds as far as 0150 goes; cred 0.7.0's `crd_store_build()` itself refuses an existing file unless `overwrite = TRUE`, and the rule's command passes `OVERWRITE=TRUE` |

## Findings

- **[severity: bug (false doc)]** CLAUDE.md:170-171 and scripts/README.md:266-267 — round 2's fix calls `fraser`,
  `peace` and `pine` harvest stores: "Never so a harvest store ... a build over `fraser`, `peace` or `pine` replaces
  their harvest documents" (README: "replaces their harvest documents with Zotero's"). Measured read-only today on the
  local copies: `fraser`'s 283 origins are harvest files (`.../harvest_nechako/FRAN__53706.pdf`), but `peace`'s 117
  are Zotero attachment-key files from an older Web API build (`data/rag/_pdfs/peace/5QHVCWSE.pdf`, ...), and `pine`'s
  5 are author-year PDFs ingested from a local directory (`.../pine_pdfs/guppy_2006_peace_crossing_inventory.pdf`).
  None is under `storage/<key>/`, which is why the update guard refuses all three, but only `fraser` is a harvest
  store. `scripts/0150-store.R:210-213` draws the distinction itself ("a harvest file from 0152, a PDF ingested from a
  local directory"), CLAUDE.md:176-177, five lines below the new sentence, says "`peace.duckdb` is key-named", and
  `0150`'s own usage line 7 is a build of `peace` from Zotero collections (`ACTION=build STORE=peace
  COLLECTIONS="pine - PINE,peace arm - PCEA"`), which the new "never" now contradicts. Same mechanism as round 2:
  one member's nature (`fraser`'s) stated for the set. Fix: say what the three hold ("documents from outside Zotero
  storage: `fraser`'s harvest files, `peace`'s and `pine`'s local PDFs"), and that a build replaces them with what
  the named collections hold now.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/README.md:172, :24 and :501-502; scripts/0150-store.R:16 and :246 — the rebuild
  remedy is one claim held in many places, and round 2 fixed two of them. Round 2 asked to point "the line-167 and
  0275 sentences" at the rule; neither was touched. Still giving update-then-push: README:172 ("after a library
  change, ACTION=update with the same COLLECTIONS brings a store up to date instead", under build lines that each end
  "then ACTION=push"); README:24 (the run order: `0150 update a store in place`, then `0150 push the store ... after
  ANY local write`); README:501-502 (the `0275` bullet: "brought up to date with `0150 ACTION=update`"); and
  `0150-store.R`'s usage comment at line 16 ("Pull the store first ..., push it after.") and its closing message at
  line 246 ("It is not in the bucket until ACTION=push."), which is the text a person running the update reads last.
  A reader following any of them pushes an updated store without the rebuild that CLAUDE.md:169-170 and
  README:265-266 now require: for `habitat_modelling`, a 3.6 GiB upload of 0.9 GiB of data. No data loss; the cost is
  the bloated store in the bucket and two procedures for one store. Fix: point each at the update bullet (or, for the
  script, add "rebuild first while cred#48 is open" to the message), or hold the rule in one place and reference it.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a remedy repeated across sibling
    messages is one claim written many times)

- **[severity: minor (false record)]** scripts/logs/rag/20261115_rebuild_bull_trout.log:1 — "#194: the in-place
  update left the file mostly free blocks". `bull_trout`'s update left 32 % free (findings.md:66, cred#48's table),
  the case round 2 corrected in README:490 for exactly this phrase. The `bull_trout_grayling` (71 %) and
  `habitat_modelling` (76 %) logs' identical line holds. Fix: annotate this log, as round 2 did the update logs
  ("32 % free; rebuilt under the one rule for every updated store").
  - **Rule:** none
