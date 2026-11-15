# Enumeration after round 3: every tracked passage that gives the update procedure

The mechanism round 3 named is one remedy repeated across several passages: round 2 fixed two of them, and the others
still said update, then push. Set: `git grep -n -E "ACTION=update|crd_store_update"` over tracked files outside
`planning/archive/`, `scripts/logs/` and the review files (2026-11-15, after the round 3 fixes). Planning records
(`task_plan.md`, `findings.md`, `review-plan.md`) describe what this branch did, not a procedure, and are left out.

| passage | says push after update? | rebuild rule |
|---|---|---|
| `scripts/README.md:24` (run order) | implied | states it (cred#48) |
| `scripts/README.md:172-173` (under the build lines) | yes, the lines end "then ACTION=push" | points to the update bullet |
| `scripts/README.md:259-268` (the `ACTION=update` bullet) | yes | **the one statement**: 32 to 76 %, rebuild with `OVERWRITE=TRUE`, never reaches `fraser`, `peace`, `pine` |
| `scripts/README.md:492-493` (bull trout store) | yes | points to the update bullet |
| `scripts/README.md:503` (`0275` bullet) | brought up to date | points to the update bullet |
| `CLAUDE.md:165-170` (Ragnar stores note) | yes | states it, points to the update bullet |
| `CLAUDE.md:240` (merging duplicates) | no: a document "joins a store at its next update" | none needed |
| `scripts/0150-store.R:11-18` (usage) | yes, was "push it after" | states it |
| `scripts/0150-store.R` closing message after an update | yes ("not in the bucket until ACTION=push") | prints it after every update |
| `scripts/0150-store.R:204-242` (code) | no | none needed |
| `scripts/0275-zotero-attachments-tidy.py:44` | no: names the stores to update | none needed |

Nothing in the set gives update-then-push without the rule or a pointer to it.

Round 4 found a passage the regex could not match: README's "Push after every local write (..., a rebuild or update)",
a bare "update". It now names the rebuild. Rerun with `git grep -n -i -E "update" -- scripts/README.md CLAUDE.md
scripts/0150-store.R` and read for push: no further passage gives update-then-push without the rule. The README's
"one place" claim was false (the rule is carried in four places); it now lists them, and `git grep -n cred#48`
finds every copy.

Round 5: the README's "a warning R cuts after six" was a miscount (R cuts at `warning.length`, 1,000 characters; the
habitat_modelling warning is cut inside its seventh entry), and the comparison step reached only the README. The
remedy is now in the code, not in more copies of a sentence: `0150` lists the documents a rebuild dropped from the
store it replaced, as it does for an update (checked on a scratch copy of `statistics`: "4 documents before, 4 after:
0 added, 0 dropped"), and its message after an update says to read that list.

Round 6 found the round-5 pre-read refusing a rebuild over a file it cannot read, which a rebuild used to replace.
A build now reads the old store under `tryCatch()` and says so when it cannot; an update still stops. The candidate
set is every state of the file at the store path, run on a scratch store (deleted after), 2026-11-15:

| file | action | result |
|---|---|---|
| valid store | build `OVERWRITE=TRUE` | "4 documents before, 4 after: 0 added, 0 dropped"; built |
| valid store | build | cred refuses ("Store already exists"), as before |
| 0-byte file | build `OVERWRITE=TRUE` | "cannot be read, so no dropped list follows"; built |
| 5,000 random bytes | build `OVERWRITE=TRUE` | the same; built |
| 5,000 random bytes | update | stops in `dbConnect()` (not a valid DuckDB file), as before |
| absent | update | "is not here to update: pull it first", as before |
| absent | build | built, no counts printed |

A store with no `documents` table was attempted, but dropping it did not take (the run read 4 documents), so that
state is untested; it reaches the same `tryCatch()` branch as the two unreadable files. Round 6 found a held write
lock now refused rather than unlinked under its writer (safer), and a killed build's main file plus `.wal` still
read. Nothing in the set behaves worse than before 213e0fcc.

