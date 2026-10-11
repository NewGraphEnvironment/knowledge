"""Apply audit-late-round2.md to data/literature_evidence.csv. Notes only; no row added or removed."""
import csv, io
P = "data/literature_evidence.csv"
rows = list(csv.reader(io.StringIO(open(P, newline="", encoding="utf-8").read())))
H = rows[0]; data = [dict(zip(H, r)) for r in rows[1:]]
def row(n): return data[n - 1]
def note(n, s): row(n)["note"] = s
note(954, ("Ford et al. call 30-90 cm/s Raleigh et al.'s (1984) optimal spawning velocity. The original's optimum is 30-70 "
  "cm/s, with velocities below 10 or above 90 cm/s unsuitable (p. 8; data rows 1044, 1045). Its IFIM section says the "
  "spawning velocity curve assumes velocities below 1.0 or above 3.0 ft/s (about 30 and 91 cm/s) are unsuitable, with "
  "most redds at 1.6-3.0 ft/s (p. 39; also p. 44). The plotted curve, Figure 2, has SI 0 at 0.9 and 3.1 ft/s and SI 1.0 "
  "from 1.6 to 3.0 ft/s (p. 41; data rows 1049, 1050). Ford's 30-90 matches p. 39's suitable span, not an optimum, and no "
  "value is drawn here."))
note(955, ("Ford et al. give 0.15-2.5 m as the depths Raleigh et al. (1984) paired with the optimal spawning velocity, and "
  "add that the main consideration with depth is enough flow for incubation and emerging fry. Raleigh et al. print no such "
  "span. The text treats depths below 0.6 ft or above 8.2 ft (about 0.18 and 2.5 m) as unsuitable, 'although 8.2 feet may "
  "not be the upper limit' (p. 43). Figure 2 has SI 0 at 0.6 and 8.3 ft and SI 1.0 from 0.7 to 8.2 ft (p. 41; data rows "
  "1051, 1052). So Ford's 2.5 m is the text's 8.2 ft edge, and 0.15 m is not the 0.6 ft lower edge. 15 cm is the minimum "
  "depth in the model's spawning-site definition (p. 28; data row 1048). No value is drawn here."))
for n, season, orig, fr, fo in ((962, "late summer", 1040, 961, 1039), (964, "winter", 1042, 963, 1041)):
    note(n, (f"Lower edge of the fair class, {season} base flow: below 25 % is poor. The base or lowest flow of late summer or "
      "winter months, as a percent of average annual daily flow (mean annual discharge), rated for trout habitat, citing "
      f"Raleigh et al. (1984). The 25 % edge matches the original (p. 6; data row {orig}). Ford's excellent class, 'greater "
      f"than 55%' (data row {fr}), does not: the original prints '≥ 50%' (data row {fo}). In the rainbow trout chapter; the "
      "sentence itself says 'trout'. Printed page 53 (the OCR reads '33')."))
note(943, ("Estimated optimal spawning velocity range. Table 4 (p. 70) lists 30-60 cm/s as estimated optimal spawning "
  "velocity for westslope cutthroat. Matches the original, Hickman and Raleigh (1982) pp. 5-6, 'We assume that optimal "
  "velocities range from 30 to 60 cm/sec' (read on the rendered pages; the scan's OCR cannot be quoted for p. 6, so the "
  "original has no row of its own)."))
a = row(1053)["note"]; assert "fry (<2 inches)" in a; note(1053, a.replace("fry (<2 inches)", "fry (≤ 2 inches)"))
a = row(960)["note"]; assert "So the velocities are not a rainbow trout measurement" in a
note(960, a.replace("So the velocities are not a rainbow trout measurement", "So the velocities are Griffith's cutthroat values, not a rainbow trout measurement"))
out = io.StringIO(); w = csv.writer(out, lineterminator="\n"); w.writerow(H)
for r in data: w.writerow([r[h] for h in H])
open(P, "w", newline="", encoding="utf-8").write(out.getvalue())
print("applied")
