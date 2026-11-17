# Enumeration after code-check round 3 (#216)

**Mechanism (round 3):** 0270 rebuilt a work's metadata from today's inputs (CrossRef plus today's override) and
compared it with what the group holds, which was written from an earlier state of those inputs. The comparison keyed
on fields an `override` can change (`OVERRIDABLE`: title, creators, date, publicationTitle, volume, issue, pages).

**Candidate set:** every site in `scripts/0270-habitat-collection-build.py` that compares rebuilt or row metadata
with held state. It was enumerated with
`grep -n "same_work(|_first_last(|_year(|held.get|d.get(|title_of(|OVERRIDABLE|creators_key(|group_copy(|abstractNote"`
at dd605ad7: 11 sites. Verdict per site:

| # | line | site | keyed on an overridable field? | verdict |
|---|---|---|---|---|
| 1 | 317 | `group_copy`: DOI match | DOI (not overridable) | the source of truth; matches first |
| 2 | 319 | `group_copy`: `same_work(title)` | title | reached only when the DOI does not match: non-DOI rows (which take no override) or a held item with no or another DOI |
| 3 | 321 | `group_copy`: first creator | creators | the same; after the DOI match |
| 4 | 324 | `group_copy`: year | date | the same; after the DOI match |
| 5 | 509, 516 | `do_addition`: `group_copy(item)`, then by CrossRef's title | title (search recall) | recall only: a hit is accepted by #1 to #4. Its limit is stated in the comment, docstring and README |
| 6 | 493 | `apply_override`: field-by-field compare | overridden fields | compares the row's value with the held one exactly, so it is idempotent; the dry run after the patch has 0 `would` |
| 7 | 541 | abstract compare | abstractNote | not overridable (refused at line 420), and CrossRef's on both sides |
| 8 | 277 | `has_pdf`: attachment md5 | none | keyed by item key |
| 9 | 631 | `do_member`: `group_copy(body)` for a copy from another library | title, creators, date from the local item | members take no override; a local copy carries no DOI conflict, and the copy's fields are the source item's own |
| 10 | 645-646 | `do_member`: `same_work(title_of(...))` across local hits | local titles | members take no override; it compares two held titles, not a rebuilt one |
| 11 | 407-421 | `OVERRIDABLE` and its guard | — | the list the mechanism is about. `DOI` and `abstractNote` are outside it, which #1 and #7 rely on |

**Outside 0270:** 0150 builds by citation key (`collection_keys()`), which Better BibTeX keeps once set
(`resetKeyOnChange` off). A title patch therefore moves no key, and the store holds no titles. Measured on
`5BP2PEU4` after its patch, the Web API's `citationKey` field is still `hsieh_etal2016iNEXTpackage`.

Nothing in the set compares a rebuilt overridable field with held state as an identity test, except #2 to #4, where
the DOI has already been consulted. Enumeration terminal.
