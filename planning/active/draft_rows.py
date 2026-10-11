"""Draft #40 rows: Bear et al. 2005 and 2007. Writes planning/active/draft-bear-evidence.csv.
Notes cite other rows by label ({r[label]}), resolved to data row numbers after the rows are ordered."""
import csv
HDR = open("data/literature_evidence.csv", encoding="utf-8").readline().strip().split(",")
FIRST = 1071  # data row of the first appended row (the table held 1,070 data rows before #40)
K7, K5 = "bear_etal2007ComparativeThermal", "bear_etal2005ThermalRequirements"
LAB_WCT = "Laboratory (Montana wild-stock westslope cutthroat)"
LAB_RB = "Laboratory (Fish Lake strain rainbow trout, Montana)"
OCR = "The text layer renders the degree sign as '8', so the quote is checked against OCR."
M7 = ("Juveniles (mean sizes across experiments 102-126 mm TL for WCT, 110-152 mm TL for RB; p. 1115); 60-d acclimated chronic exposure, acclimated at 14 C "
      "and ramped 1 C/day to a held test temperature, satiation ration (p. 1114).")
M5G = ("Juveniles; 60-d acclimated chronic exposure, ramped 1 C/day from 14 C to a held test temperature (p. 8). "
       "The growth curves use only the third WCT and the second RB experiment, fed above satiation (p. 9; Figs. 1 and 2); "
       "the 2007 paper's growth curves carry the same coefficients (2007 Fig. 4, p. 1118), so the optima are one estimate "
       "published twice.")
M5S = ("Juveniles; 60-d acclimated chronic exposure, ramped 1 C/day from 14 C to a held test temperature (p. 8). "
       "The survival data pool all three WCT and both RB experiments: p. 11 reports 16 WCT test temperatures where each "
       "experiment had 12 (p. 8), and the LD50 figures name every experiment (Figs. 6 and 8, pp. 28 and 30). The earlier "
       "experiments had a fixed ration below satiation at some temperatures (p. 9). The 60-d survival curve (Fig. 5) carries "
       "the same coefficients as the 2007 paper's (2007 Fig. 1, p. 1116), so the survival-curve UUILTs (19.6 and 24.3 C) are "
       "one estimate published twice; the LD50-regression UUILTs (19.7 and 24.2 C) are the report's alone.")
TWICE7 = ("The same estimate as the 2005 report's survival-curve value: the paper's survival curve carries the "
          "report's coefficients (Fig. 1, p. 1116), so the two are not independent. The paper describes satiation rations "
          "(p. 1114); the report says the earlier experiments pooled into these survival data had a fixed ration below "
          "satiation at some temperatures (p. 9).")

Q_UUILT7 = ("The predicted UUILT for westslope cutthroat trout (19.6°C; 95% confidence interval [CI] = 19.1- 19.9°C) "
            "was 4.7°C lower than that for rainbow trout (24.3")
Q_LIM7 = "upper lethal limit (20°C for westslope cutthroat trout; 24"
Q_OPT7 = "similar peak growth temperatures (westslope cutthroat trout: 13.6°C; rainbow trout: 13.1"
Q_OPT5W = ("The optimum growth temperature estimated by regression analysis was 13.6°C with an optimal growth range, "
           "based on 95% confidence intervals, from 10.3°C to 17.0")
Q_OPT5R = ("The optimum growth temperature for rainbow trout estimated by regression analysis was 13.1°C with an "
           "optimal growth range from 6.8°C to 18.2")
Q_SLOAT_W = ("Westslope cutthroat trout are associated with habitats having average daily stream temperatures less "
             "than 12°C and maximum daily stream temperatures less than 16")
Q_SLOAT_R = ("whereas rainbow trout are associated with habitat having average daily stream temperatures less than "
             "13°C and maximum daily stream temperatures less than 18")
Q_REC5 = ("This study indicates maximum average daily temperatures below 16°C would be adequate for maximum growth, "
          "whereas maximum daily stream temperatures below 20")

