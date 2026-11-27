# Coho in the upper Fraser: how far up the records reach, and what each rests on

**Verified:** 2026-11-27 · **Issues:** #284 (this; the `coho` store it built); relates #228 (salmon records per stream)
and #285 (NuSEDS beside the Pacific Salmon Foundation's corrections, whose Fraser coho flags are not read here yet) ·
**Produced by:** `data-raw/coho_upper_fraser_records.R` (log `scripts/logs/coho/20261127_upper_fraser_records.*`, 30
records), each record's source read in the `coho` store's documents; every quote checked by
`scripts/0280-literature-verify.R`, which lists this file in `QUOTED` · **Status:** complete for the 30 records; gaps
at the end.

Pages are the printed ones, except the Westworth inventory's, which has no printed numbers: its page is the PDF's.

## In brief

- **Coho are confirmed by survey through the Nechako system and no further up the Fraser.** Fish were caught or
  counted in the Nechako mainstem, Dahl Creek on the Chilako, the Francois Lake group, Ahbau Creek, the West Road
  (Blackwater) and the Nazko. Every one of these lies at or below the Nechako confluence.
- **Above the Nechako confluence there are two records, and neither rests on a survey.** The Bowron River's is a 2004
  entry carried from a draft recovery strategy, and DFO itself calls coho there unconfirmed. Willow River's (Slade
  Creek, 1995) comes from a community advisor's quarterly report.
- **So link's `default` coho range takes in two groups on compilations alone.** BOWR and WILL are in it, while
  FRAN, with fry caught on a 2018 survey, is out of it, as are STUL and STUR, where DFO names coho seen in the Stuart
  system.

## How the records were judged

The records are every coho record in the Fraser drainage upstream of the Quesnel River's mouth: the Province's
fish observations as bcfishobs places them, the published FDIS electrofishing evidence, and DFO's NuSEDS escapement
records. Each is given one of four verdicts from its own source:

- **survey**: a field survey caught, measured or counted the fish, and its report or record says so. Where the report
  is not held, the verdict adds that the report is not held.
- **compilation**: the record is carried from a summary, a map, a stream file or a personal communication, with no
  survey behind it in the source.
- **doubtful**: its source, place or date conflicts with other sources, or it has none.
- **no observation**: the record holds no sighting at all.

Of the 30 records, 15 are surveys, 12 compilations, 2 doubtful and 1 holds no observation.

## What DFO says about the upper limit

The documents agree that coho reach the Nechako and that anything above it is unconfirmed. Irvine et al. (2001) list
where coho are confirmed outside the Thompson: "Coho are confirmed in the Seton, Bridge, Chilcotin, Westroad, and
Nechako rivers, and are suspected of being in the several other non-Thompson systems." (irvine_etal20012001Stock,
p. 12). Decker and Irvine (2013) put the limit in the same place and name the Bowron as unconfirmed: "Within the
Middle/Upper Fraser CU, Coho Salmon occur at least as far upstream as the Nechako River system, have been recorded in
a number of other major Fraser tributaries downstream of the Nechako (e.g., Quesnel, Chilcotin, West Road
(Blackwater); Figure 1), and may also occur in tributaries upstream of the Nechako (e.g., Bowron River), but their
presence has not been confirmed." (decker_irvine2013PreCOSEWICAssessment, p. 21).

The recovery potential assessment repeats it: "Coho Salmon are known to occur as far upstream as the Nechako River
in the Upper Middle Fraser subpopulation area, but there are several major Upper Middle Fraser watersheds where Coho
Salmon presence is probable but has not been confirmed." (arbeider_etal2020InteriorFraser, p. 25). Its map caption
adds two Stuart system streams that no record here holds: "Coho Salmon have been observed in some of these systems,
such as Westroad River and tributaries, Nechako River, Kuzkwa River, Kazchek Creek, and Bowron River (unconfirmed)"
(arbeider_etal2020InteriorFraser, p. 28). Kuzkwa River lies in LTRE and Kazchek Creek in MIDR.

## The records, by place

Record ids are the log's (`obs:` the Province's observation key, `fdis:` the visit, `nuseds:` the population).
Places run from the Quesnel's mouth upstream.

