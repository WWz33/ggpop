# Publication-oriented ggpop styles

Helpers for publication-oriented ggpop figures: a clean theme, colour
palettes, and discrete fill/colour scales.

## 用法

``` r
theme_ggpop_publication(base_size = 11, base_family = "",
  legend_position = "top", grid = c("major", "none", "both"))
ggpop_palette(n, palette = c("publication", "admixture", "manhattan"))
scale_fill_ggpop(n = NULL, palette = c("admixture", "publication"), ...)
scale_colour_ggpop(n = NULL, palette = c("manhattan", "publication"), ...)
```

## 参数

- base_size, base_family:

  Base text size and font family passed to ggplot2 themes.

- legend_position:

  Legend placement accepted by ggplot2.

- grid:

  Panel grid style.

- n:

  Number of colours.

- palette:

  Palette family.

- ...:

  Additional arguments passed to the ggplot2 scale constructor.
