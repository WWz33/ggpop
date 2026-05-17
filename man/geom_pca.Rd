\name{geom_pca}
\alias{geom_pca}
\title{PCA scatter layer}
\usage{
geom_pca(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
  data = NULL, ..., pc_x = 1, pc_y = 2, base_size = 11,
  base_family = "", palette = NULL, pop_group = TRUE, na.rm = FALSE,
  show.legend = NA, inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to PC1 and PC2.}
\item{data}{Optional layer data.}
\item{...}{Additional parameters passed to `geom_point()`.}
\item{pc_x}{Principal component index for x.}
\item{pc_y}{Principal component index for y.}
\item{base_size}{Base font size for the tidyplot-style ggpop theme.}
\item{base_family}{Base font family for the tidyplot-style ggpop theme.}
\item{palette}{Discrete ggpop palette name or hex vector for population colours.}
\item{pop_group}{Use imported `pop` metadata for population colours when available.}
\item{na.rm}{Remove missing values.}
\item{show.legend}{Legend display.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a PCA plot as a list of ggplot layers: the point layer, PC axis labels with variance contribution when available, unified discrete population colour scale when `pop` is present, and the tidyplot-style ggpop theme from `theme_tidyplot()`. `geom_pca()` is the ggplot extension path paired with direct `plot_pca()`.
}
