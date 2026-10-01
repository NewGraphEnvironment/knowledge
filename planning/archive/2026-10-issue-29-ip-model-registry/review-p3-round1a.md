# Review p3 round 1a: meaning check of the OW and CA IP rows

Scope: every `data/literature_evidence.csv` row and every `data/ip_model_registry.csv` row whose `model_id` is
burnett2007, busch2011, busch_nwfsc, blm2008, dent2005, bartz2006, herger2003, sloat2017, agrawal2005,
bjorkstedt2005, lindley2006 or boughton_goslin2006. That is evidence rows 21, 22, 24, 26, 27, 57, 59, 60, 120 and
191-326, and registry rows 7-38 and 81, as staged. Each row was read against the surrounding PDF text or table in
`scratchpad/txt/`. Quote presence was not re-checked.

Row numbers are 1-based data rows with the header excluded. "E" is the evidence table and "R" is the registry.

## Errors

### 1. The Boughton & Goslin summer discharge is linked to mean-annual-discharge parameters (E310, E311, E318, E319)

- **Rows.** E310 and E318 carry `parameter = rear_mad_min`, and E311 and E319 carry `rear_mad_max`.
- **What the source says.** Boughton & Goslin p. 4 and Table 2 describe a "mean discharge for months 8 and 9 (Aug & Sept)"
  (Q89). p. 2 introduces it "as a substitute for mean annual discharge". The registry correctly gives
  `flow_metric = summer_low_flow` (R38).
- **The problem.** Every other `*_mad_*` row in the table is a mean annual discharge (MAD) threshold: woll2015,
  rebellato2024, agrawal2005 and lindley2006. A consumer that pulls `rear_mad_min` would read a summer-flow minimum
  of 0.002 m3/s (or 0.0008) as a MAD minimum, which is one to two orders of magnitude too small for MAD.
- **Fix.** Blank `parameter` on all four rows. The summer-flow nature is already in `note` and in R38.

### 2. `busch_nwfsc` Chinook rows are labelled `ocean_type`, but the model is not fall-run-specific (E59, E214-E226; R14-R16)

- **What the source says.**
  - Sheer Table A1 (p. 33) lists the NOAA Lower Columbia IP as "CHN(s/f)" and the Willamette IP as "CHN (s)". Willamette
    spring Chinook are stream-type.
  - The Busch barrier sentence (p. 13) applies to Busch's Chinook generally: "gradient > 16%, documented waterfalls
    >3.7 m, and bankfull width <2 m". It then adds a separate rule for one run only: "For Lower Columbia fall Chinook,
    used a threshold of 350 m elevation".
  - The width-class gradient curves and the confinement and bankfull-width curves (p. 14) carry no run.
- **The problem.** `ocean_type` asserts that these values apply only to fall (ocean-type) Chinook. The source applies
  them to spring Chinook as well. The drafter followed the form of committed row 59, and the registry notes concede that
  "the Chinook models also cover spring run". The form column still says otherwise.
- **Fix.** Leave `life_history_form` blank, meaning runs not separated, on E59 and E214-E226 and on R14-R16. Keep the
  spring/fall coverage in `note`.

### 3. Stale registry notes contradict their own `flow_source` (R13-R16 busch_nwfsc, R21 bartz2006)

- **busch_nwfsc (R13-R16).** `flow_source = unstated` and `flow_inputs` is blank. The note still says "'modelled from
  drainage area and precipitation' is inferred from the group's published fall-Chinook model ... and is not stated
  in Sheer".
- **bartz2006 (R21).** `flow_source = unstated`. The note still says "'modelled from drainage area' is a placeholder to
  check against the paper".
- **The problem.** Both notes describe an earlier draft value that the row no longer carries. A reader sees a
  "modelled" claim that the field does not make.
- **Fix.** Reword both notes:
  - busch_nwfsc: "Sheer names bankfull width but not how it was obtained (hence `unstated`). Busch et al. 2011, the
    group's published fall-Chinook model, regresses width on drainage area and precipitation, which suggests but
    does not establish the same here."
  - bartz2006: "Sheer names bankfull width but not its source, and Bartz et al. 2006 is not in the library (hence
    `unstated`)."

### 4. E300 (bjorkstedt2005, CH spawning) note says Agrawal's curves are applied unchanged; the source says the opposite

