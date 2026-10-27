# Code check, round 2 (#94: unpin runners, add job timeouts)

## Checklist read

- `code-check-python.md` (7,237 bytes): in full.
- `soul/conventions/ci-monitoring.md`: in full.
- `code-check.md`: the prose of all fourteen H3s under `## Mechanisms`, with the table rows skipped.
- `code-check-shell.md`: the `gh` CLI section, including the floating-major-tag pin note (setup-uv, checkout).
- `code-check-r.md`: "pak Behavior" (PPM binaries lag new CRAN releases) and "Reproducibility" / pin policy.
- `code-check-spatial.md`: no section bears on two workflow files.

## Probes (2026-10-26)

- **What `ubuntu-latest` is today.** actions/runner-images#14748 says the label moves to 26.04 "over a period of
  several weeks beginning October 19, 2026", and the migration is planned to finish by November 19, 2026. This
  repo's own logs show the mix: run 40256692841 (01:57Z) has `Image: ubuntu-26.04`, and run 40353103033 (17:53Z) has
  `Image: ubuntu-24.04`. That second run was pinned, so it does not show what an unpinned run gets, but the
  announcement says an unpinned run can land on either image until about Nov 19.
- **The 26.04 image** (runner-images `Ubuntu2604-Readme.md`, image 20261023.163.3) still has the tools the
  non-install steps use: `rsync` 3.4.1 (JamesIves deploy copies the build with it), classic `sudo` 1.9.17 (not
  sudo-rs), GNU `coreutils` 9.5, Bash 5.3.9 and Git 2.55.0. Comparing the 24.04 image's apt-package table with
  26.04's, the only packages 26.04 drops are dnsutils, haveged, mediainfo, mercurial, p7zip-full, p7zip-rar and
  sphinxsearch. Neither workflow uses any of them.
- **JamesIves/github-pages-deploy-action@v4.5.0** declares `using: 'node20'`, and so does actions/checkout@v4. Which
  Node runs them depends on the runner agent's Node policy, not on the OS image, so the answer is the same on 24.04
  and 26.04. This change makes it no better and no worse, so it is not a finding here.
- The `docs/*.html docs/*.md` glob step and the citation job's `git config` / `git commit` / `git push` use only
  POSIX shell and git, so the image has no bearing on them.
- **New comment.** It says a job with no timeout is held for 6 h. GitHub's default job timeout is 360 min, so
  that is true. The stall causes it names (an apt mirror, a package compiling from source) match #94's body, which
  records a run stuck mid-download from the apt mirror and a duckdb source compile that ran 32 min. Nothing in the
  comment is untrue.

## Findings

- **[severity: fragile]** `.github/workflows/pkgdown.yaml:17` — #94's own rule is "unpin once a run on it is
  green". A green run on `ubuntu-latest` from this PR does not show that a 26.04 run is green, because the label
  points at either image until the migration ends (runner-images#14748: Oct 19 to about Nov 19, 2026). A PR run
  could land on 24.04, pass, and be read as proof of 26.04. Before calling the unpin verified, read the image from
  the run log: `gh run view <id> --log | grep -m1 'Image: '` should print `ubuntu-26.04`. If it prints 24.04,
  re-run the job until a run lands on 26.04, or test it once with `runs-on: ubuntu-26.04`. This is about how the
  change gets verified, not a defect in the YAML.
- **[severity: fragile]** `.github/workflows/update-citation-cff.yaml:15` — this PR never runs this job: it fires
  only on a push to `main` that touches `DESCRIPTION`, or on `workflow_dispatch` from `main`. So it first runs
  unpinned, and on 26.04 or 24.04 as the migration falls, at the next release. Its only install is `cffr`, so the
  risk is small. But a release-time failure here looks like a broken release (see ci-monitoring.md, "A setup
  failure and a build failure look identical"). One `gh workflow run update-citation-cff.yaml --ref main` after
  the merge would exercise it, after confirming in the log which image it got.

Nothing else found. The YAML is valid, `timeout-minutes` sits at job level on both jobs, and no step depends on
anything that 26.04 removes or changes.
