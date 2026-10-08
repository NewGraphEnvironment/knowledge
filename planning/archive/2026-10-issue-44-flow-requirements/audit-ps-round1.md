# Audit, ps family, round 1 (#44): data rows 687-877

Every row was read against its page: the quoted sentence and the page around it. Tables were checked
on rendered pages where the text layer was doubtful: Bjornn & Reiser Tables 4.5 and 4.10 and p. 89, and
the Raleigh et al. figure coordinate tables (layout text).
Data row N is file line N + 1. The proposed values below are exact field values.

## Errors

### 791-802 (12 rows, Tennant 1976 Table 1): `metric` contradicts the source
- **What is wrong:** all twelve carry `metric = seasonal_mean`. The brief set that metric for "Tennant's
  Oct-Mar and Apr-Sep". Tennant names the statistic himself, and it is not a seasonal mean.
- **Evidence:** p. 10, Recommendations, item 4: *"Request "instantaneous flows" to prevent flow releases
  from dams and diversion structures that are averaged over a day, month, or year, which permits erratic
  releases or even no flow at times."* The same page also says: *"Avoid recommending minimum
  instantaneous stream flow regimens less than 10% of the average flow"*. The seasons in Table 1 say
  when a level applies. They are not the statistic the flow is held to.
- **Fix:** `metric` = `instantaneous` on 791-802. Append to each note: "Tennant asks for the flows as
  instantaneous flows, not averages over a day, month or year (p. 10, Recommendations, item 4)."
- **The brief:** its `seasonal_mean` line is wrong for Tennant, and it is the only use of that metric in
  this family. Decide whether `seasonal_mean` stays in the vocabulary.

### 803 (Tennant 1976, abstract 10 % minimum instantaneous): delete row
- **What is wrong:** once 791-802 are fixed, 803 duplicates 800 on key, page, value, stage, metric and
  kind: `FISH`, `rearing`, `instream_flow`, `min`, 10 percent MAD, `instantaneous`, `expert`, p. 6. The
  abstract's 10 % is Table 1's "Poor or minimum" level, which is 10 % in both seasons.
- **Fix:** delete 803. Move its words into the notes of 799 and 800: "The abstract (p. 6) gives this
  level as 'a minimum instantaneous flow recommended to sustain short-term survival habitat for most
  aquatic life forms'." This also settles the drafter's doubt about this row's `rearing` stage: 799
  (`overwintering`) and 800 (`rearing`) together cover the year.

### 788, 789 (Neuman & Newcombe, Okanagan modification of the Montana method): `metric` inferred
- **What is wrong:** `metric = seasonal_mean`, which the drafter carried over from the brief's Tennant
  convention.
- **Evidence:** p. 6 (PDF page) gives only "flow adequate for long-term survival between October and
  March; 15% of mean annual flow", and the same for April-September. No statistic is named.
- **Fix:** `metric` = `unstated` on both. The months stay in the note.

### 808, 809 (Ptolemy & Lewis p. 30) and 824, 825 (Hatfield et al. 2002 Table 5, p. 41): a stream-size span coded as `range`
- **What is wrong:** 30-200 % MAD is not two limits. Each stream gets one minimum from the equation:
  200 % in the smallest streams, falling to 30 % in the largest. As `range` the rows read as "keep the
  flow between 30 and 200 % MAD", and the brief warns about exactly that reading.
- **Evidence:** Ptolemy & Lewis p. 30: *"The flows prescribed by this standard range from 30 or 200% but
  vary dependent on stream size (Figure 15)."* The equation follows on the same page. Hatfield Table 5
  pairs "30-200%" with the spawning equation 1.56 x MAD^0.63.
- **Fix, all four rows:** `bound` = `min`; keep `value_min` = `30` and `value_max` = `200`. Start each
  note with: "One minimum per stream, set by stream size (equation in the qual row): about 200 % MAD in
  the smallest streams falling to 30 % in the largest. The two values are the ends of that span, not a
  lower and an upper limit."
- **Alternative:** a blank `bound` with both values, if `min` with a `value_max` is judged to mislead.

