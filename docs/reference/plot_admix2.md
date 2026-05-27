# Pure ggplot-style admixture plots

\`plot_admix2()\` and \`geom_admix2()\` provide the pure ggplot-style
ADMIXTURE layout: stacked bars, assignment-based sample ordering,
\`theme_minimal()\`, Brewer \`Paired\` fills by default, and
script-style free facets by K and population group. The original
\`plot_admix()\` and \`geom_admix()\` remain the pophelper-style
interfaces.

## Usage

``` r
plot_admix2(data, title = NULL, subtitle = NULL, caption = NULL,
  sort = c("assignment", "none", "label"), k = "all", palette = "Paired",
  group = "pop", show_legend = FALSE, show_sample_labels = FALSE,
  base_size = 12, base_family = "", bar_width = 1, strip_angle = 30, ...)

geom_admix2(mapping = NULL, data = NULL, ...,
  sort = c("assignment", "none", "label"), k = "all", palette = "Paired",
  group = "pop", bar_width = 1, show.legend = FALSE,
  show_sample_labels = FALSE, base_size = 12, base_family = "",
  strip_angle = 30, na.rm = FALSE, inherit.aes = TRUE)
```

## Arguments

- data:

  A \`ggpop_admix\` object, or optional layer data for
  \`geom_admix2()\`.

- title, subtitle, caption:

  Plot text.

- sort:

  Sample ordering: \`assignment\` orders by most likely cluster and
  descending assignment probability, \`none\` keeps input order, and
  \`label\` orders sample labels.

- k:

  K selection: \`"all"\`, a single integer, or an integer vector.

- palette:

  A single RColorBrewer palette name such as \`"Paired"\`, or a manual
  cluster colour vector.

- group:

  Population group column used for script-style free facets. Set to
  \`NULL\` to draw without group facets.

- show_legend, show.legend:

  Legend display switches.

- show_sample_labels:

  Display sample labels on the x axis.

- base_size, base_family:

  Theme font settings.

- bar_width:

  Admixture bar width.

- strip_angle:

  Facet strip text angle.

- mapping:

  Ignored. Admixture layers define their own required aesthetics.

- ...:

  Additional arguments passed to \`ggplot2::geom_col()\`.

- na.rm:

  Remove missing values.

- inherit.aes:

  Inherit plot aesthetics.
