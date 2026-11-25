# Findings — statistics store: seven cited works of the detection methods that the library does not hold (#274)

## Issue context

**If we do it:** every work the detection models' documentation cites can be searched and read on its page in the
`statistics` store, so a claim about a method is checked against the paper and not against a memory of it. **If we
never do:** seven cited works stay outside the store, three of them read only from copies nothing here holds, and
four not read at all.

### Problem

The `statistics/detection` collection (#216) holds the methods literature for occupancy, removal, eDNA, camera
surveys and diversity. A read of the citations that rest on it found seven cited works that are not in the group
library:

| work | DOI | cited for | a free copy |
|---|---|---|---|
| Morris, White and Crowther (2019), Using simulation studies to evaluate statistical methods, *Statistics in Medicine* 38 | `10.1002/sim.8086` | summarising a simulation study by bias and coverage | published version on PubMed Central (PMC6492164); the publisher and PMC both refuse a scripted download, a browser gets it |
| Kellner et al. (2023), The unmarked R package, *Methods in Ecology and Evolution* 14 | `10.1111/2041-210X.14123` | the software several models are fitted or checked with | published version, the authors' deposit (Zenodo record 11371966, CC BY 4.0) |
| Taylor (2008), Automatic bandwidth selection for circular density estimation, *Computational Statistics and Data Analysis* 52 | `10.1016/j.csda.2007.11.003` | the smoothing rule for an activity pattern | accepted manuscript only (White Rose Research Online, eprint 3793) |
| Best and Fisher (1979), Efficient simulation of the von Mises distribution, *Applied Statistics* 28 | `10.2307/2346732` | drawing times of day | none found (Unpaywall: closed) |
| O'Brien, Kinnaird and Wibisono (2003), Crouching tigers, hidden prey, *Animal Conservation* 6 | `10.1017/S1367943003003172` | the window that makes two detections one event | none found (Unpaywall: closed) |
| Albert and Anderson (1984), On the existence of maximum likelihood estimates in logistic regression models, *Biometrika* 71 | `10.1093/biomet/71.1.1` | an estimate at a boundary | none found (Unpaywall: closed) |
| Seber (1982), *The Estimation of Animal Abundance and Related Parameters*, 2nd ed. | (book) | the removal estimator | a book |

Each DOI was resolved against Unpaywall on 2026-11-24.

### Proposed Solution

Add the seven to `data/detection_additions.csv`, acquire what can be had (Mode 0 of the literature workflow, with
the paywalled ones searched for as #216's revised rule says before any counts as a gap), file them under
`statistics/detection`, and rebuild `statistics` with its whole build list (script 0150). Taylor (2008) would be the
third accepted manuscript in the collection, with a note saying so.

Relates to #216

## Errors Encountered

| Error | Resolution |
|-------|------------|
