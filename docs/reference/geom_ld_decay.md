# LD decay plots

Plot LD decay summaries as either point or line plots. The x-axis is
pairwise distance in kilobases and the y-axis defaults to mean LD
\\r^2\\, with optional D-prime or combined \\r^2\\/D-prime views. All
styles support population colouring through the package-wide `pop`
column, and `pop_group` can relabel and regroup imported files.

## Usage

``` r
geom_ld_decay(
  mapping = ggplot2::aes(x = .data$dist_kb, y = .data$r2),
  data = NULL,
  ...,
  pop = NULL,
  pop_group = NULL,
  style = c("point", "line"),
  measure = c("r2", "D", "both"),
  colour_by = c("pop", "file"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_ld_decay(
  data,
  pop = NULL,
  pop_group = NULL,
  style = c("point", "line"),
  measure = c("r2", "D", "both"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  ...
)
```

## Arguments

- mapping:

  Aesthetic mapping. Defaults to pairwise distance in Kb and mean LD
  \\r^2\\.

- data:

  A `ggpop_ld_decay` object from
  [`import_ld_decay()`](https://wwz33.github.io/ggpop/reference/import_ld_decay.md).

- ...:

  Additional geom parameters.

- pop:

  Optional population labels to keep.

- pop_group:

  Optional population group table or path to the standard two-column
  `sample pop` file. File labels are matched through `sample`, then
  regrouped by the mapped population labels.

- style:

  Draw `"point"` or `"line"` layers.

- measure:

  Plot `r^2`, D-prime, or both measures together.

- colour_by:

  Colour by population or source file.

- size, alpha:

  Layer appearance. Point plots default to size 1, matching common LD
  decay summaries.

- base_size, base_family:

  Base theme font controls.

- palette:

  ggpop discrete palette.

- na.rm, show.legend, inherit.aes:

  Standard ggplot2 layer arguments.

- title, subtitle, caption:

  Optional plot labels. No default title is added.

## Value

`geom_ld_decay()` returns a list of ggplot layers. `plot_ld_decay()`
returns a ggplot object.

## Examples

``` r
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay", package = "ggpop")
ld <- import_ld_decay(ld_dir, type = "poplddecay")
groups <- import_pop_group(system.file("extdata", "pop_group.txt", package = "ggpop"))
ld |> plot_ld_decay(pop_group = groups, style = "point")

ld |> plot_ld_decay(pop_group = groups, style = "line")

ld |> ggpop() + geom_ld_decay(pop_group = groups, style = "point")
```
