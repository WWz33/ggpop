# PCA scatter layer

Adds a PCA plot as a list of ggplot layers: the point layer, PC axis
labels with variance contribution when available, unified discrete
population colour scale when \`pop\` is present, and the tidyplot-style
ggpop theme from \`theme_tidyplot()\`. \`geom_pca()\` is the ggplot
extension path paired with direct \`plot_pca()\`.

## Usage

``` r
geom_pca(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
  data = NULL, ..., pc_x = 1, pc_y = 2, base_size = 11,
  base_family = "", palette = NULL, pop_group = TRUE, na.rm = FALSE,
  show.legend = NA, inherit.aes = TRUE)
```

## Arguments

- mapping:

  Aesthetic mapping. Defaults to PC1 and PC2.

- data:

  Optional layer data.

- ...:

  Additional parameters passed to \`geom_point()\`.

- pc_x:

  Principal component index for x.

- pc_y:

  Principal component index for y.

- base_size:

  Base font size for the tidyplot-style ggpop theme.

- base_family:

  Base font family for the tidyplot-style ggpop theme.

- palette:

  Discrete ggpop palette name or hex vector for population colours.

- pop_group:

  Use imported \`pop\` metadata for population colours when available.

- na.rm:

  Remove missing values.

- show.legend:

  Legend display.

- inherit.aes:

  Inherit plot aesthetics.
