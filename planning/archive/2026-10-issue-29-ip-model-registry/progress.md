# Progress — Intrinsic-potential model registry from the PNW literature, to seed every species' thresholds (#29)

## Session 2026-10-01

- Plan-mode exploration — phases approved by user; both forks decided at the gate (thresholds as
  evidence rows linked by `model_id`; rows for every species a model covers)
- Created branch `29-intrinsic-potential-model-registry-from` off main
- Scaffolded PWF baseline from issue #29 with approved phases
- User: "go all phases" — run to PR
- Next: start Phase 1
- Phase 1:
  - issue body edited;
  - `knw_ip_read()`/`knw_ip_vocab()` and the `model_id`, unit and variable additions, tests first;
  - 0280 gates the registry and the links;
  - seed registry: Rebellato and Cooney & Holzer, CH × 3 stages;
  - 20 rows tagged;
  - gate green: 190 evidence rows, 6 registry rows, 9 quotes;
  - five guard mutations, all exit 1;
  - `R CMD check` 0/0/1 (the NOTE is the sandbox clock).
- Plan review landed mid-Phase 1 (`review-plan.md`), and its findings are folded in.
- Phase 1 `/code-check`, three rounds (`review-p1-round{1,2,3}.md`):
  - **Round 1:** 3 findings, all fixed:
    - the gate and the reader crashed on a header-only registry;
    - a `;`-only `flow_inputs` passed;
    - the `^m` fallback gave m3/s and m bankfull/wetted a ×1000 rescale.
  - **Round 2:** 1 finding inside round 1's fix, fixed. `.ip_check` normalised `flow_inputs` on its local
    copy and the reader discarded it. Also 1 pre-existing finding, fixed: the OCR sidecar is now written
    atomically.
  - **Round 3:** asked for the mechanism ("the value gate keys on the spelling, not on the variable × unit,
    and contracts are kept in prose"). 3 latent fail-toward-pass findings, all fixed:
    - an unknown unit now defaults to scale 1;
    - unit exponents are no longer read as values;
    - the link key includes life-history form.
  - **Ended by enumeration:**
    - every one of the 17 vocabulary units, written after "value 7", yields only 7, and each has an
      explicit `SCALE` or a default of 1;
    - the link key equals the registry's identity columns;
    - `.ip_check` has exactly one assignment to `x`, and it is returned.
  - Mutation proofs: 8 guards, all exit 1. The original 5, plus ×1000 MAD, a registry form mismatch, and
    the exponent probe.
- Phase 1 committed dc999c7.
- Phase 2:
  - 0270 dry run, then live: Burnett 2007 copied from library 6; Bjorkstedt 2005, Lindley 2006 and
    Boughton & Goslin 2006 created from the web. All four synced with keys and PDFs within about 2 min.
  - Store rebuilt (14:36–15:06 UTC, about 30 min, 8 workers): 207 documents, 35,130 chunks.
  - Spot queries return Lindley and Burnett first for their topics.
  - Pushed, and md5 `2f8fd201390b0f64b074a84b313d84e4` matched by a verified connect.
- Phase 3:
  - Three drafters (ow, ca, nb), each on a frozen gate copy; merged by `merge_drafts.py`. Corrected at merge:
    - `bjorkstedt2005` split out;
    - `unstated` added as a `flow_source`;
    - three CO/ST `none` rows written.
  - `COVERAGE` now CH, BT, CO, ST.
  - Gate: 481 evidence rows, 81 registry rows, 117 quotes, links green both ways, coverage 48 of 48.
- Phase 3 `/code-check`, three rounds (`review-p3-round{1a,1b,2,3}.md`), all meaning audits of every in-scope
  row against the PDF:
  - **Round 1** (two reviewers in parallel): 12 findings, all fixed.
    - Rebellato's "not validated" was read off the lateral-habitat sentence (my seed-row error).
    - Porter's cross-validation was pruning, not validation.
    - Two superseded Cooney ratings were tagged.
    - Boughton's summer flow sat under the MAD parameters.
    - `busch_nwfsc` form was too narrow.
    - Stale notes, and two false search claims in `none` notes.
    - Plus 26 interior breakpoints that carried `bound` as if they were limits.
  - **Round 2:** 6 findings, 3 of them inside round-1 fixes, all fixed.
    - Stale form clauses; the Bjorkstedt claim fixed in one row but not its siblings; the bound fix wrong in
      both directions (E404 lost a real zero-edge, and 11 more interior breaks were missed).
    - One invented parameter. `parameter` is now a controlled vocabulary in the reader, test first.
    - Cooney's redd ANOVA is calibration (it set the final classes).
    - Woll 2017 compared its maps with fish records.
  - **Round 3:** 4 findings inside round-2 fixes, all fixed.
    - Woll 2017's shared validation text claimed aerial surveys and false positives for species that have
      none; its pink note contradicted its `none`.
    - Ruled: Woll stays `fish_observations`, "not fully independent".
    - Busch 2011 and BLM independence caveats added.
  - **Ended by enumeration:**
    - every tagged min/max row checked by keyword against its note (3 flagged, all genuine zero-edges);
    - every registry row's validation tabulated against the rule (independent fish records = validated;
      the data that set the classes = calibration);
    - notes checked mechanically against `validation` and form (clean);
    - every registry text shared across species checked for species-specific claims (only Woll's, now
      true of each row).
- Phase 3 committed as 1084630. `R CMD check` 0/0/1 (the NOTE is the clock).
- Phase 4:
  - docs written: `research/ip_models.md`, index row, `habitat_literature.md` pointer, `CLAUDE.md`,
    `scripts/README.md`;
  - fact-checked by one reviewer against the CSVs, 0280, findings and PDFs (`review-p4-round1.md`):
    14 errors, all fixed. Overstated claims ("every claim quoted", "holds no numbers", "only in reference
    lists"), a coho barrier filed under rearing, CH width minima omitted, RB wrongly listed as having no
    model, and the cw/mad comparison regions;
  - one round only, for a prose-only commit; reported in the PR.
