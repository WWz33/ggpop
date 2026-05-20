# Import introgression results

Import introgression summaries into a typed tidy object for use with
[`plot_introgression()`](https://wwz33.github.io/ggPopi/reference/geom_introgression.md)
or `ggpop() + geom_introgression()`.

## Usage

``` r
import_introgression(
  dir = NULL,
  ...,
  type = c("auto", "dsuite_dtrios", "dsuite_dinvestigate", "genomics_general",
    "treemix", "qpgraph")
)
```

## Arguments

- dir:

  Directory containing introgression result files, or a single file
  path.

- ...:

  Optional named file paths. Relative paths are resolved inside `dir`.

- type:

  Input type. Supports Dsuite `Dtrios`, Dsuite
  `Dinvestigate`/localFstats, genomics_general ABBA-BABA window outputs,
  TreeMix edge lists, and ADMIXTOOLS2 qpGraph edge tables.

## Value

A `ggpop_introgression` tidy S3 data frame with standardized columns
including `analysis`, `stat`, `value`, and format-specific columns such
as `chr`, `start`, `end`, `pop1`, `pop2`, `pop3`, `from`, and `to`.

## Details

Windowed Dsuite `Dinvestigate`/localFstats and genomics_general
ABBA-BABA outputs are normalized to one row per statistic per window.
Dsuite `Dtrios` is imported as trio-level D statistic summaries. Graph
imports expect a user-facing edge table with `from` and `to` columns;
this is suitable for TreeMix migration-edge summaries or ADMIXTOOLS2
qpGraph edge data frames.

## Examples

``` r
gg_dir <- system.file("extdata", "introgression", "genomics_general", package = "ggpop")
intro <- import_introgression(gg_dir, type = "genomics_general")
#> Error: `dir` must point to an existing directory.
intro |> plot_introgression(stat = c("D", "fdM"))
#> Error: object 'intro' not found

trios <- import_introgression(
  system.file("extdata", "introgression", "Dsuite", "Dtrios.tsv", package = "ggpop"),
  type = "dsuite_dtrios"
)
#> Error: `dir` must point to an existing directory.
trios |> plot_introgression()
#> Error: object 'trios' not found
```
