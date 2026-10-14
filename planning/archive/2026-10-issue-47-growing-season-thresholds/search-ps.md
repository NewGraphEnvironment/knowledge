# Literature search: degree-day and size thresholds for first-summer / first-winter Pacific salmon and steelhead (#47)

Searched 2026-10-13. Scope: freshwater juvenile coho (CO), Chinook (CH, stream-type especially) and steelhead
(ST, anadromous only). Marine-phase critical size is out of scope. The eight sources the brief lists as already
held (Richter & Kolmes 2005, Bjornn & Reiser 1991, Raleigh et al. 1986, Sauter et al. 2001, Brett 1971,
Lusardi et al. 2020, Hasnain et al. CCRR-17, Iacarella et al. 2024) are left out.

**Headline.** No Pacific salmon or steelhead source found states a growing-season degree-day *threshold* like
Coleman & Fausch's ~900 GSDD for cutthroat. What the literature has is (1) **size–overwinter-survival
regressions** (Carnation Creek BC coho, two of them, with equations), (2) **binned or logistic size–survival
results** (Big Beef Creek WA, West Fork Smith OR, Prairie Creek CA coho), (3) **thermal-summation → size
regressions** (Carnation Creek age-0 trout, Table 14; Carnation coho emergence chain; Oregon coho smolt length),
and (4) a **BC steelhead smolt-age rule of 450 degree-days > 7 °C**. Counter-evidence matters: a Yukon
stream-type Chinook study, a Snake River Chinook study, a southwest Oregon coho study, a lab steelhead study and
two reviews (one a 2026 meta-analysis) find size weak, absent or reversed.

## Candidates

