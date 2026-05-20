# Import LD decay results

Import LD decay summaries into a typed tidy object for use with
[`plot_ld_decay()`](https://wwz33.github.io/ggpop/reference/geom_ld_decay.md)
or `ggpop() + geom_ld_decay()`. PopLDdecay `*.stat.gz` and `*.bin.gz`
files are read directly. PLINK pairwise `*.ld` files are summarized into
distance bins.

## Usage

``` r
import_ld_decay(
  dir = NULL,
  ...,
  type = c("poplddecay", "plink", "auto"),
  pop = NULL,
  pop_group = NULL,
  method = c("MeanBin", "none", "MedianBin", "PercentileBin"),
  bin1 = 10,
  bin2 = 100,
  breakpoint = 100,
  percent = 0.5,
  bin_size = NULL
)
```

## Arguments

- dir:

  Directory containing LD decay result files.

- ...:

  Optional named file paths. Relative paths are resolved inside `dir`.

- type:

  Input type. Supports `"poplddecay"` and `"plink"`.

- pop:

  Optional sample or group labels for input files. A scalar is recycled
  across files; a vector is matched to file order.

- pop_group:

  Optional population group table or path to the standard two-column
  `sample pop` file. File labels are matched through `sample`.

- method:

  Binning method for PopLDdecay summaries and PLINK pairwise LD tables.
  `"MeanBin"` matches the common PopLDdecay summary plot; `"MedianBin"`
  and `"PercentileBin"` use pair-count weighted quantiles.

- bin1:

  Short-distance bin width in base pairs.

- bin2:

  Long-distance bin width in base pairs.

- breakpoint:

  Distance threshold that switches from `bin1` to `bin2`.

- percent:

  Percentile used by `"PercentileBin"`.

- bin_size:

  Legacy alias for a single bin width. When supplied, `method` is
  treated as `"MeanBin"` and both bin widths use the same size.

## Value

A `ggpop_ld_decay` tidy S3 data frame with standardized columns
including `dist`, `dist_kb`, `r2`, `pop`, and `n_pairs`.

## Details

Population grouping follows the package-wide convention: `pop_group` is
the standard two-column `sample pop` table used by PCA and admixture
workflows. LD decay file labels are stored as `sample_id`; when
`pop_group` is supplied, matching labels are mapped to `pop`. The
plotting helpers then regroup the mapped LD decay rows by population
label so line layers stay population-specific after relabeling.

## Examples

``` r
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay", package = "ggpop")
ld <- import_ld_decay(ld_dir, type = "poplddecay")
ld |> plot_ld_decay(style = "point")

ld |> plot_ld_decay(style = "line")
```
