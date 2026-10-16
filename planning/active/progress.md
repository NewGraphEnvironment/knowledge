# Progress — Clean up and make the repo public (#56)

## Session 2026-10-16

- Plan-mode exploration — phases approved by user
- Created branch `56-clean-up-and-make-the-repo-public-packag` off main
- Scaffolded PWF baseline from issue #56 with approved phases
- Next: start Phase 1
- Phase 1: package at the root (`git mv`), root `.Rbuildignore`, `URL`/`BugReports`, scripts `load_all()` from the
  root, `test-data-dir.R` (planted `data/zz_probe.R` and `.rda` each fail it; clean tree passes). `devtools::check()`:
  0 errors, 0 warnings, 1 note (`comms` at top level, removed in Phase 2).
