\name{plot_manha}
\alias{plot_manha}
\title{Publication-oriented Manhattan plots}
\usage{
plot_manha(data, title = NULL, subtitle = NULL, caption = NULL,
  threshold = 5e-8, suggestive = 1e-5,
  threshold_color = .gwas_threshold_color(),
  suggestive_color = .gwas_suggestive_color(), point_size = 1.404,
  point_alpha = 0.9, base_size = 11, base_family = "", legend_position = "none",
  logp = TRUE, maxP = 14, bybp = FALSE, palette = "manhattan",
  binary = FALSE, ...)
}
\arguments{
\item{data}{A `ggpop_gwas` object.}
\item{title, subtitle, caption}{Plot text.}
\item{threshold, suggestive}{Manhattan reference p-value thresholds.}
\item{threshold_color, suggestive_color}{Reference-line colours. Defaults use the unified ggpop publication palette and can be overridden explicitly.}
\item{point_size, point_alpha}{Point appearance.}
\item{base_size, base_family, legend_position}{Publication theme settings.}
\item{logp, maxP, bybp}{Core fastman-style controls forwarded by `plot_manha()` and mirrored by `geom_manha()`.}
\item{palette}{A ggpop palette name or a character vector of hex colours for Manhattan plots.}
\item{binary}{If `TRUE`, repeat two palette colours across chromosomes for a binary alternating Manhattan plot. If `FALSE`, use one discrete colour per chromosome.}
\item{...}{Additional layer or backend arguments.}
}
\description{
High-level publication-oriented Manhattan plot builder. `plot_manha()` and the tidy extension path `ggpop(data) + geom_manha()` share ggpop's internal fastman-style ggplot implementation.
}
