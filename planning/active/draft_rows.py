"""Draft #40 rows: Bear et al. 2005 and 2007. Writes planning/active/draft-bear-evidence.csv."""
import csv
HDR = open("data/literature_evidence.csv", encoding="utf-8").readline().strip().split(",")
K7, K5 = "bear_etal2007ComparativeThermal", "bear_etal2005ThermalRequirements"
LAB_WCT = "Laboratory (Montana wild-stock westslope cutthroat)"
LAB_RB = "Laboratory (Fish Lake strain rainbow trout, Montana)"
OCR = "The text layer renders the degree sign as '8', so the quote is checked against OCR."
M7 = ("Juveniles (WCT 102-126 mm TL, RB 110-152 mm TL), 60-d acclimated chronic exposure: acclimated at 14 C, "
      "ramped 1 C/day to a held test temperature, satiation ration.")
M5 = "Juveniles, 60-d acclimated chronic exposure (ramped 1 C/day from 14 C to a held test temperature), satiation ration."

def row(sp, bound, vmin, vmax, metric, kind, region, key, page, quote, qs, note, cited="", stage="rearing"):
    return dict(zip(HDR, [sp, stage, "", "temperature", "", bound, vmin, vmax, "degC", metric, kind, region,
                          key, str(page), quote, qs, "", cited, note, ""]))

