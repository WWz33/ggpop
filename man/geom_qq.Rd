\name{geom_qq}
\alias{geom_qq}
\alias{geom_qq_pub}
\title{Q-Q plot layer for GWAS p-values}
\usage{
geom_qq(mapping = ggplot2::aes(p = .data$p), data = NULL, geom = "point",
  position = "identity", ..., size = 0.8, alpha = 0.8, colour = "black",
  diagonal = TRUE, diagonal_colour = "red", show_lambda = TRUE,
  maxP = 14, fix_zero = TRUE, speedup = TRUE, base_size = 11,
  na.rm = FALSE, show.legend = FALSE, inherit.aes = TRUE)
geom_qq_pub(mapping = ggplot2::aes(p = .data$p), data = NULL, ...,
  size = 0.8, alpha = 0.8, diagonal = TRUE, diagonal_colour = "red",
  show_lambda = TRUE, maxP = 14, fix_zero = TRUE, speedup = TRUE,
  base_size = 11, show.legend = FALSE, inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to `p`.}
\item{data}{Optional layer data.}
\item{geom}{Geom used for rendering.}
\item{position}{Position adjustment.}
\item{...}{Additional layer parameters.}
\item{na.rm}{Remove missing values.}
\item{size, alpha, colour}{Point appearance for publication style.}
\item{diagonal}{Draw the expected-equals-observed diagonal.}
\item{diagonal_colour}{Diagonal line colour.}
\item{show_lambda}{Display genomic inflation factor.}
\item{maxP}{Maximum displayed `-log10(p)` value, following `fastman::fastqq_gg()`.}
\item{fix_zero}{Replace zero p-values with the minimum non-zero p-value before log transform.}
\item{speedup}{Round expected and observed values to reduce duplicate points, following `fastman::fastqq_gg()`.}
\item{base_size}{Base font size for the tidyplot-style ggpop theme.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a Q-Q plot as a list of ggplot layers using the same core p-value cleaning, truncation, speedup, red diagonal, and lambda annotation contract as `fastman::fastqq_gg()`, while applying the tidyplot-style ggpop theme from `theme_tidyplot()`. `geom_qq_pub()` is the publication-style layer used by native `plot_qq(..., use_fastman = FALSE)`.
}
