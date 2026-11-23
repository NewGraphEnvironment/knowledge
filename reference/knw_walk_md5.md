# The walk's code, by its md5

The md5 of the walk
[`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
installs (`inst/sql/ch_dist_profile.sql`). A change to the walk changes
every distance it can return, so the walk cache keys every row on it,
and every grade table records it as `walk_md5`, which `0320`, `0325` and
`0330` compare with this value (#87).

## Usage

``` r
knw_walk_md5(window = FALSE)
```

## Arguments

- window:

  `logical(1)` the window walk's md5 instead of the annual walk's.

## Value

`character(1)`, an md5 in hex.

## Details

The window walk (`inst/sql/ch_dist_profile_window.sql`, \#226) is
another file with its own md5, which only its own cache rows are keyed
on: no grade is walked by it, so nothing compares a grade with it.

## Examples

``` r
knw_walk_md5()
#> [1] "c3f7bdbecff1d55107f28afa59d7f532"
```
