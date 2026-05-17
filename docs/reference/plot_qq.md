# Publication-oriented GWAS Q-Q plots

High-level publication-oriented Q-Q plot builder. The direct path is
\`import_gwas(...) \|\> plot_qq()\`, and the tidy extension path is
\`import_gwas(...) \|\> ggpop() + geom_qq()\`.

## Usage

``` r
plot_qq(data, title = NULL, subtitle = NULL, caption = NULL,
  show_lambda = TRUE, point_size = 0.8,
  diagonal_color = .gwas_threshold_color(), diagonal_colour = NULL,
  point_alpha = 0.8, base_size = 11, base_family = "",
  legend_position = "none", ...)
```

## Arguments

- data:

  A \`ggpop_gwas\` object.

- title, subtitle, caption:

  Plot text.

- show_lambda:

  Display genomic inflation factor on Q-Q plots.

- diagonal_color:

  Diagonal line colour. Defaults to the unified ggpop publication
  threshold colour and can be overridden explicitly.

- diagonal_colour:

  Deprecated spelling kept for compatibility. Prefer \`diagonal_color\`.

- point_size, point_alpha:

  Point appearance.

- base_size, base_family, legend_position:

  Publication theme settings.

- ...:

  Additional layer or backend arguments.
