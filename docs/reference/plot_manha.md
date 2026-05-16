# Publication-oriented Manhattan plots

High-level publication-oriented plot builders. \`plot_manha()\` is the
Manhattan direct API, and \`plot_gwas()\` remains a compatibility alias
only. The reference visual standard is \`plot_manha(..., use_fastman =
TRUE)\`, and the tidy extension path is \`ggpop(data) + geom_manha()\`.

## Usage

``` r
plot_manha(data, title = "Manhattan plot", subtitle = NULL, caption = NULL,
  threshold = 5e-8, suggestive = 1e-5, use_fastman = TRUE,
  point_size = 0.9, point_alpha = NA, base_size = 11,
  base_family = "", legend_position = "none", logp = TRUE, maxP = 14,
  bybp = FALSE, palette = "manhattan", binary = FALSE, ...)
plot_gwas(data, ...)
```

## Arguments

- data:

  A \`ggpop_gwas\` object.

- title, subtitle, caption:

  Plot text.

- threshold, suggestive:

  Manhattan reference p-value thresholds.

- use_fastman:

  Use \`fastman::fastman_gg()\` when available.

- point_size, point_alpha:

  Point appearance.

- base_size, base_family, legend_position:

  Publication theme settings. \`base_family\` and \`legend_position\`
  are retained for fastman compatibility; native GWAS paths use
  \`base_size\` through the module geom defaults.

- logp, maxP, bybp:

  Core \`fastman::fastman_gg()\` controls forwarded by \`plot_manha()\`
  and mirrored by \`geom_manha()\`.

- palette:

  A ggpop palette name or a character vector of hex colours for native
  Manhattan plots. Non-default palettes use the native ggplot
  implementation even when \`use_fastman = TRUE\`.

- binary:

  If \`TRUE\`, repeat two palette colours across chromosomes for a
  binary alternating Manhattan plot. If \`FALSE\`, use one discrete
  colour per chromosome.

- ...:

  Additional layer or backend arguments.
