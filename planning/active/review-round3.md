# Code-check round 3 (#178 / #234), 2026-11-18

## Checklist read

- INDEX.md in full (every index line of the five files).
- code-check-python.md: index lines; no Python file is in the diff (0270 and 0275 were read as consumers, unchanged).
- code-check.md: the prose of every H3 under `## Mechanisms` ("A guard that fails toward pass" through "One fact derived
  twice"), with the first mechanism's table.
- code-check-r.md, by heading: "`$` on a list partial-matches, so a longer sibling key answers for a missing one",
  "`nzchar(NA)` is TRUE — non-empty checks silently pass NA", "CSV whitespace: `trim_ws` and `strip.white` do not do what
  the name suggests", "A `data-raw/` script must load the source tree, not the installed package", "Tests that silently
  do not run".
- code-check-shell.md and code-check-spatial.md: index lines only; the diff has no shell or spatial code (the one shell
  consumer, soul's `backlog_moves.sh`, was run read-only against the branch's `planning/backlog.md` instead).

## The mechanism

Rounds 1 and 2 are one mechanism: **a fact owned by link is held here as a restatement of link's input file, not asked of
link.** Round 1 hand-copied the species list out of link's config (two lists that agree today); its fix re-parsed
`parameters_fresh.csv` with `read.csv`, a second reader of link's schema, and round 2 found that reader's `$`. The fix
still re-reads link's *input*, and the input is not the set the code says it reads: `parameters_fresh.csv` has a row for
every species with parameters (13), while the species link's default *models* are link's compiled set,
`link::lnk_config("default")$species` (from `species_modelled.csv`: BT CH CM CO PK SK ST WCT GR), with KO and RB paused
(`$species_paused`, link#432, 2026-11-01: "gets no access, habitat or mapping code", link's config README) and CT and DV
not rules species at all. code-check.md, "One fact derived twice": "Ask a rule engine for its compiled predicate rather
than re-reading its input: a classifier transcribed from the config file agrees with the engine until the config
declares something the engine ignores." Here the config already declares four species the engine ignores or pauses.

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:40-41 (header), 83-94 (ACCESS); research/access_gradients.md,
  Specification bullet 3 — the ACCESS grid and every sentence describing it say it asks of "every species link models",
  but it reads the rows of `parameters_fresh.csv`, which is not that set: 13 species against link's 9 modelled plus 2
  paused (measured on the installed link 0.78.1 and on link `origin/main` 0.85.0, 2026-11-18;
  `setdiff(params, c(cfg$species, cfg$species_paused))` is CT, DV). It is a superset, so the gate cannot pass a modelled
  species with no row (link cannot model a species with no `access_gradient_max`); it fails toward demanding rows for
  CT and DV, which link does not model. So no false pass today, but the guard covers a different set from the one its
  sentence names, and "a species link adds is asked about at once" is true only of a row added to the parameter table,
  not of a species link turns on. Either read link's compiled set (`link::lnk_config("default")`, as 0310 already does at
  its line 218, `cfg$species` and, if paused species are meant, `cfg$species_paused`), or say "every species in link's
  `parameters_fresh.csv`" in the header, the comment and the research Specification.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: bug]** research/access_gradients.md, "What link does, and what this asks", first sentence, and the "link's
  class" column of the by-species table — "link blocks a species above the first stretch of stream steeper than its access
  gradient ... 15 % for ... grayling and kokanee, ... 25 % for bull trout, rainbow, cutthroat and Dolly Varden (link's
  `.../parameters_fresh.csv`)". In link's default, KO and RB are paused (no access code at all since 2026-11-01, link#432)
  and CT and DV are not modelled, so link blocks none of those four; the parameter file holds values for them that the
  engine does not apply. The file's premise ("what link does") is transcribed from link's input, the same mechanism, and
  #131's access gate, the track's next piece, reads this file. Say which classes link applies (the nine in
  `species_modelled.csv`) and that KO, RB, CT and DV carry configured values link does not currently use. The
  `habitat_literature.md` cross-reference in the Specification is unaffected.
  - **Rule:** code-check.md "One fact derived twice"

## Every place the mechanism reaches in this diff

| place | fact held | owner | verdict |
|---|---|---|---|
| 0280 ACCESS species | which species link models | link (`lnk_config()$species`) | does not hold: reads the parameter table (13), a superset of the modelled set (finding 1) |
| 0280 ACCESS column read | `species_code` is link's column | link's schema | holds: exact name check and `[[` (round 2) |
| 0280 ACCESS parameter `access_gradient_max` | the evidence parameter name | this repo's vocabulary (`knw_literature_vocab()$parameter`) | holds: a contract this repo chose, and in the vocabulary |
| research "What link does" and table | each species' class, and that link applies it | link | values match link 0.78.1 and `origin/main` (all 13); "link blocks" fails for KO, RB, CT, DV (finding 2) |
| research data-row citations (6-8, 63, 355-359, 1154-1189) | row positions and values | `data/literature_evidence.csv` | holds: every cited row read back (species, parameter, value, key) |
| evidence species codes | codes match link's | link | holds: BT CH CM CO CT DV PK RB SK ST WCT GR KO, each in the evidence table |
| `fits` units for `leap_height`/`swim_speed` | units in the vocabulary | `knw_literature_vocab()$unit` | holds: m, cm, ft, m/s, cm/s, ft/s all present |
| `swim_speed` metrics | metric vocabulary | `.knw_metric_fits()` | holds: vocabulary derives from it |
| 0280 `SCALE` | rescale per unit | 0280 | holds: ft, cm, ft/s absent, so read at scale 1 (fails closed); m rescales only for `bridge_distance` |
| 0280 FLOW grid | velocity is the water a fish meets | 0280 | holds: `swim_speed` is its own variable; GR's culvert `velocity` row (1185) is `migration`, a stage FLOW has no velocity cell for |
| `passage_limits_additions.csv` columns | fields 0270 reads | `0270` `addition_item()` | holds: every column is in 0270's list; braced organisation creators parse as one name |
| `passage_limits_members.csv` | `citation_key,source,pdf`, a URL pdf | `0270` `do_member()`/`addition_pdf()` | holds |
| verdict rows `merge-items` | action and column meaning | `0275` | holds: action in `ACTIONS`; done state (dc:replaces, collections, duplicate trashed) re-reads as done |
| `ESNB4BQB`, `HJZKI75D` in scripts/README.md and CLAUDE.md | Zotero collection keys | Zotero | holds against the run records (progress.md, findings.md); Zotero itself not read (out of scope) |
| `planning/backlog.md` | table shape | soul `backlog_moves.sh` | holds: `list`, `free`, `next` and `lanes` read it (rc 0); every clash is covered by a waits-on chain |
| CLAUDE.md, scripts/README.md, roxygen, man | unit and metric lists, the capability guard | `R/literature.R` | holds: each restatement matches the code |
| `$` reads in added R lines | names exist exactly | the frames and lists they read | holds: re-enumerated from the diff (x$/y$ on the checked evidence frame and fixture; ACCESS/access/cov/thermal/flow built in place; `knw_literature_vocab()$variable` exact), matching review-round2.md's list |

Nothing else in the diff restates a fact owned elsewhere. Tests, lint and the vignette-data failure are as the brief
accepts.
