# Code-check round 2 (#122), branch diff to 1fc2259

## Checklist read

- code-check-python.md: read in full.
- code-check.md: read the prose of all 14 H3s under `## Mechanisms` (table rows skipped). Read none of the
  sections under "Rules that stand alone" or "Security" past their index lines; none names a tool or shape
  this diff uses beyond the Mechanisms.
- code-check-r.md: read 10 sections: "`on.exit()` at a script's top level never fires", "`$` on a list
  partial-matches…", "A database driver's value is not a base R type…", "`nzchar(NA)` is TRUE…", "`paste()`
  with a zero-length argument…", "`dbConnect(SQLite(), path)` CREATES the file…", "`package_version()` errors
  on a pre-release version string", "`match()` treats NA as a matchable VALUE…", "Postgres row order is never
  fixed…", "`ifelse()` with an all-NA test returns a logical vector…". The other ~120 headings were read at
  index level only.
- code-check-shell.md, code-check-spatial.md: read at index level only; the diff uses no shell, git, gh, sf,
  terra or GDAL construct their headings name.

## Findings

- **[severity: security]** scripts/logs/rag/20261031_push_habitat_modelling.log:31-32,70 and
  scripts/logs/rag/20261031_push_bull_trout_grayling.log:31-32,70: the committed push logs dump the whole
  merged `log.json` manifest, which names the private repo `NewGraphEnvironment/fish_passage_template_reporting`
  (line 31, `"repo"`), its branch `rag-dedup-presync` (line 32), and a private-repo issue pointer
  `NewGraphEnvironment/fish_passage_template_reporting#208` (line 70, the `peace` store's note).
  `gh repo view` reads that repo PRIVATE (2026-10-31). CLAUDE.md, "One discipline": nothing tracked carries
  links to private repositories, and only `scripts/logs/` written before 2026-10-16 is "left as it was". On
  `origin/main` the newest log carrying the name is `scripts/logs/habitat/20261015_temperature_store_push.txt`,
  so these two are the first post-cutoff logs to add it. The #56 `public_sweep.py` will not catch them: it
  exempts `scripts/logs/` wholesale (`EXEMPT_PREFIX`), wider than CLAUDE.md's date-bounded exemption, so its
  `private_repo` and `template_name` patterns (both match these lines, run on this branch) never see them.
  Redact the manifest dump in both logs (keep this run's own store entry, or the first two lines) before the
  PR; GitHub keeps every pushed revision, so the branch's history already holds them (the issue/branch-history
  remedy in `feature-workflow.md` applies if the repo is flipped public with this history).
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## The round-1 fix (`held` restricted to keys in `res`): holds

Read against cred 0.5.0 (`.crd_zot_key_pdfs` -> `.crd_zot_resolve_keys`, `.crd_zot_attachments`,
`.crd_zot_pdf_sources`, `crd_store_build`). cred resolves each key to the single live item holding it in the
group library (a key on two live items there is left unresolved, with a warning); takes every live,
non-linked-URL (`linkMode <> 3`) `application/pdf` child of that item, deduped by md5 per item; and skips,
with a warning naming the key, any whose file is not on disk.

Mutation runs on scratch copies of `zotero.sqlite` (checkpointed copy, storage symlinked), with
`collection_keys()` parsed out of the current 0150 and cred's resolver run on its keys, for
`VHWEK6RE,GELFSUTU`, against the grayling standalone NNS8U574 (covered by `mcpherson2020Habitatuse`'s
child JDJ4IKR9):

| variant | 0150 lists NNS8U574 | cred ingests mcpherson | agree |
|---|---|---|---|
| baseline | no | yes | yes |
| parent taken out of GELFSUTU | yes | no (key not passed) | yes |
| covering attachment trashed | yes | no | yes |
| standalone's storageHash NULL | yes (over-reports) | yes | conservative |
| second live item given the same key in the group | **no** | no (cred warns, unresolved) | no |

- A parent with two PDFs, one the standalone's: cred 0.5.0 takes all PDFs, so the standalone is ingested;
  `held` agrees. (bottoms_etal2023 is such an item in habitat_modelling.)
- A hash on several parents: `held` keeps it if any parent's key is in `res`; that parent is the one cred
  resolves unless the key is ambiguous (below).
- The current left-out list is unchanged by the fix: rerun on the copy, habitat_modelling's 86 item keys
  equal the committed build log's, and bull_trout_grayling's 6.

Remaining divergences between `collection_keys()` and what cred ingests, none a finding: each is either
unreachable on today's data or named by cred itself, and none loses a member silently.

- Ambiguous key inside the group (two live items, one key): 0150 calls the standalone and the keyed member
  covered; cred drops the key and warns, naming the key, not the standalone. Today: 0 duplicate live keys in
  the group (query on the copy), and BBT disambiguates keys within a library.
- Covering PDF not on disk: 0150 calls the standalone covered; cred's "Skipping N missing file(s)" names the
  key. Real today for `opperman_etal2010EcologicallyFunctional` (no standalone depends on it; findings.md
  line 158 records it).
- `linkMode = 3` PDFs: `res` and `held` do not exclude them, cred does; 0 such PDFs in the group. A key whose
  only PDF is one would reach cred and be reported by cred as "no live PDF".
- Linked files (`linkMode = 2`, NULL storageHash) cannot cover a standalone in `held` though cred ingests
  them: over-reports, never under-reports; 0 linked-file PDFs in the group.

Other changes read and found sound: the cred version floors (`packageVersion() < "0.5.0"` compares as a
version; a `.9000` dev build is refused, the safe side); `library = as.integer(GROUP_ID)` matches the group
`collection_keys()` resolves in (an empty GROUP_ID stops in `collection_keys()` before cred is called);
0270's `--parent` and the paginated name check (fails loud, runs before the dry-run return); the
`hagen_weber2019Limitingfactors` rename (a pure substitution in literature_evidence.csv and the three members
files; the key resolves to one live group item, YC3EQ8T8; no other tracked file outside planning/logs names
the old key).

## Disposition (main session)

- Finding (private repo named in the two new push logs, from cred's dump of the whole bucket manifest): real, fixed.
  Each push log now holds only its own store's manifest entry, and `grep` finds no private repo name. The lines are
  still in this branch's commits `4653d64` and `01df0a5`. History was not rewritten, because `origin/main` already holds
  the same name in exempt pre-cutoff push logs (`scripts/logs/habitat/20260929_habitat_store_push.txt` and others), so
  the merge exposes nothing new. A later push log trimmed the same way would carry nothing; `public_sweep.py` exempting
  all of `scripts/logs/` is #56's to settle.
- The round-1 fix was checked against cred 0.5.0's resolution, with five mutations: no finding inside it.
