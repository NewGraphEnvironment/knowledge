"""Apply meaning-audit round 1 (audit-ps-round1.md, audit-tc-round1.md) to data/literature_evidence.csv.
Edits are keyed by the committed data row; deletions and appended twins are resolved last, and any
{row:N} / {new:K} placeholder in a note is replaced by the final data row number."""
import csv, io, re
P = "data/literature_evidence.csv"
rows = list(csv.reader(io.StringIO(open(P, newline="", encoding="utf-8").read())))
H = rows[0]; ix = H.index
data = [dict(zip(H, r)) for r in rows[1:]]
def row(n): return data[n - 1]
def setf(n, **kw):
    for k, v in kw.items():
        assert k in H, k
        row(n)[k] = v
def note_replace(n, old, new):
    assert old in row(n)["note"], (n, old); row(n)["note"] = row(n)["note"].replace(old, new)
def note_append(n, s): row(n)["note"] = row(n)["note"].rstrip() + " " + s

# --- ps family -------------------------------------------------------------
tennant_tail = "Tennant asks for the flows as instantaneous flows, not averages over a day, month or year (p. 10, Recommendations, item 4)."
for n in range(791, 803):
    assert row(n)["citation_key"] == "tennant1976InstreamFlow" and row(n)["metric"] == "seasonal_mean", n
    setf(n, metric="instantaneous"); note_append(n, tennant_tail)
abstract = "The abstract (p. 6) gives this level as 'a minimum instantaneous flow recommended to sustain short-term survival habitat for most aquatic life forms'."
note_append(799, abstract); note_append(800, abstract)
for n in (788, 789):
    assert row(n)["metric"] == "seasonal_mean"; setf(n, metric="unstated")
span = ("One minimum per stream, set by stream size (equation in the qual row): about 200 % MAD in the smallest "
        "streams falling to 30 % in the largest. The two values are the ends of that span, not a lower and an upper limit.")
for n in (808, 809, 824, 825):
    assert row(n)["bound"] == "range"; setf(n, bound="min"); row(n)["note"] = span + " " + row(n)["note"]
setf(851, note=("Figure 5, spring-run chinook spawning depth HSC, from logistic regression of redd and non-redd locations: "
                "non-zero suitability 0.8-7.0 ft, so the zero edges lie at those ends. The Gard (1998) correction for low "
                "availability of deep water could not be applied, because the deepest redd in the HSC sample was 3.0 ft (p. 26)."))
note_append(852, "The optimum lies beyond the deepest redd in the HSC sample (3.0 ft, p. 26).")
setf(863, note=("The introduction's recommended flow of 200 cfs for January-June gives more than 91 % of maximum WUA for "
                "steelhead/rainbow trout spawning, so the authors judge it near the optimum (hedged: 'may be close'). "
                "One curve for both; RB twin: data row {new:7}."))
note_replace(850, "a rigorous assessment is required", "a more rigorous assessment is recommended")
for n in range(696, 703):
    note_replace(n, "velocity at 0.6 x depth, measured at redds",
                 "criteria from depth and velocity measured at redds, usually at the upstream edge; most velocity criteria are for 0.6 x depth (p. 95)")
setf(704, note=("Depth in the pit of 47 completed chinook redds (mean 0.87 m). This is the excavated pit, not the upstream "
                "edge where depth is usually measured to reflect the site the fish chose (p. 95)."))
setf(787, value_min="0.7", value_max="",
     note=("Oregon Fish Commission method from summer rearing studies of juvenile coho in 19 streams: the rearing flow is "
           "the one that creates the maximum 'preferred' pool velocities, given as 0.7 ft/s. Read either as the preferred "
           "velocity itself or as the most pool area at that velocity; either way 0.7 ft/s is a preferred velocity, not a "
           "limit. Page is the PDF page (no page number is printed)."))
ash = ("Ash River (Hatfield et al. 2002 p. 92, PDF page) lists general standards below a chart with coho rows "
       "(spawning 45 %, incubation, rearing and over-wintering 20 % MAD), but names no species.")
