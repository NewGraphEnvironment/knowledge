# Draft — link issue (NOT FILED; for review)

link is PUBLIC: aggregates only, no project or client identifiers. File once Track 3 (redd segments)
has a result, or as-is if the user wants the hold recorded now.

**Title:** BT spawning thresholds: keep for now, score against redd segments when available

**If we do it:**
- `spawn_gradient_max` (0.0549) and `spawn_channel_width_min` (2 m) for BT get scored against where BT
  actually spawned, the way #284 scored rearing.
- The spawning-connection rule that BT rearing depends on gets evidence, not only a literature default.

**If we never do:**
- The BT spawning thresholds stay set by convention.
- Any change to how rearing weights apply (all accessible stream, rather than rearing-flagged only) would
  remove a rule nobody has tested.

## What is known (evidence assembled outside link)

- **Fish records cannot settle it.**
  - Spawner evidence from provincial electrofishing (maturity-coded fish, Aug–Oct) shows no detectable
    gradient effect within watershed groups. Rate ratios across gradient classes are 0.75–1.22, with
    intervals of roughly 0–3.6.
  - The raw rise with gradient is a between-group pattern.
  - Mature fish on steep segments are mostly small. That is consistent with resident spawning, though
    many are August fish that may be migrants.
- **The literature gives observed spawning gradients, but no limit.**
  - BC reach studies place spawning at 0.6–4 %.
  - US sources call preferred spawning habitat "low-gradient stream reaches with loose, clean gravel"
    (Fraley & Shepard 1989, via the USFWS 2010 critical habitat rule), and set no gradient range.
  - Resident populations are described in smaller, higher-gradient streams.
  - Redds of large migratory BT are reported in sections as small as 2 m wetted width, by one author
    group, where such streams held a small share of redds.

## Proposed

1. Keep the BT spawning thresholds and the spawning-connection rule unchanged for now.
2. When redd or critical-spawning segments are available on FWA:
   - score `spawn_gradient_max` and `spawn_channel_width_min` against them, by length-weighted share and
     by the share link flags `spawning`;
   - state the layer's survey design, since surveys that skip streams under 2 m make the width share zero
     by construction.
3. Treat resident spawning (small, steep headwaters) as a separate question. A threshold set for migratory
   spawners will exclude it by design.

Relates to #284
