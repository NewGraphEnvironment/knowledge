# Code-check round 2 for #75 (knowledge 33d754be...1a83a5d, soul 416-readme-knowledge @ 72a52a9)

## Checklist read

- `code-check-python.md` (7 KB): in full.
- `code-check.md` (329 KB): the prose of all 14 H3s under `## Mechanisms`, without the `|` rows or evidence blocks.
  Also read in full: "A link to a repo-hosted artifact must be *tracked*" and "Documentation Staleness". The other
  standalone, Security and Spreadsheets/PDF headings were not read (about 22).
- `code-check-r.md` (175 KB): read 6 headings: "A `data-raw/` script must load the source tree", "`R CMD build`
  ships every top-level directory", "`.Rbuildignore` has no comment syntax", "`cffr::cff_create()` writes a CRAN DOI",
  "Regenerated binaries churn git", and "`load_all()` runs every `.R` file at the top of `data/`". About 120 were not read.
- `code-check-shell.md` (121 KB): read 2 headings: "A `git push` can land and still report failure" (the CITATION
  workflow pushes) and "`gh` CLI" (About is set with `gh repo edit`). About 95 were not read.
- `code-check-spatial.md` (154 KB): no heading's index line names a tool or shape these diffs use. The diffs add no
  sf, terra or GDAL code; the figure goes through the unchanged `knw_compare_map()`. None were read (about 95).

## Findings