### 851 (USFWS 2007 p. 28, spring-run chinook spawning depth HSC 0.8-7.0 ft): the note claims a correction that was not applied
- **What is wrong:** the note says "logistic regression, adjusted for low availability of deep water".
  That adjustment was made to the steelhead/rainbow curve, not the chinook curve.
- **Evidence:** p. 26: *"For spring-run Chinook salmon, the depth suitability from the logistic regression
  reached a suitability of 1.0 at 6.0 feet. Since the deepest spring-run redd in our study sites had a
  depth of 3.0 feet, we were unable to apply the Gard (1998) depth correction method."*
- **Fix, note:** "Figure 5, spring-run chinook spawning depth HSC, from logistic regression of redd and
  non-redd locations: non-zero suitability 0.8-7.0 ft, so the zero edges lie at those ends. The Gard
  (1998) correction for low availability of deep water could not be applied, because the deepest redd
  in the HSC sample was 3.0 ft (p. 26)."
- **Row 852:** append "The optimum lies beyond the deepest redd in the HSC sample (3.0 ft, p. 26)." Not
  counted as an error.

### 863 (USFWS 2007 p. 59, steelhead/rainbow 200 cfs): the note misnames the flow
- **What is wrong:** the note calls 200 cfs "the existing 200 cfs release". The page calls it a
  recommendation.
- **Evidence:** p. 59: *"the flow recommendations in the introduction during the steelhead/rainbow trout
  spawning and incubation period of January-June (200 cfs) may be close to achieving maximum habitat
  availability ... (greater than 91% of maximum WUA)"*.
- **Fix, note:** "The introduction's recommended flow of 200 cfs for January-June gives more than 91 % of
  maximum WUA for steelhead/rainbow trout spawning, so the authors judge it near the optimum (hedged:
  'may be close'). One curve for both."

### 850 (DFO 2013 p. 2): the note overstates the requirement
- **What is wrong:** the note says "below 30 % MAD instantaneous flow a rigorous assessment is required".
- **Evidence:** p. 2: *"a more rigorous level of assessment is recommended"*.
- **Fix, note:** replace "is required" with "is recommended". The rest of the note stands.

### 696-702 (Bjornn & Reiser Table 4.5, 7 rows): the note claims more than the page says
- **What is wrong:** every note says "velocity at 0.6 x depth, measured at redds".
- **Evidence:** p. 95 says only that *"Most velocity criteria have been developed for 0.6 x depth"*, and
  that measurements *"were usually taken at the upstream edge of the redd"*. Neither is stated per row.
- **Fix, all seven notes:** replace that clause with "criteria from depth and velocity measured at redds,
  usually at the upstream edge; most velocity criteria are for 0.6 x depth (p. 95)". The rest of each
  note stands. Minor, but it applies to every row in the table.

### 704 (Bjornn & Reiser p. 94, Nechako redd pit depth 0.46-1.20 m): the note infers beyond the page
- **What is wrong:** the note ends "so deeper than the depth the fish chose". The page does not say this.
- **Fix, note:** "Depth in the pit of 47 completed chinook redds (mean 0.87 m). This is the excavated
  pit, not the upstream edge where depth is usually measured to reflect the site the fish chose
  (p. 95)."

### 787 (Neuman & Newcombe p. 6, coho 0.7 ft/s): the field placement commits to one reading
- **What is wrong:** the note grants two readings of "created the maximum 'preferred' pool velocities
  (0.7 fps)". In one, 0.7 ft/s is the preferred velocity itself; in the other, it is the upper end of a
  preferred span. Putting the value in `value_max` alone, and calling it "the upper end", asserts the
  second reading.
- **Fix:** `value_min` = `0.7`, `value_max` = blank: a single-value optimum, as in rows 805, 811 and 813.
- **Fix, note:** "Oregon Fish Commission method from summer rearing studies of juvenile coho in 19
  streams: the rearing flow is the one that creates the maximum 'preferred' pool velocities, given as
  0.7 ft/s. Read either as the preferred velocity itself or as the most pool area at that velocity;
  either way 0.7 ft/s is a preferred velocity, not a limit. Page is the PDF page (no page number is
  printed)."

