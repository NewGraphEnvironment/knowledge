# Drafter notes: `ps` (CH, CO, ST), thermal rows for #38

114 rows in `draft-ps-evidence.csv`: CH 29 valued + 3 `none`, CO 46 valued + 5 `none`, ST 27 valued + 4
`none`. Merged with `merge_drafts.py ps`, every row (data rows 511-624) passes `0280`
(`verified_text` 392, `verified_table` 178, `verified_ocr` 24 across the whole table) and every CH, CO
and ST cell of the `thermal:` grid has a row. The only empty cells left are BT and WCT (the `tc` family).

## How the search was done

- The #38 temperature collection: 44 members (`data/temperature_members.csv`). Every member with a PDF in
  the group library (37) has extracted text in the scratch `txt/`; the seven without text are the two
  Bear et al. items (no PDF), McMahon et al. 2007 and Piotrowski & Napiorkowski 2019 (no PDF in the
  group), and three data or software items. All 37 were grepped for coho / Chinook / steelhead with a
  temperature, and for degree-day wording (degree-days, temperature units, thermal units, ATU).
- The `temperature` ragnar store was queried for degree-days to hatch and to emergence (coho,
  steelhead, Chinook) and growing-season degree-days for juvenile salmon. It returned nothing the grep
  had missed.
- Read for CH/CO/ST: Richter & Kolmes 2005 (all of it), Bjornn & Reiser 1991 (OCR, plus the scanned
  pages for Tables 4.3 and 4.8 rendered and looked at), Raleigh et al. 1986 (adult and embryo sections),
  Sauter et al. 2001 (Tables 2-4), Roberge et al. 2002 (coho, rainbow/steelhead and Chinook accounts),
  Hasnain et al. (CCRR-17: definitions and appendix tables), Lusardi et al. 2020, Iacarella et al. 2024,
  Eaton & Scheller 1996, Cooney & Holzer 2006, and Bustard & Schell 2002 (Morice). Brett 1971 is about
  sockeye. Iacarella & Weller 2024, Weller et al. 2024, Isaak et al. 2017, Gilbert et al. 2022, Martins
  et al. 2022 and O'Connor et al. 2025 hold no CH/CO/ST temperature limits or degree-days.

## Conventions I used (please check)

1. **`kind` for laboratory tolerance limits.** UILT, ILT, CTmax, "upper lethal", "growth ceases above"
   have no kind of their own. I used `expert` (the review states them as limits); `max_obs` only where a
   field study reports the highest temperature fish were seen to tolerate (Bjornn 1978 Idaho stream,
   Lusardi's warmest reach, Eaton & Scheller's FTDMS, as the existing CH Eaton row does).
