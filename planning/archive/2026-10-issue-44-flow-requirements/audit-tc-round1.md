# Meaning audit, round 1: trout, char and grayling rows (#44)

Scope: `data/literature_evidence.csv` data rows 878-1011 (draft rows 1-134; data row N = file line N + 1).
Every row was read against its source page (text, `-layout` or OCR), not only the quoted sentence. Rows
not listed below were checked and found correct as coded.

Severity: **A** changes what a row asserts (stage, bound, species, variable, metric) or the row should not
exist; **B** a note or region that claims more or less than the page says; **C** consistency only.

## Rows with errors

### DR 881 (draft 4): BT rearing velocity max 30 cm/s, Hagen & Weber p. 19 (B)
- Wrong: `kind = pref`. The value is "an upper limit of approximately 30 cm/s" suggested for fry, not a
  preference. `pref` is a preference from use and availability; the same sentence's preference is DR 880.
- Evidence: p. 19, "preferred velocities have been suggested to be less than 15 cm/s, with an upper limit of
  approximately 30 cm/s (Baxter and McPhail 1996)".
- Fix: `kind = expert`. Note: "Age-0+ fry: suggested upper limit of approximately 30 cm/s (the preference in
  the same sentence is the previous row)."

### DR 883 (draft 6): BT spawning depth min 10 cm, McPhail & Baxter p. 5 (A) — drafter's doubt confirmed
- Wrong: `bound = min` asserts a lower limit of 10 cm. The page says depths run "from less than 10 cm", so
  redds occur below 10 cm; neither end is a limit (the upper end is "over 1.0 m"). No bound fits: as `range`
  it would read as two limits, and both ends are open.
- Evidence: p. 5, "Water depth over the redds varies from less than 10 cm to over 1.0 m".
- Fix: **delete row**. The BT spawning-depth cell stays filled (DR 878, 889, 897). If the span is wanted, put
  it in DR 878's note ("McPhail and Baxter 1996, p. 5: redd depths from less than 10 cm to over 1.0 m").

### DR 892 (draft 15): BT spawning depth optimum 0.15-0.84 m, Ford Table 8 p. 117 (A) — drafter's doubt confirmed
- Wrong: `bound = optimum`, `kind = pref`. Table 8 is titled "Observed habitat use" and its "Preferred spawning
  depth 0.15 to 0.84 m" is the full span of the same chapter's Table 10 (p. 125) depths over redds: lowest
  0.15 m (Flathead R. range 0.15-0.35) to highest 0.73-0.84 m (Meadow Creek). It is the extremes of observed
  redd depths across studies, not a preferred subset; coding it as an optimum tells a reader that depths
  outside 0.15-0.84 m are merely less preferred, when no redd in the compiled studies was outside it. The
  source (Table 10 on the same subject) decides, not the label.
- Fix: `bound = range`, `kind = dist`. Note: "Table 8 (observed habitat use) labels it 'preferred spawning
  depth', but the span is the extremes of Table 10's (p. 125) depths over redds: 0.15 m (Flathead River, range
  of 0.15-0.35) to 0.73-0.84 m (Meadow Creek, Kootenay Lake). A span of observed redd depths across studies,
  not a preference."

### DR 894 (draft 17): BT rearing velocity max 0.25 m/s, Ford p. 120 (B)
- Wrong: `region = "Mackenzie Creek, Arrow Lakes, BC"`. Ford p. 120 names no stream; the stream comes from
  McPhail & Baxter's account of the same study.
- Evidence: p. 120, "Yearling and older juveniles rear in pools ... (McPhail and Murray 1979)"; no place named.
- Fix: `region = "Arrow Lakes, BC (McPhail and Murray 1979 study)"` or blank; add to note "Ford names no
  stream; McPhail and Baxter 1996 (p. 11) place the study in Mackenzie Creek."

### DR 895 (draft 18): BT rearing velocity max 0.5 m/s, Ford p. 120 (B)
- Wrong: same inferred `region` as DR 894. Fix as DR 894.
- Also (advisory, not counted separately): McPhail & Baxter p. 11, written by the original study's author,
  says the August run fish were in "water velocity >50 cm/s", the opposite of Ford's "< 0.5 m/s". The note
  discloses the conflict; the caller may prefer to delete this row, since a `max` that the primary author
  reports as a `min` fills the BT velocity-rearing cell with a value the original study contradicts (the
  cell stays filled by DR 881, 887, 894, 896, 902).

### DR 905 (draft 28): BT rearing instream_flow min 55 % MAD, Hatfield 2002 Nechako chart (A/B)
- Wrong: the note does not say that 55 % MAD is Ptolemy's **adult** rearing standard. The grid's `rearing` cell
  is juvenile summer rearing. Ptolemy's Table 5 (p. 41) gives juvenile rearing 20 % and adult rearing > 55 %;
  the Nechako chart applies the adult value to a combined "Rearing (adult and juvenile)" line for bull trout,
  while for resident rainbow on the same chart it splits juveniles (20) from adults (55). Read alone, the row
  says BT juveniles need 55 % MAD where every other species needs 20 %.