- **[false-claim] README.md:34-36**: "each one's header names the databases, credentials and tools it needs" is false.
  This is round 1's requirements finding back again, written as a quantifier. I walked all 41 scripts:
  - The five `scripts/wf_*.js` have no comment header at all, so nothing names the Workflow runtime they need
    (`agent()`, `parallel()`, `phase()`).
  - `0150-store.R`'s header (lines 1-31) does not name Ollama. Yet `ACTION=build` calls `cred::crd_store_build()`,
    which runs `.crd_ollama_check(model)` and `ragnar::embed_ollama`. (`0152`'s header does name Ollama.)
  - `0140` and `0160` run `system2("pdftotext", …)` (lines 44 and 34), and neither header names pdftotext.
  - `0280` runs `pdftotext` (line 231) and `ocrmypdf` (line 275). Its header (lines 1-58) names neither.

  Fix: narrow the sentence rather than widen it, for example "each R script's header names the database and
  environment variables it reads". Otherwise drop the completeness claim and point at the headers without promising them.

- **[false-claim] inst/NOTICE.md:8-12, and the README's "Data and methods"**: the notice lists `research/fig/` under the BC
  open licence as "maps drawn from the Atlas". That leaves out a source most of them carry:
  - 102 of the 121 tracked `research/fig/compare_*.png` are 1800 x 690, the three-panel form. Their third panel is
    floodplain cells built from the stac_floodplains_bc catalog: `scripts/0330-compare.R:53` (`catalog_items`) and
    lines 235-256 (`knw_floodplain_ha()`, `fl_valley_join`), passed as `fp_cells` to `knw_compare_map()` at 261-264.
  - That catalog's own `ATTRIBUTION.md` publishes the floodplain products under CC BY 4.0, and the delineation
    "contains information licensed under the Open Government Licence – Canada (MRDEM-30, Natural Resources Canada)".
  - The NOTICE names neither CC BY 4.0 nor OGL-Canada.
  - The README's "Data and methods" section does not name the floodplain catalog either, although the package exports
    `knw_floodplain_ha()`. The plan review's G3 asked for it (and for the BC Hydrologic Zones zip that `0310:61` downloads).
    `progress.md:19` records G3 as done for bcfishobs and CABD and drops the other two without saying so.

- **[false-claim] data-raw/README.md:4-6**: two parts of this sentence are false. Both were carried over from the old
  text when the sentence was reworded.
  - It says `vignette_chinook.R` "runs once against … the catalog's floodplain layers". It reads no floodplain layer:
    its header (line 24) says "The floodplain is not in the article (#62's second draft)", and the only floodplain line is
    `unlink(… "bulk_fp_grade.tif")` at line 240.
  - "Rerun it … after any `scripts/0320` or `scripts/0330` rerun" leaves out 0322. The script md5s 0322's outputs
    (`f_ge`, lines 118-142, folded into `src` and so into `meta$md5`), so `test-vignette-data.R` also fails after a 0322
    rerun. The script's own RUN line (37) says "after any 0320, 0322 or 0330 rerun".

- **[false-claim, minor] README.md:16 (alt text)**: the alt text says each stream is coloured by whether it is habitat
  under both rules, only `default`, or only the tuned rule. The map draws a fourth class, grey "accessible, neither"
  (`R/compare_map.R:76-79, 84-85`), and it covers most of the network drawn. The caption (lines 18-21) includes it; the
  alt text does not.

- **[fragile, soul] conventions/readme.md, the figure bullet's new sentence**: "Where a shared mapping function is what
  fails a check, file it against the function, which the article's map shares, and say in the caption what the map cannot show".
  - It follows "A map passes `cartography.md`'s checks" in the same bullet, and it lets a failing map ship without
    saying so. That is an unstated exception to the sentence before it.
  - "which the article's map shares" is knowledge's case, not a rule: a generic README figure may have no article map.
  - Suggested wording: "A map that fails a check only because of a shared mapping function may ship once the gap is
    filed against the function, with the caption saying what the map cannot show (where it is, without a keymap)."

- **[false-claim, minor, soul] conventions/readme.md, item 9's new evidence**: "the first NOTICE draft put EcoCat-derived
  site tables under the open licence because their names matched the open observations layer".
  - The draft is on record: `findings.md:90-91`, "a first NOTICE draft had them under OGL-BC; corrected". The cause
    ("because their names matched") is recorded nowhere, and it is the kind of causal clause a compression adds.
  - The first committed NOTICE (9aa5e9c) did not have them under OGL-BC, so the draft was never committed. Either drop
    "because …" or state the measured fact: `fiss_sites_*` is written by `0220` from the workbooks, not from the layer.

- **[note, soul] public-safety**: the amended file is `visibility: public-safe`, and it now cites knowledge#75, #76 and #77.
  `gh repo view` reads knowledge as PRIVATE today. The file already cites private soul issues (soul#416, soul#355), and
  evidence blocks do not load into the index, so this only matters if the file is published before #56's flip. There
  are no host names, private repo paths or client identifiers.

## Mechanism

Round 1's seven findings had one shared assumption, and it produced the four findings above. A sentence was written
from the member of a set that was in view, and then stated over the whole set. The member in view was the script's
default rather than the store, the one script just edited, the one panel being drawn, or the step that changed. When
review corrected a clause, only that clause was rewritten. The rest of the sentence, and the set it names, was carried
forward unverified.

The two failure shapes in this round:

- **Widening instead of narrowing.** Round 1 found the requirements list incomplete. The fix replaced the list with "each
  one's header names …", a universal over 41 scripts that nobody walked. `code-check.md`'s "The probe is broken before
  the world is" names this: "widening adds a quantifier over a population you have not enumerated … every widening
  broke and every narrowing held".
- **Inherited clauses in a reworded sentence.** `data-raw/README.md` was reworded to scope "every script" down to one.
  It kept the old sentence's input list (floodplain layers, dropped in #62) and its rerun list (no 0322) without
  rereading `vignette_chinook.R`. The NOTICE did the same at a larger scale: it generalised the README figure's
  provenance (Atlas only) to `research/fig/`, where 102 of 121 maps carry a third source. The alt text names the three
  classes in view and drops the fourth.

The remedy is the one round 1 asked for, applied to fixes too. Before editing any sentence a review touched, list every
member of every set the whole sentence names, from the producer (the script's code, `git ls-files`, the function's
factor levels), and narrow the sentence to what holds.

## Enumeration: Diff A published text

| # | Where | Claim | Verdict | Evidence |
|---|---|---|---|---|
| 1 | README:7, DESCRIPTION Title, About | Fisheries evidence and tuned habitat thresholds for BC watershed groups | TRUE | Same text in all three; `gh repo view` description matches |
| 2 | README:9-10 | gathers fish sampling records, past reports and literature, per group | TRUE | `R/fdis_*.R`, `R/fiss_visits.R`, `R/pscis.R` (`knw_pscis_reports`), `R/literature.R`, `scripts/0100`-`0250` |
| 3 | README:10-13 | from the fish records it tunes, where they allow, link's thresholds (e.g. smallest stream, steepest gradient for CH rearing) | TRUE | `data/thresholds.csv` CH_rear_v1 rows `rear_mad_min`, `rear_gradient_max`; status per species × stage in `knw_tune_run` |
| 4 | README:13 | compares the tuned rules with the ones link uses today | TRUE | `scripts/0330`, `data/compare/*_compare.csv` against `default` |
| 5 | README:13-14 | link's models show restoration and passage planning where habitat lies | TRUE | Statement of link's purpose (link README) |
| 6 | README:16 alt | streams chinook can reach | TRUE | `R/compare_map.R:73` filters `accessible`; `R/link_segments.R:62-64` gates on `streams_access` |
| 7 | README:16 alt | each coloured by both / default only / tuned only | FALSE (minor) | A fourth class, grey "accessible, neither", `R/compare_map.R:76-79` |
| 8 | README:18-19 caption | Bulkley River group, around Smithers and Houston, default against tuned | TRUE | `vignette_chinook.R:45` wsg BULK; towns established |
| 9 | README:19-20 caption | blue both, orange default only, green tuned only, grey open but neither | TRUE | `R/compare_map.R:84-85` colours; PNG viewed |
| 10 | README:20-21 caption | tuned rule drops more than it adds | TRUE | lost 747 km against gained 232 km (established) |
| 11 | README:29-30 | under active development, functions change (see NEWS) | TRUE | `NEWS.md` exists; lifecycle badge |
| 12 | README:30-31 | pin a release `@vX.Y.Z` | TRUE | Tags v0.4.1 to v0.4.6 exist |
| 13 | README:33 | evidence tables live in the repository, not the package | TRUE | `.Rbuildignore` `^data$` |
| 14 | README:33-34 | most work in a clone with `load_all()` | TRUE | `scripts/*` call `pkgload::load_all()` |
| 15 | README:34-35 | scripts run in the order of `scripts/README.md` | TRUE | `scripts/README.md` exists, tracked |
| 16 | README:36 | each one's header names the databases, credentials and tools it needs | **FALSE** | `wf_*.js` (5) have no header; 0150 omits Ollama; 0140, 0160 and 0280 omit pdftotext; 0280 omits ocrmypdf |
| 17 | README:36-37 | many read a PostgreSQL fwapg database found by `PG*` | TRUE | 22 of 36 R/Python scripts connect; `dbConnect(RPostgres::Postgres())` |
| 18 | README:37-38 | the tuning also reads link's province-wide run and wet's flows there | TRUE | `0320` → `knw_grade_species` → `knw_link_segments` reads `<schema>.streams` and `discharge.fwa_v1_segment_monthly` (`R/link_segments.R:36-50`) |
| 19 | README:40 | the FDIS extract is public as supplied under `s3://fresh-bc/fdis/` | TRUE | `fdis/MANIFEST.md5` 200 anonymously |
| 20 | README:40-41 | the visit tables are public as Parquet under `knowledge/fdis/` | TRUE | v1 and v2 `manifest.json` 200 |
| 21 | README:41-43 | the bucket does not list; the provenance note links the manifest | TRUE | List 403; `data/fdis_README.md:35-37` names the v2 manifest URL; live copy byte-identical |
| 22 | README:47-48 | thresholds are one table; parts are rows with link's parameter where it has one | TRUE | Rerun output matches; exception rows have a blank `link_parameter` |
| 23 | README:50-58 | code and its printed output | TRUE | Rerun prints identically |
| 24 | README (Example prose) | on a stream line, gradient ≤ 9 % and (MAD ≥ 0.75 or a ≥ 3 m³/s river within 1 km downstream) | TRUE | `R/rule_in.R:72-91`; rule `mad>=0.75\|g<=0.09\|Q3@D1000` |
| 25 | README (Example prose) | access and link's other steps then apply as to `default` | TRUE | CLAUDE.md, CH rearing's three stages; `0330` regenerates both |
| 26 | README Learn more 1 | the article tells the tuning in plain language, with the map above | TRUE | `vignettes/chinook_rearing.Rmd:426-430` (its panel adds a window outline) |
| 27 | README Learn more 2 | research index: one file per topic, FDIS export to tuned rules | TRUE | `research/README.md` plus 18 topic files |
| 28 | README Learn more 3 | function reference | TRUE | `man/` tracked |
| 29 | README Ecosystem | 10 rows: roles and links | TRUE | Wording matches fly's README; all 9 sites 200 |
| 30 | README Data s1 | fish records: FDIS, Known BC Fish Observations, EcoCat submissions; EcoCat holds past reports | TRUE | `0230`, `0200` (observations layer), `0200`-`0220`, `wf_*harvest.js` |
| 31 | README Data s2 | crossings from PSCIS | TRUE | `R/pscis.R:12-15` |
| 32 | README Data s3 | visits on link's run on FWA via fwapg, wet flows, CABD dams, each visit matched in bcfishobs | TRUE | `0310`; `R/link_regulated.R:3,36` CABD; `0310:7`, `0299:85` `bcfishobs_fdis_match` |
| 33 | README Data s4 | some crossing and report scripts read a bcfishpass database | TRUE | `0100`, `0110:12`, `0160:19` |
| 34 | README Data s5 | each literature value carries a verbatim quote checked against its source | TRUE | 1,088 of 1,145 rows quoted; the 57 unquoted are `kind = none` (no value); gate `0280` |
| 35 | README Data (set) | what it builds on | INCOMPLETE | Leaves out stac_floodplains_bc (`knw_floodplain_ha`, `0330:53`) and BC Hydrologic Zones (`0310:61`) |
| 36 | README Citation | `citation("knowledge")` | TRUE | `inst/CITATION` renders (author Irvine, organization the firm) |
| 37 | README License | MIT for the code; other data's terms in NOTICE | TRUE as stated | NOTICE completeness: rows 41-42 |
| 38 | DESCRIPTION Desc s1 | gathers records, reports, literature with quotes, IP models, timing; tunes gradient and size thresholds; places visits, scores held-out, grades, tabulates, maps, compares | TRUE | `knw_link_place`, `knw_tune_score`, `knw_grade`, `knw_thresholds_table`, `knw_compare_map`, `knw_compare_rules`, `knw_ip_read`, `knw_timing_read` |
| 39 | DESCRIPTION Desc s2 | pulls PSCIS layers and past-report tables; checks stream names | TRUE | `knw_pscis_pull`, `knw_pscis_reports` (derived from the layers), `knw_gnis_collisions` |
| 40 | DESCRIPTION Desc s3, CITATION.cff abstract | Under active development; the abstract is the Description verbatim | TRUE | Diff |
| 41 | NOTICE:3-4 | code MIT; data from other sources under their own terms | TRUE | LICENSE |
| 42 | NOTICE:8-12 | OGL-BC: FWA in `bulk_water.rds` and `bulk_segments.rds` (both installed), `readme-bulk.png`, `research/fig/` | TRUE for the files named; **FALSE by omission** for `research/fig/` | 102 of 121 maps also carry stac_floodplains_bc floodplain (CC BY 4.0, OGL-Canada MRDEM-30) |
| 43 | NOTICE:16-18 | the Province supplied extracts 2020-11-16 and 2022-03-22 and agreed 2026-10-16, with a note | TRUE | `data/fdis_README.md`; CLAUDE.md |
| 44 | NOTICE:19-20 | tables built from those visits (`fdis_*.csv`, use, tuning, comparison, thresholds) are NGE's work | TRUE (nuance) | `fdis_species_codes.csv` is a hand-curated input to `0230`, not built from visits; still NGE's work |
| 45 | NOTICE:24-25 | the two tables quote passages from what each row cites; the quoted text stays its authors' | TRUE | 57 `kind = none` rows cite nothing and quote nothing |
| 46 | NOTICE:29-30 | terms open in #76 | TRUE | #76 OPEN |
| 47 | NOTICE PSCIS | Access Only; `pscis_<wsg>.gpkg`, `crossings.csv`, `reports.csv`, `gnis_seed.csv` | TRUE | #76 table; `0100:20`; `0110:12` |
| 48 | NOTICE EcoCat submissions | `data/<wsg>/fiss_*`, `data/fiss_*.csv` | TRUE | `0200`-`0250` |
| 49 | NOTICE EcoCat text | `priority_*`, `priority_farmed_all`, `rag_priorities.*`, `corpus_tags`, `context_*.md`, `reports_found.md` | TRUE | `git ls-files` |
| 50 | NOTICE bcfishpass | `gnis_seed_ambiguity.csv`, `priority_pine_enriched.csv` | TRUE | `0110:13`, `0160` |
| 51 | NOTICE flows | PCIC flows on `bulk_segments.rds` | TRUE | `vignette_chinook.R:214` `mad = knw_size`; no other tracked table carries per-segment flow |
| 52 | `_pkgdown` Habitat evidence | read and validate the evidence and registry, list their vocabularies | TRUE | `knw_*_read` validate (`R/ip.R:68`); `knw_*_vocab` |
| 53 | `_pkgdown` link's segments | place visits with every species' flags; read segments, flow, width, regulated, barriers, walks; count access disagreement | TRUE | 8 of 8 functions mapped (Rd titles) |
| 54 | `_pkgdown` Tuning | build around link's thresholds, score held-out, fit curve, grade; one call builds, scores, fits | TRUE | `R/tune_run.R:67-138` (`grid`, `score`, `curve`; no grade) |
| 55 | roxygen `title` | names the figure in the nothing-drawn message, interactive title and legend title; static draws none | TRUE | `R/compare_map.R:70`, `add_categorical_legend(legend_title = title)`, `saveWidget(title = title)`; no title in `tm_layout` |
| 56 | CLAUDE.md fdis | 0299 builds v3, not uploaded; v2 published; PULL only with VERSION=v2 | TRUE | `0299:56-57` (v2\|v3 only); v3 403, v2 200 |
| 57 | data-raw/README s1 | scripts write the package's bundled data and figures | TRUE | Three scripts |
| 58 | data-raw/README s2 | `vignette_chinook.R` reads tuning and compare tables, the database **and the catalog's floodplain layers** | **FALSE** (last clause) | `vignette_chinook.R:24`, `:240` |
| 59 | data-raw/README s3 | rerun after any 0320 or 0330 rerun; the test fails until you do | **FALSE** (incomplete) | 0322's `grad_ext` files are md5'd (`:118-142`); header `:37` lists 0322 |
| 60 | data-raw/README s4 | `readme_figure.R` draws the README map from the same bundled data; rerun after `vignette_chinook.R`; `make_hexsticker.R` draws the sticker | TRUE | `readme_figure.R:8-16`; `make_hexsticker.R` |

## Enumeration: Diff B new sentences

| # | Where | Sentence | Verdict | Evidence |
|---|---|---|---|---|
| B1 | Check-claims bullet | Link a repo file by absolute URL: pkgdown copies the README to the home page, where a relative link breaks | TRUE, rule | pkgdown 2.2.0 `tweak_link_md` rewrites `scripts/README.md` to `.html`, which the site does not have |
| B2 | new bullet | a claim about what is published is checked against the store | Rule; no conflict | grep of soul conventions |
| B3 | evidence s1 | issue audit called v2 stale (script default v3); bucket held v1 and v2, v3 403; README names no version | TRUE | #75 body; probes |
| B4 | evidence s2 | plan review found the requirements sentence silent on bcfishpass, wet flows, Zotero key, AWS, Python, and the example prose stating a rule as fact | TRUE | `review-plan.md` B2, B3 |
| B5 | evidence s3 | relative links to `scripts/README.md`, `research/README.md` would have broken | TRUE | a3498ff diff; B1 |
| B6 | item 4 add | repo with package and data says how to reach both; where the store does not list, link a public document (note, manifest), not a bare prefix | Rule (wording: "a document that does" reads as if the note lists the store) | none |
| B7 | item 9 add | read the licence from the catalogue record; trace each file to its writer; `inst/NOTICE.md` when the package installs the data, as in flooded | Rule; TRUE | `flooded/inst/NOTICE.md` exists; no conflict with `pkgdown-publishing.md` (link's root NOTICE is a different case) |
| B8 | item 9 evidence | four PSCIS layers in 11 groups are Access Only | TRUE | #76; `R/pscis.R:12-15`; 11 tracked gpkgs |
| B9 | item 9 evidence | first draft put EcoCat site tables under OGL **because names matched** | draft TRUE, **cause unsupported** | `findings.md:90-91` |
| B10 | item 9 evidence | both went to #76; a root NOTICE is not installed, so the notice moved to `inst/` | TRUE | #76; `findings.md:93` |
| B11 | figure bullet add | file a shared function's failing check against the function, "which the article's map shares"; caption says what the map cannot show | **Contradicts** the bullet's first sentence (unstated exception); anecdote in a rule | see Findings |
| B12 | figure bullet add | assert gq in the figure script when the function falls back without it | Rule; TRUE of knowledge | `R/compare_map.R:88-93`; `readme_figure.R:12-13` |
| B13 | new bullet | one panel of an article's figure can be the README figure | Rule; no conflict | none |
| B14 | figure evidence s1 | the README map is the whole-group panel; the zoomed panel's examples belong to the article's table | TRUE | `vignette:429-430` (the article's panel also outlines the window) |
| B15 | figure evidence s2-3 | no scale bar or keymap, in the article too, went to #77, caption names two towns; gq fallback, so the script asserts the registry | TRUE | #77; caption; `readme_figure.R:12-13` |
| B16 | index | no heading or first sentence changed | TRUE | diff touches bullets, list items 4 and 9, and evidence only |
| B17 | public-safety | no hosts, private paths or clients | TRUE, except the knowledge#N citations while knowledge is PRIVATE (note) | `gh repo view` |
