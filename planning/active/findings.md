# Findings — Evidence vocabulary has no groundwater / upwelling variable (#36)

## Issue context

**If we do it:** statements about groundwater upwelling, hyporheic exchange and springs can be recorded as evidence rows. These are the site features the BT spawning literature stresses most after gradient. **If we never do:** they are either left out or squeezed in as `temperature` or `valley_width_index` qualitative rows, which reads as a claim about something else.

## Problem

`knw_literature_vocab()` has no variable for groundwater. In #33 the drafter left out the pure groundwater statements, from the 2010 critical habitat rule's hyporheic passages and from Hagen & Weber 2019 p. 22. Other statements went in under `temperature` (cold springs) or `valley_width_index` (alluvial, bounded valley reaches).

## Proposed solution

Add a `groundwater` variable to the vocabulary, with no unit (qualitative rows only) or a unit for upwelling flux if a source gives one. Add a test. Re-file the left-out statements from `planning/archive/2026-10-issue-33-*/draft-spawn-notes.md`.

Relates to #33, #19

