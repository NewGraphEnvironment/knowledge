# Code-check round 2 (branch 171, 89ee4d3a...e2bea996)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all fourteen H3s under `## Mechanisms`, with table rows and evidence blocks skipped: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. I did not read the 21 "Rules that stand alone", Security and Spreadsheets/PDF sections in full (index lines only).
- code-check-r.md, by heading. Read in full: Tests that silently do not run; A `skip_if_not()` skips only its own `test_that()` block; Under `R CMD check`, tests run from a temp dir against the INSTALLED package; A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared; A `data-raw/` script must load the source tree, not the installed package; CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests; `$` on a list partial-matches, so a longer sibling key answers for a missing one; testthat counts an uncaught error under `error`, not `failed`. Not read in full: the other ~120 headings (index lines only).
- code-check-shell.md: no section read in full. The only shell in the diff is one `echo | sudo tee` line in the workflow, and none of the headings covers it. I read the index lines only (~110).
- code-check-spatial.md: no section read in full. The diff's only spatial change is a mapgl layers-control label, and I checked that against mapgl 0.4.6's source and NEWS instead. I read the index lines only (~105).

## What I checked and found sound

- The round-1 fix: Kirsch et al. 2014, printed p. 42 (PDF p. 50; the page numbers are footers), Recommendation 2: "Based on prior AFFI findings, additional Chinook salmon rearing areas may be found in the lower reaches of small (less than 50 km2 upstream drainage) non-natal tributaries to large rivers supporting Chinook salmon ...". The rewritten opening describes a recommendation drawn from earlier Alaska inventories, at that page, and "do not always rear where they hatched" rests on "non-natal". The fix holds.
- `rbbt::bbt_detect_citations()` finds `-@kirsch_etal2014Fishinventory`, `@wet` and `@norris_irvine2026NewGraphEnvironmentfwapg` in the three renamed articles. `kirsch_etal2014Fishinventory` exists in group library 9 (it also exists in library 1, and `library_id = 9` resolves it). The fork's Zotero title, `NewGraphEnvironment/fwapg`, matches the fork pattern and not upstream's `^(smnorris/)?fwapg`. Upstream's `version = NULL` survives `list()` and takes the `is.null()` branch. Regeneration should therefore write the intended entries.
- The comment that `fwapg_sha` 9a62b0c is a fork commit upstream does not hold is true. GitHub serves the commit under `smnorris/fwapg` (shared fork objects), but `compare/main...9a62b0c` reads ahead 213, behind 0.
- In a detached worktree at HEAD, the full suite (`test_dir`, NOT_CRAN=true) gave 0 failed, 0 error and 4 skips (the ignored-data ones). `pkgdown::check_pkgdown()` reported no problems.
- The new register test fires when a printed column changes (a label/value edit went red) and stays green when only `where` changes, as designed.
- No tracked file outside `NEWS.md` history and the `_pkgdown.yml` redirects still names the old article files. Every cross-article anchor (`#thresholds`, `#se`, `#snap`, `#steps`, `#lost`, `#limits`, `#cuts`) exists in its target.
- mapgl 0.4.6 turns the named `layers =` into `layers_config` labels. Custom labels arrived in mapgl 0.4.1, and CI installs the current release.
- The claim that bcfishpass's parameter sets are "most of them an organization's own" holds at 3bd2824: five of six directories (ccira, cwf, fptwg, newgraph, psf_fraser), plus `example_testing`.

## Findings

- **[severity: fragile]** .github/workflows/pkgdown.yaml:35-40: the "Make apt retry a stalled mirror" step changes nothing on the runner image this job uses, and its comment describes settings that are not in force.
  - The CI's image is `ubuntu24/20261101.360`, per the Set up job log of run 43178952073. At that tag, `images/ubuntu/scripts/build/configure-apt.sh` writes `/etc/apt/apt.conf.d/zz-retries` (x64: `Acquire::Retries "1"`, `Acquire::http::Timeout "15"`, `Acquire::https::Timeout "15"`). It does so because "apt reads /etc/apt/apt.conf.d in C-locale filename order and the last setting for a key wins" (runner-images #14726, 2026-09-15).
  - `zz-retries` sorts after `80-retries`, so the image's 1 retry and 15 s timeout override this step's 3 and 30. The comment's claim that "apt itself gives up on a dead connection and retries first" is therefore not this step's doing.
  - If the step ever did take effect (named to sort last), it would make failover slower than the image's own setting. runner-images sets x64 to 1 retry on purpose, because apt "spends every retry on the same URI before trying the next mirror" in `apt-mirrors.txt`.
  - The per-step `timeout-minutes` and second tries are what bound a stall. Either drop this step and its sentence, or confirm what apt actually uses by adding `apt-config dump Acquire::Retries Acquire::http::Timeout` to the job before relying on it.
  - **Rule:** code-check.md "A proxy is not the property". The step names a mechanism (a file written) where the requirement is the effective apt setting, which the image's later file decides.

- **[severity: bug]** vignettes/tuning-method.Rmd:113-114: the new opening states as known life history that "young chinook, for example, rear in small streams close to a large river". It cites nothing, and it is the same overreach round 1 fixed in the chinook article.
  - The repo's own summary of the literature says otherwise. research/chinook_rearing_tuned.md, "What to expect of juvenile chinook": "Chinook fry and parr rear in larger streams than coho do, and in small streams mostly where those are tributaries of a river that holds chinook."
  - The small streams near a river are the exception the intrinsic-potential sources allow beside a size floor. They are not where young chinook rear in general.
  - The sentence stands as the example of "roughly which" streams a species uses, so a reader takes the exception for the rule. The chinook article now words the same point as Kirsch et al.'s recommendation.
  - Reword it, for example: "rear in larger streams, and in small streams mostly where they join a river that holds chinook". Or cite it as the chinook article now does.
  - The README (line ~228) and tuning-stream-splits.Rmd:154 use the phrase as the shape of a definition ("such as young chinook rearing in small streams close to a large river"). That reads as the definition's allowance, not a life-history claim, but it is worth the same look.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies". This is the paragraph on compression running both ways, where a demotion drops the condition ("larger streams ... mostly where those are tributaries") that made the sentence true.

- **[severity: fragile]** vignettes/tuning-stream-splits.Rmd:581-583: "their flows are wet's [@wet], carried onto Atlas streams by New Graph's fork of `fwapg`" gives every flow to the fork's crosswalk.
  - The methodology article (step 4) and the chinook article's Flow row both say that only PCIC's routed flow is carried by the fork. Where that flow does not reach a stream, or carries under a fifth of the balance on a stream's own line, the flow is wet's own water balance, which the fork does not carry.
  - The sentence is new on this branch and is the stream-splits article's reason to cite the fork.
  - Narrow it, for example: "their flows are wet's [@wet], mostly PCIC's modelled flow carried onto Atlas streams by New Graph's fork of `fwapg` [...]".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression: a qualifier dropped widens the claim).
