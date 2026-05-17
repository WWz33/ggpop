# Import population genomics summary statistics

Import windowed population genomics statistics such as FST, pi, Dxy,
Watterson's theta, and Tajima's D for tidy ggpop plotting.

## Usage

``` r
import_stats(dir = NULL, ..., type = c("pixy", "vcftools", "auto"))
```

## Arguments

- dir:

  Directory containing pixy or vcftools result files. Files are
  auto-discovered by suffix.

- ...:

  Optional named files such as `pi = "pixy_pi.txt"` or
  `fst = "pixy_fst.txt"`. Relative paths are resolved inside `dir`.

- type:

  Input format. Supports `"pixy"`, `"vcftools"`, and `"auto"`.

## Value

A `ggpop_stats` data frame with normalized columns: `stat`, `chr`,
`start`, `end`, `pos`, and `value`.

## Examples

``` r
pixy_dir <- system.file("extdata", "Population_genomics_statistics", "pixy", package = "ggpop")
stats <- import_stats(pixy_dir, type = "pixy")
stats |> plot_stats(stat = c("fst", "pi"), chr = "chr2L")
```
