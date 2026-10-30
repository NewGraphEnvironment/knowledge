# Code-check round 3: #121 branch (site_gradient_check.R, data-raw/README.md, research/fdis_export.md)

## Checklist read

- `code-check-python.md` in full (under 40,000 bytes; nothing in this diff is Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (guard that fails toward pass; fixture that cannot
  reach the failure mode; proxy is not the property; verification that reads its own output; a guard's scope,
  escape hatches, and remedies; a fix lands in one of two callers; restore the bug; shared working tree; wrapper's
  exit; zero-length/empty/unset; the probe is broken; written data outlives the fix; serialization; one fact
  derived twice), table rows skipped.
- `code-check-r.md` sections whose index line names a tool or shape this diff uses: `system2(stdout = TRUE)` warns
  on a non-zero exit; CSV whitespace (`readr::read_csv`); a `data-raw/` script must load the source tree; `$` on a
  list partial-matches; plus the index lines for `match()` NA, `identical()` on reader results, Rscript reads a
  script as it runs.
- `code-check-shell.md`, `code-check-spatial.md`: indexes only; no shell or spatial tool in the diff.

## Mechanism

Both candidates are confirmed, and they are one mechanism: **every population, key set and number in this branch
is written twice by hand, once where it is owned and once where it is used, and the only link between the copies
is the author's reading of the first when writing the second.** The script restates the tuning's definitions
(mechanism 2) and the prose restates the script's log and its header (mechanism 1). Every R1/R2 finding is a
place the two copies stopped agreeing: the default ladder for ST's (script vs `knw_tune_grid()` per key), the
ratio direction and quantifiers (prose vs log), the BT spawning filters (prose vs script), the stamp's scope
(script comment vs what `git status` was given). The guards that do exist (the rearing `n_visits` check, the
evidence md5 check) are the places where a copy is compared with its source by machine, and no R1–R3 finding sits
behind one of them.

Two new instances this round, one per side, plus one inside R2's fix:

1. Mechanism 2: the script restates "which keys publish a limit" as `status == "fitted"`; every other reader in
   the package uses `c("fitted", "underpowered")`. WCT rearing (limit 0.25) is dropped.
2. Mechanism 1: the prose restates the BT spawning population as "every BT visit in the species' range"; the
   script's own header (lines 17-20) gives the correct, narrower definition.
3. R2's stamp now passes `TUNE_DIR` to `git status`, which aborts the run for any `TUNE_DIR` outside the repo.

## Enumeration 1: numbers and quantifiers in the #121 section against the log

Log = `scripts/logs/habitat/20261030_site_gradient_check.txt` (line numbers in the log file).

| # | Prose claim | Log source | Verdict |
|---|---|---|---|
| 1 | 18,759 of 45,529 placed visits | L3 | OK |
| 2 | RISC Site Card Field Guide 2008, p. 13 (method codes, 0.5 %) | none (external document) | no log source; not checked here |
| 3 | "the 644 half-zero rows above" | research/fdis_export.md:85 | not in this log; exists in the file |
| 4 | rank correlation 0.90 over 9,389 | L8 (0.9, 9389) | OK |
| 5 | 0.60 to 1.58 at 80 % of 9,204 | L8 p10/p90; 9389 − 185 = 9204 | OK |
| 6 | 16,279 visits with a measured gradient on the branch | L3, L22 | OK |
| 7 | Table, second-reading row: 0.90, 0.89, 0.60–1.00–1.58, 1.0 point, 46.5 % | L8, L10 | OK as numbers; population is every visit with both (9,389), not the stream branch the paragraph heads. Measured on the branch: 8,482 pairs, rank 0.895, log r 0.882, same ratios, 47.1 %. Spread immaterial; not a finding |
| 8 | Table, segment row: 0.69, 0.64, 0.33–0.90–2.22, 2.2 points, 56 % | L22, L25 | OK |
| 9 | Table, Atlas row: 0.65, 0.62, 0.26–0.83–1.94, 2.5 points, 61 % | L23, L26 | OK |
| 10 | "narrower ratio spread on the log scale" | L22-23: 2.22/0.33 = 6.7 vs 1.94/0.26 = 7.5 | OK (derived) |
| 11 | p90 9.3 against 13.0 points | L25-26 absdiff_p90 | OK |
| 12 | log r 0.64 against width's 0.54 | 0.641 L22; 0.54 from research/fdis_export.md:264 | 0.54 not in this log; exists in the file |
| 13 | 87 % at 0; 67 % above 0 to 3 %; 23 % above 30 % | L125, L127, L149 | OK |
| 14 | best on 50–250 m and orders 2–4 (rank r 0.70 to 0.73) | L44, L46, L72, L74, L76 (0.732, 0.731, 0.699, 0.712, 0.695) | OK (0.695 at the rounding edge) |
| 15 | worst on ≤ 10 m (0.53) and orders 5, 6; median ratio 1.24, 2.05 | L38, L78, L80, L91, L93 | OK |
| 16 | river, wetland, lake rank r 0.37, 0.21, 0.33 | L202, L206, L198 | OK |
| 17 | CH 11 %: 6.4 % of 2,453; BT rear 30 %: 0.8 % of 4,427; CO, GR 5.49 %: 25.8 %, 11.7 % | L232, L236, L238, L240 | OK |
| 18 | BT spawning "over every BT visit in the species' range before that filter and the groups filter (5,660 …, against the 513 …)": at 13 %, 8.5 % | L223, L234 | **Numbers OK; quantifier wrong** (Finding 2) |
| 19 | "Within one step of each species' own ladder … 34 to 42 %" (CH 34 % of 218, BT spawning 34 % of 446) | L247-260 segment rows: 33.9 to 42.4 | OK over the 7 keys logged; "each species" misses WCT (Finding 1; WCT 33.3 % of 3) |
| 20 | median 1.7 against 2.6 points | L171, L173 | OK |
| 21 | 1.2 against 1.6 at ≤ 3 %; 6.2 against 6.0 above 13 % | L178-185 | OK |
| 22 | rank r 0.64 against 0.68; wider ratio spread | L166, L168 (7.5x vs 6.3x) | OK |
| 23 | 2.4 against 6.6 on ≤ 50 m; 1.7 against 3.4 on 50–250 m; 0.64 against 0.41 | L189-192 | OK |
| 24 | "Per species, caught flips less often": CH 4.1/6.5, CO 18.1/27.4, GR 2.2/15.0 | L279-290 | OK; the universal holds for all six rearing keys logged (and WCT, measured: 0.5 vs 0.7) |
| 25 | 55 negatives, −13.6 % to −0.01 %, 52 on own Atlas line | L305 | OK |
| 26 | edge types 1200, 1400, 1410, 1425; 34 in wetlands; none on the branch | L305, L309-313 (5 + 29) | OK |
| 27 | "No species' scored population holds one" | L317-323 | OK over 7 keys; WCT not tested by the log (measured: 0). Finding 1 |
| 28 | "the check tests every rule of the key at it" | code L253-274 | OK; path never ran on the published build, so I ran it with planted negatives in CH_rear and BT_spawn: runs, NA kept out, counts sane |
| 29 | curve and grade clamp to 0 | R/tune_curve.R:81, R/grade.R:59 (`pmin(pmax(g, 0), 0.2)`) | OK |
| 30 | evidence `1bd35829 009698d7 99f499bb`, `knowledge/fdis/v3` | L1, L2 | OK |
| 31 | 29,335 placed visits "as #92's check counts" | L3; `scripts/logs/habitat/20261027_segment_gradient_check.txt` L2 | OK |
| 32 | 487 of 16,279; 337 | L22-23 | OK |
| 33 | 45 visits at 13 %, 22 at 11 % | L249-252 meas_on_limit | OK |
| 34 | Header: Verified 2026-10-30, #121, #120 | gh: #120 "Tune chinook rearing on minimal segments…", #121 "Measured site gradient…" | OK |

## Enumeration 2: definitions the script restates instead of calling

| # | Restatement (site_gradient_check.R) | Owner | Agree today? | What would make them drift; guard |
|---|---|---|---|---|
| A | Stream-branch predicate, L98-99 (edge type, three `wb_*`, `!is.na(area_m2)`, range) | `knw_tune_run()` R/tune_run.R:137-139 (`base`) | Yes (constants read from formals; predicate retyped) | A change to the predicate in `knw_tune_run()` (e.g. a new waterbody exclusion). Guarded for rearing keys by the `n_visits` check (L181-187); unguarded for the all-visit and branch agreement blocks and BT spawning |
| B | Key population filters (in_range, not blocked, barrier col), L167-171 | R/tune_run.R:156-158 | Yes | Same; rearing guarded by `n_visits`, spawning not |
| C | Groups-with-both-outcomes filter | `.tune_modelled()` R/tune_score.R:200 | Yes: **called**, not restated | n/a |
| D | Spawn population (spawner evidence, then groups) | R/tune_run.R:166-173 + 0320's `knw_spawner_evidence()` | Deliberately not reproduced; disclosed in header L19-20 and prose | Prose restates it a third time and gets it wrong (Finding 2) |
| E | Which keys publish a gradient limit: `status == "fitted"`, L163 | `knw_thresholds_table()` R/thresholds_table.R:85, 0325:104/125, `knw_tune_promote()` R/tune_promote.R:89/220 (`c("fitted","underpowered")`, `.knw_no_fit`) | **No**: WCT_rear (underpowered, limit 0.25) dropped | Already drifted (Finding 1). `data-raw/vignette_method.R:82` uses the same narrower literal on the summaries (outside this diff) |
| F | Key ladder: `sort(unique(tune$grad_max))`, L217/L232 | `knw_tune_grid()` per key, as written to `<key>_tune.csv` | Yes: read from the artifact the tuning wrote | n/a (fixed in R1) |
| G | Generic ladder `formals(knw_tune_grid)$grid_grad`, L44, for the "measured step" block | `knw_tune_grid()` default; 0320 passes no `grid_args` | Yes | Only a label for a grouping; no published number depends on it |
| H | Rule predicate: `knw_rule_in()` **called**, but with its own defaults for `cols`, `src`, `edge_stream`, L263 | `knw_tune_run()` passes `cols = cols_run` (0320 `GRADIENT`), `src = "pick"`, `edge_stream` | Yes (defaults equal: `segment_gradient`, `"pick"`, 1000/1100/2000/2300) | A change to `knw_tune_run()`'s `src` default or 0320 passing `src`/`cols`; no guard. Latent: the path has 0 visits on this build |
| I | Walks: `knw_walk_index(walks.csv)` raw | 0320 passes the same raw `walks.csv` to `knw_tune_run()` | Yes | n/a |
| J | Evidence md5: `visits_link`, `visits_species`, `walks`, joined by `;` | 0320 L148-152 | Yes, same order and separator; compared with `thresholds.csv`'s value | 0320 adding a table; the check would then refuse (fails toward abort) |
| K | "On the limit is in" (`<=`) in `flip_tbl` | `knw_rule_in()` `g >= 0 & g <= grad_max` | Yes for the upper bound; `flip_tbl` ignores the `>= 0` side, which matters only at a negative gradient (0 in every population) | Documented as "opposite sides of the limit", not rule in/out |
| L | `at_visit` −1 to 5 m and `len_breaks` | `data-raw/segment_gradient_check.R:29, 65` | Yes | Both are data-raw measurements, no tuning owner |
| M | Provenance stamp scope: `git status -- <script> R data/thresholds.csv <tune_dir>` | n/a (R2 fix) | Works for in-repo `TUNE_DIR` | Aborts for any `TUNE_DIR` outside the repo (Finding 3) |

## Findings

- **[severity: bug]** data-raw/site_gradient_check.R:163 (and header L21-22) — `filter(status == "fitted", component == "gradient")` drops WCT rearing. `data/thresholds.csv` publishes WCT_rear with `status = underpowered`, `value = 0.25`, `n_visits = 1238`, and `data/tune/WCT_rear_tune.csv` exists. `knw_tune_run()` fits an underpowered key (R/tune_run.R:266), and every reader of the published set uses `c("fitted", "underpowered")` (R/thresholds_table.R:85, scripts/0325-publish.R:104,125, R/tune_promote.R:89). So the header's "counted at every published gradient limit in data/thresholds.csv" is false, and the research section's "each species' own ladder", "No species' scored population holds one" and "Per species, …" were never tested on WCT. Measured by a temp copy with `status %in% c("fitted", "underpowered")` on the published evidence: WCT_rear population 1,238 (matches `n_visits`), 461 with a measured gradient; flips 0.7 % (segment), 3.3 % (Atlas line); band (0.2, 0.3] 3 visits, 33.3 %; caught 0.5 % vs not 0.7 %; 0 negatives. No prose conclusion reverses, but the band range would read 33 to 42 %, and the log and the header describe a key set that is not the published one.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a literal set used as a filter; pin scope against its source of truth)
- **[severity: bug]** research/fdis_export.md, "At the limits" bullet (line ~305 in the file) — "its figure is over every BT visit in the species' range before that filter and the groups filter (5,660 with a measured gradient …)". The population is the stream branch, in range, not blocked, with no barrier downstream (script header L16-20, `pop()` L167-171): 11,805 visits, 5,660 with a measured gradient. Every BT visit in range is 38,021, 15,564 with a measured gradient (measured on the published evidence). The quantifier overstates the population about 2.75-fold; the figure's own numbers are right. Fix: "over BT's stream-branch visits in its range, not blocked and with no barrier downstream, before that filter and the groups filter".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (compression runs both ways: a sentence that gained a quantifier is unsupported until checked against its source)
- **[severity: fragile]** data-raw/site_gradient_check.R:70 — R2's stamp passes `tune_dir` to `git status --porcelain --`. For a `TUNE_DIR` outside the repo, git exits 128 ("is outside repository"), and `git_out()` stops the run with "git status … failed", which names neither the cause nor a remedy. The header documents `TUNE_DIR` as a knob, and CLAUDE.md prescribes staging promoted inputs beside the repo (`~/Projects/repo_aside/knowledge_published_inputs_20261028/data/tune` exists on this machine). The run aborts before writing anything, so no wrong number results, but a legitimate configuration is refused for an unrelated reason. Conversely, an in-repo but ignored `TUNE_DIR` (`data/tune/candidate/<run>`) shows nothing in `git status`, and the stamp reads clean though those tables are no commit's; line 1 still prints the directory, so it is visible. Fix: pass `tune_dir` to `git status` only when it is inside the work tree, and stamp it as "untracked" when it is ignored or outside.
  - **Rule:** code-check.md "A guard that fails toward pass" (which direction it fails: the mirror mistake, a guard that fails toward abort on a legitimate input)

Not findings, measured:
- The yardstick row in the comparison table is over every visit with both readings, while the table sits under "On the tuning's stream branch". On the branch it is 8,482 pairs, rank 0.895, log r 0.882, the same ratio quantiles, 47.1 % second higher: the same within the table's rounding, except log r 0.88 for 0.89.
- The negatives path (L253-274) has 0 visits on this build. Run with planted negatives (two in CH_rear, two in BT_spawn, plus an NA): it executes, keeps the NA out, and returns counts.
