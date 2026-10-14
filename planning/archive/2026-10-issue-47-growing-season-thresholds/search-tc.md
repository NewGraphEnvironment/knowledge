# Search: degree-day and size thresholds for age-0 trout and char (first summer and first winter)

**Searched:** 2026-10-13 · **Scope:** freshwater age-0 WCT, BT, RB, other cutthroat; brook and brown trout lower priority.
Excludes the sources already held (Coleman & Fausch 2007a,b; Thorley et al. 2021/2022 UFR; Hill et al. 2024/2025;
Bear et al. 2005/2007; McPhail & Baxter 1996; Selong et al. 2001) except where a new document restates them with new content.

Page convention: "p." is the printed page number; "pdf p." is the PDF page where no printed number was found.
"Verified" means I read the sentence in the full text. "Abstract only" means the full text was not obtained.

## Candidates

### 1. Thorley & Branton 2022: Elk Valley WCT, GSDD → fork length at onset of winter → egg-to-age-1 survival (BC)
- **Citation:** Thorley, J.L. & Branton, M.A. (2022). Subject Matter Expert Report: Energetic Status at the Onset of Winter Based on Fork Length and Wet Weight. Evaluation of Cause – Reduced Recruitment in the Harmer Creek Westslope Cutthroat Trout Population. Poisson Consulting / Branton Environmental Consulting for Teck Coal Ltd. https://www.teck.com/media/Energetic-Status-Harmer-Creek-Evaluation-of-Cause-SME-Report.pdf
- **Claim (verified):**
  - p. 25–26: "The model also estimated that expected fork length increased with GSDD from 35 (30-40 95% CI) mm at 800 GSDD to 43 (38-52 95% CI) mm at 1,200 GSDD (Figure 16)."
  - p. 25: GSDD "ranged from ~800 to ~900 in all years except 2021 in the Harmer Creek population when it was ~1,000 degree days … In the Grave Creek population area GSDD was estimated to range between ~1,050 and ~1,150".
  - p. ii (exec. summary): energetic status "explains 65% (29-85% 95% CI) of the difference in recruitment between the Harmer Creek and Grave Creek populations"; "GSDD and dietary selenium explain 34% (4-58% 95% CI) and 8% (3-16% 95% CI) of the Reduced Recruitment".
  - p. 3: restates Coleman & Fausch's 30–35 mm TL threshold as "[28 – 33 mm FL]" (Thorley's own conversion).
  - The model estimates expected fork length at 900 GSDD (α_L0 = 36.6 mm FL, 95% CI 33–41.2) and a GSDD effect of 0.000562 on the log scale (Table of parameter estimates, p. 24). Population replacement requires 3.7% egg-to-age-1 survival (Figure 21 caption, p. 28).
- **Species / life stage / region:** WCT, age-0 at onset of winter → age-1; Harmer and Grave creeks, Elk Valley, BC.
- **Window/base:** GSDD per Coleman & Fausch (2007a), quoted on p. 3: start = beginning of first week averaging >5 °C and staying above; end = last day of first week averaging <4 °C; base 0 °C (summed daily means). Lengths are **fork length**.
- **PDF:** direct URL https://www.teck.com/media/Energetic-Status-Harmer-Creek-Evaluation-of-Cause-SME-Report.pdf (verified as a PDF).
- **Keep?** Yes. This is the only BC WCT source found with a fitted GSDD–length relation and a length/energy → recruitment relation. It also cites Brooks & Robinson 2022 (Lotic Environmental for Teck), a steeper GSDD–fry-length relation across upper Fording, Grave, Greenhills, Harmer, Lizard and Michel creeks. That report was not found online and may need a request to Teck.

