# Code-check round 1, branch 122-arctic-grayling-and-bull-trout-store-cle

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms`, all 14 of them (table rows and evidence blocks skipped). Of the stand-alone rules and Security, none read in full: none of their headings names a tool or shape this diff uses beyond what Mechanisms covers.
- code-check-r.md: read "A database driver's value is not a base R type", "`match()` treats NA as a matchable VALUE", "`ifelse()` with an all-NA test returns a logical vector", "`dbConnect(SQLite(), path)` CREATES the file", "`nzchar(NA)` is TRUE", "`on.exit()` at a script's top level never fires" (6). The rest (about 170) not read; the index lines show they cover tools this diff does not use.
- code-check-shell.md: no section read. The diff has no shell code; the README and CLAUDE.md commands are documentation.
- code-check-spatial.md: no section read. Nothing spatial in the diff.

## Findings

- **[severity: fragile]** scripts/0150-store.R:108-120: the left-out list counts a standalone attachment as covered when any live keyed item anywhere in the group holds the same file (`held` is scoped by `p.libraryID = ?` only). The build ingests only the keys `res` returns, which are the keyed items in the named collections. So a standalone in a built collection whose keyed copy sits outside those collections, or has been taken out of them, is left out of the store and is not listed. The header (lines 26-28), the comment at 89-92 and scripts/README.md ("It names every member it leaves out") all say every left-out member is named.
  Reproduced on a scratch copy of zotero.sqlite (WAL checkpointed into the copy), running the branch's `collection_keys()` extracted unchanged: `collection_keys("GELFSUTU")` gives 24 keys and lists 1 left out (H8IMD55M). After deleting only the collectionItems row that puts keyed parent 9CQ7K3EM in grayling (its standalone 27WSD58H stays in the collection), it gives 23 keys and still lists only H8IMD55M. 27WSD58H's PDF is no longer ingested, and nothing says so.
  Today it causes no harm: a probe of the four store builds in scripts/README.md (bull_trout_grayling, habitat_modelling, temperature, flow) found no standalone covered only from outside its build (0 of 4, 0 of 11, 0 of 3, and no standalones). It is reachable, though: bull_trout and grayling are hand-curated, and CLAUDE.md now says 0270 never removes a member, so removing a parent by hand starts it. The same gap applies to a keyed holder whose key cred leaves unresolved (ambiguous in the group): cred names the key, but not the standalone that relied on it.
  Fix: scope `held` to the parents being built, for example `AND p.itemID IN (SELECT itemID FROM collectionItems WHERE collectionID IN (<ids>))` together with the citation key in `unique(res$citation_key)`, or filter `held` in R by the parent's key `%in% res$citation_key`.
  - **Rule:** code-check.md "A guard that fails toward pass"

## Checked and found sound

- cred 0.5.0 `crd_store_build(library =)`: `.crd_zot_library()` reads a numeric value as a groupID (it refuses one that matches only an internal libraryID), so `as.integer("4733734")` resolves to the group. Its `.crd_zot_resolve_keys()` also leaves trashed items out.
- Version gates: a `package_version < "0.5.0"` comparison is valid, and each gate runs before any work in its branch.
- 0270 `--parent` / `find_collection()`: the guard runs before the dry-run return, so `--dry-run` refuses too. A wrong `--parent` key raises at the first GET. The `parentCollection: false` for a top-level collection is handled. Under the species collection 9U54XAND there is one live grayling and one live bull_trout and no trashed duplicates.
- Key rename: in all four edited CSVs, the file equals origin/main's after `s/hagen_weber2019Limitingfactorsa/hagen_weber2019Limitingfactors/g`, with no other bytes changed. CR counts are unchanged (79 in habitat_modelling_members.csv, 0 in the others). Before the branch, no row used the new key. The old key survives only in planning/. No tracked .rds, inst/ or tests/ file names either key. In the group the new key has one live item (YC3EQ8T8) and one trashed one (PT7KYXRX), which 0150, 0280 and cred all skip. 0280's 2026-10-30 log verifies all 19 rows that cite the key; the other 3 rows name it only in a note.
- Members CSVs: every key in bull_trout_members.csv and grayling_members.csv names exactly one live group item, and that item is in VHWEK6RE or GELFSUTU. The header is `citation_key,source,pdf`, as 0270 reads it.
- Public text: the lines added outside planning/ and scripts/logs/ carry no home path, host, credential or private link.

## Observation outside the brief's scope (not a finding)

The new committed logs scripts/logs/rag/20261031_build_bull_trout_grayling.log (36 lines) and 20261031_build_habitat_modelling.log (263 lines) print absolute home paths (`<home>/Zotero/storage/...`) for each ingested PDF. CLAUDE.md exempts scripts/logs only for logs written before 2026-10-16. But origin/main already carries three later logs with home paths (20261017_compare-maps.out, 20261017_compare.out, 20261019_compare.out), and public_sweep.py skips scripts/logs. The brief excluded scripts/logs, so this is recorded here and not raised as a finding.

## Disposition (main session)

- Finding (standalone coverage held by any keyed item in the library): real, fixed. `held` is now limited to keyed
  items whose citation key the build ingests (`res`). The reviewer's reproduction did not reach it: `27WSD58H` is in
  the trash, so it is no live member, and old and new code both list nothing for it. Re-proved on a copy with
  `BQKF3I37` (McPherson 2020's keyed parent) taken out of GELFSUTU: the old code lists only H8IMD55M; the new one also
  lists `NNS8U574` (the McPherson standalone). The real collections are unchanged: 6 of 45 and 86 of 354 left out, so the
  two pushed stores are unaffected.
- Home paths in the two new build logs: replaced with `~/` (299 lines).
