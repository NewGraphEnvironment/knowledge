## Outcome

Prepared the repository to go public in place (#56). The R package moved from `pkg/` to the root
(installs as `NewGraphEnvironment/knowledge`), with a root `.Rbuildignore`, a test keeping `.R` and `.rda`
files off the top of `data/`, and a pkgdown site whose workflow keeps CLAUDE.md out. Every script connects
through the standard `PG*` variables, with no host, port or login in code and no fallback between
databases; the Zotero key comes only from `ZOTERO_API_KEY`; host names, private-repository links and
project names left the live files, the issue and PR text, and CLAUDE.md, whose conventions were rebuilt in
public-safe form. The FDIS extract stays as received under `s3://fresh-bc/fdis/` with a provenance note
(received from the Province, exports of 2020-11-16 and 2022-03-22, public with its agreement), and the
visit tables built from it are published by `scripts/0299` as Parquet with a schema-guarded manifest under
`knowledge/fdis/v1/`. What was learned: R's `~/.Renviron` replaces shell `PG*` values, so `PGSERVICE` is
the per-run selector; and every review round past the first found a guard deciding "clean" or "done" from
a list written from what was known rather than from the population (the sweep's surfaces and patterns, a
manifest's presence as proof of a complete download, a revision list recalled rather than read). The fix
each time was to measure the population; `public_sweep.py` here is the result, and the next issue reruns it.

Left for the owner, after the merge: delete the 23 items' earlier revisions in the web UI (list from
`public_sweep.py history` on the day), decide on #4's retitle entry and on the issue branch behind open
PR #12, then flip visibility, enable Pages, apply the bucket policy, and update link#346. Upstream:
An internal issue (peer list), an internal issue (private references in the
public-safe conventions).

## Measurement

- Public sweep of live files: 128 hits before (db 74, host 10, internal_ref 13, key_path 4,
  password_manager 1, private_repo 23, project_repo 3); 0 after, once the generated conventions below
  CLAUDE.md's marker are reported separately (41 hits there, owned upstream by an internal issue).
- GitHub text: 13 issue bodies, 4 PR bodies and 5 comments edited, #4 and #17 included; one retitle
  entry (#4) remains and cannot be deleted. Earlier revisions carrying hits: 23 items, measured from
  GraphQL `userContentEdits` (a recalled list had missed #19).
- FDIS: `fdis/MANIFEST.md5` names 26 keys; a fresh credentialed sync and a key-by-key fetch both verify
  26 of 26. Five tables published (53,018 / 17,606 / 21,862 / 21,862 / 372,687 rows; 81 MB of CSV to
  9 MB of Parquet). The value read-back caught `ch_rule_visits.hydro_zone` (`"08"` read as 8 in 6,651
  rows) before the versioned publish; zero-padded columns now stay text.
- Package: `devtools::test()` 105 passed; `devtools::check()` 0 errors, 0 warnings, 0 notes. Scripts run
  from the root through `PG*`: 0240 and 0250 reproduced every tracked output byte for byte, 0280 passed;
  0100 and 0110 stop at the remote server's connection timeout (unreachable from this machine).
- Review: one plan review and four `/code-check` rounds (17 findings, all reproduced; 16 fixed and one, the open-PR
  branch, left to the owner; rounds 2, 3 and 4 each found a defect inside the previous round's fix), ended by enumerating
  what the last fixes claimed and measuring each.

## Evidence

`review-plan.md` and `review-round*.md` in this directory; `public_sweep.py` (`all`, `history`).

Closed by: PR (this branch, `56-clean-up-and-make-the-repo-public-packag`)