### 2. Hocking, Whelan & Hatfield 2022: Coleman & Fausch functions applied to Elk Valley WCT (BC)
- **Citation:** Hocking, M., Whelan, C. & Hatfield, T. (2022). Subject Matter Expert Report: Water Temperature and Ice. Evaluation of Cause – Reduced Recruitment in the Harmer Creek Westslope Cutthroat Trout Population. Ecofish Research Ltd. for Teck Coal Ltd., Dec 1 2022. https://www.teck.com/media/Water,-Air-Temp-and-Ice-Harmer-Creek-Evaluation-of-Cause-SME-Report.pdf
- **Claim (verified):**
  - p. 18: "Less than 800 GSDD is unsuitable for recruitment, 800-900 GSDD is marginally suitable, and >900 GSDD tends to be sufficient for recruitment to support high-abundance populations (Coleman and Fausch 2007b)." This restates Coleman & Fausch.
  - p. 46–47: TL→FL conversion (Mayhood 2012) "Total Length (mm) = 1.040 × Fork Length (mm) + 1.697". The GSDD→fry FL equation is printed as "Fry Fork Length (mm) = (18.983 + 0.17e0.046 × GSDD) / 1.04". **As printed the exponent looks mis-transcribed** (e^(0.046×GSDD) would be astronomically large). Check it against Coleman & Fausch 2007b Fig. 4 before use.
  - p. 47: at GSDD 723–926 (HRM-R3 to R5), predicted fry are 22–30 mm FL at onset of winter. At >1,000 GSDD (HRM-R1, GRV-R1, GRV-R2), predicted fry are >35 mm FL. Observed Harmer fry were "~15% smaller by length" than Grave fry.
  - p. 49: fry survival to onset of winter, from Coleman & Fausch 2007a lab data, "= e-3.71 + 0.0048 × GSDD / (1 + e-3.71 + 0.0048 × GSDD)" (logistic).
  - p. 51: a logistic fitted to the three lab treatment means predicts "overwinter survival of Cutthroat Trout fry is high (>90%) at a fork length greater than ~30 mm. Below 30 mm, survival decreases sharply, and at a fork length of ~20 mm survival is predicted to be only 40%." This rests on three points only.
  - p. 75 (uncertainties): "observed fry sizes in the Grave Creek and Harmer Creek population areas were similar to but slightly larger than predicted by the Coleman and Fausch models."
- **Species / life stage / region:** WCT age-0; Elk Valley, BC. Functions taken from Colorado River cutthroat.
- **Window/base:** GSDD per Coleman & Fausch, summed daily means. Fork length, converted from TL.
- **PDF:** direct URL (as above; verified PDF).
- **Keep?** Yes. It operationalizes Coleman & Fausch for BC WCT and says outright that BC fry ran slightly larger than the Colorado curve predicts. Its derived equations are secondary: cite them only as Hocking et al.'s transformation.

### 3. Coleman 2007 PhD dissertation: explicit 30–35 mm TL overwinter threshold and its field basis
- **Citation:** Coleman, M.A. (2007). Cold summer stream temperatures reduce recruitment of native cutthroat trout populations. PhD dissertation, Colorado State University. doi:10.25675/3.019077 · https://hdl.handle.net/10217/237658
- **Claim (verified):**
  - Abstract (p. iii): "selecting sites with ≥800-900 degree days during the growing season, and fry grow to ≥30-35 mm by the end of the growing season".
  - p. 34 (lab chapter): Peterson & Fausch's two cold streams (mean July 6.6 and 6.9 °C) yielded September age-0 "of 26 mm and 30 mm median length", and the warmer streams (12.7, 12.4 °C) 45 and 69 mm. "These observations and my own experimental results suggest that age-0 cutthroat trout fry must reach a threshold length of 30-35 mm to survive over winter (Figure 5)."
  - p. 59 (Fig. 5 caption): "the approximate minimum size threshold for overwinter survival derived from previous field research (Peterson and Fausch 2002; Peterson et al. 2004)".
  - p. 69: "accumulate 900-1200 Celsius degree days … best opportunity … 800-900 degree days likely sustain recruitment in some years … less than 800 degree days are generally unsuitable".
  - p. 89–90: "cutthroat trout fry need to reach a minimum of 30-35 mm TL by the onset of winter to allow recruitment to age-1 … If the 30-35 mm TL minimum size threshold I propose can be validated and generalized among streams…" The lab warm treatment (1044 GSDD) gave fry averaging 34 mm TL; the 932 and 818 GSDD treatments gave 26 and 25 mm TL.
  - p. 77: GSDD computed by summing daily means (gaps filled from weekly means × 7).
- **Species / life stage / region:** Colorado River, greenback and Rio Grande cutthroat; age-0; high-elevation Colorado.
- **Window/base:** GSDD as in the published papers. **Total length.**
- **PDF:** direct URL https://mountainscholar.org/bitstreams/d307e409-c4e6-42c1-be70-994dc08d1858/download (verified PDF, 2.97 MB).
- **Keep?** Yes, as the explicit, citable origin of the 30–35 mm TL figure. It shows the figure is a proposal from lab means plus four streams' September medians, and the author says it still needs validation. The chapters overlap the two TAFS papers already held.

