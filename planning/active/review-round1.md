# Code check round 1: #284 branch (coho store, upper Fraser coho records)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms` (all 14), table rows skipped; under "Rules that stand
  alone" and Security, headings only from the index (none other applies to this diff).
- code-check-r.md, by heading: "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests";
  "Postgres row order is never fixed unless the query fixes it, ..."; "`ifelse()` with an all-NA test returns a
  logical vector, ..."; "`paste()` with a zero-length argument returns length ONE, not zero"; "`strsplit()` drops a
  trailing empty field, ..."; "`match()` treats NA as a matchable VALUE, ..."; "`data.frame()` recycles a scalar
  against a zero-length column"; "`unlist()` prefixes a `split()` group's name, ...". About 140 other headings not
  read (no tool or shape of theirs in the diff).
- code-check-spatial.md, by heading: "FWA main flow is not edge type 1000 alone"; "A relation between FWA watershed
  codes is not a place"; "FWA `upstream_route_measure` misses the next segment's start"; "FWA lookup area follows
  watershed codes, so side channels get the river's"; "A Freshwater Atlas main stem's downstream end lies on the
  receiving river's centreline, not at the confluence". About 120 others not read.
- code-check-shell.md: none read in full (the only shell in the diff is the RUN comment's `set -o pipefail ... | tee`,
  which the index line for pipefail covers); about 110 headings not read.

What was checked against what: every coho_additions.csv report row against its PDF's title page and "Correct
citation" line (pdftotext); each DOI row's PDF first page; every quote in research/coho_upper_fraser.md verbatim on
the cited printed page (Westworth: PDF page 40); every table row against the log CSV; placements, group codes and
stream codes against bcfishobs.observations and fwa_stream_networks_sp (read-only); link 0.78.1's default
wsg_species_presence.csv for the range claims; NuSEDS v1 for uncoded or mainstem coho populations; cred 0.8.1's NEWS
and cred#48's state for the 0150 floor; `git grep cred#48`; the tracked logs for home paths and repository names.

## Findings

