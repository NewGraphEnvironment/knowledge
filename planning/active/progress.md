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
