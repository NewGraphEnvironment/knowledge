# Meaning audit, round 3 (#44): every row commit c176f09 changed

Scope: the rows `git diff c176f09^ c176f09 -- data/literature_evidence.csv` changes. The hunks touch file lines
736-745, 761, 792-803, 808-809, 823-824, 826, 838, 850-851, 877, 887, 890, 929, 984, 986, 988, 990-991, 1001 and
1012-1014. That is data rows 735-744, 760, 791-802, 807, 808, 822, 823, 825, 837, 849, 850, 876, 886, 889, 928, 983,
985, 987, 989, 990, 1000 and 1011-1013: 44 rows. The brief's list repeats 742, which is already inside 735-744. Each
row's line number was checked with `awk 'NR==N+1'`.

For each row, the changed field or note was read against the source page in the scratchpad text (`.txt`,
`.layout.txt`, `.ocr.txt`). Page numbers were found from the `\f` breaks and the printed footers. Every "data row N"
and "qual row" reference in the 44 rows was resolved.

## Raleigh et al. 1986, Figures 8-13 (735-744): `region` (and 742's `note`)

Source: pp. 53-54, "Following are brief descriptions of the background for each curve", plus the figure captions on
pp. 38-43 (layout lines 2493-2782).

- **735 holds.** p. 53: spring chinook redds (n = 252) "from the Little North Santiam River ..., and the Molalla
  River ...; and in 1962 from the South Fork McKenzie River". Figure 8's caption: "spring chinook ... (n=252; from
  Sams and Pearson 1963)". Oregon: "several small streams in Oregon".
- **736 holds.** p. 53: "Data for fall chinook redds (n = 107) were collected during 1962 from Humbug Creek ..., East
  Humbug Creek ..., Tillamook River ..., and Moon Creek". The text dates the study 1963 and the caption dates it 1973,
  and the row's note already says so.
- **737, 738 hold.** p. 53: "Vogel (1982) collected data in Battle Creek, California". Figure 10, n = 216.
- **739, 740 hold.** p. 53: "in the upper Yakima and American rivers in south-central Washington". Figure 11, n = 118.
- **741 holds.** p. 54: "Portage Creek (n = 137) and the Indian River (n = 125), tributaries of the Susitna River in
  Alaska". The row's existing n = 265 is the caption's figure; the text says n = 262. That was not changed by
  c176f09.
- **742 holds.**
  - The `region` matches p. 54, as for 741.
  - The note matches:
    - the caption reads "depth (category one) (n=265; from Vincent-Lang et al. 1984)";
    - p. 54 reads "The depth curve was modified based on the assumption that depths from 48.8 to 122.0 cm (1.6 to
      4.0 ft) will not limit spawning activities";
    - the layout's coordinates are cm 0.0/15.2/30.5/121.9/3048.0 with SI 0.0/0.0/1.0/1.0/1.0, so SI is 0 at and
      below 15.2 cm and 1.0 from 30.5 cm.
  - "data row 731" resolves to the Figure 5 category-one depth row. Figure 5's coordinates (p. 34, layout ~2140) are
    0.0/15.2/30.5/3048.0 with SI 0/0/1/1, the same function.
  - Cosmetic, optional: Figure 12 lists one extra coordinate (121.9 cm, SI 1.0) that Figure 5 does not, so "the same
    curve" is more exact than "numerically identical". It is not an error, because the two functions are identical.
- **743, 744 hold.** p. 54: "Kurko (1977) collected data (n = 436) from the upper Skagit River in north-central
  Washington". Figure 13.

## Raleigh et al. 1986 p. 5 (760): `bound` min to optimum, note prefix

**Holds.**
- Page 5 (the paragraph ends just before the "5" footer): "An annual base flow ~50% of the average annual daily flow
  is considered excellent for salmonid production, a base flow of 25% to 50% is considered fair to good, and a base
  flow of <25% is considered poor (adapted from Tennant 1976; Binns and Eiserman 1979; Wesche 1980)".
