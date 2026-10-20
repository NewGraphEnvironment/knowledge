## Checklist read

soul `conventions/code-check.md` `## Mechanisms` prose read in full (all fourteen mechanisms, table rows skipped), in the
worktree `soul-75`. Whole of `conventions/readme.md` read in the worktree; diff `soul-diff-r4.patch` (2 commits,
72a52a9 and 72d0c66, 4 hunks of rule bullets and 3 evidence paragraphs).

## What was checked

- **Index lines.** No `###` heading and no rule first sentence changed; every addition is a bullet, a numbered-item
  sentence or evidence.
- **Public safety.** No host, private path, private repo or client identifier in the added lines.
- **Rule sentences against code or other conventions.**
  - Absolute-URL bullet: pkgdown 2.2.0's `tweak_link_md()` rewrites a relative `.md` link to `.html`. A README link to
    `scripts/README.md` therefore becomes `scripts/README.html` on the home page, which the site does not build, so the
    claim holds.
  - Store bullet and item 4's "where the store does not list": the bucket's list request answers 403, and
    `fdis/README.md` is public and names the v2 manifest URL.
  - Item 9's `inst/NOTICE.md` "as in flooded": flooded has `inst/NOTICE.md` locally and on GitHub. It does not contradict
    `pkgdown-publishing.md`, whose root NOTICE is link's choice for a page it publishes.
  - The figure bullets: no conflict with `cartography.md`, which sets checks and states no ship bar. The round-2 fix
    reads as an exception tied to a filed gap in a shared function.
- **Evidence sentences against the sources.**
  - fdis v1/v2 listed, v3 manifest 403, `0299` defaults to v3: findings.md:68-73 and issue #75's corrected line.
  - Plan-review omissions B2 and B3: review-plan.md:8-9.
  - Absolute links: README.md:30, 35, 70.
  - PSCIS "Access Only" in 11 groups, and the NOTICE draft that put `fiss_sites_*` under OGL-BC: issue #76 and
    findings.md:89-93.
  - `inst/vignette-data` FWA geometry moving the notice to `inst/`: findings.md:93 and progress.md:17.
  - The README map is the whole-group panel: vignette lines 429-430 make two `knw_compare_map()` calls, and the zoomed
    one carries the numbered example labels.
  - No scale bar or keymap: R/compare_map.R has no `tm_scalebar` or inset; filed as #77.
  - The caption names Smithers and Houston (README.md:18).
  - The plain-fill fallback without gq: compare_map.R:87-97. The `stopifnot` assertion on gq is at readme_figure.R:11-13.
  - All TRUE. The round-2 fix ("because their names matched" dropped) is in place.

## Findings

- **[low] conventions/readme.md:123** — "Link a file in the repo by its absolute URL" is wider than its reason clause
  ("a relative link to a file outside the site breaks"). Item 1 of "Sections run in a fixed order" prescribes a
  relative `man/figures/logo.png` for the sticker. The figure rule's `man/figures/readme-*.png` is a file "pkgdown
  serves". A reader in another repo who applies the sentence as written could switch those, or a relative link to a
  page pkgdown builds, to `github.com/.../blob/main/...` URLs. Those URLs show `main` rather than the built version, and
  they 404 while a repo is private. A fix is to scope the subject to what the reason covers: "Link a file the site does
  not publish (a script, a research note, `inst/NOTICE.md`) by its absolute URL".

No other issue: every new rule sentence and evidence sentence checked TRUE against its source.
