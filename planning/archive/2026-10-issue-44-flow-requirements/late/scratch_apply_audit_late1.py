"""Apply audit-late-round1.md to data/literature_evidence.csv. In place only; no row added or removed."""
import csv, io
P = "data/literature_evidence.csv"
rows = list(csv.reader(io.StringIO(open(P, newline="", encoding="utf-8").read())))
H = rows[0]; data = [dict(zip(H, r)) for r in rows[1:]]
def row(n): return data[n - 1]
def setf(n, **kw):
    for k, v in kw.items():
        assert k in H, k; row(n)[k] = v
def to_qual(n, note):
    setf(n, kind="qual", bound="", value_min="", value_max="", unit="", metric="", note=note)

assert row(1046)["bound"] == "optimum"
setf(1046, bound="range", note=("Focal point velocities of juvenile cutthroat (Griffith 1972; the reference list names brook and "
     "cutthroat trout in small northern Idaho streams), given in the juvenile section of the rainbow trout model. An "
     "observed span, not a limit and not an optimum; the maximum observed is the next row. Same sentence as the 22 cm/s "
     "row (next row)."))
for n in (1049, 1050):
    assert row(n)["region"].startswith("Not stated"), n
    setf(n, region="Lardeau River, British Columbia; Deschutes River, Oregon; South Fork Feather River, California; Idaho streams (p. 39)")
setf(1053, note=("Figure 3, fry (<2 inches) mean water column velocity SI curve, n = 619: SI 1.0 at 0, 0.78 at 0.49, 0.19 at "
     "0.98, 0.04 at 1.48, 0.01 at 1.97-2.46 and 0 at 2.95 ft/s, the upper zero-suitability edge (coordinates checked on the "
     "rendered page; the OCR drops the 2.46 line). Weighted, normalized frequencies of fry observations (p. 44). The quote "
     "is the coordinate columns as the OCR emits them."))
setf(1054, note=("Figure 4, juvenile mean water column velocity SI curve, n = 546: SI 1.0 at 0, 0.99 at 0.49, 0.59 at 0.98, "
     "0.24 at 1.48, 0.08 at 1.97, 0.02 at 2.46-3.44 and 0 at 3.50 ft/s, the upper zero-suitability edge (coordinates "
     "checked on the rendered page). From Moyle et al. (1983) observations of juveniles 2.0-4.7 inches long (pp. 47-48). "
     "The quote is the coordinate columns as the OCR emits them."))

for n in (954, 955, 960, 961, 963):
    assert row(n)["citation_key"] == "ford_etal1995LiteratureReviews", n
to_qual(954, ("Ford et al. call 30-90 cm/s Raleigh et al.'s (1984) optimal spawning velocity. The original's optimum is 30-70 "
     "cm/s, with velocities below 10 or above 90 cm/s unsuitable (p. 8; data rows 1044, 1045). Its spawning curve puts the "
     "unsuitable edges at 1.0 and 3.0 ft/s, about 30 and 91 cm/s, with SI 1.0 from 1.6 to 3.0 ft/s (pp. 39, 41; data rows "
     "1049, 1050). So Ford's 30-90 is a suitable span, not an optimum, and no value is drawn here."))
to_qual(955, ("Ford et al. give 0.15-2.5 m as the depths Raleigh et al. (1984) paired with the optimal spawning velocity, and "
     "add that the main consideration with depth is enough flow for incubation and emerging fry. Raleigh et al. print no "
     "such span. 2.5 m is the 8.2 ft upper edge of the spawning depth curve, whose lower edge is 0.6 ft (pp. 41, 43; data "
     "rows 1051, 1052). 15 cm is the minimum depth in the model's spawning-site definition (p. 28; data row 1048). No value "
     "is drawn here."))
