# Findings — Evidence vocabulary has no groundwater / upwelling variable (#36)

## Issue context

**If we do it:** statements about groundwater upwelling, hyporheic exchange and springs can be recorded as evidence rows. These are the site features the BT spawning literature stresses most after gradient. **If we never do:** they are either left out or squeezed in as `temperature` or `valley_width_index` qualitative rows, which reads as a claim about something else.

## Problem

`knw_literature_vocab()` has no variable for groundwater. In #33 the drafter left out the pure groundwater statements, from the 2010 critical habitat rule's hyporheic passages and from Hagen & Weber 2019 p. 22. Other statements went in under `temperature` (cold springs) or `valley_width_index` (alluvial, bounded valley reaches).

## Proposed solution

Add a `groundwater` variable to the vocabulary, with no unit (qualitative rows only) or a unit for upwelling flux if a source gives one. Add a test. Re-file the left-out statements from `planning/archive/2026-10-issue-33-*/draft-spawn-notes.md`.

Relates to #33, #19


## Exploration (2026-10-07)

- `fits` in `.literature_check()` is the unit gate. `groundwater = character(0)` refuses every unit. A value
  needs a unit, so a groundwater row carries no value. No code beyond the two list entries.
- `0280` checks a no-value row by its quote only, and its THERMAL grid names temperature and degree_days,
  so the gate needs no change. `ip.R` reads only `life_stage`/`life_history_form` from the literature vocab.
- Row numbers in the approved plan were **file lines** (one more than data rows). The rows are data rows
  493 (Metolius temperature qual), 501/502 (Hagen & Sary elevation/vwi), 503 (USFWS 2015 p. 5) and
  505 (USFWS 2015 p. 6 Swan River). Trotter 2000 is data row 94.
- New rows are **appended** (data rows 675-683), because `research/bt_spawning.md` and other docs cite
  evidence rows by data-row number, and an insert would renumber them.

## Meaning audit, one line per row (data rows 675-683)

Each quote was read in its page's text (`scratch_keytext.py` from the #29 archive). The
`0280` log's `pdf_pages` match the printed pages via each document's offset (Hagen & Weber PDF 21/24 =
pp. 19/22; 2015 plan PDF 20/21 = pp. 5/6; 2010 rule PDF 33 = FR 63930).

675. Metolius p. 36, spawning, groundwater sibling of row 493. The spawning and rearing streams are
     spring-influenced; reach scale and `cited_source` Riehle 1993, as the original. Its note points to rows
     684 and 685. OK.
676. Hagen & Sary 2023 p. 4, spawning, the third row from the sentence. It names "groundwater exchange" as
     part of the alluvial-section geomorphology that redds relate to; reach scale (alluvial sections). OK.
677. USFWS 2015 p. 5, spawning, sibling of 503. "Cold-water springs, groundwater infiltration". The 2010
     rule's parallel sentence goes in the note, not a row: the 2015 plan restates the rule elsewhere (#33
     flag 3), and the two cite overlapping sources. OK.
678. USFWS 2015 p. 6 Swan River, spawning, sibling of 505. The measured correlate is bounded alluvial
     reaches; groundwater exchange is the plan's "likely". The note says so, so the row does not read as a
     measured groundwater correlation. Network scale, as the original. OK.
679. 2010 rule p. 63930, spawning, hyporheic flow, citing Baxter and Hauer 2000. "Across multiple spatial
     scales", so scale is blank. The quote carries the rule's own definition of hyporheic flow. Not
     independent of 676: Hagen & Sary also cite Baxter and Hauer 2000, and the note says so (review G2). OK.
680. 2010 rule p. 63930, spawning, Fraley and Shepard 1989 (Flathead): groundwater influence and proximity
     to cover in spawning site selection. Site scale; region Flathead River system as in row 508, which
     comes from the same paragraph. A new statement, not in the #33 notes. OK.
681. Hagen & Weber 2019 p. 22, spawning: spawning sites in larger streams with aggrading areas and
     groundwater infiltration. The note keeps the smaller-stream caveat from the same sentence. Region
     wording follows rows 501/502 (a general statement in a Williston report). OK.
682. Hagen & Weber 2019 p. 19, incubation: Halfway River experiment, groundwater areas gave higher
     egg-to-alevin survival (Baxter 1997). Site scale. OK.
683. USFWS 2015 p. 6, incubation: embryos survived better in upwelling areas used for spawning than in
     recharge areas not used (Baxter and McPhail 1999). The plan names no stream, so the region is the plan's
     coverage. May be the same work as 682; the note says that is unchecked. OK.
684. Metolius p. 28 (OCR PDF p. 32), spawning: spawning observed at Heising Spring and at a
     spring-influenced area of the mainstem near Jack Creek. This is the report's own observation, so no
     `cited_source`. Site scale. Added after plan review G5; it is the most direct statement of the set. OK.