### 4. Mochnacz 2021 PhD thesis: bull trout thermal units, a proposed 1600 ATU need, and NWT counter-evidence
- **Citation:** Mochnacz, N.J. (2021). Thermal ecology of bull trout (*Salvelinus confluentus*) and potential consequences of climate warming in montane watersheds. PhD thesis, University of Manitoba. http://hdl.handle.net/1993/35421
- **Claim (verified):**
  - p. 98: "Laboratory studies on a southern bull trout population show that eggs require 500 ATU to hatch and juveniles require 800 ATU to emerge (Gould 1987). Bebak et al. (2000) show that juvenile survival of Arctic char (*Salvelinus alpinus*) is highest when fish experience an additional 800 ATU after emergence. Together, these data suggest that bull trout require 1600 ATU from egg deposition to the onset of winter to increase their chance of survival during this season." This is an inference: the post-emergence 800 comes from hatchery Arctic char.
  - p. 127, Table 3.5: growing-season ATU (hatch to onset of winter): NT mean 651 (range 378–936), AB 597 (321–787), ID 1230 (807–1745).
  - p. 114: "several of these streams accumulate very few thermal units throughout the growing season (i.e., ≤ 800)" yet hold "abundant, self-sustaining juvenile bull trout populations". The author proposes local adaptation or countergradient growth.
  - **Caution:** p. 109 says Coleman & Fausch (2007b) found low recruitment at "<700 thermal units", and p. 114 says "at least 800 thermal units from egg deposition to the onset of winter". Both misstate Coleman & Fausch (800/900 GSDD). Do not cite Mochnacz for the Coleman & Fausch values.
- **Species / life stage / region:** BT juveniles; Idaho, Alberta and Northwest Territories.
- **Window/base:** ATU = summed daily means (1 °C × 24 h = 1). The growing season runs from the estimated 50% hatch date to the first date ≤2 °C on consecutive days. Table 3.2 says two days and Table 3.3 says seven, so the definitions conflict. This is **not** the Coleman & Fausch GSDD window.
- **PDF:** direct URL https://mspace.lib.umanitoba.ca/bitstreams/182a5c5d-b545-47de-b1b2-36ccb369e9aa/download (verified PDF, 222 pp).
- **Keep?** Yes. It is the only bull trout source found that quantifies thermal units against a winter-survival need, and the NWT observation is direct evidence that a cutthroat-derived GSDD floor does not transfer to BT. The companion paper, Mochnacz, Taylor, Docker & Isaak 2022, "An ecothermal paradox…", *Environ. Biol. Fishes* (doi:10.1007/s10641-022-01339-0), is open access, but Springer blocked scripted download. Abstract only: "in northern streams, unsuitably cold temperatures may be more limiting". Browser: https://link.springer.com/article/10.1007/s10641-022-01339-0

### 5. Smith & Griffith 1994: age-0 rainbow trout first-winter survival vs size (Idaho)
- **Citation:** Smith, R.W. & Griffith, J.S. (1994). Survival of rainbow trout during their first winter in the Henrys Fork of the Snake River, Idaho. *Trans. Am. Fish. Soc.* 123:747–756. doi:10.1577/1548-8659(1994)123<0747:SORTDT>2.3.CO;2
- **Claim (abstract only):** "Fish smaller than 100 mm in October did not survive the winter." Survival ranged "from 100% at a spring-fed site to 63% at the coldest site", and "95% of the mortality occurred during early winter". Secondary, not verified against the paper: Handy (1997, pdf p. 13) reports from it that "survival of 130-160 mm fish exceed[ed] 95% while fish < 100 mm suffered 100% mortality" and "0% survival of fish with late-autumn K values below 0.77 to 0.82".
- **Species / life stage / region:** wild resident RB, age-0 (78–169 mm TL, caged); Henrys Fork, Idaho (cold tailwater/spring-influenced; large age-0).
- **Window/base:** no degree-days. **Total length** in October.
- **PDF:** paywalled.
- **Keep?** Yes (RB, region priority). Note that the 100 mm cutoff applies to a productive river where age-0 are large, so it is not transferable to headwater fry sizes.

### 6. Meyer & Griffith 1997: rainbow and brook trout first winter, size-dependence only at the cold site (Idaho)
- **Citation:** Meyer, K.A. & Griffith, J.S. (1997). First-winter survival of rainbow trout and brook trout in the Henrys Fork of the Snake River, Idaho. *Can. J. Zool.* 75:59–63. doi:10.1139/z97-007
- **Claim (abstract only):** "At the warmer site, over 90% of the rainbow trout … survived the winter, and there was no significant difference between >90 and <90 mm fish. At the colder site, survival was 60% and all mortality occurred in fish <90 mm." "size-dependent mortality may be more likely to occur when environmental conditions are more severe".
- **Species / life stage / region:** RB and brook trout, age-0, caged; Henrys Fork, Idaho.
- **Window/base:** no degree-days. Length type not stated in abstract.
- **PDF:** paywalled.
- **Keep?** Yes. It gives a size cutoff that depends on temperature: it applies only at the colder site.

