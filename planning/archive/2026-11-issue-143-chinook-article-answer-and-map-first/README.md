## Outcome

The chinook rearing article was rewritten so a reader meets the answer and the Bulkley map first, then one before/after
table, then why a nearby river matters as a figure (the fitted chance of a catch by distance to a river, one line per
stream flow, the 1 km allowance marked), then how sure the choice is (the close calls, a dials-by-rule stricter-bar table,
the other checks as a table with each one's direction), and how it was done in a table at the end that links the
methods article. The methods article now opens with what bcfishpass's map was for (choosing where to look first) and
what tuning adds, and holds the one-SE and cross-validation citations that moved out of the chinook article (both
`.bib` files regenerated from Zotero). Prose only: no bundle was rebuilt. What was learned: compressing qualified prose
into short sentences and cells drops the clause that says which build, population or condition a statement holds for,
and the result survives review because its two possible sources agree on most members (the tuning's link build a17e917
against the comparison's config 102762d; the code-confirmed against the nearest-stream placement path; the tuning's
7,659 sites against the comparison's 11,532). The branch review found thirteen defects, most of this kind, over five rounds and
ended on an enumeration of 47 statements; three of them were on main before the branch (the Bulkley sentence crediting
all residual change to the spawning-connection step, the methods article's placement fallback, the unstated
hidden-catch filter).

## Measurement

- Rendered words, reference list excluded (`count.R` over renders of 3140693 and the branch): chinook 2,053 -> 1,800
  (-12 %), methods 4,452 -> 4,746 (+294, the new opening and the moved citations). The forecast was about half; the
  detail moved into tables and a figure rather than off the page, which is what Al asked for.
- Bulkley change by cause, from `bulk_segments.rds`: 1,128.6 km changed, of which 868.0 km dropped below the flow floor
  more than 1 km from a river, 222.1 km gained beside one, 20.3 km from the other limits and 18.2 km from the
  spawning-connection step alone. Main's sentence credited the last 38.5 km to the spawning step only; the new one names
  both, guarded.
- Code-check rounds: 1, 5, 4, 2, 1 findings (13, all fixed); defects inside the previous fix in rounds 2 and 4.

Closed by: PR for #143