685. Metolius p. 6 (OCR PDF p. 10), spawning: no perennial cold spring areas suitable for spawning in the
     mainstem Crooked River. It is the authors' reason that Crooked River fish were wanderers, an absence the
     authors state rather than a survey result, and the note says so. Region Crooked River; reach scale;
     `life_history_form` blank, because the wanderers' origin is "other populations". OK.

Rows 1-674 verify with the same status as in `20261006_literature_verify.csv` (674 compared, 0 changed). The 11
new rows give verified_text 8 and verified_ocr 3.

## Left out, with reasons

- 2010 rule PCE 1 (p. 63931 area): "Springs, seeps, groundwater sources, and subsurface water connectivity
  (hyporheic flows) ... provide thermal refugia". A criterion for every life stage, and `life_stage` has
  no all-stages value. Not stage-specific evidence.
- 2015 plan p. 6, "Redds are often constructed in stream reaches fed by springs or near other sources of cold
  groundwater": the same claim as p. 5 (row 677). Its note quotes it.
- Trotter 2000 p. 9 (data row 94): springs explain where BT **occur** (distribution boundaries), not where
  they spawn, so no groundwater sibling. Row 94 itself is coded `spawning` from that sentence. The text just
  before it says cold water is requisite for spawning and early life stages, which arguably supports the
  coding. Left as is, outside this issue's scope.
- Metolius p. 37 (OCR PDF p. 41): cold water from tributaries and springs lowers embryos' oxygen use, so
  sediment effects "may be partially mitigated". It is about the effect of temperature on sediment
  tolerance, and hedged; the same holds for the p. 36 sentence after the spring sentence ("These cold water
  conditions may help buffer ..."). The mechanism named is temperature and oxygen, not groundwater. Not a row
  (meaning audit, candidate 3, declined).

## Meaning audit, independent (`review-p2-meaning.md`), and what changed

The audit found 4 errors, 3 candidate rows and 3 firm-ups. Its reference-list claims were checked against the
extracted text before acting: Baxter 1997 is the Chowade River MSc thesis; Williamson 2006 is a northern BC
thesis; the 2015 plan lists Baxter and McPhail 1999 (egg-to-alevin, upwelling) and Baxter, Frissell and
Hauer 1999 (TAFS 128:854, geomorphology and spawning distribution).

- Hagen & Sary p. 4 region: "citing mostly Montana studies" was wrong (two Montana, two northern BC). Fixed
  on all three rows from the sentence (501, 502, 676). 501 and 502 predate this issue (#33).
- 677: the reason for not making the 2010 sentence a row is now the real one (same agency, same claim, its
  citations are in this row's list). The note also says why the p. 6 "Redds are often constructed ..."
  sentence is not a row.
- 678 and 505 (Swan River): the plan's citation of Baxter and McPhail 1999 is probably a slip, judged from
  the plan's own reference-list titles. `cited_source` is kept as printed. 505's earlier speculation about
  Baxter and Hauer 2000 is removed.
- 493 and 675: `cited_source` Riehle 1993 is kept, with a note that the sentence carries no citation itself.
- 682 and 683: not independent. Probably the thesis (1997) and its paper (1999).
- 685: scale blank (the whole mainstem). 684 and 679 wording tightened. 680: where the Flathead is named.
- New row **686**: Hagen & Weber p. 19, Pratt 1992, incubation, hedged ("may compensate").

After the fixes, 0280 reads 686 rows. Rows 1-674 still have identical statuses; the 12 new rows give
verified_text 9 and verified_ocr 3.

## Meaning audit round 2 (`review-p2-meaning-round2.md`), and how the loop ended

Round 2 found two errors inside round 1's fixes, both now fixed:
- 680 said "two sentences earlier", which round 1 had suggested; the Flathead is named five sentences earlier.
  The note now names the sentence rather than counting.
- 682/683 said "the two incubation rows", ambiguous once 686 existed; each now names the other row.

Also fixed: 493's p. 6 clause put "no spawning documented" on the mainstem, but the source says it of the
upper Crooked River Basin (OCR p. 10, checked); 686 scale `site`, plus a note on "streambed recharge".

Since a round had found errors inside fixes, the loop ended by **enumeration**, not by another round. Every
cross-reference claim in the changed notes (493, 501-503, 505, 675-686) was checked mechanically:
- same-sentence claims: quotes identical for 493/675, 503/677, 501/676, 502/676 and 505/678;
- citation-list claims: 677 against 503's `cited_source`, and 679 against 676's (Baxter and Hauer 2000);
- row pointers: 680 → 508 (temperature, max 10, Flathead, p. 63930); 682 ↔ 683 and 686; 675 → 684 (p. 28)
  and 685 (p. 6).

All hold. 0280 reads 686 rows with rows 1-674 unchanged; tests pass.