### 7. Harig 2000 PhD dissertation (≈ Harig & Fausch 2002): mean July temperature threshold for translocated cutthroat
- **Citation:** Harig, A.L. (2000). Factors influencing success of cutthroat trout translocations. PhD dissertation, Colorado State University. Published as Harig & Fausch (2002) *Ecol. Appl.* 12:535–551 (doi:10.1890/1051-0761(2002)012[0535:MHRFET]2.0.CO;2, paywalled; abstract read).
- **Claim (verified in dissertation, p. 46):** "in streams that support low numbers of cutthroat trout, cold temperatures (< 7.8 °C mean daily temperature for July) likely prevent successful reproduction and recruitment during most summers. Conversely, in streams that support high numbers of cutthroat trout, summer water temperatures are probably warm enough (mean = 10.0°C; SE= 0.6) to allow successful reproduction in most years." The 2002 abstract gives only "cold summer water temperature … limited translocations" and the 14.7 km² watershed area.
- **Species / life stage / region:** greenback and Rio Grande cutthroat; recruitment; 27 translocation streams in Colorado and New Mexico.
- **Window/base:** mean July daily water temperature, not degree-days.
- **PDF:** direct URL https://mountainscholar.org/bitstreams/e6643d1c-3e93-4393-93f3-6ad0a89e5420/download (verified PDF; dissertation).
- **Keep?** Yes, as the predecessor threshold the GSDD work refined. **Discrepancy:** Young (2008, GTR-207, p. 17) states the Harig & Fausch successes were "associated with streams above 7.1oC". The dissertation sentence says 7.8 °C, and 7.1 °C is the mean of the "absent" group in Harig's Table (Doctor Cr. etc., mean 7.1, SE 1.0). Treat Young's 7.1 as a misreading unless the 2002 paper says otherwise.

### 8. Coleman 2007: greenback cutthroat life-history report (agency synthesis)
- **Citation:** Coleman, M.A. (2007). Life-History and Ecology of the Greenback Cutthroat Trout. Colorado State University / Colorado Division of Wildlife report. https://mountainscholar.org/bitstream/handle/10217/46965/GBN_Life_History-Coleman-4-26-07.pdf?sequence=1
- **Claim (verified):**
  - p. 3: "Colorado River cutthroat trout survived poorly through the start of their first winter in temperature regimes in which fewer than 800 degree-days accumulated between spawning and the start of winter". Note the window is **spawning to winter**, unlike the GSDD wording elsewhere.
  - p. 3–4: "young-of-year … fry densities were very low in stream reaches with fewer than 800 growing season degree-days and fry length was < 30 mm. Thus, the mean July temperature criteria (> 7.8 C) … may be further refined when sufficient temperature data are available to calculate degree-days during the growing season." It also lists screening criteria: "mean July temperatures > 7.8ºC".
  - p. 4: greenback eggs from Little South Fork Poudre "required only 256 degree-days to hatch" vs 312 for an Arkansas basin population.
- **Species / life stage / region:** greenback and CRCT; Colorado.
- **Window/base:** mixed. Spawning-to-winter degree-days for the lab result and GSDD for the field result. TL implied.
- **PDF:** direct URL (as above; verified PDF).
- **Keep?** Yes, as a secondary synthesis by the primary author. It shows the threshold reported on two different windows, which matters for coding `metric`.

### 9. Zeigler et al. 2019: RGCT Bayesian network, cold-recruitment cut-off expressed as M30AT
- **Citation:** Zeigler, M.P., Rogers, K.B., Roberts, J.J., Todd, A.S. & Fausch, K.D. (2019). Predicting persistence of Rio Grande cutthroat trout populations in an uncertain future. *N. Am. J. Fish. Manage.* 39(5):819–848. doi:10.1002/nafm.10320
- **Claim (verified):** p. 832: "few streams are likely to remain so cold as to prevent any recruitment (M30AT < 8°C; Figure A.1.2)". p. 828–829 and Appendix A.1: most populations "were predicted to occupy streams with M30AT suitable for recruitment and growth (9.1–19.0°C) in 2080". The M30AT node's support table cites "Bear et al. 2007; Coleman and Fausch 2007a, 2007b; Zeigler et al. 2013a".
- **Species / life stage / region:** Rio Grande cutthroat; recruitment; Colorado and New Mexico.
- **Window/base:** M30AT = maximum 30-day average water temperature, not degree-days.
- **PDF:** direct URL https://cpw.cvlcollections.org/files/original/e38b4af92a28241f3266d5a99b50df6d.pdf (verified PDF).
- **Keep?** Yes, as a translation of the Coleman & Fausch cold limit into a summer-peak metric. It is an expert-elicited node, not a new measurement.