### 819 (Ptolemy & Lewis p. 27, summer chinook passage depth 30 cm): delete row (drafter's doubt)
- **What is wrong:** the note's caveat leaves out the strongest evidence, which is in this same document.
- **Evidence:**
  - p. 30, citing the same Reiser and Bjornn (1979): *"lower minimum passage depths (12 cm) compared to
    larger fish ( 24 cm)"*.
  - Bjornn & Reiser 1991, the later edition of the same authors' review: Table 4.1 gives 0.24 m passage
    depth for summer chinook (rows 687-689), and Table 4.5 gives >=30 cm spawning depth (row 698).
  - The 30 cm therefore contradicts both the document's own passage figure and the primary table.
- **Fix:** delete 819.
- **If kept:** the note must read "Passage depth for summer chinook as the authors report it. It
  conflicts with the same document's p. 30 (24 cm for larger fish, citing the same Reiser and Bjornn
  1979) and with Bjornn and Reiser (1991) Table 4.1 (0.24 m for summer chinook). The 30 cm equals Table
  4.5's summer chinook spawning depth (>=30 cm), so it is probably that criterion misattributed."

### 872-875 (`none`, CO spawning, incubation, rearing and overwintering instream_flow): the notes overstate the absence
- **What is wrong:** the notes say Hatfield et al. 2002 Appendix A "charts coho ... but gives no coho
  standard". That is true of the per-activity flow-standard column, but not of the whole page.
- **Evidence:** the Ash River chart (p. 92, PDF page) charts chinook and coho activities, and below the
  chart it lists general standards:
  - *"Adult passage (general) 45%mad or 12.5 cms for Days"*
  - *"Spawning 45%mad or 12.5 cms for Days-Weeks"*
  - *"Incubation 20%mad or 5.5 cms for months"*
  - *"Rearing 20%mad or 5.5 cms for months"*
  - *"Over-wintering 20%mad or 5.5 cms for months"*
  - *"Smolt Migration 45%mad ..."*

  "General" is set against "Summer Steelhead passage" on the line below, so the list reads as applying
  to every species charted. 45 % is also what the 30-200 % equation gives for a 27.8 m3/s stream. The
  Sinmax chart (p. 98) has a conservation flow of 160 % MAD in October, which matches coho and sockeye
  spawning and the equation for a 0.78 m3/s stream, but it labels no species.
- **Fix (Al to decide):**
  - (a) Write CO rows from the Ash list: spawning `min` 45, incubation `min` 20, rearing `min` 20 and
    overwintering `min` 20, all percent MAD, `metric` `unstated`, kind `expert`, region "Ash River,
    Vancouver Island, BC", p. 92. The note says the list is general, names no species, and sits below a
    chart that has coho rows. Then delete 872-875.
  - (b) Keep the `none` rows and append to each note: "Ash River (p. 92) lists general standards below a
    chart with coho rows (spawning 45 %, incubation, rearing and over-wintering 20 % MAD), but names no
    species."
- **Recommendation:** (b), because (a) rests on inferring the scope of an unlabelled list.
- **876 and 877 (SK):** no labelled source either. Adding the Sinmax October conservation-flow
  observation to those notes would be accurate. Not counted.

### 865 (Warkentin et al. 2022 p. 8, 36 % MAD): one estimate written twice without saying so
- **What is wrong:** 865 is the same replacement estimate as 864. On p. 6 it is *"10.6 ... m3 s−1 (or
  36% MAD)"*, and 864's own quote carries the 36 %. Rows 817 and 818 handle the same situation by
  cross-referencing each other.
- **Fix, 865 note:** append "The same replacement threshold as the 10.6 m3/s row (p. 6), in percent
  MAD; not independent."
- **Fix, 864 note:** append "Restated as 36 % MAD on p. 8 (own row)."

## Drafter's doubts: verdicts
- **819:** delete; see above.
- **783 (Roberge Table 57, steelhead young-of-the-year <0.15 m/s):** keep. The doubt that it was carried
  over from chinook is mostly answered. Bjornn & Reiser Table 4.10 (p. 129, checked on the rendered
  page) lists Everest and Chapman (1972), steelhead age 0: depth <15 cm, velocity <15 cm/s. Roberge's
  steelhead text cites Everest and Chapman (1972) for young-of-the-year on p. 67. Append to the note:
  "Bjornn and Reiser (1991) Table 4.10 gives Everest and Chapman (1972) steelhead age 0 at <15 cm/s,
  which matches this cell." Do not set `cited_source`, because Roberge does not name it. Not counted.
