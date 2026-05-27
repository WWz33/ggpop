# Effective population size history plots

Plot effective population size through time from PSMC, MSMC2, SMC++, and
Stairway Plot 2 outputs.

## Usage

``` r
geom_ne_history(
  mapping = ggplot2::aes(x = .data$time, y = .data$ne, colour = .data$sample_id),
  data = NULL,
  ...,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  colour_by = c("sample_id", "method"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_ne_history(
  data,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  ...
)

geom_demographic_history(
  mapping = ggplot2::aes(x = .data$time, y = .data$ne, colour = .data$sample_id),
  data = NULL,
  ...,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  colour_by = c("sample_id", "method"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_demographic_history(
  data,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  ...
)
```

## Arguments

- mapping:

  Aesthetic mapping. Defaults to time, Ne, and sample colour.

- data:

  A `ggpop_ne_history` object from
  [`import_ne_history()`](https://wwz33.github.io/ggPopi/reference/import_ne_history.md).

- ...:

  Additional geom parameters.

- sample_id, method:

  Optional sample/population or method filters.

- style:

  Draw `"auto"`, `"step"`, `"line"`, or `"point"` layers. `"auto"`
  follows common tool conventions: SMC++ histories use lines, while
  PSMC, MSMC2, and Stairway Plot 2 histories use step curves.

- ci:

  Draw confidence interval ribbons when `ne_lower` and `ne_upper` are
  available.

- colour_by:

  Colour by sample or method.

- size, alpha:

  Layer appearance.

- base_size, base_family:

  Base theme font controls.

- palette:

  ggpop discrete palette.

- log_x, log_y:

  Use log10 time and Ne axes.

- na.rm, show.legend, inherit.aes:

  Standard ggplot2 layer arguments.

- title, subtitle, caption:

  Optional plot labels. No default title is added.

## Value

`geom_ne_history()` and `geom_demographic_history()` return a list of
ggplot layers. `plot_ne_history()` and `plot_demographic_history()`
return a ggplot object.

## Details

SMC++ bootstrap or replicate trajectories are drawn first as thin
low-alpha lines when common columns such as `type`, `plot_type`,
`replicate`, or `bootstrap` identify them. Main trajectories remain
visually dominant.

## Examples

``` r
smcpp <- import_ne_history(
  system.file("extdata", "ne_history", "SMC++", "model.csv", package = "ggpop"),
  type = "smcpp"
)
#> Error: `dir` must point to an existing directory or file.
smcpp |> plot_ne_history()
#> Error: object 'smcpp' not found
smcpp |> ggpop() + geom_ne_history()
#> Error: object 'smcpp' not found
```
