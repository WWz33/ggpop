# Publication-oriented PCA plots

High-level publication-oriented PCA plot builder. When \`pop_group\` was
supplied to \`import_pca()\`, population groups are mapped to the
unified ggpop discrete colour scale by default.

## 用法

``` r
plot_pca(data, title = "PCA plot", subtitle = NULL, caption = NULL,
  pc_x = 1, pc_y = 2, point_size = 1.8, point_alpha = 0.85,
  base_size = 11, base_family = "", legend_position = "right",
  palette = NULL, ...)
```

## 参数

- data:

  A \`ggpop_pca\` object.

- title, subtitle, caption:

  Plot text.

- pc_x, pc_y:

  Principal components to plot.

- point_size, point_alpha:

  Point appearance.

- base_size, base_family, legend_position:

  Publication theme settings.

- palette:

  Discrete ggpop palette name or hex vector for population colours.

- ...:

  Additional layer arguments.
