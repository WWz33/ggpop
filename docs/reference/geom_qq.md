# Q-Q plot layer for GWAS p-values

Adds a Q-Q plot as a list of ggplot layers using the same core p-value
cleaning, truncation, speedup, red diagonal, and lambda annotation
contract as \`fastman::fastqq_gg()\`, while applying the tidyplot-style
ggpop theme from \`theme_tidyplot()\`. \`geom_qq_pub()\` is the
publication-style layer used by native \`plot_qq(..., use_fastman =
FALSE)\`.

## 用法

``` r
geom_qq(mapping = ggplot2::aes(p = .data$p), data = NULL, geom = "point",
  position = "identity", ..., size = 0.8, alpha = 0.8, colour = "black",
  diagonal = TRUE, diagonal_colour = "red", show_lambda = TRUE,
  maxP = 14, fix_zero = TRUE, speedup = TRUE, base_size = 11,
  base_family = "", lambda_size = base_size * 0.9, na.rm = FALSE,
  show.legend = FALSE, inherit.aes = TRUE)
geom_qq_pub(mapping = ggplot2::aes(p = .data$p), data = NULL, ...,
  size = 0.8, alpha = 0.8, diagonal = TRUE, diagonal_colour = "red",
  show_lambda = TRUE, maxP = 14, fix_zero = TRUE, speedup = TRUE,
  base_size = 11, base_family = "", lambda_size = base_size * 0.9,
  show.legend = FALSE, inherit.aes = TRUE)
```

## 参数

- mapping:

  Aesthetic mapping. Defaults to \`p\`.

- data:

  Optional layer data.

- geom:

  Geom used for rendering.

- position:

  Position adjustment.

- ...:

  Additional layer parameters.

- na.rm:

  Remove missing values.

- size, alpha, colour:

  Point appearance for publication style.

- diagonal:

  Draw the expected-equals-observed diagonal.

- diagonal_colour:

  Diagonal line colour.

- show_lambda:

  Display genomic inflation factor.

- maxP:

  Maximum displayed \`-log10(p)\` value, following
  \`fastman::fastqq_gg()\`.

- fix_zero:

  Replace zero p-values with the minimum non-zero p-value before log
  transform.

- speedup:

  Round expected and observed values to reduce duplicate points,
  following \`fastman::fastqq_gg()\`.

- base_size:

  Base font size for the tidyplot-style ggpop theme.

- base_family:

  Base font family for the tidyplot-style ggpop theme.

- lambda_size:

  Font size for the genomic inflation factor annotation.

- show.legend:

  Legend display.

- inherit.aes:

  Inherit plot aesthetics.
