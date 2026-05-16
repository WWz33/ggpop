# ggpop theme helpers

Theme helpers for ggpop plots. \`theme_tidyplot()\` is the primary
tidyplot-style theme used by the PCA and GWAS modules. The minimal
variants selectively keep one or both axes visible.

## Usage

``` r
theme_tidyplot(plot, fontsize = 7)
theme_ggplot2(plot, fontsize = 7)
theme_minimal_xy(plot, fontsize = 7)
theme_minimal_x(plot, fontsize = 7)
theme_minimal_y(plot, fontsize = 7)
style_void(plot, fontsize = 7)
```

## Arguments

- plot:

  A ggplot object.

- fontsize:

  Base font size.
