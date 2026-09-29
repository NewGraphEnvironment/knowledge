# Code-check enumeration — 0250 (ends the loop after round 2 found defects inside round-1 fixes)

Mechanism behind the 0250 findings: (a) a set decided from a derived quantity instead of its
source (FDIS status from the allocation; owner from the site table only; `n_measured` from the
classed subset); (b) one real thing split across key values (a catch under a blank and a named
method; a report under several groups; one FDIS fish across several sites).

## (a) Every set-membership decision in 0250

| set | decided from | source-level? | guarded by |
|---|---|---|---|
| owner group per report | union of sites / Step 2 / Step 3 tables | yes | `step3_fish_in_buckets_vs_owner_groups` (proven: fires with sites-only owner) |
| placeable sites | 0220's UTM window | yes (same literal as 0220) | count of not-placeable evidence sites |
| candidate pairs | date + zone + 50 m | yes | radius sensitivity measured (50 m -> 2 km, +1.5 %) |
| `in_fdis_sites` | raw pair x species x length join, before allocation | yes (was allocation: 34 sites, 13 char fish wrongly kept) | measured: classed 1,296 -> 1,283 |
| `in_fdis` rows | in-FDIS site AND (EF or blank method) | yes | accepted tradeoff (site rule) |
| focal fish | code table `species_group` | yes | unmapped labels listed (none focal) |
| placement set | union of evidence site keys (classed, unmeasured, spawner) | yes | `evidence_sites_unplaced` count |

## (b) Every grouping key in 0250

| key | can one thing split across values? | status |
|---|---|---|
| report -> group | yes, reports parse under several groups | one owner; `reports_parsed_differently_across_groups` = 0 |
| species label -> code | codes and names mixed | `to_code()` maps both to one code |
| method (Step 3 blank vs named) | yes | inherit per site x species, then site; gate `site_species_step3_fish_blank_beside_named_method` (proven: fires with site-only inheritance) |
| method (Step 2 blank vs named rows) | separate count rows, not duplicates (19089:1 sums 41 across 11 rows) | accepted: they add up |
| FDIS length cell -> FISS sites | yes, same survey in two reports | allocated once; overlap figures only |
| `site_key` | unique after owner | `stopifnot` |
| stage comparison `one_stage` (site x species x method) | fish carry inherited methods, Step 2 staged rows keep raw ones | can only drop a comparison, never mislabel one; affects `fiss_stage_vs_class.csv` coverage only |

Set sizes: 7 decisions, 7 keys. Nothing above its source; loop ends here.