- Evidence: PDF p. 89, "Rearing (adult and juvenile) ... 55"; p. 41 Table 5, "Juvenile 20% ... Adult > 55%".
- Fix (keep row, rewrite note): "PDF page (Appendix A, 'Examples of Ptolemy's Criteria applied to British
  Columbia streams'; no printed number). Nechako periodicity chart, column 'Flow Standard (%mad)': bull trout
  'Rearing (adult and juvenile)' 55 % MAD, April-November. 55 % is Ptolemy's adult-rearing standard (Table 5,
  p. 41: juvenile 20 %, adult > 55 %); the chart applies it to adults and juveniles together, so it is not a
  juvenile-specific need. Statistic not stated."
- On the caller's question whether the Nechako rows state BT flow needs at all: yes. Appendix A (PDF p. 87)
  titles these charts "Examples of Ptolemy's Criteria applied to British Columbia streams", and each line
  gives a flow standard in % MAD per activity; the existing ST and CH rows 834-848 are coded from the same
  charts on the same basis. Caveats that belong in the notes of DR 904 and 905: they are worked examples of
  the method on one river (the conservation-flow row is marked "PRELIMINARY"), not provincial standards.

### DR 915 (draft 38): GR migration instream_flow 10-15 m3/s, dist, no bound, Stuart & Chislett p. 50 (A)
- Wrong: `instream_flow` is a flow need (`pkg/R/literature.R`: "the water a life stage needs while it is in the
  stream"). The page reports the discharge of Martin Creek while adults were seen moving upstream as flows
  dropped after the peak; that is neither a need nor a statement that grayling require it, and an absolute
  discharge from one creek carries no meaning elsewhere. The unit is also inferred: the OCR prints "n/s" here
  and "m/s" for the 19.4 peak, so "m3/s" is the drafter's reading.
- Evidence: p. 50, "intermittent trapping as the water level dropped indicated adult grayling were moving upstream
  in approximately 10 - 15 n/s flows and water temperatures from 6 - 10°C".
- Fix: **delete row**; move the fact to `draft-tc-notes.md` ("flows during an observed migration, not a need").
  Then edit DR 1005's note (below).

### DR 916 (draft 39): GR spawning velocity 0.34-1.46 m/s, Hubert p. 2 (B)
- Wrong: `region = "Alaska (review)"`. Hubert p. 2 names no place for Krueger (1981); "Alaska" is imported
  from Stewart et al.'s source list.
- Fix: `region` blank (or "not stated (Krueger 1981)").

### DR 932 (draft 55): WCT rearing velocity max 1 cm/s, 2004 WCT account p. 6 (A) — drafter's doubt confirmed
- Wrong: `species_code = WCT`. The account cites Ford et al. 1995, and Ford (p. 72) traces the value to Moore
  and Gregory (1988b) "in tributary streams of the Cascade Mountains": cutthroat fry not identified as
  westslope (the Cascade studies are of coastal-range cutthroat). Ford gives the westslope fry value
  separately: "Griffith (1972) reported finding westslope cutthroat fry in velocities of 7 to 10 cm/s" (DR 939).
  The species measured is generic cutthroat, so the WCT row misattributes it; the account's restatement adds
  "adfluvial and fluvial populations", which Ford does not say.
- Fix (recode in place rather than delete, so later data rows do not shift): `species_code = CT`,
  `citation_key = ford_etal1995LiteratureReviews`, `page = 72`,
  `quote = Fry over 30 mm were found in water velocities less than 1 cm/s`, `quote_source = ocr`,
  `cited_source = Moore and Gregory 1988b`, `region = Cascade Mountains tributary streams`, `kind = dist`,
  `bound = max`, `value_max = 1`, `unit = cm/s`, `scale = site`; note: "Fry over 30 mm (fry under 30 mm were
  in velocities too low to measure). Ford's westslope chapter cites Moore and Gregory (1988b), Cascade Mountains
  streams, cutthroat not identified as westslope; the 2004 WCT account (p. 6) restates it for westslope
  cutthroat, citing Ford." (Re-run 0280 on the recoded row.) The WCT velocity-rearing cell stays filled
  (DR 935, 936, 939, 940).

### DR 948 (draft 71): CT spawning depth min 0.15 ft, Beecher Fig. 13a p. 71 (B)
- Wrong: note says "subspecies not separated". The page says only "Cutthroat Trout (O. clarki)" and names the
  streams (Irely and Skookum creeks); it makes no statement about subspecies.