- **830-833 (Hatfield Table 7 example):** keep. The notes say plainly that this is a worked example for
  a 5.8 m3/s stream. 831 is a thin basis for the CH migration cell, and nothing better exists in the
  collection.
- **Year-round FISH standards coded `rearing` (803, 849, 850):**
  - 803 is resolved by deleting it.
  - 849 (lowest-flow month, which is late summer or winter by region) and 850 (DFO, year-round) have
    no correct stage in the vocabulary. `rearing` with the existing notes is the least-bad choice.
  - This is a schema gap, not a row error. Raise it with Al: a year-round stage, or a rule that such
    rows are read only through their notes.
- **760, 761 (Raleigh base flow, `overwintering`):** acceptable. V11 is "Average annual base flow during
  the late summer to winter low-flow period" (Table 1). The note already states the choice.

## Duplicates
- **No row duplicates a row in 1-686.**
  - The Gottesfeld `SALMON` row 121 (p. 6) and rows 867-868 (p. 7) are different statements.
  - No existing CH, CO, SK or ST depth, velocity or instream_flow row is restated.
- **Duplicates among the new rows:**
  - 800 and 803: delete 803 (above).
  - Advisory, not counted:
    - 757 (p. 10, `pref`) and 759 (p. 11, `expert`): the same 0 to <40 cm/s, first as a literature
      statement, then as the authors' summary.
    - 731 (Fig. 5 depth) and 742 (Fig. 12 depth): identical category-one curves (0 at 15.2 cm, 1.0 from
      30.5 cm).

  The brief's rule (same key, page, value and stage) admits both pairs, but each is one fact twice.
  Consider cross-referencing their notes as 817 and 818 do.
- **Same standard in two documents:** 806 and 807 against 821 and 822, and 808 and 809 against 824 and
  825. The notes disclose this, which is acceptable. The group code differs (`SALMONIDS` for Ptolemy &
  Lewis, `FISH` for Hatfield), and each follows the scope its own source states.

## Checked and found right (no entry needed)
- Table 4.1 rows (687-695).
- Table 4.10 rows (710-719): every cell matches the rendered page, including the OCR corrections stated
  in the notes (78-81 mm, 77-89 mm, 55-60 cm, 30-70 cm).
- All 22 Raleigh figure rows: every breakpoint and zero edge matches the coordinate tables.
- The Beecher & Caldwell curves (762-775).
- The Levy & Slaney cells (720-727).
- Roberge 776-782 and 784.
- Hatfield Appendix A cells (834-848) and Table 5 cells.
- Ptolemy & Lewis 804-818 and 820.
- Warkentin 864 and 866, Gottesfeld 867 and 868, Keeley & Slaney 869 and 870 ("13 species" is in
  Table 2), and MacIsaac 871.

audited 191 rows, 37 with errors

## Mechanisms
1. **A convention in the brief overrode the source.** The brief's "seasonal_mean (Tennant's Oct-Mar and
   Apr-Sep)" was applied to 12 Tennant rows although Tennant names instantaneous flows, then carried to
   Neuman & Newcombe by analogy. It caused 14 rows of error and one duplicate. A metric convention in a
   brief needs the same check against the source as a row does.
2. **Notes describe a method from a neighbouring or general sentence rather than this row's own:**
   - 851 took the steelhead curve's availability correction.
   - 696-702 turned "most criteria" into every criterion.
   - 863 turned "recommendation" into "existing release".
   - 704 added an inference.
3. **The span of a stream-size-dependent minimum was coded as `range`** (808, 809, 824, 825). The values
   are faithful, but `range` reads as two limits.
4. **Searches read a chart's labelled column and stopped.** The `none` notes for coho state an absence
   that the same page qualifies (the Ash general list).
5. **One fact in two units or on two pages became two rows** without saying so (864 and 865, 800 and
   803; 757 and 759, 731 and 742 advisory).