rows = [
 # ---- Bear et al. 2007 (TAFS) ----
 row("WCT", "max", "", "19.6", "constant", "lab", LAB_WCT, K7, 1115,
     "The predicted UUILT for westslope cutthroat trout (19.6", "ocr",
     f"60-d ultimate upper incipient lethal temperature (LT50 at day 60); 95% CI 19.1-19.9 C. {M7} "
     f"The 2005 report gives 19.7 C by its LD50 regression and 19.6 C by its survival curve. Cleator et al. 2009 (row 521) and Thorley et al. 2021 (row 522) cite this paper. {OCR}"),
 row("RB", "max", "", "24.3", "constant", "lab", LAB_RB, K7, 1115,
     "was 4.7°C lower than that for rainbow trout (24.3", "ocr",
     f"60-d ultimate upper incipient lethal temperature; 95% CI 24.0-24.7 C. {M7} The 2005 report gives 24.2 C by its LD50 regression. {OCR}"),
 row("WCT", "max", "", "24.1", "constant", "lab", LAB_WCT, K7, 1117,
     "the 7-d UUILT for westslope cutthroat trout in our study (24.1", "ocr",
     f"7-d UUILT from the same chronic exposure, for comparison with 7-d tests elsewhere; the 60-d UUILT is 19.6 C (the paper: 4.5 C lower). "
     f"The 2005 report gives 24.7 C. {OCR}"),
 row("RB", "max", "", "26.0", "constant", "lab", LAB_RB, K7, 1118,
     "the 7-d UUILT derived from our study (26.0", "ocr",
     f"Rainbow trout 7-d UUILT from the same chronic exposure; the 60-d UUILT is 24.3 C (the paper: 1.7 C lower). The 2005 report gives 31.1 C. {OCR}"),
 row("WCT", "max", "", "20", "constant", "lab", LAB_WCT, K7, 1117,
     "approached the species' upper lethal limit (20", "ocr",
     f"Fish became lethargic and ceased feeding as temperatures approached this rounded upper lethal limit; the fitted 60-d UUILT is 19.6 C. {OCR}"),
 row("RB", "max", "", "24", "constant", "lab", LAB_RB, K7, 1117,
     "upper lethal limit (20°C for westslope cutthroat trout; 24", "ocr",
     f"Rainbow trout became lethargic and ceased feeding as temperatures approached this rounded upper lethal limit; the fitted 60-d UUILT is 24.3 C. {OCR}"),
 row("WCT", "optimum", "13.6", "13.6", "constant", "lab", LAB_WCT, K7, 1117,
     "similar peak growth temperatures (westslope cutthroat trout: 13.6", "ocr",
     f"Peak of 60-d relative growth at satiation, from a regression over growth tested at 8-24 C (no WCT survived 24 C long enough to measure growth). {M7} The 2005 report gives the same 13.6 C. {OCR}"),
 row("RB", "optimum", "13.1", "13.1", "constant", "lab", LAB_RB, K7, 1117,
     "(westslope cutthroat trout: 13.6°C; rainbow trout: 13.1", "ocr",
     f"Rainbow trout peak of 60-d relative growth at satiation. The paper notes this is far below the 17.2 C of Hokanson et al. 1977 (smaller fish). The 2005 report gives the same 13.1 C. {OCR}"),
 row("RB", "optimum", "10.1", "14.1", "constant", "lab", LAB_RB, K7, 1119,
     "rainbow trout: 10.1-14.1°C), as is their thermal preferendum", "ocr",
     f"Rainbow trout fundamental thermal niche (Christie and Regier 1988: 3 C below to 1 C above the 13.1 C optimum), derived from the growth optimum. The same sentence gives WCT 10.6-14.6 C, which has no row from this paper: the OCR doubles the dash inside that range, so no quote of it verifies. The 2005 report states the same WCT niche (p. 14). {OCR}"),
 row("WCT", "max", "", "13", "daily_max", "expert", "Montana (laboratory results)", K7, 1113,
     "maximum daily temperatures near the optimum growth temperature of 13–15", "ocr",
     f"Abstract: maximum daily temperatures near 13-15 C would ensure suitable thermal habitat for WCT populations. Stated as 13-15 C; the lower end is stored. {OCR}"),
 row("WCT", "max", "", "13", "unstated", "expert", "Montana (field studies, corroborated by laboratory results)", K7, 1119,
     "maximum temperatures near an upper limit of 13–15", "ocr",
     f"Discussion: field investigations, which the laboratory results corroborate, indicate that maximum temperatures near an upper limit of 13-15 C would delineate suitable habitat for long-term persistence. "
     f"Names no statistic (the abstract's version, p. 1113, says maximum daily). Stated as 13-15 C; the lower end is stored. {OCR}",
     cited="Sloat et al. 2001, 2005; Shepard 2004"),
 # ---- Bear et al. 2005 (WFHI final report) ----
 row("WCT", "max", "", "19.7", "constant", "lab", LAB_WCT, K5, 12,
     "The ultimate upper incipient lethal temperature, derived from plotting LD50 for each temperature followed by exponential regression analysis, was 19.7", "text",
     f"60-d UUILT by exponential regression of LD50 (days) on temperature; 95% CI 19.1-20.3 C. {M5} The same page gives 19.6 C by the survival curve, and the 2007 paper reports 19.6 C (CI 19.1-19.9)."),
 row("WCT", "max", "", "19.6", "constant", "lab", LAB_WCT, K5, 12,
     "as predicted by regression analysis of the survival vs. temperature curve, was 19.6", "text",
     f"Temperature at which 50% survived 60 days, by sigmoid regression of survival on temperature; 95% CI 19.1-19.9 C. The report says both methods gave a similar UUILT (the other is 19.7 C, same page). {M5}"),
 row("RB", "max", "", "24.3", "constant", "lab", LAB_RB, K5, 12,
     "as predicted by regression analysis of the survival vs. temperature curve, was 24.3", "text",
     f"Rainbow trout: temperature at which 50% survived 60 days, by the survival curve; 95% CI 24.0-24.7 C. {M5}"),
 row("RB", "max", "", "24.2", "constant", "lab", LAB_RB, K5, 12,
     "followed by exponential regression analysis, was 24.2", "text",
     f"Rainbow trout 60-d UUILT by exponential regression of LD50; 95% CI 22.9-25.4 C. {M5} The 2007 paper reports 24.3 C."),
 row("WCT", "max", "", "24.7", "constant", "lab", LAB_WCT, K5, 16,
     "The predicted UUILT at seven days for westslope cutthroat trout from exponential regression in this study was 24.7", "text",
     "7-d UUILT from the same 60-d exposure, for comparison with 7-d tests elsewhere; the 60-d UUILT is 19.7 C. The 2007 paper gives 24.1 C."),
 row("RB", "max", "", "31.1", "constant", "lab", LAB_RB, K5, 16,
     "the predicted 7-d UUILT, from exponential regression, for rainbow trout in this study was 31.1", "text",
     "Rainbow trout 7-d UUILT from the same exposure; the report calls it far greater than previously reported values (26.2 C, 25.6 C). The 2007 paper gives 26.0 C."),
 row("WCT", "optimum", "13.6", "13.6", "constant", "lab", LAB_WCT, K5, 11,
     "The optimum growth temperature estimated by regression analysis was 13.6°C with an optimal growth range, based on 95% confidence intervals, from 10.3°C to 17.0", "text",
     f"Peak of 60-d relative growth of age-1 juveniles at satiation (quadratic regression, tested 8-20 C). {M5} Shares its quote with the optimal growth range row (10.3-17.0 C)."),
 row("WCT", "optimum", "10.3", "17.0", "constant", "lab", LAB_WCT, K5, 11,
     "The optimum growth temperature estimated by regression analysis was 13.6°C with an optimal growth range, based on 95% confidence intervals, from 10.3°C to 17.0", "text",
     "Optimal growth range: the span around the 13.6 C peak between the lower and upper 95% confidence intervals of the growth regression (p. 10). Shares its quote with the 13.6 C optimum row."),
 row("WCT", "range", "5.5", "21.8", "constant", "lab", LAB_WCT, K5, 11,
     "The predicted lower and upper thermal limits for westslope cutthroat trout growth were 5.5°C and 21.8", "text",
     "Zero-growth edges: where the quadratic growth regression crosses the x-axis, predicted rather than tested (growth was tested at 8-20 C). Limits for growth, not survival."),
 row("RB", "optimum", "13.1", "13.1", "constant", "lab", LAB_RB, K5, 11,
     "The optimum growth temperature for rainbow trout estimated by regression analysis was 13.1°C with an optimal growth range from 6.8°C to 18.2", "text",
     f"Rainbow trout peak of 60-d relative growth at satiation. {M5} Shares its quote with the optimal growth range row (6.8-18.2 C)."),
 row("RB", "optimum", "6.8", "18.2", "constant", "lab", LAB_RB, K5, 11,
     "The optimum growth temperature for rainbow trout estimated by regression analysis was 13.1°C with an optimal growth range from 6.8°C to 18.2", "text",
     "Rainbow trout optimal growth range (95% confidence intervals of the growth regression around the 13.1 C peak). Shares its quote with the 13.1 C optimum row."),
 row("RB", "range", "1.8", "24.3", "constant", "lab", LAB_RB, K5, 11,
     "The predicted lower and upper thermal limits for rainbow trout growth were 1.8°C and 24.3", "text",
     "Rainbow trout zero-growth edges, where the quadratic growth regression crosses the x-axis; predicted, not tested. Limits for growth, not survival."),
 row("WCT", "optimum", "10.6", "14.6", "constant", "lab", LAB_WCT, K5, 14,
     "as -3 to +1°C of the optimum growth temperature, from 10.6°C to 14.6", "text",
     "Fundamental niche (Christie and Regier 1988: -3 to +1 C of the 13.6 C optimum growth temperature), derived from the growth optimum."),
 row("RB", "optimum", "10.1", "14.1", "constant", "lab", LAB_RB, K5, 15,
     "generate a fundamental niche for rainbow trout from 10.1°C to 14.1", "text",
     "Rainbow trout fundamental niche (-3 to +1 C of the 13.1 C optimum), derived from the growth optimum."),
 row("WCT", "max", "", "12", "daily_mean", "dist", "Montana (field)", K5, 17,
     "Westslope cutthroat trout are associated with habitats having average daily stream temperatures less than 12", "text",
     "Field association. Shares its sentence with the maximum daily row (16 C).", cited="Sloat 2001"),
 row("WCT", "max", "", "16", "daily_max", "dist", "Montana (field)", K5, 17,
     "average daily stream temperatures less than 12°C and maximum daily stream temperatures less than 16", "text",
     "Field association. Shares its sentence with the average daily row (12 C).", cited="Sloat 2001"),
 row("RB", "max", "", "13", "daily_mean", "dist", "Montana (field)", K5, 17,
     "whereas rainbow trout are associated with habitat having average daily stream temperatures less than 13", "text",
     "Rainbow trout field association. The rainbow clause carries no citation; the sentence cites Sloat 2001 for the cutthroat clause before it. Shares its sentence with the maximum daily row (18 C)."),
 row("RB", "max", "", "18", "daily_max", "dist", "Montana (field)", K5, 17,
     "average daily stream temperatures less than 13°C and maximum daily stream temperatures less than 18", "text",
     "Rainbow trout field association; no citation on this clause (see the 13 C row). Shares its sentence with the average daily row (13 C)."),
 row("WCT", "max", "", "16", "daily_mean", "expert", "Montana (laboratory results)", K5, 17,
     "This study indicates maximum average daily temperatures below 16", "text",
     "Water-quality recommendation: the maximum daily mean below 16 C would be adequate for maximum growth. Shares its sentence with the 20 C survival recommendation."),
 row("WCT", "max", "", "20", "daily_max", "expert", "Montana (laboratory results)", K5, 17,
     "whereas maximum daily stream temperatures below 20", "text",
     "Water-quality recommendation: maximum daily temperatures below 20 C would be adequate to maintain survival. Shares its sentence with the 16 C growth recommendation."),
]
with open("planning/active/draft-bear-evidence.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=HDR, lineterminator="\n"); w.writeheader(); w.writerows(rows)
print(len(rows), "rows")
