# Code check, round 2: `.Rprofile` sources `~/.Rprofile` (#94)

## Checklist read

- `code-check-python.md` (7,237 bytes): read in full (nothing applies, no Python in the diff).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (table rows skipped), plus the knowledge#4 row on
  a nearer config file shadowing the user's (line 1054).
- `code-check-r.md`, `code-check-shell.md`, `code-check-spatial.md`: over 40,000 bytes; grepped for `Rprofile`,
  `normalizePath` and `Renviron` and read the headings' index. No section names a tool or shape this diff uses
  beyond the shadowing row above.
- The diff, the full `.Rprofile` and setup-r's `installer.ts` excerpt from `diff_rprofile2.md`; the repo's two
  workflows (both `ubuntu-latest`, so the Windows `Documents/.Rprofile` path is not exercised).

## Findings

- **[severity: bug]** `.Rprofile:5` — the guard compares `~/.Rprofile` with `./.Rprofile` **in the working
  directory**, but when `~/.Rprofile` is this file, R is usually running it *because* the working directory has
  no `.Rprofile` (R looks in the cwd first, then HOME). Then `normalizePath(".Rprofile")` fails, warns, returns
  the bare string `".Rprofile"`, the comparison is unequal, and `source("~/.Rprofile")` re-runs this file, which
  repeats the same test: infinite recursion. So the two cases the comment on line 4 says it stops are stopped
  only when R is started from the checkout itself. Reproduced in a scratch copy (file copied verbatim; nothing
  in the repo touched):

  | HOME | cwd | result |
  |---|---|---|
  | dir whose `.Rprofile` symlinks to the checkout's | checkout | ok |
  | same | any other dir | `Error: evaluation nested too deeply: infinite recursion`, 50+ warnings, `Execution halted` |
  | the checkout | any other dir | same infinite recursion, `Execution halted` |
  | the checkout | checkout | ok |

  A symlinked `~/.Rprofile` is used from every directory on the machine, so the failing row is the normal one
  for that setup: every R session started outside the repo halts, which is a regression against the
  pre-#94 file (which never sourced anything). Nobody is known to be in that setup today (`~/.Rprofile` here is
  a regular file; on CI it is setup-r's own file under `/home/runner`, not the checkout), so this breaks no
  current run, but the guard does not do what its comment says. A hard-linked `~/.Rprofile` recurses from any
  cwd for the same reason (`normalizePath()` does not join hard links).

  A re-entry flag held in an **option** has none of these dependencies (the cwd, links, case, `~` expansion)
  and emits no `normalizePath()` warning. An option is not inherited by child processes, so callr/pak children
  still read `~/.Rprofile`; an environment variable would be inherited and would make those children skip it,
  which is the #94 defect again. Probed in the same scratch copy across all four rows above plus a HOME with its
  own ordinary profile: every case finished, and the ordinary profile ran once.

  ```r
  if (is.null(getOption("knowledge.home_rprofile")) && file.exists("~/.Rprofile")) {
    options(knowledge.home_rprofile = TRUE)
    source("~/.Rprofile")
  }
  ```

  (When `~/.Rprofile` is this file, the body then runs twice, which is harmless: it only sets options.)

## Checked and not a finding

- **Missing path, warning at startup.** `file.exists("~/.Rprofile")` short-circuits, so a missing home profile
  never reaches `normalizePath()`. A missing `./.Rprofile` happens only when R was handed this file some other
  way; with `R_PROFILE_USER=<checkout>/.Rprofile` and a cwd elsewhere, R prints
  `In normalizePath(".Rprofile") : path[1]=".Rprofile": No such file or directory` and carries on correctly
  (home profile sourced, option set). Noise only; the fix above removes it.
- **Case-insensitive filesystem.** With HOME set to the checkout spelled in a different case on macOS (APFS),
  both `normalizePath()` calls returned the same on-disk spelling, so the comparison held (measured).
- **Windows.** `~` expands to `R_USER` (Documents), the directory setup-r writes to, and both sides normalise
  with the same `winslash`; no Windows runner exists in this repo's workflows.
- **CLAUDE.md hunk.** Accurate as written.
