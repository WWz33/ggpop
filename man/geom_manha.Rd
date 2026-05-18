\name{geom_manha}
\alias{geom_manha}
\title{Manhattan plot layer}
\usage{
geom_manha(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, geom = "point", position = "identity", ..., threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = .gwas_threshold_color(),
  suggestive_colour = .gwas_suggestive_color(),
  threshold_color = NULL, suggestive_color = NULL,
  size = 1.5, shape = 20, speedup = TRUE, logp = TRUE, maxP = 14,
  bybp = FALSE, palette = "manhattan", binary = FALSE, base_size = 11,
  base_family = "", na.rm = FALSE, show.legend = FALSE, inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to `chr`, `pos`, and `p`.}
\item{data}{Optional layer data.}
\item{geom}{Geom used for rendering.}
\item{position}{Position adjustment.}
\item{...}{Additional layer parameters.}
\item{threshold}{Genome-wide p-value threshold line.}
\item{suggestive}{Suggestive p-value threshold line.}
\item{size, shape, speedup}{Point appearance and fastman-style duplicate compression.}
\item{logp}{Transform p-values to `-log10(p)`, following ggpop's internal fastman-style layout.}
\item{maxP}{Maximum displayed transformed value.}
\item{bybp}{Display position in Mb rather than combined chromosome scale.}
\item{palette}{A ggpop palette name or a character vector of hex colours.}
\item{binary}{If `TRUE`, repeat two colours across chromosomes for a binary alternating Manhattan palette. If `FALSE`, assign one discrete colour per chromosome.}
\item{base_size}{Base font size for the default module theme.}
\item{base_family}{Base font family for the default module theme.}
\item{threshold_colour, suggestive_colour}{Reference-line colours. Defaults use the unified ggpop publication palette and can be overridden explicitly.}
\item{threshold_color, suggestive_color}{Compatibility aliases for `threshold_colour` and `suggestive_colour`.}
\item{na.rm}{Remove missing values.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a Manhattan plot as a list of ggplot layers: the data layer, threshold lines, fastman-style scales, and the default module theme. `geom_manha()` is the ggplot extension path paired with direct `plot_manha()`.
}
