# Access gradients: where link's classes come from, and what fish are measured to pass

**Verified:** 2026-11-18 · **Issues:** #234 (this), the first piece of the access track (#132); split from backlog move 9
(#178) · **Produced by:** `data/literature_evidence.csv` data rows 1154-1189, gated by
`scripts/0280-literature-verify.R` (log `scripts/logs/habitat/20261118_literature_verify.csv`); sources in the group
library's `Fisheries/Fish Passage/passage_limits` collection (`data/passage_limits_{members,additions}.csv`,
`scripts/0270`) and the `fish_passage` store; the classes' history read from bcfishpass's docs and SQL and from fresh's
and link's `parameters_fresh.csv` histories · **Status:** the literature half of #132; the records above modelled
gradient barriers are the track's next piece.

## What link does, and what this asks

link blocks a species above the first stretch of stream steeper than its access gradient, read over 100 m: 15 % for
chinook, chum, coho, pink, sockeye, grayling and kokanee, 20 % for steelhead and westslope cutthroat, 25 % for bull
trout, rainbow, cutthroat and Dolly Varden (link's `configs/default/parameters_fresh.csv`). Those cuts decide which water
can hold habitat at all, and where link breaks streams. This file asks where each number came from, and whether what
fish are measured or seen to pass supports it.

**In short:** none of the classes is a measured passage limit. 25 % comes from BC's first fish-passage model and 20 %
from BC's 1998 fish-stream rule and Washington's barrier manual, each a convention handed down without its basis; 15 %
is the one set on evidence, from where chinook and coho records sit, beside Washington's 16 %. Grayling and kokanee have
no source at all. Where the
sources give species limits, chum (5 %) and pink (12 %) sit well below the 15 % BC applies to them, and bull trout,
Dolly Varden and resident trout are seen above their class.

## Where each class comes from

- **25 %, bull trout, rainbow, cutthroat, Dolly Varden.** BC's Fish Passage GIS Version 1 used 25 % for every species
  (data row 1157). Its authors took 20 % for anadromous species from the 1998 guidebook and 25-30 % for bull trout and
  Dolly Varden/cutthroat from Cannings and Ptolemy 1998. That book says only that bull trout reach 30 %, on a personal
  communication (data row 1156). bcfishpass kept 25 % for bull trout and, in its SQL, for rainbow, cutthroat and Dolly
  Varden; Norris and Mount 2016 call it Version 1's cut-off and say the model was never field verified.
- **20 %, steelhead and westslope cutthroat.** BC's 1998 Fish-stream Identification Guidebook designates reaches under
  20 % as fish streams by default, measured over 100 m, and cites no study (data row 1158). Washington's 2009 manual
  defines a natural barrier for most adult salmonids as more than 20 % sustained for 160 m (data row 1154), and its 2019
  edition gives steelhead the same 20 % (data row 1168). No source gives westslope cutthroat a limit (data row 1188).
- **15 %, the five salmon, grayling and kokanee.** The CWF report behind bcfishpass's salmon thresholds cites
  Washington's 16 % for chinook, coho and sockeye, finds 98 % of chinook and 94 % of coho records in BC below a maximum
  downstream gradient of 15 %, and on those results sets 15 % for all five salmon (Rebellato et al. 2024's rows).
  Washington's own table passes chinook, coho and sockeye to 16 %, pink to 12 % and chum to 5 % (data rows
  1167, 1169-1172). Grayling and kokanee entered link's configuration on the salmon class in 2026; no source gives
  either a gradient limit (data rows 1186, 1187).

## What fish are measured to pass

| species | link's class | what the sources give | data rows |
|---|---:|---|---|
| chinook, coho, sockeye | 15 % | pass to 16 % (WDFW 2019) | 1167, 1170, 1171 |
| pink | 15 % | pass to 12 % (WDFW 2019) | 1172 |
| chum | 15 % | pass to 5 % (WDFW 2019) | 1169 |
| steelhead | 20 % | pass to 20 % (WDFW 2019) | 1168 |
| bull trout | 25 % | found to 30 % (Cannings and Ptolemy, pers. comm.); 20 % used, "often found above 30%" recognised (WDFW 2019, after Cannings and Ptolemy); well above 20 % in stepped-pool reaches (BC 1998) | 1156, 1160, 1163 |
| Dolly Varden | 25 % | as bull trout in WDFW 2019 and BC 1998 | 1161, 1164 |
| rainbow, cutthroat | 25 % | resident cutthroat/rainbow: 20 % used, passing to 33 % recognised, the 33 % being cutthroat's (WDFW 2019, after Jauquet 2002); sea-run cutthroat pass to 20 % (WDFW 2019); well above 20 % (BC 1998; rainbow "sometimes") | 1155, 1159, 1162, 1165, 1166, 1189 |
| westslope cutthroat | 20 % | no gradient limit found; a maximum swimming speed of 3.55 m/s in a flume | 1184, 1188 |
| grayling | 15 % | no gradient limit found; 1.5 m/s in a 30 m culvert stopped every fish under 300 mm | 1185, 1186 |
| kokanee | 15 % | nothing found | 1187 |

The basis the passage literature gives is a fish's leap and burst speed, not a gradient. Adult steelhead burst at 13.7
to 26.5 ft/s and chinook, coho and sockeye at 10 to 22 ft/s, while pink and chum, at 7.7 to 15.0 ft/s, were estimated
from leaps of 3 to 4 ft (Bell 1973, through Powers and Orsborn 1985; data rows 1173-1180). Steelhead leap to 3.4 m and
coho to 2.2 m (Reiser and Peacock 1985, through Bjornn and Reiser 1991; data rows 1181, 1182). A gradient limit is an
inference from such numbers over a reach length, and none of the sources makes that inference explicitly: the order
they give (chum lowest, steelhead highest) is the order of these speeds.

## What it leaves open

- **The reach length.** BC reads gradient over 100 m (bcfishpass, the 1998 guidebook), Washington over a sustained
  160 m. A 20 % limit over 160 m is less strict than the same limit over 100 m.
- **Chum and pink.** BC's 15 % is three times Washington's chum limit. Fish records above 5 % for chum and 12 % for pink
  are what would say which is right; that is the track's next piece (the records above modelled gradient barriers).
- **Resident trout and char.** Every source that looks says bull trout, Dolly Varden and resident trout use reaches
  above their class. Whether link's 25 % blocks populations it should not is the same records question, for #131's
  access gate.
- **Not held:** Mesa et al. 2008 (bull trout sprint speeds) and Lauritzen et al. 2010 (kokanee jumping) are paywalled
  with no abstract to quote; Jauquet 2002, Reiser and Peacock 1985 and Bell 1973 are seen only as cited.

## Specification

- The classes' history: bcfishpass `docs/02_model_access.md` (the table) and `model/01_access/sql/model_access_*.sql`
  (CT, DV and RB at 25 % are in the SQL only); fresh aac96efe (2026-03-18) first carried RB, CT and DV; link 323207783
  (2026-05-02, link#107) added GR and KO at 15 %. None cites a source.
- Washington's species limits are drawn cells (crossed: passes; blank: impassable), read from the rendered pages of
  WDFW 2019's Table 2.1 (p. 2-7, repeated as Table 10.1, p. 10-7) and WDFW 2009's Table 9.2 (p. 9-7), which agree.
- Capability rows carry no model parameter (`knw_literature_read()` refuses one), so they never fill an access cell;
  `0280`'s access grid asks only that every species link models has an access-gradient row, a value or a `none`.
- The evidence for bull trout's 25 % in `habitat_literature.md` ("BT has no cited source anywhere in bcfishpass") is
  this file's 25 % lineage, traced one step further back.
