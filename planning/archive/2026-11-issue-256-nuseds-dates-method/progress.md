# Progress — A method for reading NuSEDS spawning dates: what a record can bound (#256)

## Session 2026-11-24

- Plan-mode exploration — phases approved by user
- Created branch `256-a-method-for-reading-nuseds-spawning-dat` off origin/main
- Scaffolded PWF baseline from issue #256 with approved phases
- Next: start Phase 1

## Phase 1, 2026-11-24
- Plan review (Plan agent) returned beside Phase 1; 16 findings folded into task_plan.md (`review-plan.md`).
- `data-raw/nuseds_dates_read.R` (shared reader) and `data-raw/nuseds_dates_check.R`; log `scripts/logs/timing/20261124_nuseds_dates_check.txt`.
- The rule test was added to the plan after the first run (which showed the NONE OBSERVED windows) and before the test ran.
- Next: Phase 2, the method in `research/nuseds_timing.md`.

## Phase 3 (code), 2026-11-24
- `nuseds_survey()` and `nuseds_mid()` moved into the shared reader; the check script reads them (its counts moved by one or two where a start is given only as `start_spawn_dt_to`; the log was rerun).
- `data-raw/timing_nuseds.R` on the shared reader with four readings (rec_, bulk_, peak_, edge_); its three checks pass on rec_, and every rec_ value of all 6,112 windows equals 20261121's.
- Logs `scripts/logs/timing/20261124_timing_nuseds{.txt,_windows.csv}`.
- Next: Phase 2 and Phase 3's research write-up.

## Phase 2 and Phase 3 (write-up), 2026-11-24
- `research/nuseds_timing.md` opens with what a NuSEDS date is (upper Bulkley worked, Morice and Nanika beside it), the rule test and choice, the four readings, the note wording, and the four groups' rows refilled estimate against estimate, with UFRA and COTR under the method.
- Every number checked against `20261124_nuseds_dates_check.txt` and `20261124_timing_nuseds*`; three statements corrected in that pass (the grid share, the accuracy wording, the MORR coho direction).
- Next: Phase 4, the UFRA and COTR notes and the issue bodies.

## Phase 4 and validation, 2026-11-24
- UFRA and COTR chinook notes rewritten in the method's wording, dates unchanged; #241 and #242's "Waits on #256" lines point at the branch.
- `/code-check branch`: five rounds; rounds 2 to 5 each found a defect inside an earlier fix or the same mechanism (a set built twice); ended on round 5's enumeration of 80 claims, fixed and re-checked (`review-verdict.md`). Tests: 0 failures, 2678 passing.
