# Branch review round 3 (#197)

Diff: `8926ae37...HEAD` (HEAD 1781855d), without `planning/`.

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms`, table rows skipped (A guard that fails toward pass;
  A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output;
  A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug
  and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work;
  Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data
  outlives the fix; Serialization loses meaning silently; One fact derived twice). No "Rules that stand alone" headings
  read; none names a tool or shape the diff uses.
- `code-check-r.md`: 8 headings read: "`sort()` and `order()` collate by `LC_COLLATE`…"; "Postgres row order is never
  fixed…"; "An `information_schema` lookup by the literal table name…"; "A database driver's value is not a base R
  type…"; "`paste()` with a zero-length argument…"; "Under `R CMD check`, tests run from a temp dir against the
  INSTALLED package"; "A `pkg::` call in a test passes `devtools::test()`…"; "A `skip_if_not()` skips only its own
  `test_that()` block". About 140 not read.
- `code-check-shell.md`: no heading read (the diff runs no shell); all not read.
- `code-check-spatial.md`: no heading read (no spatial code touched); all not read.

## The mechanism behind rounds 1 and 2

Both earlier findings were a sentence describing an artifact the author did not read when writing it: round 1 described
the *next* evidence build's `visits_link` from the #165 two-database comparison ("the same values"), and round 2
described a test fixture's provenance ("the order one database gave them on #165") from the intent behind it. The shared
assumption is that a description of an artifact can be written from what the author knows about a neighbouring
artifact or about their own intent, when it has to be read off the artifact it names. Its usual carrier is a count, a
"same", a provenance or a population (`code-check.md`, "A guard's scope…": a restatement names its population six ways,
a count first).

## Every place in the diff the mechanism reaches, checked

| # | where | claim | verdict | read from |
|---|---|---|---|---|
| 1 | R/link_place.R 31-33 (and man) | both species lists are sorted by name, which orders the species' columns in `placed`, so the column order does not depend on the catalog | true | SELECT list order is `acc` (sp_access) then `hab_sel` (sp_hab); `_stored` columns appended in the `for (sp in sp_hab)` loop |
| 2 | R/link_place.R 88-91 | unsorted, two databases holding one build write the same values in another column order | true for `placed` | `placed` carries no flow (`mad_pick` joins later in 0310); `DISTINCT ON` ends on `s.id_segment`; #165 values identical |
| 3 | test-link_place.R 20 | "four species in an unsorted order" | **false**: five species | fixture lines 21-24 and the expected literal on line 29 |
| 4 | test-link_place.R 20 | rows "of the shape" the catalog query returns | true | query returns `table_name`, `column_name` |
| 5 | test-link_place.R 69 | `_stored` copies follow the habitat list's order | true | re-gating loop, R/link_place.R 76-84 |
| 6 | database_builds.md 262 / run_archive.md 138-139 | the two tables carry one column order on any database | true (columns only; row order comes from `sites.rds` and left/inner joins on `v`/`fw_sites`, not the database) | 0310 lines 253-259, 438-450, 464 |
| 7 | same, 263 / 139 | published ledger lists both species groups in catalog order | true | `20261103_evidence_build_ledger.csv`: access and habitat both `BT;CH;CM;CO;PK;SK;ST;WCT;GR;KO;RB`, not sorted |
| 8 | same | next build's `visits_link` carries `segment_fwa_gradient`, which the published build lacks | true | column added 58fe4bb8 (2026-11-04), after the 2026-11-03 build; published ledger has no `segment_fwa_gradient_missing`; `database_second/…-evidence.csv` "added by the current code: segment_fwa_gradient" |
| 9 | same | the parent flows #161's fix moves | supported, not measured | `link_flow_tie_check.csv` host-old vs host-new, 632 lines; 4 visits in `derived_receipt_a/visits_link.csv` sit on them, all 4 with `flow_from = parent` (172777_1_1, 95183_49_1, 95796_73_1, 97120_75_1), so their `mad_pick` comes from the parent the fix re-picks |
| 10 | run_archive.md 98 | grade tables' bytes differ only in `evidence_md5`, through `visits_link`'s column order | true | `evidence_md5` is visits_link;visits_species;walks (0320 line 250); in #165 visits_species and walks bytes matched, visits_link values identical |
| 11 | evidence.yaml 12-16 | two tables' bytes differed by the species order until #197; crate fingerprints by column name so the verdict never moved; each grade's `evidence_md5` did | true | `receipt_165/…evidence_receipt_compare.txt` (sha256 "within", table agrees); row order deterministic as in 6 |
| 12 | database_builds.md 7, run_archive.md 5 | header issue lines | true | n/a |

Unchanged context left in present tense (run_archive.md 136-137 "takes the species from the catalog unordered … their
bytes differ"; database_builds.md 260) is corrected by the sentence that now follows it in each file, inside a dated
measurement paragraph; not raised.

## Findings

- **[severity: fragile]** tests/testthat/test-link_place.R:20 — the comment says the fixture holds "four species in an
  unsorted order", but it holds five: PK, BT, WCT and GR have `access_` columns, and KO has a habitat table and no access
  column (lines 21-24), which is why the expected `habitat` on line 29 has five members. This is round 1's fix to round
  2's finding carrying the same defect: a count written from intent, not read off the fixture. A reader taking it at its
  word would miss that the test also covers a habitat-only species. Say "five species (KO with a habitat table and no
  access column)" or drop the count.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

Code: no defects found. Prose: rows 1-2 and 4-12 hold against the code and logs.
