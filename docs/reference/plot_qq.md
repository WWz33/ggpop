# Publication-oriented GWAS Q-Q plots

High-level publication-oriented Q-Q plot builder. The direct path is
\`import_gwas(...) \|\> plot_qq()\`, and the tidy extension path is
\`import_gwas(...) \|\> ggpop() + geom_qq()\`.

## 用法

``` r
plot_qq(data, title = "Q-Q plot", subtitle = NULL, caption = NULL,
  show_lambda = TRUE, use_fastman = TRUE, point_size = 0.8,
  point_alpha = 0.8, base_size = 11, base_family = "",
  legend_position = "none", ...)
```

## 参数

- data:

  A \`ggpop_gwas\` object.

- title, subtitle, caption:

  Plot text.

- show_lambda:

  Display genomic inflation factor on Q-Q plots.

- use_fastman:

  Use \`fastman::fastqq_gg()\` when available.

- point_size, point_alpha:

  Point appearance.

- base_size, base_family, legend_position:

  Publication theme settings.

- ...:

  Additional layer or backend arguments.
