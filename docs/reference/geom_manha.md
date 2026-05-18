# Manhattan plot layer

Adds a Manhattan plot as a list of ggplot layers: the data layer,
threshold lines, fastman-style scales, and the default module theme.
\`geom_manha()\` is the ggplot extension path paired with direct
\`plot_manha()\`.

## Usage

``` r
geom_manha(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, geom = "point", position = "identity", ..., threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = .gwas_threshold_color(),
  suggestive_colour = .gwas_suggestive_color(),
  threshold_color = NULL, suggestive_color = NULL,
  size = 1.5, shape = 20, speedup = TRUE, logp = TRUE, maxP = 14,
  bybp = FALSE, palette = "manhattan", binary = FALSE, base_size = 11,
  base_family = "", na.rm = FALSE, show.legend = FALSE, inherit.aes = TRUE)
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

  Transform p-values to \`-log10(p)\`, following ggpop's internal
  fastman-style layout.

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

- base_family:

  Base font family for the default module theme.

- threshold_colour, suggestive_colour:

  Reference-line colours. Defaults use the unified ggpop publication
  palette and can be overridden explicitly.

- threshold_color, suggestive_color:

  Compatibility aliases for \`threshold_colour\` and
  \`suggestive_colour\`.

- na.rm:

  Remove missing values.

- show.legend:

  Legend display.

- inherit.aes:

  Inherit plot aesthetics.
