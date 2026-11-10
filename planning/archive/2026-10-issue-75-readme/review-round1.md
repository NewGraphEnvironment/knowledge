# Code-check round 1: branch `75-readme-bring-it-to-the-readme-convention` (33d754be...HEAD)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md` (329 KB): the prose of every H3 under `## Mechanisms` (all 14, `|` rows skipped); plus
  "Bare `y`, `n`, `on`, `off`..." (YAML), "A link to a repo-hosted artifact must be *tracked*", "Documentation
  Staleness". Not read: the remaining 15 standalone/Security/Spreadsheet headings (none touches what this diff uses).
- `code-check-r.md` (175 KB): "A `data-raw/` script must load the source tree", "`R CMD build` ships every
  top-level directory not in `.Rbuildignore`", "`.Rbuildignore` has no comment syntax", "`R CMD build` ships the
  `.git` FILE...", "`cffr::cff_create()` writes a CRAN DOI...", "Regenerated binaries churn git", "`load_all()` runs
  every `.R` file at the top of `data/`", "Under `R CMD check`, tests run from a temp dir...". 8 read, the other
  ~120 not (no tool or shape in the diff).
- `code-check-shell.md` (121 KB): "Quoting" (the workflow's `Rscript -e '...'` and `git commit` step). 1 read,
  ~95 not.
- `code-check-spatial.md` (154 KB): none read; the diff makes no sf/terra/GDAL call of its own (the figure script
  calls `knw_compare_map()`, unchanged code). ~95 not read.
- Also read in full: soul `conventions/readme.md`.

## Verified, not findings

README example reruns byte-for-byte; caption's "drops more than it adds" holds (736 km lost vs 229 km gained in
`bulk_segments.rds`); every segment in the bundle is `accessible` (alt text "streams chinook can reach" holds);
cffr recipe in a temp copy reproduces `CITATION.cff` identically (cffr 1.4.2); `inst/CITATION` renders through
`readCitationFile()` and pkgdown's `read_citation()`; pkgdown with `inst/CITATION` writes only `authors.html`
(already allowed), so the net-unchanged allowlist is right; tagline = Title = GitHub About; Ecosystem rows match
an internal issue's decided rows; all 19 external links answer 200; FDIS extract, `MANIFEST.md5`, a data file and the v2
`manifest.json` are anonymously readable, and `fdis/README.md` links the manifest; release tags exist for the pin
line; every literature row with a value carries a quote; `compare_map.R` `title` roxygen matches lines 71/158/161;
`new_graphiti` (hex icon URL) is public; NOTICE's file list covers every tracked `data/` file I enumerated.

## Findings