### 10. Peterson 2002 PhD dissertation (≈ Peterson, Fausch & White 2004): field basis for cold-stream recruitment failure
- **Citation:** Peterson, D.P. (2002). Population ecology of an invasion: demography, dispersal, and effects of nonnative brook trout on native cutthroat trout. PhD dissertation, Colorado State University. Published as Peterson, Fausch & White (2004) *Ecol. Appl.* 14:754–772 (doi:10.1890/02-5395, paywalled; abstract read).
- **Claim (verified in dissertation):** p. 78–79: "cutthroat trout recruitment in high-elevation streams was low or absent, and removal of brook trout did not ameliorate recruitment failures … abiotic factors, primarily cold summer water temperatures, appear to limit cutthroat trout recruitment". p. 69: "Age-0 brook trout averaged 22.3 mm longer than cutthroat trout at the end of their first summer" (brook 76.3 mm, cutthroat 54.0 mm). The study-stream table (pdf p. ~118) gives mean July temperatures: Indiana 6.6, Willow 6.9, E. Fk 12.4 and Little Muddy 12.7 °C. Survival models used "summer degree days" (sum of daily means >0 °C, May–August) and annual degree days as covariates. **No explicit size threshold was found in the dissertation text.** The 26/30 mm September medians that Coleman attributes to "Peterson and Fausch 2002" are in a separate 2002 final report to the Colorado Division of Wildlife, the Central Utah Project Completion Act Office, the USDA Forest Service and Trout Unlimited. That report was not found online.
- **Species / life stage / region:** CRCT age-0 to adult; four Colorado headwater streams.
- **Window/base:** May–Aug degree-days >0 °C (covariate only). Fork length.
- **PDF:** direct URL https://api.mountainscholar.org/server/api/core/bitstreams/2b2d8231-7831-45e5-9ddb-57ffb20d02ec/content (verified PDF).
- **Keep?** Yes as provenance, no as a threshold source. It answers the coordinator's question: neither Peterson document available online states 30–35 mm. The threshold was Coleman's reading of their data.

### 11. Hunt 1969: brook trout first-winter survival vs fingerling length (Wisconsin)
- **Citation:** Hunt, R.L. (1969). Overwinter survival of wild fingerling brook trout in Lawrence Creek, Wisconsin. *J. Fish. Res. Board Can.* 26:1473–1483. doi:10.1139/f69-138
- **Claim (abstract only):** "Overwinter survival tended to increase with an increase in mean length of fingerling stocks (r = 0.83++) and with an increase in winter water temperatures." Mean first-winter survival 54% (range 35–73%) over 11 winters.
- **Species / life stage / region:** brook trout, age-0; Wisconsin spring creek.
- **Window/base:** none (mean autumn length).
- **PDF:** paywalled.
- **Keep?** Yes, low priority. It is the classic quantitative size–overwinter relation cited by everyone above.

### 12. Biro et al. 2004; Post & Parkinson 2001; Biro, Post & Beckmann 2021: age-0 rainbow trout winter starvation in BC lakes
- **Citations:** Biro, P.A., Morton, A.E., Post, J.R. & Parkinson, E.A. (2004) *Can. J. Fish. Aquat. Sci.* 61:1513–1519, doi:10.1139/f04-083. Post, J.R. & Parkinson, E.A. (2001) *Ecology* 82:1040–1051, doi:10.1890/0012-9658(2001)082[1040:EASIYF]2.0.CO;2. Biro, P.A., Post, J.R. & Beckmann, C. (2021) *Can. J. Fish. Aquat. Sci.* 78:738–743, doi:10.1139/cjfas-2020-0276.
- **Claim:** Biro 2004 (abstract only): lab "critical minimum lipid content below which death occurred". In lakes, "mortality that ranged from just under 60% for the largest individuals to just over 90% of the smallest individuals". Biro 2021 (abstract read, accepted manuscript opened): "fish in low food lakes nearing 90% mortality and about 60% mortality in high food lakes". Fish were stocked as swim-up fry (mean TL 27 mm), in experimental lakes in south-central BC (manuscript lines 124, 135). Post & Parkinson 2001 (abstract only): constituent allometries "with inflexions at ∼10 cm in length".
- **Species / life stage / region:** RB age-0; BC lakes.
- **Window/base:** none; size and lipid. Lengths TL/FL as stated.
- **PDF:** Biro 2021 direct URL https://utoronto.scholaris.ca/bitstreams/e0d7c313-5c47-4c58-ab8a-6498d4957bd9/download (verified PDF). Biro 2004 and Post & Parkinson 2001 paywalled.
- **Keep?** Yes, low priority: lake, not stream. They give the mechanism (size-dependent lipid reserves) but no stream length cutoff.

