# Code-check P1, round 3

Reviewer: general-purpose subagent, 2026-10-01. Working tree untouched; probes were run on copies or
with functions parsed out of `scripts/0280-literature-verify.R` into a fresh R session.

## Mechanism

Two shapes produced R1–R2.

1. **The value gate decides what a quote "states" from how the text looks, not from what the row
   means.** R1 #3 is this one: the rescale was keyed on the *spelling* of the unit (`grepl("^m")`),
   so adding units to `knw_literature_vocab()` changed what 0280 accepted without anyone editing
   0280. The same thing happens in two more places: the number set is built from every digit token
   in the quote, unit exponents included (finding 2), and the rescale is keyed on the unit alone
   with no reference to the variable (finding 1).
2. **A contract kept in prose rather than enforced in code.** R1's zero-row crashes, and R2's
   "normalised but not returned". Finding 3 is the same kind: the comment in 0280 says every
   registry row has evidence, but the key the link uses is narrower than the registry's own
   uniqueness key.

## Findings

- **[fragile]** scripts/0280-literature-verify.R:339 (`SCALE` at :305). The `^m` → ×1000 fallback is
  now unreachable for every unit in the current vocabulary. All seven lower-case `m…` units
  (`m`, `m bankfull`, `m wetted`, `m3/s`, `mm`, `m/s`, `mi2`) have their own `SCALE` entry, so the
  only input that can reach the fallback is a unit added later, and that is exactly where it is
  wrong (R1 #3 again, for example `mg/L` or `mi`). Nothing ties `SCALE` to the vocabulary, so the
  guard fails toward pass on vocabulary growth. Dropping the fallback (default `1`) changes nothing
  today and fails closed. The same keying-on-unit-alone also gives plain `m` its ×1000 on
  `channel_width` and `depth`, not only on `bridge_distance`. That overlaps the ACCEPTED item, so it
  is noted only for reach. Measured: 9 `channel_width` rows are in plain `m`, and none of them
  passes only because of the ×1000 (all 190 rows pass `value_in_quote`; with every scale set to 1,
  the only rows that fail are 1 `percent` row and 3 `mm` rows, which are legitimate rescales).

- **[fragile]** scripts/0280-literature-verify.R:157/310–324. Unit exponents count as stated numbers.
  `TOKEN` splits `km2` into `km` and `2`, and `m3/s` into `m`, `3`, `/`, `s`, and `quote_numbers()`
  takes every numeric token. So any quote that writes a unit as `km2`, `mi2` or `m3/s` "states" 2 or
  3. Probe: `value_in_quote(list(variable="drainage_area", unit="km2", value_min="2", quote="streams draining more than 50 km2 were excluded"))`
  is `TRUE`, and so is `discharge`/`m3/s`/`3` against "below 0.5 m3/s". This diff adds
  `drainage_area` with `km2`/`mi2`, which widens the hole to a new variable whose quotes will
  routinely carry `km2`/`mi2`. Measured: the 3 committed rows whose quote contains `km2` or `m3/s`
  all take their value from a real number (0.5/1.5, 0.28, 1), so nothing passes on an exponent
  today. A digit attached to a unit word should not count as a value: drop a numeric token that
  directly follows `km`, `mi`, `m` or `ft` with no space between them in the cleaned quote.

- **[fragile]** scripts/0280-literature-verify.R:433–437 compared with pkg/R/ip.R (`dup` check). The
  link key is `model_id × species × life_stage`, but `.ip_check` treats `life_history_form` as part
  of a registry row's identity. The test "a model x species x stage x form appears once" builds two
  rows that differ only by form. When a model has two such rows (for example CH spawning
  `stream_type` and `ocean_type`), they share one link key. Evidence for either form then
  satisfies `unread` for both, so a registry row with no thresholds of its own passes. An evidence
  row tagged with a form the registry does not have also links silently. That contradicts the gate's
  own claim at :35–38 that "every registry row has at least one tagged evidence row". Latent: the
  committed registry has one form per model × species × stage. Either add `life_history_form` to
  the link (an NA form in the evidence would then need to match, or be explicitly allowed to
  match, any form), or forbid two forms per model × species × stage in `.ip_check`.

## Where the mechanisms reach (enumerated; no defect unless listed above)

- **Zero rows.** Header-only `knw_literature_read` gives a 0×19 tibble, and header-only
  `knw_ip_read` gives 0×23 (both measured). For the 0280 registry block (`PASS` … `unread`) I
  evaluated the script's own lines with `check_row` stubbed, on the header-only registry and on the
  committed 6-row one. Both run. With 0 rows the output is a 0-row `reg_out`, an empty summary
  string, and `link_key()` returning `character(0)` because every `paste` argument is zero-length.
  The 0-row registry makes all 6 evidence links `unregistered`, which is correct. A pre-existing
  case is harmless: in `.literature_check`'s timing check, `paste0("2000-", character(0))` yields
  `"2000-"`, but the `grepl()` term on `character(0)` makes the conjunction `logical(0)`.
- **Vocabularies that must agree.** The 14 variables match the 14 `fits` names. All 17 units sit
  in at least one `fits` entry. Every lower-case `m…` unit has a `SCALE` entry (finding 1). `PASS`
  covers `verified_` × the 3 `quote_source` values. `flow_surrogate` is derived from
  `flow_metric`. `SCALE[[unit]]` and `fits[[variable]]` are exact-match `[[` on lists, so
  `km2`/`km` and `mm`/`m` do not collide.
- **What the reader normalises against what it returns.** `.knw_blank_to_na` result: assigned in
  both readers. `.ip_check`'s `flow_inputs` rewrite: returned and assigned in `knw_ip_read`.
  `.literature_check` mutates nothing, so discarding its return is harmless. 0280 makes `t_keys`
  trimmed tokens before resolving them.
- **Registry quotes through `check_row`.** `quote_row()` supplies `kind`, `citation_key`, `quote`,
  `quote_source`, `variable`, `value_min` and `value_max`. `value_in_quote` returns before it
  reads `unit` or `variable`, so the missing `unit` key is never read. `$` on that list cannot
  partial-match into the wrong key because `quote` and `quote_source` both match exactly.
- **OCR.** The per-run `work_*` dir and sidecar rename both sit inside `data/rag/ocr`, so the
  rename stays on one filesystem. `on.exit` is inside a function, so it fires. A killed run leaks
  one `work_*` dir, which nothing reads.

Tests: `devtools::test(filter = "ip|literature")` all pass. The Rd examples for `knw_ip_read`,
`knw_ip_vocab` and `knw_literature_read` run.
