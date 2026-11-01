# Code-check round 2 (#56 branch, after fix 3f71563)

## Checklist read

- Indexes: `index_code-check.md`, `index_code-check-r.md`, `index_code-check-shell.md`, `index_code-check-spatial.md`, `index_code-check-python.md`.
- `code-check-python.md` in full (no Python in the diff).
- `code-check.md`: prose of the `## Mechanisms` H3s ("A guard that fails toward pass" through "A guard's scope, escape hatches, and remedies" and the rest), "Documentation Staleness", "\"Public bucket\" != listable".
- The diff touches only prose and comments (CLAUDE.md, README.md, research/fdis_export.md, comment headers of scripts/0299 and scripts/0325), so no R, shell or spatial rule applies to code here.

## Verified (no finding)

- The repo reads PUBLIC (`gh repo view`); every new README link and the CLAUDE.md site URL answer 200 with `curl -sL` (github.io 301s to www, accepted); the two article titles match the README link text and the vignettes' `title:`.
- fresh-bc's bucket policy (`PublicReadPrefixes`) grants `s3:GetObject` on `fdis/*` and `knowledge/*`; anonymous GETs of `fdis/README.md`, `fdis/MANIFEST.md5` and `knowledge/fdis/{v1,v2}/manifest.json` return 200; an anonymous list returns 403; `rag/` returns 403. `knowledge/` holds only `fdis/v1` and `fdis/v2`.
- `aws s3 cp --no-sign-request` of the v2 manifest and `fdis_sites.parquet` succeeds, which is what 0299's `PULL=TRUE NO_SIGN=TRUE` path runs (`s3 cp` per key, no list), so 0299:35 is true. 0325:16-17 is true for its upload targets under `knowledge/`.
- research/fdis_export.md "Where it lives" re-checked whole for its new 2026-11-01 date: the prefixes listed, the 26-line `MANIFEST.md5` with no sqlite line, `archive/fdis/` holding the sqlite, `derived/` and the original manifest, and v2's six tables all match the bucket.
- CLAUDE.md's repository line is byte-identical to #133's; `git merge-tree --write-tree` exits 0 in both orders (HEAD with origin/76-pscis-notice and the reverse).
- `public_sweep.py tree`: the only hits are pre-existing false positives (`m1` in tests/testthat/test-tune_score.R, bytes in research/fig/*.png) and the generated conventions; planning/active/ carries no local path or client/project slug.

## Findings

**[medium]** CLAUDE.md:119-121 — the restored licence sentence says PSCIS, EcoCat and bcfishpass files "are #76, to settle before the repo is public". On this branch line 11 says the repo is public since 2026-11-01, and #76's body (edited today) says PSCIS is decided and the rest "settle here, after the flip". After #133 merges (either order, merge is clean) the PSCIS half is fixed but "to settle before the repo is public" survives, so the merged CLAUDE.md contradicts itself and #76 in every order. The only record of the follow-up is the "Owed at the end" item in planning/active/task_plan.md, which goes into the archive with this PR; nothing in #76's body or #133's PR body carries it. Put the owed step in #76's body (or #133's) as a task so it survives the archive, or have #133 drop the clause before it merges.
**Rule:** `code-check.md` "Documentation Staleness"; CLAUDE.md "A pointer to another issue goes in that issue's body, not a comment".

**[low]** scripts/README.md:86 — 0325's row still ends "PUBLISH=TRUE uploads to s3://fresh-bc/knowledge/{thresholds,habitat_grade}/v1/ (after the bucket policy of #56)", the same pre-flip qualifier this branch removed from scripts/0325-publish.R:16-17 ("public only once the bucket policy of #56 is applied"). The plan review's widened grep ("once the bucket", "until then", ...) did not match "after the bucket policy", so task_plan.md's ticked "Re-run the grep for flip wording ... expect nothing that describes knowledge as private or not yet public" is not true of the tree (this line, and CLAUDE.md:120-121, whose "before\nthe repo is public" wraps a line and so escapes a line grep). Drop the parenthetical or say the prefix is public.
**Rule:** `code-check.md` "A fix lands in one of two callers that share a harness"; "Documentation Staleness".

**[low]** Issue #56 body, section 4, the open licences item — it now reads "continues in #76 (PSCIS settled 2026-11-01; flipped with the EcoCat and bcfishpass rows still open, on Al's word) (#76: the PSCIS layers are "Access Only" in the BC Data Catalogue; EcoCat- and bcfishpass-derived files' terms unread), before the flip". The old tail, "(#76: the PSCIS layers are ...)" and "before the flip", was kept beside the new parenthetical, so the item both says the flip went ahead with the rows open and that they settle before the flip, and lists PSCIS as open beside "PSCIS settled". Drop the old tail.
**Rule:** none (CLAUDE.md "Issue bodies get edited, not appended": a body should read correctly top to bottom).
