"""Apply meaning-audit round 2 (audit-round2.md) to data/literature_evidence.csv. No row is added or
deleted, so data row numbers are unchanged."""
import csv, io
P = "data/literature_evidence.csv"
rows = list(csv.reader(io.StringIO(open(P, newline="", encoding="utf-8").read())))
H = rows[0]; data = [dict(zip(H, r)) for r in rows[1:]]
def row(n): return data[n - 1]
def setf(n, **kw):
    for k, v in kw.items():
        assert k in H, k; row(n)[k] = v
def rep(n, old, new):
    assert old in row(n)["note"], (n, old); row(n)["note"] = row(n)["note"].replace(old, new)

for n in range(791, 803):
    rep(n, "(p. 10, Recommendations, item 4)", "(p. 10, Recommendations, item 1)")
setf(849, note=("Figure 5, spring-run chinook spawning depth HSC, from logistic regression of redd and non-redd locations: "
                "non-zero suitability 0.8-7.0 ft, so the zero edges lie at those ends; the HSC redd depths span the same "
                "0.8-7.0 ft (p. 24). The Gard (1998) correction for low availability of deep water could not be applied, "
                "because the deepest spring-run redd in the six study sites was 3.0 ft (p. 26)."))
setf(850, note=("Figure 5, spring-run chinook spawning depth HSC: optimum 6.0-6.2 ft. HSC redd depths reach 7.0 ft (p. 24); "
                "the deepest redd in the six study sites was 3.0 ft (p. 26). The sensitivity analysis gives the depth "
                "regression's first maximum as 2.1 ft (p. 36)."))
blank = ("Coded with no bound: neither value is a limit. A program reading a bound would take 30 % MAD, which is the "
         "minimum only for the largest streams.")
for n in (807, 808, 822, 823):
    assert row(n)["bound"] == "min" and row(n)["value_max"] == "200", n
    setf(n, bound=""); row(n)["note"] = row(n)["note"].replace(
        " the percent falls as stream size rises (equation in the qual row).", " the percent falls as stream size rises.") + " " + blank
for n in (825, 837):
    row(n)["note"] += " The source does not say what sets the flow within the 50-100 % span."
for n in (983, 985, 987):
    assert row(n)["metric"] == "monthly_mean", n
    setf(n, metric="unstated"); row(n)["note"] += " p. 30 does not say whether a 'monthly flow' is a mean or a within-month minimum."
for n in (989, 990):
    rep(n, "(p. 56; p. 83)", "(p. 56; p. 83: 'baseline mean March flows')")
setf(928, note=("Fry over 30 mm (fry under 30 mm were in velocities too low to measure). Moore and Gregory (1988b) studied "
                "'cutthroat trout fry (Salmo clarki) in Cascade Mountain streams' (Ford's reference list); this sentence names "
                "no subspecies. Ford calls the same study's fish westslope and interior cutthroat on p. 71, so the subspecies "
                "is uncertain and the row is coded generic cutthroat. The 2004 WCT account (p. 6) restates the value for "
                "westslope cutthroat, citing Ford."))
setf(889, note=("Table 8 (observed habitat use) labels it 'preferred spawning depth'. The span matches the ends of Table 10 "
                "(p. 125), mean water depth over redds by study: 0.15 m is the low end of the Flathead River range (mean 0.28, "
                "range 0.15-0.35) and 0.84 m the high end of Meadow Creek's mean of 0.73-0.84 m (Kootenay Lake). Ford does not "
                "say Table 8 was compiled from Table 10. Coded as an observed span, not a preference."))
setf(742, region="Portage Creek and Indian River (Susitna River tributaries), Alaska (Vincent-Lang et al. 1984)",
     note=("Figure 12 depth curve (labelled category one) from Vincent-Lang et al. (1984), modified on the assumption that "
           "depths of 48.8-122.0 cm do not limit spawning (p. 54): SI 0 at and below 15.2 cm, 1.0 from 30.5 cm. Quote is the "
           "cm and ft columns. Numerically identical to the Figure 5 category-one curve (data row 731)."))
regions = {735: "Little North Santiam, Molalla and South Fork McKenzie rivers, Oregon (Sams and Pearson 1963)",
           736: "Humbug, East Humbug and Moon creeks and Tillamook River, Oregon (Sams and Pearson 1963)",
           737: "Battle Creek, California (Vogel 1982)", 738: "Battle Creek, California (Vogel 1982)",
           739: "Upper Yakima and American rivers, Washington (Stempel 1984)",
           740: "Upper Yakima and American rivers, Washington (Stempel 1984)",
           741: "Portage Creek and Indian River (Susitna River tributaries), Alaska (Vincent-Lang et al. 1984)",
           743: "Upper Skagit River, Washington (Kurko 1977)", 744: "Upper Skagit River, Washington (Kurko 1977)"}
for n, reg in regions.items():
    assert row(n)["citation_key"] == "raleigh_etal1986HabitatSuitablility" and row(n)["region"].startswith("Not stated"), n
    setf(n, region=reg)
assert row(760)["bound"] == "min"
setf(760, bound="optimum"); row(760)["note"] = "Excellent class (best of three). " + row(760)["note"]
setf(876, note="Range of study means of depth at redds, as written. The velocities in the same sentence are data rows 497 and 498.")
rep(886, "is the one in the hagen_weber2019 row (14-52 cm/s)", "is data row 497 (hagen_weber2019, 14-52 cm/s)")
for n in (1011, 1012, 1013):
    rep(n, "the curve is for steelhead/rainbow trout", "the WUA is for steelhead/rainbow trout")
row(1000)["note"] = row(1000)["note"].rstrip()
out = io.StringIO(); w = csv.writer(out, lineterminator="\n"); w.writerow(H)
for r in data: w.writerow([r[h] for h in H])
open(P, "w", newline="", encoding="utf-8").write(out.getvalue())
print("applied; rows", len(data))
