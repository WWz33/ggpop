\name{theme_tidyplot}
\alias{theme_tidyplot}
\alias{theme_ggplot2}
\alias{theme_minimal_xy}
\alias{theme_minimal_x}
\alias{theme_minimal_y}
\alias{style_void}
\title{ggpop theme helpers}
\usage{
theme_tidyplot(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_ggplot2(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_xy(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_x(plot, base_size = 7, base_family = "", fontsize = NULL)
theme_minimal_y(plot, base_size = 7, base_family = "", fontsize = NULL)
style_void(plot, base_size = 7, base_family = "", fontsize = NULL)
}
\arguments{
\item{plot}{A ggplot object.}
\item{base_size}{Base font size.}
\item{base_family}{Base font family.}
\item{fontsize}{Compatibility alias for `base_size`.}
}
\description{
Theme helpers for ggpop plots. `theme_tidyplot()` is the primary tidyplot-style theme used by the PCA and GWAS modules. The minimal variants selectively keep one or both axes visible.
}
