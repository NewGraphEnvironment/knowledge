# Review: `.Rprofile` sources `~/.Rprofile` (commit bdb5a7f), round 1

## Checklist read

- `code-check-python.md` (7,237 bytes): read in full. Nothing in it applies; the diff has no Python.
- `code-check-r.md`: read the sections the diff touches: "Under `R CMD check`, tests run from a temp dir against the
  INSTALLED package" and "`source()`ing a config into the render environment leaks it into the next render". I also
  grepped every `.Rprofile`/`.Renviron` mention across the four large files. The only one is code-check.md's
  knowledge#4 row, where a project config file shadows the user's.
- `code-check.md`: read the prose of all fourteen H3s under `## Mechanisms`, table rows skipped. The ones I applied:
  "The probe is broken before the world is" (which config file actually loaded; the positive control is a second
  working directory), "A guard's scope…" (execute each claim the comment and CLAUDE.md make), and "Verification that
  reads its own output".
- `code-check-shell.md` and `code-check-spatial.md`: no heading touches R startup or profiles.

## Probes (scratchpad `rv1/`; HOME pointed at a fake home holding a copy of setup-r's profile; R 4.5.2, pak 0.11.1, callr 3.7.6)

| case | result |
|---|---|
| old project profile, fake `~/.Rprofile` from setup-r | `repos` = `CRAN "@CRAN@"`; `pak::repo_get()` row 1 is `CRAN https://cran.rstudio.com`, with no RSPM row |
| new project profile, same home | `repos` = RSPM (P3M `__linux__/noble/latest`), then CRAN; pak lists RSPM first; `cred.store_source` still `s3://fresh-bc/rag/` (the project value is set after the source call, so it wins) |
| `callr::r()` (default `user_profile = "project"`) from the new project | the child now runs `~/.Rprofile` too and gets the RSPM repos |
| `~/.Rprofile` that calls `stop()` | the new profile halts Rscript (rc 1). R does the same from any directory without a project profile (rc 1). The repo root used to be the only place that hid a broken `~/.Rprofile`, so this matches R's normal behaviour |
| HOME equal to the project root | `Error: evaluation nested too deeply: infinite recursion`, then `Execution halted` |

- **The claim holds, and the probe explains the URL.** Without `~/.Rprofile`, pak maps `@CRAN@` to
  `https://cran.rstudio.com`. That is pkgcache's default mirror, so it is why the #94 logs show `cran.rstudio.com`
  even though setup-r's profile was never read. In setup-r's `installer.ts` (v2), the `~/.Rprofile` it writes is the
  only place that adds `RSPM`.
- P3M's `/__api__/status` lists `resolute` (Ubuntu 26.04) among its Ubuntu distros, so binaries are available for
  the new image as well.
- The pkgdown run on bdb5a7f (40413562090) was still in `setup-r-dependencies` at 22:39Z. That run, not this
  review, is the evidence that CI now resolves to P3M binaries.
- Things I checked that are fine:
  - `source()` evaluates in the global environment, as R's own profile loading does.
  - R does not read `~/.Rprofile` again on its own when a project profile exists, so nothing is sourced twice.
  - `--vanilla` and `--no-init-file` skip both files.
  - When `R_PROFILE_USER` is set, R does not read the project profile, so the change has no effect there.
  - `.Rprofile` is in `.Rbuildignore`, so `R CMD check` never sees it.
  - On Windows, `~` resolves through `R_USER`, the same lookup R uses for its own user profile and the folder
    setup-r writes to. Both workflows run on ubuntu anyway.
  - The user's `~/.Rprofile` sets `Authors@R`, `License`, `rbbt.default.library_id` and `mc.from`. No tracked code
    reads any of them: `data-raw/vignette_bib.R` passes `library_id = 9` explicitly. So no local output changes.
- I checked the two prose claims. CLAUDE.md's sentence matches the findings.md measurement of 2026-10-26 and the
  probe. The comment's "this one wins over ~/.Rprofile" is true whenever `R_PROFILE_USER` is unset.

## Findings

- **[fragile, unlikely]** `.Rprofile:4`: if `~/.Rprofile` resolves to this same file, the file sources itself
  forever, and every R process started from the repo root halts with "evaluation nested too deeply: infinite
  recursion". That happens when HOME is the checkout (a container whose WORKDIR and HOME are the repo) or when
  `~/.Rprofile` is a symlink to it. I reproduced it with HOME set to the project directory. Neither GitHub-hosted
  ubuntu runners (HOME `/home/runner`, workspace `/home/runner/work/...`) nor this machine meet the condition, so it
  does not affect the CI fix. A one-line guard closes it, if wanted:
  `if (file.exists("~/.Rprofile") && normalizePath("~/.Rprofile") != normalizePath(".Rprofile")) source("~/.Rprofile")`.

No other issues. Apart from that edge case, the diff is correct.