to_qual(960, ("Ford et al. give 10-12 cm/s and a maximum of 22 cm/s for rainbow trout juveniles 5-13 cm long, citing Raleigh "
     "et al. (1984) and Rose (1986). Raleigh et al. give exactly these numbers for juvenile cutthroat in Idaho (Griffith "
     "1972; p. 9; data rows 1046, 1047), with no length. Rose (1986) is a study of brook trout growth after rainbow trout "
     "emergence (Ford's reference list). So the velocities are not a rainbow trout measurement, and no value is drawn here."))
for n, season, orig in ((961, "late summer", 1039), (963, "winter", 1041)):
    to_qual(n, (f"Excellent class, {season} base flow, as Ford et al. print it: 'greater than 55%' of average annual daily flow, "
        "with 25-50 % fair and below 25 % poor, citing Raleigh et al. (1984). The original prints '≥ 50%' for excellent "
        f"(p. 6; data row {orig}), so Ford's 55 leaves 50-55 % unclassed and is not the source's value; no value is drawn "
        "here. In the rainbow trout chapter; the sentence itself says 'trout'. Printed page 53 (the OCR reads '33')."))
for n, season, orig, sib in ((962, "late summer", 1040, 961), (964, "winter", 1042, 963)):
    setf(n, note=(f"Lower edge of the fair class, {season} base flow: below 25 % is poor. The base or lowest flow of late summer "
        "or winter months, as a percent of average annual daily flow (mean annual discharge), rated for trout habitat, citing "
        f"Raleigh et al. (1984). The 25 % edge matches the original (p. 6; data row {orig}); Ford's '>55 %' excellent class "
        f"does not (the original prints '≥ 50%'; data row {sib}). In the rainbow trout chapter; the sentence itself says "
        "'trout'. Printed page 53 (the OCR reads '33')."))
setf(942, note=("Spawning velocities from studies reported in Hickman and Raleigh (1982). The original gives 11-92 cm/s, as "
     "average water column velocities for embryo development (p. 5; data row 1037), so Ford's upper 90 is 2 cm/s low."))
setf(943, note=("Estimated optimal spawning velocity range. Table 4 (p. 70) lists 30-60 cm/s as estimated optimal spawning "
     "velocity for westslope cutthroat. Matches the original, Hickman and Raleigh (1982) p. 6, 'We assume that optimal "
     "velocities range from 30 to 60 cm/sec' (read on the rendered page; the scan's OCR cannot be quoted, so the original "
     "has no row of its own)."))
setf(958, note=("Recently emerged fry. The sentence names no source; it matches Raleigh et al. (1984) p. 8 ('Fry utilize "
     "velocities less than 30 cm/sec, but velocities less than 8 cm/sec are preferred'), whose cited studies are Griffith "
     "(1972), brook and cutthroat trout in northern Idaho, and Horner and Bjornn (1976), trout and salmon fry of unnamed "
     "species. So the species measured is uncertain."))
setf(959, note=("Recently emerged fry prefer velocities below 8 cm/s. The sentence names no source; see the previous row: it "
     "matches Raleigh et al. (1984) p. 8, whose cited studies are Griffith (1972, brook and cutthroat trout) and Horner and "
     "Bjornn (1976, trout and salmon fry), so the species measured is uncertain."))
assert row(936)["species_code"] == "WCT" and row(936)["value_max"] == "22", row(936)
setf(936, note=("Age 1+ and 2+. The sentence follows Griffith (1972) on westslope cutthroat fry and names no source of its own; "
     "the 2004 WCT account (p. 6) repeats the maximum for westslope cutthroat, citing Ford et al. 1995. The same maximum "
     "traces to Griffith (1972), cutthroat in small northern Idaho streams: Raleigh et al. (1984) p. 9 give 10-12 and 22 "
     "cm/s for juvenile cutthroat (data rows 1046, 1047), and Hickman and Raleigh (1982) p. 5 give 10-14 and 22 cm/s for adults."))
out = io.StringIO(); w = csv.writer(out, lineterminator="\n"); w.writerow(H)
for r in data: w.writerow([r[h] for h in H])
open(P, "w", newline="", encoding="utf-8").write(out.getvalue())
print("applied")
