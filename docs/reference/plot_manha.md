# Publication-oriented Manhattan plots

High-level publication-oriented Manhattan plot builder. \`plot_manha()\`
and the tidy extension path \`ggpop(data) + geom_manha()\` share ggpop's
internal fastman-style ggplot implementation.

## Usage

``` r
plot_manha(data, title = NULL, subtitle = NULL, caption = NULL,
  threshold = 5e-8, suggestive = 1e-5, point_size = 0.9,
  point_alpha = NA, base_size = 11, base_family = "",
  legend_position = "none", logp = TRUE, maxP = 14, bybp = FALSE,
  palette = "manhattan", binary = FALSE, ...)
```

## Arguments

- data:

  A \`ggpop_gwas\` object.

- title, subtitle, caption:

  Plot text.

- threshold, suggestive:

  Manhattan reference p-value thresholds.

- point_size, point_alpha:

  Point appearance.

- base_size, base_family, legend_position:

  Publication theme settings.

- logp, maxP, bybp:

  Core fastman-style controls forwarded by \`plot_manha()\` and mirrored
  by \`geom_manha()\`.

- palette:

  A ggpop palette name or a character vector of hex colours for
  Manhattan plots.

- binary:

  If \`TRUE\`, repeat two palette colours across chromosomes for a
  binary alternating Manhattan plot. If \`FALSE\`, use one discrete
  colour per chromosome.

- ...:

  Additional layer or backend arguments.
