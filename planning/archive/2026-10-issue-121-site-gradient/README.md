## Outcome

Measured how closely the gradient every habitat rule reads (link's segment gradient, and the whole Atlas line's)
follows the gradient FDIS crews measured at the same sites, on the evidence build the published thresholds name.
`data-raw/site_gradient_check.R` holds its evidence to `data/thresholds.csv`'s md5s (`EVIDENCE_CHECK=FALSE` for #120's
rerun on the minimal network) and each rearing key's population to its tracked `n_visits`, and the result is the
"Measured vs modelled gradient" section of `research/fdis_export.md`. The RISC site card defines the two gradient
rows; the export carries neither method code, and the second reading does not run higher than the first, as 0230's
comment had it. The plan expected a negative segment gradient to change nothing if set to 0; the plan review showed a
negative fails every rule (`knw_rule_in()`'s `g >= 0`) while the curve and grade clamp it to 0, and the run showed
none of the 55 is in any species' scored population. Four code-check rounds: every finding was a definition or a
number written twice by hand (the script against the tuning, the prose against the log), and the loop ended on
round 4's enumeration of both (41 prose claims, 13 restated definitions).

## Measurement

On the tuning's stream branch (16,279 visits with a measured gradient, build `1bd35829 009698d7 99f499bb`):
measured against segment gradient rank r 0.69, log r 0.64, ratio p10–p90 0.33–2.22, median absolute difference 2.2
points; against the Atlas line 0.65, 0.62, 0.26–1.94, 2.5 points. Two readings at one site: rank r 0.90, ratio
0.60–1.58, 1.0 point. Visits on the other side of a published limit on the ground: CH rearing 6.4 % (0.11), BT
rearing 0.8 % (0.30), WCT rearing 0.7 % (0.25), BT spawning 8.5 % before the spawner and groups filters (0.13), CO
25.8 % and GR 11.7 % (0.0549); within one ladder step of a limit 33 to 42 %. Sites with fish agree better in absolute
terms mostly because they are gentler. This turned "a gradient limit is a limit on the ground" into a measured
statement: true in bulk, uncertain to a few points near the limit. Wrong turns kept in `findings.md` and the review
files: the population guard refused the first run (missing groups filter), ST's band was first built on the default
ladder, WCT rearing (underpowered) was first left out of the published set.

## Evidence

`scripts/logs/habitat/20261030_site_gradient_check*` · `research/fdis_export.md`, "Measured vs modelled gradient
(#121, 2026-10-30)".

## Owed

- The sentence in `vignettes/habitat_thresholds.Rmd`'s limits, carried through `data-raw/vignette_method.R`, at the
      next `method.rds` rebuild (#119 or the next promotion); written into #119's body as a task, with the note that
      `vignette_method.R` must compute it as `data-raw/site_gradient_check.R` does (plan review).
- #120's body gains the rerun: `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=<minimal network's build> Rscript
      data-raw/site_gradient_check.R`.

Closed by: PR (this branch, `121-measured-site-gradient-against-link-s-se`)
