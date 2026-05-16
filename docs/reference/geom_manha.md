# Manhattan plot layer

Adds a Manhattan plot as a list of ggplot layers: the data layer,
threshold lines, fastman-style scales, and the default module theme.
\`geom_manha()\` is the ggplot extension path paired with direct
\`plot_manha()\`. \`geom_manha_pub()\` is retained as an advanced
compatibility helper.

## Usage

``` r
geom_manha(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, geom = "point", position = "identity", ..., threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = "red", suggestive_colour = "blue",
  size = 0.9, shape = 20, speedup = TRUE, logp = TRUE, maxP = 14,
  bybp = FALSE, palette = "manhattan", binary = FALSE, base_size = 11,
  na.rm = FALSE, show.legend = FALSE, inherit.aes = TRUE)
geom_manha_pub(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, ..., size = 0.9, alpha = NA, threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = "red", suggestive_colour = "blue",
  speedup = TRUE, logp = TRUE, maxP = 14, bybp = FALSE,
  palette = "manhattan", binary = FALSE, base_size = 11, show.legend = FALSE,
  inherit.aes = TRUE)
```

## Arguments

- mapping:

  Aesthetic mapping. Defaults to \`chr\`, \`pos\`, and \`p\`.

- data:

  Optional layer data.

- geom:

  Geom used for rendering.

- position:

  Position adjustment.

- ...:

  Additional layer parameters.

- threshold:

  Genome-wide p-value threshold line.

- suggestive:

  Suggestive p-value threshold line.

- size, shape, speedup:

  Point appearance and fastman-style duplicate compression.

- logp:

  Transform p-values to \`-log10(p)\`, following
  \`fastman::fastman_gg()\`.

- maxP:

  Maximum displayed transformed value.

- bybp:

  Display position in Mb rather than combined chromosome scale.

- palette:

  A ggpop palette name or a character vector of hex colours.

- binary:

  If \`TRUE\`, repeat two colours across chromosomes for a binary
  alternating Manhattan palette. If \`FALSE\`, assign one discrete
  colour per chromosome.

- base_size:

  Base font size for the default module theme.

- threshold_colour, suggestive_colour:

  Reference-line colours.

- alpha:

  Point alpha for publication style.

- na.rm:

  Remove missing values.

- show.legend:

  Legend display.

- inherit.aes:

  Inherit plot aesthetics.