for n in range(872, 876):
    assert row(n)["kind"] == "none" and row(n)["species_code"] == "CO"; note_append(n, ash)
for n in (876, 877):
    note_append(n, "Hatfield et al. 2002's Sinmax chart (p. 98, PDF page) gives an October conservation flow of 160 % MAD, which coincides with sockeye and coho spawning, but labels no species.")
note_append(783, "Bjornn and Reiser (1991) Table 4.10 gives Everest and Chapman (1972) steelhead age 0 at <15 cm/s, which matches this cell.")
note_append(865, "The same replacement threshold as the 10.6 m3/s row (p. 6), in percent MAD; not independent.")
note_append(864, "Restated as 36 % MAD on p. 8 (data row {row:865}).")
note_append(757, "The same 0 to <40 cm/s as data row {row:759} (the authors' summary on p. 11): one fact, two rows.")
note_append(759, "The same 0 to <40 cm/s as data row {row:757} (the literature statement on p. 10).")
note_append(731, "Figure 12 repeats this category-one curve (data row {row:742}): one curve, two rows.")
note_append(742, "Identical to the Figure 5 category-one curve (data row {row:731}).")

# --- tc family -------------------------------------------------------------
setf(881, kind="expert", note="Age-0+ fry: suggested upper limit of approximately 30 cm/s (the preference in the same sentence is the previous row).")
setf(892, bound="range", kind="dist",
     note=("Table 8 (observed habitat use) labels it 'preferred spawning depth', but the span is the extremes of Table 10's "
           "(p. 125) depths over redds: 0.15 m (Flathead River, range of 0.15-0.35) to 0.73-0.84 m (Meadow Creek, Kootenay "
           "Lake). A span of observed redd depths across studies, not a preference."))
for n in (894, 895):
    setf(n, region="Arrow Lakes, BC (McPhail and Murray 1979 study)")
    note_append(n, "Ford names no stream; McPhail and Baxter 1996 (p. 11) place the study in Mackenzie Creek.")
setf(905, note=("PDF page (Appendix A, 'Examples of Ptolemy's Criteria applied to British Columbia streams'; no printed "
                "number). Nechako periodicity chart, column 'Flow Standard (%mad)': bull trout 'Rearing (adult and juvenile)' "
                "55 % MAD, April-November. 55 % is Ptolemy's adult-rearing standard (Table 5, p. 41: juvenile 20 %, adult > 55 %); "
                "the chart applies it to adults and juveniles together, so it is not a juvenile-specific need. A worked "
                "example of the method on one river. Statistic not stated."))
setf(916, region="Not stated (Krueger 1981)")
setf(932, species_code="CT", citation_key="ford_etal1995LiteratureReviews", page="72",
     quote="Fry over 30 mm were found in water velocities less than 1 cm/s", quote_source="ocr",
     cited_source="Moore and Gregory 1988b", region="Cascade Mountains tributary streams", kind="dist",
     bound="max", value_min="", value_max="1", unit="cm/s", scale="site", life_history_form="",
     note=("Fry over 30 mm (fry under 30 mm were in velocities too low to measure). Ford's westslope chapter cites Moore "
           "and Gregory (1988b), Cascade Mountains streams, cutthroat not identified as westslope; the 2004 WCT account "
           "(p. 6) restates it for westslope cutthroat, citing Ford."))
setf(948, note=("Figure 13a, cutthroat trout (O. clarki as labelled; 7 studies, 123 redds, Irely and Skookum creeks). "
                "Preference 0.00 at 0 and 0.15 ft, 0.50 at 0.25 ft: 0.15 ft is the zero-suitability edge. An axis tick (0.8) "
                "sits between the columns."))
for n, s in ((965, "late summer base flow"), (967, "winter base flow")):
    note_replace(n, f"Excellent class, {s}.", f"Excellent class (best of three), {s}.")
    setf(n, bound="optimum")