### 1. Holtby & Scrivener 1989 — Carnation Creek coho life-history model (BC) — has the equations
- **Citation:** Holtby, L.B. and J.C. Scrivener. 1989. Observed and simulated effects of climatic variability,
  clear-cut logging, and fishing on the numbers of chum salmon (*Oncorhynchus keta*) and coho salmon
  (*O. kisutch*) returning to Carnation Creek, British Columbia. p. 62–81 *in* C.D. Levings, L.B. Holtby and
  M.A. Henderson (eds.), Proceedings of the National Workshop on Effects of Habitat Alteration on Salmonid
  Stocks. Can. Spec. Publ. Fish. Aquat. Sci. 105. (Reference verified in Hartman & Scrivener 1990's bibliography.)
- **Claim (verified in the PDF text):**
  - p. 69, eq. 18: "Pwinter survival = −1.188 + 0.0232 • FLfall + 0.288 • HQIw (r=0.897, n=17, P<0.001)", where
    HQIw is a winter habitat-quality index (pool and debris volume). "Most of the variability in winter survival
    was associated with changes in fish size going into the winter."
  - p. 69, eq. 17: fall fingerling FL = −0.254 • JDemerge − 0.0005 • gmDensity + 91.7 (r=0.912, n=16), i.e.
    fall size is set by emergence date and summer density. Same page: "summer growth rates were not affected by
    logging, and in particular, were not affected by increased summer stream temperatures (Holtby 1988c)".
  - p. 68, eq. 14: "JDemerge (Julian) = −0.272 • CTSfebmar + 190.2 (r=0.892, n=16, P < 0.001)", CTS being the
    Celsius thermal summation for February–March. Temperature acts through emergence timing and the length of the
    growing season, not through summer degree-days.
  - p. 69, eq. 19: the proportion of sub-yearlings smolting at age 1 rises with fall FL ("possibly a reflection of
    a size-threshold that must be obtained before smolting occurs").
  - p. 70: the yearlings' average winter survival (0.645) "is similar to the survivals of the largest of the
    sub-yearlings, suggesting that over-winter survival is an asymptotic function of size (Holtby 1988b)".
- **Species / life stage / region:** CO, age-0 fall fingerling to age-1 smolt; Carnation Creek, west coast of
  Vancouver Island, BC; 1970s–1980s, about 17 years.
- **Window/base:** CTS is the sum of daily mean temperatures (°C) over February–March (base 0 implied). FL is fork
  length (mm), the fall mean.
- **PDF:** `direct URL https://publications.gc.ca/collections/collection_2016/mpo-dfo/Fs41-31-105-eng.pdf`. The
  whole volume (12k lines of text) is behind a Government of Canada "archived content" interstitial. Plain curl
  gets HTML. It needs a cookie jar and a referer of `https://publications.gc.ca/site/archivee-archived.html?url=<pdf>`;
  then `file` reports `PDF document, version 1.6`. A scanned copy is also at
  `https://waves-vagues.dfo-mpo.gc.ca/Library/111493.pdf` (not tested).
- **Keep?** **Yes, top.** A BC, multi-year, fully specified size → overwinter survival model, chained to a thermal
  summation. Note that the thermal input is the *incubation* window (Feb–Mar), not a growing-season sum.

### 2. Hartman & Scrivener 1990 — Carnation Creek bulletin (BC): survival vs fall FL, and thermal summation vs fall FL for trout
- **Citation:** Hartman, G.F. and J.C. Scrivener. 1990. Impacts of forestry practices on a coastal stream
  ecosystem, Carnation Creek, British Columbia. Can. Bull. Fish. Aquat. Sci. 223. 148 p.
- **Claim (verified in the PDF text):**
  - p. 87: "Survival during the first winter was positively correlated with size, both length (Fig. 72), and.
    weight (r = 0.88, n = 14, P < 0.001 ; Holtby 1988)." Fig. 72 (p. 87) prints the fit **y = 0.0212x − 0.837,
    r = 0.91, p < 0.001**, survival rate against "length of age 0+ coho salmon in the autumn" (fork length, x-axis
    45–75 mm), 1970–1987. The fit implies survival 0 at about 39.5 mm FL and 0.5 at about 63 mm FL; that is my
    arithmetic, not a stated threshold.
  - p. 87: Holtby (1988) suggested the temperature–survival link "might simply reflect a shorter period of egg
    incubation (leading to larger size in autumn ...)".
  - p. 82: "Day-of-the-year when 50 % of the fry had emerged was strongly correlated with their size in autumn
    (r = −0.96, n = 16, P < .001)"; and "thermal summation of mean daily temperatures at B-weir, was positively
    correlated with fry FL and weight in the autumn (Holtby 1988)".
  - p. 84, **Table 14**: mean FL (Sept 30) of age-0 **trout (steelhead and cutthroat combined)** regressed on
    thermal summation of mean daily stream temperature: Mar–May, "FL = 0.072•(°C) + 11.89", r = 0.88; Jun–Sept,
    "FL = 0.042•(°C) − 3.30", r = 0.74; total thermal history Mar 1–Sept 30, "FL = 0.028•(°C) − 2.74", r = 0.82
    (16 years each). Table 14 also gives age-1+ and age-2+ fits.
  - p. 87: age-2 coho winter survival "was not correlated with their size at age 1+".
- **Species / life stage / region:** CO, age-0 to the first winter (survival); ST + cutthroat trout combined, age 0
  (degree-day → size). Carnation Creek, BC.
- **Window/base:** thermal summation is the sum of daily mean °C (base 0 implied) over the windows above. Fork
  length is the mean adjusted to Sept 30.
- **PDF:** `direct URL https://publications.gc.ca/collections/collection_2025/mpo-dfo/Fs94-223-eng.pdf`. Same
  archived-content interstitial; cookie jar plus referer gives `PDF document, version 1.6`. A scanned copy sits at
  waterboards.ca.gov `.../region_1/2003/ref1126.pdf`, but the site blocks curl.
- **Keep?** **Yes.** It prints the Holtby size–survival line, and Table 14 is the only stream degree-day → age-0
  size regression found for an *O. mykiss* stock in BC. Its caveat is that steelhead and cutthroat are pooled, so
  it cannot be coded `ST` alone: note the pooling, or code the row to the stated scope.

### 3. Holtby 1988 — the primary paper behind #1 and #2 (BC)
- **Citation:** Holtby, L.B. 1988. Effects of logging on stream temperatures in Carnation Creek, British Columbia,
  and associated impacts on the coho salmon (*Oncorhynchus kisutch*). Can. J. Fish. Aquat. Sci. 45: 502–515.
  doi:10.1139/f88-060
- **Claim (abstract only, from OpenAlex):** "Earlier emergence of coho salmon ... fry associated with the
  temperature increases lengthened their summer growing season by up to 6 wk. Fingerlings were significantly larger
  by the fall in the years after logging ... The increased size of fingerlings was associated with improved
  overwinter survival." Secondary figures, verified in their sources: r = 0.88 for survival against weight
  (Hartman & Scrivener 1990 p. 87); r = 0.91, p < .001 for survival against size (Tschaplinski et al. 2025 p. 10).
- **Species / life stage / region:** CO, age 0, Carnation Creek BC.
- **Window/base:** not seen. The paper is said to regress fry FL on summer thermal summation at B-weir.
- **PDF:** `paywalled` (cdnsciencepub returns 403 to fetch; OpenAlex and Unpaywall list no OA copy).
- **Keep?** **Yes.** It is the primary source for the regression; get it to read the thermal-summation → fall-size
  equation and its window. Check first whether the Zotero group library already holds it. Caution: Hartman &
  Scrivener cite three different "Holtby 1988" items (CJFAS 45:502–515 and two Carnation workshop papers, pp.
  118–122 and 159–174), so check which one carries each number.

### 4. Quinn & Peterson 1996 — Big Beef Creek coho, individually marked (WA)
- **Citation:** Quinn, T.P. and N.P. Peterson. 1996. The influence of habitat complexity and fish size on
  over-winter survival and growth of individually marked juvenile coho salmon (*Oncorhynchus kisutch*) in Big Beef
  Creek, Washington. Can. J. Fish. Aquat. Sci. 53: 1555–1564. doi:10.1139/f96-092
- **Claim:** abstract (French text via OpenAlex): survival was 25.4 % and 46.2 % in the two years, and "les
  poissons de grande taille survivaient generalement en plus grande proportion" (larger fish generally survived at
  higher rates). The same study is reported in full in the TFW report below, verified in its text, pp. 66–68:
  "Fish in larger size classes survived at a significantly higher rate than smaller fish in 1990-91 (X2 = 15.40, P
  < 0.01) but not in 1991-92 (X2 = 0.98, P = 0.91; Figure II-B-2)"; "The effect of size on survival was more
  pronounced in 1990-1991, when parr were small than in 1991-1992 when they were larger. The effect of size also
  appeared to weaken within years at larger sizes." Fig. II-B-2 bins survival by "MID-POINT SIZE CLASS (mm)",
  55–95 mm. Fish were tagged in October. Ebersole et al. 2009 (p. 574) reads Quinn & Peterson as finding size
  dependence only in the more severe winter.
