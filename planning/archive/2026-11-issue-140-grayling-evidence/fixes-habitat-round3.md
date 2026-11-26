# Write-up fixes, round 3 (#140), applied 2026-11-26

All 10 findings of `audit-habitat-round3.md` accepted, and the two it noticed outside its scope (the MAD paragraph's
"every class has an interval", false for the two empty classes over 5 m³/s, and its missing any-fish reading, now given
from `data/gr_use.csv`: any-fish ratio 0.143, given-fish 0.939 (0.333-2.085)). One fix (F6) sat inside round 2's.

| finding | change |
|---|---|
| F1, F2 | "No source gives a gradient limit"; "medium", "low" or "relatively low" as the rows say |
| F3, F5 | Hawkshaw and Shrimpton's poor prediction is at the watershed scale, and the low-contrast reason is offered as one possibility |
| F4 | Adsett densest per unit of habitat; the preference is what the authors suggest |
| F6 | populations appear centred around the fry rearing areas, which lie in 4th-order-and-larger tributaries |
| F7 | up to 5.49 % no class caught detectably less often, with the river-polygon sensitivity's lower read |
| F8, F9 | width: as low with no modelled width; MAD: few visits caught any fish, and among those that did, grayling as often |
| F10 | Hawkshaw and Shrimpton's sites are scored as juvenile sites by one grayling of any size |
