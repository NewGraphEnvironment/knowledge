# Progress — Backlog move 10: Report corpus: one library, stable keys, and our own prose indexed (#179)

## Session 2026-11-21

- Plan-mode exploration — phases approved by user
- Created branch `179-backlog-move-10-report-corpus-one-librar` off origin/main
- Scaffolded PWF baseline from issue #179 with approved phases
- Next: start Phase 1
- cred 0.8.0 and ragnar 0.4.0 installed; Plan review in (`review-179.md`), folded into the plan: a sixth store (`peace`)
  left out with its reason, Zotero quit before the builds (cred#45), backlog names checked, two more copies of the
  BBT-named sentence fixed
- Phase 2: triage script and verdicts (113 present, 51 merge, 4 discard), policy in `CLAUDE.md`, research file
  ; filed #251 (split from #13) and cred#53 (blocks #14); #13, #14, #16 and #179 bodies edited;
  backlog batch 16 now carries #13 only
- Phase 1: OCR running (the first try failed under the sandbox's `/tmp`; `TMPDIR` in the scratchpad fixed it)
- OCR done 08:39–09:00 UTC (21 min, 1,453 pages): word counts 4,817 (Hartman) to 97,071 (Ford); each title page read;
  ten `replace` rows appended; `0275 --only <ten> --dry-run` clean
- `0275` live for the ten (09:02 UTC); new attachments synced with the OCR md5s, but cred's immutable read saw none of
  it until Zotero was quit (0-byte `-wal`); rebuilds 09:04–10:48 UTC: habitat_modelling 404 → 414, temperature 53 → 54,
  fish_passage 24 → 25, bull_trout_grayling 196 → 197, each with its new keys and none of the old
- `flow`'s first rebuild dropped two more textless HSI scans; OCRed (Hubert's needed `--invalidate-digital-signatures`),
  replaced, Zotero reopened to sync and quit again, `flow` rebuilt to 43 with all six new keys
- All five pushed (10:50–10:56 UTC), each verified connect kept the local file (md5 matches manifest); queries return
  Bjornn & Reiser 1991 and Ford et al. 1995; tests 2,557 pass, 0 fail; Zotero reopened; #217's body corrected
- `/code-check branch`: five rounds, ended on an enumeration (`review-enumeration.md`, `review-verdict.md`). Rounds 2-4
  each found a defect inside the previous fix (the triage CSV's read-back guessing who decided a row, until `decided_by`
  made it explicit; `central_file` judged on any file, then on one central copy). Round 3 found the push logs dumping
  the bucket manifest, which named a private repository; round 4 found a host name left in early planning commits.
  The branch's history was rewritten twice before its first push, and all five stores re-pushed at `c75c804a`.
