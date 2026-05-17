# ggpop theme helpers

Theme helpers for ggpop plots. \`theme_tidyplot()\` is the primary
tidyplot-style theme used by the PCA and GWAS modules. The minimal
variants selectively keep one or both axes visible.

## 用法

``` r
theme_tidyplot(plot, fontsize = 7, base_family = "")
theme_ggplot2(plot, fontsize = 7, base_family = "")
theme_minimal_xy(plot, fontsize = 7, base_family = "")
theme_minimal_x(plot, fontsize = 7, base_family = "")
theme_minimal_y(plot, fontsize = 7, base_family = "")
style_void(plot, fontsize = 7, base_family = "")
```

## 参数

- plot:

  A ggplot object.

- fontsize:

  Base font size.

- base_family:

  Base font family.