- **[bug]** data-raw/coho_upper_fraser_records.R:57-63 (`upstream()`), and so research/coho_upper_fraser.md:37, :97
  and every count built on them. A point whose code is the Fraser's bare `100` is judged by its
  `downstream_route_measure` against the Fraser main stem's measure at the Quesnel mouth (645,065 m), but a record on a
  Fraser side channel or connector carries `wscode` 100 on a *different* `blue_line_key`, whose measure runs from 0 on
  its own line. Such a record is dropped wherever it lies. One coho record is lost this way: `obs:c51f92359e`
  (FISS survey_id 7503424, 2004-01-01, gazetted SWIFT RIVER, the 2004 consultative draft recovery strategy, COTR),
  on blue line 355992659 (edge types 1350/1450, `localcode` 100.478686, the Cottonwood confluence, 53.12 N against
  the Quesnel mouth's 52.97 N), measure 114 m. It is upstream of the Quesnel mouth by the script's own rule and is
  the fifth 2004 entry #284's body named (findings.md line 27; survey ids 7501690 to 7503426 include it).
  findings.md line 103 explains the fifth away as the 1986 hatchery pers. comm. (`obs:83623c516c`), which is a
  different record. So the asserted "24 bcfishobs records" should be 25, the research's "30 records ... 12
  compilations" should be 31 and 13, and "The 2004 entries" lists four of five. The same test drops FDIS visits on
  Fraser side channels upstream of the Quesnel (42 visits on wscode 100 off the main blue line, 41 of them in TABR,
  localcodes 100.578734 and 100.580963; none caught coho, so only the printed 7,813 moves). Decide a bare-`100` point
  by its `localcode` (second part above 458399, or the Fraser's own blue line and measure), not by a measure taken on
  another line. The asserted counts then fail and must be re-set; a reader acting on the research gets a record set
  that silently omits one of the compilations it judges.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check-spatial.md "FWA lookup area follows watershed codes, so side channels get the river's"

- **[fragile]** research/coho_upper_fraser.md:5 — the header's log path is
  `scripts/logs/coho/20261127_upper_fraser_records.*`; the files are `20261127_coho_upper_fraser_records.*`. The
  "Produced by" pointer, the only route from the verdicts to the record ids' source data, names files that do not
  exist.
  - **Rule:** none

- **[fragile]** research/coho_upper_fraser.md:30-31 against :71, :79, :80-81, :126-128 — the verdict definition says
  "Where the report is not held, the verdict adds that the report is not held", and Gaps says the reports behind
  Triton's 2014 Ahbau survey and Marlim's 2018 FRAN inventory are not held (and Triton's 2010 report was not
  retrieved), yet `obs:94e4f8d30d`, `fdis:172649_1_1`, `obs:026afad5a5`, `obs:785aff6b11` and `obs:02652e805d` are
  plain "survey". Gaps' "The reports behind six survey records are not held" then lists six reports that sit behind
  eight records (`c1262aeb8a`, `c3caf22396`, `7a98d34717`, `bb1787d1bf`, `94e4f8d30d`, `fdis:172649_1_1`,
  `026afad5a5`, `785aff6b11`). Either the FDIS-database records count as the record saying so (then say that in the
  definition) or their verdicts take the suffix; and "six reports", not "six survey records".
  - **Rule:** none

- **[fragile]** research/coho_upper_fraser.md:60 — "Places run from the Quesnel's mouth upstream", but within the
  Nechako the table runs Dahl (069486), CHES (528889), Greer (483452), Micks, the NECR mainstem, FRAN (374775), STUR
  (179319), STUL; by the network the Stuart (179319) comes before FRAN, Greer and CHES, and CHES last. Within BLAR the
  Baezaeko tributary (500560.367242) precedes the West Road mainstem rows. Either order the rows by code or drop the
  sentence.
  - **Rule:** none

- **[fragile]** data/coho_additions.csv:20 — the Bradford, Taylor and Allan (1997) row's `why` calls it "a BC
  synthesis"; the paper's abstract: "We assembled a database of 474 annual estimates of smolt abundance from 86
  streams in western North America". A tracked description of a source that says otherwise.
  - **Rule:** none

- **[security]** scripts/logs/rag/20261127_push_coho.log and scripts/logs/rag/20261127_push_habitat_modelling.log
  (excluded from the review diff, but tracked on the branch) — each holds the bucket's whole merged manifest, which
  names a private repository's name (a PRIVATE repository; `gh repo view` reports
  visibility PRIVATE) with its branch and head SHA, twice per file. CLAUDE.md: "a committed push log keeps only its
  own store's entry", and the public-repo rule bars naming private repositories in tracked files. `origin/main` holds
  no copy of that name in `scripts/logs/rag/`; the earlier push logs (20261121, 20261125) keep only their own entry.
  Trim both logs to the coho and habitat_modelling entries before the branch is pushed or merged (if already pushed,
  the name is in the branch history GitHub serves).
  - **Rule:** none

Checked and clean: every additions row's title, creators, date, report number, institution, place, pages, bookTitle
and publisher against its title page or citation line (Sandercock 395-445, UBC Press, Vancouver; the CSAS numbers,
months and places; COSEWIC 2002's citation); each DOI is the paper its `why` names (f75-086 Bustard & Narver, f00-030
Solazzi, f82-172 and f82-173 Peterson, f01-091 Sharma & Hilborn, the TAFS 126:49 DOI Bradford et al.); all five
research quotes verbatim on the cited pages (Irvine 2001 p. 12, Decker & Irvine p. 21, Arbeider p. 25 and 28,
Westworth PDF p. 40); every table row's group, place and date against the log; 15/12/2/1 against the table as
written; Kuzkwa River in LTRE and Kazchek Creek in MIDR, both in the Stuart system; Slade Creek
(100.594120.845867.799925) joins Tregillus Creek (100.594120.845867), where the record lands; Ocock Lake 1,255.8 m
from a stream; only WILL and BOWR records lie above the Nechako (second code part > 567134); link's default presence
(CO in BOWR, WILL; not in FRAN, STUL, STUR); Dahl Creek sampled September 1996 in reach one, the Province's date
December 1998; no NuSEDS coho population on the bare Fraser code upstream of the Quesnel and none uncoded with an
upper Fraser name; 0150's `< "0.8.1"` floor matches cred 0.8.1's NEWS (cred#48 closed) and `git grep cred#48` finds
no remaining rebuild-after-update instruction; the update log's 414 -> 463, 49 added, 0 dropped and the build's 53
documents; issues #228, #285 and #286 are the ones the text names; no home path, host or credential path in the new
files (the `/tmp/Rtmp*` lines are R session temp dirs).

index, diff and changed files read from file