SPEC = []  # (label, fields..., note template)
def row(label, sp, bound, vmin, vmax, metric, kind, region, key, page, quote, qs, note, cited=""):
    SPEC.append((label, dict(zip(HDR, [sp, "rearing", "", "temperature", "", bound, vmin, vmax, "degC", metric, kind,
                                       region, key, str(page), quote, qs, "", cited, note, ""]))))

# ---- Bear et al. 2007 (TAFS) ----
row("u7w", "WCT", "max", "", "19.6", "constant", "lab", LAB_WCT, K7, 1115, Q_UUILT7, "ocr",
    "60-d ultimate upper incipient lethal temperature (LT50 at day 60); 95% CI 19.1-19.9 C. " + M7 +
    " Shares its quote with the RB row (24.3 C, data row {u7r}). The 2005 report gives 19.7 C by its LD50 regression and "
    "19.6 C by its survival curve (p. 12, data rows {u5w}, {s5w}). " + TWICE7 +
    " Cleator et al. 2009 (data row 521) and Thorley et al. 2021 (data row 522) cite this paper. " + OCR)
row("u7r", "RB", "max", "", "24.3", "constant", "lab", LAB_RB, K7, 1115, Q_UUILT7, "ocr",
    "Rainbow trout 60-d ultimate upper incipient lethal temperature; 95% CI 24.0-24.7 C. " + M7 +
    " Shares its quote with the WCT row (19.6 C, data row {u7w}). The 2005 report gives 24.2 C by its LD50 regression and "
    "24.3 C by its survival curve (p. 12, data rows {u5r}, {s5r}). " + TWICE7 + " " + OCR)
row("d7w", "WCT", "max", "", "24.1", "constant", "lab", LAB_WCT, K7, 1117,
    "the 7-d UUILT for westslope cutthroat trout in our study (24.1", "ocr",
    "7-d UUILT: the LT50 at day 7, one of the time points in Fig. 2 (method p. 1115; figure p. 1116), for comparison "
    "with 7-d tests elsewhere. The 60-d UUILT is 19.6 C "
    "(p. 1115, data row {u7w}); p. 1118 puts it 4.5 C below the 7-d value. The 2005 report gives 24.7 C by a different method (p. 16, data row {d5w}). " + OCR)
row("d7r", "RB", "max", "", "26.0", "constant", "lab", LAB_RB, K7, 1118,
    "the 7-d UUILT derived from our study (26.0", "ocr",
    "Rainbow trout 7-d UUILT: the LT50 at day 7, one of the time points in Fig. 2 (method p. 1115; figure p. 1116). The 60-d UUILT is 24.3 C (p. 1115, data row "
    "{u7r}), 1.7 C lower (p. 1118). The 2005 report gives 31.1 C by a different method (p. 16, data row {d5r}). " + OCR)
row("l7w", "WCT", "max", "", "20", "constant", "lab", LAB_WCT, K7, 1117, Q_LIM7, "ocr",
    "The page calls 20 C the species' upper lethal limit, as temperatures approached which fish became lethargic and "
    "ceased feeding. The fitted 60-d UUILT is 19.6 C (p. 1115, data row {u7w}). Shares its quote with the RB row "
    "(24 C, data row {l7r}). " + OCR)
row("l7r", "RB", "max", "", "24", "constant", "lab", LAB_RB, K7, 1117, Q_LIM7, "ocr",
    "The page calls 24 C rainbow trout's upper lethal limit, as temperatures approached which fish became lethargic and "
    "ceased feeding. The fitted 60-d UUILT is 24.3 C (p. 1115, data row {u7r}). Shares its quote with the WCT row "
    "(20 C, data row {l7w}). " + OCR)
row("o7w", "WCT", "optimum", "13.6", "13.6", "constant", "lab", LAB_WCT, K7, 1117, Q_OPT7, "ocr",
    "Peak of 60-d relative growth at satiation, from a regression over 8-20 C (growth was assessed at 8-24 C, p. 1115, "
    "but no WCT survived 24 C long enough to measure growth, p. 1117). " + M7 +
    " Shares its quote with the RB row (13.1 C, data row {o7r}). The 2005 report gives the same 13.6 C (p. 11, data row {o5w}). " + OCR)
