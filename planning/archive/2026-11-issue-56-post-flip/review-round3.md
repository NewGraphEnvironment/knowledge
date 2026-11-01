# Code-check round 3 (knowledge branch, #56)

## Checklist read

Indexes of code-check.md, -r, -shell, -spatial, -python; code-check-python.md in full; code-check.md's prose under
`## Mechanisms` (with "A guard that fails toward pass", "A fixture that cannot reach the failure mode" and "One fact
derived twice" read closely) and "Documentation Staleness". The diff touches no Python, shell, spatial or R code
paths (two R files change comments only).

## Mechanism

Rounds 1 and 2 share one shape: a fact (the repo's and the bucket's visibility, and what #76 still holds open) is
stated by hand in several homes (tree files, the bodies of #56, #76 and link#346, #133's branch and PR body), and
each home is edited separately. The check that ended round 2 enumerated one of those homes (tracked text files), so
it could not see the others, and the list of what is open was copied from an earlier restatement instead of from
the file that holds it (`inst/NOTICE.md`, "Terms not yet settled"). Two lists happened to agree until one grew.

Checked across every home: repo public 2026-11-01 (all agree; `gh repo view` PUBLIC); PSCIS kept tracked (#56,
#76, #133 agree; the tree follows when #133 merges); thresholds not yet uploaded (link#346 "to be published",
`scripts/README.md`, `scripts/0325-publish.R`, #56 agree; anonymous GET of `knowledge/thresholds/v1/manifest.json`
is 403 while `knowledge/fdis/v2/manifest.json` and `fdis/README.md` are 200, which under a GetObject-only grant
means absent); `research/fdis_export.md`'s two 200s reproduce; #58 is the merged clean-up PR; `git merge-tree`
with `origin/76-pscis-notice` is clean and #133's CLAUDE.md keeps "to settle before the repo is public" as #76's
task says. Two disagreements and one split spelling remain:

## Findings

**[medium]** Bodies of #56 (licence item), #76 (closing line and the CLAUDE.md task) and PR #133 — each says the
repo went public "with the EcoCat and bcfishpass rows still open". `inst/NOTICE.md:47` (and line 54 on #133's
branch) also lists **Modelled flows** (PCIC's, through wet) on `inst/vignette-data/bulk_segments.rds` under "Terms
not yet settled", and #76's own Problem lists it; it is the one unsettled source that installs with the package.
#76 has no task for it, so nothing tracks it. The open list was restated from `CLAUDE.md:118-120`'s three-source
sentence (PSCIS, EcoCat, bcfishpass), which predates the PCIC row; that sentence has the same omission, and #76's
task to rewrite it should add the flows. Fix: derive the list from NOTICE's section; add a PCIC task to #76.
**Rule:** code-check.md, "One fact derived twice" (expected set from the producer the subject cannot influence);
agent-operations §3, "Documents that share an ancestor corroborate nothing".

**[low]** #56 body, Status: "the post-flip pass (links on the public site, the last pre-flip wording, link#346)
closes this issue". After this branch `CLAUDE.md:120` still says "to settle before the repo is public"; it moved to
#76, it was not removed. Say the last pre-flip sentence continues in #76 (as the licence item already does).
**Rule:** code-check.md, "Documentation Staleness".

**[low]** `README.md:30,68,70,74` link the site at `www.newgraphenvironment.com/knowledge/`, while `_pkgdown.yml:1`,
`DESCRIPTION:22`, `CITATION.cff:38,45`, `CLAUDE.md:12`, `man/knowledge-package.Rd`, `data-raw/vignette_method.R:428`
and the research files name `newgraphenvironment.github.io/knowledge/` (which today 301s to the www host; all
four README targets answer 200). Not false now, but the site is one fact with two spellings, and the README's
breaks alone if the org's custom domain changes. Use the `_pkgdown.yml` URL in the README, or accept and note it.
**Rule:** code-check.md, "One fact derived twice".