### 13. Counter-evidence: no size-dependent first-winter mortality (Idaho/Montana cutthroat)
- **Gregory, J.S. & Griffith, J.S. (2000).** First-winter survival of caged wild and hatchery cutthroat trout in allopatry and in sympatry with brook trout. *Intermountain Journal of Sciences* (2000). PDF verified: https://arc.lib.montana.edu/ojs/index.php/IJS/article/download/2892/2538. Verified text: wild YCT age-0 averaging 46–47 mm (range 30–65 mm) survived 84% in allopatry. "Survival was not size-dependent." p. 219: the site was groundwater-moderated, "resulting in accumulation of 625 degree-days above 0 °C", while an adjacent stream got one-third as many. "Temperatures in our experiment apparently were above those at which survival would become size-dependent." Henry's Lake Outlet tributary, Idaho. Keep: yes, as a condition on the size threshold: it holds in cold winters, not in thermally buffered ones.
- **Handy, M.J. (1997).** Overwinter survival of westslope cutthroat trout in Cache Creek, Montana. MSc thesis, Montana State University. https://scholarworks.montana.edu/server/api/core/bitstreams/832a162e-10d0-4a91-a409-36cef6b197e0/content (verified PDF; server rate-limits). Abstract: "no size-specific survival was evident". p. 23: no decrease in fish <100 mm (χ², P = 0.99). Fish <80 mm were excluded and size classes start at 50–80 mm FL, so the sample was **mostly not age-0**. Keep: low. It is also the source of the secondary detail on Smith & Griffith 1994 above.
- **McGrath, K.E. (2003).** Size variation and fitness consequences in age 0 westslope cutthroat trout. PhD dissertation, University of Idaho. https://fs.usda.gov/rm/boise/publications/misc/McGrathDissert.pdf (verified PDF). Ch. 4 abstract (p. 96): overwinter selection on growth rate in 2001–02 but not 2000–01, "favoring faster growth in the warmer stream and slower growth in the colder stream". Autumn mean age-0 WCT size was 26.3–49.1 mm at site scale (Ch. 2). No threshold. Keep: low, as WCT counter-evidence and a source of autumn size ranges in N Idaho.