row("o7r", "RB", "optimum", "13.1", "13.1", "constant", "lab", LAB_RB, K7, 1117, Q_OPT7, "ocr",
    "Rainbow trout peak of 60-d relative growth at satiation. Shares its quote with the WCT row (13.6 C, data row {o7w}). "
    "p. 1118: much lower than the 17.2 C of Hokanson et al. 1977; the paper suggests their smaller fish (30 mm TL) or "
    "strain differences. The 2005 report gives the same 13.1 C (p. 11, data row {o5r}). " + OCR)
row("n7r", "RB", "optimum", "10.1", "14.1", "constant", "lab", LAB_RB, K7, 1119,
    "10.6—-14.6°C; rainbow trout: 10.1-14.1°C), as is their thermal preferendum", "ocr",
    "Rainbow trout fundamental thermal niche, defined on p. 1118 (Christie and Regier 1988) as 3 C below to 1 C above "
    "the 13.1 C optimum; derived, not measured separately. Shares its quote with the WCT niche (data row {n7w}). The 2005 "
    "report gives the same niche (p. 15, data row {n5r}). " + OCR)
row("a7", "WCT", "max", "", "13", "daily_max", "expert", "Montana (laboratory results)", K7, 1113,
    "maximum daily temperatures near the optimum growth temperature of 13–15", "ocr",
    "Abstract: maximum daily temperatures near 13-15 C would ensure suitable thermal habitat for WCT populations. "
    "Stated as 13-15 C; the lower end is stored. The Discussion (p. 1119, data row {b7}) restates it as maximum "
    "temperatures near an upper limit of 13-15 C, citing field studies. " + OCR)
row("b7", "WCT", "max", "", "13", "unstated", "expert", "Montana (field studies, corroborated by laboratory results)", K7, 1119,
    "maximum temperatures near an upper limit of 13–15", "ocr",
    "Discussion: field investigations, which the laboratory results corroborate, indicate that maximum temperatures "
    "near an upper limit of 13-15 C would delineate suitable habitat for long-term persistence. Names no statistic "
    "(the abstract's version, p. 1113, data row {a7}, says maximum daily). Stated as 13-15 C; the lower end is stored. " + OCR,
    cited="Sloat et al. 2001, 2005; Shepard 2004")
# ---- Bear et al. 2005 (WFHI final report) ----
row("u5w", "WCT", "max", "", "19.7", "constant", "lab", LAB_WCT, K5, 12,
    "The ultimate upper incipient lethal temperature, derived from plotting LD50 for each temperature followed by "
    "exponential regression analysis, was 19.7", "text",
    "60-d UUILT by exponential regression of LD50 (days) on temperature, pooling all three WCT experiments (Fig. 6, "
    "p. 28); 95% CI 19.1-20.3 C; the value the abstract (p. 2) headlines. " + M5S +
    " The same page gives 19.6 C by the survival curve (data row {s5w}); the 2007 paper reports 19.6 C, CI 19.1-19.9 "
    "(p. 1115, data row {u7w}).")
row("s5w", "WCT", "max", "", "19.6", "constant", "lab", LAB_WCT, K5, 12,
    "as predicted by regression analysis of the survival vs. temperature curve, was 19.6", "text",
    "Temperature at which 50% survived 60 days, by sigmoid regression of survival on temperature; 95% CI 19.1-19.9 C. "
    "The report says both methods gave a similar UUILT (the other gives 19.7 C, same page, data row {u5w}). " + M5S)
row("s5r", "RB", "max", "", "24.3", "constant", "lab", LAB_RB, K5, 12,
    "as predicted by regression analysis of the survival vs. temperature curve, was 24.3", "text",
    "Rainbow trout: temperature at which 50% survived 60 days, by the survival curve; 95% CI 24.0-24.7 C. The same page "
    "gives 24.2 C by LD50 regression (data row {u5r}); the 2007 paper reports 24.3 C (p. 1115, data row {u7r}). " + M5S)
