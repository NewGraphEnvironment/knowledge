# The stretch of stream an FDIS site visit fished

An FDIS visit is placed on the Freshwater Atlas by one point, its
reported UTM snapped to a stream (`0230`), and records a fished length.
Field crews usually report a site's downstream end, so the fished
stretch is taken to run upstream from that point for the fished length,
along the same blue line, and is cut at the line's top (#23). This is
the stretch a fish caught on the visit came from, which is what \#137
weighs one discharge value per segment against.

## Usage

``` r
knw_fdis_span(downstream_route_measure, fished_length_m, line_top_m)
```

## Arguments

- downstream_route_measure:

  `numeric`, the visit's measure on its blue line, in metres.

- fished_length_m:

  `numeric`, the fished length, in metres.

- line_top_m:

  `numeric`, the blue line's top measure (its largest
  `upstream_route_measure`).

## Value

A `data.frame` with one row per visit: `upstream_route_measure`, and
`flag_span_capped`, TRUE where the line's top cut the span short.

## Details

A fished length that is missing, zero or a sentinel (9999 or more) gives
no span, nor does a point with no measure or one beyond its line's top.

## Examples

``` r
# a 200 m site 100 m up its stream, and a 300 m one whose stream ends 100 m above its point
knw_fdis_span(c(100, 900), c(200, 300), line_top_m = c(5000, 1000))
#>   upstream_route_measure flag_span_capped
#> 1                    300            FALSE
#> 2                   1000             TRUE
```