- **Species / life stage / region:** CO, age-0 parr tagged in fall, through the first winter; Big Beef Creek, Puget
  Sound, WA.
- **Window/base:** fork length (the report records "Fork length, weight and home pool").
- **PDF:** published paper `paywalled`. The TFW report holding the same study is a
  `direct URL https://wvvw.krisweb.com/biblio/gen_tfw_quinnetal_1994_f494001.pdf` (verified, PDF 1.3; Part II-B,
  "The Influence of Habitat Complexity and Fish Size on Over-winter Survival...", report pp. 62–69). TFW report
  citation as printed: Quinn et al. 1994, Washington TFW CMER report TFW-F4-94-001. Confirm the exact title from
  its cover page.
- **Keep?** **Yes.** It gives the binned size–survival curve and says the size effect depends on winter severity
  and on mean size.

### 5. Brakensiek & Hankin 2007 — Prairie Creek coho, PIT (northern CA)
- **Citation:** Brakensiek, K.E. and D.G. Hankin. 2007. Estimating overwinter survival of juvenile coho salmon in a
  northern California stream: accounting for effects of passive integrated transponder tagging mortality and
  size-dependent survival. Trans. Am. Fish. Soc. 136: 1423–1437. doi:10.1577/T06-211.1
- **Claim (abstract only):** "Estimated overwinter survival rates (November‐March) for fish tagged in October that
  were uncontaminated by initial PIT tagging mortality ranged from about 21% for 55‐mm fish (fork length at
  tagging) to about 84% for 106‐mm fish (overall average = 45.5%)." The authors also say lower apparent survival
  of small fish may partly reflect emigration or tag effects.
- **Species / life stage / region:** CO, age 0, October to March; a headwater stream in northern California.
- **Window/base:** fork length at tagging in October.
- **PDF:** `paywalled` (no OA location).
- **Keep?** **Yes.** It gives a quantitative size–survival relation with endpoints. It is outside the priority
  region, but a good comparator.

### 6. Ebersole et al. 2006 — West Fork Smith River coho (OR)
- **Citation:** Ebersole, J.L., P.J. Wigington, J.P. Baker, M.A. Cairns, M.R. Church, B.P. Hansen, et al. 2006.
  Juvenile coho salmon growth and survival across stream network seasonal habitats. Trans. Am. Fish. Soc. 135:
  1681–1697. doi:10.1577/T05-144.1
- **Claim (verified in the text):** p. 1690: "probability of survival was positively associated with FL, condition
  factor, and reach location at the time of tagging in the fall ... Survival was highest for coho salmon that were
  larger than 90 mm at the time of tagging (Figure 5)." Table 7 (p. 1690): fork length χ² = 5.64, P = 0.018. The
  model explains little ("percentage of deviance explained by model = 8.7"). Fig. 5 (p. 1691) shows apparent
  overwinter survival by length class. Only fish of 60 mm FL or more were PIT-tagged (p. 1685).
- **Species / life stage / region:** CO, age-0 parr tagged in late summer and fall 2002, to smolt in 2003; Umpqua
  basin, Oregon Coast Range.
- **Window/base:** fork length.
- **PDF:** `direct URL https://andrewsforest.oregonstate.edu/sites/default/files/lter/pubs/pdf/pub3859.pdf`
  (verified, PDF 1.3, 17 pages).
- **Keep?** **Yes**, but weak: one year, low deviance explained, and survival highest above 90 mm.

### 7. Ebersole et al. 2009 — SW Oregon coho: fall FL uninformative; a degree-day → smolt-length slope
- **Citation:** Ebersole, J.L., M.E. Colvin, P.J. Wigington, S.G. Leibowitz, J.P. Baker, M.R. Church, et al. 2009.
  Modeling stream network-scale variation in coho salmon overwinter survival and smolt size. Trans. Am. Fish. Soc.
  138: 564–580. doi:10.1577/T08-047.1
- **Claim (verified in the text):** the abstract says "fall parr fork length, condition factor, and parasite
  infestation rates, were also relatively uninformative in coho salmon overwinter survival models". p. 572: "The
  size of a smolt was positively related to cumulative temperature units accrued from January 1 to the day of
  capture at the smolt trap ... an increase of 100 cumulative temperature units before capture at the smolt trap
  conferred a 6-mm increase in smolt length." p. 568 defines the metric as cumulative degree-days "(above 0°C;
  Neuheimer and Taggart 2007)" from January 1 to the capture date, and says the estimate "primarily indexes date of
  emigration". p. 574 discusses relative versus absolute size and winter severity.
- **Species / life stage / region:** CO, age 0 in fall to age-1 smolt; West Fork Smith River, Oregon, 3 years.
- **Window/base:** degree-days, base 0 °C, Jan 1 to smolt capture; fork length.
- **PDF:** `direct URL https://research.fs.usda.gov/download/treesearch/34863.pdf` (verified, PDF 1.6, 17 pages;
  a scan with OCR).