- **[false-claim]** README.md:12 — "the thresholds that link's habitat models use ... such as the smallest flow and
  the steepest gradient for juvenile chinook rearing". link's `default` sizes CH rearing streams by channel width,
  not flow: `parameters_habitat_method.csv` puts all 188 groups on `cw` (link `inst/extdata/configs/default/`), and
  link's own `default_tuned/README.md` says its MAD values "move no output while every group is on `cw`, which is
  every group today". The tuned CH rule *replaces* link's 1.5 m width floor with a MAD floor
  (`data/thresholds.csv` row 9: `rear_mad_min`, `default_value` NA; `knw_compare_rules()` roxygen: "with the stream
  branch's size test replaced"). So the sentence tells a reader link uses a flow threshold for chinook rearing
  today, which it does not. A neutral wording ("the smallest stream", as DESCRIPTION's "stream-size thresholds")
  would be true.

- **[false-claim]** README.md:61-62 — "The tuned rule counts a stream segment as chinook rearing habitat where its
  gradient is at most 9 % and either its MAD ≥ 0.75 m³/s or a river of ≥ 3 m³/s lies within 1 km downstream."
  Read as stated, this is a sufficient condition, but the code's rule is only the stream-branch predicate: the
  segment must also be accessible, and rearing must survive fresh's connectivity pass (spawning upstream or within
  10 km downstream), with hand-entered reaches added (`R/compare_rules.R:3-12`, the three stages; the article states
  it correctly at `vignettes/chinook_rearing.Rmd:129-139`: "if chinook can reach it and ... rearing is kept only
  where it connects to spawning"). "Stream segment" also means the code's stream branch (a stream edge in no river
  polygon, wetland ≥ 1 ha or lake ≥ 100 ha, `R/compare_rules.R:17-23`), and the tuned gradient also moves river
  polygons (`compare_rules.R:16`, vignette:145-147), which the sentence does not say. The figure directly above
  shows the post-access, post-connectivity result, so a reader checking a segment against the sentence will find
  ones that meet it and are grey. Either add "on a stream reachable by chinook ... and connected to spawning" or
  drop the sentence (the convention's "When a correction needs a qualifier, consider dropping the claim").

- **[false-claim]** README.md:35-38 — the requirements list "Others need a bcfishpass database, a Zotero Web API
  key, AWS credentials or Python" omits needs the scripts state: a local, synced Zotero data directory
  (`scripts/0150-store.R:18-19` "cred reads the LOCAL ~/Zotero/zotero.sqlite ... The Zotero data dir must be synced";
  `0280-literature-verify.R:50,118`; `0270`), Ollama with `nomic-embed-text` (`0152-rag-add-harvest.R:22`
  "REQUIRES: Ollama up (nomic-embed-text) for embedding"; `0154`, `0156` embed too), and the five `wf_*.js` harvest
  workflows, which run in an agent workflow runtime rather than R or Python. The old README carried the Zotero
  data-directory need; the rewrite dropped it. Per readme.md, "A requirements sentence is a claim about each path
  it names." (Also borderline: "Most read a PostgreSQL database" holds for 19 of the 36 numbered scripts and 19 of
  41 counting `wf_*.js`.)

- **[false-claim]** `_pkgdown.yml:43-46` (Tuning `desc:`) — "...grade every segment by expected use, and run all
  of it in one call for every species and stage". `knw_tune_run()` does not grade: it cuts the population, builds
  the grid, scores and fits the curve (`R/tune_run.R:1-6`; no `knw_grade*` call in the file); grading is a separate
  `knw_grade_species()` call (`scripts/0320-tune-run.R:203`). "All of it" therefore overstates the one call. (Lesser:
  `knw_walk_index` and `knw_rule_in`, listed under this group, are covered only implicitly by "score them".)

- **[false-claim]** CLAUDE.md:65-67 — "`0299` builds them as `knowledge/fdis/v3`, which is not yet uploaded ..., and
  restores them with `PULL=TRUE`". With v3 not uploaded, `PULL=TRUE` at the default `VERSION` (v3,
  `scripts/0299-fdis-publish.R:56`) has nothing to restore; only `PULL=TRUE VERSION=v2` works today. The edit added
  the "not yet uploaded" fact but left the restore claim pointing at the same unpublished set.

- **[false-claim, minor]** `data-raw/README.md:3-5` (not in the diff, made stale by it) — "Scripts that write the
  data the package's articles read ... writes small files under `inst/vignette-data/`". The branch adds
  `data-raw/readme_figure.R` and `data-raw/make_hexsticker.R`, which write `man/figures/`, plus a committed
  `nge-icon_white.png`; the README now describes one of three scripts. Public on GitHub once #56 flips.

- **[fragile, minor]** `data-raw/readme_figure.R:12` — the guard asserts gq's registry has a `lake` layer, but
  `knw_compare_map()` falls back silently to a hand-picked fill when `gq::gq_tmap_style()` errors
  (`R/compare_map.R:89-90`, `tryCatch(..., error = function(e) NULL)`), so the guard can pass while the README map
  is not styled through gq, which is what its comment says it ensures. Today the translation succeeds (checked:
  returns fill/col/lwd), so this is not live; asserting `!is.null(gq::gq_tmap_style(reg$layers$lake))` would close
  it.

## Note (planning, outside the reviewed diff)

`planning/active/task_plan.md:55` is checked "[x] ... add `NOTICE` to the pkgdown workflow's `allowed` list" and
`findings.md:93` says it was added, but 9bb77ef reverted that when NOTICE moved to `inst/` (net diff to
`pkgdown.yaml` is empty, which is correct). The PWF record describes a change the branch does not make.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round1.md
