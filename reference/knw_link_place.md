# Place site visits on link's segments, with access and habitat for every species

`scripts/0290`'s placement, on one schema for every species at once. A
visit takes the segment of its blue line whose downstream end lies
within `[measure - 1, measure + start_window_m]`, the lowest such start
if there are several (link breaks streams at observations, and an FDIS
site's point sits at or a few metres below the record's). Only when no
segment starts in that window does it take the segment containing its
point; adjacent segments overlap by up to a few millimetres at breaks,
so there the segment with the greatest downstream measure wins and
`id_segment` breaks any tie. An overlap longer than `overlap_max_m`
anywhere a visit's point falls stops the run.

## Usage

``` r
knw_link_place(conn, visits, schema, start_window_m = 5, overlap_max_m = 0.01)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `schema`.

- visits:

  `data.frame` with `site_visit`, `watershed_group_code`,
  `blue_line_key` and `downstream_route_measure`.

- schema:

  `character(1)` link persist schema, e.g. `"fresh_default"`.

- start_window_m:

  `numeric(1)` metres above the visit within which a segment start is
  taken as the visit's segment.

- overlap_max_m:

  `numeric(1)` the largest segment overlap tolerated.

## Value

A list: `placed`, one row per placed visit (`site_visit`, `id_segment`,
`segment_start_offset_m`, the segment attributes, elevation,
`access_<sp>` columns, `<sp>_<flag>` and `<sp>_<flag>_stored` columns);
`species_access`, the species with an `access_<sp>` column;
`species_habitat`, the species with a habitat table; `overlap`, a
one-row `data.frame` with the number of visits whose point lies in two
segments and the largest overlap found.

## Details

Each placed visit carries the segment's attributes, its `access_<sp>`
from `streams_access` for every species the schema models, and for every
species with a habitat table its `accessible`, `spawning`, `rearing`,
`lake_rearing` and `wetland_rearing`, re-gated on `access_<sp> > 0`
(link#349: the two columns disagree, and `streams_access` is the gate).
The stored habitat flag is kept beside the re-gated one as
`<sp>_<flag>_stored`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
v <- data.frame(site_visit = "x", watershed_group_code = "BULK",
                blue_line_key = 360886335, downstream_route_measure = 1520.4)
knw_link_place(conn, v, "fresh_default")$placed
} # }
```
