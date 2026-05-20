# Introgression plots

Plot introgression summaries from Dsuite, genomics_general,
TreeMix-style edge summaries, or ADMIXTOOLS2 qpGraph edge tables.
Windowed statistics use chromosome-wise Manhattan-like points or
regional point-and-line traces, trio summaries use a horizontal dot
plot, and graph inputs use a compact edge diagram.

## Usage

``` r
geom_introgression(
  mapping = NULL,
  data = NULL,
  ...,
  stat = "all",
  analysis = c("auto", "window", "trio", "graph"),
  chr = NULL,
  start = NULL,
  end = NULL,
  style = c("auto", "window", "manhattan", "region", "trio", "graph"),
  colour_by = c("stat", "chr"),
  point_size = NULL,
  point_alpha = 0.9,
  base_size = 11,
  base_family = "",
  palette = "publication",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_introgression(
  data,
  stat = "all",
  analysis = c("auto", "window", "trio", "graph"),
  chr = NULL,
  start = NULL,
  end = NULL,
  style = c("auto", "window", "manhattan", "region", "trio", "graph"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  point_size = NULL,
  point_alpha = 0.9,
  ...
)
```

## Arguments

- mapping:

  Optional aesthetic mapping. Defaults are chosen from the resolved plot
  style.

- data:

  A `ggpop_introgression` object from
  [`import_introgression()`](https://wwz33.github.io/ggPopi/reference/import_introgression.md).

- ...:

  Additional geom parameters.

- stat:

  Introgression statistic names to plot, e.g. `c("D", "fdM")` or
  `"all"`.

- analysis:

  Optional analysis class filter: `"window"`, `"trio"`, or `"graph"`.

- chr:

  Optional chromosome vector for windowed results.

- start, end:

  Optional genomic region boundaries in base pairs for windowed results.

- style:

  Plot layout. `"auto"` uses chromosome-wise Manhattan-like points for
  genome-wide window statistics, a point-and-line regional axis for
  local window calls, a trio dot plot for Dtrios-style summaries, and an
  edge diagram for graph data. `"manhattan"` is accepted as a
  compatibility alias for `"window"`.

- colour_by:

  Colour window plots by statistic or chromosome.

- point_size, point_alpha:

  Layer appearance. Genome-wide window plots use this value as point
  size; region plots use it as point size and draw a thinner connecting
  line.

- base_size, base_family:

  Base theme font controls.

- palette:

  ggpop discrete palette.

- na.rm, show.legend, inherit.aes:

  Standard ggplot2 layer arguments.

- title, subtitle, caption:

  Optional plot labels. No default title is added.

## Value

`geom_introgression()` returns a list of ggplot layers.
`plot_introgression()` returns a ggplot object.

## Examples

``` r
intro_dir <- system.file("extdata", "introgression", "genomics_general", package = "ggpop")
intro <- import_introgression(intro_dir, type = "genomics_general")
#> Error: `dir` must point to an existing directory.
intro |> plot_introgression(stat = c("D", "fdM"))
#> Error: object 'intro' not found
intro |> plot_introgression(stat = "D", chr = "1")
#> Error: object 'intro' not found
intro |> ggpop() + geom_introgression(stat = "D")
#> Error: object 'intro' not found
```