- That is three classes, and excellent is the best, so "Excellent class (best of three)" is accurate.
- The coding now matches Ford p. 53's identical scheme (961, 963: `optimum` 55, `value_max` blank).
- The sibling row 761 (`min` 25) is unchanged and matches 962 and 964.

## Tennant 1976 (791-802): "item 4" to "item 1"

**All 12 hold.**
- The PDF page that follows the page carrying the "July - August 1976 9" footer is printed p. 10. Under
  "Recommendations" it reads: "1. Request "instantaneous flows" to prevent flow releases from dams and diversion
  structures that are averaged over a day, month, or year".
- The notes' "not averages over a day, month or year (p. 10, Recommendations, item 1)" is the page's wording.
- `metric = instantaneous` stands.

## Ptolemy & Lewis 2002 p. 30 (807, 808) and Hatfield et al. 2002 p. 41 (822, 823): `bound` min to blank, note sentence

**All four hold.**
- Ptolemy & Lewis: the paragraph comes after the "29" footer, so it is p. 30. It reads "The stream-size-dependent 30%
  MAD to 200% MAD conservation flow covers both migration and spawning", "The flows prescribed by this standard range
  from 30 or 200% but vary dependent on stream size (Figure 15)", and gives the equation
  `%MADspawning= 148*{MAD)-036`.
  - From the equation, 200 % falls at MAD ≈ 0.4 m3/s and 30 % at MAD ≈ 84 m3/s.
  - So "A program reading a bound would take 30 % MAD, which is the minimum only for the largest streams" is
    accurate.
  - 807's duplicated "(equation in the qual row)" is gone, with one instance left.
  - "Its 'applies to large trout and Pacific salmon'" is p. 30's "The B.C. spawning flow standard applies to large
    trout and Pacific salmon".
- Hatfield Table 5 (p. 41) reads "D. Migration and Spawning 30-200% Days-weeks", with "Spawning equation: 1.56 *
  MAD 0.63".
- The "qual row" references resolve: 809 for Ptolemy & Lewis, and 824 for Hatfield, which carries 1.56 × MAD^0.63.
  In % MAD that is about 156 × MAD^-0.37, which also gives about 200 % at small MAD and 30 % at about 86 m3/s.
- A blank `bound` on a valued row is accepted by `knw_literature_read()`, which checks only `min`, `max` and `range`
  (literature.R lines 314-320). These are group-code rows and fill no grid cell.
- Advisory, outside c176f09's change, so not counted as an error:
  - Hatfield's table attaches the equation to the "Spawning" sub-line only. 822 (migration) reads it as also setting
    the migration flow.
  - That reading is supported by Ptolemy & Lewis p. 30 ("covers both migration and spawning"), which the note names.
  - It is also supported by Hatfield's own Ash River chart (PDF p. 92). There, "Adult passage (general)" is "45%mad
    or 12.5 cms", the value the equation gives for MAD 27.8 m3/s: 148 × 27.8^-0.36 = 44.7 %, and 1.56 × 27.8^0.63
    = 12.7 m3/s.

## Hatfield et al. 2002 (825, 837): note sentence added

**Both hold.**
- The sentence added to both notes is "The source does not say what sets the flow within the 50-100 % span".
  Table 5 (p. 41) gives "Summer Steelhead passage 50-100% Days". The Ash River pages (PDF p. 92) give "Summer Adult
  passage ... 50-100 for several days" and "Summer Steelhead passage ... 50-100%mad or up to 27.8 cms for Days".
  None of these says what selects a value within the span.
- The verdict on the coding is below.

## USFWS 2007, Clear Creek spring-run chinook spawning depth (849, 850): notes

**Both hold.**
- p. 24 (PDF p. 27, before the "24" footer) reads "The spring-run salmon HSC data had depths ranging from 0.8 to 7.0
  feet deep". The HSC data are redd measurements: p. 23 says "Data relative to depth, velocity, and substrate size
  were collected for a total of 180 spring-run Chinook salmon redds", with depths measured on 177. So "the HSC redd
  depths span the same 0.8-7.0 ft (p. 24)" and "HSC redd depths reach 7.0 ft (p. 24)" are accurate.
