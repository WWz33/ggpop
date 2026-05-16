\name{theme_tidyplot}
\alias{theme_tidyplot}
\alias{theme_ggplot2}
\alias{theme_minimal_xy}
\alias{theme_minimal_x}
\alias{theme_minimal_y}
\alias{style_void}
\title{ggpop theme helpers}
\usage{
theme_tidyplot(plot, fontsize = 7, base_family = "")
theme_ggplot2(plot, fontsize = 7, base_family = "")
theme_minimal_xy(plot, fontsize = 7, base_family = "")
theme_minimal_x(plot, fontsize = 7, base_family = "")
theme_minimal_y(plot, fontsize = 7, base_family = "")
style_void(plot, fontsize = 7, base_family = "")
}
\arguments{
\item{plot}{A ggplot object.}
\item{fontsize}{Base font size.}
\item{base_family}{Base font family.}
}
\description{
Theme helpers for ggpop plots. `theme_tidyplot()` is the primary tidyplot-style theme used by the PCA and GWAS modules. The minimal variants selectively keep one or both axes visible.
}
