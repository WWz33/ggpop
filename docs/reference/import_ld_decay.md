# Import LD decay results

Import LD decay summaries into a typed tidy object for use with
[`plot_ld_decay()`](https://wwz33.github.io/ggpop/reference/geom_ld_decay.md)
or `ggpop() + geom_ld_decay()`. PopLDdecay `*.stat.gz` files are read
directly. PLINK pairwise `*.ld` files are summarized into distance bins.

## Usage

``` r
import_ld_decay(
  dir = NULL,
  ...,
  type = c("poplddecay", "plink", "auto"),
  pop = NULL,
  pop_group = NULL,
  bin_size = 200
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

- bin_size:

  Distance bin width in base pairs for PLINK pairwise LD files.

## Value

A `ggpop_ld_decay` tidy S3 data frame with standardized columns
including `dist`, `dist_kb`, `r2`, `pop`, and `n_pairs`.

## Details

Population grouping follows the package-wide convention: `pop_group` is
the standard two-column `sample pop` table used by PCA and admixture
workflows. LD decay file labels are stored as `sample_id`; when
`pop_group` is supplied, matching labels are mapped to `pop`.

## Examples

``` r
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay", package = "ggpop")
ld <- import_ld_decay(ld_dir, type = "poplddecay")
ld |> plot_ld_decay(style = "point")

ld |> plot_ld_decay(style = "line")
```
