\name{geom_manha}
\alias{geom_manha}
\alias{geom_manha_pub}
\title{Manhattan plot layer}
\usage{
geom_manha(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, geom = "point", position = "identity", ..., threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = "red", suggestive_colour = "blue",
  size = 0.9, shape = 20, speedup = TRUE, logp = TRUE, maxP = 14,
  bybp = FALSE, base_size = 11, na.rm = FALSE, show.legend = FALSE,
  inherit.aes = TRUE)
geom_manha_pub(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
  data = NULL, ..., size = 0.9, alpha = NA, threshold = 5e-8,
  suggestive = 1e-5, threshold_colour = "red", suggestive_colour = "blue",
  speedup = TRUE, logp = TRUE, maxP = 14, bybp = FALSE, base_size = 11,
  show.legend = FALSE, inherit.aes = TRUE)
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
\item{logp}{Transform p-values to `-log10(p)`, following `fastman::fastman_gg()`.}
\item{maxP}{Maximum displayed transformed value.}
\item{bybp}{Display position in Mb rather than combined chromosome scale.}
\item{base_size}{Base font size for the default module theme.}
\item{threshold_colour, suggestive_colour}{Reference-line colours.}
\item{alpha}{Point alpha for publication style.}
\item{na.rm}{Remove missing values.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a Manhattan plot as a list of ggplot layers: the data layer, threshold lines, fastman-style scales, and the default module theme. `geom_manha()` is the ggplot extension path paired with direct `plot_manha()`. `geom_manha_pub()` is retained as an advanced compatibility helper.
}
