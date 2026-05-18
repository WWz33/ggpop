# Import selective sweep scan results

Import selective sweep scan results into a typed tidy object for use
with
[`plot_selection()`](https://wwz33.github.io/ggpop/reference/geom_selection.md)
or `ggpop() + geom_selection()`.

## Usage

``` r
import_selection(dir = NULL, ..., type = c("selscan", "xpclr", "auto"))
```

## Arguments

- dir:

  Directory containing selective sweep scan result files.

- ...:

  Optional named file paths. Relative paths are resolved inside `dir`.

- type:

  Input type. Supports `"selscan"` and `"xpclr"`.

## Value

A `ggpop_selection` tidy S3 data frame with standardized columns
including `stat`, `chr`, `pos`, `value`, and `score_type`.

## Examples

``` r
selscan_dir <- system.file("extdata", "selective_sweep", "selscan", package = "ggpop")
selection <- import_selection(selscan_dir, type = "selscan")
selection |> plot_selection(stat = "ihs", chr = "1")

xpclr_dir <- system.file("extdata", "selective_sweep", "xpclr", package = "ggpop")
xpclr <- import_selection(xpclr_dir, type = "xpclr")
xpclr |> plot_selection(stat = "xpclr", chr = "1", start = 1, end = 1600000)
```