- **The note.** E300 reads: "Fall-run Chinook spawning IP on the Agrawal et al. (2005) Chinook curves. ... Bjorkstedt et
  al. apply the Agrawal et al. (2005) curves unchanged".
- **What the source says.**
  - Bjorkstedt p. 89: "The approach is identical to that used for coho salmon and steelhead ... **except that we used
    habitat suitability curves designed to capture the characteristics of areas in which fall-run Chinook salmon
    typically spawn**."
  - p. 26: the Chinook spawning IP uses "suitability curves based on the work of the Umpqua Land Exchange Project".
  - Agrawal's own Chinook curves are juvenile-rearing curves (Agrawal PDF p. 16).
- **The problem.** The note contradicts the source, and it contradicts the reason this row has its own `model_id`
  (R81's note gets it right).
- **Fix.** Replace the note with: "Fall-run Chinook spawning IP using Chinook spawning curves (p. 89; ULEP-based, p. 26),
  on the same gradient / mean annual discharge / valley-constraint framework (p. 25)."

### 5. R34 (agrawal2005 CH spawning) note cites Bjorkstedt p. 89 as using Agrawal's Chinook IP for spawning

- **The note.** It reads "Plate 3 and Bjorkstedt et al. 2005 (p. 89) use the Chinook IP for spawning."
- **The problem.** Bjorkstedt p. 89 uses its own spawning curves (see 4), not Agrawal's Chinook IP. Only Agrawal's Plate
  3 ("Intrinsic potential for fall-run Chinook salmon spawning and rearing habitat") supports the stage.
- **Fix.** Drop the Bjorkstedt p. 89 clause.

### 6. E27 (busch2011, CH access, tagged): a low-flow access width is linked to the bankfull spawning-width parameter (low severity)

- **What the source says.** Busch PDF p. 3: "minimum accessible channel width for fall Chinook salmon (inaccessible
  reaches are <4 m during seasonal low flow)". That is an access limit on low-flow (effectively wetted) width.
