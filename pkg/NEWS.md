# knowledge 0.2.1

* `knw_literature_vocab()` adds `elevation` to the `variable` vocabulary, in
  `m` or `ft`, so a source that fits an elevation term (a watershed-scale
  occurrence coefficient, say) can be recorded. Other units are refused.

# knowledge 0.2.0

* `knw_ip_read()` and `knw_ip_vocab()` read and validate the intrinsic-potential
  model registry: one row per model, species and life stage, recording how the
  model sizes streams (`flow_metric`, `flow_source`, `flow_inputs`,
  `flow_surrogate`), its valley-confinement variable and whether it was
  validated against fish, each claim with a verbatim quote.
* `knw_literature_read()` requires a `model_id` column (its value may be
  blank), linking a threshold to the registry model that uses it. A table
  without the column is refused.
* `parameter` is now a controlled vocabulary (the habitat-model parameter
  names, in `knw_literature_vocab()`), so a misspelt or invented parameter is
  refused rather than silently matching nothing.
* New evidence variables `valley_width_index` (`ratio`) and `drainage_area`
  (`km2`, `mi2`); `cfs` for discharge and `ft` for channel width are read as the
  source wrote them.

# knowledge 0.1.0

* First version: PSCIS pulls by watershed group, GNIS collision checks, size
  classes, and readers for the life-history timing and literature evidence
  tables.
