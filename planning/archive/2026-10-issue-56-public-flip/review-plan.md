# Plan review (Plan agent, 2026-10-16)

Spawned at 21:33 UTC against the baseline plan; arrived after Phases 1–3 had landed and Phase 4 was in flight.
Full findings were returned as reply text; the dispositions below record what was done with each.

| id | finding | disposition |
|---|---|---|
| B1 | `~/.Renviron` sets `PG*`, and R applies it over the shell's, so per-run `PG*` overrides are ignored | Reproduced (`PGDATABASE=zzz_probe` read back FALSE). `PGSERVICE` does win (libpq tried the service's database). Documented in `scripts/README.md` and CLAUDE.md, with `PGCONNECT_TIMEOUT`. `0200` now says when the database has no `bcfishpass` schema. |
| B2 | `MANIFEST.md5` lists `fissr_explore.sqlite`; `0230` stops on any missing listed file once it moves | Reproduced. Original record kept at `archive/fdis/MANIFEST.md5`; `fdis/MANIFEST.md5` is it less that line (26 files). A fresh sync and the local cache both verify 26/0. |
| G1 | sweep misses bare private names, home paths | Patterns added (`local_path`, `template_name`, `poisreport`); fixed `wf_peace_report_harvest.js` (harvest dir now `args.harvest_dir`), `planning/README.md`, `0298`'s `LINK_REPO` default; exemption narrowed to `planning/archive/` and `planning/active/`. |
| G2 | third-party private repo detail in `research/stream_temperature.md` | Trimmed to "not public" without names, SHAs or repo contents; the public memos stay cited. |
| G3 | stale "private" / `fdis/derived/` text | Fixed in 0230, 0240, 0290, 0294, 0296, `scripts/README.md`, `research/fdis_export.md`; CLAUDE.md in Phase 5. |
| G4 | no way back to `data/fdis/derived/` | `0299` `PULL=TRUE` (sha256-checked against the manifest). |
| G5 | manifest names the publish commit, not the build | Field is `published_from_commit`; each file records its source CSV's sha256 and mtime. |
| G6 | prefix unversioned | `knowledge/fdis/v1/`. |
| G7 | `0162` skips silently without a database | Not a regression (it skipped when both databases were down before); left. |
| G8 | `db_source` vocabulary changes | Old values mapped in `scripts/README.md`. |
| G9 | `.Rprofile` machine note; `0298` home-path default | Both reworded. |
| G10 | rtj#397 in #56/#57 and the PR body; PR reviews and branch commits unswept | Sweep reads PR reviews and branch commits; GitHub text edited in Phase 5; PR body names the bucket change in words; sweep re-run after the PR opens. |
| G11 | read-back compares arrow with itself | Replaced with an all-character comparison. It caught `ch_rule_visits.hydro_zone` (`"08"` read as 8, 6,651 rows); zero-padded columns are now kept as text. A planted `"007"` column fails the check. |
| G12 | archive publishes sweep patterns | Accepted: `planning/` archives are exempt in the issue, and repo names are not secrets. |
| G13 | "One discipline" needs a home for private context | Phase 5 CLAUDE.md rewrite. |
| G14 | public readers cannot sync | `0230` and `0299` take `NO_SIGN=TRUE`. `0260` needs the template checkout; its header says so. |
| O1 | S3 move before merge | Done before the review arrived; B2's fix restores `main`'s `0230` for a fresh cache. |
| O2 | PR body unswept | Sweep re-run after the PR opens. |
| O3 | flip steps split across commits | Noted: soul#438 holds the peer-list change. |
| AC1–2 | "reproduce outputs" undefined | Validation runs each package-loading script through `load_all()`; full runs where inputs are local (recorded in progress.md). |
| AC5 | local pkgdown build is not the control | The PR's pkgdown workflow run is the check. |
| AC6 | public URLs 403 until the bucket policy | Post-flip check. |
