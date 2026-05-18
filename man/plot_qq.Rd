\name{plot_qq}
\alias{plot_qq}
\title{Publication-oriented GWAS Q-Q plots}
\usage{
plot_qq(data, title = NULL, subtitle = NULL, caption = NULL,
  show_lambda = TRUE, point_size = 0.8,
  diagonal_colour = .gwas_threshold_color(), diagonal_color = NULL,
  point_alpha = 0.8, base_size = 11, base_family = "",
  legend_position = "none", ...)
}
\arguments{
\item{data}{A `ggpop_gwas` object.}
\item{title, subtitle, caption}{Plot text.}
\item{show_lambda}{Display genomic inflation factor on Q-Q plots.}
\item{diagonal_colour}{Diagonal line colour. Defaults to the unified ggpop publication threshold colour and can be overridden explicitly.}
\item{diagonal_color}{Compatibility alias for `diagonal_colour`.}
\item{point_size, point_alpha}{Point appearance.}
\item{base_size, base_family, legend_position}{Publication theme settings.}
\item{...}{Additional layer or backend arguments.}
}
\description{
High-level publication-oriented Q-Q plot builder. The direct path is `import_gwas(...) |> plot_qq()`, and the tidy extension path is `import_gwas(...) |> ggpop() + geom_qq()`.
}