- Fix: note "Figure 13a, cutthroat trout (O. clarki as labelled; 7 studies, 123 redds, Irely and Skookum
  creeks). Preference 0.00 at 0 and 0.15 ft, 0.50 at 0.25 ft: 0.15 ft is the zero-suitability edge. An axis
  tick (0.8) sits between the columns."

### DR 965 (draft 88) and DR 967 (draft 90): RB rearing / overwintering instream_flow min 55 % MAD, Ford p. 53 (A)
- Wrong: `bound = min` for the threshold of the **excellent** class. "Greater than 55 % ... is considered
  excellent" is the best class, which the brief codes `optimum`; the limit below which habitat is poor is
  25 % (DR 966, 968, correctly `min`). As `min`, the table holds two different lower limits (25 and 55) for the
  same statement.
- Evidence: p. 53, "A base flow of greater than 55% of the average annual daily flow is considered excellent,
  25 to 50% is considered fair and less than 25% is considered poor".
- Fix: `bound = optimum` (value_min 55, value_max blank) on both; first sentence of each note "Excellent
  class (best of three), late summer base flow" / "... winter base flow".

### DR 974 (draft 97) and DR 975 (draft 98): RB rearing velocity, Beecher Fig. 9b p. 65 (C)
- Wrong: blank `life_history_form`. Beecher says the curve "combines steelhead and resident rainbow juvenile
  observations"; the RB rows are its resident part, and the other RB rows from this source (DR 969-973)
  carry `resident`. Notes also do not point to the ST twin.
- Fix: `life_history_form = resident`; append to each note "The ST twin of this curve is data row 775
  (steelhead coded separately, per one row per named species)."
- On the caller's question: these are not duplicates of the ST rows. The curve names two forms, so the brief's
  rule (one row per named species, grouping in the note) gives an ST row and an RB row with identical fields.
  The pairing is incomplete on the ps side: ST has the 5.00 ft/s max (775) but no 0.75-0.95 ft/s optimum twin
  of DR 974. Either add that ST row or accept the asymmetry knowingly.

### DR 987, 989, 991 (drafts 110, 112, 114): RB spawning / rearing instream_flow min (IFN), AMEC p. 57 (A)
- Wrong: `metric = unstated`, and the notes say "the table does not name a flow statistic". The method text
  names it: the IFN "were set as the minimum monthly flows required to protect fish ... during each
  biologically relevant stanza" (p. 30). The gate's rule is to code what the source states; it states a
  monthly flow.
- Evidence: p. 30 (PDF 42), "The IFN were set as the minimum monthly flows required to protect fish and, by
  association, other aquatic values during each biologically relevant stanza".
- Fix: `metric = monthly_mean` on all three; replace "the table does not name a flow statistic for it" with
  "IFN are 'the minimum monthly flows required to protect fish' in each stanza (p. 30), set to give at least
  90 % of the habitat available at the stanza's baseline mean annual 30-day low flow."
  (If the caller reads "minimum monthly flows" as too loose for `monthly_mean`, keep `unstated` but the note
  must still quote p. 30 instead of saying no statistic is named.)

### DR 993 (draft 116): RB rearing instream_flow min 0.225 m3/s, lower Davidson Creek, AMEC p. 57 (A)
- Wrong: the 0.225 m3/s IFN for lower Davidson 1 July-31 August is set by **kokanee spawning** (the bold,
  defining stage; p. 56 "Spawning kokanee require the highest flows in lower Davidson Creek in summer"). Table
  14 repeats the stanza's single IFN on every species line. It is not an RB juvenile need; the RB juvenile need
  is at most this and is not stated. The drafter treated the same layout correctly elsewhere: the spring
  stanza's non-defining "RB juveniles ... 0.545" line was not coded as an RB rearing need.
- Fix: **delete row** (DR 992, the RB-juvenile flow producing maximum habitat, stays). Alternatively recode
  to `species_code = KO`, `life_stage = spawning` with the quote "1 July – 31 August 0.286 KO spawning 0.525
  92% 0.225 83%" — but KO is outside both families' briefs, so deletion plus a notes line is simpler.

### DR 994, 995 (drafts 117, 118): RB overwintering instream_flow min, AMEC p. 57 (A)
- Wrong: `metric = unstated` while the row's own note says the IFN were set at "baseline March flows, the
  lowest mean monthly flows of the winter stanza" (p. 56; also p. 83). That is a stated monthly mean.
  The note also omits that the source contradicts itself: p. 30 defines winter IFN as "the mean annual winter
  stanza 30-day low flow (Table 11)".
- Fix: `metric = monthly_mean`; note: "Table 14, Blackwater Gold Project instream flow study. Recommended flow
  (IFN) for 1 December-10 May, rainbow trout juveniles. IFN are 'minimum monthly flows' (p. 30); winter IFN
  were 'baseline March flows, the lowest mean monthly flows for the winter stanza' (p. 56; p. 83), though
  p. 30 calls them the winter-stanza mean annual 30-day low flow."

