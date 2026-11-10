# Progress — Backlog move 3 (#172)

## Session 2026-11-09

- Plan-mode exploration — phases approved by user (gate: #20's data question to wet#5; BDA3 only; #20's rows kept)
- Created branch `172-backlog-move-3-zotero-fix-what-the-group` off origin/main
- Scaffolded PWF baseline from issue #172 with approved phases
- Next: start Phase 1
- Phase 1 (#168): `0153`'s `api_key()` reads `ZOTERO_API_KEY`, else `ZOTERO_API_KEY_FILE`'s first non-blank line.
  Seven branches probed by import (var set; var blank + file; file only; empty file; blank-lines file; missing file;
  neither), 0270 reads the file key through `z.API`, and `data-raw/zotero_copy_check.R` PASS (its child still uses the
  placeholder variable).
