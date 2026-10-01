# Habitat literature: what the sources say about CH and BT thresholds

**Verified:** 2026-09-30 · **Issues:** #19 (this); input to NewGraphEnvironment/link#284 · **Produced by:**
`data/literature_evidence.csv`, gated by `scripts/0280-literature-verify.R`
(log `scripts/logs/habitat/*_literature_verify.csv`); sources in the group library's `Fisheries/habitat_modelling`
collection (`scripts/0270`) and the `habitat_modelling` store.

The intrinsic-potential models behind several of these sources (Rebellato, Cooney & Holzer, Busch, Agrawal, Woll),
and how each sized streams, are in `ip_models.md` (#29). Their threshold rows here carry a `model_id`.

The table is the record; this file keeps the conclusions someone would otherwise re-derive from it. Every
statement below has a gated row (a verbatim quote found in the cited PDF) or a `none` row saying what was
searched.

## What these thresholds are

The channel-width and gradient thresholds in bcfishpass's `example_newgraph` parameters are ours.
They are the ones the province uses, and they are set on the inclusive side on purpose: they exist
to describe opportunities and navigate to sites for review across many watersheds, not to draw the
edge of habitat. This work tunes them against literature, observations, logic and statistics, and
that tuning is ongoing. A value with no literature source is not wrong for that reason; it has to
be judged by how well it screens.

## Where the modelled values come from

Most CH values in bcfishpass and link trace to one document, Rebellato et al. 2024 (Canadian Wildlife Federation),
Table 1 (p. 6). Tracing each value back through it:

| Parameter (CH) | Model value | What the sources support |
|---|---|---|
| `spawn_gradient_max` | 0.0449 | Rebellato gives 0–3 %, citing Busch 2013 and Cooney & Holzer 2006. Neither says 3 %: Busch scores 4–7 % at 0.05 and 0 above 7 %, and Cooney & Holzer exclude > 5 % (C-8) and rate > 7 % None (Table C-1). Montgomery 1999 puts the Chinook zone at < 1 %. |
| `spawn_channel_width_min` | 4 m | Uncited in Rebellato. There, modelled channel width (Thorley et al. 2021, our model) is "a surrogate for discharge" wherever modelled MAD was unavailable, i.e. outside the Fraser and the Bulkley: a screening device, not a habitat limit. The field measurements that bound it are Woll 2017 Table 16, "Channel size < 4m" = Not Suitable, and Cooney & Holzer, BF < 3.7 m = None. |
| `spawn_mad_min` | 0.46 m³/s | **No source.** Rebellato cites five works; none of them gives a discharge threshold. Bjornn & Reiser and Neuman & Newcombe were read through OCR. |
| `rear_gradient_max` | 0.0549 | Rebellato gives 0–5 %, citing Woll 2017 and Porter 2008. **Neither states 5 %.** Woll 2015 (Mat-Su) rates juvenile CH "No potential" above 5 %. Beamer 2013 found no non-natal juveniles above 6.5 %. |
| `rear_mad_min` | 0.28 m³/s | Agrawal et al. 2005, through Sheer et al. 2009 p. 13. |
| `rear_channel_width_min` | 1.5 m | **No source.** Uncited in Rebellato; like the spawning width, it is a discharge surrogate there. |
| `cluster_bridge_*` | 10 km, 5 % | Rebellato p. 7, rearing criterion 4, for CH, coho and steelhead: a design rule with no literature behind it. **Nothing for BT.** |
| `rear_lake_ha_min`, `rear_wetland_ha_min` | — | No source for CH or BT. Rebellato's ≥ 200 ha lake rule is for sockeye; its wetland rule is for coho. |

BT has no cited source anywhere in bcfishpass. Its access value, 25 %, is the provincial default (Norris &
Mount 2016 p. 6), which Porter et al. 2014 say rests on bull trout swimming ability.

## Bull trout: what the literature does and does not give

- **Spawning gradient.** No review gives a numeric reach-scale maximum; they say "relatively low gradients"
  (McPhail & Baxter 1996). Reach-scale BC data does exist:
  - O'Brien 1999 (Duncan system, adfluvial): 1.3, 1.9 and 4 % section averages at reaches with redds;
  - Bustard & Schell 2002 (Morice): all spawning sites in reaches of 1–4 % and wider than 7 m;
  - Cope & Morris 2001 (Wigwam): 0.6–1.0 %.

  Gill 2006's "~1.0–1.5 %" is attributed to McPhail & Baxter, whose text gives no number.
- **Rearing gradient.** Morice rearing sites span 1–14.5 % (mean 3.2 %, n = 33; Bustard & Schell). Isaak 2015
  trimmed natal habitat at 15 %, with < 1 % of occurrences above it. Porter 2008 found BT CPUE highest in steeper
  streams.
- **Width.** "< 2 m wetted" is the lower limit in two independent lines: Hagen et al. 2015 p. 23 (expert, migratory
  spawners) and Dunham & Chandler 2001 (juvenile occurrence).
- **Stream order.** Sources disagree by life history. Williston adfluvial spawning is in 5th- to 6th-order
  streams (Hagen & Weber 2019); the BC management plan says 3rd order and smaller.

## Corrections to earlier readings

- Roberge et al. 2002 print a CH juvenile bankfull width of 0.5 m. It is a transcription error: Porter et al. 2000
  Table 2 gives 20.2 m.
- Page corrections to link#284's review:
  - Cooney & Holzer's > 5 % exclusion is on C-8, not C-7;
  - Hagen 2015's 2 m sentence is on p. 23, not 22;
  - Hagen 2020's footnote 9 is on p. 31, not 30;
  - Trotter 2000's last-fish values are on p. 10, not 9.

## Timing

None of the six unsourced CH/BT windows in `data/life_history_timing.csv` (BULK and MORR incubation; BULK BT
migration and spawning) is stated exactly by any source in the store. The pieces that are stated, mostly start
dates, are timing rows in the evidence table. The BULK coho migration row's key was a truncation of
`officeofthewetsuweten2013WetsuwetenTitle`, which p. 24 supports ("early to mid-August").

## How a quote is verified

Quote and page are compared as exact token sequences: a number as written, a word, or any other single
character. Normalization is typography only (quote marks, dashes, invisible characters, ligatures, case). Details:
- A quote may not stop inside a number or a range.
- Table rows are matched as adjacent tokens on the `-layout` text.
- A scan with no text layer is OCR'd with `ocrmypdf`, and there is no fuzzy match.
- Every value must be stated by its own quote, with only the unit rescalings a unit can carry.

An earlier string-normalizing version passed 21 fabricated rows across two review rounds. See the #19 archive for
the enumeration that closed it.
