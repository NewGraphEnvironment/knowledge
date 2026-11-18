# Access gradients: where link's classes come from, and what the sources say fish pass

**Verified:** 2026-11-18 · **Issues:** #234 (this), the first piece of the access track (#132); split from backlog move 9
(#178) · **Produced by:** `data/literature_evidence.csv` data rows 1154-1189, gated by
`scripts/0280-literature-verify.R` (log `scripts/logs/habitat/20261118_literature_verify.csv`) and audited for meaning
in rounds until one found no error inside an earlier round's fix (`planning/archive/` for #178); sources in the group library's `Fisheries/Fish Passage/passage_limits`
collection (`data/passage_limits_{members,additions}.csv`, `scripts/0270`) and the `fish_passage` store; the classes'
history read from bcfishpass's docs and SQL and from fresh's and link's `parameters_fresh.csv` histories ·
**Status:** the literature half of #132; the records above modelled gradient barriers are the track's next piece.

## What link does, and what this asks

link blocks a species above the first stretch of stream steeper than its access gradient, read over 100 m, unless
link's overrides lift it (fish records or confirmed habitat above it, by rules that differ by species: records of
any salmon count for each salmon, and none lift a barrier for cutthroat or Dolly Varden): 15 % for
chinook, chum, coho, pink, sockeye, grayling and kokanee, 20 % for steelhead and westslope cutthroat, 25 % for bull
trout, rainbow, cutthroat and Dolly Varden (link's `inst/extdata/configs/default/parameters_fresh.csv`). Those cuts
decide which water can hold habitat at all, and where link breaks streams. This file asks where each number came from,
and whether what fish are measured or seen to pass supports it.

**In short:** none of the classes is a measured passage limit. 25 % comes from BC's first fish-passage model. bcfishpass
has used 15 % for salmon and 20 % for steelhead and westslope cutthroat since 2020, with no source named; Washington's
barrier manual gives steelhead the same 20 %. 15 % is the one with evidence behind it, though the evidence came after:
Rebellato et al. 2024, a Canadian Wildlife Federation report, found that 94 to 98 % of BC records of pink, chum, chinook
and coho have a maximum downstream gradient of 15 % or less. Westslope cutthroat's 20 % and
grayling's and kokanee's 15 % have no source at all. Where the sources give species limits, chum (5 %) sits well below,
and pink (12 %) below, the 15 % BC applies to them; bull trout and cutthroat are recorded above their 25 % class, and
cutthroat, bull trout, Dolly Varden and sometimes rainbow above 20 %.

## Where each class comes from

- **25 %, bull trout, rainbow, cutthroat, Dolly Varden.** BC's Fish Passage GIS Version 1 used 25 % for every species
  (data row 1157). Its authors took 20 % for anadromous species from the 1998 guidebook, whose 20 % is for all fish, and
  25-30 % for bull trout and Dolly Varden/cutthroat from Cannings and Ptolemy 1998. That book says only that bull trout
  reach 30 %, on a personal communication (data row 1156). bcfishpass uses 25 % for bull trout (from 2022; its first
  gradient classes, in 2020, were 15, 20 and 30 %, "from FPTWG") and, in its SQL, for rainbow, cutthroat and Dolly Varden; Norris and Mount 2016 call it Version 1's cut-off and say the model has not been
  field verified.
- **20 %, steelhead and westslope cutthroat.** bcfishpass has used 20 % for steelhead and westslope cutthroat since its
  first access model (2020); Rebellato et al. 2024 later document steelhead's from Sheer and Steel 2006 and WDFW 2009 (data row
  359), and Sheer and Steel cite Washington's 2000 manual (data row 63). Washington's 2009 manual defines a natural barrier for most adult salmonids as
  more than 20 % sustained for 160 m (data row 1154), and its 2019 edition gives steelhead the same 20 % (data row 1168).
  BC's 1998 Fish-stream Identification Guidebook uses 20 % for all fish, designating reaches under it as fish streams
  by default, measured over 100 m, and cites no study (data row 1158). Westslope cutthroat's 20 % is uncited, and no
  source gives it a limit (data row 1188).
- **15 %, the five salmon, grayling and kokanee.** bcfishpass has used 15 % for salmon since its first access model
  (December 2020); its first README (November 2020) lists gradient barriers at 15, 20 and 30 % "from FPTWG" among its
  inputs, with no species, and no document read says who first gave salmon 15 %. Rebellato et al. 2024, which
  bcfishpass cites for its salmon habitat thresholds, found no literature limit for pink or chum and sets 15 % from BC
  records: 96 % of pink and 97 % of chum observations lie at or below a maximum downstream gradient of 15 %, and
  chinook (98 %) and coho (94 %) confirm it, beside Washington's 16 % for chinook, coho and sockeye (data rows 6-8,
  355-358). Yet the Washington manual it cites does give pink and chum limits, in its Table 9.2 (p. 9-7), as the 2019 edition's
  tables do: chinook, coho and sockeye
  pass to 16 %, pink to 12 % and chum to 5 % (data rows 1167, 1169-1172). Grayling and kokanee entered link's
  configuration on the salmon class in 2026; no source gives either a gradient limit (data rows 1186, 1187).

