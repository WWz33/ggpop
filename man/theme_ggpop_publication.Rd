\name{theme_ggpop_publication}
\alias{theme_ggpop_publication}
\alias{ggpop_palette}
\alias{scale_fill_ggpop}
\alias{scale_colour_ggpop}
\title{Publication-oriented ggpop styles}
\usage{
theme_ggpop_publication(base_size = 11, base_family = "",
  legend_position = "top", grid = c("major", "none", "both"))
ggpop_palette(n, palette = c("publication", "admixture", "manhattan"))
scale_fill_ggpop(n = NULL, palette = c("admixture", "publication"), ...)
scale_colour_ggpop(n = NULL, palette = c("manhattan", "publication"), ...)
}
\arguments{
\item{base_size, base_family}{Base text size and font family passed to ggplot2 themes.}
\item{legend_position}{Legend placement accepted by ggplot2.}
\item{grid}{Panel grid style.}
\item{n}{Number of colours.}
\item{palette}{Palette family.}
\item{...}{Additional arguments passed to the ggplot2 scale constructor.}
}
\description{
Helpers for publication-oriented ggpop figures: a clean theme, colour palettes, and discrete fill/colour scales.
}