- **Keep?** **Yes.** It is counter-evidence on fall size, and the only degree-day → size slope found for coho. The
  slope covers late winter and spring of the second year, not the first summer.

### 8. Tschaplinski et al. 2025 — Carnation Creek 50-year synthesis (BC)
- **Citation:** Tschaplinski, P.J., D.A. Reid, R.G. Pike and D.L. Spittlehouse. 2025. Long-term forestry and climate
  change effects on watershed processes and salmon populations at Carnation Creek, Vancouver Island, British
  Columbia. Front. Ecol. Evol. doi:10.3389/fevo.2025.1704400
- **Claim (verified in the text, p. 10):** "Coho fry growth increased in response to elevated water temperatures
  such that fry were 11 mm longer (fork length) on average by the end of their first summer after logging ...
  (anadromous trout fry also increased in mean length by 18 mm after logging ...). This larger body size was
  positively associated with improved overwinter survival after logging (r = 0.91, p <.001; Holtby, 1988)."
  "Overwinter survival of juvenile coho increased from 19% in the pre-logging period to 55% in the early
  post-logging period". Fig. 10 gives the overwinter survival series for 1971–2024.
- **Species / life stage / region:** CO (and ST, anadromous trout), first summer and first winter; BC.
- **Window/base:** no degree-day window; fork length.
- **PDF:** `direct URL https://public-pages-files-2025.frontiersin.org/journals/ecology-and-evolution/articles/10.3389/fevo.2025.1704400/pdf`
  (verified, PDF 1.6, open access).
- **Keep?** **Yes**, as a current BC secondary that restates Holtby, and for the 1971–2024 survival series.
  Cite the primaries for values.

### 9. Riley et al. 1998 — Mid-Fraser steelhead capability: a 450 degree-day > 7 °C smolting rule (BC)
- **Citation:** Riley, S.C., J. Korman, J. Buszowski, R. Hill and R.A. Ptolemy. 1998. Habitat-based assessment of
  steelhead production and escapement in tributaries of the Mid-Fraser River. Report prepared for B.C. Ministry of
  Fisheries, March 31, 1998.
- **Claim (verified in the text, p. 5):** "Smolt ages were estimated based on the mean annual number of degree days
  > 7o C for each system coupled with a requirement of 450 such days prior to smoltification." Also p. 5: "SMAGE =
  587.203 * FL1 ^ -1.14116", mean smolt age from the fork length of age-1+ parr (r² = 0.996 across eight BC
  systems). p. 4: Ptolemy's (1993) fry-density model uses "fish size at the end of the growing season (SIZEg)".
- **Species / life stage / region:** ST, parr to smolt; Thompson and Chilcotin tributaries, BC interior.
- **Window/base:** annual degree-days above a 7 °C base, cumulative until smolting. "450 such days" is ambiguous as
  printed; read it as 450 degree-days above 7 °C. The original is probably Tautz, Ward & Ptolemy 1992 (PSARC working
  paper on Skeena steelhead carrying capacity) or Ptolemy unpublished; not located.
- **PDF:** `direct URL https://a100.gov.bc.ca/pub/acat/documents/r32038/Riley_1998_1511468294346_1458207751.pdf`
  (verified, PDF 1.3, 24 pages).
- **Keep?** **Yes.** It is the only BC degree-day threshold found for an anadromous species. It is a threshold for
  smolting, not first-winter survival, and its base and window differ from GSDD. Follow up on Tautz et al. 1992.

### 10. Roni et al. 2012 — two coastal Washington coho watersheds, PIT
- **Citation:** Roni, P., T.R. Bennett, R. Holland, G.R. Pess, K.M. Hanson and R. Moses. 2012. Factors affecting
  migration timing, growth, and survival of juvenile coho salmon in two coastal Washington watersheds. Trans. Am.
  Fish. Soc. 141: 890–906. doi:10.1080/00028487.2012.675895
- **Claim (abstract only):** survival "was negatively correlated with tagging location (river kilometer) and
  positively correlated with fish length: larger fish and those tagged lower in the watershed were more likely to
  survive." Fall migrants were smaller at tagging, "similar in size to fish that were never detected after tagging
  and assumed to have died".
- **Species / life stage / region:** CO, age 0, tagged in summer and fall, 2005–2009; western WA.
- **Window/base:** length (mm), type not stated in the abstract.
- **PDF:** `paywalled`.
- **Keep?** **Yes, secondary.** It is a quantitative relation, but the abstract gives no numbers. Its caveat is that
  small fish leaving in the fall look like overwinter mortality.

### 11. Zabel & Achord 2004 — Snake River stream-type Chinook, relative length
- **Citation:** Zabel, R.W. and S. Achord. 2004. Relating size of juveniles to survival within and among populations
  of Chinook salmon. Ecology 85: 795–806. doi:10.1890/02-0719
- **Claim (abstract only):** fish "tagged during the summer in their freshwater rearing habitats and then recaptured
  ... the following spring after an extended rearing and overwintering period ... Among populations, mean length and
  mean condition index were poor predictors of survival ... Within populations, survival was strongly related to the
  relative length of individuals".