row("u5r", "RB", "max", "", "24.2", "constant", "lab", LAB_RB, K5, 12,
    "followed by exponential regression analysis, was 24.2", "text",
    "Rainbow trout 60-d UUILT by exponential regression of LD50, pooling both RB experiments (Fig. 8, p. 30); 95% CI 22.9-25.4 C here, while the abstract (p. 2) "
    "prints 24.2 C with a 95% CI of 20.3-24.2 C. " + M5S + " The same page gives 24.3 C by the survival curve "
    "(data row {s5r}); the 2007 paper reports 24.3 C (p. 1115, data row {u7r}).")
row("d5w", "WCT", "max", "", "24.7", "constant", "lab", LAB_WCT, K5, 16,
    "The predicted UUILT at seven days for westslope cutthroat trout from exponential regression in this study was 24.7", "text",
    "7-d UUILT predicted from the exponential regression of LD50 (days) on temperature, in which LD50 was set to 120 d "
    "at 18 and 20 C (p. 10), pooling all three WCT experiments (Fig. 6, p. 28); for comparison with 7-d tests elsewhere. The 60-d UUILT is 19.7 C (p. 12, data row {u5w}). "
    "The 2007 paper gives 24.1 C, its day-7 LT50 (p. 1117, data row {d7w}).")
row("d5r", "RB", "max", "", "31.1", "constant", "lab", LAB_RB, K5, 16,
    "the predicted 7-d UUILT, from exponential regression, for rainbow trout in this study was 31.1", "text",
    "Rainbow trout 7-d UUILT predicted from the exponential LD50 regression over both RB experiments (Fig. 8, p. 30; "
    "LD50 set to 120 d at 22 and 24 C, p. 10), "
    "so an extrapolation above the 28 C highest test temperature; the report calls it far greater than the UUILT "
    "previously reported for rainbow trout (26.2 C and 25.6 C, same page). The 2007 paper gives 26.0 C, its day-7 "
    "LT50 (p. 1118, data row {d7r}).")
row("o5w", "WCT", "optimum", "13.6", "13.6", "constant", "lab", LAB_WCT, K5, 11, Q_OPT5W, "text",
    "Peak of 60-d relative growth of age-1 juveniles at satiation (quadratic regression over 8-20 C). " + M5G +
    " Shares its quote with the optimal growth range row (10.3-17.0 C, data row {g5w}). The 2007 paper gives the same "
    "13.6 C (p. 1117, data row {o7w}).")
row("g5w", "WCT", "optimum", "10.3", "17.0", "constant", "lab", LAB_WCT, K5, 11, Q_OPT5W, "text",
    "Optimal growth range: the span around the 13.6 C peak between the lower and upper 95% confidence intervals of the "
    "growth regression (defined p. 10). Shares its quote with the 13.6 C optimum row (data row {o5w}).")
row("z5w", "WCT", "range", "5.5", "21.8", "constant", "lab", LAB_WCT, K5, 11,
    "The predicted lower and upper thermal limits for westslope cutthroat trout growth were 5.5°C and 21.8", "text",
    "Zero-growth edges: where the quadratic growth regression crosses the x-axis (same page), predicted rather than "
    "tested (growth was tested at 8-20 C). Limits for growth, not survival.")
row("o5r", "RB", "optimum", "13.1", "13.1", "constant", "lab", LAB_RB, K5, 11, Q_OPT5R, "text",
    "Rainbow trout peak of 60-d relative growth at satiation. " + M5G + " Shares its quote with the optimal growth range "
    "row (6.8-18.2 C, data row {g5r}). The 2007 paper gives the same 13.1 C (p. 1117, data row {o7r}).")
row("g5r", "RB", "optimum", "6.8", "18.2", "constant", "lab", LAB_RB, K5, 11, Q_OPT5R, "text",
    "Rainbow trout optimal growth range: the 95% confidence intervals of the growth regression around the 13.1 C peak "
    "(defined p. 10). Shares its quote with the 13.1 C optimum row (data row {o5r}).")
row("z5r", "RB", "range", "1.8", "24.3", "constant", "lab", LAB_RB, K5, 11,
    "The predicted lower and upper thermal limits for rainbow trout growth were 1.8°C and 24.3", "text",
    "Rainbow trout zero-growth edges, where the quadratic growth regression crosses the x-axis; predicted, not tested. "
    "Limits for growth, not survival.")