## Dropped
- Isaak, Climate-Aquatics Blog #45 (USFS, ~2013; Wayback copy) — secondary. It says only that Coleman & Fausch "concluded that approximately 900 degree days were needed". Its citations (Neuheimer & Taggart 2007; McCullough et al. 2009) give no age-0 threshold.
- Neuheimer & Taggart 2007 (CJFAS), and Chezik et al. 2013/2014 "Fish growth and degree-days I/II" (CJFAS) — methods for degree-day base choice, not thresholds. Could support how `metric`/base is noted.
- Roberts, Fausch, Peterson & Hooten 2013 (GCB 19:1383) and Roberts et al. 2017 (NAJFM) — CRCT persistence BNs. Abstracts give no cold-recruitment threshold. Full text not obtained: the landscapepartnership.org copy returns 404 or HTML. The node may restate Coleman & Fausch. Not verified.
- Kennedy, P. & Meyer, K.A. 2015, "Trends in abundance and the influence of bioclimatic factors on westslope cutthroat trout in Idaho", *J. Fish Wildl. Manage.* 6(2):305 (doi:10.3996/012015-JFWM-001) — abstract only (publisher 403; IDFG host unresolvable). "Bioclimatic indices generally explained a low amount of variation in westslope cutthroat trout abundance through time". The abstract names no degree-day or size threshold.
- Reimers 1963, "Body condition, water temperature, and over-winter survival of hatchery-reared trout in Convict Creek, California", *TAFS* 92:39–46 — catchable-size hatchery RB, not age-0. A partial scan (pp. 39–40) was read at https://arc.lib.montana.edu/robert-behnke/objects/2491-07-09.pdf. It covers condition decline and late-winter die-off, and says starved hatchery trout survive ~6 months "below about 45° F". No age-0 threshold.
- Peterson & Fausch 2002 final report to the Colorado Division of Wildlife — not online (searched); see candidate 10.
- MacDonald et al. 2013 (CJFAS, doi:10.1139/cjfas-2013-0221; year per OpenAlex) and MacDonald 2013 ULeth PhD thesis — WCT/BT emergence-date predictions only, no growth or overwinter threshold.
- Al-Chokhachy et al. 2021 (CJFAS, YCT) — occurrence declines below 10 °C mean August with nonnatives; distribution, not recruitment threshold.
- Al-Chokhachy et al. 2013 (GCB, YCT growth under warming) — growth-model projections, no threshold (abstract).
- Kaeding 2010 (IJS 16(4) and MSU thesis) — Yellowstone Lake adfluvial YCT. The covariate is annual air degree-days >0 °C, and "Characteristics of climate that individually or collectively affected first-year survival of YCT are unknown". No threshold.
- Borgstrøm & Museth 2005 (*Ecol. Freshw. Fish* 14:375) — brown trout, Norway. Mean August temperature is linked to strong year-classes, and "Size of the young-of-the-year (YOY) trout at onset of the winter seemed to be crucial". Abstract only, with no numeric threshold in the abstract. Re-add if brown trout scope widens.
- Huusko et al. 2007 (*River Res. Appl.* 23:469) and Hurst 2007 (*J. Fish Biol.*) — reviews. Huusko concludes "overwinter survival of juvenile fish appears to be context-dependent". Useful framing, no threshold.
- Shuter & Post 1990 (TAFS) — minimum first-year size vs growing season, modelled for perch and bass, not salmonids.
- Zeigler et al. 2013b (USGS OFR 2013-1051) — RGCT temperature/discharge data. Grep found no degree-day or recruitment threshold.
- Young 2008 (RMRS-GTR-207) — CRCT conservation assessment. A secondary restatement (p. 17: "threshold of about 900 degree-days during the growing season") with the 7.1 °C misquote noted under candidate 7. p. 25 restates emergence at "570-600 degree-days" (Coleman & Fausch 2007a).
- Huntsman et al. 2018/2020/2021 (RGCT growth/life history), Strait et al. 2020 (WCT × RB growth), Stead et al. 2022 (LCT growth) — degree-days or temperature drive growth. No recruitment or overwinter threshold.
- Isaak et al. 2015 (climate shield), Wenger et al. 2011 (CJFAS), Ma et al. 2023 (RRA), Mochnacz et al. 2025 (DDI) — distribution or occupancy models, no age-0 threshold (abstracts).
- Avila, Winkelman & Fetherman 2023 (NAJFM 43:786) — stocked age-0 RB survival rises with mean temperature. No threshold or degree-days.
- Voss et al. 2022 (TAFS) — smallmouth bass, not trout.
- Fitzgerald et al. 2021 (FME) — white-spotted charr and masu, hatch timing.
- Cook, Rahel & Hubert 2010 (TAFS) — CRCT persistence, recruitment failure in small populations, no thermal threshold.
- Gould 1987 (bull trout development), Austin et al. 2019 (BT emergence phenology), Bebak et al. 2000 (Arctic char eggs/alevins, aquaculture) — development thermal units, not growth/overwinter. They are cited only through Mochnacz (candidate 4).
- Finstad et al. 2004b and Berg et al. 2009 (Atlantic salmon winter energetics) — out of species scope.
- Xu, Letcher & Nislow 2010 (J. Fish Biol.) — brook trout size-dependent survival in **summer**, not winter.
- Shepard & Zale 2008 (IJS meeting abstract) — method only.
- Brooks & Robinson 2022 (Lotic Environmental for Teck), "A Preliminary Investigation into Water Temperature as a Predictor of Westslope Cutthroat Trout Fry Growth" — not found online. It would be a high-value BC source if obtainable from Teck or Lotic.