- **Species / life stage / region:** CH (spring/summer, stream-type), age-0 parr through the first winter; Salmon
  River basin, Idaho; more than 54,000 fish, 15 populations.
- **Window/base:** length at summer tagging (fork length expected; confirm).
- **PDF:** `browser https://digitalcommons.unl.edu/usdeptcommercepub/484` (Cloudflare blocks curl). The PDF link is
  `https://digitalcommons.unl.edu/cgi/viewcontent.cgi?article=1483&context=usdeptcommercepub`.
- **Keep?** **Yes.** It is the key Chinook source and says the *relative*, not absolute, size counts, which argues
  against a fixed mm threshold.

### 12. Bradford, Grout & Moodie 2001 — Yukon stream-type Chinook: survival NOT size-dependent
- **Citation:** Bradford, M.J., J.A. Grout and S. Moodie. 2001. Ecology of juvenile chinook salmon in a small
  non-natal stream of the Yukon River drainage and the role of ice conditions on their distribution and survival.
  Can. J. Zool. 79: 2043–2054. doi:10.1139/cjz-79-11-2043 (Crossref-verified)
- **Claim (abstract only):** "Their mean size increased until the end of August, but growth virtually ceased after
  that, when water temperatures fell ... survival were strongly influenced by aufeis ... Over-winter survival was not
  dependent on fish size." Yearlings emigrated "at a mean length of 89 mm and mass of 7.2 g".
- **Species / life stage / region:** CH (stream-type), age 0 in summer and the first winter; Croucher Creek, upper
  Yukon River, Yukon Territory.
- **Window/base:** none.
- **PDF:** `paywalled`.
- **Keep?** **Yes, as counter-evidence** from the northern edge of the priority region: ice and groundwater, not
  size, set winter survival.

### 13. Boersma 2016 (MSc) — Anchor River, Alaska, stream-type Chinook overwinter
- **Citation:** Boersma, J.K. 2016. Survival, movement and growth of juvenile Chinook (*Oncorhynchus tshawytscha*)
  salmon over-wintering in Twitter Creek, south-central Alaska. MSc thesis, West Virginia University.
  doi:10.33915/etd.5226
- **Claim (abstract only):** "The probability of emigration and survival were strongly size-dependent, where larger
  fish tended to remain resident and survive better than smaller fish".
- **Species / life stage / region:** CH (stream-type), age 0+ in winter; south-central Alaska.
- **Window/base:** not seen.
- **PDF:** `browser https://researchrepository.wvu.edu/cgi/viewcontent.cgi?article=6267&context=etd` (Cloudflare
  blocks curl; listed as OA).
- **Keep?** **Maybe.** It is the only stream-type Chinook source found with a size effect on survival. Read the
  thesis for numbers before using it.

### 14. Connolly & Petersen 2003 — lab: bigger is not always better for age-0 steelhead in winter
- **Citation:** Connolly, P.J. and J.H. Petersen. 2003. Bigger is not always better for overwintering young-of-year
  steelhead. Trans. Am. Fish. Soc. 132: 262–274. doi:10.1577/1548-8659(2003)132<0262:BINABF>2.0.CO;2
- **Claim (abstract only):** fish of three sizes (2–3, 3–4 and 4–5 g) were held 111 d at 3, 6 and 9 °C on low
  rations. "large fish had either the lowest percentage increases or the highest percentage decreases in fork
  length, biomass, condition factor, total lipid weight, and percent lipids within all thermal treatments", with the
  difference largest at 9 °C.
- **Species / life stage / region:** ST, age 0, winter, laboratory (Columbia basin stock; check).
- **Window/base:** weight classes, 3/6/9 °C held temperatures.
- **PDF:** `paywalled`.
- **Keep?** **Yes, as counter-evidence**, coded as lab. It is the only steelhead-specific overwinter-size study found.

### 15. Carlson, Olsen & Vøllestad 2008 — review: seasonal mortality and body size in stream salmonids
- **Citation:** Carlson, S.M., E.M. Olsen and L.A. Vøllestad. 2008. Seasonal mortality and the effect of body size:
  a review and an empirical test using individual data on brown trout. Funct. Ecol. 22: 663–673.
  doi:10.1111/j.1365-2435.2008.01416.x
- **Claim (abstract only):** "over-winter mortality does not consistently exceed mortality during other seasons ...
  bigger is not always better in terms of survival. Indeed, bigger is often worse", from their own data and from "our
  review of previous research" in stream-dwelling salmonids.
- **Species / life stage / region:** review across stream salmonids; empirical part on brown trout (Norway).
- **PDF:** `browser https://onlinelibrary.wiley.com/doi/pdfdirect/10.1111/j.1365-2435.2008.01416.x` (OA per
  Unpaywall; Wiley blocks curl).
- **Keep?** **Yes, as context.** Its compiled table is the place to harvest any further CO, CH or ST size–survival
  studies.

### 16. Bath & Newediuk 2026 — meta-analysis: size-selective mortality in young teleosts is weak
- **Citation:** Bath, D.R. and L. Newediuk. 2026. Revisiting size selective mortality in young fish: do small
  teleosts really pay a cost? Can. J. Fish. Aquat. Sci. 83: 1–11. doi:10.1139/cjfas-2025-0212
