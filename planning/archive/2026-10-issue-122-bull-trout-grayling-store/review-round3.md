# Code-check round 3 (#122), branch 122-arctic-grayling-and-bull-trout-store-cle at 449c77a

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all fourteen H3s under `## Mechanisms` (table rows and evidence blocks skipped). None of
  the "Rules that stand alone", Security, or Spreadsheets/PDFs sections read in full; 23 headings not read.
- code-check-r.md: read "`ifelse()` with an all-NA test returns a logical vector", "`match()` treats NA as a matchable
  VALUE", "`dbConnect(SQLite(), path)` CREATES the file", "`nzchar(NA)` is TRUE", "`paste()` with a zero-length
  argument returns length ONE", "A database driver's value is not a base R type". About 120 headings not read (none
  names a tool or shape this diff uses: no testthat, roxygen, Postgres, arrow, sf, glue or package code changes).
- code-check-shell.md: no heading read; the diff has no shell script (the logs are captured output, not code). About 95
  not read.
- code-check-spatial.md: no heading read; the diff touches no spatial code. About 110 not read.

## The mechanism behind rounds 1 and 2

Both earlier findings are one assumption: **a set taken at the scope a tool naturally hands you stands in for the
scope the claim is about.** Round 1: `held` was every keyed PDF in the library (the scope of a SQL query on
`zotero.sqlite`) where the claim was "a keyed item this build ingests". Round 2: the push log was the whole bucket
manifest (the scope `crd_store_push(dry_run = TRUE)` prints) where the log is about one store. The same assumption
explains why both reached a commit: `public_sweep.py` (the #56 archive) exempts `scripts/logs/` by directory, while
CLAUDE.md exempts only the logs written before 2026-10-16, so no later log is ever swept. That is the check's scope
standing in for the rule's scope; it lives outside this diff (a one-line date filter in the archive script, or a
pattern run over new logs before commit).

Every place the mechanism reaches in this diff, checked:

| Place | Scope of the set | Verdict |
|---|---|---|
| 0150 `held` | PDFs of keys in `res` (the build's keys), group library, live | Fixed. Remaining gaps (file not on disk, `linkMode = 3`, linked files) are round 2's enumerated list; each is named by cred or unreachable today. |
| 0150 `res` vs cred | PDF rows vs files cred finds on disk | `opperman_etal2010EcologicallyFunctional` is absent from the store, named by cred's "Skipping 3 missing file(s)" warning in the committed log and recorded in findings.md. Not silent. |
| 0150 `mem` | live members of the named collections only | Correct. `DISTINCT` without `collectionID` dedups a member of two collections. |
| 0150 `why`/`out` | aligned by the same `!is.na(why)` mask | Correct; zero-row and all-covered cases return zero rows (no phantom row, `ifelse` all-NA case harmless). |
| `library = GROUP_ID` | cred's `.crd_zot_library()` reads a number as a groupID, refusing an internal libraryID | Correct (read cred 0.5.0's source). |
| 0270 `find_collection` elsewhere search | whole group, paginated (257 collections, 3 pages), trashed excluded | Correct; a bad `--parent` raises on the 404 before any write. |
| Push logs | trimmed to the store's own entry; the "would hold" line names the store list, already on main in 2026-09-29's push log | Clean. |
| Build logs | the Zotero storage path from the home directory and file names; earlier build logs on main list ingested files the same way | Clean; the #56 patterns find nothing. |
| 0280 logs | basenames of PDFs; 1145 and 117 rows, every row verified or `none_row` | Clean. |
| README collection keys | the ten keys | Each resolves (copy of `zotero.sqlite` with its WAL) to the name the README gives: habitat_modelling, chinook, bull_trout, grayling, species, temperature, wedzin_kwa_chinook, hydrology, salmon (under aquatic), salmon (under species). |
| Data CSVs | rename of `hagen_weber2019Limitingfactorsa` | Remainder compare against origin/main: the rename is the only change in all four edited CSVs (22 rows in literature_evidence). The new key is one live item in the group (`YC3EQ8T8`; a trashed `PT7KYXRX` carries it too, which every reader excludes). No vignette, test, `.bib` or research file cites the old key; only pre-branch logs do. New CSVs parse with a constant field count, LF endings, trailing newline. |
| Commit messages of the branch | #56 patterns | No hit. |
| planning/active | #56 patterns (held to `local_path` and `project_repo`) | Hit: see the finding. |

## Findings

- **[severity: security, low]** planning/active/progress.md:42 and :46 — the resume block carries a home-relative
  checkout path (the user's projects directory under `~`, twice), and planning/active/review-round1.md:30 a literal
  macOS home-directory path shape (with a placeholder user). CLAUDE.md ("One discipline: everything here is public") says planning/ from 2026-10-16 carries no home
  paths, and `public_sweep.py` holds `planning/active/` to its `local_path` class, so the sweep exits 1 on this branch
  and the text goes public with the archive. Same mechanism as rounds 1 and 2: text written for this machine committed
  where only the generic form belongs. Archives on main from after 2026-10-16 carry full home paths, so this is a
  discipline call, not a new kind of leak; write `cd <repo root>` and `<zotero dir>/storage/...` instead.
  - **Rule:** none (repo CLAUDE.md, "One discipline: everything here is public")

## Observations (not findings)

- scripts/0270-habitat-collection-build.py:214 — the lookup under PARENT does not filter trashed collections while the
  new group-wide search does (`not c["data"].get("deleted")`). A trashed same-named collection under PARENT would be
  returned as "exists" and filled. Today the group holds one trashed collection, not a name 0270 builds, and 0150 would
  then fail loudly (it skips trashed collections), so nothing is lost silently.
- scripts/0270-habitat-collection-build.py:229 — for a same-named collection at the top level the refusal says "pass
  --parent with that parent's key", which `--parent` cannot express. The refusal itself is the safe outcome.

## Disposition (main session)

- Finding (home-relative checkout paths in the resume block of progress.md, and a home-path placeholder in
  review-round1.md): real, fixed. Both now name the repo root and `<home>`. The #56 sweep
  (`public_sweep.py tree`) reports no hit in any file this branch changed (its 27 `host` hits are `m1`/`m2` variables in
  tests on main), and `public_sweep.py commits` reports no hits.
- The mechanism (a default population taken for the claimed one) was enumerated over the whole diff: `held`, `mem`,
  the push and build logs, the 0280 logs, the README keys, the CSVs, the commit messages. This progress.md/review path
  was the only remaining instance. The loop ends on that enumeration and the sweep's count, not on a clean round.
- Observations (not fixed): 0270's lookup under PARENT does not skip a trashed collection (the group has one, under
  another name), and its refusal message cannot express "top level". Neither applies today.
