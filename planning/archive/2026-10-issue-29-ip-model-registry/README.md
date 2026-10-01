## Outcome

The Pacific Northwest intrinsic-potential (IP) literature is now a gated registry. It supplies thresholds for
every species those models cover, not only CH and BT.

- **Registry.** `data/ip_model_registry.csv` (read with `knw_ip_read()`) records 17 models: Sheer et al. 2009
  Table A1 and later work in Oregon, Washington, California, Alaska and BC. For each model × species × stage
  it records:
  - how the model sized streams (`flow_metric`, `flow_source`, `flow_inputs`, `flow_surrogate`);
  - its valley-confinement variable;
  - its validation.

  The flow claim and any claimed validation are quoted verbatim.
- **Evidence table.** The registry holds no thresholds. They are rows of `data/literature_evidence.csv`
  carrying a new `model_id`, so each number is stored once. `0280` gates both tables, checks the link both
  ways on model × species × stage × form, and now requires coverage for CO and ST as well as CH and BT.
- **Collection and store.** Burnett 2007, Bjorkstedt 2005, Lindley 2006 and Boughton & Goslin 2006 joined
  `Fisheries/habitat_modelling`, and the `habitat_modelling` store was rebuilt and pushed.
- **Package.** `pkg` is 0.2.0:
  - `knw_ip_read()` / `knw_ip_vocab()`;
  - a required `model_id` column;
  - `parameter` is now a controlled vocabulary;
  - new variables (`valley_width_index`, `drainage_area`) and US units read as written.

The substantive finding is in `research/ip_models.md`. **No PNW IP model thresholds on gauged flow.** Mean
annual flow was a regression on drainage area and precipitation, and five models threshold on modelled width.
So building MAD for the Skeena and coast would repeat our width model's inputs. The one open question is
whether BC's process-based MAD carries information width does not. That question is measurable where both
exist, and it is the input to link#286.

What was learned about the method:
- **Quotes verify, meaning does not.** A gated quote proves the words exist, not that the row means what the
  source means. The reviews that mattered here were full-row meaning audits against the PDFs. Round 1 found 12
  errors of meaning in rows whose quotes all verified, one of them in the Phase 1 seed row written by hand.
- **The same classes recurred inside their own fixes,** twice:
  - a stale note left behind by a field fix;
  - a correction applied to one row but not its siblings;
  - a bound fix that went wrong in both directions;
  - a shared validation text that was true of some species and not others.

  The loop ended on enumeration, not on a quiet round.
- **Validation needed a rule before it could be coded consistently.** The rule: comparison with fish records
  the model was not fitted to is validation; comparison with the records that set its classes is calibration.
  Under it, Cooney & Holzer's redd ANOVA and Rebellato's chum and pink checks are calibration.

## Measurement

- **Tables:**
  - **Evidence:** 190 → 481 rows. 291 new (288 cited plus 3 `none`). 324 rows carry a `model_id`: CH 107,
    CO 77, ST 76, SK 23, CM 17, PK 17, RB 4, BT 3. 18 existing rows were tagged, with only `model_id`
    changed, confirmed by a field-level diff.
  - **Registry:** 81 rows, 17 models, 117 quotes, all verified.
  - **Coverage:** 24 → 48 species × parameter cells, all with a row.
- **Collection:** 88 → 92 members (77 with a PDF). Every new item synced with a BBT key and a PDF on disk
  within about 2 minutes of the 0270 writes.
- **Store:** 202 → 207 documents and 33,746 → 35,130 chunks; rebuilt in about 30 minutes on m1 with 8 workers.
  Manifest md5 `2f8fd201390b0f64b074a84b313d84e4`, matched by a verified connect. The same 3 keys as #19
  were dropped by cred's lookup.
- **Flow finding** (17 models):
  - mean annual flow, modelled from gauges on drainage area and precipitation: 7;
  - BC hydrologic-model MAD with a width surrogate: 1;
  - summer low flow: 1;
  - modelled channel width: 5;
  - width with an unstated source: 2;
  - none: 1;
  - gauged directly: 0.
- **Code-check:**
  - Phase 1, three rounds:
    - 3 findings;
    - then 1 inside a fix, plus 1 pre-existing;
    - then 3 latent fail-toward-pass findings, found after asking for the mechanism.
  - Phase 3, three rounds of meaning audit:
    - round 1, two reviewers in parallel: 12 findings, plus 26 breakpoint bounds;
    - round 2: 6 findings, 3 inside round-1 fixes;
    - round 3: 4 findings inside round-2 fixes.
  - Phase 4: one fact-check round, 14 findings. This was a deliberate single round on a prose-only commit.
- **Guard proofs:** 8 mutations of the gate, each exiting 1:
  - a fabricated flow quote;
  - a fabricated validation quote;
  - an unread registry row;
  - an unknown `model_id`;
  - a wrong species;
  - a ×1000 MAD;
  - a form mismatch;
  - a unit exponent read as a value.
- **Subagents:** 12 spawned in total. That is over the default of about 5. The extra rounds are where the
  meaning errors were found.
  - 1 plan review;
  - 3 Phase 1 code-check rounds;
  - 3 drafters;
  - 4 Phase 3 reviewers (round 1 as two in parallel);
  - 1 docs fact-check.

  The wrong turns are kept in `findings.md` and the review files:
  - Busch "2013" proposed as a separate work;
  - Rebellato "not validated";
  - Bjorkstedt's Chinook curves filed under Agrawal;
  - bounds blanked on a real zero-edge.

## Evidence

- `scripts/logs/habitat/20261001_*`: the collection build, store build and push, and both gate logs.
- This directory:
  - `review-*.md`: the plan review and every code-check round;
  - `draft-{ow,ca,nb}-notes.md`: per-model page references and the flow detail;
  - `drafter-brief.md`.

Closed by: PR from branch `29-intrinsic-potential-model-registry-from`
