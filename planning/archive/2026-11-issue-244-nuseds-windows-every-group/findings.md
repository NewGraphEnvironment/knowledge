# Findings — Backlog move 16 (#244)

## Issue context

**If we do it:** every watershed group with dated spawner records gets NuSEDS spawning windows for every species, set beside the cited timing rows, and `PUBLISH=TRUE scripts/0340-nuseds-build.R` runs as its header documents. **If we never do:** the timing reviews in #243 start without a measured window, and each NuSEDS publish needs its log moved by hand.

Order and state: `planning/backlog.md`. Run `/planning-init <this issue>`. When the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue naming move 16, and leaves it out of the backlog file for the next `/backlog-sweep` to place in another move.

## Batch 25: NuSEDS windows for every group (#240)

**Why here:** the first piece of the timing track (#243); #241 and #242 start from its windows.

**Touches:** `data-raw/timing_nuseds.R`, a new tracked timing log, and `data/life_history_timing.csv` only if the gate allows a NuSEDS-only row.

**Decided at the gate:** the mainstem rule (by reach name, by the group holding the population's spawning reach, or reported apart from the group window), and whether a NuSEDS window alone may become a row where no literature exists yet.

| issue | title |
|---|---|
| #240 | NuSEDS spawning windows for every watershed group and species, with a mainstem rule |

## Batch 26: the publish no longer truncates its own log (#230)

**Why here:** #240 reads the published parquet, so the next NuSEDS publish should run as written rather than by hand, as #174's did.

**Touches:** `scripts/0340-nuseds-build.R`, `scripts/README.md`.

**Decided at the gate:** the log goes outside the repo and is copied in after the run (keeps the clean-tree check whole), or `scripts/logs/nuseds/` is exempt from the check.

| issue | title |
|---|---|
| #230 | 0340: the documented tee into a tracked log makes PUBLISH=TRUE refuse |

Other repos: two open issues in wet read the timing rows (a run of two creeks under the UFRA and COTR chinook windows, and a chinook article on a Bulkley tributary); neither touches these files, but either may rerun when the rows move.


### #240

**If we do it:** every watershed group with dated spawner records gets NuSEDS spawning windows for every species in one pass, beside the cited rows in `data/life_history_timing.csv`, so the literature reviews start from a measured window and say where they differ from it. **If we never do:** each group's timing is looked up by hand when a project reaches it, and the existing rows are never checked against NuSEDS.

## What is known

`data-raw/timing_nuseds.R` (#96) computes chinook spawning windows from NuSEDS for a list of groups: the median start (`START_SPAWN_DT_FROM`) to the median end (`END_SPAWN_DT_TO`, else `END_SPAWN_DT_FROM`) over population-years, with each population's own medians and stream arrival beside it. It ran for UFRA and COTR only.

Run for BULK and MORR on 2026-11-19 (release 2026-06-01, the published `s3://fresh-bc/knowledge/nuseds/v1/nuseds_records.parquet`), it disagrees with both groups' cited chinook rows:

| group | cited row (source) | NuSEDS |
|---|---|---|
| BULK | spawning 08-01 to 09-15 (Gottesfeld and Rabnett 2007) | tributaries pooled 08-15 to 09-10 (28 population-years, 1955–2025); upper Bulkley mainstem 08-15 to 09-15 (33 years, 1953–2020) |
| MORR | spawning 09-01 to 10-07, migration to 09-30 (Bustard and Schell 2002) | Morice River mainstem 08-21 to 09-30 (64 years, 1953–2025); Nanika River 08-21 to 09-30 (45 years) |

Two things the run showed about the script:

- **It drops mainstems.** A population counts for a group only when every Atlas line with its watershed code lies in that group, so the Bulkley and Morice mainstems, the largest records in both groups, fall out of the group windows. UFRA placed its mainstem reach by DFO's reach name ("FRASER RIVER - ABOVE TETE JAUNE"); a rule is needed that holds for every group.
- **It reads a local file.** It should read the published parquet.

The table's convention, that migration ends the day before spawning starts, holds in BULK, UFRA and COTR but not in MORR, where migration runs a month into spawning.

## The work

- Take the groups and species as arguments (default: every group and species with dated records), read the published parquet, and write the windows to a tracked log.
- A mainstem rule, decided at the plan gate (by reach name, by the group holding the population's spawning reach, or reported apart from the group window).
- Compare every existing row of the table with its group's NuSEDS window and report each disagreement, the BULK and MORR chinook rows above among them.
- Whether a NuSEDS window alone may become a row where no literature exists yet, or only beside a cited one, is decided at the plan gate.

Part of #243 (umbrella). Relates to #96.



### #230

**If we do it:** `PUBLISH=TRUE scripts/0340-nuseds-build.R` runs as its header documents. **If we never do:** a publish on a day whose build log is already committed refuses until the log is written elsewhere by hand, as #174's publish of `knowledge/nuseds/v1` had to be.

`scripts/0340-nuseds-build.R`'s RUN line pipes into `tee scripts/logs/nuseds/<yyyymmdd>_nuseds_build.txt`. `tee` truncates that tracked file at launch, so the script's own clean-tree check (`PUBLISH=TRUE` refuses uncommitted changes) sees the log modified and stops before anything is built.

Fix one of two ways: the RUN line writes the log to a path outside the repo and the run copies it in afterwards, or the clean-tree check exempts `scripts/logs/nuseds/`. The first keeps the check whole.


## Exploration (2026-11-20, m1, published knowledge/nuseds/v1, release 20260601)

- The parquet (5,980,132 bytes, sha256 ecc4716f…eaee4, 421,001 rows) is readable over public HTTPS
  (`https://fresh-bc.s3.amazonaws.com/knowledge/nuseds/v1/…`); `aws s3 ls --no-sign-request` is denied (no ListBucket).
- 102,803 rows carry a spawn date (start, end_to or end_from); 5,223 populations. By species: CM 34,047, CO 29,454,
  PK 21,899, CH 8,818, SK 8,567, ST 15, Atlantic 3.
- Against `whse_basemapping.fwa_stream_networks_sp` by watershed code: 4,928 populations on single-group codes,
  189 on multi-group codes (70 named waterbodies; Kitlope, Dean, Morice, Lakelse, Maria Slough, Bulkley upper…),
  72 unmatched. 97 groups hold single-group dated populations.
- DFO's "Conservation Unit Census Sites" CSV (same Open Government record) gives a point per GFE_ID for 97 % of dated
  populations, but the points are not spawning reaches: Morice River → BULK, North Thompson → LNTH, Skeena → LSKE,
  Bulkley upper → BULK, Fraser above Tete Jaune → UFRA. Hence the gate's named-reach table instead.
- `run_type` on dated chinook rows: 1 (2,930), FALL (2,006), SUMMER (46), 2 (4), else NA; sockeye carries named runs
  (EARLY STUART, EARLY SUMMER, LATE, SUMMER).

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `Rscript -e '…' P=x` left `P` unset | env assignment goes before the command: `P=x Rscript -e '…'` |
| `string_agg(…, ",")` in a double-quoted R string: Postgres read `","` as a column | single-quote the SQL literal |
