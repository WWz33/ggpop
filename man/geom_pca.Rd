\name{geom_pca}
\alias{geom_pca}
\alias{geom_pca_pub}
\title{PCA scatter layer}
\usage{
geom_pca(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
  data = NULL, ..., pc_x = 1, pc_y = 2, base_size = 11, palette = NULL, na.rm = FALSE,
  show.legend = NA, inherit.aes = TRUE)
geom_pca_pub(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
  data = NULL, ..., pc_x = 1, pc_y = 2, size = 1.8, alpha = 0.85,
  na.rm = FALSE, base_size = 11, show.legend = NA, palette = NULL,
  inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to PC1 and PC2.}
\item{data}{Optional layer data.}
\item{...}{Additional parameters passed to `geom_point()`.}
\item{pc_x}{Principal component index for x.}
\item{pc_y}{Principal component index for y.}
\item{base_size}{Base font size for the tidyplot-style ggpop theme.}
\item{palette}{Discrete ggpop palette name or hex vector for population colours.}
\item{size, alpha}{Point appearance for publication style.}
\item{na.rm}{Remove missing values.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a PCA plot as a list of ggplot layers: the point layer, unified discrete population colour scale when `pop` is present, and the tidyplot-style ggpop theme from `theme_tidyplot()`. `geom_pca_pub()` is the publication-style layer used by `plot_pca()`.
}
