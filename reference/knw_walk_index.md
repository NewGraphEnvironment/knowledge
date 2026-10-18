# Index the walks by source and river size, for the exception test

[`knw_rule_in()`](https://newgraphenvironment.github.io/knowledge/reference/knw_rule_in.md)
tests a rule's exception by looking up, for each visit, the distance
downstream to the first river of at least `exc_q` m³/s on one flow
source. This turns
[`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)'s
long table into that lookup once, so a grid of thousands of rules does
not re-filter it.

## Usage

``` r
knw_walk_index(walks)
```

## Arguments

- walks:

  the table
  [`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
  returns, with the target flags `target_lake` and `target_regulated`
  where the caller has them (absent columns read as `FALSE`).

## Value

A named list, one element per `src|qmin`, each a list of `pt` (the start
key `"<blue_line_key> <downstream_route_measure>"`), `dist` (`Inf` where
the walk did not find a river), `lake` and `reg`.

## Examples

``` r
w <- data.frame(blue_line_key = 1, downstream_route_measure = c(10, 10), src = "pick",
                qmin = c(3, 10), status = c("found", "none"), dist_m = c(400, NA))
names(knw_walk_index(w))
#> [1] "pick|10" "pick|3" 
```