## What the sources give, by species

| species | link's class | what the sources give | data rows |
|---|---:|---|---|
| chinook, coho, sockeye | 15 % | pass to 16 % (WDFW 2019) | 1167, 1170, 1171 |
| pink | 15 % | pass to 12 % (WDFW 2019) | 1172 |
| chum | 15 % | pass to 5 % (WDFW 2019) | 1169 |
| steelhead | 20 % | pass to 20 % (WDFW 2019) | 1168 |
| bull trout | 25 % | found to 30 % (Cannings and Ptolemy, pers. comm.); 20 % used and passing to 33 % recognised (WDFW 2019 p. 10-7), where its Chapter 7 says bull trout are "often found above 30%" (p. 7-4); well above 20 % in stepped-pool reaches (BC 1998) | 1156, 1160, 1163 |
| Dolly Varden | 25 % | 20 % used, passing to 33 % recognised (WDFW 2019; its Chapter 7 does not name Dolly Varden); well above 20 % (BC 1998) | 1161, 1164 |
| rainbow, cutthroat | 25 % | resident cutthroat/rainbow: 20 % used, passing to 33 % recognised, the 33 % being cutthroat's (WDFW 2009 and 2019, after Jauquet 2002); sea-run cutthroat pass to 20 % (WDFW 2019); well above 20 % (BC 1998; rainbow "sometimes") | 1155, 1159, 1162, 1165, 1166, 1189 |
| westslope cutthroat | 20 % | no gradient limit found; a maximum swimming speed of 3.55 m/s in a flume | 1184, 1188 |
| grayling | 15 % | no gradient limit found; 1.5 m/s in a 30.5 m culvert stopped every fish under 300 mm and all but 5 of 61 longer ones | 1185, 1186 |
| kokanee | 15 % | nothing found | 1187 |

The basis the passage literature gives is a fish's leap and burst speed, not a gradient. Adult steelhead burst at 13.7
to 26.5 ft/s and chinook, coho and sockeye at 10 to 22 ft/s, while pink and chum, at 7.7 to 15.0 ft/s, were estimated
from leaps of 3 to 4 ft (Bell 1973, through Powers and Orsborn 1985; data rows 1173-1180). Reiser and Peacock (1985)
computed from darting speeds that steelhead can leap 3.4 m and coho 2.2 m (through Bjornn and Reiser 1991; data rows
1181, 1182). A gradient limit is an inference from such numbers over a reach length, and none of these sources derives
a reach gradient from them: the order Washington's table gives (chum and pink lowest, steelhead highest) follows these speeds, though the
speeds do not separate chum from pink, and none is given for sea-run cutthroat, which the table ranks with steelhead.

## What it leaves open

- **The reach length.** BC reads gradient over 100 m (bcfishpass, the 1998 guidebook), Washington over a sustained
  160 m. A 20 % limit over 160 m is less strict than the same limit over 100 m.
- **Chum and pink.** BC's 15 % is three times Washington's chum limit. Rebellato et al. set 15 % from BC fish records
  (97 % of chum and 96 % of pink with a maximum downstream gradient of 15 % or less; data rows 357, 358) and do not report how many sit above 5 % or 12 %:
  that is the track's next piece (the records above modelled gradient barriers).
- **Resident trout and char.** Bull trout and cutthroat are recorded above 25 %, and cutthroat, bull trout, Dolly Varden
  and sometimes rainbow above 20 % (BC 1998); Washington still sets resident trout and bull trout/Dolly Varden use at
  20 %. Whether link's 25 % blocks populations it should not is the same records
  question, for #131's access gate.
- **Not held:** Mesa et al. 2008 (bull trout sprint speeds) and Lauritzen et al. 2010 (kokanee jumping) are paywalled
  with no abstract to quote; Jauquet 2002, Reiser and Peacock 1985 and Bell 1973 are seen only as cited.

## Specification

- The classes' history: bcfishpass `docs/02_model_access.md` (the table, with no citation) and
  `model/01_access/sql/model_access_*.sql` (CT, DV and RB at 25 % are in the SQL only); fresh aac96efe (2026-03-18)
  first carried RB, CT and DV; link 323207783 (2026-05-02, link#107) added GR and KO at 15 %. None cites a source.
- Washington's species limits are drawn cells, read from the rendered pages of WDFW 2019's Table 2.1 (p. 2-7, repeated
  as Table 10.1, p. 10-7, and Table 11.1, p. 11-4; crossed: passes, blank: impassable) and WDFW 2009's Table 9.2 (p. 9-7,
  hatched for passing, strata to 16-20 %), which agree for the seven anadromous species.
- Capability rows carry no model parameter (`knw_literature_read()` refuses one), so they never fill an access cell;
  `0280`'s access grid asks only that every species link models has an access-gradient row, a value or a `none`.
- The evidence for bull trout's 25 % in `habitat_literature.md` ("BT has no cited source anywhere in bcfishpass") is
  this file's 25 % lineage, traced one step further back.
