# ggpop theme helpers

Theme helpers for ggpop plots. \`theme_tidyplot()\` is the primary
tidyplot-style theme used by the PCA and GWAS modules. The minimal
variants selectively keep one or both axes visible.

## Usage

``` r
theme_tidyplot(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_ggplot2(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_xy(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_x(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_y(plot, base_size = 7, base_family = "", fontsize = NULL)
style_void(plot, base_size = 7, base_family = "", fontsize = NULL)
```

## Arguments

- plot:

  A ggplot object.

- base_size:

  Base font size.

- base_family:

  Base font family.

- fontsize:

  Compatibility alias for \`base_size\`.
