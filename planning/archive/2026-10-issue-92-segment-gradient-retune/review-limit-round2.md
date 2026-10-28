# Review: Limits bullet on link's 2026-10-17 build, round 2

## Checklist read

- soul `conventions/code-check.md`, "## Mechanisms" prose (as in round 1): a guard that fails toward pass, a proxy is
  not the property, a guard's scope, zero-length/empty/unset, one fact derived twice.
- soul `conventions/writing.md`, "State each claim by the code's definition".
- Sources: link#326 body; link NEWS 0.69.0 and 0.69.2 (origin/main, fetched 2026-10-28);
  `research/bcfp_segmentation_parity.md` ("Measured since #326"); `research/observation_breaks.md` ("How many cuts
  go"); link `R/lnk_pipeline_prepare.R` (`.lnk_pipeline_prep_minimal()` roxygen) and
  `inst/extdata/configs/default/config.yaml` (`break_order`).

## What holds

- **"more than halves the segments in the four groups link measured"**: `default` drops 2.1 to 2.7-fold on PCEA, FINA,
  PARS, LKEL (to 37-48 % of before). True, and now scoped to #326's four groups.
- **"a further"**: #396's BEFORE builds were `default` "built at main (every observation breaks)", and main already held
  #326 (PR #391 f043b98 is an ancestor of PR #397 d167e96). The BEFORE counts confirm it: PARS 46,341 and LKEL 3,378 are
  exactly #326's post-change `default` counts. So #396's percentages are after #326, and "further" is right.
- **"1 to 4 %"**: 0.7 to 3.6 %, rounded to whole percent. Acceptable.
- **"at fish records only at each species' highest record on a stream"**: matches `top_per_species` (farthest-upstream
  record per species per `blue_line_key`, `default` only). "Stream" for a blue line key is fair.
- **"The thresholds have not yet been tuned on those segments"**: true; the provincial re-model under both changes is
  still owed in link (NEWS 0.69.0, 0.69.2).
- **The guard**: unchanged from round 1; no finding.

## Findings

1. **Medium — vignettes/habitat_thresholds.Rmd:364-365, "at barriers only where a species present first can no longer
   get past".** Still overstates #326's scope, in the same way round 1's finding 1 described (and round 1's proposed
   wording carried it). `default`'s `break_order` is observations, gradient_minimal, falls, barriers_definite,
   habitat_endpoints, crossings; #326 changed only what `gradient_minimal` holds (each present species' post-lift set
   reduced to the downstream-most position per flow path). NEWS 0.69.0: "The independent falls, user-definite and
   subsurface sources still break where they sit", and crossings still break as their own source. So link still cuts
   at every fall, every user-definite barrier and every crossing, all of which a reader calls barriers; "at barriers
   only where..." is false for them. What actually moved in `default` is the steep-gradient breaks. Suggested exact
   words: "at steep sections only where a species present first can no longer get past
   ([link#326](...)), and at fish records only at each species' highest record on a stream ([link#396](...))." (If
   "steep sections" is not the article's term, use whatever it calls gradient barriers elsewhere.)

2. **Low — vignettes/habitat_thresholds.Rmd:367-368, "in the four groups link measured, and the second removes a
   further 1 to 4 %".** The "further" reads as measured on the same four groups, but #396 was measured on LKEL, BULK,
   UPCE, PARS and ELKR: only PARS (0.7 %) and LKEL (2.0 %) are in #326's four, and the 2.6 to 3.6 % end of the range
   comes from UPCE and ELKR, outside them. Suggested exact words: "The first more than halves the segments in the four
   groups link measured it on, and the second removes a further 1 to 4 % in the five it was measured on."