### DR 1005 (draft 128): GR migration instream_flow none (B, consequential)
- Wrong once DR 915 is deleted: the note refers to "a dist row with no bound".
- Fix: replace the last sentence with "stuart_chislett1979 (p. 50) gives the discharge of Martin Creek while
  adults were moving upstream (about 10-15 m3/s, OCR 'n/s'), which is an observation, not a need."

## Checked and correct (selected, for the record)

- Hatfield 2002 Nechako and Sinmax RB rows (DR 976-985): stage, value and `resident` form match the charts;
  "Adult passage 160" vs "Migrant passage 50" read correctly on Sinmax.
- Beecher BT (DR 897-902), CT (DR 948-954 apart from the 948 note) and RB Fig. 10 (DR 969-973) breakpoints
  all match the plotted columns; zero edges and plateaus read correctly; pooling noted on every BT row.
- Hubert Fig. 1, 3, 5 coordinates (DR 919-925, 928) match the OCR once axis ticks are discounted.
- Stewart (DR 906-913), Roberge (DR 889-891, 941), DFO 2019 Table 2 (DR 933-936), Levy & Slaney Table 6
  (DR 942-943, 956-957), Bjornn & Reiser Table 4.10 (DR 903, 955), Ford RB (DR 958-964, 966, 968), Ford WCT/CT
  (DR 937-940, 944-947): species, stage, bound, kind, page and cited source all as the page says.
- `none` rows (DR 997-1011): notes say what was searched and claim no absence in the literature.

## Advisories (not counted as row errors)

1. **USFWS 2007 Clear Creek RB rows are missing.** ps rows 855 and 857 say "one curve for both; the RB row is
   left to the trout-and-char draft", and 856, 858, 861-863 rest on the same steelhead/rainbow curves. The tc
   draft wrote no `u_s_fishandwildlifeservice2007` rows and its notes do not mention the source. Either add the
   seven RB twins or edit the ps notes.
2. **Cross-family convention on Beecher curves.** ps codes a curve's two zero edges as one `range` row (ST 774,
   CH 764, SK 772); tc codes them as separate `min` and `max` rows (BT, CT, RB). Both are legal; a reader
   filtering `bound = range` gets only the salmon. Pick one before merge.
3. **One fry value counted three times.** GR fry velocity 0.8 m/s appears as DR 914 (Stuart & Chislett,
   primary), DR 929 (Ford, citing Stuart & Chislett among five) and DR 911 (Stewart, citing Stuart & Chislett
   and Ford among nine). The drafter dropped Hubert's restatement as secondary but kept these two.
4. **DR 927 vs 928.** Two `min` rows on one curve: 0.4 ft is where Fig. 5 reaches SI 1.0 (the text calls it
   "the minimal water depth considered suitable"), 0.3 ft is the zero edge. Defensible because the text states
   0.4 as the minimum; the note says so.
5. **DR 940** (WCT age 1+/2+ max 22 cm/s): Ford's sentence names no source and its numbers (10-12.5 average,
   22 max) mirror Ford's rainbow chapter (p. 49, 10-12 and 22, Raleigh et al. 1984; Rose 1986). Roberge
   (p. 61) attributes 10-12.5 to Griffith 1972 for westslope juveniles, which supports WCT. Keep, as noted.
6. Deleting DR 883, 915 and 993 shifts every later new data row number by up to three. A grep of `research/`
   and `planning/active/` found nothing citing data rows 878-1011, and no note in 878-1011 points forward.

audited 134 rows, 21 with errors (DR 881, 883, 892, 894, 895, 905, 915, 916, 932, 948, 965, 967, 974, 975, 987, 989, 991, 993, 994, 995, 1005)

## Mechanisms behind several errors

- **The quoted page was read, the method page was not.** AMEC's metric (p. 30) and which stage defines each
  IFN (p. 56) live away from Table 14 (DR 987-995); Ford's Table 8 "preferred" depth is explained by Table 10
  (DR 892); Ptolemy's adult/juvenile split (p. 41) explains the Nechako 55 % (DR 905).
- **A secondary source's attribution was taken without tracing it.** Species (DR 932, westslope via a
  restatement of a Cascade Mountains study) and region (DR 894, 895, 916, place names imported from another
  document).
- **A class edge or an open span coded as a limit.** "Excellent above 55 %" as a `min` (DR 965, 967); "from less
  than 10 cm" as a `min` (DR 883); an observed discharge as a flow need (DR 915).
- **Pooled curves split across two drafts.** RB/ST twins (DR 974-975 vs 775) and the USFWS curves were each
  left half-coded because each family assumed the other would write the twin.
