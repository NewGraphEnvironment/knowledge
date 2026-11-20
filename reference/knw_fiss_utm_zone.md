# Read a UTM zone as entered

Submitters write the zone as "10", "11U", "10 U" or "zone 11". The
letter is the latitude band (all of BC is U or V), so the zone is the
leading digits. Read as a plain number, "11U" was `NA` on 116 sites each
in two North Thompson groups, which were then never placed.

## Usage

``` r
knw_fiss_utm_zone(x)
```

## Arguments

- x:

  a vector of zones as entered.

## Value

`numeric`, the zone, or `NA` where `x` carries no digits.

## Examples

``` r
knw_fiss_utm_zone(c("10", "11U", "10 U", "zone 11", "", NA))
#> [1] 10 11 10 11 NA NA
```
