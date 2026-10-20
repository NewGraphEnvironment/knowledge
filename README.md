# knowledge <img src="man/figures/logo.png" align="right" height="139" alt="knowledge hex sticker" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

> Fisheries evidence and tuned habitat thresholds for BC watershed groups

knowledge gathers what is known about where fish live in British Columbia's streams, a watershed group
at a time: the Province's fish sampling records, past reports and the published literature. From the fish
records it tunes, where they allow, the thresholds that [link](https://www.newgraphenvironment.com/link/)'s
habitat models use to decide where a species can spawn and rear, such as the smallest flow and the steepest
gradient for juvenile chinook rearing, and compares the tuned rules with the ones link uses today. Those models show
restoration and fish passage planning where habitat lies on a stream network.

<img src="man/figures/readme-bulk.png" alt="Map of the streams chinook can reach in the Bulkley River watershed group, coloured by whether each is chinook rearing habitat under both rules, only under link's default rule, or only under the tuned rule" width="70%" />

*Chinook rearing habitat in the Bulkley River watershed group, around Smithers and Houston, under link's
`default` rule and the rule tuned here. Blue streams are habitat under both, orange only under `default`,
green only under the tuned rule; grey streams are open to chinook but habitat under neither. Here the tuned
rule drops more than it adds.*

## Installation

```r
pak::pak("NewGraphEnvironment/knowledge")
```

knowledge is under active development and its functions change between releases (see
[NEWS](https://github.com/NewGraphEnvironment/knowledge/blob/main/NEWS.md)). Pin a release for
reproducible work: `pak::pak("NewGraphEnvironment/knowledge@vX.Y.Z")`.

The evidence tables live in the repository, not the package, so most work happens in a clone with the
package loaded from the source tree (`pkgload::load_all()`). The scripts that build them run in the order of
[`scripts/README.md`](https://github.com/NewGraphEnvironment/knowledge/blob/main/scripts/README.md), and each one's header names what it needs. Most read a
PostgreSQL database holding the BC Freshwater Atlas through fwapg, found by the standard `PG*` environment
variables, and the tuning also reads link's province-wide run and wet's flows there. Others need a
bcfishpass database, a Zotero Web API key, AWS credentials or Python.

The FDIS electrofishing extract is public as the Province supplied it, under `s3://fresh-bc/fdis/`, and so
are the visit tables built from it, as Parquet under `s3://fresh-bc/knowledge/fdis/`. The bucket does not
list: start from the extract's [provenance note](https://fresh-bc.s3.us-west-2.amazonaws.com/fdis/README.md),
which links the published tables' manifest.

## Example

The tuned thresholds are one table. Each rule's parts are rows, with the link parameter each fills where
link has one:

```r
th <- read.csv("data/thresholds.csv")
ch <- th[th$rule_id == "CH_rear_v1", c("component", "link_parameter", "value", "unit")]
print(ch, row.names = FALSE)
#>    component    link_parameter   value     unit
#>         size      rear_mad_min    0.75     m3/s
#>     gradient rear_gradient_max    0.09 fraction
#>  exception_q                      3.00     m3/s
#>  exception_d                   1000.00        m
```

The tuned rule counts a stream segment as chinook rearing habitat where its gradient is at most 9 % and
either its mean annual flow is at least 0.75 m³/s or a river of at least 3 m³/s lies within 1 km downstream.

## Learn more

- [How the chinook rearing threshold was chosen and what it draws](https://github.com/NewGraphEnvironment/knowledge/blob/main/vignettes/chinook_rearing.Rmd): the
  tuning told in plain language, with the map above and what changes on the ground.
- [What is known](https://github.com/NewGraphEnvironment/knowledge/blob/main/research/README.md): one file per topic, from the FDIS export and the cited literature
  to the tuned rules.
- [Function reference](https://github.com/NewGraphEnvironment/knowledge/tree/main/man)

## Ecosystem

| Package | Role |
|---|---|
| **knowledge** | Fisheries evidence and tuned habitat thresholds for BC watershed groups (this package) |
| [fresh](https://www.newgraphenvironment.com/fresh/) | Stream network modelling engine: segment, classify, cluster, aggregate |
| [link](https://www.newgraphenvironment.com/link/) | Intrinsic habitat models: develop, test and communicate |
| [wet](https://www.newgraphenvironment.com/wet/) | Stream flow and water temperature for BC's Freshwater Atlas |
| [flooded](https://www.newgraphenvironment.com/flooded/) | Delineate floodplain extents from DEMs and stream networks |
| [drift](https://www.newgraphenvironment.com/drift/) | Track land cover change within floodplains over time |
| [floodplains](https://www.newgraphenvironment.com/floodplains/) | Floodplain and land cover change modelling for BC watershed groups |
| [stac_floodplains_bc](https://www.newgraphenvironment.com/stac_floodplains_bc/) | STAC catalogue of floodplain land cover change in BC, 2017-2023, by watershed group |
| [cd](https://www.newgraphenvironment.com/cd/) | Climate departure analysis from ERA5-Land reanalysis |
| [fly](https://www.newgraphenvironment.com/fly/) | Estimate airphoto footprints and select photos that cover a study area |

## Data and methods it builds on

Fish records come from the Province of British Columbia: the Fisheries Data Information System (FDIS)
electrofishing extract it supplied, [Known BC Fish Observations](https://catalogue.data.gov.bc.ca/dataset/known-bc-fish-observations-and-bc-fish-distributions),
and the fish data submissions filed in [EcoCat](https://a100.gov.bc.ca/pub/acat/), which also holds the past
reports. Stream crossings come from [PSCIS](https://catalogue.data.gov.bc.ca/dataset/pscis-assessments). The
FDIS visits are placed on the stream segments of link's province-wide run, built on the
[BC Freshwater Atlas](https://www2.gov.bc.ca/gov/content/data/geographic-data-services/topographic-data/freshwater)
through [fwapg](https://smnorris.github.io/fwapg/), with flows from [wet](https://www.newgraphenvironment.com/wet/)
and dams from the [Canadian Aquatic Barriers Database](https://aquaticbarriers.ca/), and each visit is matched
to the records it produced in [bcfishobs](https://github.com/smnorris/bcfishobs). Some crossing and report
scripts also read a [bcfishpass](https://smnorris.github.io/bcfishpass/) database. Each value taken from the literature
carries a verbatim quote, checked against its source.

## Citation

```r
citation("knowledge")
```

## License

MIT for the code (see [`LICENSE`](https://github.com/NewGraphEnvironment/knowledge/blob/main/LICENSE)). Data from other sources carries its own terms: see
[`NOTICE.md`](https://github.com/NewGraphEnvironment/knowledge/blob/main/inst/NOTICE.md).
