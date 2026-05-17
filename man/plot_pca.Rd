\name{plot_pca}
\alias{plot_pca}
\title{Publication-oriented PCA plots}
\usage{
plot_pca(data, title = NULL, subtitle = NULL, caption = NULL,
  pc_x = 1, pc_y = 2, point_size = 1.8, point_alpha = 0.85,
  base_size = 11, base_family = "", legend_position = "right",
  palette = NULL, ...)
}
\arguments{
\item{data}{A `ggpop_pca` object.}
\item{title, subtitle, caption}{Plot text.}
\item{pc_x, pc_y}{Principal components to plot.}
\item{point_size, point_alpha}{Point appearance.}
\item{base_size, base_family, legend_position}{Publication theme settings.}
\item{palette}{Discrete ggpop palette name or hex vector for population colours.}
\item{...}{Additional layer arguments.}
}
\description{
High-level publication-oriented PCA plot builder. When `pop_group` was supplied to `import_pca()`, population groups are mapped to the unified ggpop discrete colour scale by default.
}