for n in (974, 975):
    setf(n, life_history_form="resident")
    note_append(n, "The ST twin of this curve is data row " + ("{new:8}" if n == 974 else "775") + " (steelhead coded separately, per one row per named species).")
p30 = ("IFN are 'the minimum monthly flows required to protect fish' in each stanza (p. 30), set to give at least 90 % "
       "of the habitat available at the stanza's baseline mean annual 30-day low flow")
for n in (987, 989, 991):
    note_replace(n, "the table does not name a flow statistic for it", p30); setf(n, metric="monthly_mean")
for n in (994, 995):
    setf(n, metric="monthly_mean",
         note=("Table 14, Blackwater Gold Project instream flow study. Recommended flow (IFN) for 1 December-10 May, rainbow "
               "trout juveniles. IFN are 'minimum monthly flows' (p. 30); winter IFN were 'baseline March flows, the lowest "
               "mean monthly flows for the winter stanza' (p. 56; p. 83), though p. 30 calls them the winter-stanza mean "
               "annual 30-day low flow."))
note_replace(1005, "stuart_chislett1979 gives flows during an observed adult migration (10-15 m3/s, a dist row with no bound), which is not a need.",
             "stuart_chislett1979 (p. 50) gives the discharge of Martin Creek while adults were moving upstream (about 10-15 m3/s, OCR 'n/s'), which is an observation, not a need.")

# --- twins appended (new:1-7 RB of USFWS 2007 ST rows; new:8 ST twin of 974) ---
new = []
for k, n in enumerate((855, 856, 857, 858, 861, 862, 863), 1):
    t = dict(row(n)); t["species_code"] = "RB"
    t["note"] = re.sub(r"\s*\(one curve for both; the RB row is left to the trout-and-char draft\)", "", t["note"])
    t["note"] = t["note"].replace("One curve for both; RB twin: data row {new:7}.", "").rstrip()
    t["note"] += " RB twin of data row {row:%d}: the curve is for steelhead/rainbow trout, coded one row per named species." % n
    new.append(t)
    if n != 863:
        row(n)["note"] = re.sub(r"\s*\(one curve for both; the RB row is left to the trout-and-char draft\)", " (one curve for both)", row(n)["note"])
        note_append(n, "RB twin: data row {new:%d}." % k)
t = dict(row(974)); t["species_code"] = "ST"; t["life_history_form"] = ""
t["note"] = ("Figure 9b, O. mykiss juveniles (32 studies, 1954 fish; steelhead and resident rainbow observations combined): "
             "preference 1.00 from 0.75 to 0.95 ft/s. Axis ticks sit between the columns. ST twin of data row {row:974}.")
new.append(t)
note_replace(775, "so the same curve holds for RB (left to the trout-and-char draft)", "so the same curve holds for RB (data rows {row:974}, {row:975})")

# --- deletions, then numbering ---------------------------------------------
delete = {803, 819, 883, 915, 993}
for n in delete: row(n)["__del"] = True
kept = [r for r in data if not r.get("__del")]
final = {}
pos = 0
for i, r in enumerate(data, 1):
    if not r.get("__del"): pos += 1; final[i] = pos
allrows = kept + new
newpos = {k: len(kept) + k for k in range(1, len(new) + 1)}
def fill(s):
    s = re.sub(r"\{row:(\d+)\}", lambda m: str(final[int(m.group(1))]), s)
    return re.sub(r"\{new:(\d+)\}", lambda m: str(newpos[int(m.group(1))]), s)
for r in allrows: r["note"] = fill(r["note"])
out = io.StringIO(); w = csv.writer(out, lineterminator="\n"); w.writerow(H)
for r in allrows: w.writerow([r[h] for h in H])
open(P, "w", newline="", encoding="utf-8").write(out.getvalue())
print(len(data), "->", len(allrows), "rows; deleted", sorted(delete), "; twins at", list(newpos.values()))
