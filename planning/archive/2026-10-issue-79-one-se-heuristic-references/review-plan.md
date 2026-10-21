# Plan review — #79 (Plan agent, 2026-10-20, delivered in its reply; written here by the session)

Most severe first. "Folded" says what the plan or the code took from each.

1. **Ordering.** Phase 2's new `thresholds.csv` columns change its header and CH rows, so `test-vignette-data.R`'s
   `md5_rows` check fails until `data-raw/vignette_chinook.R` reruns (Phase 5); that rerun needs the database and the
   ignored `data/compare/CH_rear_segments.rds`, `data/tune/CH_rear_curve.rds`, `CH_rear_grades.csv` (present here).
   The identical-to-old check must name what changes (`thresholds` +2 columns, `meta$md5_rows`, `meta$written`,
   `meta$md5` additions, new elements) and read the old bundle from `git show HEAD:`. The popup's "which condition
   kept it" needs Phase 5's kind-of-water column, so Phase 5's data comes before Phase 4's popup is finished.
   *Folded:* expected failure recorded between phases; Phase 5 reruns the bundle before the map is wired.
2. **Assumption.** Retitling the Zotero masters could make Better BibTeX regenerate `norris2024smnorris*`, cited by
   35 local files; the masters' titles are already lowercase, the mixed-case ones are copies. Keys live in
   `zotero.sqlite`'s `citationKey` field, not the stale `better-bibtex.sqlite`. The third fwapg (NX4NTJFN) and third
   bcfishpass (TDT6ZC48) copies are already in the group trash. rbbt's `library_id` is 9. Web API items get keys only
   after sync. *Folded:* masters' titles left alone.
3. **Gap.** `holds_196`'s size-variable check and its NA–NA branch had no test; `knw_thresholds_table()` used the
   default `d_floor`. *Folded:* two tests added, `d_floor` passed, and a guard that the 1-SE replay is `recommended`.
   Per component on the real data (size / gradient / exc_q / exc_d): BT rear F/T/T/T, BT spawn F/T/F/F, CH rear
   T/F/F/F, CO rear F/T/T/T, GR all T, RB rear T/F/T/T, ST rear F/T/T/T, WCT rear T/F/T/T. A TRUE on a value equal to
   `default`'s says little; when the 1.96 rule is a width rule, a MAD row's `link_parameter` is not what it would set.
4. **Gap, content.** CH at 1.96 also returns to a 5.49 % gradient (`mad>=0.75|g<=0.0549|none`). At 1.96 the close-call
   set is near the whole grid for several species (BT spawn 3,010 of 3,010; GR 3,493 of 3,612; ST 3,307; WCT 3,010),
   so "keeps `default`" often means the bar cannot separate rules. `tune_all` needs `is_default`, `size_var`,
   `size_min`, `grad_max`, `exc_q`. Wetland: edge types 1050/1150 (link's wetland rule) on `CH_rear_segments.rds` give
   tuned 10,197 km (median grade 0.0307), default 10,287 km, both 10,075 km. FDIS needs a Zotero item; the package's
   own citation drops out with the old section; `knw_compare_mapgl` needs a reference entry; round coordinates after
   the transform to 4326; popups built in the browser (`concat()`/`get_column()`) rather than an HTML string per
   segment. *Folded:* all.
5. **Acceptance.** `build_article()` renders against the installed package, so install the branch first; check
   `thresholds.csv` column by column (HEAD's equals the new one minus the two columns: TRUE); check the rendered
   references show versions; count `failed > 0 | error`; tests run locally only (no R-CMD-check workflow).
6. **Scope.** Other "cannot tell apart / noise" wording: `research/grayling_rearing_tuned.md:14`,
   `research/README.md:21`, `research/habitat_thresholds_tuned.md:31`, `research/chinook_rearing_tuned.md:147,252`.
   The 1.96 table belongs in `chinook_rearing_tuned.md`'s #57 paragraph, labelled as that run; the 30 % ladder is not
   replayed at 1.96. *Folded:* those lines in Phase 3; the replay's scope stated.
7. **Checked sound.** `se_diff` is the region's SE; `in_region` replays in all 26,875 rows; k = 1 reproduces pick and
   recommended for all 8, k = 1.96 the issue's column; no ties; nothing reading `thresholds.csv` breaks; pkgdown 2.2.0
   sets `IN_PKGDOWN` and renders with `html_document`, so citeproc and widgets work; the ESL PDF is the full book;
   fresh's `CITATION.cff` is on `origin/main`; link's README credits "Simon Norris … with contributions from many groups".
