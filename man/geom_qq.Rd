\name{geom_qq}
\alias{geom_qq}
\title{Q-Q plot layer for GWAS p-values}
\usage{
geom_qq(mapping = ggplot2::aes(p = .data$p), data = NULL, geom = "point",
  position = "identity", ..., size = 0.8, alpha = 0.8, colour = "black",
  diagonal = TRUE, diagonal_color = .gwas_threshold_color(),
  diagonal_colour = NULL, show_lambda = TRUE,
  maxP = 14, fix_zero = TRUE, speedup = TRUE, base_size = 11,
  base_family = "", lambda_size = base_size * 0.65, na.rm = FALSE,
  show.legend = FALSE, inherit.aes = TRUE)
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
\item{diagonal_color}{Diagonal line colour. Defaults to the unified ggpop publication threshold colour and can be overridden explicitly.}
\item{diagonal_colour}{Deprecated spelling kept for compatibility. Prefer `diagonal_color`.}
\item{show_lambda}{Display genomic inflation factor.}
\item{maxP}{Maximum displayed `-log10(p)` value, following ggpop's internal fastqq-style layout.}
\item{fix_zero}{Replace zero p-values with the minimum non-zero p-value before log transform.}
\item{speedup}{Round expected and observed values to reduce duplicate points, following ggpop's internal fastqq-style layout.}
\item{base_size}{Base font size for the tidyplot-style ggpop theme.}
\item{base_family}{Base font family for the tidyplot-style ggpop theme.}
\item{lambda_size}{Font size for the genomic inflation factor annotation.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a Q-Q plot as a list of ggplot layers using the same core p-value cleaning, truncation, speedup, publication-palette diagonal, and lambda annotation contract as ggpop's internal fastqq-style layout, while applying the tidyplot-style ggpop theme from `theme_tidyplot()`. `geom_qq()` is the ggplot extension path paired with direct `plot_qq()`.
}
