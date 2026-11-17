# Code-check round 3: #216 branch (86088f67...fe583b25)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped); the 24
  other headings not read (none names a tool or shape this diff uses).
- code-check-r.md: "Read-back shape must match write-back shape", "Cross-function consistency for label/string
  normalization" (2 read, 120 not: the diff has no R; these two describe 0270's read-compare-PATCH shape and its two
  comparisons at different normalisations).
- code-check-shell.md: none read (72 not; the diff adds no shell).
- code-check-spatial.md: none read (94 not; nothing spatial).

## Mechanism

Rounds 1 and 2 and this round share one assumption: **0270 finds and reconciles a group item by rebuilding its
metadata from today's inputs (CrossRef now, plus the row's override now) and comparing that with what the group
holds**, but what the group holds was written from an earlier input state: CrossRef as it was, the override as it
was, or no override. Round 2's (a) was CrossRef's text standing in for the title page; (b) was a field set only on
create while the existing-item path never compared it. The identity key `group_copy()` uses (normalised title,
first creator's last name, year) is made of exactly the fields `OVERRIDABLE` lets a row change (title, creators,
date), and never of the one field the override cannot touch, the DOI. Two comparisons sit at different
normalisations (`group_copy`/`same_work`: alphanumerics, lower case, year only; `apply_override`: exact strings and
`creators_key` tuples). The round-2 fallback adds one more input state to the identity search (CrossRef without the
override) but not the other one that exists in the library: an item written under an older or since-removed override.

Where it reaches, each checked:

| place | holds? | how checked |
|---|---|---|
| `group_copy(item)` keyed by today's override values | no, when the override was edited or removed | probe below |
| fallback `group_copy(crossref_item(...))` | covers "filed before its override" only; runs only while `fields` is non-empty | read + probe |
| title overrides in this file (MacKenzie 2002, Royle & Nichols 2003, Tyre 2003, Dorazio & Erickson 2018, Hsieh 2016) | safe today: each differs from CrossRef only in case or markup, so the fallback's normalised title still matches an item holding any of them | probe: an edited Royle & Nichols title override still resolved to `NQVDVEQA` via the fallback |
| creators overrides (MacKenzie 2002, Royle 2004) | safe today: first last name is the same either side (`_first_last` skips CrossRef's empty organisation author) | `crossref_item` probe: Royle 2004 CrossRef creators `['', 'Royle']` |
| date override (Dorazio & Erickson 2018: held `2018-03`, CrossRef `2017-12-02`) | **no**: year is in the identity key | probe below |
| `apply_override` exact compare after a normalised match | holds: the normalised match is a superset of exact equality, so a patched item is found by the first search next run | live dry run at HEAD: 0 `would` lines (`2 members, 22 additions | exists 22 | member 24 | pdf 24`) |
| `If-Unmodified-Since-Version` across `apply_override`, `ensure`, abstract PATCH | holds: each PATCH follows its own GET in the same row; a concurrent run gets 412, which reads `OVERRIDE-FAIL` and exits 1 | read |
| extra CrossRef fetch in the fallback | holds: a failure raises before any write, so the row reads ERROR and nothing is created | read |
| other collections' additions files | unaffected: only `detection_additions.csv` has an `override` column, so `fields` is `[]` and no fallback runs; `apply_override` costs one extra GET per existing row there | `head -1 data/*_additions.csv` |
| README / CLAUDE.md build list, "0150 reads only items filed directly in a collection" | holds | `collection_keys()` in 0150 (`collectionItems` by collection id, no recursion); keys match `20261116_0270_detection_measure.log` |

## Findings

- **[severity: fragile]** scripts/0270-habitat-collection-build.py:498-506 (`do_addition`'s fallback) and
  `group_copy()` (lines 286-313) — an override that changes a field in the identity key, once edited or removed,
  makes 0270 create a duplicate of an item it filed, in the shared group library. `group_copy()` rejects a
  candidate whose year (or first author) differs, without looking at its DOI, and the fallback only re-searches with
  CrossRef's values, and only while the row still has an override. So the comment's claim at line 502-504
  ("An item filed before its override (or under an older one) carries CrossRef's fields ... never creating a
  duplicate") is false for "under an older one" (that item carries the older override's values), and so is the
  docstring's and README's "patched onto one that already exists". Measured with a dry `do_addition()` on the live
  library (no writes), Dorazio & Erickson 2018 (`UB6D7BRC`, held date `2018-03`, CrossRef `2017-12-02`):
  - date override edited to `2019-03` -> `would create journalArticle`
  - `override` reduced to `title` -> `would create journalArticle`
  - `override` cleared -> `would create journalArticle`

  In each case the title search does return `UB6D7BRC` (same DOI `10.1111/1755-0998.12735`, `same_work` TRUE) and
  `group_copy` drops it on the year. A live run would then create a second item with a second PDF upload, and Better
  BibTeX would give it a suffixed key. Removing an override also never restores CrossRef's value on the held item
  ("Written data outlives the fix"), so the removal is exactly the edit that strands it. Remedy: identify by DOI,
  the one field the override cannot change: in `group_copy`, when the item has a DOI, accept a candidate whose held
  `DOI` equals it (case-insensitive) before the creator and year checks (and, preferably, refuse a candidate with a
  different non-empty DOI). A DOI search does not replace this: `q=<DOI>&qmode=everything` found neither
  Dorazio & Erickson's nor Hsieh's item (probe), so the DOI has to be compared on the title search's candidates.
  A title override whose letters (not just case) differ from both CrossRef's and an older override would still
  escape that remedy; none in this file does today.
  - **Rule:** code-check-r.md "Cross-function consistency for label/string normalization" (identity at one
    normalisation over fields another path rewrites); code-check.md "Written data outlives the fix"; code-check.md
    "A guard that fails toward pass" (a comment stating a property, worded wider than the code reaches).

Probe scripts (read-only, dry): the scratchpad's `r3probe/probe.py`, `r3probe/t.py`, `r3probe/doi.py`; HEAD dry run
log `r3_dryrun.log`.
