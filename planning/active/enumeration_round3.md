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
