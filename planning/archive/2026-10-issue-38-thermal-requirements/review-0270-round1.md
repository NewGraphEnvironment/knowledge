# Review: 0270 `--collection` + member `pdf` column, round 1

## Clean

No issues found.

### What was checked (all read-only)

- `global COLLECTION`: `item_json`, `do_addition`, `find_collection` read it at call time, after `main()` has
  reassigned it. No default argument evaluates it at def time (`ensure.__defaults__ == (False,)`); the argparse
  default is evaluated inside `main()`. No other script imports 0270.
- Lambdas in `do_member`: `local`, `hits`, `want`, `pdf` are locals of the same call and are only called
  synchronously inside `ensure()` within that call, so late binding cannot pick up another member's values.
- `required=bool(pdf)`: a local PDF wins when present. A named PDF that is missing, empty, or not a PDF gives
  `PDF-MISSING` / `PDF-FAIL`, both of which fail the run. `find_pdf` is called only when `has_pdf()` is false, so a
  re-run on a machine without the gitignored `data/rag/pdf/` reports `pdf present` and does nothing.
- `addition_pdf` branches, tested directly: `""` gives None, so `PDF-MISSING`. Before this change, `""` reached
  `z.fetch` and raised (ERROR). Both outcomes fail the run. A relative path, an absolute path (`os.path.join`
  returns the absolute path unchanged) and a missing path all behave as intended. A URL that fails or returns
  non-PDF bytes raises; the per-member `except` catches it as `ERROR`, so it is not a silent pass. The
  habitat_modelling additions hold only `http(s)://` and `zotero:` values, so the new path branch does not change
  their behaviour.
- `data/temperature_members.csv`: 44 rows, all unique, and every row parses to exactly three fields. Every key
  resolves to exactly one non-deleted libraryID-9 item in the z.sqlite snapshot. None is AMBIGUOUS, MISSING or
  outside the group. `coleman_fausch2007ColdSummer`/`...a` swap papers between the personal and group libraries,
  and `same_work()` already guards that case. The two memo PDFs' title pages match their keys:
  `hill_etal2024` is the Nechako 2022b appendix and `hill_etal2025` is the Skeena 2025 appendix.
- Tags: nothing downstream consumes the collection tag (grep of scripts/ and pkg/R), so applying it only to
  created items affects nothing.
- `find_collection` `limit=100`: Fisheries has 8 subcollections, and `temperature` is `SW2RXUJC`.
- The live-run log agrees: 29 added, 15 already members, 2 PDFs uploaded, no upper-case steps.