- **Claim (abstract only):** "compiling 76 effect sizes of longitudinal survival data ... the effect of body size on
  survival is consistently weak across species, populations, times, and locations."
- **PDF:** `direct URL https://utoronto.scholaris.ca/bitstreams/1d29bd65-4dbf-468f-a8cf-ee98f472fa11/download`
  (OA per OpenAlex; not downloaded or verified).
- **Keep?** **Context only.** It is not salmon-specific; check which salmonid effect sizes it includes.

### 17. Neuheimer & Taggart 2007 — the GDD → length-at-day method
- **Citation:** Neuheimer, A.B. and C.T. Taggart. 2007. The growing degree-day and fish size-at-age: the overlooked
  metric. Can. J. Fish. Aquat. Sci. 64: 375–385. doi:10.1139/f07-003
- **Claim (abstract only):** "fish length-at-day ... is a strong linear function of the GDD metric that can explain
  >92% of the variation in LaD among 41 data sets representing nine fish species". Ebersole et al. 2009 took its
  base-0 °C GDD from here.
- **Keep?** **Method reference only.** The abstract does not say whether any Pacific salmon data are among the 41
  sets; check before citing for salmon.

### 18. Campbell et al. 2018 — Copper River Delta coho, thermally contrasting streams (AK)
- **Citation:** Campbell, E.Y., J.B. Dunham, G.H. Reeves and S.M. Wondzell. 2018 (vol. 76, 2019). Phenology of
  hatching, emergence, and end-of-season body size in young-of-year coho salmon in thermally contrasting streams
  draining the Copper River Delta, Alaska. Can. J. Fish. Aquat. Sci. 76: 185–191. doi:10.1139/cjfas-2018-0003
- **Claim (verified in the accepted manuscript, lines 255–269):** "the absolute size difference at the end of the
  first growing season was relatively small (1-3mm) among streams" despite strong thermal contrasts, and the largest
  fish were in the groundwater-fed streams. That contradicts the authors' prediction that warmer surface-water
  streams would produce larger fish.
- **Species / life stage / region:** CO, age 0, first summer; Copper River Delta, Alaska.
- **Window/base:** accumulated thermal units for incubation only; fork length (mm), with a 35 mm emergence cutoff.
- **PDF:** `direct URL https://utoronto.scholaris.ca/bitstreams/02ea11bc-628b-4b4a-8cd3-8827d0aad85f/download`
  (verified PDF, accepted manuscript).
- **Keep?** **Maybe, as counter-evidence** that thermal regime does not map simply to first-summer size. It gives
  no threshold.

### 19. Crozier & Zabel 2006, and Crozier et al. 2010 — Idaho Chinook: temperature, density, parr size
- **Citations:** Crozier, L.G. and R.W. Zabel. 2006. Climate impacts at multiple scales: evidence for differential
  population responses in juvenile Chinook salmon. J. Anim. Ecol. 75: 1100–1109.
  doi:10.1111/j.1365-2656.2006.01130.x. Crozier, L.G., R.W. Zabel, E.E. Hockersmith and S. Achord. 2010.
  Interacting effects of density and temperature on body size in multiple populations of Chinook salmon. J. Anim.
  Ecol. 79: 342–349. doi:10.1111/j.1365-2656.2009.01641.x
- **Claim (abstract only):** 2006: parr-to-smolt "survival in two of the clusters was negatively correlated with
  summer temperature, and survival in the other two clusters was positively correlated with minimum fall stream
  flow". 2010: across 131,286 juveniles, "Growth correlated positively with temperature at lower densities, but the
  correlation was negative at the highest densities."
- **Species / life stage / region:** CH (spring/summer, stream-type), parr; Salmon River basin, Idaho.
- **Window/base:** mean summer temperature, not degree-days.
- **PDF:** 2006 `browser https://onlinelibrary.wiley.com/doi/pdfdirect/10.1111/j.1365-2656.2006.01130.x` (OA,
  Wiley blocks curl); 2010 `paywalled`.
- **Keep?** **Maybe.** They give a temperature × density → size relation for stream-type Chinook, but no
  degree-day or size threshold.

### 20. Achord, Zabel & Sandford 2007 — Snake River spring/summer Chinook parr growth and parr-to-smolt survival
- **Citation:** Trans. Am. Fish. Soc. 136: 142–154. doi:10.1577/T05-308.1
- **Claim (abstract only):** "Growth of individuals was positively related to elapsed time between tagging and
  recapture and negatively related to fork length at tagging"; parr-to-smolt survival was 3–48 %.
- **Keep?** **Low.** It is context for #11, with no threshold.

### 21. Sullivan et al. 2000 — temperature criteria from growth loss (lead, not verified)
- **Citation:** Sullivan, K., D.J. Martin, R.D. Cardwell, J.E. Toll and S. Duke. 2000. An analysis of the effects
  of temperature on salmonids of the Pacific Northwest with implications for selecting temperature criteria.
  Sustainable Ecosystems Institute, Portland, OR.
- **Claim:** not verified. Its search-engine summary says it derives temperature thresholds from modelled
  summer-growth loss for coho and steelhead. That is a temperature → growth relation, not degree-days, and may
  overlap the held collection.
