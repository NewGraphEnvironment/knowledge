# Review p4 round 1: research/ip_models.md and the doc diffs (#29)

Checked against data/ip_model_registry.csv (81 rows, 17 model_ids), the model_id-tagged rows of
data/literature_evidence.csv, scripts/0280, pkg/R/ip.R, pkg/R/literature.R, planning/active/findings.md,
draft-*-notes.md, and the scratch PDF texts. The latest registry verify log
(20261001_literature_verify_ip_registry.csv) is 117/117 verified_text.

Confirmed correct (no action): the 17-model count and region lists; the per-model flow table's metric,
source and inputs for every model; every value in the threshold table except item 2; the Sheer p. 6 quote
(PDF page 13 = printed p. 6) and the p. 36 workshop point (Table B2, printed p. 36, 2008 workshop);
Cooney & Holzer C-7 quote; every model's validation coding in the Validation section; "five models
threshold on modelled width"; "grayling appears once, in Rebellato"; 104 of 246 groups; lake_area = ha
only; no stream_order in the registry flow_metric vocabulary; 0280's link check is on
model x species x stage x form both ways, registry flow and validation quotes are gated, and
EVIDENCE=/REGISTRY=/LOG= behave as scripts/README says.

## Errors

1. **research/ip_models.md:9-10** says "Every claim below is a registry or evidence row with a verbatim
   quote found in its PDF." False for several claims: the p. 36 workshop point (lines 52-53) is in no CSV;
   busch2011's 43 %, chi-squared 394.84 and "did not predict abundance" (lines 85-87) are in
   `validation_result` free text, not the gated `validation_quote` (which covers only the 89 %); the
   29 gauges / R² 0.38 (line 44) and the "not fully independent" caveats are in `note`; the 104 of 246
   (line 68) is from findings.md; the species search (lines 107-110) is not a row. Fix: "Every value and
   model attribution below is a registry or evidence row; quoted claims were found in their PDFs, and the
   remaining statements come from the rows' notes and results or from the #29 findings."

2. **research/ip_models.md:59** puts "1.2 m bankfull barrier (`busch_nwfsc`)" under **CO rearing**. The
   evidence row (Sheer p. 9) and the registry row are `busch_nwfsc` CO **access**; busch_nwfsc has no CO
   rearing row. Fix: drop it from CO rearing (add a CO access line, or note it as an access barrier).

3. **research/ip_models.md:55-65** "Thresholds exist in both currencies, at similar levels across models"
   omits CH width minima that are tagged rows and fall outside the shown range: `busch_nwfsc` CH spawning
   and rearing 2 m (rear/spawn_channel_width_min, Sheer p. 14) and CH access < 2 m bankfull (p. 13), and
   `bartz2006` CH spawning 5 m bankfull (Sheer p. 16). The table includes busch_nwfsc's analogous coho
   1.2 m barrier, so the selection is inconsistent and makes the CH spread look tighter (3.6-4 m) than the
   registry's (2-5 m). Fix: add 2 (`busch_nwfsc`) to CH rearing and CH spawning width, and 5 bankfull
   (`bartz2006`) to CH spawning, or state the table is a selection.

4. **research/ip_models.md:105-110** heads "Species with no IP model: **RB**, WCT and GR", while line 16
   and the registry have `porter2008` RB rearing (4 tagged evidence rows). Line 110 also calls Porter's RB
   "resident rainbow trout"; the registry note says "RB is juvenile O. mykiss in FDIS (steelhead not
   separated)". Fix: "WCT and GR have no IP model; RB appears only in Porter 2008, as juvenile O. mykiss
   (steelhead not separated)."

5. **research/ip_models.md:108** "cutthroat appears only in reference lists and species lists" is
   contradicted by the texts: Porter 2008 body text (Rosenfeld et al. 2000 could predict cutthroat from
   stream size), Bjorkstedt 2005 life-history and genetics paragraphs, Boughton & Goslin's parameter
   listing ("Downstream gradient to bar fish passage(cutthroat?)" 0.20), and Sheer Table 9 (WDFW 2000
   gradient usability/passability by species, p. 26-27). Fix: "cutthroat has no thresholds in any model
   document: it appears in reference lists, species lists and passing mentions (Porter citing Rosenfeld
   2000; Boughton & Goslin's barrier parameter; Sheer's WDFW 2000 Table 9, shading only)."

6. **research/ip_models.md:88** heads the list "Compared with fish records the model was not fitted to",
   but the registry notes say `blm2008` reuses Burnett's barriers "placed partly from 1:100,000-scale fish
   distribution maps ... so any fish comparison is not wholly independent", and `woll2017` is caveated on
   line 91-92 as not fully independent. The heading contradicts its own sub-items, and blm2008 (line 95)
   carries no caveat. Fix: head it "Compared with fish records, no statistic" and add the blm2008
   caveat to line 95.

7. **research/ip_models.md:15-16** "written for every species it covers": Sheer Table A1 lists steelhead
   for `busch_nwfsc` (registry note: "Table A1 lists coho, steelhead, spring and fall Chinook"), and the
   registry has no busch_nwfsc ST row. Fix: "written for every species and stage the source gives a value
   for".

8. **CLAUDE.md:30** "each claim quoted" and **scripts/README.md:329** "and its validation, each with a
   verbatim quote": the registry has two quote columns, flow (`quote`) and validation (`validation_quote`).
   `valley_confinement` has no quote, and `validation = none` rows carry no quote by rule (ip.R:
   "an absence cannot be quoted"). Fix: "its flow claim and any validation claimed, each quoted".

9. **scripts/README.md:329** "It holds no numbers": `validation_result` holds statistics (chi-squared
   394.84, R² 0.46) and `note` holds equations and counts. Fix: "It holds no threshold values".

10. **research/ip_models.md:45** "Field widths regressed on drainage area and precipitation" includes
    `busch2011`, whose registry inputs are `drainage_area;precipitation` without `field_measurement` and
    whose note says "The regression's training widths are not described." Fix: list busch2011 in the
    parenthetical as "training widths not described", or drop "Field" for it.

11. **research/ip_models.md:42** lists `woll2015` under "Regression of gauge flows on drainage area and
    mean annual precipitation"; its registry note says the gauge basis is "our reading; the report does
    not say". Fix: mark it "(gauge basis inferred)".

12. **research/ip_models.md:20** puts `bartz2006` (Snohomish, Puget Sound) under "Oregon and Washington
    coast, Columbia". Fix: "Oregon and Washington (coast, Puget Sound, Columbia)".

13. **research/ip_models.md:32** says the agency layers "(ODFW, NOAA, CDFW, ...)" are implementations of
    Burnett's, Agrawal's and Cooney & Holzer's models. findings.md attributes only the NOAA **SWFSC**
    layers to Agrawal; NOAA NWFSC's IP is Busch's (`busch_nwfsc`). Fix: "NOAA SWFSC".

14. **research/ip_models.md:78** "Compare `cw` and `mad` classification where both exist (the Fraser, the
    Bulkley)" contradicts line 68: our modelled MAD covers the Fraser, Columbia and Peace and **none of the
    Skeena**, so the Bulkley has no `mad`. The Bulkley MAD was Rebellato's (Foundry Spatial 2021), not ours.
    Fix: "where both exist (the Fraser, Columbia and Peace groups)".