## Search log (2026-10-13)
- Semantic Scholar API (`/graph/v1/paper/search`): HTTP 429 twice; not retried.
- Crossref `query.bibliographic` resolved DOIs: Coleman & Fausch field = 10.1577/T05-244.1 (TAFS 136:1231); lab = 10.1577/T05-288.1 (TAFS 136:639). Also resolved: Smith & Griffith 1994, Meyer & Griffith 1997, Mitro & Zale 2002, Biro 2004, Post & Parkinson 2001, Shuter & Post 1990, Hunt 1969, Kennedy & Meyer 2015, Zeigler 2013 OFR, Xu 2010, Al-Chokhachy 2013, Borgstrøm & Museth 2005, Hurst 2007.
- OpenAlex `filter=cites:W2087676938` (field paper; 79 citing works) and `cites:W2149084742` (lab paper; 36). All titles scanned. Abstracts pulled via OpenAlex for ~35 of them (`abstract_inverted_index`).
- Unpaywall: queried for 10.1890/02-5395 (not OA). **Note:** this call sent the user's email address as the Unpaywall `email` parameter, which it should not have. No other service received it.
- WebSearch queries (standard mode):
  1. Coleman dissertation Colorado State cutthroat cold summer temperature age-0 recruitment mountainscholar
  2. Roberts Fausch 2013 "growing season degree days" … Bayesian network recruitment threshold pdf
  3. Harmer Creek WCT "Evaluation of Cause" reduced recruitment energetic status report Teck
  4. Peterson Fausch White 2004 "Population ecology of an invasion" … age-0 length overwinter
  5. Peterson Fausch 2002 "Demography, dispersal, and effects …" final report
  6. Reimers 1963 "body condition, water temperature, and over-winter survival …"
  7. Kennedy Meyer 2015 WCT abundance bioclimatic factors Idaho growing season degree days
  8. "Trends in abundance and the influence of bioclimatic factors on westslope cutthroat trout in Idaho" pdf
  9. Mochnacz 2021 thesis "Thermal ecology of bull trout" mspace growing season degree days
  10. Zeigler 2019 RGCT Bayesian network "degree days" recruitment node
  11. "Fragmentation and thermal risks from climate change interact" … pdf
  12. "growing season degree days" trout recruitment age-0 stream threshold
  13. westslope cutthroat trout age-0 fry size end of summer overwinter survival length mm
  14. bull trout young-of-year size overwinter survival degree days emergence growth cold streams
  15. Harig Fausch 2002 "Minimum habitat requirements …" pdf July temperature 7.8
  16. Elk Valley WCT GSDD fry fork length October recruitment Fording River report
  17. Montana State thesis overwinter survival age-0 WCT Cache Creek size
  18. "degree days" "young-of-year" rainbow trout stream recruitment … BC/Montana/Idaho
  19. Yellowstone cutthroat age-0 recruitment cold summer temperature degree days …
  20. age-0 rainbow trout first winter survival minimum length threshold stream "size-dependent"
  21. "A Preliminary Investigation into Water Temperature as a Predictor of WCT Fry Growth" Lotic Teck
  22. MacDonald 2013 ULeth thesis stream temperature … WCT degree days emergence
  23. Peterson Fausch 2002 final report CDOW … Central Utah Project Completion Act Trout Unlimited
- Full texts downloaded and searched (pdftotext + grep), in scratchpad only: Coleman 2007 dissertation; Peterson 2002 dissertation; Harig 2000 dissertation; Coleman 2007 greenback report; Teck Energetic Status (Thorley & Branton 2022); Teck Water Temperature and Ice (Hocking et al. 2022); Mochnacz 2021 thesis; Zeigler et al. 2019; Young 2008 GTR-207; McGrath 2003; Handy 1997; Gregory & Griffith 2000; Kaeding 2010 (IJS); Biro et al. 2021 (manuscript); Reimers 1963 (partial scan); USGS OFR 2013-1051; MacDonald 2013 thesis; Isaak blog #45 (Wayback); Shepard & Zale 2008.
- Reference lists chased: Coleman 2007 dissertation (Peterson & Fausch 2002; Peterson et al. 2004; Harig & Fausch 2002; Young & Guenther-Gloss 2004; Biro et al. 2004; Post & Parkinson 2001; Cunjak et al. 1987; Shuter & Post 1990; Isaak & Hubert 2004). Thorley & Branton 2022 (Brooks & Robinson 2022; Biro et al. 2004, 2021; Huusko et al. 2007; Cope & Cope 2020). Hocking et al. 2022 (Mochnacz 2021; Harig & Fausch 2002; Mayhood 2012). Mochnacz 2021 (Gould 1987; Bebak et al. 2000; Berg et al. 2009; Finstad et al. 2004b; Austin et al. 2019). Gregory & Griffith 2000 (Hunt 1969; Smith & Griffith 1994; Meyer & Griffith 1997; Griffith 1972). Zeigler 2019 (M30AT node sources). Isaak blog (Neuheimer & Taggart 2007).
- Blocked or unavailable: Springer, Wiley and ESA PDFs (bot challenge); CPW RGCT BN tutorial (404); landscapepartnership.org Roberts 2013 copy (404/HTML); collaboration.idfg.idaho.gov (DNS failure); fwspubs.kglmeridian.com (403); scholarworks.montana.edu intermittent 429.
- Stopped when the forward-citation sets of both Coleman & Fausch papers had been scanned and the last chains (Mochnacz, Teck SME reports, Gregory & Griffith, Zeigler) returned only items already listed.