2. **A recommended span used as a limit** ("a 7-DAM of 14 to 17 C to fully protect rearing", "13.5 to
   14.5 C") is one `max` row at the lower end, with the span in `note`. That follows the existing CH row
   for Hicks's 20-21 C migration limit (value 20). If the table should hold the upper end, or both, these
   rows change: CH 9, 11, 13.5, 23.8; CO 9, 14, 22, 27; ST 11, 13.5, 16.
3. **Richter & Kolmes Table 1 applied to coho and steelhead.** The table has no species column; it gives a
   separate row only for steelhead smoltification, and pp. 38-39 then discuss each criterion species by
   species (coho: "beyond their optimal temperature but within the upper end of their acceptable
   incubation range"; steelhead spawning and early fry development "within the range protected by the
   10 C weekly mean"). The existing CH note already says the criteria are for all four species. I added
   CO and ST rows for both columns (13 C 7DADM / 10 C weekly mean for spawning and incubation, 16 / 15 for
   rearing) and the weekly-mean rows for CH, whose 7DADM rows were already there.
4. **"Pacific salmon" (Richter p. 27, 5.6-12.8 C spawning)** is entered for CH and CO only. The review
   names "salmon and steelhead" separately throughout, so I did not extend it to steelhead.
5. **Cooney & Holzer's WMAT > 22 C** ("could potentially limit or exclude salmon and steelhead
   production") is entered as an `expert` rearing max for ST and CH. The TRT applied it only to the
   downstream extent of spring Chinook spawning, which the existing CH `param` row already records; the
   new rows are the stated criterion, and the note says how it was used.
6. **Lusardi et al. "mean T"** is the mean of daily averages over a 63-day study, 9 July to 9 September,
   so `summer_mean`. Their MWMT is `mwmt`.
7. Spring-, fall-, summer- and winter-run Chinook are named in `note`, with `life_history_form` blank, as
   in the existing rows.

## Per species, per cell

### CH (Chinook)

- **temperature / spawning, upper and lower**: already filled by existing rows. Added: Richter Table 1
  10 C weekly mean; Pacific salmon 5.6-12.8 (p. 27); Hicks 7DADM 11-12 C at fertilization, recorded as
  spawning (p. 30; arguably incubation); Hicks's review, maximum spawning temperature below 14.5 C (p. 31);
  fall/summer 5-13.4 DAT (Richter p. 31 and Sauter Table 4, both citing Raleigh); Raleigh: 4.4-18 C
  spawning (p. 6), >12.8 C raises prespawning mortality of females (p. 6), spring run 12.8 to 4.5 C and
  fall run 13.4 to 5.0 C (Chambers 1956, p. 8), winter run 5.9-14.2 C (p. 9).
- **temperature / incubation, upper and lower**: already filled. Added: Table 1 weekly mean 10; fall
  Chinook 10-16.7 and 10-12 (p. 29); constant >12 C cuts alevin survival (p. 29); constant >9-10 C
  (p. 30); 1-DM 13.5-14.5 C (p. 30); Raleigh >16 C very low survival (p. 8), 4.5-12.8 C for the first
  2-3.5 weeks (p. 9; the scan has the signs >= and <= that the text layer renders as "~"), a constant
  15 C killed all embryos (p. 9).
- **temperature / rearing, upper and lower**: already filled. Added: Table 1 15 C weekly mean;
  McCullough's 15.6 C standard; Burck's live-box mortality at daily maxima of 23.8-25.5 C (p. 31); Bjornn
  1978 Idaho stream, daily maxima up to 24 C with fish thriving (B&R p. 114); B&R Table 4.8 lower lethal
  0.8 C (ILT); Cooney & Holzer 22 C WMAT. Optima added: 10.0-15.6 and Hicks's 14.2-16.8 C 7DADM.
- **degree_days / incubation (to_hatch)**: Raleigh p. 4, 900-1,000 thermal units from fertilization to
  hatching (Seymour 1956), base 0 C.
- **degree_days / emergence (to_emergence)**: `none`. B&R p. 107 gives Heming's (1982) estimates of
  emergence at 192 d at 6 C and 85 d at 12 C. The products (1,152 and 1,020) are not printed, so not
  entered.
- **degree_days / rearing and overwintering (growing_season)**: `none`.

### CO (coho)

- **temperature / spawning, upper and lower**: Richter: Bell 1973 7.2-15.6, Bell 1991 DAT 10-12.8,
  Reiser & Bjornn and Brett 4.4-9.4, Hicks 4.4-13.3 (p. 33); Pacific salmon 5.6-12.8 (p. 27); Table 1
  13 C 7DADM and 10 C weekly mean. Sauter Table 4 10-12.8 DAT. Hasnain appendix 4.4-7.7 C (Wismer &
  Christie 1987). B&R p. 92: most BC coho spawned below 10 C (mode 5-6 C).
- **temperature / incubation, upper and lower**: Richter p. 32: acceptable egg survival 1.3-10.9 C (the
  lower-cell row); alevin and fry acceptable up to 10.9 C; a constant 12 C as the upper threshold for
  optimal development; more mortality above 11 C; egg mortality at 14 C; Hicks 7DADM 9-12 C for the
  pre-emergent stages (printed under the rearing heading, recorded as incubation); Table 1. Optima: best
  egg survival at a constant 2.5-6.5 C, alevins and fry at 4-8 C.
- **temperature / rearing, upper**: Richter: upper lethal 25.8 C, growth stops above 20.3 C, Hicks 7DADM
  14-17 C, Sullivan 7DADM 16.5 C, fry UILT 25.0 C, CTmax 28.2 / 29.1 / 29.2 C in three Washington
  populations, constant 22-23 C lethal (Hicks), Table 1. B&R Table 4.8: ILT 26.0 C, CTM 28.8 C. Lusardi:
  thermal stress from 16 C (Brett 1952), CTmax 27-29 C, positive growth at MWMT 24.0 / mean T 18.1 C
  (`max_obs`), Stenhouse's instantaneous maximum of 15.5 C for the Shasta, ~16 C constraining growth.
  Iacarella 24 C 7DEC (same quote as the CH row). Eaton & Scheller 23.4 C MWAT.
- **temperature / rearing, lower**: `none`. B&R Table 4.8 prints a coho lower lethal of 1.7 C (seen on
  the scan), but the OCR the gate checks against reads it as "17", so the value cannot be in a quote.
  This is the one place in my cells where the source has a value the table cannot hold. Konecki et al.
  1995 (via Richter p. 33) give preference ranges of 7-21 C and 6-16 C in a gradient; those are where
  fish chose to sit, not a lower limit, so not entered.
- **degree_days, all four cells**: `none`. Roberge p. 64: "At 2.2°C, eggs take 137 days to hatch"
  (Sandercock 1991); B&R p. 106: coho need the least time to 50% hatch among Pacific salmon (115-150 d at
  [a dropped temperature] and 35-60 d at 12 C across species). No degree-day total is printed.

### ST (steelhead)

- **temperature / spawning, upper and lower**: Richter p. 36, Bell 1991 DAT 10-12.8; Sauter Table 4, the
  same value; Table 1 13 / 10 C; Morice (Bustard & Schell p. 67) mainstem spawning at 3-7 C and
  tributary spawning at 8-12 C (Envirocon 1984), the only BC values.
- **temperature / incubation, upper and lower**: Richter p. 35: Velsen fair survival 3-15 C (the
  lower-cell row), elevated mortality at 15 C, survival 7% above 16 C, Hicks 1-DM 13.5-14.5 C, an optimal
  constant temperature below 11-12 C; Table 1. Optima: 10 C preferred for hatching, high survival 4-9 C.
- **temperature / rearing, upper**: Richter: Hicks 16-17 C, Sullivan 7DADM 20.5 C, growth zero at
  22.5 C, juvenile upper lethal 24 C (Nielsen 1994); Table 1. B&R Table 4.8 upper lethal 23.9 C (Bell
  1986), Idaho stream 24 C daily max (`max_obs`). Cooney & Holzer 22 C WMAT. Optima: 14-15 and 13-15 C.
- **temperature / rearing, lower**: B&R Table 4.8, lower lethal 0.0 C (Bell 1986; the table gives no
  technique for steelhead).
- **degree_days, all four cells**: `none`. B&R p. 107: steelhead and rainbow trout need about 85 d at 4 C
  and 26 d at 12 C to 50% hatch; no degree-day total is printed.

## Found but not entered

- **OCR-garbled B&R values** (checked against the scan): Table 4.3 coho spawning 4.4-9.4 and incubation
  4.4-13.3 C, steelhead spawning 3.9-9.4 C; Table 4.8 coho lower lethal 1.7 C, Chinook upper lethal
  26.2 C. The OCR renders them as "44-94", "4413.3", "3,9-9,.4", "17" and "26,2", so no quote can carry
  the value. Coho 4.4-9.4 is in the table through Richter p. 33 (Reiser & Bjornn 1979 and Brett 1952).
- **Life stage not stated**: Richter p. 28, McCullough's (1999) distribution limit for Chinook,
  steelhead and rainbow trout, about a 20 C mean daily and a 22-24 C maximum daily temperature; Chinook
  UILT 25.1 and 24.9 C, Berman's 17.5 C, Hicks's 22 C daily max against acute lethality (p. 31); Hicks's
  coho lethal limit of 22-23 C less 2 C, i.e. 20-21 C (p. 33, after a sentence on adults); Hicks's
  steelhead daily maximum below 19-20 C (p. 36); Roberge's coho "lethal water temperature" of 25.1 C
  (p. 65). Each could be rearing, but the page does not say.
- **Hasnain et al.** states that all its metric estimates come from adults, so its coho and Chinook
  UILT, CTMax, OGT and FTP values are not rearing values and are not entered. Its coho embryo "optimum"
  of 0.9-13.4 C (Rombough 1997) looks like a tolerance span sitting in the optimum column; not entered.
- **Not grid stages**: smoltification, adult migration and holding (Richter, Sauter Table 3, B&R Table
  4.1), Morice "seek overwinter habitat below 5 C" (a behaviour threshold, not degree-days), Flett et al.
  on adult coho above 20 C.
- **Optima and preferences left out** (welcome but optional): CH growth optima of 14.8-20, 19 and 14.8 C,
  the ISG's 12-17 C (most optimal 15 C), Brett's 12-13 C acute and 11.7 C final preference; CO Bell
  12-14, Coutant 11.4, Everson 15, Konecki 11.6 and 9.9 C, Lusardi's citations of McCullough (15), Hicks
  (weekly average 14-15) and Moyle (12-14), B&R Table 4.8 12-14; ST Cech & Myrick and Grabowski, Roper &
  Scarnecchia 15.0 and 17.8 C, B&R 10-13 C.
- **Sullivan et al. 2000 "corresponding temperature range of 12-17 C"** for coho (Richter p. 32): Richter
  does not say what the span bounds (a range of thresholds or a suitable range), so it is not a `range`.
- **Resident rainbow trout (RB, not ST)**: Roberge spawning 10-15.5 C and lethal 24 C, Hasnain rainbow
  rows, Eaton & Scheller 24.0 C, B&R Table 4.3 2.2-20.0 C, Sauter's rainbow/redband rows.
- **Sauter Table 2**: juvenile steelhead field avoidance at 23 C (Nielsen 1994). The multi-column layout
  splits the row, so it was not quoted; the same study's 24 C upper lethal is in via Richter.
- **Lusardi p. 414**: Osterback et al. (2018) positive coho growth in a lagoon at mean daily temperatures
  above 20 C. A lagoon, and a ">" with no ceiling; not entered.

## Unsure

- CH 11-12 C 7DADM "at the time of fertilization" filed as spawning rather than incubation.
- CO 7DADM 9-12 C "to fully support the pre-emergent states" sits under Richter's rearing heading; I
  filed it as incubation because pre-emergent stages are in the gravel.
- `kind` for lab lethal values (convention 1) and the lower-end reading of spans (convention 2).
- Lusardi's growth peak (16.6 C mean T, 21.1 C MWMT) is entered as `optimum` with kind `dist` (the reach
  where enclosure growth peaked), not `pref`.

## Parent's decisions after drafting (2026-10-06)

- **Raleigh p. 6, female pre-spawning mortality above 12.8 C (Andrew and Geen 1960), was not filed**: it is
  adult holding mortality, not a spawning-ground limit (meaning audit round 1, finding 5).
- Added from the audit: Richter p. 30, CH incubation significant mortality at 9.9-16.7 C (Hicks 2000), as a
  `lab` max of 9.9 (the lower end).
- `lab` replaces `expert` on measured results; Sauter Table 4's assumed DAT is `unstated`; the upper edges of
  optima are `optimum`, not limits; Hicks's 11-12 C at fertilization is incubation.