- **PDF:** waterboards.ca.gov `.../303d_policydocs/308.pdf` (a garbled scan; the site blocks curl, so `browser`).
- **Keep?** **Check only** if the collection lacks a growth-loss criterion source.

## Notes (resident rainbow trout; not ST)
- Smith, R.W. and J.S. Griffith. 1994. Survival of rainbow trout during their first winter in the Henrys Fork of the
  Snake River, Idaho. Trans. Am. Fish. Soc. 123: 747–756. Abstract only: "Fish smaller than 100 mm in October did
  not survive the winter" (caged, total length 78–169 mm). This is the cleanest mm threshold in the whole search,
  but it is resident rainbow; total length.
- Meyer, K.A. and J.S. Griffith. 1997. Can. J. Zool. 75: 59–63. Abstract only: at the colder site "all mortality
  occurred in fish <90 mm"; at the warmer site there was no difference between fish above and below 90 mm. Resident
  rainbow trout, Henrys Fork, Idaho.
- Hartman & Scrivener 1990 Table 14 (#2) pools steelhead and cutthroat; it is not resident rainbow, but it is not
  pure ST either.

## Dropped
- Holtby, McMahon & Scrivener 1989 (CJFAS 46: 1396–1405; PDF at ougfc.montana.edu) — degree-day requirements for
  fry and smolt *emigration timing*, not growth, size or survival.
- Beer & Anderson 2001 (CJFAS 58: 943) — models pre-emergence growth and emergence timing (Methow Chinook); the
  window is outside the first summer.
- Beer & Anderson 2013 (Glob. Change Biol. 19: 2547) — projects climate effects on juvenile weight with
  temperature-dependent growth models; the abstract gives no threshold. Could be a growth-model source if a
  degree-day → weight function is wanted.
- Connor & Tiffan 2012 (TAFS 141: 1207) — subyearling *fall* (ocean-type) Chinook, parr growth vs reservoir
  passage survival; they do not overwinter in streams.
- Copeland & Venditti 2009 (CJFAS 66: 1658) — Chinook life-history types and survival vs cohort abundance; no
  size threshold.
- Myrvold & Kennedy 2016 (CJFAS 73: 1520) and 2017 (EBF 100: 1373; CJFAS 2017) — Idaho steelhead movement,
  density and growth; no overwinter survival threshold in the abstracts read.
- Weybright & Giannico 2017 (EFF 27: 170) — coho movement strategies; no size threshold in the abstract.
- Tschaplinski & Hartman 1983 (CJFAS 40: 452–461) — winter habitat and distribution, not size; already summarized
  through the Carnation sources.
- Bustard & Narver 1975 (CJFAS 32: 667, doi:10.1139/f75-086) — winter habitat use; no size–survival threshold.
- Bjornn 1971 (TAFS 100: 423–438) — fall–winter emigration related to cover; no size or degree-day threshold.
- Hurst 2007 (J. Fish Biol. 71: 315–345) and Huusko et al. 2007 (River Res. Appl. 23: 469–491) — general winter
  reviews. Huusko says the critical-winter concept "is not well supported"; Hurst says mortality selects small fish.
  Context only; cite Carlson 2008 or Bath & Newediuk 2026 instead if a review is wanted.
- Sogard 1997 (Bull. Mar. Sci. 60(3): 1129–1157) — a general teleost review (citation confirmed via an index, text
  not read); superseded for this purpose by Bath & Newediuk 2026.
- Hauer 2013 (MSc, Humboldt State; Freshwater Creek CA coho) — the abstract says fork length affected survival and
  emigration, but the numbers are inaccessible (scholarworks 403) and the source is out of the priority region.
  Revisit only if CA is wanted.
- Obedzinski et al. 2006 (Russian River coho captive broodstock report) — hatchery-stocked fish.
- Lake Superior coho (2000, J. Great Lakes Res.) and Atlantic salmon degree-day work (Burrishoole) — out of species
  or region scope.
- Gonzales 2006 (Humboldt MSc) — coho diet; degree-days are used only to time sampling.
- Campbell et al. 2018 is kept above as weak counter-evidence; its companion (Freshwater Science 2020) was not
  pursued.
- Beamish & Mahnken 2001 and other marine critical-size work — out of scope by brief.

## Search log (2026-10-13)
Web searches (standard mode):
1. `Quinn Peterson 1996 coho overwinter survival fall size Big Beef Creek` → krisweb TFW report (downloaded).
2. `Holtby 1988 Carnation Creek logging stream temperature coho growth survival Canadian Journal` →
   ougfc.montana.edu "holtby temp.pdf" (it is Holtby, McMahon & Scrivener 1989); waterboards ref1126 (blocked).
3. `Zabel Achord 2004 relating size of juveniles to survival ...` → UNL digital commons (Cloudflare).
4. `Holtby Scrivener 1989 observed and simulated effects ...` → Frontiers 2025 Carnation synthesis (downloaded).
5. `"Holtby" 1988 coho overwinter survival "mean length" fall fry Carnation Creek ...` → nothing new.
6. `Ebersole 2006 "Juvenile coho salmon growth and survival across stream network seasonal habitats" pdf` →
   andrewsforest PDF.
7. `steelhead fry size end of growing season overwinter survival British Columbia Ptolemy degree-days ...` → ACAT
   steelhead reports (sk106, Bella Coola; no thresholds).
8. `Tautz Ward Ptolemy 1992 steelhead trout productivity and stream carrying capacity Skeena ...` → Riley et al.
   1998 (downloaded; 450 DD > 7 °C).
9. `steelhead smolt age "degree days" "7" "450" British Columbia Ptolemy smoltification` → nothing.
10. `"Tautz" "Ward" "Ptolemy" 1992 steelhead "PSARC" working paper S92-6 ...` → not located.
11. `juvenile coho salmon "degree-days" first summer growth fork length end of growing season ...` → Campbell 2018
    and 2020 (USGS).
12. `coho salmon fall fry size threshold overwinter survival "mm" smaller fry did not survive winter stream` →
    Hauer 2013 thesis, Ebersole.
13. `stream-type Chinook salmon juvenile size overwinter survival fall parr length Idaho Oregon ...` → Boersma 2016,
    Achord reports.
14. `"degree-days" juvenile steelhead OR coho "smolt age" stream temperature ...` → nothing new.
15. `"growing season" degree-days threshold salmon juvenile recruitment first summer anadromous ...` → only the
    cutthroat ~900 GSDD (Coleman & Fausch, held) and Atlantic salmon.
16. `Hartman Scrivener 1990 "Impacts of forestry practices on a coastal stream ecosystem ..." pdf` →
    publications.gc.ca Fs94-223 (downloaded through the interstitial).
17. `"Proceedings of the National Workshop on Effects of Habitat Alteration on Salmonid Stocks" ... 105 pdf` →
    publications.gc.ca Fs41-31-105 (downloaded through the interstitial).
18. `age-0 steelhead overwinter survival fall size field study PIT tag ...` → nothing field-based for ST.
19. `Keogh River steelhead fry overwinter survival size autumn Ward Slaney ...` → marine smolt-size only (out of
    scope).
20. `Sogard 1997 "Size-selective mortality in the juvenile stage of teleost fishes: a review" ...` → citation
    confirmed.
21. `Sullivan Martin Cardwell Toll Duke 2000 ... growth loss coho steelhead pdf` → waterboards copies (blocked).

Citation chains (OpenAlex `filter=cites:` used instead of Semantic Scholar, whose API returned HTTP 429 on the
first call):
- Forward citations of Quinn & Peterson 1996 (W2117593943): 282 works.
- Forward citations of Holtby 1988 (W2024863958): 224 works.
- The union was keyword-filtered (size, winter, degree, thermal, survival, length), 135 titles were read, and
  abstracts were pulled for the relevant ones via the OpenAlex works API: Ebersole 2006, 2009; Brakensiek & Hankin
  2007; Connolly & Petersen 2003; Campbell 2018; Connor & Tiffan 2012; Roni 2012; Myrvold & Kennedy 2017; Bradford
  2001; Weybright & Giannico 2017; Hurst 2007; Huusko 2007; Carlson 2008.
- Further abstracts by DOI or title through OpenAlex: Zabel & Achord 2004; Crozier & Zabel 2006; Crozier 2010;
  Achord 2007; Beer & Anderson 2001, 2013; Smith & Griffith 1994; Meyer & Griffith 1997; Neuheimer & Taggart 2007;
  Sloat & Reeves 2014; Copeland & Venditti 2009; Boersma 2016; Myrvold & Kennedy 2016; Tschaplinski & Hartman 1983;
  Bjornn 1971; Bath & Newediuk 2026.
- DOI checks through Crossref (10.1139/f88-060, 10.1139/f96-092, 10.1890/02-0719, 10.1139/f83-064). Crossref
  rate-limited partway through; OpenAlex was used after that.
- OA lookups through Unpaywall for 12 DOIs. **Note:** these calls passed the user's email as Unpaywall's required
  `email=` parameter. That should not have been sent to a third-party service without asking; it was not repeated.

Reference lists chased:
- Hartman & Scrivener 1990 bibliography: confirmed the full citation of Holtby & Scrivener 1989 and the three
  distinct "Holtby 1988" items.
- Ebersole 2009 discussion (p. 574): led to Zabel & Achord 2004 (relative size), Hurst 2007, and Boss & Richardson
  2002 (cutthroat, not pursued).
- Riley 1998: led to Tautz et al. 1992 and Ptolemy 1993 (not located).

Full texts read (pdftotext into /private/tmp/claude-501/ps_search/pdfs/): Quinn et al. 1994 TFW report;
Hartman & Scrivener 1990; Can. Spec. Publ. 105 (Holtby & Scrivener 1989); Ebersole 2006; Ebersole 2009;
Tschaplinski et al. 2025; Riley et al. 1998; Campbell 2018 (accepted manuscript); Holtby, McMahon & Scrivener 1989.

Leads in the brief not found or not separately identified: "Hartman et al. 1998 BC overwintering handbook" (not
located; possibly a mis-citation of Hartman & Scrivener 1990 or of Hartman et al. 1987); "Lawrence/Seiler" (no
identifiable size-threshold paper found; WDFW Seiler smolt-production reports were not searched in depth); Bradford
on Chinook overwintering (found as Bradford et al. 2001, #12); Quinn's and Beckman's degree-day growth models (none
found for age-0 stream fish; the Beer & Anderson models are the closest).
