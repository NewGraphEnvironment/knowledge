# Review 0250 — round 2

## Findings

- **[bug]** scripts/0250-fiss-evidence.R:187-196 — the round-1 allocation fix changed which sites count as "in FDIS", so evidence rows are affected. The findings note says they are not.
  - `in_fdis_sites` is now taken from `matched` after the per-cell allocation and `filter(n_matched > 0)`. When one survey was submitted in two reports, both FISS sites pair with the same FDIS visit. The site whose `site_key` sorts first takes every FDIS fish in the cell, and the other gets an allocation of 0. That second site then drops out of `in_fdis_sites`, and its electrofished fish are kept as new evidence, even though they duplicate FDIS.
  - Measured by re-running lines 1-253 with the writes removed. 2,949 sites have a length match before allocation and 2,915 after, so 34 sites lost their FDIS status. All 34 are report 19867, and each partner site is in report 19729 and is dropped. The 34 sites hold 1,547 EF fish. Their Step 2 counts are not dropped either.
  - In the staged `data/fiss_evidence.csv` this gives 12 rows at 11 of those sites, 13 char fish in all (adult 9, subadult 2, juvenile 2, electrofishing). Every one of them is already in `fdis_evidence.csv` through the partner site's FDIS visit. The "FDIS overlap: 2915 sites, 98616 ... dropped" line in the log is the smaller number because of this.
  - Before the fix, both sites were dropped. The regression is in the evidence, not only in the overlap figures.
  - Fix: decide `in_fdis_sites` from the raw pair × length join, before allocation (any shared species and length). Use the allocation only for `fish_matched` / `share_matched`.

- **[bug, small]** scripts/0250-fiss-evidence.R:161-167, 226-253 — method inheritance splits one catch across two keys, and the result is double counted.
  - A fish inherits a method only when the site's Step 2 names exactly one. Step 2 rows keep their own method, and Step 3 fish with a blank method stay under `method = NA`.
  - At `50296:7` BT there are 2 fish under NA and a Step 2 angling count of 2 with nothing measured. The file writes `unmeasured` 2 under angling and `unmeasured` 2 under NA, so 4 fish from a catch of 2.
  - It is 1 site × species today. No gate can see it, because both new gates are per key (see below).

- **[fragile]** scripts/0250-fiss-evidence.R:370-377 — two of the new gates are now identities by construction, not reconciliations.
  - `evidence_n_vs_n_caught_mismatched_keys`: `by_class` + `n_nolength` both come from the same `ff` rows as `n_measured`, so classed + nolength == n_measured exactly. `n_caught = pmax(coalesce(n_counted, 0), n_measured) >= n_measured`, so written = n_measured + (n_caught − n_measured) = n_caught for every key. It fires only if the unmeasured formula regresses to the round-1 form. That is how it was proven, and it holds as a regression guard. But it cannot see anything the data does: a cross-key split like the one above, or Step 2 totals being wrong.
  - `n_caught_na_where_fish_measured` cannot fire. Line 245 sets NA only when `n_measured == 0`.
  - Neither is broken. Do not read either as evidence that Step 2 totals reconcile with what was written. Spawner rows are excluded from `written` correctly, so they do not interfere.

## Checked and fine

- n_measured / n_caught now match 0230's definitions. The formula for unmeasured no longer double counts fish that have no length. `52771:502` BT is now correct.
- `step3_fish_in_buckets_vs_owner_groups` does read from a different path. `owned_fish` takes the first group, alphabetically, among the groups that have Step 3 rows. `owner` takes the first group across the sites, Step 2 and Step 3 tables. If a report's owner group has no Step 3 rows while another group does, the two differ and the gate fires. The `site_method` and `sites` joins are unique, so the bucket total is `nrow(step3)`.
- Allocation arithmetic: within a cell, `pmin(n_fiss, pmax(0, n_fdis - (cumsum - n_fiss)))` is a correct greedy fill, and the order is deterministic. After the cap per FISS cell, the fish matched never exceed the FDIS fish present. Greedy per visit can undercount a site that pairs with two visits. That touches overlap figures only, apart from the zero-allocation effect above.
- Owner taken from the union of all three tables: the 808 fish now land in `no_step1_site` (851 in that bucket).
