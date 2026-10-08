# Review: #44 phase 2/3 staged diff, round 3

Reviewed `git diff --cached` (14 files). Unstaged changes ignored. Work done in a copy of the
staged tree (`git checkout-index` into the scratchpad); the repo was not edited.

## Mechanism

The remaining defects come from the same mechanism as rounds 1 and 2: two descriptions of one
thing that nothing makes agree. In this round that means prose (README, comments) describing a
scope the code or data does not have. The two instances below are a README sentence that
contradicts the data a few lines above it, and a code comment that describes as variable-scoped
a rescale that is keyed on unit alone.

## Findings

- **[severity: fragile]** `scripts/README.md:342-343`: "...and the `flow` store from
  `Fisheries/flow` alone (`COLLECTIONS=FWTJDD8Z`); **neither collection feeds
  `habitat_modelling`**." This is false for `Fisheries/temperature`. Line 340 of the same
  paragraph says the `habitat_modelling` store is built from "the species, **temperature**,
  hydrology and Wedzin Kwa collections". The group holds exactly one collection named
  `temperature`, and it is `SW2RXUJC` under Fisheries (checked against a copy of
  `zotero.sqlite`, groupID 4733734). The last `habitat_modelling` build read 9 collections
  (`20261006_habitat_store_build.txt`: "223 keys across 9 collections"), and its log ingests
  Coleman, Chezik, Lusardi and Iacarella PDFs (6 hits). Those are the `Fisheries/temperature`
  members. The #38 archive also records `habitat_modelling` going from 207 to 220 documents
  because the temperature collection grew. An operator who trusts the new sentence will skip
  rebuilding `habitat_modelling` after `0270 --collection temperature` adds members, and the
  store will go stale. Fix: limit the sentence to flow ("`Fisheries/flow` does not feed
  `habitat_modelling`").

- **[severity: fragile]** `scripts/0280-literature-verify.R:340-341` (a comment line this diff
  edits) says the rescales are "m and km for the bridge distance (x1000)". In the code,
  `SCALE$m = c(1, 1e3)` is looked up by `r$unit` alone (`value_in_quote`, line 384). So
  every row in `m` gets the x1000: the 24 `channel_width` rows in `m` today, and also the
  `depth` and `elevation` rows in `m` that `knw_literature_vocab()` allows. The FLOW grid this
  diff adds asks for depth lower limits, so depth rows in `m` are about to enter that
  population. A depth or width value 1000 times a number in its quote passes the gate. The
  behaviour predates this diff, and it is the same mechanism as round 1's x100 note on
  `percent MAD`. Fix the comment or key the bridge rescale on `variable == "bridge_distance"`.

## Claims checked (holds / does not hold)

**scripts/README.md**
- `0270 --collection flow` reads `data/flow_members.csv` and `data/flow_additions.csv`. **Holds:**
  `main()` defaults to `data/<collection>_members.csv` and to `_additions.csv` when it exists,
  and the log shows "26 members, 9 additions".
- `0150 ... STORE=flow COLLECTIONS=FWTJDD8Z`, and `Fisheries/flow` is `FWTJDD8Z`. **Holds:** the
  collection log says "collection flow (FWTJDD8Z) under TRXPJHQE", and in the DB `FWTJDD8Z` is
  `flow` under `Fisheries` with 35 items (26 + 9).
- An additions `pdf` may be a path from the repo root, and those copies sit in the ignored
  `data/rag/pdf/flow/`. **Holds:** `addition_pdf()` takes the non-URL, non-`zotero:` branch;
  `ensure()` checks `%PDF`; `git check-ignore` matches `.gitignore:6 data/rag/`; and the file is
  on disk. A re-run on another machine is a no-op, because `has_pdf()` is checked before
  `find_pdf()`.
- The `flow` store is built from `Fisheries/flow` alone. **Holds:** the log says "34 keys across 1
  collections". "Neither collection feeds `habitat_modelling`" **does not hold** (finding 1).
- `metric` gives the flow statistic for `instream_flow`. **Holds** (`.knw_metric_fits()`).
- `instream_flow` is in m3/s, cfs, `percent MAD`, `percentile` or `percent exceedance`, with no
  model parameter. **Holds:** the `fits` list and the `modelled` check.
- `discharge` is stream size, and the `*_mad_*` parameters belong to it. **Holds** (`mad_off`).
- Depth and velocity are in `cm`, `ft`, `cm/s`, `ft/s`, and bankfull depth is `m bankfull`.
  **Holds, but the list is incomplete:** `m` and `m/s` also fit. The roxygen says so; the README
  omits them. Not a contradiction.
- The FLOW grid is CH, CO, SK, BT, GR, WCT, ST, with need cells for 5 stages met by
  min/range/optimum, depth lower limits for spawning and migration (never bankfull), and
  velocity upper limits for spawning and rearing. SK has no rearing or overwintering flow cell
  and no rearing velocity cell. **Holds:** I ran the FLOW/`meets_flow` block against the staged
  evidence and got 60 cells (7×9 − 3), SK 6, 2 met. The 3 CH depth rows in `m bankfull` meet
  nothing.
- The grid is met "by a value, or by a `none` row naming the bound". **Holds:** `valued |
  kind == "none"`, then the bound filter.

**pkg/R/literature.R roxygen**
- Of discharge and instream_flow, only instream_flow takes a metric. **Holds** (the `stray` check).
- The metric list (instantaneous, daily/monthly/seasonal mean, monthly median, `7day_low`) matches
  `.knw_metric_fits()$instream_flow`, plus `unstated`. **Holds.**
- `percent MAD` fits no other variable. **Holds.**
- `percentile` and `percent exceedance` fit only instream_flow. **Holds:** the test pins the
  gradient rejection.
- "the metric which flows were ranked": a valued instream_flow row must carry a metric. **Holds**
  (`bare`).
- A `7day_low` row gives its return period in the note. **Holds.** Mutation test: replacing
  `low7_bare` with all-FALSE fails `test-literature.R:503`. Restored, 116 literature tests pass.
- A flow need carries no `parameter` or `model_id`. **Holds.**
- Depth and velocity units, and bankfull depth in `m bankfull`. **Holds.**
- `knw_literature_read()` says an instream_flow value needs a metric. **Holds.** The staged
  evidence (686 rows) reads clean.

**scripts/0280-literature-verify.R**
- The header names FLOW, and the run exits non-zero on a flow cell. **Holds**
  (`any(flow$rows == 0)`).
- The FLOW comment (bounds per side, a `none` row by the same bound, bankfull never meets, SK
  skips). **Holds.**
- "percent (and percent MAD) from a proportion (x100)". **Holds**, with round 1's caveat.
- "m and km for the bridge distance (x1000)". **Does not hold** (finding 2).
- Depth and velocity stay in the source unit, and cm/s has no rescale to m/s. **Holds:** `m/s = 1`,
  and `cm/s`, `ft`, `cm`, `percentile` and `percent exceedance` are absent, so they read at scale 1
  (`[[` matches exactly).
- `--invalidate-digital-signatures` alters only the OCR copy. **Holds:** the input is `file`, the
  output `tmp_pdf` in `work`. The installed ocrmypdf 17.4.2 has the option. Note only: an
  ocrmypdf without it rejects the call, and every uncached OCR row would then fail as
  "ocrmypdf failed" on that machine. Nothing checks for that.

**scripts/0270 docstring, and the CSV notes against the logs**
- The docstring's path form ("kept in the ignored data/rag/pdf/"). **Holds.**
- amec: "group copy had no PDF; 0270 uploaded one". **Holds:** the log says "pdf uploaded".
- raleigh 1984: "no PDF in any local library yet". **Holds:** the log says "no-pdf: none local".
- 26 + 9 items, 1 with no PDF, gives 34 PDFs = a 34-document store. **Holds.**

## Verdict

The code is clean. Two prose claims do not hold: one README sentence that contradicts its own
paragraph and the build logs, and one comment whose scope the code does not match.
