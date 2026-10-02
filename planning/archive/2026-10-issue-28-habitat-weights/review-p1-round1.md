# Review — Phase 1 (`scripts/0290-bt-use-build.R`), round 1

Reviewed the staged diff, the script, the ledger, and the run's output
(`data/fdis/derived/bt_use_visits.csv`, 15,883 rows), checked against `fdis_sites.csv`,
`data/fdis_species_codes.csv`, link 0.55.0's `lnk_species_pooling()` and the local fwapg.

## Findings

- **[severity: bug]** scripts/0290-bt-use-build.R:44 (`char_codes`) with :87-93 — `char_codes`
  claims to be the `char` group of `data/fdis_species_codes.csv`. It is missing `SLV` ("Char,
  general: counted as char presence"). 0240 counts `SLV` into `n_char_other`, and so into
  `n_char`. In a DV-pooled WSG, `bt_n = n_char` therefore counts SLV fish while `bt_present`
  ignores them. Measured in the output: 2 rows in UFRA (`179331_1_1`, `179332_2_1`) have
  `species_caught = SLV`, `bt_present = FALSE` and `bt_n = 1` and `3`. Each is a char catch
  recorded as a confirmed BT absence, with a positive BT count in the same row. Fix: read
  the char codes from the codes file (`species_group == "char"`) rather than keeping a
  literal copy, and decide whether SLV counts as BT presence or blocks the absence.

- **[severity: bug]** scripts/0290-bt-use-build.R:90-91 — in a WSG where DV is not pooled,
  `bt_present` is `"BT" %in% codes`. A visit whose only char is `BT/DV` ("either DV or BT,
  but suspect they are BT") is therefore kept as a **confirmed BT absence**. `BT/DV` does
  not block absence in the codes file because it is char presence, so line 98 does not
  catch it either. The header justifies DV-as-absence ("a visit that caught only DV is a BT
  absence"), but `BT/DV` is a suspected BT, not a DV. Measured: 19 kept visits, all in KLUM
  (calibration). That stratum (`pooling == "BT"`) holds only 30 presences against 652
  absences, so 19 suspected-BT catches read as absences is material there. `DVxBT` and
  `SLV` take the same path; neither occurs in the current output. Either count these as
  presence or drop them as absence-blocked. A confirmed absence is the one reading the
  evidence does not support.

- **[severity: fragile]** scripts/0290-bt-use-build.R:124 — `if (anyDuplicated(seg$site_visit)) stop(...)`
  cannot fire. Each query is `DISTINCT ON (t.site_visit)` and the two schemas' WSG lists
  are disjoint, so any multi-segment match has already been collapsed before the check
  runs. The real multi-matches today are harmless: 29 in fresh_default and 6 in
  score284_default, every one a 2-segment overlap. They do not quite fit the header's
  "< 1 mm", though: the largest overlap is 1.42 mm. A genuine overlap, such as a duplicated
  segment, would still be resolved silently by `drm DESC, id_segment` and never reach the
  guard. No current data impact. To make the guard real, count the matches before the
  DISTINCT ON, or bound the overlap.

Checked and fine:
- [drm, urm) placement.
- Join uniqueness of `streams_access` and `streams_habitat_bt` on (wsg, id_segment) in both schemas.
- Z present on every `streams` geom.
- Tercile cuts match link's `cut(c(-Inf, cuts, Inf))`, right-closed.
- The pooling tracker pools only `DV` for BT, and no `obs_year_max` is set.
- No NA `year`/`bt_n`.
- The ledger partitions the input.
- The findings figures (2,250 with BT; 15,201 in DV-pooled WSGs) match the output.
- The `flag_no_area` drop is consistent with the Phase 2 `log(area_m2)` model.