row("n5w", "WCT", "optimum", "10.6", "14.6", "constant", "lab", LAB_WCT, K5, 14,
    "as -3 to +1°C of the optimum growth temperature, from 10.6°C to 14.6", "text",
    "Fundamental niche (Christie and Regier 1988: -3 to +1 C of the 13.6 C optimum growth temperature), derived from "
    "the growth optimum. The 2007 paper gives the same niche (p. 1119, data row {n7w}).")
row("n5r", "RB", "optimum", "10.1", "14.1", "constant", "lab", LAB_RB, K5, 15,
    "generate a fundamental niche for rainbow trout from 10.1°C to 14.1", "text",
    "Rainbow trout fundamental niche, derived from the 13.1 C growth optimum by the Christie and Regier definition given "
    "on p. 14 (-3 to +1 C). The 2007 paper gives the same niche (p. 1119, data row {n7r}).")
row("f5w1", "WCT", "max", "", "12", "unstated", "dist", "Madison River basin, Montana (field; Sloat 2001)", K5, 17, Q_SLOAT_W, "text",
    "Field association. The page does not say whether 'average daily' is each day's mean or a mean of daily means "
    "over a period, so metric unstated. Shares its quote with the maximum daily row (16 C, data row {f5w2}).", cited="Sloat 2001")
row("f5w2", "WCT", "max", "", "16", "daily_max", "dist", "Madison River basin, Montana (field; Sloat 2001)", K5, 17, Q_SLOAT_W, "text",
    "Field association. Shares its quote with the average daily row (12 C, data row {f5w1}).", cited="Sloat 2001")
row("f5r1", "RB", "max", "", "13", "unstated", "dist", "Not stated (field)", K5, 17, Q_SLOAT_R, "text",
    "Rainbow trout field association. The page does not say whether 'average daily' is each day's mean or a mean of "
    "daily means over a period, so metric unstated. The clause carries no citation or place; the sentence cites Sloat 2001 for the "
    "cutthroat clause before it. Shares its quote with the maximum daily row (18 C, data row {f5r2}).")
row("f5r2", "RB", "max", "", "18", "daily_max", "dist", "Not stated (field)", K5, 17, Q_SLOAT_R, "text",
    "Rainbow trout field association; no citation or place on this clause (see data row {f5r1}). Shares its quote with "
    "the average daily row (13 C, data row {f5r1}).")
row("r5g", "WCT", "max", "", "16", "daily_mean", "expert", "Montana (laboratory results)", K5, 17, Q_REC5, "text",
    "Water-quality recommendation: maximum average daily temperatures below 16 C would be adequate for maximum growth. "
    "Shares its quote with the 20 C survival recommendation (data row {r5s}).")
row("r5s", "WCT", "max", "", "20", "daily_max", "expert", "Montana (laboratory results)", K5, 17, Q_REC5, "text",
    "Water-quality recommendation: maximum daily stream temperatures below 20 C would be adequate to maintain survival. "
    "Shares its quote with the 16 C growth recommendation (data row {r5g}).")

# ---- appended after round 2 (rows are appended, never inserted) ----
row("n7w", "WCT", "optimum", "10.6", "14.6", "constant", "lab", LAB_WCT, K7, 1119,
    "10.6—-14.6°C; rainbow trout: 10.1-14.1°C), as is their thermal preferendum", "ocr",
    "Fundamental thermal niche, defined on p. 1118 (Christie and Regier 1988) as 3 C below to 1 C above the optimum "
    "growth temperature; derived from the 13.6 C optimum, not measured separately. The sentence names the species on "
    "p. 1118. The OCR reads the printed en dash as a doubled dash. Shares its quote with the RB niche (data row {n7r}). "
    "The 2005 report gives the same niche (p. 14, data row {n5w}). " + OCR)

num = {lab: FIRST + i for i, (lab, _) in enumerate(SPEC)}
out = []
for lab, d in SPEC:
    d = dict(d); d["note"] = d["note"].format(**num); out.append(d)
with open("planning/active/draft-bear-evidence.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=HDR, lineterminator="\n"); w.writeheader(); w.writerows(out)
print(len(out), "rows;", {k: v for k, v in num.items() if k in ("u7w", "n7w", "n5w")})
