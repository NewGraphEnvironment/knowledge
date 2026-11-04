# Progress — Chinook article: answer and map first, the river effect as a figure, detail in tables; methods article opens with what the map was for (#143)

## Session 2026-11-03

- Plan-mode exploration — phases approved by user
- Created branch `143-chinook-article-answer-and-map-first-the` off origin/main (3140693; main moved from 7d6712e during the gate with #141's work, none of it touching the articles or their bundles)
- Scaffolded PWF baseline from issue #143 with approved phases
- Next: start Phase 1
- Phase 1: methods article opens with what the map was for (bcfishpass screening, the Province's access model, the two pinned parameter files) and what tuning adds; the one-SE and cross-validation citations moved into "How are two rules told apart?". The Data Catalogue record is linked, not yet cited: its Zotero item comes in Phase 3.
- Phase 2: chinook article rewritten in the approved order. Opening states the answer with link and bcfishpass cited; the Bulkley map follows; "What changes?" is one table with the catch rates from the comparison's checks; the river effect is a figure (lines per flow over distance, dashed 1 km allowance, small flows grey beyond it) opening with bcfishpass's order-5 exception; the stricter bar is a dials-by-rule table with changed cells bold and the counts in a note; the three other checks are a table with each one's direction; the methods sit in a literal markdown table at the end, keeping the register's two placement phrases on one line each. kableExtra added to Suggests. The longer-ladder history is cut, and CLAUDE.md now says the article no longer quotes `grad_ext`.
- Rendered from the source tree: every citation resolves, `test-settings-register.R` 272 pass and `test-vignette-data.R` 193 pass, the three register phrases resolve to 500, 200 and 1.96. Source prose 1,683 -> 1,236 words; the methods table (moved, not cut) sets the floor.
- Al's review of the local build (2026-11-04): the opening's habitat percentage, catch rates and stricter-bar sentence moved out (the "What changes?" table and "How sure are we?" carry them; a pattern sentence now leads the table); the methods article names New Graph's set and links the other organizations' sets by bcfishpass's parameters folder, without naming one.
- Zotero restarted (2026-11-04); `data-raw/vignette_bib.R` rewrote both bibliographies: the five statistics entries moved from `chinook_rearing.bib` to `habitat_thresholds.bib`, 56 lines each way, nothing else.