- **The problem.** The row is `life_stage = access` but has `parameter = spawn_channel_width_min`. Busch's widths come
  from a bankfull regression, and the spawning zero-edge on bankfull width is already E24 ("Channels ≤4 m wide are
  assumed unsuitable for spawners", bankfull, PDF p. 4). Linking E27 as well double-counts the parameter with a
  differently defined width.
- **Fix.** Blank `parameter` on E27. Optionally set unit `m wetted`, since the source says low flow but not wetted
  explicitly, so `m` is defensible.

## Checked and found consistent with the source

The following were each read against the source and need no change:

- **burnett2007 (E191-E206; R7-R10).**
  - Mean annual flow classes 0.06, 21.24 and 76.45 m3/s, and the coho score of 0.5 above 76.45 (p. 68-69).
  - Valley-width index 5.06 / 8.87, with coho highest and steelhead lowest when unconstrained.
  - Gradient: coho declines from 0 to no use above 7 %; steelhead peaks at 2-3 % with no use above 10 %. The access rows
    match.
  - Rearing stage, from "high-quality rearing habitat".
  - MAF modelled from Sheer Table 2, with footnotes 1, 2 and 3 resolving to Agrawal, Burnett and Clarke.
  - Validation is "density": Sheer pp. 9 and 19 compare reach IP with fish-density classes.
  - Minor: E197 and E198 place steelhead breakpoints at the 21.24 and 76.45 class bounds. Burnett says only that the
    curves were "established relative to" these classes, and the steelhead shape is figure-only. The notes say so, so
    this is acceptable.
- **busch2011 (E21, E22, E24, E26, E207-E211; R11-R12).**
  - Table I and the text match: gradient 0-2 % = 1, 4 % = 0.05, 4-7 % = 0.05, >7 % = 0; width ≤4 m = 0 and >20 m = 1;
    confinement ratio 1 = 0.25 and ≥8.87 = 1; access >16 %.
  - The width regression is on drainage area and mean annual precipitation (PDF p. 3).
  - The validation statistics (χ² 394.84, 89 % vs 43 %, p = 0.47, EDT adjusted R² 0.46) are on PDF pp. 7-8.
- **busch_nwfsc values (E212-E226).**
  - Coho barrier: ≥16 % and bankfull <1.2 m (p. 9). Chinook barrier: >16 % and <2 m (p. 13).
  - Width classes are >25 m and 2-25 m (p. 14), and the stages are spawning and rearing (p. 13).
  - The validation is a population-size comparison (p. 13).
  - Only the form is wrong (item 2).
- **blm2008 (E227-E235; R17-R19).**
  - Variable lists on pp. 8, 12 and 18. "Same data and model as Burnett" (p. 8). Burnett 2007 is applied to "Western
    Oregon (BLM)" (p. 12).
  - Validation: distribution vs IP > 0.75 (pp. 9, 13, 19).
  - The coho and steelhead stage is assumed, as the notes say.
- **dent2005 (E236; R20).** "Dent: Maximum gradient = 7%" sits under natural barriers (p. 9). The sensitivity analysis is
  correctly marked as not validation.
- **bartz2006 (E237-E240).**
  - Table 5 (p. 16) is adult capacity by bankfull-width/gradient class, so `spawning` is right even though Sheer's
    life-stage list (p. 13) files Bartz under rearing.
  - The ocean-type label is supported (p. 47).
  - The note that reaches outside the three classes have no adult capacity is an inference from the table listing only
    those classes. It is acceptable.
- **herger2003 (E241-E246; R22-R23).**
  - The variable lists (pp. 8, 12) and the figure-only curves (pp. 11, 17) match.
  - Rearing stage (pp. 9, 13).
  - `flow_metric = none` is reasonable and explained.
- **sloat2017 (E247-E268; R24-R26).**
  - Every Table 1 cell checks out (coho, pink and chum; high and moderate classes; gradient, bankfull width and depth,
    D50).
  - The criteria are Paustian (2010)'s, developed from field, fish and expert sources (p. 609).
  - The hydraulic-geometry regressions (n = 23, n = 83; w = 0.0027 A^0.5129, R² 0.92).
  - Confinement is "twice the bankfull width", with 372 reaches ground-truthed.
  - The "require field validation" statement is on p. 618.
- **agrawal2005 (E57, E60, E120, E269-E299, E302-E303; R27-R35).**
  - Figure-only curves (PDF p. 17), the Engle steelhead gradient extension and the reduced constraint score (PDF p. 14),
    and the Chinook valley constraint being less important (PDF p. 16).
  - The access sentence (PDF p. 13) and the LMAT 21 / 21.5 / 22 °C layers (PDF p. 19).
  - The Sheer numbers: CO 7 / 5 % and 0.01 m3/s with 21.5 °C; CH 8 / 3.5 % and 0.28 m3/s; ST 12 %.
  - Plate 3 says "spawning and rearing" for Chinook.
  - Bjorkstedt p. 26 applies the coho and winter steelhead IP to spawning and rearing, and p. 54 adopts 21.5 °C.
  - The gauge regression (n = 29, r² 0.988; PDF pp. 12-13).
  - Validation `none`: the Mad River barrier check was not quantified.
- **bjorkstedt2005 (E301; R81).** 50 m3/s is the conservative Chinook spawning discharge curve (p. 89), and the
  regional discharge regressions are on p. 32. Validation is `none`: the authors say the conservative curve "better
  describes" current distribution but do not test it. Only the E300 note is wrong (item 4).
- **lindley2006 (E304-E309; R36-R37).**
  - The envelope is >0.028 m3/s, <12 % and <24 °C mean August air (p. 3), with 1 cfs on p. 4.
  - The abstract says "spawning and rearing" and Figure 1 says "summer rearing".
  - The DEM + PRISM discharge was recalibrated on Central Valley data. "gauge" is inferred, as the note says.
  - No validation was found.
- **boughton_goslin2006 (E310-E326; R38).**
  - The Table 5 columns (layout: Complete, 95 %, Consensus | Consensus, 95 %, Complete) match every 95 % value and
    every complete and consensus value in the notes, for both ESUs.
  - The 95 % envelope is recommended (p. 8) and mapped (p. 10).
  - The alluvium exclusion is on p. 2. Q89 is a log-linear regression on 29 gauges (R² 0.380, p. 6).
  - VWI follows Burnett (p. 5). The qualitative map-note comparison with historical records (p. 18 onward) is
    correctly `fish_observations` with no statistic.
  - Only the parameter link is wrong (item 1).
