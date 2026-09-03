# PINE (Pine River) — the whole story: what a fish bio should know before the field

Watershed group **PINE / Pine River**, around **Chetwynd, BC** (Peace region, below the W.A.C.
Bennett Dam). The Pine rises in the Misinchinka Ranges, runs east collecting the **Sukunka** and
**Murray** rivers, and joins the **Peace River near Taylor**; it follows **Hwy 97** from Pine Pass
through Chetwynd. This is the richest of our three target groups — **307 PSCIS crossings / 137
barriers** across ~55 named systems. This brief is the "learn everything first" layer.

> Draft 2026-07-11, from web + EcoCat + the harvested report corpus (Zotero `pine - PINE` ~69 reports;
> queryable in `data/rag/peace.duckdb`). Citations inline.

## Nations & territory — and what they care about (engagement-critical)

Chetwynd / Pine / Moberly country is **Treaty 8**, the territory of the **West Moberly First Nations**
(West Moberly Lake 168A) and **Saulteau First Nations** (Moberly Lake), with **McLeod Lake**,
**Halfway River**, and **Blueberry River** nations in the broader region.
([West Moberly](https://en.wikipedia.org/wiki/West_Moberly_First_Nations),
[Saulteau — Treaty Rights & Environmental Protection](https://www.saulteau.com/departments-and-services/treaty-rights-and-environmental-protection/))

**What they care about — lead with this:**
- **Caribou recovery is the defining conservation story here.** West Moberly + Saulteau jointly run
  the **Klinse-Za** maternal-penning + predator-management + habitat-restoration program — from **16
  animals (2013) to 100+** — one of BC's most successful recoveries, backed by a **30-year, ~2-million-acre
  partnership agreement (2020)**. The herd roams the northern Rockies west of Hudson's Hope and
  Chetwynd. The **Bennett Dam severed the caribou migration** — a living grievance.
  ([The Tyee](https://thetyee.ca/News/2020/09/25/Caribou-Recovery-Indigenous-Leadership/),
  [The Narwhal](https://thenarwhal.ca/agreements-mark-turning-point-six-b-c-caribou-herds-leave-most-herds-hanging/))
- **Treaty rights and cumulative effects** — coal, forestry, oil & gas (Montney), and **Site C** (on
  the Peace, downstream) have driven the *Yahey v. BC* cumulative-effects concerns. Approach any
  disturbance-adjacent work with that context; connect fish-passage/habitat gains to their priorities.
- **Food traditions** — caribou, moose, fish. Restoration framed as cultural continuity lands better
  than "compensation."

## Species at risk

- **Arctic Grayling** (Williston/Peace) — the flagship; a regionally important fishery and a
  conservation priority. Pine/Sukunka/Burnt hold the strongest populations.
- **Bull Trout — Western Arctic population (DU2)** — COSEWIC **Special Concern**. Needs cold water,
  clean spawning substrate, and **connectivity** to headwaters — so culvert barriers hit it directly.
  Poor status is tied to cumulative land use (forestry, oil/gas, coal, ORV access).
  ([bull trout cumulative-effects context](https://www.jasperlocal.com/2021/05/19/at-risk-of-failure-alberta-ecologist-calls-bull-on-dfos-critical-habitat-order/))
- **Southern Mountain Caribou** — Klinse-Za, plus Quintette and Narraway herds (federally Threatened).

## Ongoing recovery & funding programs

- **Klinse-Za caribou recovery** (West Moberly / Saulteau) — the marquee program.
- **FWCP – Peace Region** — funds tributary habitat + **Arctic Grayling** restoration (aligns to the
  FWCP Arctic Grayling Status & Limiting Factors Synthesis). ([FWCP](https://fwcp.ca/our-work-in-your-region/))
- **Fish-passage remediation** — where our work plugs in (Guppy's barriers, below).

## The recreational fishery (why the public cares)

The **Pine Highway (Hwy 97) Arctic Grayling dry-fly fishery** is genuinely renowned — the Pine from
Pine Pass through Chetwynd, plus the **Sukunka** and **Burnt**, hold lots of grayling; best mid-July
to early September. The **Sukunka** (accessed via the Sukunka FSR) also fishes for **bull trout,
rainbow, Dolly Varden, and Rocky Mountain whitefish**. **Sukunka Falls Provincial Park** is a local
landmark. ([gofishbc](https://www.gofishbc.com/learn/fishing-tips/where-to-fish/fly-fishing-for-arctic-grayling-along-the-pine-highway-in-northern-bc/),
[SunCruiser](https://suncruisermedia.com/the-sport-fishing-guide/features/driving-the-pine-for-arctic-grayling/),
[Sukunka Falls PP](https://env.gov.bc.ca/bcparks/explore/parkpgs/sukunka))
Local stewardship: **Mackenzie Fish & Game** (regional); Chetwynd-area rod & gun / BCWF clubs.

## Industrial context (drives both the impacts and the reports)

Northeast **coal** (Sukunka, Wolverine, Quintette, Brazion), **forestry** (Canfor **TFL 48**, Chetwynd
Forest Industries, Dawson Creek FD), **oil & gas** (Montney), and rail (CN). This is why so much of
the harvested literature is EIA/inventory work — and why cumulative effects dominate the conservation
conversation.

## Key past fish work — and where to read it (all in Zotero + Ragnar)

- **Guppy 2006 Peace River Stream Crossing Inventory** — the source of all 307 PINE PSCIS crossings;
  Table 8 = his **10 Priority-1 barriers in Pine** (see `priority_guppy_p1.csv`).
- **Stuart & Chislett 1979** — Arctic Grayling life history, **Sukunka** drainage (foundational).
- **Culling — Burnt River Grayling** assessments (1999, and data 1990–2006).
- **Hatfield 1:20,000 Reconnaissance Inventories** (TFL 48 / Canfor / CFI) — reach-level fish-bearing
  status incl. **non-fish-bearing** determinations.
- **Callazon / Sukunka / Martin Creek** watershed-restoration reports (G3, AGRA, EDI).
- Query any of it: `WSG_TARGET=peace QUERY="..." Rscript scripts/0155-rag-query.R`.

## Field-prep takeaways

1. Grayling + bull trout are the target species; barrier removal that reconnects cold headwater
   habitat serves both — and the caribou-era restoration narrative.
2. Check the 1:20,000 inventories for **non-fish-bearing** reaches before prioritizing a barrier
   (some Guppy P1 sites need fish-presence confirmation — his own note).
3. Engagement runs through West Moberly + Saulteau; caribou and cumulative effects are the frame.
4. Priority barriers to hit: Sukunka tribs, Wildmare, Bissette, Windrem, Rocky Ck, Pine oxbow,
   Silver Sands (see `priority_guppy_p1.csv`).
