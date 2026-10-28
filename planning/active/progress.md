# Progress — Compare only default and the reported structure unless asked (#112)

## Session 2026-10-28

- Plan-mode exploration — phases approved by user; Al chose to drop the other structures' sentences
- Created branch `112-compare-only-default-and-the-reported-st` off main
- Scaffolded PWF baseline from issue #112 with approved phases
- Next: start Phase 1
- Phase 1: per-rule and per-group setup minutes in `.knw_compare_bin()`, summed and logged by `knw_compare_rules()`
  (`worker_minutes`); `data-raw/compare_structures_check.R` with TUNE_DIR/COMPARE_DIR/EVIDENCE_DIR, because the
  database host's ignored inputs are an older build (visits md5 d3a434e2/bc71243b against #92's 1bd35829/009698d7;
  grade tables of 2026-10-25) while m4 holds #92's
