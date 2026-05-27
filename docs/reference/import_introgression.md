# Import introgression results

Import introgression summaries into a typed tidy object for use with
[`plot_introgression()`](https://wwz33.github.io/ggPopi/reference/geom_introgression.md)
or `ggpop() + geom_introgression()`.

## Usage

``` r
import_introgression(
  dir = NULL,
  ...,
  type = c("auto", "dsuite_dtrios", "dsuite_dinvestigate", "fixed_diff",
    "genomics_general", "admixtools", "treemix", "qpgraph")
)
```

## Arguments

- dir:

  Directory containing introgression result files, or a single file
  path.

- ...:

  Optional named file paths. Relative paths are resolved inside `dir`.

- type:

  Input type. Supports Dsuite `Dtrios`/BBAA/Dmin trio summaries, Dsuite
  `Dinvestigate`/localFstats window summaries, fixed-difference trio
  summaries, genomics_general ABBA-BABA window outputs, ADMIXTOOLS
  qpdstat/f3/f4ratio tables, TreeMix internal edge/treeout summaries,
  and legacy qpGraph edge tables. TreeMix `*.edges.gz` imports use
  matching `*.vertices.gz` files when present to recover the
  drift-coordinate layout.

## Value

A `ggpop_introgression` tidy S3 data frame with standardized columns
including `analysis`, `stat`, `value`, and format-specific columns such
as `chr`, `start`, `end`, `pop1`, `pop2`, `pop3`, `from`, and `to`.

## Details

Windowed Dsuite `Dinvestigate`/localFstats and genomics_general
ABBA-BABA outputs are normalized to one row per statistic per window.
Dsuite `Dtrios`/BBAA/Dmin files are imported as trio-level D statistic
summaries. ADMIXTOOLS qpdstat, f3, and f4ratio outputs are imported as
trio statistic tables. TreeMix internal `*.edges.gz` and `*.treeout.gz`
files are imported as lightweight graph summaries. For `*.edges.gz`, a
same-prefix `*.vertices.gz` file is used when available to add `x`, `y`,
`xend`, and `yend` drift coordinates; `*.treeout.gz` alone remains a
migration-edge summary. Legacy qpGraph edge tables expect user-facing
`from` and `to` columns.

## Examples

``` r
local_fstats <- system.file(
  "extdata", "introgression", "Dsuite",
  "PopB_PopC_PopA_localFstats_run1_100_50.txt",
  package = "ggPopi"
)
intro <- import_introgression(local_fstats, type = "dsuite_dinvestigate")
intro |> plot_introgression(stat = c("D", "fdM"))


trios <- import_introgression(
  system.file("extdata", "introgression", "Dsuite", "dsuite_results_BBAA.txt", package = "ggPopi"),
  type = "dsuite_dtrios"
)
trios |> plot_introgression(style = "matrix")


qpdstat <- import_introgression(
  system.file("extdata", "introgression", "admixtools", "qpdstat_result.csv", package = "ggPopi"),
  type = "admixtools"
)
qpdstat |> plot_introgression()
```