- p. 26 (before the "26" footer) reads "Since the deepest spring-run redd in our study sites had a depth of 3.0 feet,
  we were unable to apply the Gard (1998) depth correction method". The study sites are the six RIVER2D sites (p. 24:
  "a total of 7 redds for the six study sites"). So "the deepest spring-run redd in the six study sites was 3.0 ft
  (p. 26)" is the page's claim.
- p. 36 (before the "36" footer) reads "The spring-run Chinook salmon spawning depth logistic regression had its
  first maximum at 2.1 feet (Figure 5)". 850 is accurate.
- Figure 5 is on p. 28: "non-zero suitability for depths of 0.8 to 7.0 feet and an optimum suitability at depths of
  6.0 to 6.2 feet".
- Not an error: p. 36 also counts 15 redds in the six study sites over 2003-2005, six of them deeper than 2.1 ft.
  That fits a 3.0 ft deepest redd, and neither note claims otherwise.

## Hagen & Weber 2019 p. 22 (876) and Roberge et al. 2002 p. 80 (886): data-row references

**Both hold.**
- 876: "The velocities in the same sentence are data rows 497 and 498." Data row 497 is the BT spawning velocity
  `range` 14-52 cm/s, and 498 is `max` 65 cm/s. Both are hagen_weber2019 p. 22 with the same quote.
- 886: "is data row 497 (hagen_weber2019, 14-52 cm/s) from the same review". Roberge p. 80 has "in slow moving water
  (0.14 - 0.52 m/s) ... (from Baxter and McPhail 1996)". Hagen & Weber p. 22 has "velocities average 14-52 cm/s ...
  (reviewed in Baxter and McPhail 1996)". Both pass the same review on, and the values are equal.
- Round 2 was wrong that these rows did not exist, as the caller noted. The c176f09 fix took the "rewrite the notes"
  path rather than appending duplicates, which is right.

## Ford et al. 1995 Table 8 (889): note

**Holds.**
- Table 8 (OCR, before the "117" footer) reads "Preferred spawning depth 0.15 to 0.84 m".
- Table 10 follows the "124" footer, so it is p. 125. Its column is "Mean water depth over redd (m)", with
  "Flathead R., Montana 0.28 (0.15-0.35)" and "Meadow Creek 0.73-0.84 (Kootenay Lake, British Columbia)".
- The note's description of the two ends, and "Ford does not say Table 8 was compiled from Table 10", are accurate.

## Ford et al. 1995 p. 72 (928): note

**Holds.**
- p. 72 (after the "71" footer): "Fry over 30 mm were found in water velocities less than 1 cm/s". The paragraph's
  study is "Moore and Gregory (1988b) studied habitat preferences in tributary streams of the Cascade Mountains". No
  subspecies is named.
- p. 71: "After emergence westslope cutthroat trout have been observed to immediately take up positions in stream
  margin habitat ... (Moore and Gregory 1988b)" and "Moore and Gregory (1988b) also found that interior cutthroat
  fry less than 30 mm long".
- The reference list has "Summer habitat utilization and ecology of cutthroat trout fry (Salmo clark[i]) in Cascade
  Mountain streams".
- The WCT 2004 account (PDF p. 6) reads "fry often use habitat where water velocities are very low (<1 cm/s) ...
  (Ford et al. 1995)".
- `CT` stands.

## AMEC 2015 Table 14 (983, 985, 987: metric to `unstated`; 989, 990: p. 83 wording)

**All five hold.**
- p. 30 (between the "Page 29" and "Page 30" footers) reads "The IFN were set as the minimum monthly flows required to
  protect fish ... during each biologically relevant stanza". It names no monthly statistic, so `unstated` and the
  added sentence are right.
