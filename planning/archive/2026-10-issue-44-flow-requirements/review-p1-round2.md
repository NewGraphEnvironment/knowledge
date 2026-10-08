# Review: #44 Phase 1 staged diff, round 2

## Clean

No bugs, security issues or data-loss risks found.

## What was checked (evidence, not findings)

- Staged tree copied with `git checkout-index` to the scratchpad. `test-literature.R` passes there with no
  failures. `knw_literature_read("data/literature_evidence.csv")` reads: 44 `discharge` rows, 1 `instream_flow`.
- Moved row (data row 121, file line 122), checked against the PDF
  (`gottesfeld_rabnett_2007_skeena_fish_populations_and_their_habitat.pdf`, PDF p. 24, printed p. 6). The
  quote is verbatim. `bound = min`, `value_min = 1` and `m3/s` match "flows of less than 1m3/sec often
  prevent upstream migration". `metric = unstated` is right because the sentence names no statistic, and
  CLAUDE.md says never to infer one. `kind = expert` and `life_stage = migration` hold.
- Other flow-worded rows: I read all 44 remaining `discharge` rows and every row whose quote mentions
  flow/discharge/cfs/m3/s. All are stream size: Rebellato Table 1 MAD; the Sheer/Agrawal, Lindley, Woll and
  Burnett mean-annual-flow curves; Bjorkstedt's 50 m3/s curve; the `qual` IP-framework rows; Isaak's
  summer-flow trim, which says "trout are rare in such small streams"; and Boughton & Goslin Q89, which p. 2
  calls "a substitute for mean annual discharge". Busch row 28 ("<4 m during seasonal low flow") is a width
  and is correctly `channel_width`. No other row is a flow need.
- Roxygen claims against the code:
  - "`percent MAD` fits no other variable": enforced. It appears only in `fits$instream_flow`, and the test
    covers both `discharge` and `gradient`.
  - "every other row leaves `metric` blank": enforced by `stray` and `idle`.
  - "an `instream_flow` value needs a metric": enforced by `bare`.
- Consumers:
  - `0280` is the only script that reads the table. Its THERMAL `meets()` keys on `variable`, so a shared
    metric name (`daily_mean`, `monthly_mean`, `annual_mean`) cannot leak into a thermal cell.
    `SCALE[["percent MAD"]]` is an exact `[[` lookup that falls through to scale 1, which fails closed.
  - `ip.R` takes only `life_stage`, `life_history_form` and `quote_source` from the literature vocabulary.
  - There are no snapshot tests, and nothing in `pkg/` or `scripts/` enumerates `variable` values.
- BT `rear_mad_min` `none` row (data row 124) says Isaak is "row above". That is still true, because the move
  changed no row order.

## Notes, not defects

1. **Context the moved row's note leaves out.** The quoted sentence sits directly under "Figure 4. Upper
   Bulkley and Exchamsiks Rivers – September mean flow", after "summer drought in many years leading to
   extreme low flows". `unstated` is still the right metric, because the sentence does not tie the 1 m3/s to
   the figure. But `research/modelled_discharge.md:90-94` compares September gauge means against this
   1 m3/s line, which treats the threshold as if it were a September mean. Two options: name Figure 4 (the
   September mean) in the row's note as adjacent context, or add a caveat to the research file that the
   threshold's statistic is unstated. Either keeps a later reader from coding it `monthly_mean` on the
   strength of the research file.
2. **A sentence that is wrong out of context.** The roxygen sentence "The two are not interchangeable, so
   only `instream_flow` takes a `metric`" is right within its paragraph, which compares the two flow
   variables. Taken alone it is false, because temperature, air temperature and degree-days also take one.
   "of the two, only `instream_flow`..." would make it unambiguous. It is a wording point, not a code issue.
3. **No NEWS entry.** `pkg/NEWS.md` has nothing yet for the new variable and unit (0.3.1 recorded
   `groundwater`). Presumably this lands at release. It is listed here so it is not missed.
4. The new error message reads "a instream_flow value needs a metric". That is cosmetic and comes from the
   existing `"a "` prefix.