| record | group | place | date | source | verdict |
|---|---|---|---|---|---|
| `obs:c1262aeb8a` | COTR | Fraser River | 1996-06 | Upper Fraser River EEM cycle one interpretive report | survey, report not held |
| `obs:83623c516c` | COTR | Swift River | 1986 | Quesnel River Hatchery manager, personal communication | compilation |
| `nuseds:2487` | | Swift River | 2000 | NuSEDS: not inspected | no observation |
| `obs:94e4f8d30d` | COTR | Ahbau Creek | 2014-09-16 | FDIS, Ahbau Creek Compensation 2014 (Triton) | survey |
| `fdis:172649_1_1` | COTR | Ahbau Creek | 2014-09-16 | FDIS extract: one coho, measured | survey (the same event) |
| `nuseds:287` | | Ahbau Creek | 2001 | NuSEDS: 6 spawners, a peak live count expanded | survey |
| `obs:2a6ba27160` | BLAR | Baezaeko River | 1989 | DFO fishery officer, stream files and personal communication | compilation |
| `obs:354c34e58c` | BLAR | West Road River | 1994 | a reference titled only Untitled | compilation |
| `obs:d8994c8816` | BLAR | West Road River | 1994 | a reference titled only Untitled | compilation |
| `obs:75f445dfc9` | BLAR | West Road River | 1995 | SISS map, source not indicated | compilation |
| `obs:93f8af4399` | BLAR | West Road River | 2004 | 2001 stock status assessment; 2004 draft recovery strategy | compilation |
| `nuseds:45985` | | West Road River | 1996–2001 | NuSEDS: 100 spawners in 1996, present in 1999, none seen in 2001 | survey |
| `nuseds:44756` | | Nazko River | 1999–2001 | NuSEDS: present in 1999, 6 spawners in 2001 | survey |
| `obs:2739278381` | COTR | Naver Creek | 1994 | DFO fishery officer, 1989; a reference titled only Untitled, 1994 | compilation |
| `obs:c3caf22396` | LCHL | Nechako River | 1984 (recorded 1986) | reconnaissance sampling for juvenile salmonids in the upper Fraser, 1984; DFO fisheries officer, personal communication, 1986 | survey, report not held |
| `obs:f1f6bf3008` | LCHL | Nechako River | 2004 | 2001 stock status assessment; 2004 draft recovery strategy | compilation |
| `obs:2cd410cabc` | LCHL | Dahl Creek | 1996 | Westworth, Brusnyk & Associates' Chilako–Nechako inventory | survey |
| `obs:75afbf2f4b` | LCHL | Dahl Creek | 1996 | the same inventory | survey (the same survey) |
| `obs:ce739e353a` | CHES | unnamed stream | 1994 | draft report on hydrology and water use for salmon streams in the upper Fraser | compilation |
| `obs:bb1787d1bf` | NECR | Greer Creek | 1978-08-25 | RAB database survey, no reference | survey, report not named |
| `obs:8bdec2064b` | NECR | Greer Creek | 1986 | DFO fisheries officer, personal communication | compilation |
| `obs:50524cd88f` | NECR | Micks Creek | none | RAB database, no reference and no date | doubtful |
| `obs:02652e805d` | NECR | Nechako River | 2010-07-15 | FDIS, Nechako Fry Emergence Project 2010 (Triton) | survey |
| `nuseds:1812` | | Nechako River | 2004 | NuSEDS: present, method unknown | survey |
| `obs:026afad5a5` | FRAN | unnamed stream | 2018-07-26 | FDIS, 200 FSR Culvert Replacement Inventory 2018 (Marlim): coho fry | survey |
| `obs:785aff6b11` | FRAN | unnamed stream | 2018-07-26 | the same site and date under a second collection id | survey (the same event) |
| `obs:d578bf599c` | STUR | Stuart River | 2004 | 2004 draft recovery strategy | compilation |
| `obs:7a98d34717` | STUL | Ocock Lake | 1976-06-16 | a reconnaissance survey of Ocock Lake (lakes database) | survey, report not held |
| `obs:ad92d4930e` | WILL | Slade Creek | 1995 | Community Advisors' quarterly reports, 1995 | compilation |
| `obs:59bce25800` | BOWR | Bowron River | 2004 | 2004 draft recovery strategy | doubtful |

Notes on single records:

- **The 2004 entries** (`obs:93f8af4399`, `obs:59bce25800`, `obs:f1f6bf3008`, `obs:d578bf599c`) cite the
  consultative draft of the national recovery strategy for Interior Fraser coho, which is not public. Two also cite
  Irvine et al.'s 2001 stock status assessment. Each is dated 1 January 2004, the draft's year, not a survey date.
  The West Road and Nechako entries agree with surveys; the Stuart entry stands alone. The Bowron entry is doubtful,
  because DFO's own later assessments (2013 and 2020, quoted above) still call coho there unconfirmed.
- **Dahl Creek.** The inventory caught coho in the creek's lowest reach: "Also numerous coho salmon ranging in size
  from 67 to 85 mm were sampled." (westworthassociatesenvironmentalltd_20011996Reconnaissance, p. 40). The Province
  dates both records December 1998, the report's date; the sampling was in 1996.
- **The 2018 FRAN fry** are one site and date under two FDIS collection ids. Neither is in the published FDIS
  evidence, because the extract it was built from holds electrofishing only; the observation records no method.
- **Ocock Lake** is a lake record, which bcfishobs places 1.26 km from a mapped stream.
- **Willow River.** The Slade Creek record lands on Tregillus Creek, the stream Slade Creek flows into.

## What this means for link's coho range

link's `default` coho range takes in BOWR and WILL and leaves out STUR, STUL and FRAN (#284's measurement of
2026-11-26). Against the records:

- **BOWR** rests on one doubtful 2004 entry. Nothing here confirms coho in the Bowron.
- **WILL** rests on one compilation, the 1995 community advisor's report.
- **FRAN** holds the most recent survey in the upper Nechako, fry caught in 2018, and is outside the range.
- **STUL and STUR** hold a 1976 lake survey whose report is not held and a 2004 compilation. DFO's 2020 map names coho
  seen in two other Stuart system streams (Kuzkwa River, Kazchek Creek), with no record behind them here.

The records say the range's upper edge on the Fraser itself is not supported, and its edge within the Nechako system
is drawn tighter than the surveys reach. Whether link's range should change is not decided here.

## Gaps

- The reports behind six survey records are not held: the 1984 reconnaissance sampling (a paper copy at the UNBC
  archive), the 1996 Upper Fraser EEM report, the Ocock Lake survey, the RAB Greer Creek survey, Triton's 2014 Ahbau
  report and Marlim's 2018 culvert inventory. Triton's 2010 fry emergence report is on the Nechako Fisheries
  Conservation Program's site but was not retrieved.
- The 2004 draft recovery strategy is not public.
- The Pacific Salmon Foundation's corrections to NuSEDS (#285) carry flags on Fraser coho populations; they are not
  read here yet.
- No record was sought for Kuzkwa River or Kazchek Creek beyond the three sets above.
