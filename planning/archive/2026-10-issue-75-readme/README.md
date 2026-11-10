# #75: README to the readme convention, with the habitat-threshold work

## Outcome

The README was rewritten in the convention's order: sticker, lifecycle badge, tagline, a plain opening on what
knowledge is and the decision it informs (link's habitat thresholds), the Bulkley chinook rearing map
(`data-raw/readme_figure.R`, the whole-group panel of the article's map), Installation with what runs need and how
to reach the published FDIS data, an example reading `data/thresholds.csv` with its real output, Learn more,
an internal issue's Ecosystem rows, Data and methods, Citation (`inst/CITATION`, `CITATION.cff` and its workflow, from
`/citation-cff`) and License with `inst/NOTICE.md`. DESCRIPTION's Title and Description, the GitHub About and two
`_pkgdown.yml` group descriptions were rewritten with it. What was learned: the issue's own audit was wrong about
`knowledge/fdis/v3` (not uploaded; v2 is the newest published set); the PSCIS layers tracked in 11 groups are
"Access Only" in the BC Data Catalogue, and EcoCat- and bcfishpass-derived files have unread or share-alike terms,
so #76 must settle before #56 makes the repo public; `knw_compare_map()` draws no scale bar or keymap (#77). Every
review round's false claims came from one mechanism: a sentence written from the member of a set in view, then
stated over the whole set, and a fix that rewrote only the flagged clause. Fixes that narrowed held; fixes that
widened (round 1's "each script's header names what it needs") broke. soul's `conventions/readme.md` was amended
with these lessons in soul PR #479.

## Measurement

- README words (`wc -w`): 680 on main, 739 at first draft, 858 after the reviews. The floor is the sections the
  convention requires that the old README lacked (Ecosystem 140, Data and methods 136, Example 121); the reviews'
  growth went to Installation (161) and Data and methods, each addition making a sentence true. link's README is
  595 words, wet's 582.
- Review: plan review 4 blockers and 8 gaps; code-check rounds found 7, 7 and 3 false claims (4 of round 1's
  inside earlier fixes); round 2 enumerated 77 claims, round 3 29 + 22; the loop ended on enumeration. The soul
  amendment: 2 findings (round 2), all 22 sentences true (round 3), 1 low finding in a soul-only round. Seven
  reviewer agents in all, past the usual five.
- BULK accessible chinook km under the two rules: kept 1,376, lost 747, gained 232, neither 2,809.
- `R CMD check`: 0 errors, 0 warnings, 2 NOTEs, both predating the branch. Tests 569 pass.

## Owed

- Add knowledge to an internal issue's Wave list as done once the PR merges
- Learn-more links switch from GitHub paths to the pkgdown site when #56 makes it resolve (note on #56)
- DESCRIPTION `URL`, `inst/CITATION`'s url and `CITATION.cff`'s url name the pkgdown site, which answers 404 until #56; confirm it resolves after the flip
- #76 (PSCIS Access Only, EcoCat terms) settled before #56's flip; then update `inst/NOTICE.md`
- #77 scale bar and keymap on `knw_compare_map()`, then rerun `data-raw/readme_figure.R`

Closed by: PR #78
