# Code-check round 4: #121 branch (site_gradient_check.R, data-raw/README.md, research/fdis_export.md)

Reviewed at HEAD 72a2107 (tree clean). Verdict: **Clean**. Nothing sits above its source of truth on either side.

## Checklist read

- `code-check-python.md` in full (under 40,000 bytes; nothing in the diff is Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (guard that fails toward pass; fixture that cannot reach
  the failure mode; proxy is not the property; verification that reads its own output; a guard's scope, escape
  hatches, and remedies; a fix lands in one of two callers; restore the bug and prove the guard fires; a shared working
  tree; a wrapper's exit is not the work; zero-length, empty, and unset; the probe is broken before the world is;
  written data outlives the fix; serialization loses meaning silently; one fact derived twice), `|` rows skipped.
- `code-check-r.md`, the sections whose index line names a tool or shape this diff uses: "`system2(stdout = TRUE)`
  warns on a non-zero exit instead of raising"; "A `data-raw/` script must load the source tree, not the installed
  package"; "`match()` treats NA as a matchable VALUE"; "CSV whitespace: `trim_ws` and `strip.white`"; "`$` on a list
  partial-matches"; "Rscript reads a script as it runs".
- `code-check-shell.md`, `code-check-spatial.md`: indexes only; no shell or spatial tool in the diff.

## How this round checked

- Ran a copy of the current script (output path redirected to the scratchpad, run from the repo root) on the published
  evidence (`~/Projects/repo_aside/knowledge_published_inputs_20261028/data/fdis/derived`). Its log body is
  **byte-identical** to `scripts/logs/habitat/20261030_site_gradient_check.txt` from line 2 on; line 1 differs only in
  the stamp (72a2107, clean, against 28f61a3 in the committed log; the script is unchanged since). `git status` clean
  after.
- Stamp probe (lines 1-80 of the copy, then `head_sha` printed) at four `TUNE_DIR`s: the repo_aside `data/tune` gives
  `72a2107 (tune tables outside the tracked data/tune, not covered by it)`; `data/tune/` and `./data/tune` give
  `72a2107`; a missing directory (`data/tune/candidate`, absent here) stops at `normalizePath(mustWork = TRUE)`, before
  anything is written, which the later read of `<key>_tune.csv` would do anyway.
- Probe appended to the copy: BT spawning by outcome at its limit (13 %) on the segment gradient: present 6.3 % of 588,
  not present 8.8 % of 5,072.

## Review of fixes (a)-(c)

| Fix | What it does now | Checked against | Verdict |
|---|---|---|---|
| (a) key set | `thr |> filter(component == "gradient", !is.na(value))` (L167-170) | `knw_thresholds_table()` R/thresholds_table.R:85 writes component rows (and so a `value`) only for `status %in% c("fitted","underpowered")`; other statuses get one row with `component = NA`, `value = NA`. Today: 7 fitted + 1 underpowered gradient rows, all with values; 14 status rows with no component | Equivalent by construction, and now read from the artifact rather than restated. WCT_rear population 1,238 = its `n_visits`, so the rearing guard covers it. All 8 `<key>_tune.csv` are tracked (`git ls-files --error-unmatch`). Header L21-22 "(fitted or underpowered)" matches the writer's own filter |
| (b) BT spawning population sentence | "over the BT visits that pass every other filter of the tuning's (stream branch, in range, not blocked, no barrier downstream; 11,805 visits, 5,660 with a measured gradient) but not the spawner and groups filters, against the 513 visits the tuning scored" | R/tune_run.R:129-131 (base), 160-162 (range, blocked, barrier), 166-175 (spawner, `!is.na(S)`), R/tune_score.R:110/200 (groups); script `pop()` L171-177; log L223 | Correct: the script applies exactly the pre-spawner filters; the two it omits are named; numbers match the log |
| (c) stamp scope | `tune_tracked <- identical(normalizePath(tune_dir), normalizePath("data/tune"))`; `git status` given `data/tune` only when tracked, a literal path; otherwise the stamp says the tune tables are not covered | Probe above | Correct in both directions: outside-repo no longer aborts; in-repo ignored candidate dirs are labelled not covered (fails toward "not covered", never toward a clean stamp). `git status --porcelain` shows untracked (`??`) but not ignored files under `data/tune`; the eight `<key>_tune.csv` are tracked and none is matched by `.gitignore` (L23-41 ignore only grades, curves, scores, dev/, ref_*/, candidate/) |

## Enumeration 1: every number and quantifier in the #121 section against its source

Log = `scripts/logs/habitat/20261030_site_gradient_check.txt` (line numbers in that file). Research = `research/fdis_export.md`.

| # | Prose (research line) | Source | Verdict |
|---|---|---|---|
| 1 | 18,759 of 45,529 placed visits (270) | log L3 | OK |
| 2 | RISC Site Card Field Guide 2008 p. 13: two or more places, nearest 0.5 %, six method codes (274-276) | external PDF | not checkable here (no log source) |
| 3 | "the 644 half-zero rows above" (279) | research L85 "644 habitat rows have one gradient slot at 0 and the other above 0" | OK (exists, same meaning) |
| 4 | rank correlation 0.90 over 9,389 with both (281-282) | L8 (0.9, 9389) | OK |
| 5 | 0.60 to 1.58 at 80 % of 9,204 (282-283) | L8 p10/p90; 9,389 − 185 zero pairs = 9,204 | OK |
| 6 | 16,279 visits with a measured gradient on the branch (285) | L3, L22 | OK |
| 7 | Table, second reading: 0.90, 0.89, 0.60-1.00-1.58, 1.0 point, 46.5 % (291) | L8, L10 (0.886, absdiff 0.01) | OK (population every visit with both; round 3 measured the branch-only spread as immaterial) |
| 8 | Table, segment: 0.69, 0.64, 0.33-0.90-2.22, 2.2 points, 56 % (292) | L22, L25 (0.690, 0.641, 0.0220, 55.7) | OK |
| 9 | Table, Atlas: 0.65, 0.62, 0.26-0.83-1.94, 2.5 points, 61 % (293) | L23, L26 (0.653, 0.619, 0.0247, 61.1) | OK |
| 10 | segment better on rank, log r, median ratio nearer 1, narrower log-scale spread (296-297) | L22-23: 0.90 vs 0.83; 2.22/0.33 = 6.7x vs 1.94/0.26 = 7.5x | OK |
| 11 | p90 9.3 against 13.0 points (297) | L25-26 (0.0929, 0.1297) | OK |
| 12 | log r 0.64 against width's 0.54 (298-299) | L22; research L264 | OK |
| 13 | model higher at 87 % measured 0; 67 % above 0 to 3 %; 23 % above 30 % (300-301) | L125, L127, L149 (86.9, 67.4, 23.2) | OK |
| 14 | best on 50-250 m and orders 2-4, rank r 0.70 to 0.73 (301-302) | L44, L46, L72, L74, L76 (0.732, 0.731, 0.699, 0.712, 0.695) | OK (0.695 at the rounding edge, accepted round 3); all other length/order classes lower |
| 15 | worst on ≤ 10 m (0.53) and orders 5, 6; median ratio 1.24, 2.05 (302-303) | L38, L78, L80, L91, L93 | OK |
| 16 | river, wetland, lake rank r 0.37, 0.21, 0.33 (304) | L202, L206, L198 | OK |
| 17 | CH 11 %: 6.4 % of 2,453 (306) | L237 | OK |
| 18 | BT rearing 30 %: 0.8 % of 4,427 (306) | L233 | OK |
| 19 | WCT rearing 25 %: 0.7 % of 461 (306-307) | L247 | OK (new) |
| 20 | CO and GR 5.49 %: 25.8 %, 11.7 % (307) | L239, L241 | OK |
| 21 | BT spawning: other filters named; 11,805, 5,660; 513 scored; 13 %, 8.5 % (307-310) | L223, L235; thresholds.csv BT_spawn n_visits 513; code (fix b row above) | OK |
| 22 | "Within one step of each species' own ladder ... 33 to 42 %" (310-311) | L250-264 segment rows: 40.0, 34.3, 33.9, 40.7, 36.3, 35.3, 42.4, 33.3 (all 8 keys) | OK: min 33.3 (WCT, 3 visits), max 42.4 (ST) |
| 23 | CH 34 % of 218, BT spawning 34 % of 446 (311) | L237/L252 (218, 33.9); L235/L250 (446, 34.3) | OK |
| 24 | median 1.7 against 2.6 points (315) | L171, L173 | OK |
| 25 | 1.2 against 1.6 at ≤ 3 %; 6.2 against 6.0 above 13 % (316) | L178-179, L184-185 | OK |
| 26 | rank r 0.64 against 0.68; wider ratio spread (316-317) | L166, L168; 2.63/0.35 = 7.5x vs 2.02/0.32 = 6.3x | OK |
| 27 | 2.4 against 6.6 on ≤ 50 m; 1.7 against 3.4 on 50-250 m; 0.64 against 0.41 (318-319) | L189-192 | OK; "the absolute gap persists" also holds on (250, Inf] (1.4 vs 2.0, L193-194) |
| 28 | "Per species, visits where it was caught flip ... less often" with CH 4.1/6.5, CO 18.1/27.4, GR 2.2/15.0 (321-322) | L288-293; all 7 rearing keys hold (BT 0.5/0.8, RB 0.2/0.9, ST 12.5/17.2, WCT 0.5/0.7); BT spawning, probed: 6.3/8.8 | OK over every key, both stages |
| 29 | 55 negatives, −13.6 % to −0.01 %, 52 on own Atlas line (324-325) | L316 | OK |
| 30 | edge types 1200, 1400, 1410, 1425, all excluded from the branch; 34 in wetlands (325) | L320-324 (5 + 29); `edge_stream` = 1000, 1100, 2000, 2300 | OK |
| 31 | "No species' scored population holds one" (325-326) | L328-335: 0 for all 8 keys (BT spawning's tested set is a superset of its scored one) | OK |
| 32 | "the check tests every rule of the key at it" (326-327) | script L266-272 over `seq_len(nrow(tune))`; round 3 exercised the path with planted negatives | OK |
| 33 | `knw_rule_in()` keeps 0 up; curve and grade clamp (327-329) | R/rule_in.R:71 `g >= 0 & g <= rule$grad_max`; R/tune_curve.R:81, R/grade.R:59 | OK |
| 34 | evidence `1bd35829 009698d7 99f499bb`, `knowledge/fdis/v3` (334) | L1-2; thresholds.csv `evidence_md5`, `evidence_version` | OK |
| 35 | 29,335 placed visits, as #92's check counts (336-337) | L3; round 3 checked #92's log | OK |
| 36 | each rearing key held to its tracked `n_visits` (337) | script L186-192 (only on the published build, as the header says) | OK |
| 37 | 487 of 16,279; 337 (338) | L22-23 | OK |
| 38 | 45 visits at 13 %, 22 at 11 % (339) | L252, L254 `meas_on_limit` | OK |
| 39 | band one step either side on the key's tune-table ladder, mirrored at the top; log also gives the measured band (339-341) | script L199-218, L222 | OK |
| 40 | Header: Verified section date 2026-10-30; #121 (gradient); Produced by `data-raw/site_gradient_check.R`, log path (3-7) | file exists; log exists | OK |
| 41 | data-raw/README.md: no database; refuses evidence not the build thresholds.csv names unless `EVIDENCE_CHECK=FALSE`; takes it from `EVIDENCE_DIR` | script L40-42, L80-88 | OK |

## Enumeration 2: every definition the script restates from the tuning

| # | Restatement (site_gradient_check.R) | Owner | Agree today? | Guard |
|---|---|---|---|---|
| A | Stream branch, L103-104: `edge_type %in% edge_stream`, not `wb_river`/`wb_wetland`/`wb_lake`, `!is.na(area_m2)`, `area_range` | `knw_tune_run()` R/tune_run.R:129-131 (`base`) | Yes; constants read from `formals(knw_tune_run)` (L45-47), predicate retyped, term for term identical | Rearing `n_visits` check (8 of 8 keys' rearing ones match); BT spawning and the all-visit blocks unguarded, as before |
| B | Key filters, L172-176: `in_range %in% TRUE & status != "blocked"`, `barrier_dnstr_<sp> %in% FALSE` when present | R/tune_run.R:147-148, 160-162 | Yes, identical (no `status` or `in_range` NA in the published `visits_species`, so the `NA & ...` row hazard both share is latent) | Same as A |
| C | Groups with both outcomes, L178-181 | `.tune_modelled()` R/tune_score.R:200, the scorer's own call (L110) | Yes: **called**; `wsg` built as `factor(watershed_group_code)` as `base$wsg` is | `n_visits` = `nrow(d)` after `.tune_modelled()` (R/tune_score.R:136) is what thresholds.csv carries, so the check compares like with like |
| D | Spawn population: pre-spawner, pre-groups (L177) | R/tune_run.R:166-175 + `.tune_modelled()` | Deliberately not reproduced; disclosed in header L19-20, the log block title (L193-194) and the prose (fix b) | n/a |
| E | Key set: gradient rows with a value, L167-170 | `knw_thresholds_table()` R/thresholds_table.R:85 | Yes, equivalent by construction (fix a) and read from the published artifact itself | n/a (it is the source) |
| F | Key ladder: `sort(unique(tunes[[i]]$grad_max))`, L222, L237 | `knw_tune_grid()` per key (R/tune_grid.R:52, 80), as written to `<key>_tune.csv` | Yes, read from the tuning's own output | `band_of()` stops if a limit is not on its ladder (L202) |
| G | Generic ladder `formals(knw_tune_grid)$grid_grad`, L44 (measured-step grouping only) | `knw_tune_grid()` default; 0320 passes no `grid_args` | Yes | No published number depends on it (prose uses only the 0, ≤ 3 % and > 30 % classes) |
| H | Rule predicate: `knw_rule_in(dn, r, walks = wi)` with its defaults (L268, L271) | `knw_tune_run()` L137 passes `cols = cols_run` (0320 L101: `segment_gradient` by default, `cw_deploy`, `mad_pick`), `src = "pick"`, `edge_stream` | Yes: `knw_rule_in()` defaults (R/rule_in.R:63-64) equal all three | None; latent (0 negatives in every key's population) |
| I | Walks: `knw_walk_index(walks)` on the raw `walks.csv` (L257) | 0320 L189 reads the same file; `knw_tune_run()` L128 indexes it | Yes | n/a |
| J | Evidence md5 order and separator: `visits_link`, `visits_species`, `walks`, `;` (L60-61) | 0320 `evidence_md5s` order and `paste(collapse = ";")` | Yes; compared with thresholds.csv's single value (L80) | Mismatch refuses (fails toward abort) |
| K | "On the limit is in" (`<=`) in `flip_tbl` (L213) | `knw_rule_in()` `g <= rule$grad_max` | Yes for the upper bound; the `g >= 0` side matters only at a negative gradient, of which every population has 0 | Documented as "opposite sides of the limit" |
| L | `at_visit` −1 to 5 m and `len_breaks` (L43, L102) | `data-raw/segment_gradient_check.R` | Yes | Measurement constants, no tuning owner |
| M | Stamp scope: script, `R`, `data/thresholds.csv`, and `data/tune` only when `TUNE_DIR` is it (L70-76) | the script's tracked inputs (evidence is held by md5 instead) | Yes (fix c); `pkgload::load_all()` also reads DESCRIPTION/NAMESPACE, which carry no number this script uses | Probe above |

## Findings

None. Fixes (a)-(c) hold on the axes one over (status-to-value equivalence, tracked-vs-ignored tune tables, outside-
repo and trailing-slash paths), the log is reproduced byte for byte by the current code, every number and quantifier in
the section matches its source, and every restated definition agrees with its owner today.

## Clean