- 989 and 990:
  - p. 56 (before "Page 56") reads "Overwintering IFN were conservatively defined as baseline March flows, the lowest
    mean monthly flows for the winter stanza".
  - p. 83 (before "Page 83") reads "Winter IFN were conservatively defined as baseline mean March flows, the lowest
    flow month in the historical flow time-series", so the quoted 'baseline mean March flows' is p. 83's.
  - The note's "though p. 30 calls them the winter-stanza mean annual 30-day low flow" matches p. 30: "winter IFN in
    Davidson Creek were defined as the mean annual winter stanza 30-day low flow (Table 11)".
- The Table 14 values match (layout ~4093-4106): Middle 16 May-30 June IFN 0.545, Lower 0.735, Middle 1 July-31
  August 0.130, and Middle and Lower winter 0.115 and 0.175.

## GR migration `none` row (1000)

**Holds.** The only change was a removed trailing space.

## USFWS 2007 RB twins (1011-1013): "the curve" to "the WUA"

**All three hold.**
- p. 36: "The flow-habitat relationships for steelhead/rainbow trout are shown in Figures 17 and 18. In the Upper
  Alluvial Segment, the 2-D model predicts the highest total WUA at 350 cfs. In the Canyon Segment, the total WUA
  highest peak is at 600 cfs."
- p. 59: the January-June 200 cfs recommendation "may be close to achieving maximum habitat availability ...
  (greater than 91% of maximum WUA)".
- The twins resolve: data rows 859, 860 and 861 are ST `optimum` 350, 600 and 200 cfs on the same pages.

## Verdict on 825 and 837 (summer steelhead passage, 50-100 % MAD, `range`)

**They are a genuine span, not the stream-size-dependent standard, so they should not be recoded to match 807, 808,
822 and 823. Keep `range`.**

- The decisive page is Ptolemy's own application to one stream: Hatfield 2002 Appendix A, Ash River below Moran
  Creek, PDF p. 92, natural MAD 27.8 m3/s.
  - On that single stream, the stream-size-dependent standard collapses to one number. Spawning is "45 for weeks" or
    "45%mad or 12.5 cms for Days-Weeks", and "Adult passage (general)" is "45%mad or 12.5 cms for Days". This is what
    148 × 27.8^-0.36 = 44.7 % and 1.56 × 27.8^0.63 = 12.7 m3/s give.
  - On the same stream, summer steelhead passage stays a span: "50-100 for several days" and "50-100%mad or up to
    27.8 cms for Days".
  - A span that survives application to one stream of known MAD is not set by stream size.
- Table 5 (p. 41) supports this. The line "Summer Steelhead passage 50-100%" sits apart from the "30-200%" line and
  the spawning equation, and no source in the collection ties it to MAD (grep of all source texts for "summer
  steelhead" and "50-100").
- Under `range` the 50 % end is a real lower limit: Ptolemy never asks for less, on any stream, whereas 30 % in the
  30-200 standard is the minimum only for the largest streams. The 100 % end is "up to", the most the standard asks,
  not a ceiling on harm. That makes `range`, two limits, a slightly strong reading of the top end, but no other bound
  fits better. A blank bound would discard a lower limit that does hold.
- Optional note addition (advisory, not an error), on both 825 and 837: "Ptolemy's Ash River chart (PDF p. 92; MAD
  27.8 m3/s) keeps the whole span ('50-100%mad or up to 27.8 cms') while giving spawning and general adult passage
  single values (45 %), so the span is not set by stream size; 'up to' makes 100 % the most asked, not a ceiling."

## Mechanism check

Round 2's fixes were checked against the pages themselves, not against round 2's wording:
- p. 26's "our study sites";
- p. 83's "baseline mean March flows";
- Tennant's item 1;
- Table 10's column header;
- Ford p. 71's two subspecies sentences.

The two places where round 2 was wrong (Hagen & Weber rows "not existing", and the advisory reading of "up to") were
not carried into the CSV. c176f09 rewrote the notes to point at 497 and 498, and left 825 and 837 at `range` with a
neutral sentence.

checked 44 rows, 0 with errors, 0 inside round-2 fixes
