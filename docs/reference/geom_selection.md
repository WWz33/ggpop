# Selective sweep scan plots

Plot selective sweep scan statistics along chromosomes or selected
genomic regions. Supports common selscan outputs such as iHS, nSL,
iHH12, XP-EHH, and XP-nSL tables, plus XPCLR window tables imported with
[`import_selection()`](https://wwz33.github.io/ggpop/reference/import_selection.md).

## Usage

``` r
geom_selection(
  mapping = ggplot2::aes(x = .data$pos/1e+06, y = .data$value),
  data = NULL,
  ...,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = c("point", "line"),
  colour_by = c("stat", "chr"),
  value = c("signed", "absolute"),
  threshold = NULL,
  threshold_type = c("value", "quantile"),
  threshold_color = "#D55E00",
  threshold_linetype = "dashed",
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_selection(
  data,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = "point",
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  value = c("signed", "absolute"),
  threshold = NULL,
  threshold_type = c("value", "quantile"),
  style = c("auto", "single", "manhattan"),
  binary = FALSE,
  threshold_color = "#D55E00",
  threshold_linetype = "dashed",
  point_size = NULL,
  point_alpha = NULL,
  ...
)
```

## Arguments

- mapping:

  Aesthetic mapping. Defaults to position in Mb and selection score.

- data:

  A `ggpop_selection` object from
  [`import_selection()`](https://wwz33.github.io/ggpop/reference/import_selection.md).

- ...:

  Additional geom parameters.

- stat:

  Selection statistic names to plot, e.g. `c("ihs", "xpehh")` or
  `"all"`.

- chr:

  Optional chromosome vector.

- start, end:

  Optional genomic region boundaries in base pairs.

- geom:

  Draw `"point"` or `"line"` layers.

- colour_by:

  Colour by statistic or chromosome.

- value:

  Plot signed scores or absolute scores. Absolute mode replaces `value`
  with `abs(value)` and draws only positive threshold lines.

- threshold:

  Optional threshold. With `threshold_type = "value"`, this is a score
  cutoff such as `2`. With `threshold_type = "quantile"`, values between
  0 and 1 are interpreted as quantile probabilities such as `0.95`.

- threshold_type:

  Interpret `threshold` as fixed score values or quantile probabilities.
  Quantiles are computed from absolute scores after statistic,
  chromosome, and region filtering.

- style:

  Direct plot layout. `"auto"` uses a Manhattan-like chromosome axis
  unless `chr`, `start`, or `end` is supplied; local calls use the
  single-region position axis. Use `"manhattan"` or `"single"` to force
  a layout.

- binary:

  Use two alternating chromosome colours for Manhattan-like selection
  plots. The default `"manhattan"` palette alternates `#4E79A7` and
  `#C4E2F3`.

- threshold_color, threshold_linetype:

  Threshold line appearance.

- size, alpha:

  Layer appearance for `geom_selection()`.

- point_size, point_alpha:

  Point appearance for `plot_selection()`. Single-region plots default
  to smaller points; Manhattan-like plots default to the GWAS Manhattan
  point style.

- base_size, base_family:

  Base theme font controls.

- palette:

  ggpop discrete palette.

- na.rm, show.legend, inherit.aes:

  Standard ggplot2 layer arguments.

- title, subtitle, caption:

  Optional plot labels. No default title is added.

## Value

`geom_selection()` returns a list of ggplot layers. `plot_selection()`
returns a ggplot object.

## Examples

``` r
selscan_dir <- system.file("extdata", "selective_sweep", "selscan", package = "ggpop")
selection <- import_selection(selscan_dir, type = "selscan")
#> Error: `dir` must point to an existing directory.
selection |> plot_selection(stat = "ihs", value = "absolute")
#> Error: object 'selection' not found
selection |> plot_selection(stat = c("ihs", "xpehh"), chr = "1")
#> Error: object 'selection' not found
selection |> ggpop() + geom_selection(stat = "ihs", chr = "1", threshold = 2)
#> Error: object 'selection' not found
selection |> plot_selection(stat = "ihs", chr = "1", value = "absolute",
  threshold = 0.95, threshold_type = "quantile")
#> Error: object 'selection' not found
```
