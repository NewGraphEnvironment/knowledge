## Outcome

Backlog move 9 (#178) held four issues that were each several PRs, so at its gate (Al, 2026-11-18) it split: #132 became
the `track:access` umbrella and #70 the `track:gradient` umbrella, #234 (this branch) and #235 (move 15, #236) their first
pieces, #131 and #71 their members. #234 traced link's access gradients to their sources: a `Fisheries/Fish Passage/
passage_limits` collection (19 held works, 6 added, two duplicate items merged) and a `fish_passage` store built from it,
new evidence variables `leap_height` and `swim_speed` with a guard that keeps them off model parameters, an access grid in
`0280` over the species link models or has paused, 36 evidence rows (data rows 1154-1189), and
`research/access_gradients.md`. The finding: none of the classes is a measured passage limit. 25 % is BC's Fish Passage
GIS Version 1 cut-off, resting on a personal communication about bull trout; bcfishpass has used 15 % and 20 % since 2020
with no documented origin; only 15 % has since been checked against BC fish records (Rebellato et al. 2024). Washington's
manual, which that report cites, gives chum 5 % and pink 12 %, well under BC's 15 %. Grayling, kokanee and westslope
cutthroat have no gradient source. The lesson the reviews kept teaching: read link's facts from link, not from its input
table (link models nine species, pauses KO and RB, and does not model CT or DV, which the plan had taken as 13 modelled).

## Measurement

- Evidence: `0280` exits 0 over 1,189 rows (1,153 before); the access grid reads 11 of 11 species (link's nine modelled and
  two paused). The meaning audit ran six rounds: errors in the rows in rounds 1-3 (4, 3 and 4), none in rows after;
  rounds 4-6 found only prose in the research file's summary, and the loop ended on an enumeration of every claim round
  6's fixes left, beside its evidence (`findings.md`).
- Store: `fish_passage`, 24 documents and 6,325 chunks from 25 keys (Bjornn and Reiser 1991 skipped as a scan with no
  text: #217), built in 7.7 min and pushed (86 MB; the manifest's md5 matches the local file). Query checks: three of five
  hit their expected top 3; the 1998 guidebook came 4th and Cannings and Ptolemy missed the top 5.
- Code-check: three rounds, five findings (no bugs; four fragile and one wrong premise), rounds 2 and 3 each inside the
  previous fix; ended on an enumeration of every link-owned fact the branch states or reads (`review-round3.md`).
- Tests: 429; 5 failures in one test (`test-vignette-data.R`'s ignored sources), from this machine's October 17 evidence
  build, which the branch does not touch.
- Wrong turns kept: the plan's "PSCIS habitat confirmations" for #70 (the confirmation layer has no gradient field; #235
  reads the assessment layer's `STREAM_SLOPE`); the planned `Fisheries/fish_passage` collection (one called `Fish Passage`
  already existed); the reading of Rebellato et al. as the origin of 15 % and 20 % (bcfishpass used both from 2020); an
  abstract-only row for two paywalled papers (no CrossRef abstract, and OpenAlex's are no fallback).

## Evidence

`scripts/logs/habitat/20261118_literature_verify*`; the audit and review rounds in this directory (`audit-r*.md`,
`review-round*.md`, `review-178.md`). The research file is `research/access_gradients.md`.

## Owed

The records review is filed as #238 and the backlog points at it (done before the merge).

- After #217 OCRs Bjornn and Reiser 1991, rebuild `fish_passage` (`ACTION=build ... OVERWRITE=TRUE`, then push) so it holds all 25 documents; until then it holds 24.

Closed by: PR (to follow) for #178 and #234
