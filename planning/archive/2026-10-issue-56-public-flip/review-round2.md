# Code review, round 2: branch 56-clean-up-and-make-the-repo-public-packag (HEAD f2e17aa)

I reviewed the branch diff against its merge-base, and read the four round-1 fixes and the files named in the brief in
full. Probes ran read-only or in the scratchpad. Nothing in the repo was edited except this file. Nothing was written to
S3, a database or GitHub.

## Findings

- **[security, low] GitHub issue #4's timeline: a rename event still shows a host name.** The sweep does not read this,
  and the planned clean-up step cannot remove it. #4 was retitled on this branch to drop the host. GitHub keeps a
  `renamed` event in the timeline, and that event shows the old title:
  `"...an unharvested group (UPCE) from the M1"`. I ran the sweep's own patterns over the rename events of all 57
  issues and PRs. This is the only hit (`host`, `M1`).
  - `public_sweep.py github()` reads bodies, titles, comments and reviews, but not the timeline. So it reports this
    issue as clean.
  - "After merge" step 1 in task_plan.md deletes earlier body revisions in the web UI. That does not touch rename
    events, which cannot be deleted.
  - Once the repo is public, anyone can read the event on the issue page.
  - Options: accept it, since it is one host label; or have an admin delete issue #4 and re-file it before the flip.
    Either way, add `issues/{n}/timeline` `renamed` events to `github()` so a future retitle is caught.
  - Not inside a round-1 fix.

- **[security, fragile] CLAUDE.md below the marker becomes public, and the sweep skips it.**
  `public_sweep.py:40-41, 62-63` cut CLAUDE.md at `# Agent Operating Rules` before scanning. The rest of the file is
  still in the repo and becomes public with it. Only the pkgdown site drops CLAUDE.md. Running the sweep's own patterns
  over the part after the marker gives 39 hits:
  - 16 `private_repo`: `soul#366`, `soul#352`, `soul#52`, `rfp#268`, `rtj#322`, `fish_passage_template_reporting#236`,
    and two `https://github.com/NewGraphEnvironment/soul/...` links, which 404 for the public;
  - 15 `local_path`: `<soul checkout>/conventions/...` (eight times), an absolute home path, and
    an author handle with a date;
  - 6 `host`: `m1 0.0391 vs cypher 0.0872` at CLAUDE.md:2611, `tailnet`, and `Tailscale` (three);
  - 1 `internal_ref` and 1 `template_name`.

  So when the sweep reports "no hits", it has not read the part of the public file that carries most of these
  patterns. The convention is to fix generated text at its source, not in place (feature-workflow.md, "Public-repo
  text describes the package"). The fix therefore belongs in soul's public-safe conventions, or the exemption should
  be stated as an accepted residual in the PR. As it stands, the sweep's exit 0 claims more than it checked. Not inside
  a round-1 fix.

- **[fragile] scripts/0230-fdis-load.R:63, 75-77. INSIDE ROUND-1 FIX.** The `NO_SIGN=TRUE` path fetches
  `MANIFEST.md5` first, but line 63 treats the manifest's presence as "cache complete". If a later `get(key)` fails
  (network, 403, Ctrl-C), the manifest is already on disk.
  - Every re-run then skips the fetch and stops at line 88: `md5 mismatch vs MANIFEST.md5: <missing files>`.
  - Nothing tells the operator to delete `data/fdis/MANIFEST.md5` to resume.
  - It fails loudly and loses no data, but the cache cannot recover by re-running.
  - Fix: fetch the manifest to a temp path, fetch the keys it names, then move the manifest into `cache` last.
  - The credentialed `aws s3 sync` branch had the same property before this branch, because sync order is arbitrary.

## Checked and not a problem

- **Round-1 fix 1 (wf_peace_report_harvest.js).** `const A` is now declared once, at line 35. `HARVEST` is defined at
  line 36, before its only uses at lines 65-77 inside `acquirePrompt`. Nothing between lines 11 and 33 reads `A` or
  `HARVEST`. All five `wf_*.js` pass `node --check` when wrapped in an async function with the runtime's globals.
- **Round-1 fix 2 (0230 NO_SIGN).** I compared `aws s3 ls --recursive s3://fresh-bc/fdis/` with the 26 manifest paths
  after `substring(…, 34)` and the `./` strip. They are the same set, plus `MANIFEST.md5` and `README.md`, both fetched
  explicitly, so the key-by-key fetch gets everything the sync got. Keys with spaces and parentheses go through
  `shQuote`. Anonymous GetObject currently returns 403 on `fdis/` and `knowledge/fdis/v1/`. That is expected until
  rtj#397's policy is applied after merge, so the NO_SIGN paths cannot be exercised end to end yet.
- **Round-1 fix 3 (0299 schema guard).**
  - `prior$files[[NA_integer_]]` is `NULL`, so a new table is caught by the set difference and skipped in the loop, as
    intended.
  - The live published `manifest.json` (uploaded at 15:10, after f2e17aa) carries `schema`. After a `read_json` round
    trip, `identical(lapply(p$schema, as.character), lapply(f$schema, as.character))` is TRUE against the same table's
    schema built the way the script builds it, so an unchanged republish passes.
  - A changed type, a renamed column or a reordered column makes it FALSE.
  - The guard's probe uses exit 1 with empty output as "not published" (correct for `aws s3 ls` on a missing key). A
    failure that exits non-zero with no output at all would also skip the guard. That is narrow: credential, network
    and missing-binary failures all print.
- **Round-1 fix 4 (public_sweep binary scan).** The only tracked non-UTF-8 files outside the exemptions are 27 `.gpkg`
  and 4 `.png`, so the 8-character run filter never applies to a text file. Round 1 measured a full latin-1 scan of
  them as clean, so the threshold hides nothing today.
- **First-match masking in `github()` and `commits()`.** Each exemption (`sred` in PR bodies, `m1` in issue 20,
  `comms/` in 34f773c) suppresses only the first match of its pattern. I ran `finditer` over issue 20 and 34f773c: no
  second hit sits behind an exempted one. Branch names, tags, releases and commit comments are clean (0 releases,
  0 tags, 0 commit comments).
- **Scripts.**
  - The scripts that used to hardcode the local fwapg (0230-0298) now read `PG*`. Their only database writes are
    `TEMPORARY` tables and `pg_temp` functions, except 0298's scratch schema, which round 1 covered.
  - 0220 initialises `db_source <- NA_character_` (line 505) before the clip block.
  - 0153 is env-only, and an empty key exits.
  - 0260 refuses without `TEMPLATE_DIR`.
- **Package and site.**
  - `.Rbuildignore` covers every top-level non-package directory present (`data`, `scripts`, `planning`, `research`,
    `docs`, `.github`, `.claude`, CLAUDE.md, `_pkgdown.yml`).
  - The test-data-dir pattern matches exactly what `pkgload:::load_data` (1.5.2) sources or loads (`\.[rR]$`,
    `\.[rR][dD]a(ta)?$`).
  - The pkgdown workflow removes CLAUDE.md before the build and then asserts the set of top-level pages.
  - The tree sweep exits clean on HEAD.

planning/active/review-round2.md
