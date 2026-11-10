# Progress — Backlog move 3 (#172)

## Session 2026-11-09

- Plan-mode exploration — phases approved by user (gate: #20's data question to wet#5; BDA3 only; #20's rows kept)
- Created branch `172-backlog-move-3-zotero-fix-what-the-group` off origin/main
- Scaffolded PWF baseline from issue #172 with approved phases
- Next: start Phase 1
- Phase 1 (#168): `0153`'s `api_key()` reads `ZOTERO_API_KEY`, else `ZOTERO_API_KEY_FILE`'s first non-blank line.
  Seven branches probed by import (var set; var blank + file; file only; empty file; blank-lines file; missing file;
  neither), 0270 reads the file key through `z.API`, and `data-raw/zotero_copy_check.R` PASS (its child still uses the
  placeholder variable).
- Phase 2: cred 0.1.0 → 0.7.0 (pak). `crd_store_update(store_path, collection | citation_keys, library)` drops any
  document whose source no longer resolves, so `0150 ACTION=update` resolves the same `COLLECTIONS` as a build and
  passes the union; it refuses without `crd_store_update()` in cred or without the local store. Guards probed
  (bad action, missing store, missing COLLECTIONS).
- Plan review (Plan agent) in `review-plan.md`: two blockers on `ACTION=update` (narrow key lists and harvest stores
  wipe documents). `0150` now refuses a store with any `<EXTENT>__<reportId>.pdf` origin (probed on a fake store) and
  prints counts and drops; `api_key()` reads a BOM file and refuses undecodable bytes (probed). Plan reordered: every
  library write in Phase 3–5, then one store pass with Zotero quit (Phase 6). Tredger's scan is replaced, not kept.
- Phase 3 prep: `0275` and `data/zotero_attachment_verdicts.csv` (31 rows: #151's four, #126's 27). Sitting verdicts
  settled by reading the files: banner part-1 copies have identical text (keep 9S2ERUGD); Thompson's 2017 copy
  T7SVJCFC is the fuller; the Alsea scan P9ZV6GDE is George W. Brown's "The Alsea Watershed Study" (OCR). Org-wide
  key search: neither banner key cited (GitHub index + 196 local checkouts); abbott and mccarthy are cited
  (safety_plan_template, fish_passage_skeena_2024_reporting) and keep their report PDFs. Tredger OCR: 49 pp,
  7,531 words. Dry run: 31 rows, all `would`, 0 failed; `download()` checked against WZ896C9Y's md5.
- Phase 4/5 prep: `0270 --parent top` (statistics is top level, LP4R4VYR); `addition_item()` takes a book's
  publisher, edition and ISBN, and writes a comma-less creator as one-field (organization) name; `addition_pdf()` names
  a PDF from a `/content` URL `.pdf` (0153 types uploads by name). `statistics_{members,additions}.csv` (8 members, BDA3
  from the authors' site): dry run, only BDA3 would be created. `flow_additions.csv` + Iacarella et al. 2025, the 2022
  EFN Policy and Schnorbus 2020 (UVic copy; PCIC's URL serves HTML): dry run, those three would be created.
  Regression dry runs: habitat_modelling, temperature unchanged (no `would`).
- The DFO document cites Weller et al. 2023 (library: weller_etal2024Streamthermalscape, the same paper) and Isaak 2016
  (NorWeST data archive; library holds Isaak 2017's paper). Its flow and temperature scores are continuous 0-1, no
  threshold, so its rows are `qual`; the EFN Policy holds values (MMD >20 % lt MAD low, 10-20 moderate, <10 high flow
  sensitivity, p. 8).
- Hand-offs: wet#162 filed (method differences, benchmark for wet#3 and wet#6); wet#5's body asks the Province about the
  Foundry/DFO layers. #95's items 2 and 3 filed as #185 and #186 (split from move 3, not in backlog.md); #139's pointer
  moved to #186; #95's body names both.
- Live writes (Al approved the dry runs, 2026-11-10): `0275` 31 rows, 0 failed; the dry run after shows 0 not done.
  `0270 --collection flow` created N3I48AN2 (DFO 2025/013), KE758PAG (EFN Policy 2022), 3JTBEP9W (Schnorbus 2020);
  `0270 --collection statistics --parent top` created 5RKUXXZS (BDA3). Each has a stored PDF; dry runs after show no `would`.
  New items from splits: A2EZNEAP (eDNA template), 3237KHR4 (Skeena 2006 valuation), 5KC9J83I, CZ6W42IB, CXPP2JUK
  (Alsea documents), 6EH9XCNQ (Comeau 2016 map). Changed attachments:
  attachments added:   5B62CMEX 9HNJIITR PGU736V9 BE4E6T9F 22AP9QJB 7PK9GSJM ZXXDT3DI 43WP56GA ZKGXNRGU BNSBUZ9M
  attachments trashed: XETIXEM2 VS4P4TG6 KFWVRH6I D6IMPRF9 ULAD6928 W5C8VQAJ YJZS6RUN GEX7LH26 H2HE7YEY JVVM3KXV 89FYJDGQ CB36ZIRY GENI8XJ8 NKDRE6Q7 HLV2RWZD RMXSJVKB DPH84ENN EPPHL4VG YJZLRJ5I 33222K2G AGU7Y3I4 GKL97JYY REXYEU92 Z64VC6DT RX63AU5F WZ896C9Y 2DVK6KM4 Y6K63TML BFM4PF4I 7W7IW7RG FEJRDH9D VBCPBATA 9S2ERUGD B7V8RRZQ 354HGUEY PUEQYI5E W8HLSVEI 4Z5EMI6B PEVEUP6I EI8Z6FME K4WGW3Q7 7H5GK2IR 9Q9GZ5WU B7ZEGMZQ E27ZSTHD K28A3DMR IBHTXREZ
- Sync confirmed: every new item keyed (`iacarella_etal2025Geospatialindicators`, `ministryofforests2022Environmentalflow`,
  `schnorbus2020VICGlacier`, `gelman_etal2013Bayesiandata`, and the six split items), all 14 new PDFs on disk,
  `KSCZP9JS` kept its key after the retitle. Sturgeon dry run: 69 additions exist, no `would`. The DFO document added
  to `Fisheries/temperature` (feeds `habitat_modelling`).
- #20's evidence rows: data rows 1146-1151 (EFN 20 % and 10 % class edges, rearing and overwintering, grounded on the
  policy's own citation of Ptolemy & Lewis's summer and winter rearing flows, pp. 7-8; DFO's low/high-flow and August
  temperature metrics as `qual`). First self-audit fixed: the class edges' sides (20 is the low class's lower edge),
  "names no species" (the policy speaks of fish), and two notes paraphrasing past the text. `0280`: 1151 rows verified.
- Store pass prep: pulled every store md5-verified. Trashed attachments held: `bull_trout_grayling` and
  `habitat_modelling` (Bottoms EPPHL4VG, YJZLRJ5I), `flow` (YJZLRJ5I); no harvest store holds any. The harvest guard
  first refused `habitat_modelling` for `storage/BCF7RZT9/PINE__56963.pdf`, a real Zotero attachment: narrowed to
  harvest-named documents outside Zotero storage (refuses `peace`'s four temp-dir MACK documents and all of
  `fraser`). Zotero quit (WAL 2.0 MB -> 0) for cred#45; Ollama answering.
- Code-check round 1 (`review-round1.md`): 2 bugs, 2 fragile, all real and fixed. `0275` counted a fileless
  named child as the merged or replacement file (now refused, `stored()`); organizations with a comma became persons
  in 0270 and 0275 (braces mark a one-field name; KE758PAG, the 2022 EFN Policy, was filed that way and is patched
  through a 32nd verdicts row; flow dry run still matches it); 0150's update guard now refuses any origin outside Zotero
  storage, cred's own test (refuses fraser, peace and pine whole; the updated stores have none); `0275` checks the
  merged PDF (`qpdf --check`, page count). The ten PDFs already merged were checked: all pass, each with exactly its
  parts' pages.
- Pushes: `statistics` in the bucket on retry (16:51Z); `habitat_modelling` retrying over the hotspot.
- Stores done: `habitat_modelling` (754 MB over the hotspot) and `statistics` pushed on retry; all six reconnect with
  md5 matching the manifest: sturgeon 84 docs, flow 43, temperature 53, bull_trout_grayling 35, habitat_modelling 264,
  statistics 4. KE758PAG synced as a one-field organization and kept `ministryofforests2022Environmentalflow`.
