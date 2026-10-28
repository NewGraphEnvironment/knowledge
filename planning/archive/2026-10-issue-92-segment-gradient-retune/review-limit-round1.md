# Review: Limits bullet on link's 2026-10-17 build, round 1

## Checklist read

- soul `conventions/code-check.md`, "## Mechanisms" prose (tables skipped): a guard that fails toward pass; a fixture
  that cannot reach the failure mode; a proxy is not the property; verification that reads its own output; a guard's
  scope, escape hatches and remedies (including "compression runs both ways"); restore the bug and prove the guard
  fires; zero-length, empty and unset; written data outlives the fix; one fact derived twice.
- soul `conventions/code-check-r.md`: no heading names stopifnot, vignettes or logical(0) as such; the logical(0)
  hazard is in code-check.md's "Zero-length, empty, and unset", applied here.
- soul `conventions/writing.md`, "State each claim by the code's definition".

## What was verified, and holds

- **Build and version.** `scripts/logs/habitat/20261027_evidence_build_ledger.csv` (tracked, md5
  90a98a2ca24955c8e993d36ec42b6355): `run_link_version` 0.66.0; `run_link_sha` a17e917…;ee21eb1…; `build_record`
  schema `fresh_default_20261017`, run 20261017_004619. "link's build of 2026-10-17" matches the schema name and link's
  NEWS 0.68.1 ("the 2026-10-17 build is kept as `fresh_default_20261017`").
- **Predates both.** Both ledger shas (ee21eb1 is an ancestor of a17e917) are ancestors of #326's merge (PR #391,
  f043b98) and #396's (PR #397, d167e96). #223 (every-position breaking, PR #228, d2de10f) is in the build, so #326's
  "before" state is the build's. No segmentation change found in link NEWS 0.66.0 to 0.68.x.
- **#396 wording.** "at each species' highest record on a stream rather than at every record" matches NEWS 0.69.2
  ("farthest-upstream record per `blue_line_key`", `default` only, `bcfishpass` keeps `all`). The article tunes
  against `default`, so default-only scope is not a misstatement.
- **The guard.** Passes on the source and the installed bundle (identical md5). Mutation test: a bundle recording the
  20261022 ledger, `meta$ledger` NULL, `meta` NULL, `meta$ledger` NA all return FALSE, so it fires; `identical()`
  returns a scalar, so no logical(0)/NA vacuity. `data-raw/vignette_method.R:52` takes the newest ledger, so a new
  evidence build changes `meta$ledger` and the guard fires. It reads only the bundle (`inst/`), not `data/` or the
  ledger file, so CI and pkgdown are unaffected.

## Findings

1. **Medium — vignettes/habitat_thresholds.Rmd:364-365, "link has since changed where it cuts streams: only where a
   species present can or cannot get past a barrier".** The "only" scopes over all of link's stream cuts, but #326
   changes only the barrier break set (each present species' post-lift barriers reduced to the downstream-most per flow
   path). NEWS 0.69.0: "The independent falls, user-definite and subsurface sources still break where they sit", and
   `research/bcfp_segmentation_parity.md` lists link-only breaks at "observations, crossings and habitat endpoints".
   The bullet's own second clause (cuts at records) already contradicts the "only". Separately, "where a species can
   or cannot get past a barrier" read literally describes every barrier of a present species (at each one it either
   can or cannot pass); what #326 adds over #45's present-species rule is the reduction to the point where access
   changes, and the phrase does not convey it. Per writing.md "State each claim by the code's definition", name the set
   the code defines. A fix: "at barriers only where a species present first can no longer get past (link#326), and at
   fish records only at each species' highest record on a stream (link#396)".

2. **Low-Medium — vignettes/habitat_thresholds.Rmd:367-368, "That more than halves the segments in the groups link
   measured".** "That" follows a sentence naming both changes, so it reads as both halving the segments. #396 alone
   cuts 0.7 to 3.6 % (NEWS 0.69.2). The two were measured on different groups (#326's `default` drop, 2.1 to 2.7-fold, on
   PCEA, FINA, PARS, LKEL; #396 on LKEL, BULK, UPCE, PARS, ELKR) and no one measured them together, so "the groups link
   measured" includes BULK, UPCE and ELKR, where no `default` halving was measured. The combined claim does hold on the
   four #326 groups (both changes only remove breaks), but the sentence names a wider set. A fix: "The first more than
   halves the segments in the four groups link measured, and the second removes a further 1 to 4 %."

No finding on the guard.
