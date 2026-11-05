# Review: final edits to vignettes/_cut_points.Rmd (16d3641..HEAD), round 1

Reviewed at c681bac. I rendered the article from a scratch copy
(`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/4806f24e-ad07-420c-9786-93dc7069477e/scratchpad/render_r1/`),
against the installed package, whose two bundles have the same md5s as `inst/vignette-data/`. It rendered with every
`stopifnot()` passing, and I looked at all four figures. `test-vignette-data.R`: 245 expectations, 5 failures, all in
the accepted environmental test ("every ignored source of the methodology article, where present, is unchanged").

## Checklist read

- code-check-python.md: in full (none of it applies; there is no Python in this diff).
- code-check-r.md: by heading. Read "Moving prose into a code chunk hides it from tools that scan the document"
  (the premise table's footnote became a `fig.cap`; it carries no `[@key]`, so citation detection loses nothing),
  "ggplot2 legends and labels: a key for an unused factor level, and ggrepel labels that must avoid each other",
  "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are", and "A `for` loop that
  builds `aes()` captures the loop variable lazily". I did not read the other headings (about 100); they name tools
  this diff does not use.
- code-check-shell.md: by heading. Read none: the diff has no shell.
- code-check-spatial.md: by heading. Read none in full. The diff's spatial change is one raster arithmetic line (the
  basemap fade) and a tmap casing layer, and no heading names either.
- code-check.md: the prose of every H3 under `## Mechanisms`, skipping `|` rows. Read most closely: "A proxy is not
  the property" and "One fact derived twice". No other headings read.

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:501-504 (guard at line 95). The sentence "For chinook rearing the
  tuning varies three parameters: the smallest stream, the steepest slope, and how close a large river must be for a
  smaller stream to count" is false for the shipped tuning tables. Each `x$tune[[setup]]` grid (6,149 candidates)
  varies:
  - the stream-size measure (`size_var`: `mad` and `width`) and its floor (`size_min`, 12 values);
  - the slope (`grad_max`, 11 values);
  - the near-river allowance's **two** numbers: the large river's size (`exc_q`: 1, 3, 5, 10, 20, 30, 50) and the
    distance (`exc_d`: 100 to 5,000).

  The close calls themselves span `exc_q` 1, 3, 5 and 10. The sentence lists three and leaves the river-size
  parameter out. The guard on line 95 (`departures == "3"`) counts link's three *parts* (size, slope, allowance), not
  parameters, so it cannot see this. The word was right before this round ("A rule has three parts"). Replacing
  "parts" with "parameters" made the count wrong.

  The next sentence ("every close call changes all three of link's standard settings") still holds as parts: the
  default is `width>=1.5|g<=0.0549|none`, and every close call changes the size floor and the slope and adds an
  allowance. It reads as wrong, though, once "three parameters" has named another set.

  Possible fixes: say "three parts", with the allowance as how large a river and how close it must be; or count the
  parameters correctly. Either way the words should match what `departures` counts (soul writing.md, "State each claim
  by the code's definition").
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:513. The setups table's first row still reads "link's full
  network, each segment reading its own slope (how link applies a rule)". The prose at line 545 says the same thing as
  "how link applies a habitat definition". This is the one place in the rendered text (outside the owner-approved
  opening) where "rule" still means a habitat definition, against this round's directive. Nothing it states is false.
  - **Rule:** none

### Figures checked, and found consistent with their captions

- **Map:** the shared habitat reads grey (#8c8c8c), the full-network-only habitat black, and the minimal-only habitat
  steel blue, each distinguishable over the faded basemap at page width. The caption names the black outlined box,
  the dashed square, the stream names and the basemap. The white casing is a halo, not a mark that needs a caption.
- **Profile:** the caption's thin grey elevation line (grey78), black full network, steel-blue minimal network, grey
  Atlas line (#9a9a9a, in the legend), ticks, black dot and open circle all match the drawing. The Atlas segment runs
  past the top (guarded). The black dot sits on the black full-network tick and line, small but visible.
- **Strip:** the light, mid and black fills match the "Slope tested" legend. The labelled slopes fall on their bars'
  side of each limit (guarded).
- **Premise bar graph:** dark (#1a1a1a) for with fish and light (#bdbdbd) for without, matching the caption's "dark"
  and "light". The dodged value labels line up with their bars, and the largest (86.2 %) fits inside the 0-1 axis.
  The caption's count of the same visits on every network is covered by the guard on line 61.
