# The walk's code, by its md5

The md5 of the walk
[`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
installs (`inst/sql/ch_dist_profile.sql`). A change to the walk changes
every distance it can return, so the walk cache keys every row on it,
and every grade table records it as `walk_md5`, which `0320`, `0325` and
`0330` compare with this value (#87).

## Usage

``` r
knw_walk_md5()
```

## Value

`character(1)`, an md5 in hex.

## Examples

``` r
knw_walk_md5()
#> [1] "c3f7bdbecff1d55107f28afa59d7f532"
```
